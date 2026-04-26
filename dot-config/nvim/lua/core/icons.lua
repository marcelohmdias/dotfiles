local M = {}

M.alerts = {
  attention = ' ',
  error = '󰅚 ',
  hint = ' ',
  info = ' ',
  question = ' ',
  warn = ' ',
}

M.dap = {
  breakpoint = ' ',
  debug = ' ',
  logpoint = '.>',
  stopped = ' ',
}

M.ft = {
  octo = ' ',
}

M.git = {
  added = ' ',
  branch = ' ',
  commit = '󰜘 ',
  conflict = ' ',
  deleted = ' ',
  ignored = ' ',
  modified = ' ',
  removed = ' ',
  renamed = ' ',
  staged = ' ',
  unmerged = ' ',
  unstaged = ' ',
  untracked = ' ',
}

M.kinds = {
  Array = ' ',
  Boolean = ' ',
  Class = ' ',
  Codeium = '󰘦 ',
  Color = ' ',
  Control = ' ',
  Collapsed = ' ',
  Constant = ' ',
  Constructor = ' ',
  Copilot = ' ',
  Enum = ' ',
  EnumMember = ' ',
  Event = ' ',
  Field = ' ',
  File = ' ',
  Folder = ' ',
  Function = ' ',
  Interface = ' ',
  Key = ' ',
  Keyword = ' ',
  Method = ' ',
  Module = ' ',
  Namespace = ' ',
  Null = ' ',
  Number = ' ',
  Object = ' ',
  Operator = ' ',
  Package = ' ',
  Property = ' ',
  Reference = ' ',
  Snippet = ' ',
  String = ' ',
  Struct = ' ',
  TabNine = '󰏚 ',
  Text = ' ',
  TypeParameter = ' ',
  Unit = ' ',
  Unknown = ' ',
  Value = ' ',
  Variable = ' ',
}

M.misc = {
  atom = '󰹻 ',
  bullet = '● ',
  bullet_open = '○ ',
  sync = '⟳ ',
  dots = '󰇘',
  duck = '󰇥 ',
  folder = '',
  folder_open = '',
  go_to = '󰑮 ',
  lsp = '󰣖',
  mark = ' ',
  neovim = ' ',
  project = ' ',
  robot = '󱙺 ',
  scissor = ' ',
  search = ' ',
  stack = ' ',
  select = '▶ ',
  check = '󰄬 ',
  cross = '󰅖 ',
  task = ' ',
  telescope = ' ',
}

M.dashboard = {
  config = ' ',
  file = ' ',
  git_diff = ' ',
  keys = ' ',
  minipack = M.misc.stack,
  new_file = ' ',
  pr_review = ' ',
  quit = ' ',
  recent = ' ',
  search = ' ',
  session = ' ',
  zoxide = '󰕮 ',
}

return M
