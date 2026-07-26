local M = { gh('mfussenegger/nvim-dap') }

M.config = function()
  local dap = require('dap')

  -- Dart uses the Dart CLI's built-in debug adapter
  dap.adapters.dart = {
    type = 'executable',
    command = 'dart',
    args = { 'debug_adapter' },
  }

  -- Flutter uses the same adapter with flutter tooling
  dap.adapters.flutter = {
    type = 'executable',
    command = 'flutter',
    args = { 'debug_adapter' },
  }

  dap.configurations.dart = {
    {
      type = 'dart',
      request = 'launch',
      name = 'Launch Dart',
      program = '${file}',
      cwd = '${workspaceFolder}',
    },
    {
      type = 'flutter',
      request = 'launch',
      name = 'Launch Flutter',
      program = '${workspaceFolder}/lib/main.dart',
      cwd = '${workspaceFolder}',
    },
  }
end

return M
