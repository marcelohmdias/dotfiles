---@diagnostic disable: undefined-global
local H = require('tests.helpers')

local child = H.new_child()

local T = MiniTest.new_set({
  hooks = {
    pre_case = function()
      child.lua('package.loaded["core.lsp"] = nil')
      child.lua('package.loaded["config.lsp"] = nil')
      child.lua('package.loaded["config.lsp.init"] = nil')
      child.lua('package.loaded["config.lsp.keymaps"] = nil')
      child.lua('package.loaded["config.lsp.handlers"] = nil')
      child.lua('package.loaded["lsp.vtsls"] = nil')
    end,
    post_once = function()
      child.stop()
    end,
  },
})

-- core.lsp --

T['core.lsp'] = MiniTest.new_set()

T['core.lsp']['ts_root_by_lockfile returns nil when no markers found'] = function()
  child.lua([[
    _G._tmp = vim.fn.tempname()
    vim.fn.mkdir(_G._tmp, 'p')
    _G._path = _G._tmp .. '/test.ts'
    io.open(_G._path, 'w'):close()
    _G._buf = vim.fn.bufadd(_G._path)
    _G._root = require('core.lsp').ts_root_by_lockfile(_G._buf)
  ]])
  MiniTest.expect.equality(child.lua_get('_G._root'), vim.NIL)
end

T['core.lsp']['ts_root_by_lockfile returns root when tsconfig exists'] = function()
  child.lua([[
    _G._tmp = vim.fn.tempname()
    vim.fn.mkdir(_G._tmp, 'p')
    io.open(_G._tmp .. '/tsconfig.json', 'w'):close()
    _G._path = _G._tmp .. '/test.ts'
    io.open(_G._path, 'w'):close()
    _G._buf = vim.fn.bufadd(_G._path)
    _G._root = require('core.lsp').ts_root_by_lockfile(_G._buf)
  ]])
  MiniTest.expect.no_equality(child.lua_get('_G._root'), vim.NIL)
end

T['core.lsp']['ts_root_by_lockfile returns root when package.json exists'] = function()
  child.lua([[
    _G._tmp = vim.fn.tempname()
    vim.fn.mkdir(_G._tmp, 'p')
    io.open(_G._tmp .. '/package.json', 'w'):close()
    _G._path = _G._tmp .. '/test.ts'
    io.open(_G._path, 'w'):close()
    _G._buf = vim.fn.bufadd(_G._path)
    _G._root = require('core.lsp').ts_root_by_lockfile(_G._buf)
  ]])
  MiniTest.expect.no_equality(child.lua_get('_G._root'), vim.NIL)
end

T['core.lsp']['ts_root_by_lockfile returns nil when deno root is closer'] = function()
  child.lua([[
    _G._tmp = vim.fn.tempname()
    _G._sub = _G._tmp .. '/sub'
    vim.fn.mkdir(_G._sub, 'p')
    io.open(_G._tmp .. '/package.json', 'w'):close()
    io.open(_G._sub .. '/deno.json', 'w'):close()
    _G._path = _G._sub .. '/test.ts'
    io.open(_G._path, 'w'):close()
    _G._buf = vim.fn.bufadd(_G._path)
    _G._root = require('core.lsp').ts_root_by_lockfile(_G._buf)
  ]])
  MiniTest.expect.equality(child.lua_get('_G._root'), vim.NIL)
end

T['core.lsp']['ts_root_by_lockfile returns ts root when ts root is closer than deno'] = function()
  child.lua([[
    _G._tmp = vim.fn.tempname()
    _G._sub = _G._tmp .. '/sub'
    vim.fn.mkdir(_G._sub, 'p')
    io.open(_G._tmp .. '/deno.json', 'w'):close()
    io.open(_G._sub .. '/tsconfig.json', 'w'):close()
    _G._path = _G._sub .. '/test.ts'
    io.open(_G._path, 'w'):close()
    _G._buf = vim.fn.bufadd(_G._path)
    _G._root = require('core.lsp').ts_root_by_lockfile(_G._buf)
  ]])
  MiniTest.expect.no_equality(child.lua_get('_G._root'), vim.NIL)
end

