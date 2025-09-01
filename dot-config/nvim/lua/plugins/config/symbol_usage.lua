local M = { "Wansmer/symbol-usage.nvim" }

M.event = "BufReadPre"

M.keys = {
  {
    "<leader>uU",
    function()
      require("symbol-usage").toggle()
    end,
    desc = "Toggle Symbol Usage",
  },
}

---@module "symbol-usage"
---@param opts UserOpts
function M.opts(_, opts)
  local function text_format(symbol)
    local fragments = {}

    -- Indicator that shows if there are any other symbols in the same line
    local stacked_functions = symbol.stacked_count > 0 and (" | +%s"):format(symbol.stacked_count)
      or ""

    if symbol.references then
      local usage = symbol.references <= 1 and "usage" or "usages"
      local num = symbol.references == 0 and "no" or symbol.references
      table.insert(fragments, ("%s %s"):format(num, usage))
    end

    if symbol.definition then
      table.insert(fragments, symbol.definition .. " defs")
    end

    if symbol.implementation then
      table.insert(fragments, symbol.implementation .. " impls")
    end

    return table.concat(fragments, ", ") .. stacked_functions
  end

  return vim.tbl_deep_extend("force", opts, {
    text_format = text_format,
  })
end

return M
