local U = require 'utils'

service = U.service
feat_list = U.FeatureList():new()

events = {
  enter = U.Event("enter"):new(),
  refresh = U.Event("refresh"):new(),
  clear = U.Event("clear"):new(),
  write = U.Event("write"):new(),
  fold_update = U.Event("fold_update"):new(),
  fs_update = U.Event("fs_update"):new(),
  git_merge_mode = U.Event("git_merge_mode"):new(),
}

local icon_sets = require 'icons'.icon_sets
icons = {
  diag = icon_sets.diag.codicons,
  lsp = icon_sets.lsp.nerdfont,
  code_action = icon_sets.code_action.nerdfont,
  kind = icon_sets.kind.codicons,
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