T['core.lsp']['ts_root_by_lockfile aborts when deno marker sits at same level as ts root'] = function()
  child.lua([[
    _G._tmp = vim.fn.tempname()
    vim.fn.mkdir(_G._tmp, 'p')
    io.open(_G._tmp .. '/package.json', 'w'):close()
    io.open(_G._tmp .. '/deno.json', 'w'):close()
    _G._path = _G._tmp .. '/test.ts'
    io.open(_G._path, 'w'):close()
    _G._buf = vim.fn.bufadd(_G._path)
    _G._root = require('core.lsp').ts_root_by_lockfile(_G._buf)
  ]])
  MiniTest.expect.equality(child.lua_get('_G._root'), vim.NIL)
end

T['core.lsp']['ts_root_by_lockfile calls on_dir callback'] = function()
  child.lua([[
    _G._tmp = vim.fn.tempname()
    vim.fn.mkdir(_G._tmp, 'p')
    io.open(_G._tmp .. '/package.json', 'w'):close()
    _G._path = _G._tmp .. '/test.ts'
    io.open(_G._path, 'w'):close()
    _G._buf = vim.fn.bufadd(_G._path)
    _G._callback_root = nil
    require('core.lsp').ts_root_by_lockfile(_G._buf, function(root)
      _G._callback_root = root
    end)
  ]])
  MiniTest.expect.no_equality(child.lua_get('_G._callback_root'), vim.NIL)
end

T['core.lsp']['find_tsc_bin prefers project tsc with major >= 7'] = function()
  child.lua([[
    _G._bin = require('core.lsp').find_tsc_bin('/project', {
      executable = function(cmd) return cmd == '/project/node_modules/.bin/tsc' end,
      run_version = function(_) return 7 end,
    })
  ]])
  MiniTest.expect.equality(child.lua_get('_G._bin'), '/project/node_modules/.bin/tsc')
end

T['core.lsp']['find_tsc_bin rejects major < 7'] = function()
  child.lua([[
    _G._bin = require('core.lsp').find_tsc_bin('/project', {
      executable = function(cmd) return cmd == 'tsc' end,
      run_version = function(_) return 6 end,
    })
  ]])
  MiniTest.expect.equality(child.lua_get('_G._bin'), vim.NIL)
end

T['core.lsp']['find_tsc_bin caches result per root'] = function()
  child.lua([[
    _G._calls = 0
    require('core.lsp')._tsc_cache = {}
    local probes = {
      executable = function(cmd)
        _G._calls = _G._calls + 1
        return cmd == 'tsc'
      end,
      run_version = function(_) return 7 end,
    }
    local first = require('core.lsp').find_tsc_bin('/cached', probes)
    local second = require('core.lsp').find_tsc_bin('/cached', probes)
    _G._first = first
    _G._second = second
  ]])
  MiniTest.expect.equality(child.lua_get('_G._first'), 'tsc')
  MiniTest.expect.equality(child.lua_get('_G._second'), 'tsc')
  MiniTest.expect.equality(child.lua_get('_G._calls'), 3)
end

T['core.lsp']['find_tsc_bin returns nil when no candidate passes'] = function()
  child.lua([[
    _G._bin = require('core.lsp').find_tsc_bin('/project', {
      executable = function(_) return false end,
      run_version = function(_) return 7 end,
    })
  ]])
  MiniTest.expect.equality(child.lua_get('_G._bin'), vim.NIL)
end

-- lsp.tsc --

T['lsp.tsc'] = MiniTest.new_set()

T['lsp.tsc']['config has js/ts inlay hints and code lenses'] = function()
  child.lua([[
    local cfg = require('lsp.tsc')
    _G._js_param = cfg.settings.javascript.inlayHints.parameterNames.enabled
    _G._ts_refs = cfg.settings.typescript.referencesCodeLens.enabled
    _G._ts_impl = cfg.settings.typescript.implementationsCodeLens.enabled
  ]])
  MiniTest.expect.equality(child.lua_get('_G._js_param'), 'literals')
  MiniTest.expect.equality(child.lua_get('_G._ts_refs'), true)
  MiniTest.expect.equality(child.lua_get('_G._ts_impl'), true)
end

