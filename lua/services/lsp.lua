--- defines how language servers are installed and setup
-- @module lsp

local M = {}

M.setup_lspconfig_server = U.Service():require(FT.PLUGIN, 'nvim-lspconfig'):new(function(server_name, opts)
  local lspconf = require 'lspconfig'

  local shared_capabilities = vim.lsp.protocol.make_client_capabilities()
  if venom.features:has(FT.PLUGIN, 'nvim-cmp') then
    shared_capabilities = require 'cmp_nvim_lsp'.update_capabilities(shared_capabilities)
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

      -- illuminate
      if venom.features:has(FT.PLUGIN, 'vim-illuminate') then
        require 'illuminate'.on_attach(client)
      end

      -- navic
      if venom.features:has(FT.PLUGIN, 'nvim-navic') then
        require 'nvim-navic'.attach(client, bufnr)
      end

      -- lsp-overloads
      if venom.features:has(FT.PLUGIN, 'lsp-overloads.nvim') and client.server_capabilities.signatureHelpProvider then
        require 'lsp-overloads'.setup(client, {
          ui = {
            border = "single"
          },
          keymaps = {
            next_signature = "<S-Down>",
            previous_signature = "<S-Up>",
            next_parameter = "<S-Right>",
            previous_parameter = "<S-Left>",
          },
        })
      end

      -- calling the server specific on attach
      if opts.on_attach then
        opts.on_attach(client, bufnr)
      end
    end
  }

  lspconf[server_name].setup(vim.tbl_deep_extend('force', opts, shared_opts))
end)

