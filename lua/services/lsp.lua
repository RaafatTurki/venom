--- defines language servers setup and install mechanisms.
-- @module lsp
local M = {}

M.setup_lspconfig_server = U.Service({{FT.CONF, 'nvim-lspconfig'}}, function(server_name, opts)
  local lspconf = require 'lspconfig'

  local shared_capabilities = vim.lsp.protocol.make_client_capabilities()
  if Features:has(FT.CONF, 'nvim-cmp') then
    shared_capabilities = require 'cmp_nvim_lsp'.default_capabilities()
  elseif Features:has(FT.CONF, 'coq_nvim') then
    opts = require 'coq'.lsp_ensure_capabilities(opts)
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

      -- navic
      if Features:has(FT.CONF, 'nvim-navic') then
        require 'nvim-navic'.attach(client, bufnr)
      end

      -- lsp-overloads
      if Features:has(FT.CONF, 'lsp-overloads.nvim') and client.server_capabilities.signatureHelpProvider then
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
M.setup_servers = U.Service({{FT.CONF, 'mason.nvim'}}, function(lsp_servers_configs)
  -- lsp servers
  require 'mason-lspconfig'.setup()
  require 'mason-lspconfig'.setup_handlers {
    function(server_name)
      M.setup_lspconfig_server(server_name, {})
    end,
    sumneko_lua = function()
      if Features:has(FT.CONF, 'neodev.nvim') then
        require("neodev").setup {
          library = {
            plugins = false,
          }
        }
      end
      M.setup_lspconfig_server('sumneko_lua', {
        settings = {
          Lua = {
            diagnostics = {
              disable = { 'lowercase-global', 'trailing-space', 'unused-local' },
            },
            -- workspace = {
            --   checkThirdParty = false,
            -- },
            completion = {
              -- keywordSnippet="Disable",
              -- keywordSnippet="Replace",
              -- callSnippet="Replace",
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
              -- onSave = true,
              executable = 'tectonic',
              args = { '%f', '--synctex', '-k' },
            },
            forwardSearch = {
              executable = 'zathura',
              args = {
                '--synctex-forward',
                '%l:1:%f',

                '--synctex-editor-command',
                [[nvim --server ]] ..
                    vim.v.servername .. [[ --remote-send "<CMD>lua U.request_jump('%{input}', %{line}, 1)<CR>"]],

                '%p',
              },
            },
            -- chktex = {
            --   onOpenAndSave = true,
            --   onEdit = true,
            -- }
          }
        }
      })

      vim.cmd [[
      augroup texlab_build
      autocmd!
      autocmd BufWritePost *.tex lua Lang.builders.texlab(0)
      augroup texlab_build
      ]]
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
            -- TODO: emsure plugin is installed
            schemas = require 'schemastore'.json.schemas(),
            validate = { enable = true },

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
                ignore = { 'E501', 'E231', 'E305', 'W391', 'W191' },
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
      if Features:has(FT.CONF, 'nvim-jdtls') then
        function JDTLSSetup()
          local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
          local workspace_dir = vim.env['XDG_CACHE_HOME'] .. '/jdtls/workspaces/' .. project_name
          local jdtls_root_dir = vim.fn.stdpath('data') .. '/mason/packages/jdtls'

          --- quit if file does not exist
          -- if not U.is_file_exists(jdtls_root_dir .. '/plugins/org.eclipse.equinox.launcher_1.6.400.v20210924-0641.jar') then return end

          -- for more details visit https://github.com/mfussenegger/nvim-jdtls
          local jdtls_nvim_configs = {
            cmd = {
              'java',

              '-Declipse.application=org.eclipse.jdt.ls.core.id1',
              '-Dosgi.bundles.defaultStartLevel=4',
              '-Declipse.product=org.eclipse.jdt.ls.core.product',
              '-Dlog.protocol=true',
              '-Dlog.level=ALL',

              -- TODO: put back once lombok gets added into mason
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

            root_dir = require('jdtls.setup').find_root({ '.git', 'mvnw', 'gradlew' }),

            -- TODO: extract into a ServerConfig
            settings = {
              java = {}
            },

            init_options = {
              bundles = {}
            },
          }

          local jdtls = require('jdtls')
          jdtls.start_or_attach(jdtls_nvim_configs)

          vim.cmd [[
            " let g:jdtls_java_home = expand('$ANDROID_HOME/platforms/android-*/android.jar')
            let g:jdtls_java_home = expand('$ANDROID_HOME/platforms/android-30/android.jar')
            let g:jdtls_java_config_path = ''
          ]]
        end

        vim.cmd [[
        augroup jdtls_setup
        autocmd!
        autocmd FileType java lua JDTLSSetup()
        augroup jdtls_setup
        ]]
      else
        M.setup_lspconfig_server('jdtls', {})
      end
    end,
    omnisharp = function()
      M.setup_lspconfig_server('omnisharp', {
        -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#omnisharp
      })
    end,
    html = function()
      M.setup_lspconfig_server('html', {
        -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#html
        -- filetypes = { 'html', 'svelte' },
      })
    end,
    yamlls = function()
      M.setup_lspconfig_server('yamlls', {})
    end
  }

  -- lsp servers with no mason-lspconfig support
  if vim.fn.executable('dart') == 1 then
    M.setup_lspconfig_server('dartls', {})
  end
  if vim.fn.executable('godot-ls') == 1 then
    M.setup_lspconfig_server('gdscript', {
      -- cmd = vim.lsp.rpc.connect('127.0.0.1', 6008),
      cmd = { 'godot-ls' },
      flags = {
        debounce_text_changes = 150,
      },
    })
  end

  -- null-ls servers
  local null_ls = require 'null-ls'
  require 'mason-null-ls'.setup {
    automatic_setup = true,
  }
  require 'mason-null-ls'.setup_handlers {
    --   function(source_name)
    --     -- log('the null-ls source '..source_name..' is installed but unused!')
    --   end,
    --   stylua = function()
    --     null_ls.register(null_ls.builtins.formatting.stylua)
    --   end,
    --   jq = function()
    --     null_ls.register(null_ls.builtins.formatting.jq)
    --   end
  }
  null_ls.setup()
end)


M.setup = U.Service({{FT.LSP, 'setup'}}, {{FT.CONF, 'mason.nvim'},{FT.CONF, 'nvim-lspconfig'}}, function()
  require('lspconfig.ui.windows').default_options.border = 'single'

  -- per line nvim diagnostics
  for type, icon in pairs(Icons.diagnostic_states) do
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

  -- inc-rename
  if Features:has(FT.CONF, 'inc-rename.nvim') then
    require 'inc_rename'.setup()
  end
end)

M.rename = U.Service(function()
  if Features:has(FT.CONF, 'inc-rename.nvim') then
    vim.api.nvim_feedkeys(':IncRename ' .. vim.fn.expand('<cword>'), '', false)
    -- require 'inc_rename'.setup()
    -- inc-rename.nvim
  else
    local curr_name = vim.fn.expand("<cword>")
    local input_opts = {
      prompt = 'LSP Rename: ',
      default = curr_name
    }
    -- ask user input
    vim.ui.input(input_opts, function(new_name)
      -- check new_name is valid
      if not new_name or #new_name == 0 or curr_name == new_name then return end

      -- request lsp rename
      local params = vim.lsp.util.make_position_params()
      params.newName = new_name

      vim.lsp.buf_request(0, "textDocument/rename", params, function(err, res, ctx, _)
        if err then
          if err.message then log.err(err.message) end
          return
        end
        if not res then return end

        -- apply renames
        local client = vim.lsp.get_client_by_id(ctx.client_id)
        vim.lsp.util.apply_workspace_edit(res, client.offset_encoding)

        -- display a message
        local changes = U.count_lsp_res_changes(res)
        local message = string.format("renamed %s instance%s in %s file%s. %s",
          changes.instances,
          changes.instances == 1 and '' or 's',
          changes.files,
          changes.files == 1 and '' or 's',
          changes.files > 1 and "To save them run ':wa'" or ''
        )
        vim.notify(message)
      end)
    end)
  end
end)

M.references = U.Service(function()
  if Features:has(FT.CONF, 'telescope.nvim') then
    vim.cmd [[Telescope lsp_references]]
  else
    vim.lsp.buf.references()
  end
end)

M.definition = U.Service(function()
  if Features:has(FT.CONF, 'telescope.nvim') then
    vim.cmd [[Telescope lsp_definitions]]
  else
    vim.lsp.buf.definition()
  end
end)

M.code_action = U.Service(function()
  vim.lsp.buf.code_action()
end)

M.hover = U.Service(function()
  vim.lsp.buf.hover()
end)

M.format = U.Service(function()
  vim.lsp.buf.format()
end)

M.diags_list = U.Service(function()
  vim.diagnostic.setloclist()
  -- vim.diagnostic.setqflist()
end)

M.diags_hover = U.Service(function()
  vim.diagnostic.open_float()
end)

M.setup_buf_fmt_on_save = U.Service(function(client, bufnr)
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
