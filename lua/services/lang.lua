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

  M.configure_server:invoke("sumneko_lua", {},  {
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
        telemetry = { enable = false },
      }
    }
  })

  M.configure_server:invoke("texlab", {},  {
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

  M.configure_server:invoke("svelte", {}, {
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

  M.configure_server:invoke("rust_analyzer", {}, {
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

  M.configure_server:invoke("emmet_ls", {}, {
    filetypes = { 'html', 'css', 'svelte' },
  })

  M.configure_server:invoke("jsonls", {}, {
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

  M.configure_server:invoke("pylsp", {}, {
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

  M.configure_server:invoke("gopls", {}, {
    settings = {
      gopls = {
        analyses = {
          -- unusedparams = true,
          fieldalignment = true,
          useany = true,
        }
      }
    }
  })


  -- annoying and up to no good lsp servers:
  M.configure_server:invoke("jdtls", { LST.NO_AUTO_SETUP }, {})

  M.configure_server:invoke("java_language_server", { LST.NO_AUTO_SETUP }, {
    cmd = {'/usr/share/java/java-language-server/lang_server_linux.sh'},
  })

  M.configure_server:invoke("gdscript", { LST.NO_AUTO_SETUP }, {
    cmd = {'godot-ls'},
    flags = {
      debounce_text_changes = 150,
    },
  })

  -- adding all unconfigured and installed LSPI servers into server_configs
  local lspi = require 'nvim-lsp-installer'
  for _, server_obj in ipairs(lspi.get_installed_servers()) do
    if (not U.has_key(M.lsp_servers_configs, server_obj.name)) then
      M.configure_server:invoke(server_obj.name, {}, {})
    end
  end
end)

M.setup_treesitter = U.Service():require(FT.PLUGIN, 'nvim-treesitter'):new(function()
  -- if not is_mod_exists('nvim-treesitter.configs') then return end
  require 'nvim-treesitter.configs'.setup {
    -- to add more parsers https://github.com/nvim-treesitter/nvim-treesitter#supported-languages
    ensure_installed = {
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
:require(FT.PLUGIN, "nvim-gps")
:require(FT.PLUGIN, "spellsitter.nvim")
:new(function()
  -- lsp-installer
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

  -- gps
  require 'nvim-gps'.setup {
    separator = ' > ',
    icons = {
      ["class-name"] = venom.icons.item_kinds.cozette.Class..' ',
      ["function-name"] = venom.icons.item_kinds.cozette.Function..' ',
      ["method-name"] = venom.icons.item_kinds.cozette.Method..' ',
      ["container-name"] = venom.icons.item_kinds.cozette.TypeParameter..' ',
      ["tag-name"] = venom.icons.item_kinds.cozette.TypeParameter..' ',
    },
  }

  -- spellsitter
  require 'spellsitter'.setup {
    enable = true,
  }

  -- matchup
  U.gvar('matchup_matchparen_offscreen'):set({})

  -- nvim-jdtls

  
  -- require 'aerial'.setup {
  --   backends = { "lsp" },
  --   -- , "treesitter", "markdown"
  --  
  --   show_guides = true,
  --   placement_editor_edge = true,
  --
  --   open_automatic = true,
  --   -- filter_kind = false,
  --
  --
  --   link_folds_to_tree = true,
  --   link_tree_to_folds = true,
  --   manage_folds = true,
  -- }
end)

return M
