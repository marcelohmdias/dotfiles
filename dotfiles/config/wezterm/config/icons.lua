local wez = require 'wezterm'

local M = {}

-- Apps
M.flatpak = "󰚰"
M.nala = "󰚰"
M.nvim = ""
M.vim = ""
M.term = ""
M.update = "󰚰"
M.upgrade = "󰚰"

-- CLIs
M.btm = ""
M.btop = ""
M.getnf = ""
M.gh = ""
M.git = "󰊢"
M.github = ""
M.htop = ""
M.lazydocker = "󰡨"
M.lazygit = "󰊢"
M.lf = ""
M.tig = "󰊢"
M.tmux = ""

-- Hardwares
M.keyboard = "󰌌"

-- Commands
M.activate_pane = "󰌌"
M.calendar = ""
M.clock = ""
M.copy = "󰆏"
M.execute = ""
M.mod = "󰹻"
M.resize_pane = "󰌌"

-- Dev Environments
M.cargo = "󱘗"
M.java = "󰬷"
M.node = "󰎙"
M.nvm = "󰎙"
M.rust = "󱘗"
M.rustc = "󱘗"

-- Paths
M.folder = wez.pad_right("", 2)
M.home = wez.pad_right("", 2)

return M
