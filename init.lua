--- entry point.
-- @module init

-- all globals must be defined here

U = require 'utils'

Features = U.FeatureList():new()

-- TODO: make it the responsibility of the related service to instantiate events here
Events = {
  enter = U.Event():new(),
  refresh = U.Event():new(),
  clear = U.Event():new(),
  write = U.Event():new(),
  fold_update = U.Event():new(),
  install_post = U.Event():new(),
  install_pre = U.Event():new(),
  configure = U.Event():new(),
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
