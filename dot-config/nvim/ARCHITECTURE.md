# MiniPack — Architecture

> Technical reference for the MiniPack wrapper and core infrastructure.

## Boot Sequence

`init.lua` → `require('core').setup()` — single entry point.

```
1. vim.loader.enable()              — bytecode cache
2. package.preload lazy.stats/lazy.status shims
3. config.globals                   — leader, feature flags, disabled builtins
4. core.utils → _G.MiniPack        — formatexpr, statuscolumn, root detection
5. config.options                   — vim.opt.* settings
6. core.pkg.sources → _G.gh, _G.cb — URL builders
7. core.mappers → _G.map/cmd/autocmd — keymap/autocmd helpers
8. vim.pack.add() foundations       — mini.misc, mini.icons, snacks.nvim, catppuccin
9. Foundation setup                 — MiniMisc, MiniIcons, Snacks minimal init
10. Pre-plugin config               — colorscheme, autocmds, diagnostics
11. core.pkg.setup()                — resolve + install + load all plugins
12. _G.MiniPack.pending_count       — lazy closure to pkg.ui
13. Post-plugin config              — keymaps (needs has_key), lsp (needs plugins)
```

Order is critical: globals before options, sources before foundation URLs, mappers before any keymap, foundation before colorscheme, pkg.setup before keymaps/lsp.

## Foundation Plugins

Loaded outside MiniPack via `vim.pack.add()` in `core/init.lua`:

| Plugin | Why | Setup |
|--------|-----|-------|
| `mini.misc` | `safely()` error handling + scheduling | `setup()`, auto_root, restore_cursor, termbg_sync |
| `mini.icons` | Icon provider for many plugins | `setup()`, mock_nvim_web_devicons, tweak_lsp_kind |
| `snacks.nvim` | Notifier + dashboard needed early | Minimal `setup({})`, full config via spec `lazy=false` |
| `catppuccin` | Colorscheme before first draw | Config in `config/colorscheme.lua` |

## MiniPack Wrapper (`core/pkg/`)

### Module Responsibilities

| Module | Role |
|--------|------|
| `init.lua` | `setup()`, `:MiniPack` command, `PackChanged` hook for builds |
| `loader.lua` | `load_plugin()`, event/cmd/key stubs, `VeryLazy`/`LazyFile`, `has_key()` |
| `resolver.lua` | Import chain resolution: file → require, dir → scan alphabetical |
| `sources.lua` | `gh('org/repo')` → GitHub URL, `cb()` → Codeberg URL |
| `spec.lua` | Normalize `[1]`→`src`, derive `name`, validate, merge duplicate specs |
| `status.lua` | `stats()`, `updates()`, foundation counting, `package.preload` shims |
| `ui.lua` | Modal UI, git info, update checker, `resolve_upstream()`, `git_fallback_update()` |

### `core/icons.lua`

Pure data module — all icons defined here as single source of truth. No external dependencies. Used by `ui.lua`, `lualine`, `diagnostics`, and plugin specs via `require('core.icons')`.

### Setup Flow

```
setup({ import = 'plugins', confirm = true })
  → resolver: scan lua/plugins/*.lua (top-level only, alphabetical)
  → resolver: follow import chains recursively
  → spec: normalize + validate + filter enabled=false
  → separate: lazy=false first, then lazy specs
  → PackChanged autocmd for build hooks
  → vim.pack.add() missing plugins (with confirm)
  → loader.register_specs() — index by name
  → load lazy=false plugins immediately
  → loader: register stubs for lazy specs (event/cmd/keys)
  → register VeryLazy + LazyFile events
  → call init() for all specs
  → :MiniPack command
  → (deferred) periodic update check timer
  → (post-VeryLazy) resolve version='*' tags + ensure_checkout
```

### Spec Format

Single table per file in `lua/plugins/config/`:

```lua
local M = { gh('org/repo') }
M.event = 'LazyFile'
M.opts = { ... }
return M
```

