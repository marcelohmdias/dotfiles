local M = {}

local GITHUB_URL = 'https://github.com/'
local CODEBERG_URL = 'https://codeberg.org/'

--- Shared pack path for all pkg modules.
M.PACK_PATH = vim.fn.stdpath('data') .. '/site/pack/core/opt'

--- Expand 'org/repo' to full GitHub URL.
--- Full URLs pass through unchanged.
---@param source string 'org/repo' or full URL
---@return string
function M.gh(source)
  if source:match('^https?://') then
    return source
  end
  return GITHUB_URL .. source
end

--- Expand 'org/repo' to full Codeberg URL.
--- Full URLs pass through unchanged.
---@param source string 'org/repo' or full URL
---@return string
function M.cb(source)
  if source:match('^https?://') then
    return source
  end
  return CODEBERG_URL .. source
end

return M
