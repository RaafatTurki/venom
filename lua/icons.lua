local M = {}

-- icons collection
M.icon_sets = {
  diag = {
    cozette  = { Error = "", Warn = "", Hint = "", Info = "" },
    codicons = { Error = "", Warn = "", Hint = "", Info = "" },
    ascii    = { Error = "E", Warn = "W", Hint = "H", Info = "I" },
  },
  lsp = {
    codicons = {
      Text          = '',
      Method        = '',
      Function      = '',
      Constructor   = '',
      Field         = '',
      Variable      = '',
      Class         = '',
      Interface     = '',
      Module        = '',
      Property      = '',
      Unit          = '',
      Value         = '',
      Enum          = '',
      Keyword       = '',
      Snippet       = '',
      Color         = '',
      File          = '',
      Reference     = '',
      Folder        = '',
      EnumMember    = '',
      Constant      = '',
      Struct        = '',
      Event         = '',
      Operator      = '',
      TypeParameter = '',
    },
    ascii = {
      Text          = 'txt',
      Method        = 'fun',
      Function      = 'fun',
      Constructor   = 'fun',
      Field         = 'var',
      Variable      = 'var',
      Class         = 'cls',
      Interface     = 'int',
      Module        = 'mod',
      Property      = 'var',
      Unit          = 'val',
      Value         = 'val',
      Enum          = 'val',
      Keyword       = 'key',
      Snippet       = 'snp',
      Color         = 'val',
      File          = 'fil',
      Reference     = 'ref',
      Folder        = 'dir',
      EnumMember    = 'val',
      Constant      = 'con',
      Struct        = 'cls',
      Event         = 'evn',
      Operator      = 'opr',
      TypeParameter = 'typ',
    },
  },
  dap = {
    codicons = {
      breakpoint = '',
      breakpoint_conditional = '',
      breakpoint_rejected = '',
      logpoint = '',
      stoppoint = '', --'→'
    },
    ascii = {
      breakpoint = '**',
      breakpoint_conditional = 'c*',
      breakpoint_rejected = 'r*',
      logpoint = 'l*',
      stoppoint = '->',
    },
  },
  vcs = {
    ascii = {
      untracked = "??",
      modified = "M",
      staged = "A",
      conflicted = "CONF",
      renamed = "R",
      deleted = "D",
      ignored = "!!",
    }
  },
  navic = {
    codicons = {
      Namespace = '',
      Package   = '',
      String    = '',
      Number    = '',
      Boolean   = '',
      Array     = '',
      Object    = '',
      Key       = '',
      Null      = '',
    },
    ascii = {
      Namespace = 'nsp',
      Package   = 'pkg',
      String    = 'str',
      Number    = 'num',
      Boolean   = 'bol',
      Array     = 'arr',
      Object    = 'obj',
      Key       = 'key',
      Null      = 'nil',
    },
  },
  -- TODO: WIP
  fs = {
    some_icon_set = {
      file = '',
      dir = '',
      dir_open = '',
      dir_empty = '',
      dir_empty_open = '',
      symlink = '',
      symlink_open = '',
      symlink_empty = '',
      symlink_empty_open = '',
    },
    ascii = {
    }
  },
  common = {
    some_icon_set = {
      arrow_left = '',
      arrow_right = '',
      arrow_up = '',
      arrow_down = '',
      dot = '',
      big_dot = '',
      tree_start = '│',
      tree_stem = '│',
      tree_branch = '├',
      tree_end = '└',
    }
  },
}

return M
