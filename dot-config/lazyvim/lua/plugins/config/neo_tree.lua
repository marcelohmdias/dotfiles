local E = require("neo-tree.events")
local icons = require("config.icons")
local git_available = vim.fn.executable("git") == 1

local M = { "nvim-neo-tree/neo-tree.nvim" }

M.events = "VeryLazy"

M.opts = {
  default_component_configs = {
    indent = {
      with_markers = true,
      with_expanders = true,
    },
    modified = {
      symbol = " ",
      highlight = "NeoTreeModified",
    },
    icon = {
      folder_closed = icons.misc.folder,
      folder_open = icons.misc.folder_open,
      folder_empty = icons.misc.folder,
      folder_empty_open = icons.misc.folder_open,
    },
    git_status = {
      symbols = {
        -- Change type
        added = icons.git.added,
        deleted = icons.git.deleted,
        modified = icons.git.modified,
        renamed = icons.git.renamed,
        -- Status type
        conflict = icons.git.conflict,
        ignored = icons.git.ignored,
        staged = icons.git.staged,
        unstaged = icons.git.unstaged,
        untracked = icons.git.untracked,
      },
    },
  },
  enable_diagnostics = true,
  enable_git_status = git_available,
  enable_modified_markers = true,
  event_handlers = {
    {
      event = E.FILE_OPENED,
      handler = function()
        require("neo-tree.command").execute({ action = "close" })
      end,
    },
  },
  filesystem = {
    filtered_items = {
      hide_dotfiles = false,
      hide_gitignored = true,
      hide_by_name = {
        "node_modules",
      },
      never_show = {
        ".DS_Store",
        "thumbs.db",
      },
    },
    use_libuv_file_watcher = true,
  },
  sources = { "filesystem", "buffers", git_available and "git_status" or nil },
  source_selector = {
    statusline = false,
    close_if_last_window = true,
  },
  window = {
    mappings = {
      ["e"] = {
        function()
          vim.api.nvim_exec2("Neotree focus filesystem left", {})
        end,
        desc = "Open files",
      },
      ["b"] = {
        function()
          vim.api.nvim_exec2("Neotree focus buffers left", {})
        end,
        desc = "Open buffers",
      },
      ["g"] = {
        function()
          vim.api.nvim_exec2("Neotree focus git_status left", {})
        end,
        desc = "Open git files",
      },
      ["<tab>"] = {
        function(state)
          local node = state.tree:get_node()
          if require("neo-tree.utils").is_expandable(node) then
            state.commands["toggle_node"](state)
          else
            state.commands["open"](state)
            vim.cmd("Neotree reveal")
          end
        end,
        desc = "Open file without close filesystem menu",
      },
    },
  },
}

return M