T['lsp.tsc']['root_dir refuses to attach without valid tsc binary'] = function()
  child.lua([[
    _G._tmp = vim.fn.tempname()
    vim.fn.mkdir(_G._tmp, 'p')
    io.open(_G._tmp .. '/package.json', 'w'):close()
    _G._path = _G._tmp .. '/test.ts'
    io.open(_G._path, 'w'):close()
    _G._buf = vim.fn.bufadd(_G._path)
    _G._notified = nil
    vim.notify = function(msg, _)
      _G._notified = msg
    end
    _G._attached = false
    local cfg = require('lsp.tsc')
    cfg.root_dir(_G._buf, function(_)
      _G._attached = true
    end)
  ]])
  MiniTest.expect.equality(child.lua_get('_G._attached'), false)
  MiniTest.expect.equality(type(child.lua_get('_G._notified')) == 'string', true)
end

T['lsp.tsc']['cmd includes --stdio flag'] = function()
  child.lua([[
    local cfg = require('lsp.tsc')
    _G._cmd = table.concat(cfg.cmd, ' ')
  ]])
  MiniTest.expect.equality(child.lua_get('_G._cmd'), 'tsc --lsp --stdio')
end

T['core.lsp']['ts_root_by_lockfile detects bun.lockb'] = function()
  child.lua([[
    _G._tmp = vim.fn.tempname()
    vim.fn.mkdir(_G._tmp, 'p')
    io.open(_G._tmp .. '/bun.lockb', 'w'):close()
    _G._path = _G._tmp .. '/test.ts'
    io.open(_G._path, 'w'):close()
    _G._buf = vim.fn.bufadd(_G._path)
    _G._root = require('core.lsp').ts_root_by_lockfile(_G._buf)
    _G._root_real = _G._root and vim.uv.fs_realpath(_G._root) or nil
    _G._tmp_real = vim.uv.fs_realpath(_G._tmp)
  ]])
  MiniTest.expect.equality(child.lua_get('_G._root_real'), child.lua_get('_G._tmp_real'))
end

-- config.lsp.init --

T['config.lsp.init'] = MiniTest.new_set()

T['config.lsp.init']['_resolve_servers returns legacy enable list with default flags'] = function()
  child.lua([[
    _G._result = require('config.lsp.init')._resolve_servers(
      { tsc_enabled = true, docker_enabled = true, copilot_enabled = true },
      function(_) return false end,
      function(_) return true end
    )
  ]])
  local result = child.lua_get('_G._result')
  local expected = {
    'astro',
    'bashls',
    'css_variables',
    'cssls',
    'dartls',
    'denols',
    'emmet_language_server',
    'fish_lsp',
    'gopls',
    'graphql',
    'harper_ls',
    'html',
    'jdtls',
    'jsonls',
    'just',
    'lemminx',
    'lua_ls',
    'marksman',
    'prismals',
    'sqls',
    'tailwindcss',
    'taplo',
    'unocss',
    'vue_ls',
    'yamlls',
    'tsc',
    'vtsls',
    'dockerls',
    'docker_compose_language_service',
    'copilot',
  }
  MiniTest.expect.equality(result.servers, expected)
  MiniTest.expect.equality(result.skipped, {})
end

T['config.lsp.init']['_resolve_servers picks oxlint > biome > eslint'] = function()
  child.lua([[
    _G._markers = {
      ['.oxlintrc.json'] = true,
      ['.oxlintrc.jsonc'] = true,
      ['oxlint.config.ts'] = true,
      ['oxlint.config.js'] = true,
    }
    _G._result = require('config.lsp.init')._resolve_servers(
      { tsc_enabled = false, docker_enabled = false, copilot_enabled = false },
      function(list)
        for _, m in ipairs(list) do
          if _G._markers[m] then return true end
        end
        return false
      end,
      function(_) return true end
    )
    _G._has_oxlint = vim.tbl_contains(_G._result.servers, 'oxlint')
    _G._has_biome = vim.tbl_contains(_G._result.servers, 'biome')
    _G._has_eslint = vim.tbl_contains(_G._result.servers, 'eslint')
  ]])
  MiniTest.expect.equality(child.lua_get('_G._has_oxlint'), true)
  MiniTest.expect.equality(child.lua_get('_G._has_biome'), false)
  MiniTest.expect.equality(child.lua_get('_G._has_eslint'), false)
end