| Field | Type | Description |
|-------|------|-------------|
| `[1]`/`src` | `string` | `'org/repo'` or full URL (required unless config-only) |
| `name` | `string?` | Auto-derived from src; explicit for config-only specs |
| `version` | `string?` | Branch/tag/commit, `'*'` = latest tag (resolved post-VeryLazy) |
| `lazy` | `bool` | Default `true`. `false` = load at startup |
| `enabled` | `bool\|fn` | Skip when false |
| `event` | `str\|str[]` | Autocmd events to trigger load |
| `cmd` | `str\|str[]` | Commands to trigger load |
| `keys` | `table[]` | Keymaps to trigger load (lazy.nvim format) |
| `ft` | `str\|str[]` | Filetypes (normalized to `FileType` events) |
| `dependencies` | `str[]` | Source strings, loaded before parent |
| `opts` | `table\|fn` | Passed to `require(name).setup(opts)` |
| `config` | `fn\|bool` | Custom setup; receives `(plugin, opts)` |
| `init` | `fn` | Runs before plugin loads |
| `build` | `fn\|str\|list` | After install/update (`:Cmd`, shell, or function) |

### Spec Merge

Multiple specs with same `name` (from `src`) are merged:
- `opts`: deep-merged via `vim.tbl_deep_extend`
- List fields (`keys`, `event`, `cmd`, `dependencies`): concatenated
- Scalar fields (`src`, `name`, `config`, `init`, `build`, `lazy`): primary wins

### Lazy-Load Mechanics

**load_plugin(spec)**: check loaded → load deps → `packadd` → resolve opts → run config/setup

**Event stubs**: one autocmd per distinct event → on trigger: delete stub → load plugins → replay event chain

**Command stubs**: `nvim_create_user_command` → delete stubs → load → replay with original args

**Key stubs**: `vim.keymap.set` → replace with real mappings → load → feedkeys replay. `has_key(lhs, mode)` prevents `_G.map()` from overwriting stubs.

### Update System (`ui.lua`)

**`resolve_upstream(path, cb)`**: async. Detects if HEAD is on a tag or branch, compares with latest.

**`git_fallback_update(path)`**: sync. Fetch + detect tag vs branch + checkout latest. Returns `true` if HEAD changed.

**`check_updates_bg(cb)`**: fetches all remotes, compares HEAD vs upstream per plugin. Periodic timer: first check at 5min, then hourly.

### Custom Events

```lua
-- VeryLazy: UIEnter + vim.schedule()
-- LazyFile: first BufReadPost/BufNewFile/BufWritePre + vim.schedule()
-- Both normalized to 'User VeryLazy' / 'User LazyFile' in spec
-- ft field normalized to 'FileType <ft>'
```

## Config Modules (`config/`)

| Module | Role |
|--------|------|
| `globals.lua` | Leader keys, feature flags, disabled builtins |
| `options.lua` | `vim.opt.*` settings |
| `keymaps.lua` | Editor-only keymaps (plugin keymaps in specs) |
| `autocmds.lua` | Non-plugin autocmds |
| `colorscheme.lua` | Colorscheme setup |
| `diagnostics.lua` | `vim.diagnostic.config()` + signs + navigation |
| `lsp.lua` | `vim.lsp.enable()` + LspAttach keymaps |

## Plugin Index Files

Four index files in `lua/plugins/` group specs by category. Each returns a list of imports in **alphabetical order**.

- `coding.lua` — Completion, pairs, surround, AI, comments
- `editor.lua` — Navigation, git, search, diagnostics, key discovery
- `miscellaneous.lua` — Formatters, linters, DAP, testing, treesitter, mason
- `ui.lua` — Statusline, tabline, dashboard, image, noice

## Performance

- Version resolution (`version='*'`) deferred to post-VeryLazy
- Tag cache in `minipack-tag-cache.json`
- `pkg/ui.lua` lazy-loaded (not required at boot)
- `pkg/status.lua` via `package.preload` (loaded on first access)
- `MiniPack.pending_count` wrapped in closure to avoid requiring ui at boot

## Error Handling

- `MiniMisc.safely()` for all loader operations — never crash editor
- `pcall` where safely() not available
- Log format: `[MiniPack] message`

## Commands

`:MiniPack update|clean|status|health|reload` — single command with subcommand parsing + tab-completion.

## Key Constraints

- `vim.pack` does NOT support `version = '*'` — MiniPack resolves via `git ls-remote --tags`
- `vim.pack.add` checkout only works on install, not retroactive — MiniPack enforces post-install
- `vim.pack.update` is async, no callback — MiniPack polls HEAD to detect completion
- `vim.pack.update` can fail with assertion for blobless clones — fallback via git direct
- Plugins must be in detached HEAD for vim.pack to recognize management
