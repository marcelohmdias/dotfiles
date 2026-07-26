local M = { gh('mfussenegger/nvim-dap') }

M.config = function()
  local dap = require('dap')

  -- Register pwa-* adapters (all use js-debug-adapter executable)
  for _, adapter_type in ipairs({ 'node', 'chrome', 'msedge' }) do
    local pwa_type = 'pwa-' .. adapter_type

    if not dap.adapters[pwa_type] then
      dap.adapters[pwa_type] = {
        type = 'server',
        host = 'localhost',
        port = '${port}',
        executable = {
          command = 'js-debug-adapter',
          args = { '${port}' },
        },
      }
    end

    -- Alias without pwa- prefix for VSCode launch.json compat
    if not dap.adapters[adapter_type] then
      dap.adapters[adapter_type] = function(cb, config)
        local native = dap.adapters[pwa_type]
        config.type = pwa_type
        if type(native) == 'function' then
          native(cb, config)
        else
          cb(native)
        end
      end
    end
  end

  -- Map filetypes for VSCode launch.json
  local js_filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' }
  local vscode = require('dap.ext.vscode')
  vscode.type_to_filetypes['node'] = js_filetypes
  vscode.type_to_filetypes['pwa-node'] = js_filetypes

  -- Default configurations per JS/TS filetype
  for _, language in ipairs(js_filetypes) do
    if not dap.configurations[language] then
      local runtime = nil
      if language:find('typescript') then
        runtime = vim.fn.executable('tsx') == 1 and 'tsx' or 'ts-node'
      end

      dap.configurations[language] = {
        {
          type = 'pwa-node',
          request = 'launch',
          name = 'Launch file',
          program = '${file}',
          cwd = '${workspaceFolder}',
          resolveSourceMapLocations = { '${workspaceFolder}/**', '!**/node_modules/**' },
          runtimeExecutable = runtime,
          skipFiles = { '<node_internals>/**', 'node_modules/**' },
          sourceMaps = true,
        },
        {
          type = 'pwa-node',
          request = 'attach',
          name = 'Attach',
          cwd = '${workspaceFolder}',
          processId = require('dap.utils').pick_process,
          resolveSourceMapLocations = { '${workspaceFolder}/**', '!**/node_modules/**' },
          skipFiles = { '<node_internals>/**', 'node_modules/**' },
          sourceMaps = true,
        },
        {
          type = 'pwa-chrome',
          request = 'launch',
          name = 'Launch Chrome',
          url = 'http://localhost:3000',
          webRoot = '${workspaceFolder}',
          sourceMaps = true,
        },
      }
    end
  end
end

return M