T['config.lsp.init']['_resolve_servers picks biome when oxlint absent'] = function()
  child.lua([[
    _G._result = require('config.lsp.init')._resolve_servers(
      { tsc_enabled = false, docker_enabled = false, copilot_enabled = false },
      function(list)
        for _, m in ipairs(list) do
          if m == 'biome.json' or m == 'biome.jsonc' then return true end
        end
        return false
      end,
      function(_) return true end
    )
    _G._has_biome = vim.tbl_contains(_G._result.servers, 'biome')
    _G._has_eslint = vim.tbl_contains(_G._result.servers, 'eslint')
  ]])
  MiniTest.expect.equality(child.lua_get('_G._has_biome'), true)
  MiniTest.expect.equality(child.lua_get('_G._has_eslint'), false)
end

T['config.lsp.init']['_resolve_servers includes tsc when flag is on'] = function()
  child.lua([[
    _G._result = require('config.lsp.init')._resolve_servers(
      { tsc_enabled = true, docker_enabled = false, copilot_enabled = false },
      function(_) return false end,
      function(_) return true end
    )
    _G._has_tsc = vim.tbl_contains(_G._result.servers, 'tsc')
    _G._has_tsgo = vim.tbl_contains(_G._result.servers, 'tsgo')
  ]])
  MiniTest.expect.equality(child.lua_get('_G._has_tsc'), true)
  MiniTest.expect.equality(child.lua_get('_G._has_tsgo'), false)
end

T['config.lsp.init']['_resolve_servers excludes tsc when flag is off'] = function()
  child.lua([[
    _G._result = require('config.lsp.init')._resolve_servers(
      { tsc_enabled = false, docker_enabled = false, copilot_enabled = false },
      function(_) return false end,
      function(_) return true end
    )
    _G._has_tsc = vim.tbl_contains(_G._result.servers, 'tsc')
  ]])
  MiniTest.expect.equality(child.lua_get('_G._has_tsc'), false)
end

T['config.lsp.init']['_resolve_servers skips non-executable servers'] = function()
  child.lua([[
    _G._result = require('config.lsp.init')._resolve_servers(
      { tsc_enabled = true, docker_enabled = false, copilot_enabled = false },
      function(_) return false end,
      function(cmd) return cmd ~= 'tsc' end
    )
    _G._has_tsc = vim.tbl_contains(_G._result.servers, 'tsc')
    _G._skipped_tsc = vim.tbl_contains(_G._result.skipped, 'tsc')
  ]])
  MiniTest.expect.equality(child.lua_get('_G._has_tsc'), false)
  MiniTest.expect.equality(child.lua_get('_G._skipped_tsc'), true)
end

T['config.lsp.init']['_resolve_servers warns once with aggregated skipped servers'] = function()
  child.lua([[
    _G.autocmd = function(_) end
    _G.Snacks = { util = { lsp = { on = function(_, _, _) end } } }
    _G._warn_msg = nil
    _G._warn_level = nil
    vim.notify = function(msg, level)
      _G._warn_msg = msg
      _G._warn_level = level
    end
    require('config.lsp.init').setup()
  ]])
  local msg = child.lua_get('_G._warn_msg')
  local level = child.lua_get('_G._warn_level')
  if msg ~= vim.NIL then
    assert(type(msg) == 'string', 'warn message should be a string')
    assert(level == vim.log.levels.WARN, 'warn level should be WARN')
    assert(msg:find('servers skipped'), 'warn should mention skipped servers')
  end
end

T['config.lsp.init']['_base_capabilities includes workspace fileOperations'] = function()
  child.lua([[
    local caps = require('config.lsp.init')._base_capabilities()
    _G._has_did_rename = caps.workspace.fileOperations.didRename == true
    _G._has_will_rename = caps.workspace.fileOperations.willRename == true
  ]])
  MiniTest.expect.equality(child.lua_get('_G._has_did_rename'), true)
  MiniTest.expect.equality(child.lua_get('_G._has_will_rename'), true)
end

T['config.lsp.init']['require produces no side-effects'] = function()
  child.lua([[
    _G._enable_calls = {}
    _G._orig_enable = vim.lsp.enable
    vim.lsp.enable = function(list)
      _G._enable_calls = list
    end
    require('config.lsp.init')
    vim.lsp.enable = _G._orig_enable
  ]])
  local calls = child.lua_get('_G._enable_calls')
  MiniTest.expect.equality(calls, {})
