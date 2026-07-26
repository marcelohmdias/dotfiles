local M = { gh('nvim-neotest/neotest') }

M.cmd = 'Neotest'

M.config = function(_, opts)
  -- Setup diagnostic namespace for compact virtual text
  local neotest_ns = vim.api.nvim_create_namespace('neotest')
  vim.diagnostic.config({
    virtual_text = {
      format = function(diagnostic)
        local msg = diagnostic.message:gsub('\n', ' '):gsub('\t', ' '):gsub('%s+', ' '):gsub('^%s+', '')
        return msg
      end,
    },
  }, neotest_ns)

  -- Resolve adapters: string keys → require + setup
  local adapters = {}
  for name, config in pairs(opts.adapters or {}) do
    if type(name) == 'number' then
      -- Already an adapter instance or string
      if type(config) == 'string' then
        adapters[#adapters + 1] = require(config)
      else
        adapters[#adapters + 1] = config
      end
    elseif config ~= false then
      local adapter = require(name)
      if type(adapter) == 'function' then
        adapters[#adapters + 1] = adapter(config)
      elseif adapter.setup then
        adapter.setup(config)
        adapters[#adapters + 1] = adapter
      elseif adapter.adapter then
        adapters[#adapters + 1] = adapter.adapter(config)
      else
        adapters[#adapters + 1] = adapter
      end
    end
  end
  opts.adapters = adapters

  require('neotest').setup(opts)
end

M.dependencies = {
  gh('marilari88/neotest-vitest'),
  gh('nvim-neotest/nvim-nio'),
  gh('nvim-neotest/neotest-vim-test'),
  gh('sidlatau/neotest-dart'),
  gh('vim-test/vim-test'),
}

-- stylua: ignore
M.keys = {
  { '<leader>t', '', desc = '+test' },
  { '<leader>ta', function() require('neotest').run.attach() end, desc = 'Attach' },
  { '<leader>td', function() require('neotest').run.run({ strategy = 'dap' }) end, desc = 'Debug Nearest' },
  { '<leader>tl', function() require('neotest').run.run_last() end, desc = 'Run Last' },
  { '<leader>to', function() require('neotest').output.open({ enter = true, auto_close = true }) end, desc = 'Show Output' },
  { '<leader>tO', function() require('neotest').output_panel.toggle() end, desc = 'Toggle Output Panel' },
  { '<leader>tr', function() require('neotest').run.run() end, desc = 'Run Nearest' },
  { '<leader>ts', function() require('neotest').summary.toggle() end, desc = 'Toggle Summary' },
  { '<leader>tS', function() require('neotest').run.stop() end, desc = 'Stop' },
  { '<leader>tt', function() require('neotest').run.run(vim.fn.expand('%')) end, desc = 'Run File' },
  { '<leader>tT', function() require('neotest').run.run(vim.uv.cwd()) end, desc = 'Run All Test Files' },
  { '<leader>tw', function() require('neotest').watch.toggle(vim.fn.expand('%')) end, desc = 'Toggle Watch' },
}

---@module 'neotest'
---@type neotest.Config
M.opts = {
  adapters = {
    ['neotest-dart'] = { command = 'flutter' },
    ['neotest-vitest'] = {},
    ['neotest-vim-test'] = {
      allow_file_types = { 'cucumber' },
    },
  },
  output = { open_on_run = true },
  quickfix = {
    open = function()
      if pcall(require, 'trouble') then
        require('trouble').open({ mode = 'quickfix', focus = false })
      else
        vim.cmd('copen')
      end
    end,
  },
  status = { virtual_text = true },
}

return M
