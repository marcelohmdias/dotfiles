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

---@param spec? { tags?: { name: string, days_ago: integer }[], commits?: integer[] }
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

T['resolve_remote()'] = MiniTest.new_set()

T['resolve_remote()']['matches install-time resolution for blocked branch plugin'] = function()
  local repos = make_repo({ commits = { 1 } })
  local release_age = require('core.pkg.release_age')
  release_age.set_defaults({ minimum_release_age = '7d' })

  local spec = { name = 'branchy', src = repos.remote }
  local policy = release_age.policy(spec)
  local resolved = release_age.resolve_remote(spec, policy)

  MiniTest.expect.equality(resolved.checkout, nil)
  MiniTest.expect.equality(resolved.pending, true)
  repos.cleanup()
end

T['setup()'] = MiniTest.new_set()

T['setup()']['skips vim.pack.add when install is blocked by minimum_release_age'] = function()
  local repos = make_repo({ commits = { 1 } })
  local child = H.new_child()
  child.lua(string.format(
    [[
    _G._fixture_src = %q
    _G._added = {}
    _G.MiniMisc = { safely = function(_, f) f() end }
    _G.autocmd = function(event, opts)
      local group = vim.api.nvim_create_augroup('MiniPackTest', { clear = true })
      opts.group = group
      vim.api.nvim_create_autocmd(event, opts)
    end
    _G.gh = function(src) return src end
    _G.cb = function(src) return src end
    vim.pack = vim.pack or {}
    vim.pack.add = function(specs) _G._added = specs end
    require('core.pkg').setup({ import = 'tests.fixtures.minimum_age_blocked', minimum_release_age = '7d' })
  ]],
    repos.remote
  ))

  MiniTest.expect.equality(child.lua_get('#_G._added'), 0)
  child.stop()
  repos.cleanup()
end

return T