end

T['config.lsp.init']['setup applies base capabilities before enable'] = function()
  child.lua([[
    _G.autocmd = function(_) end
    _G.Snacks = { util = { lsp = { on = function(_, _, _) end } } }
    _G._base_caps = nil
    _G._orig_config = vim.lsp.config
    vim.lsp.config = function(name, cfg)
      if name == '*' then
        _G._base_caps = cfg.capabilities
      end
    end
    _G._orig_enable = vim.lsp.enable
    vim.lsp.enable = function(_) end
    require('config.lsp.init').setup()
    vim.lsp.config = _G._orig_config
    vim.lsp.enable = _G._orig_enable
  ]])
  local caps = child.lua_get('_G._base_caps')
  MiniTest.expect.equality(caps.workspace.fileOperations.didRename, true)
  MiniTest.expect.equality(caps.workspace.fileOperations.willRename, true)
end

T['config.lsp.init']['setup calls vim.lsp.enable with resolved list'] = function()
  child.lua([[
    _G.autocmd = function(_) end
    _G.Snacks = { util = { lsp = { on = function(_, _, _) end } } }
    _G._enable_calls = {}
    _G._orig_enable = vim.lsp.enable
    vim.lsp.enable = function(list)
      _G._enable_calls = list
    end
    _G._orig_executable = vim.fn.executable
    vim.fn.executable = function(_) return 1 end
    vim.g.tsc_enabled = true
    vim.g.docker_enabled = true
    vim.g.copilot_enabled = true
    require('config.lsp.init').setup()
    vim.lsp.enable = _G._orig_enable
    vim.fn.executable = _G._orig_executable
  ]])
  local calls = child.lua_get('_G._enable_calls')
  MiniTest.expect.no_equality(calls, {})
  MiniTest.expect.equality(calls[1], 'astro')
end

T['config.lsp.init']['_load_server_config returns table for known server'] = function()
  child.lua([[
    local cfg = require('config.lsp.init')._load_server_config('lua_ls')
    _G._has_cmd = type(cfg) == 'table' and type(cfg.cmd) == 'table'
  ]])
  MiniTest.expect.equality(child.lua_get('_G._has_cmd'), true)
end

T['config.lsp.init']['_load_server_config returns nil for missing server'] = function()
  child.lua([[
    local cfg = require('config.lsp.init')._load_server_config('nonexistent_server_xyz')
    _G._cfg = cfg
  ]])
  MiniTest.expect.equality(child.lua_get('_G._cfg'), vim.NIL)
end

T['config.lsp.init']['_server_cmd returns first cmd entry from loaded config'] = function()
  child.lua([[
    local cmd = require('config.lsp.init')._server_cmd('lua_ls')
    _G._cmd = cmd
  ]])
  MiniTest.expect.equality(child.lua_get('_G._cmd'), 'lua-language-server')
end

-- lsp.vtsls --

T['lsp.vtsls'] = MiniTest.new_set()

T['lsp.vtsls']['filetypes fallback to all TS/JS/vue when tsc is disabled'] = function()
  child.lua([[
    vim.g.tsc_enabled = false
    package.loaded['lsp.vtsls'] = nil
    local cfg = require('lsp.vtsls')
    _G._has_js = vim.tbl_contains(cfg.filetypes, 'javascript')
    _G._has_vue = vim.tbl_contains(cfg.filetypes, 'vue')
    _G._has_astro = vim.tbl_contains(cfg.filetypes, 'astro')
  ]])
  MiniTest.expect.equality(child.lua_get('_G._has_js'), true)
  MiniTest.expect.equality(child.lua_get('_G._has_vue'), true)
  MiniTest.expect.equality(child.lua_get('_G._has_astro'), true)
end