-- TODO: require mason-lspconfig.nvim instead once PM registers deps
M.setup_servers = U.Service():require(FT.PLUGIN, 'mason.nvim'):new(function(lsp_servers_configs)
  require 'mason-lspconfig'.setup()
  require 'mason-lspconfig'.setup_handlers {
    function(server_name)
      M.setup_lspconfig_server(server_name, {})
    end,
    sumneko_lua = function()
      M.setup_lspconfig_server('sumneko_lua', {
        settings = {
          Lua = {
            -- runtime = {
            --  version = 'LuaJIT',
            --  path = vim.split(package.path, ';'),
            -- },
            diagnostics = {
              disable = { 'lowercase-global', 'trailing-space', 'unused-local' },
              globals = { 'vim' },
            },
            workspace = {
              library = {
                [vim.fn.expand('$VIMRUNTIME/lua')] = true,
                [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
              },
            },
            completion= {
              keywordSnippet="Replace",
              callSnippet="Replace",
            },
            telemetry = { enable = false },
          }
        },
        -- on_attach = function(client, bufnr)
        --   Lsp.setup_buf_fmt_on_save(client, bufnr)
        -- end
      })
    end,
    texlab = function()
      M.setup_lspconfig_server('texlab', {
        settings = {
          texlab = {
            build = {
              onSave = true,
              executable = 'tectonic',
              args = vim.split('%f --synctex', ' '),
            },
            forwardSearch = {
              executable = "zathura",
              args = {"--synctex-forward", "%l:1:%f", "%p"},
            },
            chktex = {
              onOpenAndSave = true,
              onEdit = true,
            }
          }
        }
      })
    end,
    svelte = function()
      M.setup_lspconfig_server('svelte', {
        settings = {
          svelte = {
            plugin = {
              svelte = {
                format = { enable = false },
                compilerWarnings = {
                  ["css-unused-selector"] = 'ignore',
                  ["a11y-missing-attribute"] = 'ignore',
                  ["a11y-missing-content "] = 'ignore',
                  -- ["unused-export-let"] = 'ignore',
                }
              }
            }
          }
        }
      })
    end,
    rust_analyzer = function()
      M.setup_lspconfig_server('rust_analyzer', {
        settings = {
          ["rust-analyzer"] = {
            diagnostics = {
              -- disabled = true
              disabled = {
                "unresolved-import",
              }
            }
          }
        }
      })
    end,
    emmet_ls = function()
      M.setup_lspconfig_server('emmet_ls', {
        filetypes = { 'html', 'css', 'svelte' },
      })
    end,
    jsonls = function()
      M.setup_lspconfig_server('jsonls', {
        settings = {
          json = {
            schemas = require 'schemastore'.json.schemas(),

            -- visit https://www.schemastore.org/json/ for more schemas
            -- schemas = {
            --   { fileMatch = { 'package.json' }, url = 'https://json.schemastore.org/package.json' },
            --   { fileMatch = { 'tsconfig.json', 'tsconfig.*.json' }, url = 'http://json.schemastore.org/tsconfig' },
            --   { fileMatch = { '.eslintrc.json', '.eslintrc' }, url = 'http://json.schemastore.org/eslintrc' },
            --   { fileMatch = { '.prettierrc', '.prettierrc.json', 'prettier.config.json' }, url = 'http://json.schemastore.org/prettierrc' },
            --   { fileMatch = { 'deno.json' }, url = 'https://raw.githubusercontent.com/denoland/deno/main/cli/schemas/config-file.v1.json' },
            --   { fileMatch = { '.swcrc' }, url = 'https://json.schemastore.org/swcrc.json' },
            -- },
          },
        }
      })
    end,
    pylsp = function()
      M.setup_lspconfig_server('pylsp', {
        settings = {
          configurationSources = { 'flake8' },
          formatCommand = { 'black' },
          pylsp = {
            plugins = {
              pycodestyle = {
                enabled = true,
                ignore=  {'E501', 'E231', 'E305', 'W391', 'W191'},
              },
            }
          }
        }
      })
    end,
    ltex = function()
      M.setup_lspconfig_server('ltex', {
        settings = {
          ltex = {
            completionEnabled = true,
          }
        }
      })
    end,
    gopls = function()
      M.setup_lspconfig_server('gopls', {
        settings = {
          gopls = {
            usePlaceholders = true,
            linksInHover = false,
            analyses = {
              useany = true,
            },
          }
        },
        on_attach = function(client, bufnr)
          Lsp.setup_buf_fmt_on_save(client, bufnr)
        end
      })
    end,
    jdtls = function()
      -- if venom.features:has(FT.PLUGIN, 'nvim-jdtls') then
        function JDTLSSetup()
          local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
          local workspace_dir = os.getenv('XDG_CACHE_HOME') .. '/jdtls/workspaces/' .. project_name
          local jdtls_root_dir = vim.fn.stdpath('data') .. '/mason/packages/jdtls'

          --- quit if file does not exist
          -- if not U.is_file_exists(jdtls_root_dir .. '/plugins/org.eclipse.equinox.launcher_1.6.400.v20210924-0641.jar') then return end

          local jdtls_nvim_configs = {
            cmd = {
              'java',

              '-Declipse.application=org.eclipse.jdt.ls.core.id1',
              '-Dosgi.bundles.defaultStartLevel=4',
              '-Declipse.product=org.eclipse.jdt.ls.core.product',
              '-Dlog.protocol=true',
              '-Dlog.level=ALL',

              -- '-javaagent:/home/potato/.local/share/nvim/lsp_servers/jdtls/lombok.jar',
              '-javaagent:' .. jdtls_root_dir .. '/lombok.jar',

              '-Xms1g',
              '--add-modules=ALL-SYSTEM',
              '--add-opens', 'java.base/java.util=ALL-UNNAMED',
              '--add-opens', 'java.base/java.lang=ALL-UNNAMED',

              -- '-jar', '/home/potato/.local/share/nvim/lsp_servers/jdtls/plugins/org.eclipse.equinox.launcher_1.6.400.v20210924-0641.jar',
              -- '-configuration', '/home/potato/.local/share/nvim/lsp_servers/jdtls/config_linux',
              '-jar', jdtls_root_dir .. '/plugins/org.eclipse.equinox.launcher_1.6.400.v20210924-0641.jar',
              '-configuration', jdtls_root_dir .. '/config_linux',
              '-data', workspace_dir,
            },

            root_dir = require('jdtls.setup').find_root({'.git', 'mvnw', 'gradlew'}),

            -- TODO: extract into a ServerConfig
            settings = {
              java = {}
            },

            init_options = {
              bundles = {}
            },
          }

          require('jdtls').start_or_attach(jdtls_nvim_configs)
        end

        vim.cmd [[
        augroup jdtls_setup
        autocmd!
        autocmd FileType java lua JDTLSSetup()
        augroup jdtls_setup
        ]]
      -- else
      -- end
    end
  }
end)

-- TODO figure out how to setup custom mason packages for the following
-- M.configure_server("gdscript", {}, {
--   cmd = {'godot-ls'},
--   flags = {
--     debounce_text_changes = 150,
--   },
-- })


M.setup = U.Service():provide(FT.LSP, 'setup')
:require(FT.PLUGIN, 'mason.nvim')
:require(FT.PLUGIN, 'nvim-lspconfig')
:require(FT.PLUGIN, 'inc-rename.nvim')
:new(function()
  -- per line nvim diagnostics
  for type, icon in pairs(venom.icons.diagnostic_states.cozette) do
    local hl = "DiagnosticSign" .. type
    -- if (LSP_DIAG_ICONS == lsp_diag_icons.none) then icon = nil end
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
  end

  vim.api.nvim_create_user_command('LspRename', function() M.rename() end, {})
  vim.api.nvim_create_user_command('LspReferences', function() M.references() end, {})
  vim.api.nvim_create_user_command('LspDefinition', function() M.definition() end, {})
  vim.api.nvim_create_user_command('LspCodeAction', function() M.code_action() end, {})
  vim.api.nvim_create_user_command('LspHover', function() M.hover() end, {})
  vim.api.nvim_create_user_command('LspDiagsList', function() M.diags_list() end, {})
  vim.api.nvim_create_user_command('LspDiagsHover', function() M.diags_hover() end, {})
  vim.api.nvim_create_user_command('LspFormat', function() M.format() end, {})
  -- vim.api.nvim_create_user_command('LspDiagsToggle', function() M.diags_toggle() end, {})
  
  require 'inc_rename'.setup()
  
end)

M.rename = U.Service():new(function()
  require 'inc_rename'.rename {
    default = vim.fn.expand("<cword>")
  }
end)

M.references = U.Service():new(function()
  vim.lsp.buf.references()
end)

M.definition = U.Service():new(function()
  vim.lsp.buf.definition()
end)

M.code_action = U.Service():new(function()
  vim.lsp.buf.code_action()
end)

M.hover = U.Service():require(FT.PLUGIN, 'hover.nvim'):new(function()
  -- vim.lsp.buf.hover()
  require 'hover'.hover()
end)

M.format = U.Service():new(function()
  vim.lsp.buf.format()
end)

M.diags_list = U.Service():new(function()
  vim.diagnostic.setloclist()
  -- vim.diagnostic.setqflist()
end)

M.diags_hover = U.Service():new(function()
  vim.diagnostic.open_float()
end)

-- M.diags_toggle = U.Service():new(function()
--   venom.vals.is_disagnostics_visible = not venom.vals.is_disagnostics_visible
--   if venom.vals.is_disagnostics_visible then vim.diagnostic.show() else vim.diagnostic.hide() end
-- end)

M.setup_buf_fmt_on_save = U.Service():new(function(client, bufnr)
  local augroup_fmt_on_save = vim.api.nvim_create_augroup('format_on_save', {})
	if client.supports_method("textDocument/formatting") then
		vim.api.nvim_clear_autocmds({ group = augroup_fmt_on_save, buffer = bufnr })
		vim.api.nvim_create_autocmd("BufWritePre", {
			group = augroup_fmt_on_save,
			buffer = bufnr,
			callback = function() vim.lsp.buf.format() end,
		})
	end
end)

return M
