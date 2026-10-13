# AGENTS.md — MiniPack Neovim Config

> Instructions for AI agents working on this codebase.

## Overview

Neovim 0.12 configuration with **MiniPack** — a local wrapper over `vim.pack` (built-in plugin manager). No external plugin manager. Four foundation plugins loaded before wrapper: `mini.misc`, `mini.icons`, `snacks.nvim`, `catppuccin`.

## Language & Style

- **Lua** (Neovim embedded), target **Neovim >= 0.12**
- **StyLua**: 2-space indent, 120 char width, single quotes, Unix endings (`stylua.toml` in root)

## Directory Layout

```
nvim/
├── init.lua                      → require('core').setup()
├── lua/core/                     → Boot orchestrator + MiniPack wrapper
│   ├── init.lua                  → vim.loader + foundation plugins + ordered requires
│   ├── icons.lua                 → Central icon registry (single source of truth)
│   ├── mappers.lua               → Globals: _G.map(), _G.cmd(), _G.autocmd()
│   ├── utils.lua                 → Utilities: formatexpr, statuscolumn, root detection
│   └── pkg/                      → MiniPack internals
│       ├── init.lua              → Public API: setup(), :MiniPack command, PackChanged hooks
│       ├── loader.lua            → Lazy-load stubs (event/cmd/keys), VeryLazy/LazyFile events
│       ├── resolver.lua          → Import chain resolution, file/dir scanning
│       ├── sources.lua           → URL builders: _G.gh(), _G.cb()
│       ├── spec.lua              → Spec normalization, validation, opts/config merge
│       ├── status.lua            → Stats, _G.MiniPack, lazy.stats/lazy.status shims
│       └── ui.lua                → UI modal, update checker, git operations
├── lua/config/                   → Editor configuration (no plugin dependency)
│   ├── globals.lua               → vim.g.* (leader, providers, feature flags)
│   ├── options.lua               → vim.opt.* (tabs, numbers, signcolumn, clipboard)
│   ├── keymaps.lua               → Editor-only keymaps (plugin keymaps in specs)
│   ├── autocmds.lua              → Non-plugin autocmds (yank hl, checktime, etc.)
│   ├── colorscheme.lua           → Catppuccin config + vim.cmd.colorscheme()
│   ├── diagnostics.lua           → vim.diagnostic.config + signs + navigation
│   └── lsp/                      → LSP layer (native 0.12, require-safe)
│       ├── init.lua              → Enable list + base capabilities + vim.lsp.enable()
│       ├── keymaps.lua           → LspAttach buffer-local keymaps
│       ├── handlers.lua          → Snacks.util.lsp.on handlers (inlay, move-to-file, gopls)
│       └── health.lua            → :checkhealth report for the LSP layer
├── lua/plugins/                  → Plugin index files (imports by category)
│   ├── coding.lua                → Completion, pairs, surround, AI, comments
│   ├── editor.lua                → Navigation, git, search, diagnostics, key discovery
│   ├── miscellaneous.lua         → Formatters, linters, DAP, testing, treesitter, mason
│   └── ui.lua                    → Statusline, tabline, dashboard, image, noice
├── lua/plugins/config/           → Individual plugin specs (one per plugin)
├── lsp/                          → Native Neovim 0.12 LSP server configs
├── after/ftplugin/               → Filetype-specific settings
├── snippets/                     → Snippet files
└── tests/                        → mini.test suite
```

## Core Concepts

### Boot Sequence (`core/init.lua`)

1. `vim.loader.enable()` — bytecode cache
2. `config.globals` — leader key, feature flags
3. `config.options` — editor settings
4. Expose globals: `_G.gh`, `_G.cb`, `_G.map`, `_G.cmd`, `_G.autocmd`
5. Foundation plugins via `vim.pack.add()` + immediate setup
6. Pre-plugin config: colorscheme, autocmds, diagnostics
7. `require('core.pkg').setup({ import = 'plugins', confirm = true })` — load all plugins
8. Post-plugin config:
   - `config.keymaps` (after `has_key()` available)
   - `config.lsp.setup()` (Enable List + capabilities + keymaps + handlers)

### Plugin Spec Format

Each file in `lua/plugins/config/` returns a **single spec table**:

```lua
local M = { gh('org/repo') }
M.event = 'LazyFile'
M.opts = { ... }          -- → auto require(name).setup(opts)
return M
```

- Properties in **alphabetical order**
- `opts` tables annotated with `---@module` and `---@type`
- Specs with same `name` are **merged** (opts deep-merged, lists concatenated)
- `config = function(_, opts)` for custom setup logic
- `lazy = false` for eager loading
- Config-only specs (no `src`) need explicit `M.name`

### Global Helpers

| Global | Source | Purpose |
|--------|--------|---------|
| `_G.gh(src)` | `core/pkg/sources.lua` | `'org/repo'` → `'https://github.com/org/repo'` |
| `_G.cb(src)` | `core/pkg/sources.lua` | `'org/repo'` → `'https://codeberg.org/org/repo'` |
| `_G.map(mode, lhs, rhs, opts)` | `core/mappers.lua` | Safe keymap set (skips MiniPack key stubs) |
| `_G.cmd(c)` | `core/mappers.lua` | Returns closure `function() vim.cmd(c) end` |
| `_G.autocmd(event, opts)` | `core/mappers.lua` | Autocmd with default `MiniPack` augroup |
| `_G.MiniPack` | `core/init.lua` | `pending_count()`, `formatexpr`, `statuscolumn`, `root` |

### Custom Events

