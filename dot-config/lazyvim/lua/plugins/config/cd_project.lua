local M = { "LintaoAmons/cd-project.nvim" }

M.cmd = {
  "CdProject",
  "CdProjectAdd",
  "CdProjectDelete",
}

function M.keys()
  require("which-key").add({
    { "<leader>P", group = "Projects" },
    {
      mode = { "n" },
      { "<leader>Pa", "<Cmd>CdProjectAdd<CR>", desc = "Add new project path" },
      { "<leader>Pd", "<Cmd>CdProjectDelete<CR>", desc = "Delete project path" },
      { "<leader>Pp", "<Cmd>CdProject<CR>", desc = "Find projects" },
    },
  })
end

M.event = "VeryLazy"

M.opts = {
  project_dir_pattern = {
    ".editorconfig",
    ".git",
    ".gitignore",
    "Cargo.toml",
    "package.json",
    "go.mod",
    "stylua.toml",
  },
}

return M
