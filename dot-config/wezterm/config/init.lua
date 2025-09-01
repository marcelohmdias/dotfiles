-- Class based on https://github.com/KevinSilvester/wezterm-config/blob/master/config/init.lua

local wez = require "wezterm"

--- @class Config
--- @field options table
local Config = {}
Config.__index = Config

--- Initialize term config
---@return Config
function Config:setup()
  local config = setmetatable({ options = {} }, self)
  return config
end

--- Append to `Config.options`
--- @param opts table new options to append
--- @return Config
function Config:add(opts)
  for k, v in pairs(opts) do
    if self.options[k] ~= nil then
      wez.log_warn("Duplicate config option detected: ", { old = self.options[k], new = opts[k] })
      goto continue
    end
    self.options[k] = v
    ::continue::
  end
  return self
end

--- Build Wezterm config
--- @return table
function Config:build() return self.options end

return Config
