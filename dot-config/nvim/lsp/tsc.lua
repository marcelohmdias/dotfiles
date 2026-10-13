local core = require('core.lsp')

---@type vim.lsp.Config
return {
  cmd = { 'tsc', '--lsp', '--stdio' },
  filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
  root_dir = function(bufnr, on_dir)
    core.ts_root_by_lockfile(bufnr, function(root)
      local bin = core.find_tsc_bin(root)
      vim.notify('[tsc] using TypeScript binary: ' .. (bin or 'none'), vim.log.levels.INFO)
      if bin then
        on_dir(root)
      else
        vim.notify('[tsc] no TypeScript >= 7 binary found', vim.log.levels.WARN)
      end
    end)
  end,
  before_init = function(_, config)
    local root = config.root_dir
    if not root then
      return
    end
    local bin = core.find_tsc_bin(root)
    if bin then
      config.cmd = { bin, '--lsp', '--stdio' }
    end
  end,
  settings = {
    javascript = {
      inlayHints = {
        enumMemberValues = { enabled = true },
        functionLikeReturnTypes = { enabled = true },
        parameterNames = { enabled = 'literals' },
        parameterTypes = { enabled = true },
        propertyDeclarationTypes = { enabled = true },
        variableTypes = { enabled = false },
      },
      referencesCodeLens = { enabled = true },
      implementationsCodeLens = { enabled = true },
    },
    typescript = {
      inlayHints = {
        enumMemberValues = { enabled = true },
        functionLikeReturnTypes = { enabled = true },
        parameterNames = { enabled = 'literals' },
        parameterTypes = { enabled = true },
        propertyDeclarationTypes = { enabled = true },
        variableTypes = { enabled = false },
      },
      referencesCodeLens = { enabled = true },
      implementationsCodeLens = { enabled = true },
    },
  },
  workspace_required = true,
}
