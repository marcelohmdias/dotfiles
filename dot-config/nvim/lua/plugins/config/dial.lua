local M = { gh('monaqa/dial.nvim') }

M.event = 'LazyFile'

M.config = function(_, opts)
  -- copy defaults to each group
  for name, group in pairs(opts.groups) do
    if name ~= 'default' then
      vim.list_extend(group, opts.groups.default)
    end
  end
  require("dial.config").augends:register_group(opts.groups)
  vim.g.dials_by_ft = opts.dials_by_ft
end

-- stylua: ignore
M.keys = {
  { "<C-a>", function() require("dial.map").manipulate("increment", "normal") end, expr = true, desc = "Increment", mode = { 'n' } },
  { "<C-a>", function() require("dial.map").manipulate("increment", "visual") end, expr = true, desc = "Increment", mode = { 'x' } },
  { "<C-x>", function() require("dial.map").manipulate("decrement", "normal") end, expr = true, desc = "Decrement", mode = { 'n' } },
  { "<C-x>", function() require("dial.map").manipulate("decrement", "visual") end, expr = true, desc = "Decrement", mode = { 'x' } },
}

M.opts = function()
  local augend = require('dial.augend')

  local logical_alias = augend.constant.new({
    elements = { '&&', '||' },
    word = false,
    cyclic = true
  })

  local ordinal_numbers = augend.constant.new({
    elements = { 'first', 'second', 'third', 'fourth', 'fifth', 'sixth', 'seventh', 'eighth', 'ninth', 'tenth' },
    word = false,
    cyclic = true,
  })

  local months = augend.constant.new({
    elements = {
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    },
    word = true,
    cyclic = true,
  })

  return {
    dials_by_ft = {
      css = 'css',
      javascript = 'typescript',
      javascriptreact = 'typescript',
      json = 'json',
      lua = 'lua',
      markdown = 'markdown',
      python = 'python',
      sass = 'css',
      scss = 'css',
      typescript = 'typescript',
      typescriptreact = 'typescript',
      vue = 'vue',
    },
    groups = {
      default = {
        augend.integer.alias.decimal,
        augend.integer.alias.decimal_int,
        augend.integer.alias.hex,
        augend.date.alias['%Y/%m/%d'],
        augend.constant.alias.en_weekday,
        augend.constant.alias.en_weekday_full,
        ordinal_numbers,
        months,
        augend.constant.alias.bool,
        augend.constant.alias.Bool,
        logical_alias,
      },
      css = {
        augend.hexcolor.new({ case = 'lower' }),
        augend.hexcolor.new({ case = 'upper' }),
      },
      json = {
        augend.semver.alias.semver,
      },
      lua = {
        augend.constant.new({ elements = { 'and', 'or' }, word = true, cyclic = true }),
      },
      markdown = {
        augend.constant.new({ elements = { '[ ]', '[x]' }, word = false, cyclic = true }),
        augend.misc.alias.markdown_header,
      },
      python = {
        augend.constant.new({ elements = { 'and', 'or' } }),
      },
      typescript = {
        augend.constant.new({ elements = { 'let', 'const' } }),
      },
      vue = {
        augend.constant.new({ elements = { 'let', 'const' } }),
        augend.hexcolor.new({ case = 'lower' }),
        augend.hexcolor.new({ case = 'upper' }),
      },
    },
  }
end

return M
