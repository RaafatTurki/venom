--- entry point.
-- @module init

-- all globals are defined here

-- utils
U = require 'utils'

-- icons collection
local icon_sets = {
  --   
  diagnostic_states = {
    outline = { Error = " ", Warn = " ", Hint = " ", Info = " " },
    full    = { Error = " ", Warn = " ", Hint = " ", Info = " " },
    cozette = { Error = " ", Warn = " ", Hint = " ", Info = " " },
    letters = { Error = "E ", Warn = "W ", Hint = "H ", Info = "I " },
    none    = { Error = "  ", Warn = "  ", Hint = "  ", Info = "  " },
  },
  item_kinds = {
    -- ⌂ θ ғ  Ω
    cozette = {
      Text          = '',
      Method        = '',
      Function      = '',
      Constructor   = '',
      Field         = 'ﴲ',
      Variable      = '',
      Class         = '',
      Interface     = 'ﰮ',
      Module        = '',
      Property      = '',
      Unit          = '',
      Value         = '',
      Enum          = '',
      Keyword       = '',
      Snippet       = '',
      Color         = '',
      File          = '',
      Reference     = '',
      Folder        = '',
      EnumMember    = '',
      Constant      = '',
      Struct        = 'ﳤ',
      Event         = '',
      Operator      = '',
      TypeParameter = '',

      Namespace = '',
      Package   = '',
      String    = '',
      Number    = '',
      Boolean   = '✓',
      Array     = '',
      Object    = '',
      Key       = '',
      Null      = '⌀',
    },
    codicons = {
      Text          = ' ',
      Method        = ' ',
      Function      = ' ',
      Constructor   = ' ',
      Field         = ' ',
      Variable      = ' ',
      Class         = ' ',
      Interface     = ' ',
      Module        = ' ',
      Property      = ' ',
      Unit          = ' ',
      Value         = ' ',
      Enum          = ' ',
      Keyword       = ' ',
      Snippet       = ' ',
      Color         = ' ',
      File          = ' ',
      Reference     = ' ',
      Folder        = ' ',
      EnumMember    = ' ',
      Constant      = ' ',
      Struct        = ' ',
      Event         = ' ',
      Operator      = ' ',
      TypeParameter = ' ',

      Namespace = '',
      Package   = '',
      String    = '',
      Number    = '',
      Boolean   = '',
      Array     = '',
      Object    = '',
      Key       = '',
      Null      = '',
    },
    nerdfont = {
      Text          = '',
      Method        = '',
      Function      = '',
      Constructor   = '',
      Field         = 'ﴲ',
      Variable      = '',
      Class         = '',
      Interface     = 'ﰮ',
      Module        = '',
      Property      = '襁',
      Unit          = '',
      Value         = '',
      Enum          = '',
      Keyword       = '',
      Snippet       = '',
      Color         = '',
      File          = '',
      Reference     = '',
      Folder        = '',
      EnumMember    = '',
      Constant      = '',
      Struct        = 'ﳤ',
      Event         = '',
      Operator      = '',
      TypeParameter = '',

      Namespace = '',
      Package   = '',
      String    = '',
      Number    = '',
      Boolean   = '◩',
      Array     = '',
      Object    = '',
      Key       = '',
      Null      = 'ﳠ',
    },
  },
  ui = {
    codicons = {
      breakpoint = '',
      expanded = '',
      collapsed = '',
    }
  },
}

-- venom options
venom = {
  -- a table containing key-value pairs to persist per session
  -- persistent = {},
  -- events are tables that can hold lua functions and vim commands for later execution (when invoked)
  -- TODO: make it the responsibility of the related service to instantiate events here
  events = {
    enter = U.Event():new(),
    refresh = U.Event():new(),
    clear = U.Event():new(),
    write = U.Event():new(),
    fold_update = U.Event():new(),
  },
  -- features is a table that can hold strings representing the availability of said feature for later querying.
  -- each string must be in the form of <TYPE>:<name> where TYPE is one of the FT enum values (for example "PLUGIN:nvim-cmp" means the plugin cmp is available)
  features = U.FeatureList():new(),
  icons = {
    diagnostic_states = icon_sets.diagnostic_states.full,
    item_kinds = icon_sets.item_kinds.codicons,
    debugging = icon_sets.ui.codicons,
  },
}

--- feature types enum
FT = {
  PLUGIN = "PLUGIN",
  KEY = "KEY",
  THEME = "THEME",
  MISC = "MISC",
  BIN = "BIN",
  FUNC = "FUNC",
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
vim.api.nvim_create_autocmd({ 'VimEnter' }, { callback = venom.events.enter:wrap() })
