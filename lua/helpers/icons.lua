local M = {}

local icon_sets = {
  diag = {
    nerdfont  = { Error = "", Warn = "", Hint = " ", Info = "" },
    codicons = { Error = "", Warn = "", Hint = " ", Info = "" },
    ascii    = { Error = "E", Warn = "W", Hint = "H", Info = "I" },
  },
  log = {
    nerdfont = {
      debug = " ",
      trace = " ",
    },
  },
  code_action = {
    nerdfont = {
      code_action = "",
      quickfix = "󰖷",
      source = "",
    }
  },
  kind = {
    blink = {
      Text = '󰉿',
      Method = '󰊕',
      Function = '󰊕',
      Constructor = '󰒓',
      --
      Field = '󰜢',
      Variable = '󰆦',
      Property = '󰖷',
      --
      Class = '󱡠',
      Interface = '󱡠',
      Struct = '󱡠',
      Module = '󰅩',
      --
      Unit = '󰪚',
      Value = '󰦨',
      Enum = '󰦨',
      EnumMember = '󰦨',
      --
      Keyword = '󰻾',
      Constant = '󰏿',
      --
      Snippet = '󱄽',
      Color = '󰏘',
      File = '󰈔',
      Reference = '󰬲',
      Folder = '󰉋',
      Event = '󱐋',
      Operator = '󰪚',
      TypeParameter = '󰬛',
    },
    nerdfont = {
      Text          = '',
      Method        = '',
      Function      = '',
      Constructor   = '',
      --
      Field         = '',
      Variable      = '',
      Property      = '',
      --
      Class         = '',
      Interface     = '',
      Struct        = '',
      Module        = '',
      --
      Unit          = '',
      Value         = '',
      Enum          = '',
      EnumMember    = '',
      --
      Keyword       = '',
      Constant      = '',
      --
      Snippet       = '',
      Color         = '',
      File          = '',
      Reference     = '',
      Folder        = '',
      Event         = '',
      Operator      = '',
      TypeParameter = '',
    },
    ascii = {
      Text          = 'txt',
      Method        = 'fun',
      Function      = 'fun',
      Constructor   = 'fun',
      --
      Field         = 'var',
      Variable      = 'var',
      Property      = 'var',
      --
      Class         = 'cls',
      Interface     = 'int',
      Struct        = 'cls',
      Module        = 'mod',
      --
      Unit          = 'val',
      Value         = 'val',
      Enum          = 'val',
      EnumMember    = 'val',
      --
      Keyword       = 'key',
      Constant      = 'con',
      --
      Snippet       = 'snp',
      Color         = 'val',
      File          = 'fil',
      Reference     = 'ref',
      Folder        = 'dir',
      Event         = 'evn',
      Operator      = 'opr',
      TypeParameter = 'typ',
    },
  },
  dap = {
    nerdfont = {
      --   
      breakpoint = '',
      breakpoint_conditional = '',
      breakpoint_rejected = '',
      logpoint = '',
      stoppoint = '',
      stoppoint_active = "",

      terminate = '',
      start = '',
      continue = '',
      pause = '',
      step_back = '',
      step_over = '',
      step_into = '',
      step_out = '',
    },
    ascii = {
      breakpoint = '**',
      breakpoint_conditional = 'c*',
      breakpoint_rejected = 'r*',
      logpoint = 'l*',
      stoppoint = '->',
      stoppoint_active = '=>',

      terminate = '|x',
      start = '|>',
      continue = ']>',
      pause = '||',
      step_back = '<<',
      step_over = '>>',
      step_into = '>.',
      step_out = '<.',
    },
  },
  vcs = {
    nerdfont = {
      untracked   = '',
      modified    = '•',
      staged      = '',
      conflicted  = '',
      renamed     = '',
      deleted     = '',
      ignored     = '󰛑',
    },
    ascii = {
      untracked   = '?',
      modified    = 'M',
      staged      = 'A',
      conflicted  = 'X',
      renamed     = 'R',
      deleted     = 'D',
      ignored     = '!',
    },
  },
  navic = {
    nerdfont = {
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
  copilot = {
    nerdfont = {
      Codeium       = '',
      Copilot       = '',
      CopilotError  = '',
      CopilotWarn   = '',
    },
    ascii = {
      Codeium       = 'codm',
      Copilot       = 'cplt',
      CopilotError  = 'cplt-err',
      CopilotWarn   = 'cplt-wrn',
    },
  },
  misc = {
    nerdfont = {
      user = '',
      sessions = '󱂬',
      record = '󰑊',
      modified = '•',
      spellcheck = '󰓆',
      terminal = '',
      clock = '',
      git_branch = '',
      cogwheel = '',
      search = '',
      package = '',
      ellipsis = '',
      expanded = '',
      collapsed = '',
      letter_case = '󰾹',
    },
  },
}

M.icons = {
  diag = icon_sets.diag.nerdfont,
  log = icon_sets.log.nerdfont,
  code_action = icon_sets.code_action.nerdfont,
  kind = icon_sets.kind.blink,
  dap = icon_sets.dap.nerdfont,
  vcs = icon_sets.vcs.nerdfont,
  navic = icon_sets.navic.nerdfont,
  copilot = icon_sets.copilot.nerdfont,
  misc = icon_sets.misc.nerdfont,
}

return M
