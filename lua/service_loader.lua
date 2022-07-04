--- invokes various services
-- @module service_loader

PluginManager = require 'plugin_manager'
Sessions = require 'services.sessions'
Bind = require 'services.bind'
Misc = require 'services.misc'
Themes = require 'services.themes'
Plugins = require 'services.plugins'
Lang = require 'services.lang'
Lsp = require 'services.lsp'
Statusbar = require 'services.statusbar'

PluginManager.attempt_bootstrap()
PluginManager.setup()

PluginManager.event_post_complete:subscribe(function()
  Sessions.setup()
  Bind.setup()

  Bind.bind_leader()

  Misc.base()
  Misc.open_uri()
  -- Misc.color_col()
  Misc.term_smart_esc()
  Misc.disable_builtin_plugins()
  Misc.highlight_yank()
  Misc.automatic_treesitter()
  -- Misc.diag_on_hold()
  Misc.camel()
  Misc.buffer_edits()
  -- Misc.tabline_minimal()

  Themes.init({
    { func = Themes.builtin,  args = {},             name = 'Built-In'},
    { func = Themes.material, args = 'darker',       name = 'Material Darker'},
    { func = Themes.material, args = 'lighter',      name = 'Material Lighter'},
    { func = Themes.material, args = 'deep ocean',   name = 'Material Deep Ocean'},
    { func = Themes.material, args = 'oceanic',      name = 'Material Oceanic'},
    { func = Themes.material, args = 'palenight',    name = 'Material Pale Night'},
    { func = Themes.default,  args = {},             name = 'Default'},
  })

  Plugins.impatient()
  Plugins.devicons()
  Plugins.dressing()
  -- Plugins.notify()
  Plugins.bqf()
  Plugins.reach()
  Plugins.fzf_lua()
  Plugins.gitsigns()
  Plugins.nvim_tree()
  Plugins.bufferline()
  Plugins.cmp_ls()
  Plugins.toggle_term()
  -- Plugins.fidget()
  Plugins.mini_starter()
  Plugins.mini_surround()
  Plugins.dirty_talk()
  Plugins.hover()
  Plugins.paperplanes()
  Plugins.trld()
  Plugins.fold_cycle()
  Plugins.icon_picker()
  -- Plugins.corn()
  -- Plugins.cinnamon()
  -- Plugins.remember()

  Lang.setup()
  Lang.configure_servers()
  Lang.setup_treesitter()

  Lsp.setup()
  Lsp.setup_servers(Lang.lsp_servers_configs)

  Statusbar.setup()

  Bind.setup_plugins()
end)

