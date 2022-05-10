--- defines how language servers are installed and setup
-- @module lsp

local M = {}

-- TODO: break into actions and features
M.shared_server_config = U.LspServerConfig():new("SHARED", {

  on_attach = function (client, bufnr)
    -- set gq command to use the lsp formatter for this buffer
    vim.api.nvim_buf_set_option(0, 'formatexpr', 'v:lua.vim.lsp.formatexpr()')

    -- document highlight on cursor hold if available
    if client.resolved_capabilities.document_highlight then
      -- U.create_augroup([[
      --     au CursorHold <buffer> lua vim.lsp.buf.document_highlight()
      --     au CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      --   ]], 'hover_highlight')

      vim.cmd [[
          augroup hover_highlight
          autocmd!

          au CursorHold <buffer> lua vim.lsp.buf.document_highlight()
          au CursorMoved <buffer> lua vim.lsp.buf.clear_references()

          augroup hover_highlight
          ]]
    end

    -- aerial
    -- require 'aerial'.on_attach(client, bufnr)
  end,

  -- cmp autocompletion
  capabilities = require 'cmp_nvim_lsp'.update_capabilities(vim.lsp.protocol.make_client_capabilities()),

  -- method handlers settings
  handlers = {
    ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'single' }),
    ["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'single' }),
  }
})

M.setup_servers = U.Service():require(FT.LSP, 'setup'):new(function(lsp_servers_configs)
  local lspconf = require 'lspconfig'

  -- seting up all servers in servers_configs
  for _, server_config in pairs(lsp_servers_configs) do
    -- applying shared configs opts
    if not U.has_value(server_config.tags, LST.NO_SHARED_CONFIG_SETUP) then
      server_config.opts = vim.tbl_deep_extend('force', server_config.opts, M.shared_server_config.opts)
    end

    -- setting up server
    if not U.has_value(server_config.tags, LST.NO_AUTO_SETUP) then
      lspconf[server_config.name].setup(server_config.opts)
    end
  end
end)

M.setup = U.Service():provide(FT.LSP, 'setup'):require(FT.PLUGIN, 'nvim-lsp-installer'):require(FT.PLUGIN, 'nvim-lspconfig'):new(function()
  -- per line nvim diagnostics
  for type, icon in pairs(venom.icons.diagnostic_states.cozette) do
    local hl = "DiagnosticSign" .. type
    -- if (LSP_DIAG_ICONS == lsp_diag_icons.none) then icon = nil end
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
  end
end)

return M
