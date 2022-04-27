--- defines how language servers are installed and setup
-- @module lsp

-- a langaue servers must be setup in order to be used, there are two types of language servers:
-- available servers      these are installed and setup through nvim-lsp-installer (which uses lspconfig internally)
-- WIP: third party servers    these are installed by 3rd party means and setup through lspconfig

local M = {}

M.servers_configs = {}
M.shared_server_config = {}

M.add_server_config = U.Service():require(FT.LSP, 'setup'):new(function(server_config)
  M.servers_configs[server_config.name] = server_config
end)

M.install_auto_installable_servers = U.Service():require(FT.LSP, 'setup'):new(function()
  for _, server_config in pairs(M.servers_configs) do
    if (server_config.is_auto_installed) then

      -- TODO: abstract into a M.get_server service and handle ok value with catch
      local ok, ls = require 'nvim-lsp-installer.servers'.get_server(server_config.name)
      if ok then
        if not ls:is_installed() then
          log("["..server_config.name.."] auto installing")
          -- TODO: attach the logging to a post complete hook
          ls:install()
          -- log("["..server_config.name.."] installed")
        end
      else
        log("["..server_config.name.."] no server available with such name", LL.ERROR)
      end

    end
  end
end)

M.setup_servers = U.Service():require(FT.LSP, 'setup'):new(function()
  require 'nvim-lsp-installer'.on_server_ready(function(server)
    log("["..server.name.."] setting up lsp server.", LL.DEBUG)

    local opts = {}

    local server_config =  M.servers_configs[server.name]
    if (server_config ~= nil) then
      opts = server_config.opts
    end

    -- TODO: use vim.tbl_extend and vim.tbl_deep_extend
    opts.on_attach = M.shared_server_config.opts.on_attach
    opts.capabilities = M.shared_server_config.opts.capabilities
    opts.handlers = M.shared_server_config.opts.handlers

    server:setup(opts)
    vim.cmd [[do User LspAttachBuffers]]
  end)
end)

M.setup = U.Service():provide(FT.LSP, 'setup'):require(FT.PLUGIN, 'nvim-lsp-installer'):require(FT.PLUGIN, 'nvim-lspconfig'):new(function()
    local lspconfig = require 'lspconfig'
    local lspinstaller = require 'nvim-lsp-installer'

    lspinstaller.settings({
      ui = {
        icons = {
          server_installed = " ",
          server_pending = " ",
          server_uninstalled = "  ",
        },
        keymaps = {
          toggle_server_expand = "<Space>",
          install_server = "<CR>",
          update_server = "<CR>",
          uninstall_server = "<BS>",
        },
      },
      max_concurrent_installers = 3,
    })


    -- TODO: break into actions and features
    M.shared_server_config = U.LspServerConfig():new("SHARED", {
      -- document highlight on cursor hold if available
      on_attach = function (client, bufnr)
        if client.resolved_capabilities.document_highlight then
          U.create_augroup([[
            au CursorHold <buffer> lua vim.lsp.buf.document_highlight()
            au CursorMoved <buffer> lua vim.lsp.buf.clear_references()
          ]], 'hover_highlight')
        end
      end,

      -- cmp autocompletion
      capabilities = require 'cmp_nvim_lsp'.update_capabilities(vim.lsp.protocol.make_client_capabilities()),

      -- method handlers settings
      handlers = {
        ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'single' }),
        ["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'single' })
      }
    })


    for type, icon in pairs(venom.icons.diagnostic_states.cozette) do
      local hl = "DiagnosticSign" .. type
      -- if (LSP_DIAG_ICONS == lsp_diag_icons.none) then icon = nil end
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
    end

end)

return M

-- get_available_servers()
-- get_installed_servers()
-- get_uninstalled_servers()
-- register({server})
-- get_server({server_name})
