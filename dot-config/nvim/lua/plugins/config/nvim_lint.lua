local M = { gh('mfussenegger/nvim-lint') }

M.config = function(_, opts)
  local lint = require('lint')

  for name, linter in pairs(opts.linters) do
    if type(linter) == 'table' and type(lint.linters[name]) == 'table' then
      lint.linters[name] = vim.tbl_deep_extend('force', lint.linters[name], linter)
      if type(linter.prepend_args) == 'table' then
        lint.linters[name].args = lint.linters[name].args or {}
        vim.list_extend(lint.linters[name].args, linter.prepend_args)
      end
    else
      lint.linters[name] = linter
    end
  end

  lint.linters_by_ft = opts.linters_by_ft

  local function debounce(ms, fn)
    local timer = vim.uv.new_timer()
    return function(...)
      local argv = { ... }
      timer:start(ms, 0, function()
        timer:stop()
        vim.schedule_wrap(fn)(unpack(argv))
      end)
    end
  end

  local function do_lint()
    local names = lint._resolve_linter_by_ft(vim.bo.filetype)
    names = vim.list_extend({}, names)

    -- Fallback linters
    if #names == 0 then vim.list_extend(names, lint.linters_by_ft['_'] or {}) end

    -- Global linters
    vim.list_extend(names, lint.linters_by_ft['*'] or {})

    -- Filter invalid/conditional linters
    local ctx = { filename = vim.api.nvim_buf_get_name(0) }
    ctx.dirname = vim.fn.fnamemodify(ctx.filename, ':h')
    names = vim.tbl_filter(function(name)
      local linter = lint.linters[name]
      if not linter then
        vim.notify('[MiniPack] Linter not found: ' .. name, vim.log.levels.WARN)
      end
      return linter and not (type(linter) == 'table' and linter.condition and not linter.condition(ctx))
    end, names)

    if #names > 0 then lint.try_lint(names) end
  end

  vim.api.nvim_create_autocmd(opts.events, {
    group = vim.api.nvim_create_augroup('minipack_lint', { clear = true }),
    callback = debounce(100, do_lint),
  })
end

M.event = 'LazyFile'

---@type table
M.opts = {
  events = { 'BufReadPost', 'BufWritePost', 'InsertLeave' },
  linters_by_ft = {
    fish = { 'fish' },
    gitcommit = { 'commitlint' },
    ['*'] = { 'cspell' },
  },
  ---@type table<string, table>
  linters = {
    commitlint = {
      condition = function()
        local configs = {
          '.commitlintrc',
          '.commitlintrc.json',
          '.commitlintrc.yaml',
          '.commitlintrc.yml',
          '.commitlintrc.js',
          '.commitlintrc.cjs',
          '.commitlintrc.mjs',
          '.commitlintrc.ts',
          '.commitlintrc.cts',
          'commitlint.config.js',
          'commitlint.config.cjs',
          'commitlint.config.mjs',
          'commitlint.config.ts',
          'commitlint.config.cts',
        }
        return vim.fs.root(0, configs) ~= nil
      end,
    },
    cspell = {
      condition = function(ctx)
        local configs = { '.cspell.json', 'cspell.json', '.cspell.jsonc', 'cspell.config.yaml', 'cspell.config.js' }
        return vim.fs.root(ctx.dirname, configs) ~= nil
      end,
    },
  },
}

return M
