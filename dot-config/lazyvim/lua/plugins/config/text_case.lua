local M = { "johmsalas/text-case.nvim" }

M.cmd = {
  -- NOTE: The Subs command name can be customized via the option "substitude_command_name"
  "Subs",
  "TextCaseOpenTelescope",
  "TextCaseOpenTelescopeLSPChange",
  "TextCaseOpenTelescopeQuickChange",
  "TextCaseStartReplacingCommand",
}

M.event = "LazyFile"

M.opts = {
  default_keymappings_enabled = false,
}

return M
