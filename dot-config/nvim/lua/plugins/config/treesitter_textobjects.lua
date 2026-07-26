local M = { gh('nvim-treesitter/nvim-treesitter-textobjects') }

M.config = function(_, opts)
  local TS = require('nvim-treesitter-textobjects')

  if not TS.setup then
    vim.notify('[MiniPack] Please update nvim-treesitter-textobjects', vim.log.levels.ERROR)
    return
  end

  TS.setup(opts)

  local function attach(buf)
    local ft = vim.bo[buf].filetype
    local lang = vim.treesitter.language.get_lang(ft)
    if not lang then
      return
    end

    local has_query = pcall(vim.treesitter.query.get, lang, 'textobjects')
      and vim.treesitter.query.get(lang, 'textobjects') ~= nil
    if not (vim.tbl_get(opts, 'move', 'enable') and has_query) then
      return
    end

    local moves = vim.tbl_get(opts, 'move', 'keys') or {}

    for method, keymaps in pairs(moves) do
      for key, query in pairs(keymaps) do
        local queries = type(query) == 'table' and query or { query }
        local parts = {}
        for _, q in ipairs(queries) do
          local part = q:gsub('@', ''):gsub('%..*', '')
          part = part:sub(1, 1):upper() .. part:sub(2)
          table.insert(parts, part)
        end
        local desc = table.concat(parts, ' or ')
        desc = (key:sub(1, 1) == '[' and 'Prev ' or 'Next ') .. desc
        desc = desc .. (key:sub(2, 2) == key:sub(2, 2):upper() and ' End' or ' Start')
        vim.keymap.set({ 'n', 'x', 'o' }, key, function()
          if vim.wo.diff and key:find('[cC]') then
            return vim.cmd('normal! ' .. key)
          end
          require('nvim-treesitter-textobjects.move')[method](query, 'textobjects')
        end, { buffer = buf, desc = desc, silent = true })
      end
    end
  end

  vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('minipack_treesitter_textobjects', { clear = true }),
    callback = function(ev)
      attach(ev.buf)
    end,
  })
  vim.tbl_map(attach, vim.api.nvim_list_bufs())
end

M.event = 'LazyFile'

---@module 'nvim-treesitter-textobjects'
---@type TSTextObjects.UserConfig
M.opts = {
  move = {
    enable = true,
    keys = {
      goto_next_end = {
        [']A'] = '@parameter.inner',
        [']C'] = '@class.outer',
        [']F'] = '@function.outer',
      },
      goto_next_start = {
        [']a'] = '@parameter.inner',
        [']c'] = '@class.outer',
        [']f'] = '@function.outer',
      },
      goto_previous_end = {
        ['[A'] = '@parameter.inner',
        ['[C'] = '@class.outer',
        ['[F'] = '@function.outer',
      },
      goto_previous_start = {
        ['[a'] = '@parameter.inner',
        ['[c'] = '@class.outer',
        ['[f'] = '@function.outer',
      },
    },
    set_jumps = true,
  },
}

M.version = 'main'

return M
