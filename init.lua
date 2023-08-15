U = require 'utils'
service = U.service

Features = U.FeatureList():new()

default_colorscheme = 'venom'
-- TODO: make it the responsibility of the related service to instantiate events here
Events = {
  enter = U.Event("enter"):new(),
  refresh = U.Event("refresh"):new(),
  clear = U.Event("clear"):new(),
  write = U.Event("write"):new(),
  buflist_update = U.Event("buflist_update"):new(),
  fold_update = U.Event("fold_update"):new(),
  fs_update = U.Event("fs_update"):new(),
  install_pre = U.Event("install_pre"):new(),
  install_post = U.Event("install_post"):new(),
  session_write_pre = U.Event("session_write_pre"):new(),
  plugin_setup = U.Event("plugin_setup"):new(),
}

local icon_sets = require 'icons'.icon_sets
Icons = {
  diagnostic_states = icon_sets.diagnostic_states.codicons,
  item_kinds = icon_sets.item_kinds.codicons,
  debugging = icon_sets.ui.codicons,
}

--- feature types enum
FT = {
  PLUGIN = "PLUGIN",
  CONF = "CONF",
  KEY = "KEY",
  LANG = "LANG",
  LSP = "LSP",
  SESSION = "SESSION",
}

-- initializing logger
log = require 'logger'.log

-- Loading Modules
require 'options'
require 'service_loader'

-- invoke enter event on VimEnter
vim.api.nvim_create_autocmd({ 'VimEnter' }, { callback = Events.enter:wrap() })
