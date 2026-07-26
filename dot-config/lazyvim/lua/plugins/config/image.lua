local M = { "3rd/image.nvim" }

M.build = false

function M.config()
  local luarocks = vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1"
  package.path = package.path .. ";" .. luarocks .. "/?/init.lua"
  package.path = package.path .. ";" .. luarocks .. "/?.lua"

  require("image").setup({
    backend = "kitty",
    processor = "magick_rock", -- or "magick_cli"
    kitty_method = "normal",
    integrations = {
      css = {
        enabled = true,
      },
      html = {
        enabled = true,
        only_render_image_at_cursor = true,
        filetypes = { "html", "xhtml", "htm" },
      },
      markdown = {
        enabled = true,
        clear_in_insert_mode = false,
        download_remote_images = true,
        only_render_image_at_cursor = false,
        filetypes = { "markdown", "vimwiki", "html" },
        resolve_image_path = function(document_path, image_path, fallback)
          return fallback(document_path, image_path)
        end,
      },
      neorg = {
        enabled = true,
        clear_in_insert_mode = false,
        download_remote_images = true,
        only_render_image_at_cursor = false,
        filetypes = { "norg" },
      },
    },
    max_width = nil,
    max_height = nil,
    max_width_window_percentage = nil,
    max_height_window_percentage = 30,
    window_overlap_clear_enabled = false,
    window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
    editor_only_render_when_focused = true,
    tmux_show_only_in_active_window = true,
    hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.avif" },
  })
end

M.enabled = false

M.event = "LazyFile"

M.keys = {
  {
    "<leader>uv",
    function()
      require("image").clear()
    end,
    desc = "Disable Render Images",
  },
  { "<leader>uV", "<cmd>Lazy reload image.nvim<cr>", desc = "Enable Render Images" },
}

return M
