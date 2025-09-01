local wez = require "wezterm"

local M = {}

-- Apps
M.flatpak = "󰏗"
M.vim = ""
M.neovim = " "
M.nvim = ""
M.term = " "
M.update = "󰚰 "
M.upgrade = "󰚰 "

-- CLIs
M.apt = "󰚰 "
M.brew = "󰚰 "
M.btm = " "
M.btop = " "
M.fzf = "󱩾 "
M.curl = "󰄠 "
M.getnf = " "
M.gh = " "
M.git = "󰊢 "
M.github = " "
M.htop = " "
M.lazydocker = "󰡨 "
M.lazygit = "󰊢 "
M.lf = " "
M.mise = "󰏗 "
M.nala = "󰚰 "
M.ollama = "󰚩 "
M.sesh = " "
M.tig = "󰊢 "
M.tmux = ""
M.wget = "󰄠 "
M.yazi = "󱁿 "
M.zap = " "

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
M.bun = "󰎙 "
M.cargo = "󱘗 "
M.fnm = "󰎙 "
M.g = " "
M.go = " "
M.java = "󰬷 "
M.lua = "󰢱 "
M.luarocks = "󰢱 "
M.mvn = "󰬷 "
M.node = "󰎙 "
M.npm = "󰎙 "
M.pnpm = "󰎙 "
M.rust = "󱘗 "
M.rustc = "󱘗 "
M.sdk = " "
M.yarn = "󰎙 "

-- Paths
M.folder = wez.pad_right("󰝰 ", 2)
M.home = wez.pad_right(" ", 2)

-- Wezterm
M.debug = " "
M.launcher = "󰌧 "
M["tab navigator"] = "󰇐 "

return M
