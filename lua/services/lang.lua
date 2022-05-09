--- defines language specific configurations
-- @module lang
local M = {}

M.configure_server = U.Service():require(FT.LSP, 'setup'):new(function(name, tags, opts)
  local server_config = U.LspServerConfig():new(name, opts)

  for _, tag in pairs(tags) do
    server_config:tag(tag)
  end

  Lsp.add_server_config:invoke(server_config)
end)

M.configure_servers = U.Service():require(FT.LSP, 'setup'):new(function()

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
            ignore=  {'E501', 'E231', 'E305', 'W391'},
          },
        }
      }
    }
  })

  -- M.configure_server:invoke("$1", $2, {
  --  $3
  -- })

--- language servers options that are installed by third party means
-- @field table ls opts
-- M.SERVERS_THIRD_PARTY_OPTS = {
--   gdscript = {
--     cmd = {'godot-ls'},
--     flags = {
--       debounce_text_changes = 150,
--     },
--   },
-- }
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

M.setup_plugins = U.Service()
:require(FT.PLUGIN, "nvim-gps")
:require(FT.PLUGIN, "spellsitter.nvim")
:new(function()
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

  require 'spellsitter'.setup {
    enable = true,
  }

  
  U.gvar('matchup_matchparen_offscreen'):set({})

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

M.setup_lang_opts = U.Service():new(function()
  -- vim.opt.matchpairs      = '(:),{:},[:]'
  -- vim.b.match_words = '<h1>:</h1>'

	-- let b:match_words = '<:>,<tag>:</tag>'
end)

return M
