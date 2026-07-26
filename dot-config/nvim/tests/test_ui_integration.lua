---@diagnostic disable: undefined-global
-- Integration tests for core.pkg.ui: resolve_upstream, git_fallback_update, pending_count
-- These tests create real git repos in /tmp to validate git orchestration logic.

local T = MiniTest.new_set()

--- Create a bare "remote" repo + a clone that mimics vim.pack layout.
---@param opts? { tags?: string[] }
---@return { remote: string, clone: string, tmp: string, cleanup: fun() }
local function make_git_repos(opts)
  opts = opts or {}
  local tmp = vim.fn.tempname()
  vim.fn.mkdir(tmp, 'p')

  local remote = tmp .. '/remote.git'
  local clone = tmp .. '/clone'

  -- Init bare remote with main as default branch
  vim.system({ 'git', 'init', '--bare', '--initial-branch=main', remote }, { text = true }):wait()

  -- Clone it
  vim.system({ 'git', 'clone', remote, clone }, { text = true }):wait()

  -- Configure git user in clone
  vim.system({ 'git', '-C', clone, 'config', 'user.email', 'test@test.com' }, { text = true }):wait()
  vim.system({ 'git', '-C', clone, 'config', 'user.name', 'Test' }, { text = true }):wait()
  vim.system({ 'git', '-C', clone, 'config', 'commit.gpgsign', 'false' }, { text = true }):wait()

  -- Initial commit on main
  vim.fn.writefile({ 'init' }, clone .. '/file.txt')
  vim.system({ 'git', '-C', clone, 'add', '.' }, { text = true }):wait()
  vim.system({ 'git', '-C', clone, 'commit', '-m', 'init' }, { text = true }):wait()
  vim.system({ 'git', '-C', clone, 'push', 'origin', 'main' }, { text = true }):wait()
  vim.system({ 'git', '-C', clone, 'fetch', '--quiet', '--tags', 'origin' }, { text = true }):wait()

  if opts.tags then
    for _, tag in ipairs(opts.tags) do
      vim.fn.writefile({ tag }, clone .. '/file.txt')
      vim.system({ 'git', '-C', clone, 'add', '.' }, { text = true }):wait()
      vim.system({ 'git', '-C', clone, 'commit', '-m', 'release ' .. tag }, { text = true }):wait()
      vim.system({ 'git', '-C', clone, 'tag', tag }, { text = true }):wait()
    end
    vim.system({ 'git', '-C', clone, 'push', 'origin', '--tags', 'main' }, { text = true }):wait()
    vim.system({ 'git', '-C', clone, 'fetch', '--quiet', '--tags', 'origin' }, { text = true }):wait()
  end

  return {
    remote = remote,
    clone = clone,
    tmp = tmp,
    cleanup = function()
      vim.fn.delete(tmp, 'rf')
    end,
  }
end

local ui = require('core.pkg.ui')

-- resolve_upstream -------------------------------------------------------------

T['resolve_upstream'] = MiniTest.new_set()

T['resolve_upstream']['tagged HEAD returns latest tag commit hash'] = function()
  local repos = make_git_repos({ tags = { 'v1.0.0', 'v2.0.0' } })

  -- Checkout old tag (detached HEAD, like vim.pack does)
  vim.system({ 'git', '-C', repos.clone, 'checkout', 'v1.0.0' }, { text = true }):wait()

  local expected =
    vim.trim((vim.system({ 'git', '-C', repos.clone, 'rev-parse', 'v2.0.0^{commit}' }, { text = true }):wait()).stdout)

  local result, done = nil, false
  ui._resolve_upstream(repos.clone, function(hash)
    result = hash
    done = true
  end)
  vim.wait(5000, function()
    return done
  end)

  MiniTest.expect.equality(result, expected)
  repos.cleanup()
end

T['resolve_upstream']['tagged HEAD already on latest returns HEAD hash'] = function()
  local repos = make_git_repos({ tags = { 'v1.0.0', 'v2.0.0' } })

  vim.system({ 'git', '-C', repos.clone, 'checkout', 'v2.0.0' }, { text = true }):wait()

  local head = vim.trim((vim.system({ 'git', '-C', repos.clone, 'rev-parse', 'HEAD' }, { text = true }):wait()).stdout)

  local result, done = nil, false
  ui._resolve_upstream(repos.clone, function(hash)
    result = hash
    done = true
  end)
  vim.wait(5000, function()
    return done
  end)

  -- Latest tag is v2.0.0, HEAD is v2.0.0 → same hash
  MiniTest.expect.equality(result, head)
  repos.cleanup()
end

T['resolve_upstream']['branch detached HEAD falls back to origin/main'] = function()
  local repos = make_git_repos()

  vim.system({ 'git', '-C', repos.clone, 'checkout', '--detach', 'HEAD' }, { text = true }):wait()

  local expected =
    vim.trim((vim.system({ 'git', '-C', repos.clone, 'rev-parse', 'origin/main' }, { text = true }):wait()).stdout)

  local result, done = nil, false
  ui._resolve_upstream(repos.clone, function(hash)
    result = hash
    done = true
  end)
  vim.wait(5000, function()
    return done
  end)

  MiniTest.expect.equality(result, expected)
  repos.cleanup()
