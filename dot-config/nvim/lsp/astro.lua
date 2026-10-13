local core = require('core.lsp')

local function get_tsdk(root_dir)
  local project_ts = root_dir .. '/node_modules/typescript/lib'
  if vim.uv.fs_stat(project_ts) then
    return project_ts
  end

  local global_bin = vim.fn.exepath('tsc')
  if global_bin == '' then
    global_bin = vim.fn.exepath('tsgo')
  end
  if global_bin ~= '' then
    local resolved = vim.fn.resolve(global_bin)
    local ts_lib = vim.fn.fnamemodify(resolved, ':h:h') .. '/lib'
    if vim.uv.fs_stat(ts_lib) then
      return ts_lib
    end
  end

  return ''
end

---@type vim.lsp.Config
return {
  cmd = { 'astro-ls', '--stdio' },
  filetypes = { 'astro' },
  init_options = {
    typescript = {},
  },
  before_init = function(params, config)
    local root = params.rootPath or vim.uv.cwd()
    config.init_options.typescript.tsdk = get_tsdk(root)
  end,
  root_markers = {
    'astro.config.js',
    'astro.config.mjs',
    'astro.config.cjs',
    'astro.config.ts',
    'package.json',
    'tsconfig.json',
    '.git',
  },
  workspace_required = true,
}
