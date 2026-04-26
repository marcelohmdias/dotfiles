local icons = require('core.icons')

local M = { gh('folke/snacks.nvim') }

--- Split a string by pattern into a list.
---@param str string
---@param pattern string Lua pattern with captures or matching groups
---@return string[]
local function split_to_table(str, pattern)
  local chunks = {}
  for substr in string.gmatch(str, pattern) do
    chunks[#chunks + 1] = substr
  end
  return chunks
end

--- Run a shell command synchronously and return availability info.
---@param cmd string Shell command string
---@return { enabled: boolean, height: integer }
local function cmd_validate(cmd)
  local command = split_to_table(cmd, '%S+')
  local result = vim.system(command, { text = true }):wait()
  local is_enabled = string.len(result.stdout) > 0
  local lines = split_to_table(result.stdout, '([^\n]*)\n?')

  return { enabled = is_enabled, height = #lines }
end

--- Build a terminal section.
--- Snacks handles async execution; we only declare layout.
---@param opts { icon: string, title: string, cmd: string, enabled: boolean, height?: integer, indent?: integer, ttl?: integer }
---@return snacks.dashboard.Section
local function terminal_section(opts)
  return {
    cmd = opts.cmd,
    enabled = opts.enabled,
    height = opts.height or 5,
    icon = opts.icon,
    indent = opts.indent or 3,
    padding = 1,
    section = 'terminal',
    title = opts.title,
    ttl = opts.ttl or (5 * 60),
  }
end

local header = {
  [[                                                                   ]],
  [[      ████ ██████           █████      ██                    ]],
  [[     ███████████             █████                            ]],
  [[     █████████ ███████████████████ ███   ███████████  ]],
  [[    █████████  ███    █████████████ █████ ██████████████  ]],
  [[   █████████ ██████████ █████████ █████ █████ ████ █████  ]],
  [[ ███████████ ███    ███ █████████ █████ █████ ████ █████ ]],
  [[██████  █████████████████████ ████ █████ █████ ████ ██████]],
}

---@type snacks.Config
M.opts = {
  dashboard = {
    formats = {
      key = function(item)
        return { { '[', hl = 'icon' }, { item.key, hl = 'special' }, { ']', hl = 'icon' } }
      end,
    },
    preset = {
      header = table.concat(header, '\n'),
      ---@type snacks.dashboard.Item[]
      keys = {
        { icon = icons.dashboard.file, key = 'f', desc = 'Find File', action = ":lua Snacks.dashboard.pick('files')" },
        { icon = icons.dashboard.new_file, key = 'n', desc = 'New File', action = ':ene | startinsert' },
        {
          icon = icons.dashboard.search,
          key = 'g',
          desc = 'Find Text',
          action = ":lua Snacks.dashboard.pick('live_grep')",
        },
        {
          icon = icons.dashboard.recent,
          key = 'r',
          desc = 'Recent Files',
          action = ":lua Snacks.dashboard.pick('oldfiles')",
        },
        {
          icon = icons.dashboard.config,
          key = 'c',
          desc = 'Config',
          action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
        },
        { icon = icons.dashboard.session, key = 's', desc = 'Restore Session', action = function()
          local name = vim.fn.fnamemodify(vim.uv.cwd() or '', ':t')
          if name ~= '' and MiniSessions.detected[name] then
            MiniSessions.read(name)
          else
            MiniSessions.select('read')
          end
        end },
        {
          icon = icons.dashboard.zoxide,
          key = 'z',
          desc = 'Zoxide',
          action = function()
            Snacks.picker.zoxide({ layout = { preset = 'vscode' } })
          end,
        },
        { icon = icons.dashboard.minipack, key = 'm', desc = 'MiniPack', action = ':MiniPack open' },
        { icon = icons.dashboard.quit, key = 'q', desc = 'Quit', action = ':qa' },
      },
    },
    sections = {
      { section = 'header', padding = 2 },
      { icon = icons.dashboard.keys, title = 'Keymaps\n', section = 'keys', indent = 3, padding = 1 },
      {
        icon = icons.dashboard.recent,
        title = 'Recent Files\n',
        section = 'recent_files',
        cwd = true,
        indent = 3,
        limit = 5,
        padding = 1,
      },
      function()
        local pr_cmd = 'gh search prs -L=3 --review-requested=@me --state=open'
        local pr_result = cmd_validate(pr_cmd)

        return terminal_section({
          icon = icons.dashboard.pr_review,
          title = 'PRs to Review',
          cmd = pr_cmd,
          enabled = pr_result.enabled,
          height = pr_result.height + 3,
        })
      end,
      function()
        local in_git = Snacks.git.get_root() ~= nil
        if not in_git then
          return { enabled = false }
        end
        local diff_cmd = 'git --no-pager diff --stat-width=98 --stat-count=5 -B -M -C'
        local diff_result = cmd_validate(diff_cmd)

        return terminal_section({
          icon = icons.dashboard.git_diff,
          title = 'Git Status',
          cmd = "echo ''; git --no-pager diff --stat-width=98 --stat-count=5 -B -M -C",
          height = diff_result.height + 1,
          indent = 2,
          enabled = diff_result.enabled,
        })
      end,
      { section = 'startup' },
    },
    width = 100,
  },
}

return M