- **VeryLazy**: fires after `UIEnter` + `vim.schedule()`
- **LazyFile**: fires on first `BufReadPost`/`BufNewFile`/`BufWritePre` + `vim.schedule()`

### Error Handling

- `MiniMisc.safely()` for all plugin operations — never crash editor
- `pcall` where `MiniMisc.safely()` not available
- Notifications: `vim.notify('[MiniPack] ...', vim.log.levels.WARN)`

## Plugin Index Files

Four index files in `lua/plugins/` group specs by category. Each returns a list of imports in **alphabetical order**.

### `coding.lua` — Completion, pairs, surround, AI, comments

Imports: better_escape, blink_cmp, blink_pairs, claudecode, coerce, copilot, lazydev, mini_ai, mini_operators, mini_surround, neogen, opencode, otter, template_string, treesj, ts_comments, yanky

### `editor.lua` — Navigation, git, search, diagnostics, key discovery

Imports: actions_preview, codediff, dial, flash, gitsigns, grug_far, hover, inc_rename, mini_move, multicursor, neogit, origami, outline, package_info, patterns, refactoring, snacks, snacks_explorer, snacks_picker, symbol_usage, todo_comments, trouble, vim_tmux_navigator, which_key

### `miscellaneous.lua` — Formatters, linters, DAP, testing, treesitter, mason

Imports: conform, dap, dap_dart, dap_js, dap_nlua, freemarker, garbage_day, markdown_table_mode, mason, mason_tool_installer, mini_sessions, mini_test, neotest, nvim_lint, obsidian, octo, render_markdown, schemastore, showkeys, tailwind_fold, treesitter, treesitter_textobjects, ts_autotag, ts_error_translator

### `ui.lua` — Statusline, tabline, dashboard, image, noice

Imports: blink_indent, bufferline, dropbar, edgy, helpview, lualine, modicator, neominimap, noice, nvim_highlight_colors, snacks_dashboard, snacks_image, snacks_statuscolumn, snacks_win, treesitter_context, virt_column

## Coding Conventions

- `local M = {} ... return M` module pattern
- `local` for all module-level variables
- `vim.tbl_*` helpers for table operations
- `vim.bo.*` over `vim.opt.*:get()` (performance)
- `vim.uv.cwd()` over `vim.fn.getcwd()` (performance)
- Plugin keymaps use `cmd()` helper for simple commands

## Testing

```bash
just test                                        # run all
just test-file tests/test_sources.lua            # run single file
NVIM_APPNAME=nvim-test nvim                      # isolate config
:MiniPack status                                 # plugin state
:checkhealth vim.pack                            # health check
```

- Test internals exposed via `M._` prefix

## Common Tasks

### Add a plugin

1. Create `lua/plugins/config/<name>.lua` — return spec table
2. Add `{ import = 'plugins.config.<name>' }` to index file (alphabetical)

### Add LSP server

1. Create `lsp/<server>.lua` — return `vim.lsp.Config` table
2. Add the server name to the Enable List in `lua/config/lsp/init.lua`
3. If the server needs a lifecycle handler (e.g. inlay hints, move-to-file), add it to `lua/config/lsp/handlers.lua`
4. If the server binary is managed by Mason, add the package to `lua/plugins/config/mason_tool_installer.lua`
5. Add/update tests in `tests/test_lsp.lua` for resolver and handler logic
6. Run `just test` and `stylua --check .`

### System dependencies (not managed by Mason)

These servers rely on tools installed outside Neovim/Mason:

- `denols` — Deno runtime (`deno` on PATH)
- `dartls` — Dart SDK (`dart` on PATH)

All other always-on servers must be covered by `mason-tool-installer` so the config works unchanged on macOS and Fedora.

### Add filetype settings

1. Create `after/ftplugin/<ft>.lua` — buffer-local settings

## LSP Layer — Conscious divergences from LazyVim

The config uses **native Neovim 0.12 LSP** (`vim.lsp.Config`, `vim.lsp.enable`). It does **not** use `nvim-lspconfig`, `mason-lspconfig`, or `lazy.nvim` as server managers. Parity with LazyVim is intentional only on portable values/defaults, not on architecture.

| Area | Choice | LazyVim reference |
|------|--------|-------------------|
| LSP manager | Native `vim.lsp` only | `nvim-lspconfig` + `mason-lspconfig` |
| Handler registry | Central `lua/config/lsp/handlers.lua` via `Snacks.util.lsp.on` | Per-extra handlers |
| Folds | Treesitter foldexpr (kept in `plugins/config/treesitter.lua`); LSP foldexpr only for YAML | LSP foldexpr for some filetypes |
| `gK` | Selective hover via `hover.nvim` | Signature help |
| Copilot | Ghost text + menu simultaneously (`ai_cmp` always true) | Configurable `ai_cmp` flag |
| Diagnostics styling | Custom signs/virtual text | LazyVim defaults |
| CodeLens | Native `vim.lsp.codelens` auto-display | Same, refresh keymap kept |
| vtsls keys | Per-server `gD/gR/cM/cD/cV` keys NOT adopted | Adopted in LazyVim extra |
| none-ls / neoconf | Not used | Used in LazyVim |

See `ARCHITECTURE.md` for the LSP layer module breakdown and `docs/adr/` for the ADRs.

## References

- [vim.pack guide](https://echasnovski.com/blog/2026-03-13-a-guide-to-vim-pack.html)
- [lazy.nvim](https://github.com/folke/lazy.nvim) / [LazyVim](https://github.com/lazyvim/lazyvim)
- [MiniMax](https://github.com/nvim-mini/MiniMax)
