--- Semver parsing, comparison, and range matching.
--- Supports: exact (`1.2.3`), caret (`^1.2.3`), tilde (`~1.2.3`),
--- wildcard (`*`), and plain tags (`v1.2.3`).

local M = {}

--- Parse a version string into components.
--- Strips leading `v` prefix. Missing components default to 0.
---@param str string Version string (e.g. 'v1.2.3', '1.2', '1')
---@return { major: integer, minor: integer, patch: integer }?
function M.parse(str)
  if not str or str == '' then return nil end
  local s = str:match('^v?(.+)$') or str
  local major, minor, patch = s:match('^(%d+)%.?(%d*)%.?(%d*)')
  if not major then return nil end
  return {
    major = tonumber(major) or 0,
    minor = tonumber(minor) or 0,
    patch = tonumber(patch) or 0,
  }
end

--- Compare two parsed versions.
---@param a { major: integer, minor: integer, patch: integer }
---@param b { major: integer, minor: integer, patch: integer }
---@return integer -1, 0, or 1
function M.compare(a, b)
  if a.major ~= b.major then return a.major < b.major and -1 or 1 end
  if a.minor ~= b.minor then return a.minor < b.minor and -1 or 1 end
  if a.patch ~= b.patch then return a.patch < b.patch and -1 or 1 end
  return 0
end

--- Check if version >= lower bound.
---@param v { major: integer, minor: integer, patch: integer }
---@param bound { major: integer, minor: integer, patch: integer }
---@return boolean
function M.gte(v, bound)
  return M.compare(v, bound) >= 0
end

--- Check if version < upper bound.
---@param v { major: integer, minor: integer, patch: integer }
---@param bound { major: integer, minor: integer, patch: integer }
---@return boolean
function M.lt(v, bound)
  return M.compare(v, bound) < 0
end

--- Compute upper bound for a caret range (^).
--- ^1.2.3 → <2.0.0 (major bump)
--- ^0.2.3 → <0.3.0 (minor bump when major=0)
--- ^0.0.3 → <0.0.4 (patch bump when major=0, minor=0)
---@param v { major: integer, minor: integer, patch: integer }
---@return { major: integer, minor: integer, patch: integer }
function M._caret_upper(v)
  if v.major > 0 then
    return { major = v.major + 1, minor = 0, patch = 0 }
  elseif v.minor > 0 then
    return { major = 0, minor = v.minor + 1, patch = 0 }
  else
    return { major = 0, minor = 0, patch = v.patch + 1 }
  end
end

--- Compute upper bound for a tilde range (~).
--- ~1.2.3 → <1.3.0 (minor bump)
---@param v { major: integer, minor: integer, patch: integer }
---@return { major: integer, minor: integer, patch: integer }
function M._tilde_upper(v)
  return { major = v.major, minor = v.minor + 1, patch = 0 }
end

--- Check if a version satisfies a range string.
--- Supported formats:
---   '*'       → any version
---   '1.2.3'   → exact match
---   '^1.2.3'  → >=1.2.3, <2.0.0
---   '~1.2.3'  → >=1.2.3, <1.3.0
---   '>=1.2.3' → greater or equal
---@param version { major: integer, minor: integer, patch: integer }
---@param range string Range expression
---@return boolean
function M.satisfies(version, range)
  if range == '*' then return true end

  local op, rest = range:match('^([~^>=]+)(.+)$')
  if not op then
    -- Exact match (or bare version like '1.2')
    local target = M.parse(range)
    if not target then return false end
    return M.compare(version, target) == 0
  end

  local base = M.parse(rest)
  if not base then return false end

  if op == '^' then
    return M.gte(version, base) and M.lt(version, M._caret_upper(base))
  elseif op == '~' then
    return M.gte(version, base) and M.lt(version, M._tilde_upper(base))
  elseif op == '>=' then
    return M.gte(version, base)
  end

  return false
end

--- Pick the best matching tag from a list of tag strings.
--- Returns the latest tag that satisfies the range.
---@param tags string[] List of tag strings (e.g. {'v1.0.0', 'v1.1.0', 'v2.0.0'})
---@param range string Semver range expression
---@return string? Best matching tag string, or nil
function M.best_match(tags, range)
  if range == '*' then
    -- For wildcard, pick latest semver tag
    local best_tag, best_ver = nil, nil
    for _, tag in ipairs(tags) do
      local v = M.parse(tag)
      if v then
        if not best_ver or M.compare(v, best_ver) > 0 then
          best_ver = v
          best_tag = tag
        end
      end
    end
    return best_tag
  end

  local best_tag, best_ver = nil, nil
  for _, tag in ipairs(tags) do
    local v = M.parse(tag)
    if v and M.satisfies(v, range) then
      if not best_ver or M.compare(v, best_ver) > 0 then
        best_ver = v
        best_tag = tag
      end
    end
  end
  return best_tag
end

--- Check if a version string looks like a semver range (vs branch name).
---@param version string
---@return boolean
function M.is_range(version)
  if version == '*' then return true end
  return version:match('^[~^>=]') ~= nil or version:match('^v?%d') ~= nil
end

return M
