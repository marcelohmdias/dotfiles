local utils = require("config.utils")

local M = { "folke/snacks.nvim" }

---@module "snacks"
---@param opts snacks.Config
function M.opts(_, opts)
  ---@class snacks.dashboard.Config
  local dashboard = {
    formats = {
      key = function(item)
        return { { "[", hl = "icon" }, { item.key, hl = "special" }, { "]", hl = "icon" } }
      end,
    },
    preset = {
      header = table.concat(require("config.constants").header, "\n"),
    },
    --- TODO: Move icons to icon file
    sections = {
      { section = "header", padding = 2 },
      {
        icon = " ",
        title = "Keymaps\n",
        section = "keys",
        indent = 3,
        padding = 1,
      },
      {
        icon = " ",
        title = "Recent Files\n",
        section = "recent_files",
        cwd = true,
        indent = 3,
        limit = 5,
        padding = 1,
      },
      function()
        local command = "gh search prs -L=3 --review-requested=@me --state=open"
        local cmd_result = vim.system(utils.split_to_table(command, "%S+"), { text = true }):wait()
        local is_enabled = string.len(cmd_result.stdout) > 0
        local cmd_len = utils.split_to_table(cmd_result.stdout, "([^\n]*)\n?")

        return {
          icon = " ",
          title = "PRs to Review",
          section = "terminal",
          cmd = command,
          enabled = is_enabled,
          height = #cmd_len + 3,
          indent = 3,
          padding = 1,
          ttl = 5 * 60,
        }
      end,
      function()
        local in_git = Snacks.git.get_root() ~= nil
        local command = "git --no-pager diff --stat-width=98 --stat-count=5 -B -M -C"
        local cmd_result = vim.system(utils.split_to_table(command, "%S+"), { text = true }):wait()
        local has_result = string.len(cmd_result.stdout) > 0
        local is_enabled = in_git and has_result
        local cmd_len = utils.split_to_table(cmd_result.stdout, "([^\n]*)\n?")

        return {
          icon = " ",
          title = "Git Status",
          section = "terminal",
          cmd = "echo ''; " .. command,
          height = #cmd_len + 1,
          indent = 2,
          enabled = is_enabled,
          ttl = 5 * 60,
        }
      end,
      { section = "startup" },
    },
    width = 100,
  }

  table.insert(opts.dashboard.preset.keys, 7, {
    icon = "󰕮 ",
    key = "z",
    desc = "Zoxide",
    action = function()
      Snacks.picker.zoxide({
        layout = { preset = "vscode" },
      })
    end,
  })

  opts.dashboard = utils.merge(opts.dashboard, dashboard)

  return opts
end

return M
