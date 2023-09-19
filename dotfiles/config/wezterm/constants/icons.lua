local wez = require "wezterm"

local M = {}

-- Apps
M.flatpak = "󰚰"
M.neovim = ""
M.nvim = ""
M.vim = ""
M.term = ""
M.update = "󰚰"
M.upgrade = "󰚰"

-- CLIs
M.apt = "󰚰"
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
M.nala = "󰚰"
M.tig = "󰊢"
M.tmux = ""
M.zap = "⚡"

-- Hardwares
M.keyboard = "󰌌"

-- Commands
M.activate_pane = ""
M.calendar = ""
M.clock = ""
M.copy = "󰆏"
M.execute = ""
M.leader = "󰹻"
M.resize_pane = "󰆾"

-- Dev Environments
M.bun = "󰎙"
M.cargo = "󱘗"
M.fvm = "󰎙"
M.g = ""
M.go = ""
M.java = "󰬷"
M.lua = "󰢱"
M.luarocks = "󰢱"
M.mvn = "󰬷"
M.node = "󰎙"
M.rust = "󱘗"
M.rustc = "󱘗"
M.sdk = "󰬷"

-- Paths
M.folder = wez.pad_right("󰝰", 2)
M.home = wez.pad_right("", 2)

-- Wezterm
M.debug = ""
M.launcher = "󰌧"
M["tab navigator"] = "󰇐"

return M
