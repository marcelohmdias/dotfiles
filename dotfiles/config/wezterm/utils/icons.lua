local icons = require "constants.icons"
local Path = require "utils.path"

local M = {}

function M:get_icon(name)
  name = string.lower(name)

  if name:match "copy" then return icons.copy end

  if name:match "%.sh$" then return icons.execute end

  if name == "~" then return icons.home end

  if Path:is_path(name) then return icons.folder end

  return icons[name] or icons.term
end

return M