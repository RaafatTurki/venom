--- defines language specific configurations
-- @module lang
local M = {}

M.lsp_servers_configs = {}

M.configure_server = U.Service():new(function(name, tags, opts)
  local server_config = U.LspServerConfig():new(name, opts)

  for _, tag in pairs(tags) do
    server_config:tag(tag)
  end

  M.lsp_servers_configs[server_config.name] = server_config
end)

M.configure_servers = U.Service():new(function()

  M.configure_server("sumneko_lua", {},  {
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
    -- on_attach_hook = function(client, bufnr)
    --   Lsp.setup_buf_fmt_on_save(client, bufnr)
    -- end
  })

  M.configure_server("texlab", {},  {
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
      },
      -- chktex = {
      --  onEdit = true,
      --  onOpenAndSave = true,
      -- },
    }
  })

  M.configure_server("svelte", {}, {
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

  M.configure_server("rust_analyzer", {}, {
    settings = {
      ["rust-analyzer"] = {
        diagnostics = {
          disabled = true
          -- disabled = {
          --  "unresolved-import",
          -- }
        }
      }
    }
  })

  M.configure_server("emmet_ls", {}, {
    filetypes = { 'html', 'css', 'svelte' },
  })

  M.configure_server("jsonls", {}, {
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

  M.configure_server("pylsp", {}, {
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

  M.configure_server("gopls", {}, {
    settings = {
      gopls = {
        usePlaceholders = true,
        linksInHover = false,
        analyses = {
          useany = true,
        },
      }
    }
  })


  -- annoying and up to no good lsp servers:
  M.configure_server("jdtls", { LST.NO_AUTO_SETUP }, {})

  -- M.configure_server("java_language_server", {}, {
  --   cmd = {'/usr/share/java/java-language-server/lang_server_linux.sh'},
  -- })

  M.configure_server("gdscript", {}, {
    cmd = {'godot-ls'},
    flags = {
      debounce_text_changes = 150,
    },
  })

  -- looping over all installed LSPI servers
  local lspi = require 'nvim-lsp-installer'
  for _, server_obj in ipairs(lspi.get_installed_servers()) do
    if (not U.has_key(M.lsp_servers_configs, server_obj.name)) then
      -- configure unconfigured servers
      M.configure_server(server_obj.name, { LST.AUTO_SETUP }, {})
    else
      -- add LST.AUTO_SETUP tag to configured servers
      M.lsp_servers_configs[server_obj.name]:tag(LST.AUTO_SETUP)
    end
  end

  -- log configured server names and tags
  -- for _, server_config in pairs(M.lsp_servers_configs) do
  --   logi(server_config.name)
  --   logi(server_config.tags)
  -- end
end)

M.setup_treesitter = U.Service():require(FT.PLUGIN, 'nvim-treesitter'):new(function()
  local parser_configs = require("nvim-treesitter.parsers").get_parser_configs()
  -- parser_configs.ron = {
  --   install_info = {
  --     url = "https://github.com/zee-editor/tree-sitter-ron",
  --     files = { "src/parser.c" },
  --     branch = "main",
  --   },
  -- }

  -- if not is_mod_exists('nvim-treesitter.configs') then return end
  require 'nvim-treesitter.configs'.setup {
    -- to add more parsers https://github.com/nvim-treesitter/nvim-treesitter#supported-languages
    ensure_installed = {
      -- 'ron',

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
    },
    -- playground = { enable = true },
    highlight = { enable = true },
    indent = { enable = true },   -- indentexpr (=)
    context_commentstring = { enable = true, enable_autocmd = false },
    incremental_selection = {
      enable = true,
      keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        -- init_selection = '<CR>',
        -- scope_incremental = '<CR>',
        -- node_incremental = '<TAB>',
        -- node_decremental = '<S-TAB>',
      },
    },
    matchup = { enable = true },
  }
end)

M.setup = U.Service()
:require(FT.PLUGIN, "nvim-lsp-installer")
:require(FT.PLUGIN, "nvim-comment")
:require(FT.PLUGIN, "nvim-navic")
:require(FT.PLUGIN, "spellsitter.nvim")
-- :require(FT.PLUGIN, "nvim-jdtls")
:new(function()
  -- lsp-installer
  require 'nvim-lsp-installer'.setup({
    ui = {
      border = 'single',
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

  -- nvim comment
  local commentstrings_context_aware = {
    vue = {},
    svelte = {},
    html = {},
    javascript = {},
  }
  local commentstrings = {
    gdscript = '#%s',
    fish = '#%s',
    c = '//%s',
    toml = '#%s',
    samba = '#%s',
    desktop = '#%s',
    dosini = '#%s',
    bc = '#%s',
    glsl = '//%s',
    cs = '//%s',
    sshdconfig = '#%s',
  }
  require 'nvim_comment'.setup {
    create_mappings = false,
    marker_padding = true,
    hook = function()
      for filetype, value in pairs(commentstrings) do
        if vim.api.nvim_buf_get_option(0, "filetype") == filetype then
          vim.api.nvim_buf_set_option(0, "commentstring", value)
        end
      end
      for filetype, value in pairs(commentstrings_context_aware) do
        if vim.api.nvim_buf_get_option(0, "filetype") == filetype then
          require("ts_context_commentstring.internal").update_commentstring()
        end
      end
    end
  }

  -- navic
  local navic_icons = {}
  for name, icon in pairs(venom.icons.item_kinds.cozette) do navic_icons[name] = icon..' ' end
  U.gvar('navic_silence'):set(true)
  require 'nvim-navic'.setup {
    highlight = true,
    separator = ' > ',
    icons = navic_icons,
  }

  -- spellsitter
  require 'spellsitter'.setup {
    enable = true,
  }

  -- matchup
  -- U.gvar('matchup_matchparen_offscreen'):set({})

  -- nvim-jdtls
  -- function JDTLSSetup()
  --   local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
  --   local workspace_dir = os.getenv('XDG_CACHE_HOME') .. '/jdtls/workspaces/' .. project_name
  --
  --   JDTLS_CONFIG = {
  --     cmd = {
  --       'java',
  --
  --       '-Declipse.application=org.eclipse.jdt.ls.core.id1',
  --       '-Dosgi.bundles.defaultStartLevel=4',
  --       '-Declipse.product=org.eclipse.jdt.ls.core.product',
  --       '-Dlog.protocol=true',
  --       '-Dlog.level=ALL',
  --
  --       '-javaagent:/home/potato/.local/share/nvim/lsp_servers/jdtls/lombok.jar',
  --
  --       '-Xms1g',
  --       '--add-modules=ALL-SYSTEM',
  --       '--add-opens', 'java.base/java.util=ALL-UNNAMED',
  --       '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
  --
  --       '-jar', '/home/potato/.local/share/nvim/lsp_servers/jdtls/plugins/org.eclipse.equinox.launcher_1.6.400.v20210924-0641.jar',
  --       '-configuration', '/home/potato/.local/share/nvim/lsp_servers/jdtls/config_linux',
  --       '-data', workspace_dir,
  --     },
  --
  --     root_dir = require('jdtls.setup').find_root({'.git', 'mvnw', 'gradlew'}),
  --
  --     -- TODO: extract into a ServerConfig
  --     settings = {
  --       java = {}
  --     },
  --
  --     init_options = {
  --       bundles = {}
  --     },
  --   }
  --
  --   require('jdtls').start_or_attach(JDTLS_CONFIG)
  -- end

  vim.cmd [[
    augroup java
    autocmd!
    " autocmd BufEnter .swcrc setlocal ft=json
    autocmd FileType java lua JDTLSSetup()

    augroup java
  ]]
end)

return M
