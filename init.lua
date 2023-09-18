local U = require 'utils'

service = U.service
feat_list = U.FeatureList():new()

events = {}
events.enter = U.Event("enter"):new()
events.refresh = U.Event("refresh"):new()
events.clear = U.Event("clear"):new()
events.write = U.Event("write"):new()
events.fold_update = U.Event("fold_update"):new()
events.fs_update = U.Event("fs_update"):new()

local icon_sets = require 'icons'.icon_sets
icons = {
  diag = icon_sets.diag.codicons,
  lsp = icon_sets.lsp.codicons,
  dap = icon_sets.dap.nerdfont,
  vcs = icon_sets.vcs.ascii,
  navic = icon_sets.navic.codicons,
  misc = icon_sets.misc.nerdfont,
}

-- initializing logger
log = require 'logger'.log

-- setting default colorscheme
default_colorscheme = 'venom'

-- Loading Modules
require 'options'
require 'module_loader'

-- invoke enter event on VimEnter
vim.api.nvim_create_autocmd({ 'VimEnter' }, { callback = events.enter:wrap() })
