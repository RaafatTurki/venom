U = require 'utils'

service = U.service
feat_list = U.FeatureList():new()

event = {}
event.enter = U.Event("enter"):new()
event.refresh = U.Event("refresh"):new()
event.clear = U.Event("clear"):new()
event.write = U.Event("write"):new()
event.fold_update = U.Event("fold_update"):new()
event.fs_update = U.Event("fs_update"):new()

local icon_sets = require 'icons'.icon_sets
icons = {
  diagnostic_states = icon_sets.diagnostic_states.codicons,
  item_kinds = icon_sets.item_kinds.codicons,
  debugging = icon_sets.ui.codicons,
}

-- initializing logger
log = require 'logger'.log

-- setting default colorscheme
default_colorscheme = 'venom'

-- Loading Modules
require 'options'
require 'service_loader'

-- invoke enter event on VimEnter
vim.api.nvim_create_autocmd({ 'VimEnter' }, { callback = event.enter:wrap() })
