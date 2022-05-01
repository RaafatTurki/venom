--- defines how language servers are installed and setup
-- @module lsp

local M = {}

M.servers_configs = {}
M.shared_server_config = {}

M.add_server_config = U.Service():require(FT.LSP, 'setup'):new(function(server_config)
  M.servers_configs[server_config.name] = server_config
end)

M.setup_servers = U.Service():require(FT.LSP, 'setup'):new(function()
  local lspi = require 'nvim-lsp-installer'
  local lspconf = require 'lspconfig'

  -- looping all installed LSPI servers
  for _, server_obj in pairs(lspi.get_installed_servers()) do
    
    -- adding unconfigured servers into M.servers_configs
    if (not U.has_key(M.servers_configs, server_obj.name)) then
      M.add_server_config:invoke(U.LspServerConfig():tag(LST.LSPI):new(server_obj.name, {}))
    end

    -- setting up servers
    local server_config = M.servers_configs[server_obj.name]

    if U.has_value(server_config.tags, LST.NO_SHARED_CONFIG) then
      lspconf[server_config.name].setup(server_config.opts)
    else
      local opts = vim.tbl_deep_extend('force', server_config.opts, M.shared_server_config.opts)
      lspconf[server_config.name].setup(opts)
    end

  end
end)

M.setup = U.Service():provide(FT.LSP, 'setup'):require(FT.PLUGIN, 'nvim-lsp-installer'):require(FT.PLUGIN, 'nvim-lspconfig'):new(function()
  require 'nvim-lsp-installer'.setup({
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


    on_attach = function(client)
      -- vim.api.nvim_buf_set_keymap(0, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', {noremap = true})
      -- vim.api.nvim_buf_set_keymap(0, 'n', '<c-]>', '<cmd>lua vim.lsp.buf.definition()<CR>', {noremap = true})

      -- Use LSP as the handler for omnifunc.
      --    See `:help omnifunc` and `:help ins-completion` for more information.
      -- vim.api.nvim_buf_set_option(0, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

      -- Use LSP as the handler for formatexpr.
      vim.api.nvim_buf_set_option(0, 'formatexpr', 'v:lua.vim.lsp.formatexpr()')

      -- For plugins with an `on_attach` callback, call them here. For example:
      -- require('completion').on_attach()
    end

    -- An example of configuring for `sumneko_lua`,
    --  a language server for Lua.

    -- set the path to the sumneko installation
    -- local system_name = "Linux" -- (Linux, macOS, or Windows)
    -- local sumneko_root_path = '/path/to/lua-language-server'
    -- local sumneko_binary = sumneko_root_path.."/bin/"..system_name.."/lua-language-server"

    -- require('lspconfig').sumneko_lua.setup({
    --   cmd = {sumneko_binary, "-E", sumneko_root_path .. "/main.lua"};
    --   -- An example of settings for an LSP server.
    --   --    For more options, see nvim-lspconfig
    --   settings = {
    --     Lua = {
    --       runtime = {
    --         -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
    --         version = 'LuaJIT',
    --         -- Setup your lua path
    --         path = vim.split(package.path, ';'),
    --       },
    --       diagnostics = {
    --         -- Get the language server to recognize the `vim` global
    --         globals = {'vim'},
    --       },
    --       workspace = {
    --         -- Make the server aware of Neovim runtime files
    --         library = {
    --           [vim.fn.expand('$VIMRUNTIME/lua')] = true,
    --           [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
    --         },
    --       },
    --     }
    --   },
    --
    --   on_attach = custom_lsp_attach
    -- })










    -- document highlight on cursor hold if available
    -- on_attach = function (client, bufnr)
    --   if client.resolved_capabilities.document_highlight then
    --     U.create_augroup([[
    --         au CursorHold <buffer> lua vim.lsp.buf.document_highlight()
    --         au CursorMoved <buffer> lua vim.lsp.buf.clear_references()
    --       ]], 'hover_highlight')
    --   end
    -- end,

    -- cmp autocompletion
    -- capabilities = require 'cmp_nvim_lsp'.update_capabilities(vim.lsp.protocol.make_client_capabilities()),

    -- method handlers settings
    -- handlers = {
    --   ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'single' }),
    --   ["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'single' })
    -- }
  })

  -- per line nvim diagnostics
  for type, icon in pairs(venom.icons.diagnostic_states.cozette) do
    local hl = "DiagnosticSign" .. type
    -- if (LSP_DIAG_ICONS == lsp_diag_icons.none) then icon = nil end
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
  end
end)

return M
