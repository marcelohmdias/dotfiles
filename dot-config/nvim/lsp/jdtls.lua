---@type vim.lsp.Config
return {
  cmd = { 'jdtls' },
  filetypes = { 'java' },
  root_markers = {
    'build.gradle',
    'build.gradle.kts',
    'gradlew',
    'mvnw',
    'pom.xml',
    'settings.gradle',
    'settings.gradle.kts',
    '.git',
  },
  workspace_required = true,
  before_init = function(_, config)
    local root = config.root_dir or vim.uv.cwd() or 'unknown'
    local hash = vim.fn.sha256(root):sub(1, 16)
    local data_dir = vim.fn.stdpath('cache') .. '/jdtls/' .. hash

    local lombok_dir = vim.fn.stdpath('data') .. '/mason/packages/lombok'
    local lombok_jar = lombok_dir .. '/lombok.jar'

    -- Ensure Lombok agent is available; download once if missing.
    -- Mason does not provide a lombok package, so we fetch it directly.
    if vim.uv.fs_stat(lombok_jar) == nil then
      vim.fn.mkdir(lombok_dir, 'p')
      local url = 'https://projectlombok.org/downloads/lombok.jar'
      local ok, out = pcall(vim.fn.system, { 'curl', '-fsSL', '-o', lombok_jar, url })
      if not ok or vim.v.shell_error ~= 0 or vim.uv.fs_stat(lombok_jar) == nil then
        vim.notify('[jdtls] failed to download lombok.jar: ' .. tostring(out), vim.log.levels.WARN)
      end
    end

    local cmd = { 'jdtls' }
    if vim.uv.fs_stat(lombok_jar) ~= nil then
      table.insert(cmd, '--javaagent:' .. lombok_jar)
    end
    table.insert(cmd, '-data')
    table.insert(cmd, data_dir)
    config.cmd = cmd
  end,
  settings = {
    java = {
      inlayHints = {
        parameterNames = { enabled = 'all' },
      },
    },
  },
}
