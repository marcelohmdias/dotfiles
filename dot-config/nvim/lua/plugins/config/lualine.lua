local icons = require('core.icons')

local M = { gh('nvim-lualine/lualine.nvim') }

M.event = 'VeryLazy'

M.init = function()
  vim.g.lualine_laststatus = vim.o.laststatus
  if vim.fn.argc(-1) > 0 then
    vim.o.statusline = ' '
  else
    vim.o.laststatus = 0
  end

  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'snacks_dashboard',
    callback = function()
      local ok, lualine = pcall(require, 'lualine')
      if ok then
        lualine.hide({ unhide = false })
      end
    end,
  })

  vim.api.nvim_create_autocmd('BufLeave', {
    callback = function()
      if vim.bo.filetype == 'snacks_dashboard' then
        vim.schedule(function()
          local ok, lualine = pcall(require, 'lualine')
          if ok then
            lualine.hide({ unhide = true })
          end
        end)
      end
    end,
  })
end

M.opts = function()
  local lualine_require = require('lualine_require')
  lualine_require.require = require

  vim.o.laststatus = vim.g.lualine_laststatus

  -- Resolve muted color once at config time (static table, no per-render alloc)
  local muted
  do
    local ok, palette = pcall(require, 'catppuccin.palettes')
    local p = ok and palette.get_palette() or nil
    muted = { fg = p and p.overlay2 or Snacks.util.color('Comment') }
  end

  -- Pre-compute static icon strings once
  local branch_icon = vim.trim(icons.git.branch)
  local neovim_icon = vim.trim(icons.misc.neovim)
  local dap_icon = icons.dap.debug
  local namespace_icon = icons.kinds.Namespace
  local lsp_icon = icons.misc.lsp

  -- Copilot status → kind lookup (avoids repeated ternary chains)
  local copilot_kind_map = { error = 'Error', pending = 'Warning', ok = 'Normal' }
  local copilot_icons = {
    Error = { ' ', 'DiagnosticError' },
    Inactive = { ' ', 'MsgArea' },
    Warning = { ' ', 'DiagnosticWarn' },
    Normal = { icons.kinds.Copilot, 'Special' },
  }

  -- Shared predicate: buffer has a filename
  local function not_empty()
    return vim.api.nvim_buf_get_name(0) ~= ''
  end

  -- Resolve copilot kind once per call (avoids duplicate get_clients + status reads)
  local function copilot_kind()
    if not vim.g.copilot_enabled then
      return nil
    end
    local clients = vim.lsp.get_clients({ name = 'copilot', bufnr = 0 })
    if #clients == 0 then
      return nil
    end
    return copilot_kind_map[vim.g.copilot_status] or 'Inactive'
  end

  local package_icon = vim.trim(icons.kinds.Package)

  return {
    options = {
      component_separators = '',
      disabled_filetypes = { statusline = { 'dashboard', 'snacks_dashboard' } },
      globalstatus = vim.o.laststatus == 3,
      section_separators = '',
      theme = 'auto',
    },
    sections = {
      lualine_a = {
        function()
          return neovim_icon
        end,
      },
      lualine_b = { 'mode' },
      lualine_c = {
        { 'branch', icon = branch_icon, padding = { left = 2, right = 1 } },
        {
          'diff',
          padding = { left = 0, right = 1 },
          symbols = { added = icons.git.added, modified = icons.git.modified, removed = icons.git.removed },
        },
        {
          'filetype',
          color = muted,
          icon_only = true,
          cond = not_empty,
          padding = { left = 1, right = 0 },
          separator = '',
        },
        {
          'filename',
          cond = not_empty,
          padding = 0,
          symbols = { modified = ' ', readonly = ' ', unnamed = ' ', newfile = ' ' },
        },
        {
          'diagnostics',
          symbols = {
            error = icons.alerts.error,
            warn = icons.alerts.warn,
            info = icons.alerts.info,
            hint = icons.alerts.hint,
          },
        },
      },
      lualine_x = {
        -- Snacks profiler (already lazy, returns static component)
        Snacks.profiler.status(),
        -- Noice recording/mode indicator
        -- stylua: ignore start
        {
          function() return require('noice').api.status.mode.get() end,
          cond = function()
            if not package.loaded['noice'] then return false end
            if not require('noice').api.status.mode.has() then return false end
            -- Filter out wakatime coding time (e.g. "3 hrs 11 mins")
            local mode = require('noice').api.status.mode.get()
            return not mode:match('^%d+ %a+ %d+ %a+') and not mode:match('^%d+ %a+$')
          end,
          color = function() return { fg = Snacks.util.color('Constant') } end,
        },
        -- MiniPack pending updates
        {
          function()
            local count = MiniPack.pending_count and MiniPack.pending_count() or 0
            return count > 0 and (package_icon .. ' ' .. count) or ''
          end,
          cond = function()
            local count = MiniPack.pending_count and MiniPack.pending_count() or 0
            return count > 0
          end,
          color = function() return { fg = Snacks.util.color('Special') } end,
        },
        -- OpenCode AI status
        {
          function() return package.loaded['opencode'] and require('opencode').statusline() or '' end,
          cond = function() return package.loaded['opencode'] ~= nil end,
          color = function() return { fg = Snacks.util.color('Special') } end,
        },
        -- Copilot inline completion status
        {
          function()
            local kind = copilot_kind()
            return kind and copilot_icons[kind][1] or nil
          end,
          cond = function() return copilot_kind() ~= nil end,
          color = function()
            local kind = copilot_kind()
            if not kind then return muted end
            return { fg = Snacks.util.color(copilot_icons[kind][2]) }
          end,
        },
        -- DAP debugger status
        {
          function() return dap_icon .. require('dap').status() end,
          cond = function() return package.loaded['dap'] and require('dap').status() ~= '' end,
          color = function() return { fg = Snacks.util.color('Debug') } end,
        },
        -- stylua: ignore end
        -- File metadata (static color, low-cost builtins)
        { 'filesize', color = muted, cond = not_empty, padding = 1 },
        {
          function()
            return 'Ln:' .. vim.fn.line('.') .. '  Col:' .. vim.fn.virtcol('.')
          end,
          color = muted,
          padding = 1,
        },
        {
          function()
            if not vim.bo.expandtab then
              return 'Tabs:' .. vim.bo.tabstop
            end
            local sw = vim.bo.shiftwidth
            return 'Spaces:' .. (sw ~= 0 and sw or vim.bo.tabstop)
          end,
          color = muted,
          cond = not_empty,
          padding = 1,
        },
        { 'encoding', color = muted, cond = not_empty, fmt = string.upper, padding = 1 },
        {
          'fileformat',
          color = muted,
          cond = not_empty,
          padding = 1,
          symbols = { unix = 'LF', dos = 'CRLF', mac = 'CR' },
        },
        {
          function()
            return namespace_icon .. vim.bo.filetype
          end,
          color = muted,
          cond = not_empty,
          padding = 1,
        },
        -- LSP client name (clickable → list all buffer clients)
        {
          function()
            local clients = vim.lsp.get_clients({ bufnr = 0 })
            for _, c in ipairs(clients) do
              if c.name ~= 'copilot' then
                return vim.o.columns > 100 and c.name or 'Lsp'
              end
            end
            return 'No Active Lsp'
          end,
          color = muted,
          cond = not_empty,
          icon = lsp_icon,
          on_click = function()
            vim.schedule(function()
              local clients = vim.lsp.get_clients({ bufnr = 0 })
              if #clients == 0 then
                vim.notify('[MiniPack] No active LSP clients for this buffer', vim.log.levels.INFO)
                return
              end
              local items = {}
              for _, c in ipairs(clients) do
                items[#items + 1] = c.name .. ' (id: ' .. c.id .. ')'
              end
              vim.ui.select(items, { prompt = 'LSP Clients (buffer)' }, function() end)
            end)
          end,
          padding = { left = 1, right = 2 },
        },
      },
      lualine_y = {
        {
          function()
            return vim.fn.fnamemodify(vim.uv.cwd() or '', ':t')
          end,
          cond = not_empty,
          icon = { icons.misc.folder, align = 'left', padding = { left = 0, right = 1 } },
        },
      },
      lualine_z = {},
    },
  }
end

return M
