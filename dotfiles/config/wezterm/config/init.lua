local wez = require "wezterm"

-- Class based on https://github.com/KevinSilvester/wezterm-config/blob/master/config/init.lua

--- @class Config
--- @field options table
local Config = {}

--- Initialize term config
---@return Config
function Config:init()
  local o = {}
  self = setmetatable(o, { __index = Config })

  self.options = {}

  -- if wez.config_builder then self.options = wez.config_builder() end

  return o
end

--- Append to `Config.options`
--- @param opts table new options to append
--- @return Config
function Config:append(opts)
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
