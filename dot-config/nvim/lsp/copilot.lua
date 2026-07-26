--- Copilot native LSP (copilot-language-server)
--- Uses Neovim 0.12 inline completion API, no plugin dependency.
--- Reference: LazyVim extras.ai.copilot-native

-- Track copilot status for lualine integration: 'ok' | 'error' | 'pending' | nil
vim.g.copilot_status = nil

--- Get the first active copilot client.
---@return vim.lsp.Client|nil
local function get_client()
  local clients = vim.lsp.get_clients({ name = 'copilot' })
  return clients[1]
end

-- :LspCopilotSignIn — GitHub device flow authentication
vim.api.nvim_create_user_command('LspCopilotSignIn', function()
  local client = get_client()
  if not client then
    vim.notify('[MiniPack] Copilot LSP not running', vim.log.levels.WARN)
    return
  end
  client:request('signInInitiate', vim.empty_dict(), function(err, result)
    if err then
      vim.notify('[MiniPack] Sign-in failed: ' .. tostring(err), vim.log.levels.ERROR)
      return
    end
    if result.status == 'AlreadySignedIn' then
      vim.notify('[MiniPack] Already signed in to Copilot as ' .. (result.user or ''), vim.log.levels.INFO)
      return
    end
    -- Device flow: show code + URL
    local msg = string.format(
      '[MiniPack] Go to %s and enter code: %s',
      result.verificationUri,
      result.userCode
    )
    vim.notify(msg, vim.log.levels.INFO)
    -- Copy code to clipboard
    vim.fn.setreg('+', result.userCode)
    vim.notify('[MiniPack] Code copied to clipboard', vim.log.levels.INFO)
    -- Open browser
    if vim.ui.open then
      vim.ui.open(result.verificationUri)
    end
    -- Poll for confirmation
    client:request('signInConfirm', { userCode = result.userCode }, function(confirm_err, confirm_result)
      if confirm_err then
        vim.notify('[MiniPack] Sign-in confirmation failed', vim.log.levels.ERROR)
        return
      end
      vim.notify('[MiniPack] Signed in to Copilot as ' .. (confirm_result.user or ''), vim.log.levels.INFO)
    end)
  end)
end, { desc = 'Sign in to GitHub Copilot' })

-- :LspCopilotSignOut
vim.api.nvim_create_user_command('LspCopilotSignOut', function()
  local client = get_client()
  if not client then
    vim.notify('[MiniPack] Copilot LSP not running', vim.log.levels.WARN)
    return
  end
  client:request('signOut', vim.empty_dict(), function(err)
    if err then
      vim.notify('[MiniPack] Sign-out failed: ' .. tostring(err), vim.log.levels.ERROR)
      return
    end
    vim.notify('[MiniPack] Signed out of Copilot', vim.log.levels.INFO)
  end)
end, { desc = 'Sign out of GitHub Copilot' })

-- :LspCopilotStatus
vim.api.nvim_create_user_command('LspCopilotStatus', function()
  local client = get_client()
  if not client then
    vim.notify('[MiniPack] Copilot LSP not running', vim.log.levels.WARN)
    return
  end
  client:request('checkStatus', vim.empty_dict(), function(err, result)
    if err then
      vim.notify('[MiniPack] Status check failed: ' .. tostring(err), vim.log.levels.ERROR)
      return
    end
    local user = result.user or 'unknown'
    local msg = string.format('[MiniPack] Copilot status: %s (user: %s)', result.status or 'unknown', user)
    vim.notify(msg, vim.log.levels.INFO)
  end)
end, { desc = 'Check Copilot status' })

---@type vim.lsp.Config
return {
  cmd = { 'copilot-language-server', '--stdio' },
  root_markers = { '.git' },
  on_attach = function(_, bufnr)
    vim.lsp.inline_completion.enable(true, { bufnr = bufnr })
  end,
  handlers = {
    didChangeStatus = function(err, res)
      if err then
        return
      end
      vim.g.copilot_status = res.kind ~= 'Normal' and 'error' or res.busy and 'pending' or 'ok'
      if res.status == 'Error' then
        vim.notify('[MiniPack] Use `:LspCopilotSignIn` to sign in to Copilot', vim.log.levels.ERROR)
      end
    end,
  },
  init_options = {
    copilotIntegrationId = 'neovim',
    editorInfo = {
      name = 'Neovim',
      version = tostring(vim.version()),
    },
    editorPluginInfo = {
      name = 'MiniPack',
      version = '1.0.0',
    },
  },
}
