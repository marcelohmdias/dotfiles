local icons = require('core.icons')

---@param config {type?:string, args?:string[]|fun():string[]?}
local function get_args(config)
  local args = type(config.args) == 'function' and (config.args() or {}) or config.args or {}
  local args_str = type(args) == 'table' and table.concat(args, ' ') or args

  config = vim.deepcopy(config)
  config.args = function()
    local new_args = vim.fn.expand(vim.fn.input('Run with args: ', args_str))
    if config.type and config.type == 'java' then
      return new_args
    end
    return require('dap.utils').splitstr(new_args)
  end
  return config
end

local M = { gh('mfussenegger/nvim-dap') }

M.config = function()
  vim.api.nvim_set_hl(0, 'DapStoppedLine', { default = true, link = 'Visual' })

  local dap_icons = {
    Breakpoint = { icons.dap.breakpoint, 'DiagnosticInfo' },
    BreakpointCondition = { icons.dap.breakpoint, 'DiagnosticWarn' },
    BreakpointRejected = { icons.dap.breakpoint, 'DiagnosticError' },
    LogPoint = { icons.dap.logpoint, 'DiagnosticInfo' },
    Stopped = { icons.dap.stopped, 'DiagnosticWarn', 'DapStoppedLine' },
  }

  for name, sign in pairs(dap_icons) do
    vim.fn.sign_define('Dap' .. name, { text = sign[1], texthl = sign[2], linehl = sign[3], numhl = sign[3] })
  end

  -- Setup dap config by VsCode launch.json file
  local vscode = require('dap.ext.vscode')
  vscode.json_decode = function(str)
    return vim.json.decode(str:gsub('/%*.-%*/', ''):gsub('//[^\n]*', ''))
  end

  -- Setup dap-ui
  local dap = require('dap')
  local dapui = require('dapui')
  dapui.setup()
  dap.listeners.after.event_initialized['dapui_config'] = function() dapui.open({}) end
  dap.listeners.before.event_terminated['dapui_config'] = function() dapui.close({}) end
  dap.listeners.before.event_exited['dapui_config'] = function() dapui.close({}) end

  -- Setup virtual text
  require('nvim-dap-virtual-text').setup()

  -- Setup mason-nvim-dap
  require('mason-nvim-dap').setup({
    automatic_installation = { exclude = { 'chrome' } },
    handlers = {},
  })
end

M.dependencies = {
  gh('rcarriga/nvim-dap-ui'),
  gh('theHamsta/nvim-dap-virtual-text'),
  gh('jay-babu/mason-nvim-dap.nvim'),
}

-- stylua: ignore
M.keys = {
  { '<leader>dB', function() require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = 'Breakpoint Condition' },
  { '<leader>db', function() require('dap').toggle_breakpoint() end, desc = 'Toggle Breakpoint' },
  { '<leader>dc', function() require('dap').continue() end, desc = 'Run/Continue' },
  { '<leader>da', function() require('dap').continue({ before = get_args }) end, desc = 'Run with Args' },
  { '<leader>dC', function() require('dap').run_to_cursor() end, desc = 'Run to Cursor' },
  { '<leader>dg', function() require('dap').goto_() end, desc = 'Go to Line (No Execute)' },
  { '<leader>di', function() require('dap').step_into() end, desc = 'Step Into' },
  { '<leader>dj', function() require('dap').down() end, desc = 'Down' },
  { '<leader>dk', function() require('dap').up() end, desc = 'Up' },
  { '<leader>dl', function() require('dap').run_last() end, desc = 'Run Last' },
  { '<leader>do', function() require('dap').step_out() end, desc = 'Step Out' },
  { '<leader>dO', function() require('dap').step_over() end, desc = 'Step Over' },
  { '<leader>dP', function() require('dap').pause() end, desc = 'Pause' },
  { '<leader>dr', function() require('dap').repl.toggle() end, desc = 'Toggle REPL' },
  { '<leader>ds', function() require('dap').session() end, desc = 'Session' },
  { '<leader>dt', function() require('dap').terminate() end, desc = 'Terminate' },
  { '<leader>dw', function() require('dap.ui.widgets').hover() end, desc = 'Widgets' },
  { '<leader>du', function() require('dapui').toggle({}) end, desc = 'Dap UI' },
  { '<leader>de', function() require('dapui').eval() end, desc = 'Eval', mode = { 'n', 'x' } },
}

return M
