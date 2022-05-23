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

PluginManager.attempt_bootstrap:invoke()
PluginManager.setup:invoke()

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
  Misc.buffer_edits:invoke()
  Misc.camel:invoke()

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
  Plugins.devicons:invoke()
  Plugins.dressing:invoke()
  -- Plugins.notify:invoke()
  Plugins.bqf:invoke()
  Plugins.reach:invoke()
  -- Plugins.fzf_lua:invoke()
  Plugins.gitsigns:invoke()
  Plugins.nvim_tree:invoke()
  Plugins.cmp_ls:invoke()
  Plugins.toggle_term:invoke()
  -- Plugins.fidget:invoke()
  Plugins.mini_starter:invoke()
  Plugins.mini_surround:invoke()
  Plugins.dirty_talk:invoke()
  Plugins.hover:invoke()
  Plugins.paperplanes:invoke()
  Plugins.trld:invoke()
  -- Plugins.corn:invoke()
  -- Plugins.cinnamon:invoke()
  -- Plugins.remember:invoke()

  Lang.setup:invoke()
  Lang.configure_servers:invoke()
  Lang.setup_treesitter:invoke()

  Lsp.setup:invoke()
  Lsp.setup_servers:invoke(Lang.lsp_servers_configs)

  Statusbar.setup:invoke()

  Bind.setup_plugins:invoke()


  -- local test_ns = vim.api.nvim_create_namespace('test')
  -- vim.cmd('hi! def Dim guifg=grey')
  --
  -- vim.lsp.handlers['textDocument/publishDiagnostics'] = function(_, result, ctx, config)
  --   local bufnr = vim.uri_to_bufnr(result.uri)
  --   if not bufnr then
  --     return
  --   end
  --   vim.api.nvim_buf_clear_namespace(bufnr, test_ns, 0, -1)
  --   local real_diags = {}
  --   for _, diag in pairs(result.diagnostics) do
  --     if diag.severity == vim.lsp.protocol.DiagnosticSeverity.Hint
  --       and vim.tbl_contains(diag.tags, vim.lsp.protocol.DiagnosticTag.Unnecessary) then
  --       pcall(vim.api.nvim_buf_set_extmark, bufnr, test_ns,
  --         diag.range.start.line, diag.range.start.character, {
  --           end_row = diag.range['end'].line,
  --           end_col = diag.range['end'].character,
  --           hl_group = 'Dim',
  --         })
  --     else
  --       table.insert(real_diags, diag)
  --     end
  --   end
  --   result.diagnostics = real_diags
  --   vim.lsp.diagnostic.on_publish_diagnostics(_, result, ctx, config)
  -- end

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
  -- PLUGIN_MANAGER:
  {'wbthomason/packer.nvim'},

  -- THEMES:
  {'rktjmp/lush.nvim'},
  {'marko-cerovac/material.nvim'},

  -- LSP:
  p.lspconfig,

  -- LANG:
  {p.treesitter,                                      run = ':TSUpdate' },
  {'williamboman/nvim-lsp-installer',                 requires = p.lspconfig },
  {'terrortylor/nvim-comment'},
  {'JoosepAlviste/nvim-ts-context-commentstring',     requires = p.treesitter },
  {'SmiteshP/nvim-gps',                               requires = p.treesitter },
  {'lewis6991/spellsitter.nvim'},
  -- {'andymass/vim-matchup'},
  {'b0o/schemastore.nvim',                            requires = p.lspconfig },

  -- PLUGINS:
  -- mini.*
  {'lewis6991/impatient.nvim'},
  p.devicons,
  {'stevearc/dressing.nvim'},
  {'kevinhwang91/nvim-bqf'},
  -- {'declancm/cinnamon.nvim'},
  -- {'rcarriga/nvim-notify',                            requires = p.plenary },
  {'lewis6991/hover.nvim'},
  {p.gitsigns,                                        requires = p.plenary },
  {'fedepujol/move.nvim'},
  {'rktjmp/paperplanes.nvim',                         branch = 'rel-0.1.2' },
  {'Mofiqul/trld.nvim'},
  -- {'~/sectors/lua/corn.nvim'},
  {'kyazdani42/nvim-tree.lua',                        requires = p.devicons },
  {'toppair/reach.nvim'},
  {'akinsho/nvim-toggleterm.lua'},
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
  --   -- {'hrsh7th/cmp-nvim-lsp-signature-help'},
  --   -- {'hrsh7th/cmp-nvim-lsp-document-symbol'},
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
  {'mfussenegger/nvim-jdtls'},
  {'ibhagwan/fzf-lua',                                requires = p.devicons },

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
}

PluginManager.register_plugins:invoke()
