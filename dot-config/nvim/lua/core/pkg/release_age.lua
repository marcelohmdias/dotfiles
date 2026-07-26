local M = {}

local semver = require('core.pkg.semver')

---@type { minimum_release_age: integer?, minimum_release_age_downgrade: boolean? }
local defaults = {
  minimum_release_age = nil,
  minimum_release_age_downgrade = nil,
}

---@type table<string, boolean>
local warned = {}

local DURATION_UNITS = {
  m = 60,
  h = 60 * 60,
  d = 60 * 60 * 24,
  w = 60 * 60 * 24 * 7,
  y = 60 * 60 * 24 * 365,
}

---@param key string
---@param message string
local function warn_once(key, message)
  if warned[key] then
    return
  end
  warned[key] = true
  vim.notify(message, vim.log.levels.WARN)
end

---@param args string[]
---@param cwd? string
---@return { code: integer, stdout: string, stderr: string }
local function git(args, cwd)
  local command = { 'git' }
  if cwd then
    command[#command + 1] = '-C'
    command[#command + 1] = cwd
  end
  vim.list_extend(command, args)
  local result = vim.system(command, { text = true }):wait()
  return {
    code = result.code,
    stdout = result.stdout or '',
    stderr = result.stderr or '',
  }
end

---@param value unknown
---@param context string
---@return integer?
local function parse_age_value(value, context)
  if value == nil or value == false then
    return nil
  end
  if type(value) == 'number' then
    if value < 0 or value ~= math.floor(value) then
      warn_once(
        context .. ':age:' .. tostring(value),
        '[MiniPack] Invalid minimum_release_age "'
          .. tostring(value)
          .. '" in '
          .. context
          .. '; expected non-negative integer seconds or a single-unit duration'
      )
      return nil
    end
    return value
  end
  if type(value) ~= 'string' then
    warn_once(
      context .. ':age:' .. tostring(value),
      '[MiniPack] Invalid minimum_release_age in '
        .. context
        .. '; expected non-negative integer seconds or a single-unit duration'
    )
    return nil
  end

  local amount, unit = value:match('^(%d+)([mhdwy])$')
  if not amount then
    warn_once(
      context .. ':age:' .. value,
      '[MiniPack] Invalid minimum_release_age "'
        .. value
        .. '" in '
        .. context
        .. '; expected values like 1800, 30m, 24h, 7d, 2w, or 1y'
    )
    return nil
  end
  return tonumber(amount) * DURATION_UNITS[unit]
end

---@param value unknown
---@param context string
---@return boolean?
local function parse_downgrade_value(value, context)
  if value == nil then
    return nil
  end
  if type(value) ~= 'boolean' then
    warn_once(
      context .. ':downgrade:' .. tostring(value),
      '[MiniPack] Invalid minimum_release_age_downgrade "'
        .. tostring(value)
        .. '" in '
        .. context
        .. '; expected boolean'
    )
    return nil
  end
  return value
end

---@param seconds integer
---@return string
local function format_policy(seconds)
  if seconds % DURATION_UNITS.y == 0 then
    return tostring(seconds / DURATION_UNITS.y) .. 'y'
  end
  if seconds % DURATION_UNITS.w == 0 then
    return tostring(seconds / DURATION_UNITS.w) .. 'w'
  end
  if seconds % DURATION_UNITS.d == 0 then
    return tostring(seconds / DURATION_UNITS.d) .. 'd'
  end
  if seconds % DURATION_UNITS.h == 0 then
    return tostring(seconds / DURATION_UNITS.h) .. 'h'
  end
  if seconds % DURATION_UNITS.m == 0 then
    return tostring(seconds / DURATION_UNITS.m) .. 'm'
  end
  return tostring(seconds)
end

---@param remaining integer
---@return string
local function format_eta(remaining)
  if remaining <= 0 then
    return 'available in 0 horas'
  end
  if remaining >= DURATION_UNITS.d then
    return 'available in ' .. math.ceil(remaining / DURATION_UNITS.d) .. ' dias'
  end
  return 'available in ' .. math.ceil(remaining / DURATION_UNITS.h) .. ' horas'
end

---@param path string
---@param ancestor string
---@param descendant string
---@return boolean
local function is_ancestor(path, ancestor, descendant)
  return git({ 'merge-base', '--is-ancestor', ancestor, descendant }, path).code == 0
end

---@param path string
---@param ref string
---@return string?
local function rev_parse(path, ref)
  local result = git({ 'rev-parse', ref }, path)
  if result.code ~= 0 then
    return nil
  end
  local hash = vim.trim(result.stdout)
  return hash ~= '' and hash or nil
end

---@param path string
---@param ref string
---@return integer?
local function commit_time(path, ref)
  local result = git({ 'show', '-s', '--format=%ct', ref }, path)
  if result.code ~= 0 then
    return nil
  end
  local timestamp = tonumber(vim.trim(result.stdout))
  return timestamp and math.floor(timestamp) or nil
end

---@param path string
---@return string?
local function resolve_branch_ref(path)
  for _, ref in ipairs({ '@{u}', 'origin/HEAD', 'origin/main', 'origin/master' }) do
    if rev_parse(path, ref) then
      return ref
    end
  end
  return nil
end

---@param path string
---@return string?
local function resolve_default_branch(src)
  local result = git({ 'ls-remote', '--symref', src, 'HEAD' })
  if result.code ~= 0 then
    return nil
  end
  local branch = result.stdout:match('ref:%s+refs/heads/([^%s]+)%s+HEAD')
  return branch
end

---@param src string
---@param branch string
---@return string?
local function prepare_remote_repo(src, branch)
  local tmp = vim.fn.tempname()
  vim.fn.mkdir(tmp, 'p')

  if git({ 'init' }, tmp).code ~= 0 then
    vim.fn.delete(tmp, 'rf')
    return nil
  end
  if git({ 'remote', 'add', 'origin', src }, tmp).code ~= 0 then
    vim.fn.delete(tmp, 'rf')
    return nil
  end
  local fetch = git(
    { 'fetch', '--quiet', '--force', '--tags', 'origin', 'refs/heads/' .. branch .. ':refs/remotes/origin/' .. branch },
    tmp
  )
  if fetch.code ~= 0 then
    vim.fn.delete(tmp, 'rf')
    return nil
  end
  return tmp
end

---@param path string
---@return table<string, { name: string, timestamp: integer, hash: string }>
local function tag_metadata(path)
  local result = git({ 'for-each-ref', '--format=%(refname:strip=2)|||%(creatordate:unix)', 'refs/tags' }, path)
  if result.code ~= 0 then
    return {}
  end

  local tags = {}
  for line in result.stdout:gmatch('[^\n]+') do
    local name, timestamp = line:match('^(.-)|||(%d+)$')
    if name and timestamp then
      local hash = rev_parse(path, name .. '^{commit}')
      if hash then
        tags[name] = {
          name = name,
          timestamp = tonumber(timestamp),
          hash = hash,
        }
      end
    end
  end
  return tags
end

---@param spec table
---@return boolean
function M.is_supported(spec)
  if spec.checkout then
    return false
  end
  if spec.version then
    return semver.is_range(spec.version)
  end
  return spec.src ~= nil
end

---@param spec table
---@return boolean
function M.is_fixed(spec)
  if spec.checkout then
    return true
  end
  if spec.version then
    return not semver.is_range(spec.version)
  end
  return false
end

---@param opts { minimum_release_age?: unknown, minimum_release_age_downgrade?: unknown }
function M.set_defaults(opts)
  defaults.minimum_release_age = parse_age_value(opts.minimum_release_age, 'setup()')
  defaults.minimum_release_age_downgrade = parse_downgrade_value(opts.minimum_release_age_downgrade, 'setup()')
end

---@param spec table
---@return { enabled: boolean, seconds: integer?, label: string?, downgrade: boolean }
function M.policy(spec)
  local context = 'spec ' .. (spec.name or '?')
  local local_age = parse_age_value(spec.minimum_release_age, context)
  local global_age = defaults.minimum_release_age
  local seconds = global_age
  if spec.minimum_release_age == false then
    seconds = nil
  elseif local_age ~= nil then
    seconds = local_age
  end
  if not seconds or M.is_fixed(spec) or not M.is_supported(spec) then
    return { enabled = false, downgrade = false }
  end

  local local_downgrade = parse_downgrade_value(spec.minimum_release_age_downgrade, context)
  local downgrade = spec.minimum_release_age_downgrade == false and false
    or (local_downgrade ~= nil and local_downgrade or defaults.minimum_release_age_downgrade or false)

  return {
    enabled = true,
    seconds = seconds,
    label = format_policy(seconds),
    downgrade = downgrade,
  }
end

---@param path string
---@param spec table
---@param policy { enabled: boolean, seconds: integer, label: string, downgrade: boolean }
---@param now integer
---@return { eligible_ref: string?, eligible_hash: string?, latest_ref: string?, latest_hash: string?, pending_label: string?, reason: string?, actionable: boolean, current_hash: string?, latest_time: integer? }
local function resolve_local_range(path, spec, policy, now)
  local current_hash = rev_parse(path, 'HEAD')
  local tags = tag_metadata(path)
  local all_names = vim.tbl_keys(tags)
  local latest_ref = semver.best_match(all_names, spec.version)
  if not latest_ref then
    return { actionable = false, current_hash = current_hash, reason = 'missing_latest' }
  end

  local eligible_names = {}
  local cutoff = now - policy.seconds
  for name, meta in pairs(tags) do
    if meta.timestamp <= cutoff then
      eligible_names[#eligible_names + 1] = name
    end
  end
  local eligible_ref = semver.best_match(eligible_names, spec.version)
  local latest = tags[latest_ref]
  local eligible = eligible_ref and tags[eligible_ref] or nil
  local pending_label = nil
  if latest.timestamp > cutoff then
    pending_label = format_eta(latest.timestamp + policy.seconds - now)
  end

  if not eligible then
    return {
      actionable = false,
      current_hash = current_hash,
      latest_ref = latest_ref,
      latest_hash = latest.hash,
      latest_time = latest.timestamp,
      pending_label = pending_label,
      reason = 'pending',
    }
  end

  local actionable = current_hash ~= eligible.hash
  if actionable and not policy.downgrade and current_hash and is_ancestor(path, eligible.hash, current_hash) then
    actionable = false
  end

  return {
    actionable = actionable,
    current_hash = current_hash,
    eligible_ref = eligible_ref,
    eligible_hash = eligible.hash,
    latest_ref = latest_ref,
    latest_hash = latest.hash,
    latest_time = latest.timestamp,
    pending_label = pending_label,
  }
end

---@param path string
---@param policy { enabled: boolean, seconds: integer, label: string, downgrade: boolean }
---@param now integer
---@return { eligible_ref: string?, eligible_hash: string?, latest_ref: string?, latest_hash: string?, pending_label: string?, reason: string?, actionable: boolean, current_hash: string?, latest_time: integer? }
local function resolve_local_branch(path, policy, now)
  local current_hash = rev_parse(path, 'HEAD')
  local branch_ref = resolve_branch_ref(path)
  if not branch_ref then
    return { actionable = false, current_hash = current_hash, reason = 'missing_latest' }
  end

  local latest_hash = rev_parse(path, branch_ref)
  local latest_time = latest_hash and commit_time(path, latest_hash) or nil
  if not latest_hash or not latest_time then
    return { actionable = false, current_hash = current_hash, reason = 'missing_latest' }
  end

  local cutoff = now - policy.seconds
  local pending_label = nil
  if latest_time > cutoff then
    pending_label = format_eta(latest_time + policy.seconds - now)
  end

  local eligible_hash = nil
  if latest_time <= cutoff then
    eligible_hash = latest_hash
  else
    local rev_list = git({ 'rev-list', '-n', '1', '--before=' .. tostring(cutoff), branch_ref }, path)
    local candidate = vim.trim(rev_list.stdout)
    eligible_hash = candidate ~= '' and candidate or nil
  end

  if not eligible_hash then
    return {
      actionable = false,
      current_hash = current_hash,
      latest_ref = branch_ref,
      latest_hash = latest_hash,
      latest_time = latest_time,
      pending_label = pending_label,
      reason = 'pending',
    }
  end

  local actionable = current_hash ~= eligible_hash
  if actionable and not policy.downgrade and current_hash and is_ancestor(path, eligible_hash, current_hash) then
    actionable = false
  end

  return {
    actionable = actionable,
    current_hash = current_hash,
    eligible_ref = eligible_hash,
    eligible_hash = eligible_hash,
    latest_ref = branch_ref,
    latest_hash = latest_hash,
    latest_time = latest_time,
    pending_label = pending_label,
  }
end

---@param path string
---@param spec table
---@param policy { enabled: boolean, seconds: integer, label: string, downgrade: boolean }
---@param now? integer
---@return { enabled: boolean, actionable: boolean, checkout: string?, pending: boolean, pending_label: string?, policy_label: string?, latest_hash: string?, latest_ref: string?, error: string?, current_hash: string? }
function M.resolve_local(path, spec, policy, now)
  if not policy.enabled then
    return { enabled = false, actionable = false, pending = false }
  end

  local resolved_now = now or os.time()
  local result = spec.version and resolve_local_range(path, spec, policy, resolved_now)
    or resolve_local_branch(path, policy, resolved_now)

  return {
    enabled = true,
    actionable = result.actionable,
    checkout = result.eligible_ref,
    pending = result.pending_label ~= nil,
    pending_label = result.pending_label,
    policy_label = policy.label,
    latest_hash = result.latest_hash,
    latest_ref = result.latest_ref,
    error = result.reason == 'pending' and not result.eligible_ref and 'No eligible release found yet' or nil,
    current_hash = result.current_hash,
  }
end

---@param spec table
---@param policy { enabled: boolean, seconds: integer, label: string, downgrade: boolean }
---@param now? integer
---@return { enabled: boolean, actionable: boolean, checkout: string?, pending: boolean, pending_label: string?, policy_label: string?, latest_hash: string?, latest_ref: string?, error: string?, current_hash: string? }
function M.resolve_remote(spec, policy, now)
  if not policy.enabled or not spec.src then
    return { enabled = false, actionable = false, pending = false }
  end

  local branch = spec.version and 'HEAD' or resolve_default_branch(spec.src)
  if not branch then
    return { enabled = true, actionable = false, pending = false, error = 'Failed to resolve remote default branch' }
  end

  local repo = prepare_remote_repo(spec.src, branch)
  if not repo then
    return { enabled = true, actionable = false, pending = false, error = 'Failed to fetch remote metadata' }
  end

  local result = M.resolve_local(repo, spec, policy, now)
  vim.fn.delete(repo, 'rf')
  return result
end

---@param path string
---@param target string
---@return boolean
function M.checkout(path, target)
  return git({ 'checkout', '--quiet', target }, path).code == 0
end

---@return string
function M.pending_message()
  return 'relax minimum_release_age or retry later'
end

return M
