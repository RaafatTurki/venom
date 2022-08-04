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

PluginManager.setup()

local p = {
  plenary = 'nvim-lua/plenary.nvim',
  devicons = 'kyazdani42/nvim-web-devicons',
  treesitter = 'nvim-treesitter/nvim-treesitter',
  gitsigns = 'lewis6991/gitsigns.nvim',
  nui = 'MunifTanjim/nui.nvim',
  lspconfig = 'neovim/nvim-lspconfig',
  cmp = 'hrsh7th/nvim-cmp',
  mini = 'echasnovski/mini.nvim',
  fixcusrorhold = 'antoinemadec/FixCursorHold.nvim',
  keymap_amend = 'anuvyklack/keymap-amend.nvim',
}
local plugins = {
  -- PLUGIN_MANAGER:
  {'wbthomason/packer.nvim'},

  -- LSP:
  p.lspconfig,
  {'lewis6991/hover.nvim'},
  {'smjonas/inc-rename.nvim'},
  {'RRethy/vim-illuminate'},

  -- LANG:
  p.treesitter,
  {'williamboman/mason.nvim',                         requires = {
    p.lspconfig,
    'williamboman/mason-lspconfig.nvim',
  }},
  {'numToStr/Comment.nvim'},
  {'JoosepAlviste/nvim-ts-context-commentstring',     requires = p.treesitter },
  {'SmiteshP/nvim-navic',                             requires = p.lspconfig },
  {'lewis6991/spellsitter.nvim'},
  {'b0o/schemastore.nvim',                            requires = p.lspconfig },
  {'nvim-neotest/neotest',                            requires = {
    p.plenary,
    p.treesitter,
    p.fixcusrorhold,
    {'nvim-neotest/neotest-go'},
    {'haydenmeade/neotest-jest'},
  }},

  -- PLUGINS:
  -- mini.*
  {'lewis6991/impatient.nvim'},
  p.devicons,
  p.fixcusrorhold,
  {'stevearc/dressing.nvim'},
  {'kevinhwang91/nvim-bqf'},
  {p.gitsigns,                                        requires = p.plenary },
  {'booperlv/nvim-gomove'},
  {'rktjmp/paperplanes.nvim',                         branch = 'rel-0.1.2' },
  {'Mofiqul/trld.nvim'},
  {'kyazdani42/nvim-tree.lua',                        requires = p.devicons },
  {'toppair/reach.nvim'},
  {'akinsho/bufferline.nvim',                         requires = p.devicons,  tag = "v2.*" },
  {'akinsho/nvim-toggleterm.lua'},
  {'ibhagwan/fzf-lua',                                requires = p.devicons },
  {'jghauser/fold-cycle.nvim'},
  {'Issafalcon/lsp-overloads.nvim'},
  {'anuvyklack/fold-preview.nvim',                    requires = p.keymap_amend },
  {'NMAC427/guess-indent.nvim'},
  {'j-hui/fidget.nvim'},
  {p.cmp,                                             requires = {
    {'lukas-reineke/cmp-rg'},
    {'hrsh7th/cmp-path'},
    {'hrsh7th/cmp-nvim-lsp'},
    {'hrsh7th/cmp-nvim-lua'},
    {'f3fora/cmp-spell',                              requires = p.plenary },
    {'saadparwaiz1/cmp_luasnip'},
    {'L3MON4D3/LuaSnip'},
    {'hrsh7th/cmp-cmdline'},
    -- {'hrsh7th/cmp-buffer'},
    -- {'dmitmel/cmp-digraphss'},
    -- {'hrsh7th/cmp-nvim-lsp-signature-help'},
    -- {'hrsh7th/cmp-nvim-lsp-document-symbol'},
  }},

  -- STATUSBAR:
  {'rebelot/heirline.nvim',                           requires = { p.devicons, p.gitsigns }},

  -- SESSIONS:
  -- mini.sessions

  -- MULTI_PURPOSE:
  {p.mini},

  -- DEBUGGING:
  {'nvim-treesitter/playground',                      requires = p.treesitter },

  -- UNCHARTED:
  {'baskerville/vim-sxhkdrc'},
  {'psliwka/vim-dirtytalk',                           run = ':DirtytalkUpdate'},
  {'mfussenegger/nvim-jdtls'},
  {'ron-rs/ron.vim'},
  {'RRethy/vim-hexokinase',                           run = 'make hexokinase'},
 
  -- themes -- for more ts supported colorschemes https://github.com/rockerBOO/awesome-neovim#colorscheme
  -- THEMES:

  -- {'terrortylor/nvim-comment'}, 
  -- {'declancm/cinnamon.nvim'},
  -- {'rcarriga/nvim-notify',                            requires = p.plenary },
  -- {'~/sectors/lua/corn.nvim'},
  -- {'iamcco/markdown-preview.nvim',                    config = 'vim.call("mkdp#util#install")'},
  -- {'NTBBloodbath/rest.nvim',                          requires = p.plenary },
  -- {'RaafatTurki/vim-quickui'},
  -- {'karb94/neoscroll.nvim'},
  -- {p.telescope,                                       requires = p.plenary },
  -- {'kosayoda/nvim-lightbulb'},
  -- {'dstein64/nvim-scrollview'},
  -- {'rcarriga/vim-ultest',                             requires = 'vim-test/vim-test', run = ':UpdateRemotePlugins' },
  -- {'ThePrimeagen/harpoon',                            requires = p.plenary },
  -- {'tiagovla/scope.nvim'},
  -- {'kevinhwang91/nvim-ufo',                           requires = 'kevinhwang91/promise-async' },
  -- {'smjonas/snippet-converter.nvim'},
  -- {'vladdoster/remember.nvim'},
  -- {'williamboman/nvim-lsp-installer',                 requires = p.lspconfig },
  -- {'https://git.sr.ht/~whynothugo/lsp_lines.nvim'},
  -- {'rktjmp/lush.nvim'},
  -- {'marko-cerovac/material.nvim'},
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

PluginManager.event_post_complete:sub(function()
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
  Misc.lspinfo_win_fix()

  Themes.init({
    { func = Themes.builtin,  args = {},             name = 'Built-In'},
    -- { func = Themes.material, args = 'darker',       name = 'Material Darker'},
    -- { func = Themes.material, args = 'lighter',      name = 'Material Lighter'},
    -- { func = Themes.material, args = 'deep ocean',   name = 'Material Deep Ocean'},
    -- { func = Themes.material, args = 'oceanic',      name = 'Material Oceanic'},
    -- { func = Themes.material, args = 'palenight',    name = 'Material Pale Night'},
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
  Plugins.fidget()
  Plugins.mini_starter()
  Plugins.mini_surround()
  Plugins.dirty_talk()
  Plugins.hover()
  Plugins.paperplanes()
  Plugins.trld()
  Plugins.fold_cycle()
  Plugins.fold_preview()
  Plugins.guess_indent()
  -- Plugins.icon_picker()
  -- Plugins.corn()
  -- Plugins.cinnamon()
  -- Plugins.remember()

  Lang.setup()

  Lsp.setup()
  Lsp.setup_servers()

  Statusbar.setup()

  Bind.setup_plugins()
end)

PluginManager.setup_plugins(plugins)