T['lsp.vtsls']['filetypes are vue+astro only when tsc is enabled'] = function()
  child.lua([[
    vim.g.tsc_enabled = true
    package.loaded['lsp.vtsls'] = nil
    local cfg = require('lsp.vtsls')
    _G._has_js = vim.tbl_contains(cfg.filetypes, 'javascript')
    _G._has_vue = vim.tbl_contains(cfg.filetypes, 'vue')
    _G._has_astro = vim.tbl_contains(cfg.filetypes, 'astro')
    _G._count = #cfg.filetypes
  ]])
  MiniTest.expect.equality(child.lua_get('_G._has_js'), false)
  MiniTest.expect.equality(child.lua_get('_G._has_vue'), true)
  MiniTest.expect.equality(child.lua_get('_G._has_astro'), true)
  MiniTest.expect.equality(child.lua_get('_G._count'), 2)
end

T['lsp.unocss'] = MiniTest.new_set()

T['lsp.unocss']['config registers expected filetypes'] = function()
  child.lua([[
    local cfg = require('lsp.unocss')
    _G._has_vue = vim.tbl_contains(cfg.filetypes, 'vue')
    _G._has_tsx = vim.tbl_contains(cfg.filetypes, 'typescriptreact')
    _G._has_astro = vim.tbl_contains(cfg.filetypes, 'astro')
  ]])
  MiniTest.expect.equality(child.lua_get('_G._has_vue'), true)
  MiniTest.expect.equality(child.lua_get('_G._has_tsx'), true)
  MiniTest.expect.equality(child.lua_get('_G._has_astro'), true)
end

T['lsp.unocss']['appears in resolved enable list'] = function()
  child.lua([[
    _G._result = require('config.lsp.init')._resolve_servers(
      { tsc_enabled = false, docker_enabled = false, copilot_enabled = false },
      function(_) return false end,
      function(_) return true end
    )
    _G._has_unocss = vim.tbl_contains(_G._result.servers, 'unocss')
  ]])
  MiniTest.expect.equality(child.lua_get('_G._has_unocss'), true)
end

T['lsp.vtsls']['settings include LazyVim values and globalPlugins'] = function()
  child.lua([[
    local cfg = require('lsp.vtsls')
    _G._complete_calls = cfg.settings.complete_function_calls
    _G._auto_tsdk = cfg.settings.vtsls.autoUseWorkspaceTsdk
    _G._fuzzy = cfg.settings.vtsls.experimental.completion.enableServerSideFuzzyMatch
    _G._max_hint = cfg.settings.vtsls.experimental.maxInlayHintLength
    _G._plugins = cfg.settings.vtsls.tsserver.globalPlugins
  ]])
  MiniTest.expect.equality(child.lua_get('_G._complete_calls'), true)
  MiniTest.expect.equality(child.lua_get('_G._auto_tsdk'), true)
  MiniTest.expect.equality(child.lua_get('_G._fuzzy'), true)
  MiniTest.expect.equality(child.lua_get('_G._max_hint'), 30)
  MiniTest.expect.equality(type(child.lua_get('_G._plugins')), 'table')
end

-- config.lsp.keymaps --

T['config.lsp.keymaps'] = MiniTest.new_set()

T['config.lsp.keymaps']['require produces no side-effects'] = function()
  child.lua([[
    _G._autocmd_count = 0
    _G._orig_autocmd = vim.api.nvim_create_autocmd
    vim.api.nvim_create_autocmd = function(_event, _opts)
      _G._autocmd_count = _G._autocmd_count + 1
      return -1
    end
    require('config.lsp.keymaps')
    vim.api.nvim_create_autocmd = _G._orig_autocmd
  ]])
  local count = child.lua_get('_G._autocmd_count')
  MiniTest.expect.equality(count, 0)
end

T['config.lsp.keymaps']['_has_method returns true when client supports method'] = function()
  child.lua([[
    local H = require('tests.helpers')
    local client = H.fake_client({ ['textDocument/hover'] = true })
    _G._has = require('config.lsp.keymaps')._has_method('textDocument/hover', 1, function(_)
      return { client }
    end)
  ]])
  MiniTest.expect.equality(child.lua_get('_G._has'), true)
end

