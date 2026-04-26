---@meta

-- MiniPack global namespace
---@class MiniPackGlobal
---@field formatexpr fun(): string|number
---@field statuscolumn fun(): string
---@field root fun(opts?: { buf?: number }): string
---@field root_git fun(): string
---@field pending_count fun(): number?
---@type MiniPackGlobal
MiniPack = {}

-- Root detection types
---@alias MiniPackRootFn fun(buf: number): (string|string[])
---@alias MiniPackRootSpec string|string[]|MiniPackRootFn

-- URL builders
---@type fun(source: string): string
gh = nil
---@type fun(source: string): string
cb = nil

-- Mapper helpers
---@type fun(mode: string|string[], lhs: string, rhs: string|fun(), opts?: vim.keymap.set.Opts)
map = nil
---@type fun(c: string): fun()
cmd = nil
---@type fun(event: string|string[], opts: vim.api.keyset.create_autocmd)
autocmd = nil

-- Plugin globals (injected at runtime by setup())
---@type table
Snacks = nil
---@type table
MiniSessions = nil
