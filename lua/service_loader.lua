--- invokes various services
-- @module service_loader
local PluginManager = load_module "plugin_manager"

-- venom.features:add("plugin_manager") -- XXX: set conditionally within plugin_manager.lua
PluginManager.attempt_bootstrap()
PluginManager.setup()

Sessions = load_module 'services.sessions'
Bind = load_module 'services.bind'
Misc = load_module 'services.misc'
Themes = load_module 'services.themes'
Plugins = load_module 'services.plugins'
Lang = load_module 'services.lang'
Lsp = load_module 'services.lsp'
Statusbar = load_module 'services.statusbar'

venom.actions.pm_post_complete:subscribe(function()
  Sessions.setup:invoke()
  Bind.setup:invoke()

  Bind.bind_leader:invoke()

  Misc.base:invoke()
  Misc.open_uri:invoke()
  -- Misc.color_col:invoke()
  Misc.term_smart_esc:invoke()
  Misc.disable_builtin_plugins:invoke()
  Misc.highlight_yank:invoke()
  Misc.lsp_funcs:invoke()
  Misc.automatic_treesitter:invoke()
  -- Misc.diag_on_hold:invoke()
  
  Themes.init({
    { func = Themes.builtin,  args = {},             name = 'Built-In'},
    { func = Themes.material, args = 'darker',       name = 'Material Darker'},
    { func = Themes.material, args = 'lighter',      name = 'Material Lighter'},
    { func = Themes.material, args = 'deep ocean',   name = 'Material Deep Ocean'},
    { func = Themes.material, args = 'oceanic',      name = 'Material Oceanic'},
    { func = Themes.material, args = 'palenight',    name = 'Material Pale Night'},
    { func = Themes.default,  args = {},             name = 'Default'},
  })
  
  Plugins.impatient:invoke()
  Plugins.notify:invoke()
  Plugins.gitsigns:invoke()
  Plugins.nvim_comment:invoke()
  Plugins.nvim_tree:invoke()
  Plugins.cmp_ls:invoke()
  Plugins.toggle_term:invoke()
  Plugins.fidget:invoke()
  Plugins.mini_starter:invoke()
  Plugins.mini_surround:invoke()
  Plugins.trld:invoke()
  Plugins.dirty_talk:invoke()
  Plugins.hover:invoke()

  Lsp.setup:invoke()
  Lang.configure_servers:invoke()
  Lang.setup_treesitter:invoke()
  Lsp.setup_servers:invoke()
  Lsp.install_auto_installable_servers:invoke()

  Lang.setup_plugins:invoke()
  Lang.setup_lang_opts :invoke()

  Statusbar.setup:invoke()

  Bind.setup_plugins:invoke()
end)

local p = {
  plenary = 'nvim-lua/plenary.nvim',
  devicons = 'kyazdani42/nvim-web-devicons',
  treesitter = 'nvim-treesitter/nvim-treesitter',
  gitsigns = 'lewis6991/gitsigns.nvim',
  nui = 'MunifTanjim/nui.nvim',
  telescope = 'nvim-telescope/telescope.nvim',
  lspconfig = 'neovim/nvim-lspconfig',
  cmp = 'hrsh7th/nvim-cmp',
  mini = 'echasnovski/mini.nvim',
}
PluginManager.plugins = {
  -- plugin_manager
  {'wbthomason/packer.nvim'},

  -- themes
  {'rktjmp/lush.nvim'},
  {'marko-cerovac/material.nvim'},

  -- lsp
  p.lspconfig,
  {'williamboman/nvim-lsp-installer',                 requires = p.lspconfig },
  {'b0o/schemastore.nvim',                            requires = p.lspconfig },

  -- lang
  {p.treesitter,                                      run = ':TSUpdate' },
  {'JoosepAlviste/nvim-ts-context-commentstring',     requires = p.treesitter },
  {'SmiteshP/nvim-gps',                               requires = p.treesitter },
  {'lewis6991/spellsitter.nvim'},

  -- plugins
  {'lewis6991/impatient.nvim'},
  {'stevearc/dressing.nvim'},
  {'rcarriga/nvim-notify',                            requires = p.plenary },
  {'lewis6991/hover.nvim'},
  {p.gitsigns,                                        requires = p.plenary },
  {'terrortylor/nvim-comment'},
  {'fedepujol/move.nvim'},
  {p.cmp,                                             requires = {
    {'hrsh7th/cmp-buffer'},
    {'hrsh7th/cmp-path'},
    {'hrsh7th/cmp-nvim-lsp'},
    {'hrsh7th/cmp-nvim-lua'},
    {'f3fora/cmp-spell',                              requires = p.plenary },
    {'saadparwaiz1/cmp_luasnip'},
    {'L3MON4D3/LuaSnip'},
    {'hrsh7th/cmp-nvim-lsp-signature-help'},
    -- {'dmitmel/cmp-digraphs'},
    -- {'hrsh7th/cmp-nvim-lsp-document-symbol'},
    {'hrsh7th/cmp-cmdline'},
  }},
  {'kyazdani42/nvim-tree.lua',                        requires = p.devicons },
  {'ThePrimeagen/harpoon',                            requires = p.plenary },
  {'akinsho/nvim-toggleterm.lua'},
  {'j-hui/fidget.nvim'},
  {'Mofiqul/trld.nvim'},

  -- statusbar
  -- TODO: switch to mini.statusline
  {'famiu/feline.nvim',                               requires = { p.devicons, p.gitsigns }},

  -- sessions
  -- mini.sessions

  -- multiple
  {p.mini,                                            branch = 'stable' },

  -- ls

  -- DEBUGGING
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

  -- -- ts addons

  -- extras
  {'baskerville/vim-sxhkdrc'},
  {'antoinemadec/FixCursorHold.nvim'},                  -- https://github.com/neovim/neovim/issues/12587
  {'psliwka/vim-dirtytalk',                           run = ':DirtytalkUpdate'},


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
}

PluginManager.register_plugins()
