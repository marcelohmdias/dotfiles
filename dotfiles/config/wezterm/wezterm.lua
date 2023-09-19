local Config = require "config"

require("events.tab-title").init()
require("events.update-status").init()

return Config:init()
  :append(require "config.color-scheme")
  :append(require "config.fonts")
  :append(require "config.gui")
  :append(require "config.hyperlink-rules")
  :append(require "config.keybinds")
  :append(require "config.launch")
  :append(require "config.term")
  :build()
