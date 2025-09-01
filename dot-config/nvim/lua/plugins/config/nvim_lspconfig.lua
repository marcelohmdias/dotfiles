local merge = require("config.utils").merge

local M = { "neovim/nvim-lspconfig" }

M.keys = {
  { "K", false },
}

M.event = "LazyFile"

---@module "lspconfig"
---@param opts lspconfig.Config
function M.opts(_, opts)
  require("lspconfig.ui.windows").default_options.border = vim.g.modal_border

  ---@class lspconfig.Config
  local config = {
    servers = {
      biome = {
        settings = {
          biome = {
            cmd = { "biome", "lsp-proxy" },
            filetypes = {
              "astro",
              "css",
              "graphql",
              "javascript",
              "javascriptreact",
              "json",
              "jsonc",
              "typescript",
              "typescript.tsx",
              "typescriptreact",
              "vue",
            },
          },
        },
      },
      emmet_language_server = {
        settings = {
          ["emmet-language-server"] = {
            filetypes = {
              "astro",
              "css",
              "html",
              "javascript",
              "javascriptreact",
              "typescriptreact",
              "vue",
            },
          },
        },
      },
      graphql = {
        settings = {
          ["graphql-language-service-cli"] = {
            filetypes = {
              "graphql",
              "javascript",
              "javascriptreact",
              "typescript",
              "typescriptreact",
              "vue",
            },
          },
        },
      },
      harper_ls = {
        settings = {
          ["harper-ls"] = {
            codeActions = { forceStable = true },
            diagnosticSeverity = "hint",
            filetypes = {
              "astro",
              "css",
              "gitcommit",
              "go",
              "html",
              "java",
              "javascript",
              "json",
              "lua",
              "markdown",
              "python",
              "rust",
              "toml",
              "typescript",
              "typescriptreact",
              "vue",
              "yaml",
            },
            linters = {
              spell_check = true,
              spelled_numbers = false,
              an_a = true,
              sentence_capitalization = true,
              unclosed_quotes = true,
              wrong_quotes = false,
              long_sentences = true,
              repeated_words = true,
              spaces = true,
              matcher = true,
              correct_number_suffix = true,
              number_suffix_capitalization = true,
              multiple_sequential_pronouns = true,
              linking_verbs = false,
              avoid_curses = true,
              terminating_conjunctions = true,
            },
            userDictPath = "~/.config/harper-ls/dictionary.txt",
          },
        },
      },
      unocss = {
        settings = {
          ["unocss-language-server"] = {
            filetypes = {
              "astro",
              "css",
              "html",
              "javascript",
              "javascriptreact",
              "markdown",
              "postcss",
              "rescript",
              "rust",
              "typescript",
              "typescriptreact",
              "vue",
              "vue-html",
            },
          },
        },
      },
    },
  }

  return merge(opts, config)
end

return M