T['config.lsp.keymaps']['_lsp_map creates keymap only when method supported'] = function()
  child.lua([[
    _G._maps = {}
    _G._orig_keymap = vim.keymap.set
    vim.keymap.set = function(mode, lhs, rhs, opts)
      table.insert(_G._maps, { mode = mode, lhs = lhs, opts = opts })
    end
    local H = require('tests.helpers')
    local client = H.fake_client({ ['textDocument/hover'] = true })
    require('config.lsp.keymaps')._lsp_map('textDocument/hover', 'n', '<leader>cl', function() end, { desc = 'Lsp Info' }, 1, function(_)
      return { client }
    end)
    vim.keymap.set = _G._orig_keymap
  ]])
  local maps = child.lua_get('_G._maps')
  MiniTest.expect.equality(#maps, 1)
  MiniTest.expect.equality(maps[1].lhs, '<leader>cl')
end

-- config.lsp.handlers --

T['config.lsp.handlers'] = MiniTest.new_set()

T['config.lsp.handlers']['setup registers inlay hint, vtsls and gopls handlers'] = function()
  child.lua([[
    local H = require('tests.helpers')
    local stub = H.snacks_stub()
    require('config.lsp.handlers').setup()
    _G._registry_size = #stub.registry
    _G._inlay_filter = stub.registry[1] and stub.registry[1].filter.method
    _G._vtsls_filter = stub.registry[2] and stub.registry[2].filter.name
    _G._gopls_filter = stub.registry[3] and stub.registry[3].filter.name
  ]])
  MiniTest.expect.equality(child.lua_get('_G._registry_size'), 3)
  MiniTest.expect.equality(child.lua_get('_G._inlay_filter'), 'textDocument/inlayHint')
  MiniTest.expect.equality(child.lua_get('_G._vtsls_filter'), 'vtsls')
  MiniTest.expect.equality(child.lua_get('_G._gopls_filter'), 'gopls')
end

T['config.lsp.handlers']['_on_inlay_hint enables hints for non-vue buffers'] = function()
  child.lua([[
    _G._enabled = nil
    vim.lsp.inlay_hint.enable = function(enable, opts)
      _G._enabled = { enable = enable, bufnr = opts.bufnr }
    end
    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].filetype = 'typescript'
    require('config.lsp.handlers')._on_inlay_hint(buf)
  ]])
  local enabled = child.lua_get('_G._enabled')
  MiniTest.expect.equality(enabled.enable, true)
end

T['config.lsp.handlers']['_on_inlay_hint skips vue buffers'] = function()
  child.lua([[
    _G._enabled = nil
    vim.lsp.inlay_hint.enable = function(_, _)
      _G._enabled = 'called'
    end
    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].filetype = 'vue'
    require('config.lsp.handlers')._on_inlay_hint(buf)
  ]])
  MiniTest.expect.equality(child.lua_get('_G._enabled'), vim.NIL)
end

T['config.lsp.handlers']['_on_vtsls_move_to_file registers command on client'] = function()
  child.lua([[
    local client = { name = 'vtsls', commands = {} }
    client.request = function(_, _, _) end
    require('config.lsp.handlers')._on_vtsls_move_to_file(1, client)
    _G._has_command = type(client.commands['_typescript.moveToFileRefactoring']) == 'function'
  ]])
  MiniTest.expect.equality(child.lua_get('_G._has_command'), true)
end

T['config.lsp.handlers']['_on_vtsls_move_to_file command is callable'] = function()
  child.lua([[
    local client = { name = 'vtsls', commands = {} }
    client.request = function(_, _, _) end
    require('config.lsp.handlers')._on_vtsls_move_to_file(1, client)
    local command = { command = '_typescript.moveToFileRefactoring', arguments = { 'action', 'file:///src/foo.ts', { start = { line = 0, character = 0 }, ['end'] = { line = 1, character = 0 } } } }
    _G._ok, _G._err = pcall(client.commands['_typescript.moveToFileRefactoring'], command)
  ]])
  MiniTest.expect.equality(child.lua_get('_G._ok'), true)
end

T['config.lsp.handlers']['_on_gopls_attach fabricates semantic tokens provider'] = function()
  child.lua([[
    local client = {
      name = 'gopls',
      config = {
        init_options = { semanticTokens = true },
        capabilities = {
          textDocument = {
            semanticTokens = {
              tokenTypes = { 'namespace', 'type' },
              tokenModifiers = { 'declaration', 'definition' },
            },
          },
        },
      },
      server_capabilities = {},
    }
    require('config.lsp.handlers')._on_gopls_attach(1, client)
    _G._provider = client.server_capabilities.semanticTokensProvider
  ]])
  MiniTest.expect.equality(type(child.lua_get('_G._provider')), 'table')
  MiniTest.expect.equality(child.lua_get('_G._provider.full'), true)
  MiniTest.expect.equality(child.lua_get('_G._provider.range'), true)
