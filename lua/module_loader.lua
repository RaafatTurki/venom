PluginManager = require 'plugin_manager'
Buffers = require 'modules.buffers'
Sessions = require 'modules.sessions'
Misc = require 'modules.misc'
Plugins = require 'modules.plugins'
Lang = require 'modules.lang'
Dap = require 'modules.dap'
Lsp = require 'modules.lsp'
Statusbar = require 'modules.statusbar'
Keybinds = require 'modules.keybinds'

local p = {
  plenary = 'nvim-lua/plenary.nvim',
  devicons = 'nvim-tree/nvim-web-devicons',
  nui = 'MunifTanjim/nui.nvim',
  lspconfig = 'neovim/nvim-lspconfig',
  mason = 'williamboman/mason.nvim',
  treesitter = 'nvim-treesitter/nvim-treesitter',
  dap = 'mfussenegger/nvim-dap',
}
local plugins = {
  -- NOTE LSP
  { 'williamboman/mason-lspconfig.nvim',
    dependencies = p.mason,
  },
  { 'mfussenegger/nvim-jdtls',
    dependencies = p.lspconfig
  },
  { 'jose-elias-alvarez/typescript.nvim',
    dependencies = p.lspconfig
  },
  { 'b0o/schemastore.nvim',
    dependencies = p.lspconfig
  },
  { 'folke/neodev.nvim',
    dependencies = p.lspconfig
  },
  -- NOTE LANG
  { 'JoosepAlviste/nvim-ts-context-commentstring',
    dependencies = { 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate' },
  },
  -- NOTE STATUSBAR
  { 'rebelot/heirline.nvim',
    dependencies = p.devicons,
  },
  -- NOTE DAP
  { 'jay-babu/mason-nvim-dap.nvim',
    dependencies = {
      p.dap,
      p.mason,
    },
  },
  -- NOTE PLUGINS
  { 'echasnovski/mini.nvim',
    config = function()
      events.plugin_setup:sub(Plugins.mini_map)
      events.plugin_setup:sub(Plugins.mini_bufremove)
      events.plugin_setup:sub(Plugins.mini_move)
      events.plugin_setup:sub(Plugins.mini_hipatterns)
    end
  },
  { 'RRethy/vim-illuminate',
    config = function()
      events.plugin_setup:sub(Plugins.illuminate)
    end
  },
  { 'lewis6991/gitsigns.nvim',
    config = function()
      events.plugin_setup:sub(Plugins.gitsigns)
    end
  },
  { 'akinsho/git-conflict.nvim',
    config = function()
      events.plugin_setup:sub(Plugins.git_conflict)
    end
  },
  { 'dinhhuy258/sfm.nvim', dev = false,
    dependencies = {
      'dinhhuy258/sfm-git.nvim',
    },
    config = function()
      events.plugin_setup:sub(Plugins.sfm)
    end
  },
  { 'akinsho/toggleterm.nvim',
    config = function()
      events.plugin_setup:sub(Plugins.toggle_term)
    end
  },
  { 'nvim-telescope/telescope.nvim',
    dependencies = {
      p.plenary,
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
      'nvim-telescope/telescope-ui-select.nvim',
    },
    config = function()
      events.plugin_setup:sub(Plugins.telescope)
    end
  },
  { 'jghauser/fold-cycle.nvim',
    config = function()
      events.plugin_setup:sub(Plugins.fold_cycle)
    end
  },
  { 'anuvyklack/fold-preview.nvim',
    dependencies = 'anuvyklack/keymap-amend.nvim',
    config = function()
      events.plugin_setup:sub(Plugins.fold_preview)
    end
  },
  { 'folke/noice.nvim',
    config = function()
      events.plugin_setup:sub(Plugins.noice)
    end,
    dependencies = p.nui,
  },
  { 'hrsh7th/nvim-cmp',
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
      events.plugin_setup:sub(Plugins.cmp_ls)
    end
  },
  { 'utilyre/sentiment.nvim',
    config = function()
      events.plugin_setup:sub(Plugins.sentiment)
    end
  },
  { 'RaafatTurki/hex.nvim', dev = false,
    config = function()
      events.plugin_setup:sub(Plugins.hex)
    end
  },
  { 'RaafatTurki/corn.nvim', dev = false,
    config = function()
      events.plugin_setup:sub(Plugins.corn)
    end
  },
  { 'rest-nvim/rest.nvim',
    dependencies = {
      p.plenary,
    },
    config = function()
      events.plugin_setup:sub(Plugins.rest)
    end
  },
  -- { 'RaafatTurki/view.nvim', dev = false,
  --   config = function()
  --     events.plugin_setup:sub(Plugins.view)
  --   end
  -- },
  -- { 'sindrets/diffview.nvim' },
  -- { 'folke/edgy.nvim',
  --   config = function()
  --     Events.plugin_setup:sub(Plugins.edgy)
  --   end
  -- },
}

events.install_pre:sub(function()
  Buffers.setup()

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
  Misc.neovide()

  Keybinds.setup()
end)

events.install_post:sub(function()
  Sessions.setup()

  Misc.auto_install_ts_parser()
  Misc.lorem_picsum()
  -- Misc.auto_gitignore_io()
  Misc.conceal_html_classes()

  Plugins.setup()

  Lang.setup()

  Lsp.setup()
  Lsp.setup_servers()

  Dap.setup()

  Statusbar.setup()

  Keybinds.setup_plugins()
end)

PluginManager.setup(plugins)
