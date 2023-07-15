Buffers = require 'services.buffers'
PluginManager = require 'plugin_manager'
Sessions = require 'services.sessions'
Bind = require 'services.bind'
Misc = require 'services.misc'
Plugins = require 'services.plugins'
Lang = require 'services.lang'
Lsp = require 'services.lsp'
Statusbar = require 'services.statusbar'

local p = {
  plenary = 'nvim-lua/plenary.nvim',
  devicons = 'kyazdani42/nvim-web-devicons',
  treesitter = 'nvim-treesitter/nvim-treesitter',
  dap = 'mfussenegger/nvim-dap',
  gitsigns = 'lewis6991/gitsigns.nvim',
  nui = 'MunifTanjim/nui.nvim',
  lspconfig = 'neovim/nvim-lspconfig',
  cmp = 'hrsh7th/nvim-cmp',
}
local plugins = {
  -- NOTE LSP: language server protocol related
  { p.lspconfig },
  {'jose-elias-alvarez/null-ls.nvim',
    dependencies = p.plenary,
  },
  { 'williamboman/mason.nvim',
    dependencies = {
      p.lspconfig,
      'williamboman/mason-lspconfig.nvim',
      'jayp0521/mason-null-ls.nvim',
    },
  },
  { 'mfussenegger/nvim-jdtls' },
  { 'jose-elias-alvarez/typescript.nvim' },
  { 'b0o/schemastore.nvim',
    dependencies = p.lspconfig,
  },
  { 'folke/neodev.nvim',
    dependencies = p.lspconfig,
  },
  -- NOTE LANG: treesitter and language specific plugins
  { p.treesitter,
    build = ':TSUpdate',
  },
  { 'JoosepAlviste/nvim-ts-context-commentstring',
    dependencies = p.treesitter,
  },
  { 'euclio/vim-markdown-composer',
    build = 'cargo build --release',
    config = function()
      Events.plugin_setup:sub(Plugins.vim_markdown_composer)
    end
  },
  { 'toppair/peek.nvim',
    build = 'deno task --quiet build:fast',
    config = function()
      Events.plugin_setup:sub(Plugins.peek)
    end
  },
  { 'utilyre/sentiment.nvim',
    config = function()
      Events.plugin_setup:sub(Plugins.sentiment)
    end
  },
  -- NOTE STATUSBAR:
  { 'rebelot/heirline.nvim',
    dependencies = p.devicons,
  },
  -- NOTE PLUGINS:
  { 'echasnovski/mini.nvim',
    config = function()
      -- Events.plugin_setup:sub(Plugins.mini_starter)
      Events.plugin_setup:sub(Plugins.mini_map)
      Events.plugin_setup:sub(Plugins.mini_bufremove)
      Events.plugin_setup:sub(Plugins.mini_move)
      Events.plugin_setup:sub(Plugins.mini_hipatterns)
    end
  },
  { 'RRethy/vim-illuminate',
    config = function()
      Events.plugin_setup:sub(Plugins.illuminate)
    end
  },
  { p.gitsigns,
    dependencies = p.plenary,
    config = function()
      Events.plugin_setup:sub(Plugins.gitsigns)
    end
  },
  { 'nvim-neo-tree/neo-tree.nvim',
    branch = "v2.x",
    dependencies = {
      p.plenary,
      p.nui,
      p.devicons,
      's1n7ax/nvim-window-picker',
    },
    config = function()
      Events.plugin_setup:sub(Plugins.neo_tree)
    end
  },
  { 'akinsho/toggleterm.nvim',
    config = function()
      Events.plugin_setup:sub(Plugins.toggle_term)
    end
  },
  { 'nvim-telescope/telescope.nvim',
    dependencies = {
      p.plenary,
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
      'nvim-telescope/telescope-ui-select.nvim',
    },
    config = function()
      Events.plugin_setup:sub(Plugins.telescope)
    end
  },
  { 'jghauser/fold-cycle.nvim',
    config = function()
      Events.plugin_setup:sub(Plugins.fold_cycle)
    end
  },
  { 'anuvyklack/fold-preview.nvim',
    dependencies = 'anuvyklack/keymap-amend.nvim',
    config = function()
      Events.plugin_setup:sub(Plugins.fold_preview)
    end
  },
  { 'folke/noice.nvim',
    config = function()
      Events.plugin_setup:sub(Plugins.noice)
    end,
    dependencies = p.nui,
  },
  { p.cmp,
    dependencies = {
      'lukas-reineke/cmp-rg',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-nvim-lua',
      'saadparwaiz1/cmp_luasnip',
      'L3MON4D3/LuaSnip',
      'hrsh7th/cmp-cmdline',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-nvim-lsp-signature-help',
    },
    config = function()
      Events.plugin_setup:sub(Plugins.cmp_ls)
    end
  },
  -- { 'mawkler/modicator.nvim',
  --   config = function()
  --     Events.plugin_setup:sub(Plugins.modicator)
  --   end,
  -- },
  { 'RaafatTurki/hex.nvim', dev = false,
    config = function()
      Events.plugin_setup:sub(Plugins.hex)
    end
  },
  -- { 'sindrets/diffview.nvim' },
  -- { 'folke/edgy.nvim',
  --   config = function()
  --     Events.plugin_setup:sub(Plugins.edgy)
  --   end
  -- },
  -- p.dap,
  -- {'rcarriga/nvim-dap-ui',                            dependencies = p.dap },
  -- UNCHARTED:
  -- { 'folke/paint.nvim',
  --   config = function()
  --     Events.plugin_setup:sub(Plugins.paint)
  --   end,
  -- },
}

Events.install_pre:sub(function()
  Buffers.setup()
  Bind.setup()

  Misc.base()
  Misc.open_uri()
  -- Misc.color_col()
  Misc.term_smart_esc()
  Misc.disable_builtin_plugins()
  Misc.highlight_yank()
  -- Misc.diag_on_hold()
  Misc.pets()
  Misc.buffer_edits()
  Misc.auto_create_dir()
  Misc.auto_curlinenr_mode()
end)

Events.install_post:sub(function()
  Sessions.setup()

  Misc.auto_install_ts_parser()
  Misc.lorem_picsum()
  Misc.auto_gitignore_io()
  Misc.conceal_html_classes()

  Plugins.setup()

  Lang.setup()

  Lsp.setup()
  Lsp.setup_servers()

  Statusbar.setup()

  Bind.setup_plugins()
end)

PluginManager.setup(plugins)
