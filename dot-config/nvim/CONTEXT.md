# Neovim — MiniPack

Configuração Neovim 0.12 do usuário: MiniPack (wrapper sobre `vim.pack`), LSP 100% nativo, snacks.nvim. Roda idêntica em macOS e Fedora.

## Language

**LSP nativo**:
Servers gerenciados apenas com a API nativa do Neovim (`vim.lsp.Config`/`vim.lsp.enable`), sem nvim-lspconfig e sem gerenciadores externos. Invariante do projeto.
_Avoid_: lspconfig, "adotar o setup do LazyVim"

**Paridade por portabilidade**:
A forma de acompanhar o LazyVim: portar valores e padrões dele para dentro do LSP nativo, nunca adotar as dependências que ele usa.
_Avoid_: "instalar o extra", "usar o default deles direto"

**Camada LSP**:
Os módulos de política do LSP em `lua/config/lsp/` (`init`, `keymaps`, `handlers`) — o equivalente local do `plugins/lsp` do LazyVim.
_Avoid_: "o lsp.lua", "setup LSP"

**Server Config**:
Arquivo `lsp/<server>.lua` que retorna a configuração nativa de um servidor.
_Avoid_: "spec de lspconfig"

**Enable List**:
O conjunto de servers ativados, com condicionais por Feature Flag, em `config/lsp/init.lua`.
_Avoid_: "lista de servers hardcodada"

**Feature Flag**:
Um `vim.g.<nome>_enabled` em `config/globals.lua` que liga ou desliga um server/plugin (ex.: `tsc_enabled`, `docker_enabled`, `copilot_enabled`).
_Avoid_: "variável de configuração", "option"

**Resiliência**:
A config funciona igual em qualquer máquina (macOS/Fedora) sem depender de setup local; falhas nunca são silenciosas; mudanças do ecossistema exigem ajustes mínimos e localizados.
_Avoid_: "robustez", "error handling"

**Híbrido TS/Vue**:
Divisão de trabalho deliberada: server TS nativo (`tsc`) para TS/JS puro; vtsls como host de plugins tsserver para os filetypes que dependem de plugins (vue, astro); vue_ls em hybrid mode.
_Avoid_: "takeover", "vtsls para tudo"

**Referência LazyVim**:
A instalação LazyVim mantida em `dot-config/lazyvim/`, fonte oficial de preferências e de paridade.
_Avoid_: "a outra config", "config antiga"