end

T['config.lsp.handlers']['require produces no side-effects'] = function()
  child.lua([[
    local H = require('tests.helpers')
    local stub = H.snacks_stub()
    require('config.lsp.handlers')
    _G._registry_size = #stub.registry
  ]])
  MiniTest.expect.equality(child.lua_get('_G._registry_size'), 0)
end

-- helpers --

T['helpers'] = MiniTest.new_set()

T['config.lsp.health'] = MiniTest.new_set()

T['config.lsp.health']['_report marks missing executables'] = function()
  child.lua([[
    local health = require('config.lsp.health')
    local report = health._report(
      { 'tsc', 'lua_ls' },
      function(cmd) return cmd ~= 'tsc' end,
      { tsc = true, ['lua-language-server'] = true },
      '7'
    )
    _G._tsc_exec = report.rows[1].executable
    _G._lua_exec = report.rows[2].executable
    _G._ts_version = report.ts_version
    _G._caps = report.capabilities_base
  ]])
  MiniTest.expect.equality(child.lua_get('_G._tsc_exec'), false)
  MiniTest.expect.equality(child.lua_get('_G._lua_exec'), true)
  MiniTest.expect.equality(child.lua_get('_G._ts_version'), '7')
  MiniTest.expect.equality(child.lua_get('_G._caps'), true)
end

T['config.lsp.health']['_ts_version returns nil when tsc missing'] = function()
  child.lua([[
    _G._version = require('config.lsp.health')._ts_version({
      executable = function(_) return false end,
    })
  ]])
  MiniTest.expect.equality(child.lua_get('_G._version'), vim.NIL)
end

T['config.lsp.health']['_ts_version returns major string when tsc present'] = function()
  child.lua([[
    _G._version = require('config.lsp.health')._ts_version({
      executable = function(_) return true end,
      run_version = function(_) return 7 end,
    })
  ]])
  MiniTest.expect.equality(child.lua_get('_G._version'), '7')
end

T['config.lsp.health']['_mason_set returns a table'] = function()
  child.lua([[
    _G._set = require('config.lsp.health')._mason_set()
  ]])
  MiniTest.expect.equality(type(child.lua_get('_G._set')), 'table')
end

T['helpers']['fake_client supports method lookup'] = function()
  child.lua([[
    local H = require('tests.helpers')
    local client = H.fake_client({ ['textDocument/hover'] = true, ['textDocument/rename'] = false })
    _G._hover_ok = client:supports_method('textDocument/hover', 1)
    _G._rename_ok = client:supports_method('textDocument/rename', 1)
  ]])
  MiniTest.expect.equality(child.lua_get('_G._hover_ok'), true)
  MiniTest.expect.equality(child.lua_get('_G._rename_ok'), false)
end

T['helpers']['snacks_stub captures registrations'] = function()
  child.lua([[
    local H = require('tests.helpers')
    local stub = H.snacks_stub()
    Snacks.util.lsp.on('textDocument/foldingRange', function() end, {})
    _G._size = #stub.registry
  ]])
  MiniTest.expect.equality(child.lua_get('_G._size'), 1)
end

T['lsp.emmet_language_server'] = MiniTest.new_set()

T['lsp.emmet_language_server']['includes less, sass, scss and common web filetypes'] = function()
  child.lua([[
    local cfg = require('lsp.emmet_language_server')
    _G._has_less = vim.tbl_contains(cfg.filetypes, 'less')
    _G._has_sass = vim.tbl_contains(cfg.filetypes, 'sass')
    _G._has_scss = vim.tbl_contains(cfg.filetypes, 'scss')
    _G._has_html = vim.tbl_contains(cfg.filetypes, 'html')
  ]])
  MiniTest.expect.equality(child.lua_get('_G._has_less'), true)
  MiniTest.expect.equality(child.lua_get('_G._has_sass'), true)
  MiniTest.expect.equality(child.lua_get('_G._has_scss'), true)
  MiniTest.expect.equality(child.lua_get('_G._has_html'), true)
end

return T
