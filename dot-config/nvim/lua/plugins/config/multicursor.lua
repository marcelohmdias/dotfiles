local M = { gh('jake-stewart/multicursor.nvim') }

M.version = '1.0'
M.event = 'LazyFile'

function M.config()
  local mc = require('multicursor-nvim')
  mc.setup()

  -- stylua: ignore start

  -- Add or skip adding a new cursor by matching word/selection.
  map({ 'n', 'x' }, '<c-n>', function() mc.matchAddCursor(1) end, { desc = 'Add cursor (next match)' })
  map({ 'n', 'x' }, '<c-p>', function() mc.matchAddCursor(-1) end, { desc = 'Add cursor (prev match)' })

  -- Add and remove cursors with control + left click.
  map('n', '<c-leftmouse>', mc.handleMouse, { desc = 'Add cursor (mouse)' })
  map('n', '<c-leftdrag>', mc.handleMouseDrag)
  map('n', '<c-leftrelease>', mc.handleMouseRelease)

  -- Disable and enable cursors.
  map({ 'n', 'x' }, '<c-q>', mc.toggleCursor, { desc = 'Toggle cursor' })

  -- Add a cursor for all matches in the document.
  map({ 'n', 'x' }, '<leader>A', mc.matchAllAddCursors, { desc = 'Add cursor (all matches)' })

  -- stylua: ignore end

  mc.addKeymapLayer(function(layerSet)
    -- stylua: ignore start
    layerSet({ 'n', 'x' }, '<left>', mc.prevCursor)
    layerSet({ 'n', 'x' }, '<right>', mc.nextCursor)
    layerSet({ 'n', 'x' }, '<leader>x', mc.deleteCursor)
    -- stylua: ignore end

    layerSet('n', '<esc>', function()
      if not mc.cursorsEnabled() then
        mc.enableCursors()
      else
        mc.clearCursors()
      end
    end)
  end)
end

return M
