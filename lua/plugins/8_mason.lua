local U = require "helpers.utils"
local keys = require "helpers.keys"
local icons = require "helpers.icons".icons
local buffers = require "helpers.buffers"


-- LSP
-- plugins_info.omnisharp_ext,
-- plugins_info.sqls,
-- plugins_info.schemastore,
-- { plugins_info.typescript_tools, dependencies = plugins_info.plenary },
-- plugins_info.fmt_ts_errors,

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

shared_opts_extender = function(opts)
  -- setup shared capabilities
  local shared_capabilities = vim.lsp.protocol.make_client_capabilities()

  shared_capabilities.textDocument.completion.completionItem.insertReplaceSupport = true

  local shared_opts = {
    capabilities = shared_capabilities,
    on_attach = function(client, bufnr)
      -- set gq command to use the lsp formatter for this buffer
      vim.api.nvim_set_option_value('formatexpr', 'v:lua.vim.lsp.formatexpr()', { buf = bufnr })

      -- format on save
      -- if client.supports_method("textDocument/formatting") then
      --   vim.api.nvim_create_autocmd("BufWritePre", {
      --     buffer = bufnr,
      --     callback = function(ev) vim.lsp.buf.format() end,
      --   })
      -- end

      -- enable inlay hints
      -- if client.server_capabilities.inlayHintProvider then
      --   -- this might not be needed
      --   vim.g.inlay_hints_visible = true
      --   vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
      -- else
      --   print("no inlay hints available")
      -- end

      -- calling the server specific on attach
      if opts.on_attach then
        opts.on_attach(client, bufnr)
      end
    end
  }

  return vim.tbl_deep_extend('force', opts, shared_opts)
end

setup_server = function(server_name, opts)
  local lspconfig = require 'lspconfig'
  lspconfig[server_name].setup(shared_opts_extender(opts))
end


-- setting up mason servers
local lspconfig_util = require 'lspconfig.util'
require "mason-lspconfig".setup {
  handlers = {
    function(server_name)
      setup_server(server_name, {})
    end,
    -- ts_ls = function()
    --   local opts = {
    --     settings = {
    --       expose_as_code_action = "all",
    --     },
    --   }
    --   -- use typescript-tools if available
    --   local ts_tools = prequire 'typescript-tools'
    --   if ts_tools then
    --     ts_tools.setup(shared_opts_extender(opts))
    --   else
    --     setup_server('ts_ls', opts)
    --   end
    -- end,
    -- clangd = function()
    --   setup_server('clangd', {
    --     cmd = {
    --       "clangd",
    --       "--offset-encoding=utf-16",
    --     },
    --   })
    -- end,
    lua_ls = function()
      setup_server('lua_ls', {
        settings = {
          Lua = {
            telemetry = { enable = false },
            diagnostics = {
              disable = { 'lowercase-global', 'trailing-space', 'unused-local' }
            },
            workspace = {
              checkThirdParty = false,
              -- library = {
              --   vim.env.VIMRUNTIME
              -- }
            },
            codeLens = {
              enable = true,
            },
            completion = {
              callSnippet = "Replace",
            },
            doc = {
              privateName = { "^_" },
            },
            hint = {
              enable = true,
              setType = false,
              paramType = true,
              paramName = "Disable",
              semicolon = "Disable",
              arrayIndex = "Disable",
            },
          }
        },
      })
    end,
    -- jsonls = function()
    --   local opt = {}
    --
    --   local schemastore_ext = require "schemastore"
    --   if schemastore_ext then
    --     opt.settings = {
    --       json = {
    --         validate = { enable = true },
    --         schemas = schemastore_ext.json.schemas(),
    --       },
    --     }
    --   end
    --
    --   setup_server('jsonls', opt)
    -- end,
    -- sqls = function()
    --   local opt = {
    --     settings = {
    --       sqls = {
    --         connections = {
    --           {
    --             driver = 'postgresql',
    --             dataSourceName = 'host=127.0.0.1 port=5432 user=admin password=admin dbname=tam sslmode=disable',
    --           },
    --         },
    --       },
    --     },
    --   }
    --
    --   -- use sqls plugin if available
    --   local sqls_nvim = prequire 'sqls'
    --   if sqls_nvim then
    --     opt.on_attach = function(client, bufnr)
    --       sqls_nvim.on_attach(client, bufnr)
    --     end
    --   end
    --
    --   setup_server('sqls', opt)
    -- end,
    -- omnisharp = function()
    --   local opt = {}
    --
    --   local omnisharp_ext = prequire "omnisharp_extended"
    --   if omnisharp_ext then
    --     opt.handlers = {
    --       ["textDocument/definition"] = require('omnisharp_extended').handler,
    --     }
    --   end
    --
    --   setup_server('omnisharp', opt)
    -- end,
    -- markdown_oxide = function()
    --   setup_server('markdown_oxide', {
    --     capabilities = {
    --       workspace = {
    --         didChangeWatchedFiles = {
    --           dynamicRegistration = true,
    --         }
    --       }
    --     }
    --   })
    -- end,
    -- texlab = function()
    --   setup_server('texlab', {
    --     settings = {
    --       texlab = {
    --         build = {
    --           onSave = true,
    --           executable = 'tectonic',
    --           args = { '%f', '--synctex', '-k' },
    --         },
    --       }
    --     }
    --   })
    -- end,
  }
}


keys.map("n", "<leader>l", "<CMD>Mason<CR>", "Open mason")
