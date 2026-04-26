local M = { gh('nvim-mini/mini.surround') }

-- stylua: ignore
M.keys = {
  { 'gsa', desc = 'Add Surrounding',                     mode = { 'n', 'x' } },
  { 'gsd', desc = 'Delete Surrounding' },
  { 'gsf', desc = 'Find Right Surrounding' },
  { 'gsF', desc = 'Find Left Surrounding' },
  { 'gsh', desc = 'Highlight Surrounding' },
  { 'gsr', desc = 'Replace Surrounding' },
  { 'gsn', desc = 'Update `MiniSurround.config.n_lines`' },
}

---@module 'mini.surround'
---@type MiniSurround.config
M.opts = {
  mappings = ({
    add = 'gsa',
    delete = 'gsd',
    find = 'gsf',
    find_left = 'gsF',
    highlight = 'gsh',
    replace = 'gsr',
    update_n_lines = 'gsn',
  }),
}

return M
