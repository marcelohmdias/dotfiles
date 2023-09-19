local wez = require "wezterm"
local UI = require "utils.ui"

local M = {}

function M.init() wez.on("format-tab-title", UI.format_title) end

return M
