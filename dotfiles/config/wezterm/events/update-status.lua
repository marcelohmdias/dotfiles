local wez = require "wezterm"
local UI = require "utils.ui"

local M = {}

function M.init() wez.on("update-status", UI.format_status) end

return M
