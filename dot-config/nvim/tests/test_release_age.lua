---@diagnostic disable: undefined-global
local H = require('tests.helpers')

local T = MiniTest.new_set()

---@param cmd string[]
---@param cwd? string
---@param env? table<string, string>
---@return vim.SystemCompleted
local function run(cmd, cwd, env)
  return vim.system(cmd, { text = true, cwd = cwd, env = env }):wait()
end

---@param timestamp integer
---@return table<string, string>
local function git_env(timestamp)
  local date = os.date('!%Y-%m-%dT%H:%M:%SZ', timestamp)
  return {
    GIT_AUTHOR_DATE = date,
    GIT_COMMITTER_DATE = date,
  }
end

---@param spec? { tags?: { name: string, days_ago?: integer }[], commits?: integer[] }
---@return { remote: string, clone: string, cleanup: fun(), timestamps: integer[] }
local function make_repo(spec)
  spec = spec or {}
  local tmp = vim.fn.tempname()
  local remote = tmp .. '/remote.git'
  local clone = tmp .. '/clone'
  local now = os.time()

  vim.fn.mkdir(tmp, 'p')
  run({ 'git', 'init', '--bare', '--initial-branch=main', remote })
  run({ 'git', 'clone', remote, clone })
  run({ 'git', '-C', clone, 'config', 'user.email', 'test@test.com' })
  run({ 'git', '-C', clone, 'config', 'user.name', 'Test' })
  run({ 'git', '-C', clone, 'config', 'commit.gpgsign', 'false' })

  local timestamps = {}
  local commits = spec.commits or { 10, 8, 1 }
  for index, days_ago in ipairs(commits) do
    local timestamp = now - (days_ago * 24 * 60 * 60)
    timestamps[index] = timestamp
    vim.fn.writefile({ tostring(timestamp) }, clone .. '/file.txt')
    run({ 'git', '-C', clone, 'add', '.' })
    run({ 'git', '-C', clone, 'commit', '-m', 'commit-' .. index }, nil, git_env(timestamp))
  end

  if spec.tags then
    for index, tag in ipairs(spec.tags) do
      run({ 'git', '-C', clone, 'tag', tag.name, 'HEAD~' .. tostring(#spec.tags - index) })
    end
  end

  run({ 'git', '-C', clone, 'push', 'origin', '--tags', 'main' })
  run({ 'git', '-C', clone, 'fetch', '--quiet', '--tags', 'origin' })

  return {
    remote = remote,
    clone = clone,
    timestamps = timestamps,
    cleanup = function()
      vim.fn.delete(tmp, 'rf')
    end,
  }
end

--- Fresh hermetic stdpath('data') for a child: clones and tag cache never touch the host.
---@return string
local function make_data_dir()
  local dir = vim.fn.tempname()
  vim.fn.mkdir(dir, 'p')
  return dir
end

--- Child-side vim.pack.add mock. Records specs; when `clone`, also git-clones each
--- one into the pack opt dir so the deferred resolution has a real repo to act on.
---@param clone boolean
---@return string
local function mock_add_code(clone)
  local clone_block = clone
      and [[
    for _, s in ipairs(specs) do
      if s.name then
        local dir = vim.fn.stdpath('data') .. '/site/pack/core/opt/' .. s.name
        if not vim.uv.fs_stat(dir) then
          vim.fn.mkdir(dir, 'p')
          vim.system({ 'git', 'clone', s.src, dir }):wait()
        end
      end
    end
  ]]
    or ''
  return [[
    _G._added = {}
    vim.pack = vim.pack or {}
    vim.pack.add = function(specs)
      _G._added = specs
  ]] .. clone_block .. [[
    end
  ]]
end

--- Child-side prelude: pre-seed the pack opt dir with a clone at `tag`, standing in
--- for a plugin installed by a PREVIOUS session (not just-installed).
---@param remote string
---@param tag string
---@return string
local function preseed_clone_code(remote, tag)
  return string.format(
    [[
    local dir = vim.fn.stdpath('data') .. '/site/pack/core/opt/young-versioned'
    vim.fn.mkdir(vim.fn.fnamemodify(dir, ':h'), 'p')
    vim.system({ 'git', 'clone', %q, dir }):wait()
    vim.system({ 'git', '-C', dir, 'checkout', '--quiet', %q }):wait()
  ]],
    remote,
    tag
  )
end

--- Boot a child with the shared mocks: config rtp, hermetic data dir, MiniPack globals.
---@param child table
---@param data_dir string
---@param setup_code string Lua code appended after the mocks
local function boot_child(child, data_dir, setup_code)
  child.lua(string.format([[
    _G.MiniMisc = { safely = function(_, f) f() end }
    _G.autocmd = function(event, opts)
      local group = vim.api.nvim_create_augroup('MiniPackTest', { clear = true })
      opts.group = group
      vim.api.nvim_create_autocmd(event, opts)
    end
    _G.gh = function(src) return src end
    _G.cb = function(src) return src end
    local orig_stdpath = vim.fn.stdpath
    vim.fn.stdpath = function(what)
      if what == 'config' then return %q end
      if what == 'data' then return %q end
      return orig_stdpath(what)
    end
  ]] .. setup_code, H.project_root, data_dir))
end

--- Boot a child for one setup() case and fire VeryLazy. The trailing schedule
--- sentinel flips _G._deferred_done only after the deferred resolution's own
--- schedule has run (the event loop is FIFO), so cases can await it deterministically.
---@param child table
---@param opts { data_dir: string, fixture: string, globals: table<string, string>, add: string, prelude?: string }
local function boot_setup_case(child, opts)
  local globals = {}
  for gname, value in pairs(opts.globals) do
    globals[#globals + 1] = string.format('_G.%s = %q', gname, value)
  end
  boot_child(
    child,
    opts.data_dir,
    string.format(
      [[
    %s
    %s
    %s
    require('core.pkg').setup({ import = '%s', minimum_release_age = '7d' })
    vim.api.nvim_exec_autocmds('User', { pattern = 'VeryLazy' })
    vim.schedule(function() _G._deferred_done = true end)
  ]],
      table.concat(globals, '\n'),
      opts.prelude or '',
      opts.add,
      opts.fixture
    )
  )
end

--- Poll a predicate until true or timeout: condition-driven waits, never blind sleeps.
---@param predicate fun(): boolean
---@param timeout_ms integer
---@return boolean
local function wait_until(predicate, timeout_ms)
  return vim.wait(timeout_ms, predicate, 100)
end

--- Poll a clone's exact-match tag (the deferred checkout is async in the child).
---@param plugin_dir string
---@param expected_tag string
local function wait_for_tag(plugin_dir, expected_tag)
  wait_until(function()
    local result = run({ 'git', '-C', plugin_dir, 'describe', '--tags', '--exact-match' })
    return vim.trim(result.stdout or '') == expected_tag
  end, 5000)
end

--- Negative wait: fails fast if the exact tag stops matching within the window —
--- verifies a branch took NO action without paying a blind sleep on the happy path.
---@param plugin_dir string
---@param expected_tag string
---@param window_ms integer
local function wait_tag_stays(plugin_dir, expected_tag, window_ms)
  local moved = vim.wait(window_ms, function()
    local result = run({ 'git', '-C', plugin_dir, 'describe', '--tags', '--exact-match' })
    return vim.trim(result.stdout or '') ~= expected_tag
  end, 100)
  MiniTest.expect.equality(moved, false)
end

--- Stop the child and drop hermetic dirs/repos: single exit path per case.
---@param child table
---@param data_dir string
---@param ... table repos returned by make_repo
local function finish_case(child, data_dir, ...)
  child.stop()
  vim.fn.delete(data_dir, 'rf')
  for _, repos in ipairs({ ... }) do
    repos.cleanup()
  end
end

T['policy()'] = MiniTest.new_set()

T['policy()']['inherits global values and allows per-plugin disable'] = function()
  local release_age = require('core.pkg.release_age')
  release_age.set_defaults({ minimum_release_age = '7d', minimum_release_age_downgrade = true })

  local inherited = release_age.policy({ name = 'demo', src = 'https://github.com/org/demo.nvim' })
  local disabled = release_age.policy({
    name = 'demo',
    src = 'https://github.com/org/demo.nvim',
    minimum_release_age = false,
  })

  MiniTest.expect.equality(inherited.enabled, true)
  MiniTest.expect.equality(inherited.seconds, 7 * 24 * 60 * 60)
  MiniTest.expect.equality(inherited.downgrade, true)
  MiniTest.expect.equality(disabled.enabled, false)
end

T['resolve_local()'] = MiniTest.new_set()

T['resolve_local()']['finds latest eligible branch commit and keeps pending label'] = function()
  local repos = make_repo()
  local release_age = require('core.pkg.release_age')
  release_age.set_defaults({ minimum_release_age = '7d' })
  run({ 'git', '-C', repos.clone, 'checkout', '--detach', 'HEAD~2' })

  local policy = release_age.policy({ name = 'branchy', src = repos.remote })
  local resolved = release_age.resolve_local(repos.clone, { name = 'branchy', src = repos.remote }, policy)
  local expected = vim.trim(run({ 'git', '-C', repos.clone, 'rev-parse', 'origin/main~1' }).stdout)

  MiniTest.expect.equality(resolved.checkout, expected)
  MiniTest.expect.equality(resolved.actionable, true)
  MiniTest.expect.equality(resolved.pending, true)
  MiniTest.expect.equality(resolved.pending_label:find('available in ', 1, true) == 1, true)
  repos.cleanup()
end

T['resolve_local()']['returns pending without checkout when every branch commit is too fresh'] = function()
  local repos = make_repo({ commits = { 1 } })
  local release_age = require('core.pkg.release_age')
  release_age.set_defaults({ minimum_release_age = '7d' })

  local policy = release_age.policy({ name = 'branchy', src = repos.remote })
  local resolved = release_age.resolve_local(repos.clone, { name = 'branchy', src = repos.remote }, policy)

  MiniTest.expect.equality(resolved.checkout, nil)
  MiniTest.expect.equality(resolved.pending, true)
  MiniTest.expect.equality(resolved.actionable, false)
  repos.cleanup()
end

T['resolve_local()']['resolves eligible semver tag inside cooldown window'] = function()
  local repos = make_repo({
    tags = {
      { name = 'v1.0.0', days_ago = 10 },
      { name = 'v1.1.0', days_ago = 8 },
      { name = 'v1.2.0', days_ago = 1 },
    },
  })
  local release_age = require('core.pkg.release_age')
  release_age.set_defaults({ minimum_release_age = '7d' })
  run({ 'git', '-C', repos.clone, 'checkout', '--quiet', 'v1.0.0' })

  local spec = { name = 'taggy', src = repos.remote, version = '*' }
  local policy = release_age.policy(spec)
  local resolved = release_age.resolve_local(repos.clone, spec, policy)
  local expected = vim.trim(run({ 'git', '-C', repos.clone, 'rev-parse', 'v1.1.0^{commit}' }).stdout)

  MiniTest.expect.equality(resolved.checkout, 'v1.1.0')
  MiniTest.expect.equality(resolved.latest_hash ~= expected, true)
  MiniTest.expect.equality(resolved.actionable, true)
  MiniTest.expect.equality(resolved.pending, true)
  repos.cleanup()
end

T['setup()'] = MiniTest.new_set()

T['setup()']['installs missing plugins without the release-age gate'] = function()
  local repos = make_repo({ commits = { 1 } })
  local data_dir = make_data_dir()
  local child = H.new_child()
  boot_setup_case(child, {
    data_dir = data_dir,
    fixture = 'tests.fixtures.minimum_age_young',
    globals = { _fixture_src = repos.remote },
    add = mock_add_code(true),
  })

  MiniTest.expect.equality(child.lua_get('#_G._added'), 1)
  MiniTest.expect.equality(child.lua_get('_G._added[1].checkout ~= nil'), false)
  finish_case(child, data_dir, repos)
end

T['setup()']['routes just-installed version specs to newest matching tag'] = function()
  -- Both tags younger than the gate and HEAD untagged: a no-op resolution leaves
  -- HEAD untagged and a gated one finds no eligible tag — only the ungated route
  -- lands the clone on v1.1.0.
  local repos = make_repo({ commits = { 3, 1 }, tags = { { name = 'v1.0.0' }, { name = 'v1.1.0' } } })
  run({ 'git', '-C', repos.clone, 'commit', '--allow-empty', '-m', 'post-tag' }, nil, git_env(os.time()))
  run({ 'git', '-C', repos.clone, 'push', 'origin', 'main' })
  local data_dir = make_data_dir()
  local plugin_dir = data_dir .. '/site/pack/core/opt/young-versioned'
  local child = H.new_child()
  boot_setup_case(child, {
    data_dir = data_dir,
    fixture = 'tests.fixtures.minimum_age_young_versioned',
    globals = { _fixture_src = repos.remote },
    add = mock_add_code(true),
  })

  wait_for_tag(plugin_dir, 'v1.1.0')
  local head = vim.trim(run({ 'git', '-C', plugin_dir, 'describe', '--tags', '--exact-match' }).stdout)
  MiniTest.expect.equality(head, 'v1.1.0')
  finish_case(child, data_dir, repos)
end

T['setup()']['keeps versioned plugin at HEAD when repo has no tags'] = function()
  local repos = make_repo({ commits = { 1 } })
  local data_dir = make_data_dir()
  local plugin_dir = data_dir .. '/site/pack/core/opt/young-versioned'
  local child = H.new_child()
  boot_setup_case(child, {
    data_dir = data_dir,
    fixture = 'tests.fixtures.minimum_age_young_versioned',
    globals = { _fixture_src = repos.remote },
    add = mock_add_code(true),
  })

  local done = function()
    return child.lua_get('_G._deferred_done') == true
  end
  MiniTest.expect.equality(wait_until(done, 5000), true)
  local head = vim.trim(run({ 'git', '-C', plugin_dir, 'rev-parse', 'HEAD' }).stdout)
  local expected = vim.trim(run({ 'git', '-C', repos.clone, 'rev-parse', 'HEAD' }).stdout)
  local on_branch = run({ 'git', '-C', plugin_dir, 'symbolic-ref', '--quiet', 'HEAD' }).code
  MiniTest.expect.equality(head, expected)
  MiniTest.expect.equality(on_branch, 0)
  finish_case(child, data_dir, repos)
end

T['setup()']['retains parent when young dependency is first installed'] = function()
  local dep_repos = make_repo({ commits = { 1 } })
  local parent_repos = make_repo({ commits = { 1 } })
  local data_dir = make_data_dir()
  local child = H.new_child()
  boot_setup_case(child, {
    data_dir = data_dir,
    fixture = 'tests.fixtures.minimum_age_parent_with_young_dep',
    globals = { _fixture_src = dep_repos.remote, _fixture_src_parent = parent_repos.remote },
    add = mock_add_code(false),
  })

  local has = [[vim.iter(_G._added):any(function(s) return s.name == %q end)]]
  MiniTest.expect.equality(child.lua_get('#_G._added'), 2)
  MiniTest.expect.equality(child.lua_get(string.format(has, 'parent-plugin')), true)
  MiniTest.expect.equality(child.lua_get(string.format(has, 'young-dep')), true)
  finish_case(child, data_dir, dep_repos, parent_repos)
end

T['setup()']['skips checkout enforcement when just-installed plugin is not on disk'] = function()
  local repos = make_repo({ commits = { 1 }, tags = { { name = 'v1.0.0' } } })
  local data_dir = make_data_dir()
  local child = H.new_child()
  boot_setup_case(child, {
    data_dir = data_dir,
    fixture = 'tests.fixtures.minimum_age_young_versioned',
    globals = { _fixture_src = repos.remote },
    add = mock_add_code(false),
  })

  local done = function()
    return child.lua_get('_G._deferred_done') == true
  end
  MiniTest.expect.equality(wait_until(done, 5000), true)
  MiniTest.expect.equality(child.lua_get('#_G._added'), 1)
  local opt_dir = data_dir .. '/site/pack/core/opt/young-versioned'
  MiniTest.expect.equality(vim.fn.isdirectory(opt_dir), 0)
  finish_case(child, data_dir, repos)
end

T['setup()']['gates on-disk version specs from the next session'] = function()
  -- Previous session landed v1.0.0 (cured); newest tag v1.1.0 is young. The gated
  -- branch must hold the clone at v1.0.0 — only an ungated route would move it.
  local repos = make_repo({ commits = { 10, 1 }, tags = { { name = 'v1.0.0' }, { name = 'v1.1.0' } } })
  local data_dir = make_data_dir()
  local plugin_dir = data_dir .. '/site/pack/core/opt/young-versioned'
  local child = H.new_child()
  boot_setup_case(child, {
    data_dir = data_dir,
    fixture = 'tests.fixtures.minimum_age_young_versioned',
    globals = { _fixture_src = repos.remote },
    add = mock_add_code(true),
    prelude = preseed_clone_code(repos.remote, 'v1.0.0'),
  })

  local done = function()
    return child.lua_get('_G._deferred_done') == true
  end
  MiniTest.expect.equality(wait_until(done, 5000), true)
  wait_tag_stays(plugin_dir, 'v1.0.0', 1500)
  local head = vim.trim(run({ 'git', '-C', plugin_dir, 'describe', '--tags', '--exact-match' }).stdout)
  MiniTest.expect.equality(head, 'v1.0.0')
  finish_case(child, data_dir, repos)
end

return T
