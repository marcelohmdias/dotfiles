local M = { gh('Wansmer/symbol-usage.nvim') }

M.event = 'LspAttach'

M.keys = {
  { '<leader>uU', function() require('symbol-usage').toggle() end, desc = 'Toggle Symbol Usage' },
}


---@module 'symbol-usage'
---@type UserOpts
function M.opts()
  local function text_format(symbol)
    local fragments = {}

    local stacked_functions = symbol.stacked_count > 0 and (' | +%s'):format(symbol.stacked_count) or ''

    if symbol.references then
      local usage = symbol.references <= 1 and 'usage' or 'usages'
      local num = symbol.references == 0 and 'no' or symbol.references
      table.insert(fragments, ('%s %s'):format(num, usage))
    end

    if symbol.definition then
      table.insert(fragments, symbol.definition .. ' defs')
    end

    if symbol.implementation then
      table.insert(fragments, symbol.implementation .. ' impls')
    end

    return table.concat(fragments, ', ') .. stacked_functions
  end

  return {
    text_format = text_format,
  }
end

return M
