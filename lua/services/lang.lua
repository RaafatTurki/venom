--- defines language specific configurations
-- @module lang
local M = {}

M.configure_server = U.Service():require(FT.LSP, 'setup'):new(function(name, is_auto_installed, opts)
  local available_server_names = require 'nvim-lsp-installer.servers'.get_available_server_names()

  if U.has_value(available_server_names, name) then
    local server_config = U.LspServerConfig():auto_install(is_auto_installed):new(name, opts)
    Lsp.add_server_config:invoke(server_config)
    log("["..name.."] added lsp server configurations.", LL.DEBUG)
  else
    log("["..name.."] no such server available!", LL.WARN)
  end
end)

M.configure_servers = U.Service():require(FT.LSP, 'setup'):new(function()

  M.configure_server:invoke("sumneko_lua", true, {
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

  M.configure_server:invoke("texlab", false, {
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

  M.configure_server:invoke("svelte", false, {
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

  M.configure_server:invoke("rust_analyzer", false, {
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

  M.configure_server:invoke("emmet_ls", false, {
    filetypes = { 'html', 'css', 'svelte' },
  })

  M.configure_server:invoke("jsonls", false, {
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

M.setup_treesitter = U.Service():require(FT.PLUGIN, 'nvim-treesitter'):new(function(name, is_auto_installed, opts)
  -- if not is_mod_exists('nvim-treesitter.configs') then return end
  require 'nvim-treesitter.configs'.setup {
    -- to add more parsers https://github.com/nvim-treesitter/nvim-treesitter#supported-languages
    ensure_installed = {
      'bash',
      'c',
      'cmake',
      'comment',
      'cpp',
      'css',
      'fish',
      'gdscript',
      'go',
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
    indent = { enable = true },
    context_commentstring = { enable = true, enable_autocmd = false },
  }
end)

M.setup_plugins = U.Service()
:require(FT.PLUGIN, "nvim-gps")
:require(FT.PLUGIN, "spellsitter.nvim")
:new(function()

  require 'nvim-gps'.setup {
    -- separator = ' > ',
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
end)

return M
