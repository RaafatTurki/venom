--- defines language specific configurations
-- @module lang
local M = {}

M.ts_parsers_ensure_installed = {
  'bash',
  'c',
  'cmake',
  'comment',
  'cpp',
  'c_sharp',
  'css',
  'fish',
  'gdscript',
  'glsl',
  'go',
  'gomod',
  'godot_resource',
  'html',
  'http',
  'java',
  'javascript',
  'jsdoc',
  'json',
  'latex',
  'lua',
  'markdown',
  'python',
  'query',
  'regex',
  'rust',
  'scss',
  'svelte',
  'toml',
  'typescript',
  'vim',
  'yaml',
}

M.lsp_servers_configs = {}

M.configure_server = U.Service():new(function(name, tags, opts)
  local server_config = U.LspServerConfig():new(name, opts)

  for _, tag in pairs(tags) do
    server_config:tag(tag)
  end

  M.lsp_servers_configs[server_config.name] = server_config
end)

-- TODO: make a context menu option that only appears if the following think is valid
M.configure_servers = U.Service():new(function()

  M.configure_server("sumneko_lua", { LST.MANAGED },  {
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
  M.configure_server("texlab", { LST.MANAGED },  {
    settings = {
      texlab = {
        build = {
          -- forwardSearchAfter = true,
          onSave = true,
          executable = 'tectonic',
          args = vim.split('%f --synctex', ' '),
          -- "--synctex",
          -- "--keep-logs",
          -- "--keep-intermediates"
          -- "--outdir out",
          -- "--outfmt pdf", -- pdf, html, xdv, aux, fmt
          -- },
        },
        forwardSearch = {
          executable = "zathura",
          args = {"--synctex-forward", "%l:1:%f", "%p"},
        },
        chktex = {
          onOpenAndSave = true,
          onEdit = true,
        }
      },
      -- chktex = {
      --  onEdit = true,
      --  onOpenAndSave = true,
      -- },
    }
  })
  M.configure_server("svelte", { LST.MANAGED }, {
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
  M.configure_server("rust_analyzer", { LST.MANAGED }, {
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
  M.configure_server("emmet_ls", { LST.MANAGED }, {
    filetypes = { 'html', 'css', 'svelte' },
  })
  M.configure_server("jsonls", { LST.MANAGED }, {
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
  M.configure_server("pylsp", { LST.MANAGED }, {
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
  M.configure_server("gopls", { LST.MANAGED }, {
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
  M.configure_server("ltex", { LST.MANAGED }, {
    settings = {
      ltex = {
        completionEnabled = true,
      }
    }
  })

  -- annoying and up to no good lsp servers:
  M.configure_server("jdtls", {}, {
  })
  M.configure_server("gdscript", {}, {
    cmd = {'godot-ls'},
    flags = {
      debounce_text_changes = 150,
    },
  })

  local mason_lspconfig = require "mason-lspconfig"
  for _, server_name in ipairs(mason_lspconfig.get_installed_servers()) do
    -- add LST.AUTO_SETUP to installed LST.MANAGED servers
    if U.has_key(M.lsp_servers_configs, server_name) then
      if U.has_value(M.lsp_servers_configs[server_name].tags, LST.MANAGED) then
        M.lsp_servers_configs[server_name]:tag(LST.AUTO_SETUP)
      end
    -- configure unconfigured and installed servers with LST.MANAGED and LST.AUTO_SETUP
    else
      M.configure_server(server_name, { LST.MANAGED, LST.AUTO_SETUP }, {})
    end
  end
end)

M.setup_treesitter = U.Service():require(FT.PLUGIN, 'nvim-treesitter'):new(function()
  -- local parser_configs = require 'nvim-treesitter.parsers'.get_parser_configs()
  require 'nvim-treesitter.configs'.setup {
    -- to add more parsers https://github.com/nvim-treesitter/nvim-treesitter#supported-languages
    ensure_installed = M.ts_parsers_ensure_installed,
    -- playground = { enable = true },
    highlight = { enable = true },
    indent = { enable = true },   -- indentexpr (=)
    context_commentstring = { enable = true, enable_autocmd = false },
    matchup = { enable = true },
  }
end)

M.setup = U.Service()
:require(FT.PLUGIN, "mason.nvim")
-- :require(FT.PLUGIN, "nvim-comment")
:require(FT.PLUGIN, "nvim-navic")
:require(FT.PLUGIN, "spellsitter.nvim")
:require(FT.PLUGIN, "neotest")
:require(FT.PLUGIN, "nvim-jdtls")
:new(function()
  -- mason
  require 'mason'.setup {
    ui = {
      border = 'single',
      icons = {
        package_installed = " ",
        package_pending = " ",
        package_uninstalled = "  ",
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

  -- nvim comment
  local ts_ctx_cs_filetypes = { 'html', 'svelte' }
  require 'Comment'.setup {
    mappings = false,
    ignore = '^$',
    pre_hook = function(ctx)
      if U.has_value(ts_ctx_cs_filetypes, vim.bo.filetype) then
        local comment_utils = require 'Comment.utils'
        local ts_ctx_cs_utils = require 'ts_context_commentstring.utils'
        local ts_ctx_cs_internal = require 'ts_context_commentstring.internal'

        -- determine the location where to calculate commentstring from
        local cs_pos = nil
        if ctx.ctype == comment_utils.ctype.block then
          cs_pos = ts_ctx_cs_utils.get_cursor_location()
        elseif ctx.cmotion == comment_utils.cmotion.v or ctx.cmotion == comment_utils.cmotion.V then
          cs_pos = ts_ctx_cs_utils.get_visual_start_location()
        end

        -- return '%s'
        -- commentstring calculation
        return ts_ctx_cs_internal.calculate_commentstring({
          key = ctx.ctype == comment_utils.ctype.line and '__default' or '__multiline',
          location = cs_pos,
        })
      end
    end,
  }

  -- navic
  local navic_icons = {}
  for name, icon in pairs(venom.icons.item_kinds.cozette) do navic_icons[name] = icon..' ' end
  vim.g.navic_silence = true
  require 'nvim-navic'.setup {
    highlight = true,
    separator = ' > ',
    icons = navic_icons,
  }

  -- spellsitter
  require 'spellsitter'.setup {
    enable = true,
  }

  -- neotest
  require 'neotest'.setup {
    adapters = {
      require 'neotest-go',
      require 'neotest-jest',
    }
  }
  vim.api.nvim_create_user_command('NeotestToggleTree',   function() require 'neotest'.summary.toggle() end,              {})
  vim.api.nvim_create_user_command('NeotestRunNearest',   function() require 'neotest'.run.run() end,                     {})
  vim.api.nvim_create_user_command('NeotestRunFile',      function() require 'neotest'.run.run(vim.fn.expand("%")) end,   {})

  -- nvim-jdtls
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

end)

return M
