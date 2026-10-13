-- LSP layer: pure LSP handlers registered via Snacks.util.lsp.on.
-- This module must be require-safe (no side-effects); call setup() to activate.

local M = {}

--- Auto-enable inlay hints for the buffer, excluding vue.
-- Registered on `textDocument/inlayHint` via Snacks.util.lsp.on.
---@param buf number
function M._on_inlay_hint(buf)
  if vim.bo[buf].filetype == 'vue' then
    return
  end
  vim.lsp.inlay_hint.enable(true, { bufnr = buf })
end

--- Build the workspace/executeCommand request to apply the move.
---@param command table original LSP command
---@param uri string
---@param range lsp.Range
---@param newf string destination file
---@return table
local function build_move_request(command, uri, range, newf)
  return {
    command = command.command,
    arguments = { command.arguments[1], uri, range, newf },
  }
end

--- Request the move operation on the client.
---@param client vim.lsp.Client
---@param command table
---@param uri string
---@param range lsp.Range
---@return fun(newf: string)
local function move_to_file(client, command, uri, range)
  return function(newf)
    client:request('workspace/executeCommand', build_move_request(command, uri, range, newf))
  end
end

--- Build the tsserver request payload for move-to-file suggestions.
---@param fname string
---@param range lsp.Range
---@return table
local function build_suggestions_request(fname, range)
  return {
    command = 'typescript.tsserverRequest',
    arguments = {
      'getMoveToRefactoringFileSuggestions',
      {
        file = fname,
        startLine = range.start.line + 1,
        startOffset = range.start.character + 1,
        endLine = range['end'].line + 1,
        endOffset = range['end'].character + 1,
      },
    },
  }
end

--- Show the destination picker and invoke the move callback.
---@param fname string
---@param files string[]
---@param move fun(newf: string)
local function show_destination_picker(fname, files, move)
  table.insert(files, 1, 'Enter new path...')
  vim.ui.select(files, {
    prompt = 'Select move destination:',
    format_item = function(f)
      return vim.fn.fnamemodify(f, ':~:.')
    end,
  }, function(f)
    if not f then
      return
    end
    if f:find('^Enter new path') then
      vim.ui.input({
        prompt = 'Enter move destination:',
        default = vim.fn.fnamemodify(fname, ':h') .. '/',
        completion = 'file',
      }, function(newf)
        return newf and move(newf)
      end)
    else
      move(f)
    end
  end)
end

--- Handle the response from tsserver move-to-file suggestions.
---@param fname string
---@param move fun(newf: string)
---@return fun(_: any, result: table|nil)
local function on_suggestions_response(fname, move)
  return function(_, result)
    if not result or not result.body then
      return
    end
    show_destination_picker(fname, result.body.files or {}, move)
  end
end

--- Handler for the vtsls "Move to file" refactoring command.
-- Registered on vtsls attach via Snacks.util.lsp.on.
---@param _buf number
---@param client vim.lsp.Client
function M._on_vtsls_move_to_file(_buf, client)
  client.commands['_typescript.moveToFileRefactoring'] = function(command, _ctx)
    ---@type string, string, lsp.Range
    local _action, uri, range = unpack(command.arguments)
    local fname = vim.uri_to_fname(uri)
    local move = move_to_file(client, command, uri, range)
    client:request(
      'workspace/executeCommand',
      build_suggestions_request(fname, range),
      on_suggestions_response(fname, move)
    )
  end
end

--- Workaround for gopls not announcing semanticTokensProvider.
-- Registered on gopls attach via Snacks.util.lsp.on.
-- Ref: https://github.com/golang/go/issues/54531#issuecomment-1464982242
---@param _buf number
---@param client vim.lsp.Client
function M._on_gopls_attach(_buf, client)
  if
    client.config
    and client.config.init_options
    and client.config.init_options.semanticTokens
    and not client.server_capabilities.semanticTokensProvider
  then
    local semantic = client.config.capabilities.textDocument.semanticTokens
    client.server_capabilities.semanticTokensProvider = {
      full = true,
      legend = {
        tokenTypes = semantic.tokenTypes,
        tokenModifiers = semantic.tokenModifiers,
      },
      range = true,
    }
  end
end

--- Activate LSP handlers.
function M.setup()
  Snacks.util.lsp.on({ method = 'textDocument/inlayHint' }, M._on_inlay_hint)
  Snacks.util.lsp.on({ name = 'vtsls' }, M._on_vtsls_move_to_file)
  Snacks.util.lsp.on({ name = 'gopls' }, M._on_gopls_attach)
end

return M
