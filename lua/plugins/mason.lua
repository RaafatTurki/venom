local U = require "helpers.utils"
local plugins_info = require "helpers.plugins_info"
local keys = require "helpers.keys"
local icons = require "helpers.icons".icons

local M = { plugins_info.mason.url }

M.dependencies = {
  plugins_info.lspconfig.url,
  plugins_info.mason_lspconfig.url,
  -- plugins_info.neodev.url,
  plugins_info.omnisharp_ext.url,
  { plugins_info.typescript_tools.url, dependencies = plugins_info.plenary.url },
  plugins_info.ts_error_translator.url,
  -- plugins_info.lsp_overloads.url,
}

M.config = function()
  require "mason".setup {
    ui = {
      width = 0.8,
      height = 0.8,
      border = 'single',
      icons = {
        package_installed = icons.misc.package,
        package_pending = icons.misc.clock,
        package_uninstalled = icons.misc.package,
      },
      keymaps = {
        toggle_package_expand = "<Space>",
        install_package = "<CR>",
        update_package = "<CR>",
        uninstall_package = "<BS>",
        cancel_installation = "<C-c>",
        check_package_version = "v",
        update_all_packages = "u",
        check_outdated_packages = "o",
        apply_language_filter = "f",
      },
    }
  }

  keys.map("n", "<leader>l", "<CMD>Mason<CR>", "Open mason")

  -- adds border to :LspInfo window
  require('lspconfig.ui.windows').default_options.border = 'single'

  -- setting up mason servers
  local lspconfig_util = require 'lspconfig.util'
  require "mason-lspconfig".setup()
  require "mason-lspconfig".setup_handlers {
    function(server_name)
      M.setup_server_lspconfig(server_name, {})
    end,
    tsserver = function()
      local opts = M.extend_server_opts_w_shared_opts {
        settings = {
          expose_as_code_action = "all",
        },
        handlers = {
          ["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
            require("ts-error-translator").translate_diagnostics(err, result, ctx, config)
            vim.lsp.diagnostic.on_publish_diagnostics(err, result, ctx, config)
          end
        }
      }

      require "typescript-tools".setup(opts)
    end,
    clangd = function()
      M.setup_server_lspconfig('clangd', {
        cmd = {
          "clangd",
          "--offset-encoding=utf-16",
        },
      })
    end,
    lua_ls = function()
      local neodev = prequire "neodev"
      if neodev then
        neodev.setup { library = { plugins = false } }
      end

      M.setup_server_lspconfig('lua_ls', {
        settings = {
          Lua = {
            diagnostics = { disable = { 'lowercase-global', 'trailing-space', 'unused-local' } },
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
          }
        },
      })
    end,
    omnisharp = function()
      local opt = {}

      local omnisharp_ext = prequire "omnisharp_extended"
      if omnisharp_ext then
        opt.handlers = {
          ["textDocument/definition"] = require('omnisharp_extended').handler,
        }
      end

      M.setup_server_lspconfig('omnisharp', opt)
    end,
    markdown_oxide = function()
      M.setup_server_lspconfig('markdown_oxide', {
        capabilities = {
          workspace = {
            didChangeWatchedFiles = {
              dynamicRegistration = true,
            }
          }
        }
      })
    end,
    texlab = function()
      M.setup_server_lspconfig('texlab', {
        settings = {
          texlab = {
            build = {
              onSave = true,
              executable = 'tectonic',
              args = { '%f', '--synctex', '-k' },
            },
          }
        }
      })
    end,
  }

  -- setting up non-mason servers
  if vim.fn.executable('godot') == 1 then
    M.setup_server_lspconfig('gdscript', {
      cmd = vim.lsp.rpc.connect('127.0.0.1', 6005),
      flags = {
        debounce_text_changes = 150,
      },
    })
  end

  if vim.fn.executable('dart') == 1 then
    M.setup_server_lspconfig('dartls', {
      -- cmd = vim.lsp.rpc.connect('127.0.0.1', 6005),
      -- flags = {
      --   debounce_text_changes = 150,
      -- },
    })
  end
end

-- server setup opts extender wrapper
M.extend_server_opts_w_shared_opts = function(opts)
  -- setup shared capabilities
  local shared_capabilities = vim.lsp.protocol.make_client_capabilities()
  if prequire "nvim-cmp" then
    shared_capabilities = require 'cmp_nvim_lsp'.default_capabilities()
  elseif prequire "autocomplete.capabilities" then
    shared_capabilities = vim.tbl_deep_extend('force', shared_capabilities, require 'autocomplete.capabilities')
  elseif prequire "epo" then
    shared_capabilities = vim.tbl_deep_extend('force', shared_capabilities, require 'epo'.register_cap())
  end

  local shared_opts = {
    capabilities = shared_capabilities,
    handlers = {
      ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'single' }),
      ["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'single' }),
    },
    on_attach = function(client, bufnr)
      -- set gq command to use the lsp formatter for this buffer
      vim.api.nvim_buf_set_option(0, 'formatexpr', 'v:lua.vim.lsp.formatexpr()')

      -- format on save
      -- if client.supports_method("textDocument/formatting") then
      --   vim.api.nvim_create_autocmd("BufWritePre", {
      --     buffer = bufnr,
      --     callback = function(ev) vim.lsp.buf.format() end,
      --   })
      -- end

      -- calling the server specific on attach
      if opts.on_attach then
        opts.on_attach(client, bufnr)
      end
    end
  }

  return vim.tbl_deep_extend('force', opts, shared_opts)
end

-- lspconfig server setup wrapper
M.setup_server_lspconfig = function(server_name, opts)
  local lspconf = require 'lspconfig'
  lspconf[server_name].setup(M.extend_server_opts_w_shared_opts(opts))
end

return M