end

T['resolve_upstream']['empty repo returns nil'] = function()
  local tmp = vim.fn.tempname()
  vim.fn.mkdir(tmp, 'p')
  vim.system({ 'git', 'init', tmp }, { text = true }):wait()

  local result, done = 'not_nil', false
  ui._resolve_upstream(tmp, function(hash)
    result = hash
    done = true
  end)
  vim.wait(5000, function()
    return done
  end)

  MiniTest.expect.equality(result, nil)
  vim.fn.delete(tmp, 'rf')
end

-- git_fallback_update ----------------------------------------------------------

T['git_fallback_update'] = MiniTest.new_set()

T['git_fallback_update']['updates outdated tag to latest'] = function()
  local repos = make_git_repos({ tags = { 'v1.0.0', 'v2.0.0' } })

  vim.system({ 'git', '-C', repos.clone, 'checkout', 'v1.0.0' }, { text = true }):wait()

  local changed = ui._git_fallback_update(repos.clone)

  MiniTest.expect.equality(changed, true)

  local head = vim.trim((vim.system({ 'git', '-C', repos.clone, 'rev-parse', 'HEAD' }, { text = true }):wait()).stdout)
  local expected =
    vim.trim((vim.system({ 'git', '-C', repos.clone, 'rev-parse', 'v2.0.0^{commit}' }, { text = true }):wait()).stdout)
  MiniTest.expect.equality(head, expected)
  repos.cleanup()
end

T['git_fallback_update']['updates outdated branch to latest remote'] = function()
  local repos = make_git_repos()

  -- Detach HEAD
  vim.system({ 'git', '-C', repos.clone, 'checkout', '--detach', 'HEAD' }, { text = true }):wait()
  local head_before =
    vim.trim((vim.system({ 'git', '-C', repos.clone, 'rev-parse', 'HEAD' }, { text = true }):wait()).stdout)

  -- Push new commit to remote via a second clone
  local tmp2 = vim.fn.tempname()
  vim.system({ 'git', 'clone', repos.remote, tmp2 }, { text = true }):wait()
  vim.system({ 'git', '-C', tmp2, 'config', 'user.email', 'test@test.com' }, { text = true }):wait()
  vim.system({ 'git', '-C', tmp2, 'config', 'user.name', 'Test' }, { text = true }):wait()
  vim.system({ 'git', '-C', tmp2, 'config', 'commit.gpgsign', 'false' }, { text = true }):wait()
  vim.fn.writefile({ 'new content' }, tmp2 .. '/file2.txt')
  vim.system({ 'git', '-C', tmp2, 'add', '.' }, { text = true }):wait()
  vim.system({ 'git', '-C', tmp2, 'commit', '-m', 'new commit' }, { text = true }):wait()
  vim.system({ 'git', '-C', tmp2, 'push', 'origin', 'main' }, { text = true }):wait()
  vim.fn.delete(tmp2, 'rf')

  local changed = ui._git_fallback_update(repos.clone)

  MiniTest.expect.equality(changed, true)

  local head_after =
    vim.trim((vim.system({ 'git', '-C', repos.clone, 'rev-parse', 'HEAD' }, { text = true }):wait()).stdout)
  MiniTest.expect.equality(head_before ~= head_after, true)
  repos.cleanup()
end

T['git_fallback_update']['returns false when already on latest tag'] = function()
  local repos = make_git_repos({ tags = { 'v1.0.0' } })

  vim.system({ 'git', '-C', repos.clone, 'checkout', 'v1.0.0' }, { text = true }):wait()

  local changed = ui._git_fallback_update(repos.clone)

  MiniTest.expect.equality(changed, false)
  repos.cleanup()
end

T['git_fallback_update']['returns false when already on latest branch'] = function()
  local repos = make_git_repos()

  -- Detach at latest main commit
  vim.system({ 'git', '-C', repos.clone, 'checkout', '--detach', 'origin/main' }, { text = true }):wait()

  local changed = ui._git_fallback_update(repos.clone)

  MiniTest.expect.equality(changed, false)
  repos.cleanup()
end

-- pending_count ----------------------------------------------------------------

T['pending_count'] = MiniTest.new_set()

T['pending_count']['returns nil when empty'] = function()
  ui._set_pending_updates({})
  MiniTest.expect.equality(ui.pending_count(), nil)
end

T['pending_count']['returns count of true entries'] = function()
  ui._set_pending_updates({ a = true, b = false, c = true })
  MiniTest.expect.equality(ui.pending_count(), 2)
end

T['pending_count']['returns nil when all false'] = function()
  ui._set_pending_updates({ a = false, b = false })
  MiniTest.expect.equality(ui.pending_count(), nil)
end

T['pending_count']['single update'] = function()
  ui._set_pending_updates({ a = true })
  MiniTest.expect.equality(ui.pending_count(), 1)
end

T['pending_count']['ignores cooldown pending entries'] = function()
  ui._set_pending_updates({
    a = { kind = 'pending', pending_label = 'available in 2 dias' },
    b = true,
  })
  MiniTest.expect.equality(ui.pending_count(), 1)
end

return T
