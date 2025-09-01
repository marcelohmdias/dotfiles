--
-- ██╗    ██╗███████╗███████╗████████╗███████╗██████╗ ███╗   ███╗
-- ██║    ██║██╔════╝╚══███╔╝╚══██╔══╝██╔════╝██╔══██╗████╗ ████║
-- ██║ █╗ ██║█████╗    ███╔╝    ██║   █████╗  ██████╔╝██╔████╔██║
-- ██║███╗██║██╔══╝   ███╔╝     ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║
-- ╚███╔███╔╝███████╗███████╗   ██║   ███████╗██║  ██║██║ ╚═╝ ██║
--  ╚══╝╚══╝ ╚══════╝╚══════╝   ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝
--
-- A GPU-accelerated cross-platform terminal emulator
-- https://wezfurlong.org/wezterm/

local Config = require "config"

require("events.tab-title").setup()
require("events.toggle-opacity").setup()
require("events.update-status").setup()
require("events.user-var-changed").setup()

return Config:setup()
  :add(require "config.color-scheme")
  :add(require "config.fonts")
  :add(require "config.gui")
  :add(require "config.environment")
  :add(require "config.hyperlink-rules")
  :add(require "config.keybinds")
  :add(require "config.launch")
  :add(require "config.term")
  :build()