local p = {
  plenary = 'nvim-lua/plenary.nvim',
  devicons = 'kyazdani42/nvim-web-devicons',
  treesitter = 'nvim-treesitter/nvim-treesitter',
  gitsigns = 'lewis6991/gitsigns.nvim',
  nui = 'MunifTanjim/nui.nvim',
  lspconfig = 'neovim/nvim-lspconfig',
  cmp = 'hrsh7th/nvim-cmp',
  mini = 'echasnovski/mini.nvim',
}
PluginManager.plugins = {
  -- PLUGIN_MANAGER:
  {'wbthomason/packer.nvim'},

  -- THEMES:
  {'rktjmp/lush.nvim'},
  {'marko-cerovac/material.nvim'},

  -- LSP:
  p.lspconfig,
  {'lewis6991/hover.nvim'},
  {'smjonas/inc-rename.nvim'},

  -- LANG:
  {p.treesitter,                                      run = ':TSUpdate' },
  {'williamboman/nvim-lsp-installer',                 requires = p.lspconfig },
  {'terrortylor/nvim-comment'},
  {'JoosepAlviste/nvim-ts-context-commentstring',     requires = p.treesitter },
  {'SmiteshP/nvim-navic',                             requires = p.lspconfig },
  {'lewis6991/spellsitter.nvim'},
  {'b0o/schemastore.nvim',                            requires = p.lspconfig },

  -- PLUGINS:
  -- mini.*
  {'lewis6991/impatient.nvim'},
  p.devicons,
  {'stevearc/dressing.nvim'},
  {'kevinhwang91/nvim-bqf'},
  -- {'declancm/cinnamon.nvim'},
  -- {'rcarriga/nvim-notify',                            requires = p.plenary },
  {p.gitsigns,                                        requires = p.plenary },
  {'fedepujol/move.nvim'},
  {'rktjmp/paperplanes.nvim',                         branch = 'rel-0.1.2' },
  {'Mofiqul/trld.nvim'},
  -- {'~/sectors/lua/corn.nvim'},
  {'kyazdani42/nvim-tree.lua',                        requires = p.devicons },
  {'toppair/reach.nvim'},
  {'akinsho/bufferline.nvim',                         requires = p.devicons,  tag = "v2.*" },
  {'akinsho/nvim-toggleterm.lua'},
  {'ibhagwan/fzf-lua',                                requires = p.devicons },
  {'jghauser/fold-cycle.nvim'},
  {'ziontee113/icon-picker.nvim'},
  -- {'kevinhwang91/nvim-ufo',                           requires = 'kevinhwang91/promise-async' },
  -- {'smjonas/snippet-converter.nvim'},
  -- {'j-hui/fidget.nvim'},
  -- {'vladdoster/remember.nvim'},
  {p.cmp,                                             requires = {
    {'hrsh7th/cmp-buffer'},
    {'hrsh7th/cmp-path'},
    {'hrsh7th/cmp-nvim-lsp'},
    {'hrsh7th/cmp-nvim-lua'},
    {'f3fora/cmp-spell',                              requires = p.plenary },
    {'saadparwaiz1/cmp_luasnip'},
    {'L3MON4D3/LuaSnip'},
    {'hrsh7th/cmp-cmdline'},
    {'dmitmel/cmp-digraphs'},
    -- {'hrsh7th/cmp-nvim-lsp-signature-help'},
    -- {'hrsh7th/cmp-nvim-lsp-document-symbol'},
  }},

  -- STATUSBAR:
  {'famiu/feline.nvim',                               requires = { p.devicons, p.gitsigns }},

  -- SESSIONS:
  -- mini.sessions

  -- MULTI_PURPOSE:
  {p.mini,                                            branch = 'stable' },

  -- DEBUGGING:
  -- {'nvim-treesitter/playground',                      requires = p.treesitter },




  -- themes -- for more ts supported colorschemes https://github.com/rockerBOO/awesome-neovim#colorscheme

  -- zero config
  -- {'iamcco/markdown-preview.nvim',                    config = 'vim.call("mkdp#util#install")'},
  -- {'NTBBloodbath/rest.nvim',                          requires = p.plenary },

  -- config
  -- {'RaafatTurki/vim-quickui'},
  -- {'karb94/neoscroll.nvim'},
  -- {p.telescope,                                       requires = p.plenary },
  -- {'kosayoda/nvim-lightbulb'},
  -- {'dstein64/nvim-scrollview'},
  -- {'rcarriga/vim-ultest',                             requires = 'vim-test/vim-test', run = ':UpdateRemotePlugins' },
  -- {'ThePrimeagen/harpoon',                            requires = p.plenary },

  -- -- ts addons

  -- UNCHARTED:
  {'baskerville/vim-sxhkdrc'},
  {'antoinemadec/FixCursorHold.nvim'},                  -- https://github.com/neovim/neovim/issues/12587
  {'psliwka/vim-dirtytalk',                           run = ':DirtytalkUpdate'},
  -- {'mfussenegger/nvim-jdtls'},
  {'ron-rs/ron.vim'},
  -- {'tiagovla/scope.nvim'},

  -- {'andymass/vim-matchup'},
  -- {'github/copilot.vim'},
  -- {'floobits/floobits-neovim'},
  -- {'jbyuki/nabla.nvim'},
  -- {'Mofiqul/trld.nvim'},
  -- {'goolord/alpha-nvim',                              requires = p.devicons },
  -- {'folke/lua-dev.nvim'},
  -- {'farmergreg/vim-lastplace'},
  -- {'lambdalisue/suda.vim'},
  -- {'icatalina/vim-case-change'},
  -- {'Shatur/neovim-session-manager',                   requires = p.plenary },
  -- {'norcalli/nvim-colorizer.lua'},
  -- {'weilbith/nvim-code-action-menu'},
  -- {'dstein64/vim-startuptime'},
  -- {'vuki656/package-info.nvim',                       requires = p.nui },
  -- {'gelguy/wilder.nvim'},
  -- {'p00f/clangd_extensions.nvim'},
}

PluginManager.register_plugins()
