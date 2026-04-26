local M = {}

local icons = require('core.icons')
local loader = require('core.pkg.loader')

-- State ----------------------------------------------------------------------

---@type snacks.win?
local win = nil

---@type 'plugins'|'tests'
local active_tab = 'plugins'

--- Filter text for plugin search.
---@type string
local filter_text = ''

--- Expanded plugin details.
---@type table<string, boolean>
local expanded = {}

--- All specs reference (set on open).
---@type table<string, table>
local specs = {}

--- Git info cache: git_cache[name] = { org, repo, branch, hash, has_update, updating }
---@type table<string, table>
local git_cache = {}

--- Background update check results (persists across modal open/close).
---@type table<string, boolean>
local pending_updates = {}

--- Update progress state.
---@type { current: number, total: number }?
local update_progress = nil

--- Test results: list of { desc = { file, group, name }, state = 'Pass'|'Fail', error? }
---@type table[]?
local test_results = nil

--- Test run state.
---@type 'idle'|'running'|'done'
local test_state = 'idle'

--- Timer for periodic update checks.
---@type uv_timer_t?
local check_timer = nil

-- Constants ------------------------------------------------------------------

local ns = vim.api.nvim_create_namespace('MiniPackUI')
local PACK_PATH = require('core.pkg.sources').PACK_PATH
local PAD = '   '
local PAD_ITEM = PAD .. '  '

-- Highlights -----------------------------------------------------------------

local function setup_highlights()
  local ok, palettes = pcall(require, 'catppuccin.palettes')
  if not ok then return end
  local C = palettes.get_palette()

  local groups = {
    MiniPackH2 = { fg = C.text, bold = true },
    MiniPackComment = { fg = C.overlay0 },
    MiniPackBranch = { fg = C.mauve },
    MiniPackName = { fg = C.blue },
    MiniPackUpdate = { fg = C.yellow },
    MiniPackUpdating = { fg = C.sapphire },
    MiniPackSep = { fg = C.surface1 },
    MiniPackTab = { fg = C.surface2 },
    MiniPackTabActive = { fg = C.sapphire, bold = true },
    MiniPackBullet = { fg = C.green },
    MiniPackBulletNotLoaded = { fg = C.overlay0 },
    MiniPackBulletUpdate = { fg = C.yellow },
    MiniPackBulletUpdating = { fg = C.sapphire },
    MiniPackHash = { fg = C.surface2 },
    MiniPackTime = { fg = C.peach },
    MiniPackStatNum = { fg = C.overlay0 },
    MiniPackTestPass = { fg = C.green },
    MiniPackTestFail = { fg = C.red },
    MiniPackTestFile = { fg = C.blue, bold = true },
    MiniPackTestGroup = { fg = C.mauve },
    MiniPackFooterKey = { fg = C.sapphire, bold = true },
    MiniPackFooterLabel = { fg = C.subtext0 },
  }

  for group, hl in pairs(groups) do
    hl.default = true
    vim.api.nvim_set_hl(0, group, hl)
  end
end

-- Helpers --------------------------------------------------------------------

--- Apply a highlight to a buffer line region.
---@param buf number
---@param line number 0-indexed
---@param col_start number
---@param col_end number
---@param hl_group string
local function buf_hl(buf, line, col_start, col_end, hl_group)
  vim.api.nvim_buf_add_highlight(buf, ns, hl_group, line, col_start, col_end)
end

--- Parse org/repo from a src URL.
---@param src? string
---@return string org, string repo
local function parse_org_repo(src)
  if not src then return '—', '—' end
  local org, repo = src:match('([^/]+)/([^/]+)$')
  if repo then repo = repo:gsub('%.git$', '') end
  return org or '—', repo or '—'
end

--- Scan installed plugin directories from disk (cached, invalidated on PackChanged).
---@return string[]
local _scan_cache ---@type string[]?

