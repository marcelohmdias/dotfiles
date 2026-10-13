---@diagnostic disable: undefined-global
-- Shared test helpers for mini.test suites
local H = {}

--- Create a child Neovim process with minimal_init loaded.
---@return table child MiniTest child neovim instance
function H.new_child()
  local child = MiniTest.new_child_neovim()
  child.start({ '-u', 'tests/minimal_init.lua' })
  return child
end

--- Project root (nvim config dir).
H.project_root = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':h:h')

--- Create a fake LSP client for unit tests.
---@param supports table<string, boolean>|fun(method: string, bufnr: number): boolean
---@param opts? { name?: string }
---@return table
function H.fake_client(supports, opts)
  opts = opts or {}
  local client = { name = opts.name or 'fake-client' }
  if type(supports) == 'function' then
    client.supports_method = function(self, method, bufnr)
      return supports(method, bufnr)
    end
  else
    client.supports_method = function(_, method, _)
      return supports[method] == true
    end
  end
  return client
end

--- Stub Snacks.util.lsp.on so handlers can be observed in tests.
-- Installs a fresh stub into _G.Snacks and returns the registry table.
---@return { registry: table[], installed: boolean }
function H.snacks_stub()
  local registry = {}
  local already = _G.Snacks ~= nil
  _G.Snacks = {
    util = {
      lsp = {
        on = function(filter, handler, _)
          table.insert(registry, { filter = filter, handler = handler })
        end,
      },
    },
  }
  return { registry = registry, installed = not already }
end

--- Create an injectable executable predicate.
-- `executables` is a set of names that return true.
---@param executables table<string, boolean>
---@return fun(cmd: string): boolean
function H.is_executable(executables)
  return function(cmd)
    return executables[cmd] == true
  end
end

return H
