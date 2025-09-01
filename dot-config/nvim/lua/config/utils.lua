local M = {}

function M.map(mode, lhs, rhs, opts)
  local keys = require("lazy.core.handler").handlers.keys
  ---@cast keys LazyKeysHandler
  -- do not create the keymap if a lazy keys handler exists
  if not keys.active[keys.parse({ lhs, mode = mode }).id] then
    opts = opts or {}
    opts.silent = opts.silent ~= true
    opts.noremap = opts.noremap ~= true
    vim.keymap.set(mode, lhs, rhs, opts)
  end
end

function M.merge(base, opts)
  return vim.tbl_deep_extend("force", base or {}, opts)
end

function M.split_to_table(str, pattern)
  local chunks = {}
  for substr in string.gmatch(str, pattern) do
    table.insert(chunks, substr)
  end
  return chunks
end

return M