local function scan_installed()
  if _scan_cache then return _scan_cache end

  local names = {} ---@type string[]
  if vim.fn.isdirectory(PACK_PATH) == 0 then return names end

  local handle = vim.uv.fs_scandir(PACK_PATH)
  if not handle then return names end

  while true do
    local name, ftype = vim.uv.fs_scandir_next(handle)
    if not name then break end
    if ftype == 'directory' then
      names[#names + 1] = name
    end
  end

  table.sort(names)
  _scan_cache = names
  return names
end

vim.api.nvim_create_autocmd('User', {
  pattern = 'PackChanged',
  callback = function()
    _scan_cache = nil
  end,
})

--- Try resolving a git ref to a trimmed hash. Calls callback(hash) or callback(nil).
---@param path string
---@param ref string
---@param callback fun(hash: string?)
local function try_rev_parse(path, ref, callback)
  vim.system({ 'git', '-C', path, 'rev-parse', ref }, { text = true }, function(out)
    if out.code == 0 and out.stdout and vim.trim(out.stdout) ~= '' then
      callback(vim.trim(out.stdout))
    else
      callback(nil)
    end
  end)
end

--- Try a list of git refs in order, calling callback with the first that resolves.
---@param path string
---@param refs string[]
---@param callback fun(hash: string?)
local function try_refs(path, refs, callback)
  local i = 0
  local function next_ref()
    i = i + 1
    if i > #refs then return callback(nil) end
    try_rev_parse(path, refs[i], function(hash)
      if hash then
        callback(hash)
      else
        next_ref()
      end
    end)
  end
  next_ref()
end

--- Resolve the remote ref to compare against (detached HEAD has no @{u}).
--- For tagged checkouts, compares against the latest remote tag.
--- Otherwise tries: @{u} → origin/HEAD → origin/main → origin/master.
---@param path string plugin directory path
---@param callback fun(hash: string?) called with upstream hash or nil
local function resolve_upstream(path, callback)
  -- Check if HEAD is on a tag
  vim.system({ 'git', '-C', path, 'describe', '--tags', '--exact-match', 'HEAD' }, { text = true }, function(tag_out)
    if tag_out.code == 0 and tag_out.stdout and vim.trim(tag_out.stdout) ~= '' then
      -- HEAD is a tag — compare against latest remote tag
      vim.system({ 'git', '-C', path, 'tag', '--sort=-v:refname', '--list' }, { text = true }, function(tags_out)
        if tags_out.code == 0 and tags_out.stdout then
          local latest_tag = tags_out.stdout:match('^([^\n]+)')
          if latest_tag and vim.trim(latest_tag) ~= '' then
            return try_rev_parse(path, vim.trim(latest_tag) .. '^{commit}', callback)
          end
        end
        callback(nil)
      end)
      return
    end

    -- Not a tag — try branch-based refs in order
    try_refs(path, { '@{u}', 'origin/HEAD', 'origin/main', 'origin/master' }, callback)
  end)
end

--- Fetch git hash, branch and upstream info for a single plugin.
---@param path string plugin directory path
---@param info table git info table to populate
---@param done function callback when done
local function fetch_git_info(path, info, done)
  vim.system(
    { 'git', '-C', path, 'log', '--format=%h|||%H', '-1' },
    { text = true },
    function(out)
      if out.code == 0 and out.stdout then
        local short, full = out.stdout:match('([^|]+)|||(.+)')
        if short then info.hash = vim.trim(short) end
        info._full_hash = full and vim.trim(full) or nil
      end

      vim.system(
        { 'git', '-C', path, 'name-rev', '--name-only', 'HEAD' },
        { text = true },
        function(name_out)
          if name_out.code == 0 and name_out.stdout then
            local ref = vim.trim(name_out.stdout)
            if ref ~= '' and ref ~= 'undefined' then
              ref = ref:gsub('^remotes/origin/', '')
              ref = ref:gsub('^remotes/', '')
              ref = ref:gsub('^origin/', '')
              ref = ref:gsub('^tags/', '')
              ref = ref:gsub('~%d+$', '')
              ref = ref:gsub('%^%d+$', '')
              info.branch = ref
            end
          end

          resolve_upstream(path, function(upstream_hash)
            if upstream_hash and info._full_hash then
              info.has_update = info._full_hash ~= upstream_hash
            end
            done()
          end)
        end
      )
    end
  )
end

--- Refresh git cache for all installed plugins, then re-render.
local function refresh_git_cache()
  local names = scan_installed()
  local remaining = #names

  if remaining == 0 then return end

  local function on_complete()
    remaining = remaining - 1
    if remaining == 0 then
      vim.schedule(function() M._render() end)
    end
  end

  for _, name in ipairs(names) do
    local path = PACK_PATH .. '/' .. name
    local info = git_cache[name] or {}
    local spec = specs[name]
    local org, repo = parse_org_repo(spec and spec.src)
    info.org = org
    info.repo = repo
    info.branch = '…'
    info.hash = '…'
    info.has_update = false
    info.updating = false
    git_cache[name] = info

    if org == '—' then
      vim.system(
        { 'git', '-C', path, 'remote', 'get-url', 'origin' },
        { text = true },
        function(remote_out)
          if remote_out.code == 0 and remote_out.stdout then
            local url = vim.trim(remote_out.stdout)
            url = url:gsub('^git@github%.com:', 'https://github.com/')
            local r_org, r_repo = parse_org_repo(url)
            info.org = r_org
            info.repo = r_repo
          end
          fetch_git_info(path, info, on_complete)
        end
      )
    else
      fetch_git_info(path, info, on_complete)
    end
  end
end

-- Background updates ---------------------------------------------------------

--- Check for pending updates in the background (git fetch + compare).
---@param callback? function Called when check is complete
local function check_updates_bg(callback)
  local names = scan_installed()
  local remaining = #names

  if remaining == 0 then
    if callback then callback() end
    return
  end

  for _, name in ipairs(names) do
    local path = PACK_PATH .. '/' .. name

    vim.system({ 'git', '-C', path, 'fetch', '--quiet' }, { text = true }, function()
      vim.system({ 'git', '-C', path, 'rev-parse', 'HEAD' }, { text = true }, function(local_out)
        resolve_upstream(path, function(upstream_hash)
          local has_update = false
          if local_out.code == 0 and upstream_hash then
            local local_hash = vim.trim(local_out.stdout or '')
            has_update = local_hash ~= '' and local_hash ~= upstream_hash
          end

          pending_updates[name] = has_update
          if git_cache[name] then
            git_cache[name].has_update = has_update
          end

          remaining = remaining - 1
          if remaining == 0 then
            vim.schedule(function()
              if win and win.buf and vim.api.nvim_buf_is_valid(win.buf) then
                M._render()
              end
              if callback then callback() end
            end)
          end
        end)
      end)
    end)
  end
end

-- Test runner ----------------------------------------------------------------

--- Run tests headless and capture results via JSON.
local function run_tests()
  if test_state == 'running' then return end
  test_state = 'running'
  test_results = nil
  M._render()

  local config_dir = vim.fn.stdpath('config')

  vim.system({
    vim.v.progpath,
    '--headless',
    '-u', config_dir .. '/tests/minimal_init.lua',
    '-l', config_dir .. '/tests/run.lua',
  }, { text = true, cwd = config_dir }, function(out)
    vim.schedule(function()
      if out.code == 0 and out.stdout and out.stdout ~= '' then
        local ok, parsed = pcall(vim.json.decode, out.stdout)
        if ok and type(parsed) == 'table' then
          test_results = parsed
        else
          test_results = {}
          vim.notify('[MiniPack] Failed to parse test results', vim.log.levels.WARN)
        end
      else
        test_results = {}
        local err = out.stderr or ''
        if err ~= '' then
          vim.notify('[MiniPack] Test run failed: ' .. err, vim.log.levels.WARN)
        end
      end
      test_state = 'done'
      M._render()
    end)
  end)
end

-- Render: Plugins tab --------------------------------------------------------

--- Check if a spec has expandable details.
---@param spec? table
---@return boolean
local function has_details(spec)
  if not spec then return false end
  return spec.event ~= nil or spec.cmd ~= nil or spec.keys ~= nil
    or spec.dependencies ~= nil or spec.version ~= nil
end

--- Build a single plugin entry (line string + metadata).
---@param name string
---@return { name: string, line: string, info: table, is_loaded: boolean, load_time: number?, has_details: boolean }
local function build_plugin_entry(name)
  local is_loaded = loader.is_loaded(name) or package.loaded[name] ~= nil
  local info = git_cache[name] or {}
  local load_time = loader.load_time(name)

  if pending_updates[name] ~= nil then
    info.has_update = pending_updates[name]
  end

  local spec = specs[name]
  local src_org, src_repo = parse_org_repo(spec and spec.src)
  if src_org == '—' and info.org and info.org ~= '—' then
    src_org, src_repo = info.org, info.repo
  end

  local display_name = (src_org ~= '—' and src_repo ~= '—')
      and (src_org .. '/' .. src_repo)
    or name

  local has_det = has_details(spec)

  local bullet = (info.updating or info.has_update) and icons.misc.bullet_open or icons.misc.bullet

  local update_str = ''
  if info.updating then
    update_str = '  updating…'
  elseif info.has_update then
    update_str = '  update available'
  end

  local time_str = ''
  if load_time then
    time_str = string.format('  %.1fms', load_time)
  end

  local details_icon = has_det and (' ' .. icons.kinds.Constant) or ''

  return {
    name = name,
    line = string.format(
      '%s%s%s%s - %s - %s%s%s',
      PAD_ITEM, bullet, display_name, details_icon, info.branch or '…', info.hash or '…', time_str, update_str
    ),
    info = info,
    is_loaded = is_loaded,
    load_time = load_time,
    has_details = has_det,
  }
end

--- Render expanded details for a plugin.
---@param name string
---@param lines string[]
---@param hl function
local function render_plugin_details(name, lines, hl)
  local spec = specs[name]
  if not spec then return end

  local detail_pad = PAD_ITEM .. '    '
  local fields = {}

  if spec.event then
    fields[#fields + 1] = { 'event', table.concat(spec.event, ', ') }
  end
  if spec.cmd then
    fields[#fields + 1] = { 'cmd', table.concat(spec.cmd, ', ') }
  end
  if spec.keys then
    local key_strs = {}
    for _, k in ipairs(spec.keys) do
      if k[1] then key_strs[#key_strs + 1] = k[1] end
    end
    if #key_strs > 0 then
      fields[#fields + 1] = { 'keys', table.concat(key_strs, ', ') }
    end
  end
  if spec.dependencies then
    local dep_names = {}
    for _, dep in ipairs(spec.dependencies) do
      dep_names[#dep_names + 1] = dep.name or '?'
    end
    fields[#fields + 1] = { 'deps', table.concat(dep_names, ', ') }
  end
  if spec.lazy ~= nil then
    fields[#fields + 1] = { 'lazy', tostring(spec.lazy) }
  end
  if spec.version then
    fields[#fields + 1] = { 'version', spec.version }
  end

  for _, f in ipairs(fields) do
    local detail_line = detail_pad .. f[1] .. ': ' .. f[2]
    local line_idx = #lines
    lines[#lines + 1] = detail_line
    -- Label highlight
    hl(line_idx, #detail_pad, #detail_pad + #f[1], 'MiniPackBranch')
    -- Value highlight
    hl(line_idx, #detail_pad + #f[1] + 2, #detail_line, 'MiniPackComment')
  end
end

--- Apply highlights to a plugin entry line.
---@param entry table plugin entry from build_plugin_entry
---@param line_idx number 0-indexed line
---@param hl function highlight adder: hl(line, col_start, col_end, group)
---@param default_bullet_hl string highlight for normal bullet
local function hl_plugin_entry(entry, line_idx, hl, default_bullet_hl)
  local info = entry.info
  local line = entry.line

  -- Bullet
  if info.updating then
    hl(line_idx, 0, #PAD_ITEM + #icons.misc.bullet_open, 'MiniPackBulletUpdating')
  elseif info.has_update then
    hl(line_idx, 0, #PAD_ITEM + #icons.misc.bullet_open, 'MiniPackBulletUpdate')
  else
    hl(line_idx, 0, #PAD_ITEM + #icons.misc.bullet, default_bullet_hl)
  end

  -- Name (org/repo)
  local name_part = (info.org and info.repo and info.org ~= '—')
      and (info.org .. '/' .. info.repo)
    or entry.name
  local name_start = line:find(name_part, 1, true)
  if name_start then
    hl(line_idx, name_start - 1, name_start - 1 + #name_part, 'MiniPackName')
  end

  -- Details icon (after name)
  if entry.has_details and name_start then
    local icon_start = name_start - 1 + #name_part + 1 -- +1 for the space before icon
    hl(line_idx, icon_start, icon_start + #icons.kinds.Constant, 'MiniPackComment')
  end

  -- Find the " - branch - hash" section after name
  local after_name = name_start and (name_start + #name_part) or (#PAD_ITEM + 1)

  -- Branch
  local branch_val = info.branch or '…'
  local branch_start = line:find(branch_val, after_name, true)
  if branch_start then
    hl(line_idx, branch_start - 1, branch_start - 1 + #branch_val, 'MiniPackBranch')
  end

  -- Hash (search after branch to avoid matching branch's '…' when both are '…')
  local after_branch = branch_start and (branch_start + #branch_val) or after_name
  local hash_val = info.hash or '…'
  local hash_start = line:find(hash_val, after_branch, true)
  if hash_start then
    hl(line_idx, hash_start - 1, hash_start - 1 + #hash_val, 'MiniPackHash')
  end

  -- Load time
  if entry.load_time then
    local time_str = string.format('%.1fms', entry.load_time)
    local time_start = line:find(time_str, (hash_start or after_branch) + #hash_val, true)
    if time_start then
      hl(line_idx, time_start - 1, time_start - 1 + #time_str, 'MiniPackTime')
    end
  end

  -- Update status
  if info.updating then
    local s = line:find('updating…', 1, true)
    if s then hl(line_idx, s - 1, #line, 'MiniPackUpdating') end
  elseif info.has_update then
    local s = line:find('update available', 1, true)
    if s then hl(line_idx, s - 1, #line, 'MiniPackUpdate') end
  end
end

--- Render plugins tab content.
---@param lines string[] line buffer (mutated)
---@param hl function highlight adder
local function render_plugins_tab(lines, hl)
  local names = scan_installed()
  local loaded_list = {} ---@type table[]
  local not_loaded_list = {} ---@type table[]

  local filter_lower = filter_text ~= '' and filter_text:lower() or nil

  for _, name in ipairs(names) do
    if filter_lower and not name:lower():find(filter_lower, 1, true) then
      -- Check org/repo match too
      local spec = specs[name]
      if spec and spec.src then
        local _, repo = parse_org_repo(spec.src)
        if not (repo and repo:lower():find(filter_lower, 1, true)) then
          goto continue
        end
      else
        goto continue
      end
    end

    local entry = build_plugin_entry(name)
    if entry.is_loaded then
      loaded_list[#loaded_list + 1] = entry
    else
      not_loaded_list[#not_loaded_list + 1] = entry
    end

    ::continue::
  end

  -- Stats
  lines[#lines + 1] = ''
  local status = require('core.pkg.status')
  local st = status.stats()
  local startup_str = st.startuptime > 0 and string.format('    Startup: %.1fms', st.startuptime) or ''
  local stats = string.format(
    '%sTotal: %d    Loaded: %d    Not Loaded: %d%s',
    PAD, #names, #loaded_list, #not_loaded_list, startup_str
  )
  lines[#lines + 1] = stats

  local stat_idx = #lines - 1
  local function hl_stat(label, count)
    local pos = stats:find(label, 1, true)
    if pos then
      local num_start = stats:find('%d+', pos + #label)
      if num_start then
        hl(stat_idx, num_start - 1, num_start - 1 + #tostring(count), 'MiniPackStatNum')
      end
    end
  end
  hl_stat('Total: ', #names)
  hl_stat('Loaded: ', #loaded_list)
  hl_stat('Not Loaded: ', #not_loaded_list)

  -- Startup time highlight
  if startup_str ~= '' then
    local su_start = stats:find('Startup: ', 1, true)
    if su_start then
      local time_str = string.format('%.1fms', st.startuptime)
      local ts = stats:find(time_str, su_start, true)
      if ts then hl(stat_idx, ts - 1, ts - 1 + #time_str, 'MiniPackTime') end
    end
  end

  -- Filter indicator
  if filter_text ~= '' then
    local filter_line = PAD .. icons.misc.search .. 'Filter: ' .. filter_text
    lines[#lines + 1] = filter_line
    local fl_idx = #lines - 1
    hl(fl_idx, 0, #PAD + #icons.misc.search, 'MiniPackTabActive')
    hl(fl_idx, #PAD + #icons.misc.search + #'Filter: ', #filter_line, 'MiniPackName')
  end

  -- Update progress
  if update_progress then
    local prog_line = string.format(
      '%s%s Updating %d/%d…', PAD, icons.misc.duck, update_progress.current, update_progress.total
    )
    lines[#lines + 1] = prog_line
    hl(#lines - 1, 0, #prog_line, 'MiniPackUpdating')
  end

  --- Render a section (Loaded or Not Loaded).
  ---@param header_label string
  ---@param entries table[]
  ---@param bullet_hl string
  local function render_section(header_label, entries, bullet_hl)
    lines[#lines + 1] = ''
    local header = string.format('%s%s (%d)', PAD, header_label, #entries)
    lines[#lines + 1] = header
    local h_idx = #lines - 1
    hl(h_idx, 0, #header, 'MiniPackH2')
    local paren = header:find('%(')
    if paren then hl(h_idx, paren - 1, #header, 'MiniPackStatNum') end

    for _, entry in ipairs(entries) do
      local line_idx = #lines
      lines[#lines + 1] = entry.line
      hl_plugin_entry(entry, line_idx, hl, bullet_hl)

      if expanded[entry.name] then
        render_plugin_details(entry.name, lines, hl)
      end
    end
  end

  render_section('Loaded', loaded_list, 'MiniPackBullet')
  render_section('Not Loaded', not_loaded_list, 'MiniPackBulletNotLoaded')
end

-- Render: Tests tab ----------------------------------------------------------

--- Render tests tab content.
---@param lines string[] line buffer (mutated)
---@param hl function highlight adder
local function render_tests_tab(lines, hl)
  lines[#lines + 1] = ''

  if test_state == 'idle' then
    lines[#lines + 1] = PAD .. 'Press  r  to run tests'
    hl(#lines - 1, 0, -1, 'MiniPackComment')
    return
  end

  if test_state == 'running' then
    lines[#lines + 1] = PAD .. icons.misc.duck .. 'Running tests…'
    hl(#lines - 1, 0, -1, 'MiniPackUpdating')
    return
  end

  if not test_results then return end

  -- Stats
  local pass_count, fail_count = 0, 0
  for _, r in ipairs(test_results) do
    if r.state == 'Pass' then pass_count = pass_count + 1 else fail_count = fail_count + 1 end
  end

  local stats = string.format('%sTotal: %d    Pass: %d    Fail: %d', PAD, #test_results, pass_count, fail_count)
  lines[#lines + 1] = stats
  local stat_idx = #lines - 1

  local function hl_stat(label, count, group)
    local pos = stats:find(label, 1, true)
    if pos then
      local num_start = stats:find('%d+', pos + #label)
      if num_start then
        hl(stat_idx, num_start - 1, num_start - 1 + #tostring(count), group)
      end
    end
  end
  hl_stat('Total: ', #test_results, 'MiniPackStatNum')
  hl_stat('Pass: ', pass_count, 'MiniPackTestPass')
  hl_stat('Fail: ', fail_count, fail_count > 0 and 'MiniPackTestFail' or 'MiniPackStatNum')

  -- Group by file
  local by_file = {} ---@type table<string, table[]>
  local file_order = {} ---@type string[]
  for _, r in ipairs(test_results) do
    local file = r.desc and r.desc[1] or 'unknown'
    if not by_file[file] then
      by_file[file] = {}
      file_order[#file_order + 1] = file
    end
    by_file[file][#by_file[file] + 1] = r
  end

  for _, file in ipairs(file_order) do
    lines[#lines + 1] = ''
    local file_line = PAD .. file
    lines[#lines + 1] = file_line
    hl(#lines - 1, 0, #file_line, 'MiniPackTestFile')

    for _, r in ipairs(by_file[file]) do
      local is_pass = r.state == 'Pass'
      local icon = is_pass and icons.misc.check or icons.misc.cross
      local group = r.desc[2] or ''
      local test_name = r.desc[3] or r.desc[2] or ''
      local display = group ~= '' and test_name ~= '' and (group .. ' | ' .. test_name) or (group .. test_name)
      local entry_line = PAD_ITEM .. icon .. display
      local line_idx = #lines
      lines[#lines + 1] = entry_line

      -- Icon
      hl(line_idx, #PAD_ITEM, #PAD_ITEM + #icon, is_pass and 'MiniPackTestPass' or 'MiniPackTestFail')

      -- Group name
      if group ~= '' then
        local gs = entry_line:find(group, #PAD_ITEM + #icon + 1, true)
        if gs then hl(line_idx, gs - 1, gs - 1 + #group, 'MiniPackTestGroup') end
      end

      -- Test name (hash gray)
      if test_name ~= '' then
        local ns_pos = entry_line:find(test_name, #PAD_ITEM + #icon + #group + 1, true)
        if ns_pos then hl(line_idx, ns_pos - 1, ns_pos - 1 + #test_name, 'MiniPackHash') end
      end

      -- Error details
      if not is_pass and r.error then
        for _, err_line in ipairs(vim.split(r.error, '\n')) do
          local trimmed = vim.trim(err_line)
          if trimmed ~= '' then
            local err_entry = PAD_ITEM .. '  ' .. trimmed
            local err_idx = #lines
            lines[#lines + 1] = err_entry
            hl(err_idx, 0, #err_entry, 'MiniPackTestFail')
          end
        end
      end
    end
  end
end

-- Render (main) --------------------------------------------------------------

--- Build and render all content with highlights.
function M._render()
  if not win or not win.buf or not vim.api.nvim_buf_is_valid(win.buf) then return end

  local buf = win.buf
  local lines = {} ---@type string[]
  local highlights = {} ---@type { line: number, col_start: number, col_end: number, hl: string }[]

  local function hl(line_idx, cs, ce, group)
    highlights[#highlights + 1] = { line = line_idx, col_start = cs, col_end = ce, hl = group }
  end

  -- Tabs
  lines[#lines + 1] = ''
  local tab_plugins = PAD .. icons.misc.stack .. ' Plugins  '
  local tab_tests = '  ' .. icons.misc.task .. ' Tests  '
  local tab_line = tab_plugins .. '│' .. tab_tests

  if active_tab == 'plugins' then
    hl(#lines, 0, #tab_plugins, 'MiniPackTabActive')
    hl(#lines, #tab_plugins, #tab_plugins + 1, 'MiniPackSep')
    hl(#lines, #tab_plugins + 1, #tab_line, 'MiniPackTab')
  else
    hl(#lines, 0, #tab_plugins, 'MiniPackTab')
    hl(#lines, #tab_plugins, #tab_plugins + 1, 'MiniPackSep')
    hl(#lines, #tab_plugins + 1, #tab_line, 'MiniPackTabActive')
  end
  lines[#lines + 1] = tab_line

  -- Separator
  local win_width = win.win and vim.api.nvim_win_get_width(win.win) or 80
  local sep_pad = '  '
  local sep = sep_pad .. string.rep('─', win_width - #sep_pad * 2) .. sep_pad
  lines[#lines + 1] = sep
  hl(#lines - 1, 0, #sep, 'MiniPackSep')

  -- Tab content
  if active_tab == 'plugins' then
    render_plugins_tab(lines, hl)
  else
    render_tests_tab(lines, hl)
  end

  lines[#lines + 1] = ''

  -- Write to buffer
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  for _, h in ipairs(highlights) do
    buf_hl(buf, h.line, h.col_start, h.col_end, h.hl)
  end

  vim.bo[buf].modifiable = false
end

-- Actions --------------------------------------------------------------------

--- Get plugin name from current cursor line.
---@return string?
local function plugin_under_cursor()
  if not win or not win.buf then return nil end
  local line = vim.api.nvim_get_current_line()
  local org_repo = line:match('([%w%.%-_]+/[%w%.%-_]+)')
  if not org_repo then return nil end

  -- Match against spec src
  for name, spec in pairs(specs) do
    if spec.src then
      local org, repo = parse_org_repo(spec.src)
      if org ~= '—' and repo ~= '—' and (org .. '/' .. repo) == org_repo then
        return name
      end
    end
  end

  -- Match against git cache
  for name, info in pairs(git_cache) do
    if info.org and info.repo and (info.org .. '/' .. info.repo) == org_repo then
      return name
    end
  end

  -- Match by directory name
  for name, _ in pairs(specs) do
    if name == org_repo:match('[^/]+$') then
      return name
    end
  end

  return nil
end

--- Open the repository URL for plugin under cursor.
local function open_repo()
  local name = plugin_under_cursor()
  if not name then
    vim.notify('[MiniPack] No plugin under cursor', vim.log.levels.WARN)
    return
  end

  local spec = specs[name]
  if spec and spec.src then
    vim.ui.open(spec.src)
  else
    local path = PACK_PATH .. '/' .. name
    local out = vim.fn.system('git -C ' .. vim.fn.shellescape(path) .. ' remote get-url origin 2>/dev/null')
    local url = vim.trim(out)
    if url ~= '' and vim.v.shell_error == 0 then
      url = url:gsub('^git@github%.com:', 'https://github.com/')
      url = url:gsub('%.git$', '')
      vim.ui.open(url)
    else
      vim.notify('[MiniPack] No URL found for ' .. name, vim.log.levels.WARN)
    end
  end
end

--- Fallback update via git when vim.pack.update fails or doesn't checkout.
--- Fetches and checks out to the appropriate ref (latest tag or default branch).
---@param path string plugin directory
---@return boolean updated
local function git_fallback_update(path)
  -- Fetch
  local fetch = vim.system({ 'git', '-C', path, 'fetch', '--quiet', '--tags', '--force', 'origin' }, { text = true }):wait()
  if fetch.code ~= 0 then return false end

  local head_before = vim.trim((vim.system({ 'git', '-C', path, 'rev-parse', 'HEAD' }, { text = true }):wait()).stdout or '')

  -- Check if on a tag → checkout latest tag
  local tag_out = vim.system({ 'git', '-C', path, 'describe', '--tags', '--exact-match', 'HEAD' }, { text = true }):wait()
  if tag_out.code == 0 and tag_out.stdout and vim.trim(tag_out.stdout) ~= '' then
    local tags = vim.system({ 'git', '-C', path, 'tag', '--sort=-v:refname', '--list' }, { text = true }):wait()
    if tags.code == 0 and tags.stdout then
      local latest = vim.trim(tags.stdout:match('^([^\n]+)') or '')
      if latest ~= '' then
        vim.system({ 'git', '-C', path, 'checkout', '--quiet', latest }, { text = true }):wait()
      end
    end
  else
    -- Branch: resolve default branch ref
    local ref
    for _, candidate in ipairs({ 'origin/HEAD', 'origin/main', 'origin/master' }) do
      local rp = vim.system({ 'git', '-C', path, 'rev-parse', candidate }, { text = true }):wait()
      if rp.code == 0 and rp.stdout and vim.trim(rp.stdout) ~= '' then
        ref = vim.trim(rp.stdout)
        break
      end
    end
    if ref then
      vim.system({ 'git', '-C', path, 'checkout', '--quiet', ref }, { text = true }):wait()
    end
  end

  local head_after = vim.trim((vim.system({ 'git', '-C', path, 'rev-parse', 'HEAD' }, { text = true }):wait()).stdout or '')
  return head_before ~= head_after
end

--- Update all plugins with pending updates via vim.pack.
local function update_plugins()
  -- Collect plugins that have updates
  local to_update = {} ---@type string[]
  for name, has in pairs(pending_updates) do
    if has then to_update[#to_update + 1] = name end
  end
  for name, info in pairs(git_cache) do
    if info.has_update and not pending_updates[name] then
      to_update[#to_update + 1] = name
    end
  end

  if #to_update == 0 then
    vim.notify('[MiniPack] No updates available', vim.log.levels.INFO)
    return
  end

  -- Mark as updating
  for _, name in ipairs(to_update) do
    if git_cache[name] then
      git_cache[name].updating = true
    end
  end
  update_progress = { current = 0, total = #to_update }
  M._render()

  -- Update each plugin async, one at a time
  local updated_count = 0
  local failed = {} ---@type string[]

  local function finish()
    update_progress = nil
    if updated_count > 0 then
      vim.notify(string.format('[MiniPack] Updated %d plugin(s)', updated_count), vim.log.levels.INFO)
    end
    if #failed > 0 then
      vim.notify('[MiniPack] Failed to update: ' .. table.concat(failed, ', '), vim.log.levels.WARN)
    end
    refresh_git_cache()
  end

  local function update_next(i)
    if i > #to_update then
      return finish()
    end

    local name = to_update[i]
    local path = PACK_PATH .. '/' .. name

    vim.system({ 'git', '-C', path, 'rev-parse', 'HEAD' }, { text = true }, function(before_out)
      local head_before = before_out.code == 0 and vim.trim(before_out.stdout or '') or ''

      vim.schedule(function()
        local ok = pcall(vim.pack.update, { name }, { force = true })

        vim.system({ 'git', '-C', path, 'rev-parse', 'HEAD' }, { text = true }, function(after_out)
          vim.schedule(function()
            local head_after = after_out.code == 0 and vim.trim(after_out.stdout or '') or ''
            local changed = head_before ~= '' and head_before ~= head_after

            if not changed then
              changed = git_fallback_update(path)
            end

            if changed then
              updated_count = updated_count + 1
            elseif not ok then
              failed[#failed + 1] = name
            end

            if git_cache[name] then
              git_cache[name].updating = false
              git_cache[name].has_update = not changed
            end
            pending_updates[name] = not changed
            if update_progress then
              update_progress.current = update_progress.current + 1
            end
            M._render()

            update_next(i + 1)
          end)
        end)
      end)
    end)
  end

  update_next(1)
end

--- Check for updates without applying them.
local function check_for_updates()
  vim.notify('[MiniPack] Checking for updates…', vim.log.levels.INFO)
  check_updates_bg(function()
    local count = 0
    for _, has in pairs(pending_updates) do
      if has then count = count + 1 end
    end
    if count > 0 then
      vim.notify(string.format('[MiniPack] %d plugin(s) have updates available', count), vim.log.levels.INFO)
    else
      vim.notify('[MiniPack] All plugins are up to date', vim.log.levels.INFO)
    end
  end)
end

-- Footer & Tab switching -----------------------------------------------------

--- Build footer items based on active tab.
---@return table[] statusline-style chunks
local function build_footer()
  if active_tab == 'tests' then
    return {
      { ' q ', 'MiniPackFooterKey' },
      { 'Close ', 'MiniPackFooterLabel' },
      { ' r ', 'MiniPackFooterKey' },
      { 'Rerun ', 'MiniPackFooterLabel' },
      { ' <Tab> ', 'MiniPackFooterKey' },
      { 'Tab ', 'MiniPackFooterLabel' },
    }
  end

  return {
    { ' q ', 'MiniPackFooterKey' },
    { 'Close ', 'MiniPackFooterLabel' },
    { ' o ', 'MiniPackFooterKey' },
    { 'Open ', 'MiniPackFooterLabel' },
    { ' u ', 'MiniPackFooterKey' },
    { 'Update ', 'MiniPackFooterLabel' },
    { ' c ', 'MiniPackFooterKey' },
    { 'Check ', 'MiniPackFooterLabel' },
    { ' x ', 'MiniPackFooterKey' },
    { 'Clean ', 'MiniPackFooterLabel' },
    { ' h ', 'MiniPackFooterKey' },
    { 'Health ', 'MiniPackFooterLabel' },
    { ' / ', 'MiniPackFooterKey' },
    { 'Filter ', 'MiniPackFooterLabel' },
    { ' ⏎ ', 'MiniPackFooterKey' },
    { 'Details ', 'MiniPackFooterLabel' },
    { ' <Tab> ', 'MiniPackFooterKey' },
    { 'Tab ', 'MiniPackFooterLabel' },
  }
end

--- Update footer border when tab changes.
local function update_footer()
  if not win or not win.win or not vim.api.nvim_win_is_valid(win.win) then return end
  vim.api.nvim_win_set_config(win.win, { footer = build_footer(), footer_pos = 'center' })
end

--- Switch active tab and re-render.
local function switch_tab()
  filter_text = ''
  active_tab = active_tab == 'plugins' and 'tests' or 'plugins'
  update_footer()
  if active_tab == 'tests' and test_state == 'idle' then
    run_tests()
    return
  end
  if active_tab == 'plugins' and not next(git_cache) then
    M._render()
    refresh_git_cache()
    return
  end
  M._render()
end

-- Public API -----------------------------------------------------------------

--- Open the MiniPack modal window.
---@param all_specs table<string, table> All specs by name
---@param opts? { tab?: 'plugins'|'tests' }
function M.open(all_specs, opts)
  specs = all_specs
  active_tab = opts and opts.tab or 'plugins'
  filter_text = ''
  expanded = {}

  if win then
    win:close()
    win = nil
  end

  git_cache = {}
  setup_highlights()

  win = Snacks.win({
    show = true,
    title = ' ' .. icons.misc.neovim .. 'MiniPack ',
    title_pos = 'center',
    footer = build_footer(),
    footer_pos = 'center',
    width = 0.7,
    height = 0.7,
    border = vim.g.border,
    relative = 'editor',
    position = 'float',
    minimal = true,
    wo = {
      spell = false,
      wrap = false,
      cursorline = true,
      signcolumn = 'no',
      number = false,
      relativenumber = false,
    },
    bo = {
      filetype = 'minipack',
      buftype = 'nofile',
    },
    keys = {
      q = 'close',
      ['<Esc>'] = 'close',
      o = { function() open_repo() end, desc = 'Open Repo' },
      u = { function() update_plugins() end, desc = 'Update' },
      c = { function() check_for_updates() end, desc = 'Check Updates' },
      x = { function() vim.cmd('MiniPack clean') end, desc = 'Clean' },
      h = {
        function()
          if win then win:close() end
          win = nil
          vim.cmd('checkhealth vim.pack')
        end,
        desc = 'Health',
      },
      ['<Tab>'] = { function() switch_tab() end, desc = 'Switch Tab' },
      r = { function() if active_tab == 'tests' then run_tests() end end, desc = 'Run Tests' },
      ['/'] = {
        function()
          if active_tab ~= 'plugins' then return end
          vim.ui.input({ prompt = 'Filter: ', default = filter_text }, function(input)
            filter_text = input or ''
            M._render()
          end)
        end,
        desc = 'Filter',
      },
      ['<CR>'] = {
        function()
          if active_tab ~= 'plugins' then return end
          local name = plugin_under_cursor()
          if name then
            expanded[name] = not expanded[name]
            M._render()
          end
        end,
        desc = 'Details',
      },
    },
  })

  M._render()

  if active_tab == 'plugins' then
    refresh_git_cache()
  elseif test_state == 'idle' then
    run_tests()
  end
end

--- Close the MiniPack modal window.
function M.close()
  if win then
    win:close()
    win = nil
  end
end

--- Check for pending updates in the background.
---@param callback? function Called when check is complete
function M.check(callback)
  check_updates_bg(callback)
end

--- Get the number of plugins with pending updates (for statusline).
---@return number?
function M.pending_count()
  local count = 0
  for _, has in pairs(pending_updates) do
    if has then count = count + 1 end
  end
  return count > 0 and count or nil
end

--- Start periodic update check (every hour, first after 5 min).
function M.start_check_timer()
  if check_timer then return end

  local interval = 60 * 60 * 1000

  check_timer = vim.uv.new_timer()
  if check_timer then
    check_timer:start(5 * 60 * 1000, interval, function()
      vim.schedule(function()
        check_updates_bg()
      end)
    end)
  end
end

--- Stop periodic update check.
function M.stop_check_timer()
  if check_timer then
    check_timer:stop()
    check_timer:close()
    check_timer = nil
  end
end

-- Expose internals for testing
M._resolve_upstream = resolve_upstream
M._git_fallback_update = git_fallback_update
M._pending_updates = function() return pending_updates end
M._set_pending_updates = function(t) pending_updates = t end
M._build_plugin_entry = function(name) return build_plugin_entry(name) end
M._hl_plugin_entry = hl_plugin_entry
M._render_plugins_tab = render_plugins_tab
M._render_tests_tab = render_tests_tab
M._build_footer = build_footer
M._set_git_cache = function(t) git_cache = t end
M._set_specs = function(t) specs = t end
M._set_test_state = function(s) test_state = s end
M._set_test_results = function(r) test_results = r end
M._set_active_tab = function(t) active_tab = t end
M._set_filter_text = function(t) filter_text = t end
M._set_expanded = function(t) expanded = t end
M._set_update_progress = function(t) update_progress = t end

return M
