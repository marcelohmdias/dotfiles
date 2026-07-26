local icons = require('core.icons')

local M = { gh('folke/snacks.nvim') }

--- Dynamic preset: use vscode for narrow windows, default otherwise.
---@return string
local function get_dynamic_preset()
  return vim.o.columns >= 140 and 'default' or 'vertical'
end

-- stylua: ignore
M.keys = {
  { '<leader>,',       function() Snacks.picker.buffers() end,                                 desc = 'Buffers' },
  { '<leader>/',       function() Snacks.picker.grep() end,                                    desc = 'Grep (Root Dir)' },
  { '<leader>:',       function() Snacks.picker.command_history() end,                         desc = 'Command History' },
  { '<leader><space>', function() Snacks.picker.smart({ layout = { preset = 'vscode' } }) end, desc = 'Find Files (Root Dir)' },
  -- find
  { '<leader>fb',      function() Snacks.picker.buffers() end,                                 desc = 'Buffers' },
  { '<leader>fB',      function() Snacks.picker.buffers({ hidden = true, nofile = true }) end, desc = 'Buffers (all)' },
  { '<leader>ff',      function() Snacks.picker.files() end,                                   desc = 'Find Files (Root Dir)' },
  { '<leader>fF',      function() Snacks.picker.files({ dirs = { vim.uv.cwd() } }) end,        desc = 'Find Files (cwd)' },
  { '<leader>fg',      function() Snacks.picker.git_files() end,                               desc = 'Find Files (git)' },
  { '<leader>fr',      function() Snacks.picker.recent() end,                                  desc = 'Recent' },
  { '<leader>fR',      function() Snacks.picker.recent({ filter = { cwd = true } }) end,       desc = 'Recent (cwd)' },
  { '<leader>fp',      function() Snacks.picker.projects() end,                                desc = 'Projects' },
  -- git
  { '<leader>gd',      function() Snacks.picker.git_diff() end,                                desc = 'Git Diff (hunks)' },
  { '<leader>gs',      function() Snacks.picker.git_status() end,                              desc = 'Git Status' },
  { '<leader>gS',      function() Snacks.picker.git_stash() end,                               desc = 'Git Stash' },
  -- grep
  { '<leader>sb',      function() Snacks.picker.lines() end,                                   desc = 'Buffer Lines' },
  { '<leader>sB',      function() Snacks.picker.grep_buffers() end,                            desc = 'Grep Open Buffers' },
  { '<leader>sg',      function() Snacks.picker.grep() end,                                    desc = 'Grep (Root Dir)' },
  { '<leader>sG',      function() Snacks.picker.grep({ dirs = { vim.uv.cwd() } }) end,         desc = 'Grep (cwd)' },
  { '<leader>sw',      function() Snacks.picker.grep_word() end,                               desc = 'Visual selection or word (Root Dir)', mode = { 'n', 'x' } },
  { '<leader>sW',      function() Snacks.picker.grep_word({ dirs = { vim.uv.cwd() } }) end,    desc = 'Visual selection or word (cwd)',      mode = { 'n', 'x' } },
  -- search
  { '<leader>s"',      function() Snacks.picker.registers() end,                               desc = 'Registers' },
  { '<leader>s/',      function() Snacks.picker.search_history() end,                          desc = 'Search History' },
  { '<leader>sa',      function() Snacks.picker.autocmds() end,                                desc = 'Autocmds' },
  { '<leader>sc',      function() Snacks.picker.command_history() end,                         desc = 'Command History' },
  { '<leader>sC',      function() Snacks.picker.commands() end,                                desc = 'Commands' },
  { '<leader>sd',      function() Snacks.picker.diagnostics() end,                             desc = 'Diagnostics' },
  { '<leader>sD',      function() Snacks.picker.diagnostics_buffer() end,                      desc = 'Buffer Diagnostics' },
  { '<leader>sh',      function() Snacks.picker.help() end,                                    desc = 'Help Pages' },
  { '<leader>sH',      function() Snacks.picker.highlights() end,                              desc = 'Highlights' },
  { '<leader>si',      function() Snacks.picker.icons() end,                                   desc = 'Icons' },
  { '<leader>sj',      function() Snacks.picker.jumps() end,                                   desc = 'Jumps' },
  { '<leader>sk',      function() Snacks.picker.keymaps() end,                                 desc = 'Keymaps' },
  { '<leader>sl',      function() Snacks.picker.loclist() end,                                 desc = 'Location List' },
  { '<leader>sm',      function() Snacks.picker.marks() end,                                   desc = 'Marks' },
  { '<leader>sM',      function() Snacks.picker.man() end,                                     desc = 'Man Pages' },
  { '<leader>sR',      function() Snacks.picker.resume() end,                                  desc = 'Resume' },
  { '<leader>sq',      function() Snacks.picker.qflist() end,                                  desc = 'Quickfix List' },
  { '<leader>su',      function() Snacks.picker.undo() end,                                    desc = 'Undotree' },
  -- ui
  { '<leader>uC',      function() Snacks.picker.colorschemes() end,                            desc = 'Colorschemes' },
}

---@type snacks.Config
M.opts = {
  picker = {
    actions = {
      opencode_send = function(...)
        return require('opencode').snacks_picker_send(...)
      end,
      ---@param p snacks.Picker
      toggle_cwd = function(p)
        local root = MiniPack.root({ buf = p.input.filter.current_buf, normalize = true })
        local cwd = vim.fs.normalize(vim.uv.cwd() or '.')
        local current = p:cwd()
        p:set_cwd(current == root and cwd or root)
        p:find()
      end,
    },
    icons = {
      files = {
        enabled = true,
      },
      diagnostic = icons.alerts,
      git = icons.git,
      kinds = icons.kinds,
    },
    layouts = {
      default = {
        layout = {
          border = 'none',
        },
      },
      sidebar = {
        layout = {
          width = 45,
          min_width = 45,
          position = 'left',
          border = 'none',
        },
      },
      vscode = {
        layout = {
          backdrop = false,
          row = 1,
          width = 0.4,
          min_width = 80,
          height = 0.4,
          border = 'none',
          box = 'vertical',
          {
            win = 'input',
            height = 1,
            border = 'rounded',
            title = '{title} {live} {flags}',
            title_pos = 'center',
          },
          { win = 'list',    border = 'rounded' },
          { win = 'preview', title = '{preview}', border = 'rounded' },
        },
      },
    },
    prompt = icons.misc.telescope,
    sources = {
      explorer = {
        auto_close = true,
        layout = { preview = { main = true, enabled = false } },
      },
      files = {
        layout = { preset = get_dynamic_preset },
      },
      keymaps = {
        confirm = function(picker, item)
          picker:close()
          if item then
            vim.schedule(function()
              vim.api.nvim_input(item.item.lhs)
            end)
          end
        end,
      },
      lsp_symbols = {
        layout = { preset = 'vscode', preview = 'main' },
      },
      lsp_workspace_symbols = {
        layout = { preset = 'vscode', preview = 'main' },
      },
      recent = {
        layout = { preset = get_dynamic_preset },
      },
    },
    ui_select = true,
    win = {
      input = {
        keys = {
          ['<a-a>'] = {
            'opencode_send',
            mode = { 'n', 'i' },
          },
          ['<a-c>'] = {
            'toggle_cwd',
            mode = { 'n', 'i' },
          },
        },
      },
    },
  },
}

return M
