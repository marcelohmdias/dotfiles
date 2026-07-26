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
  settings = {
    java = {
      inlayHints = {
        parameterNames = { enabled = 'all' },
      },
    },
  },
}
