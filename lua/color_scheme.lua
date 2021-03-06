local M = {}

M.set_hl = function(group_name, opts)

  local hl_opts = {
    fg = opts.fg,
    bg = opts.bg,
    sp = opts.sp,

    bold = opts.bold or false,
    standout = opts.standout or false,
    underline = opts.underline or false,
    undercurl = opts.undercurl or false,
    underdouble = opts.underdouble or false,
    underdotted = opts.underdotted or false,
    underdashed = opts.underdashed or false,
    strikethrough = opts.strikethrough or false,
    italic = opts.italic or false,
    reverse = opts.reverse or false,
    nocombine = opts.nocombine or false,
  }

  if opts.blend ~= nil then hl_opts.blend = M.clamp(opts.blend, 0, 100) end

  if opts[1] ~= nil then hl_opts.link = opts[1] end

  -- • blend: integer between 0 and 100
  -- • link: name of another highlight group to link
  -- to, see |:hi-link|.
  -- • default: Don't override existing definition
  -- |:hi-default|
  -- • ctermfg: Sets foreground of cterm color
  -- |highlight-ctermfg|
  -- • ctermbg: Sets background of cterm color
  -- |highlight-ctermbg|
  -- • cterm: cterm attribute map, like
  -- |highlight-args|. If not set, cterm attributes
  -- will match those from the attribute map
  -- documented above.

  vim.api.nvim_set_hl(0, group_name, hl_opts)
end

M.set_hls = function(hl_table)
  for hl_group, opts in pairs(hl_table) do
    M.set_hl(hl_group, opts)
  end
end


M.clamp = function(n, min, max)
  return math.min(math.max(n, min), max)
end

M.mod = function(hex, amt)
  hex = hex:sub(2)
  local hex_r = hex:sub(1, 2)
  local hex_g = hex:sub(3, 4)
  local hex_b = hex:sub(5, 6)

  local r = tonumber(hex_r, 16)
  local g = tonumber(hex_g, 16)
  local b = tonumber(hex_b, 16)

  r = r + amt
  g = g + amt
  b = b + amt

  r = M.clamp(r, 0, 255)
  g = M.clamp(g, 0, 255)
  b = M.clamp(b, 0, 255)

  local rgb = (r * 0x10000) + (g * 0x100) + b
  return string.format("#%06x", rgb)
end

M.gen_shades = function(col)
  local shades = {}
  for i = 0, 9 do
    local new_col = M.mod(col, i*3)
    table.insert(shades, new_col)
  end
  return shades
end

M.load = function()
  M.set_hls(M.highlights)
end

local green     = M.gen_shades '#1F5E3F'
local white     = M.gen_shades '#C0B9DD'
-- local pink      = M.gen_shades '#E988CF'
local red       = M.gen_shades '#CB4251'
local orange    = M.gen_shades '#F37A2E'
local yellow    = M.gen_shades '#FFBE34'
local lime      = M.gen_shades '#AAD94C'
local cyan      = M.gen_shades '#409FFF'
local blue      = M.gen_shades '#3C4879'
local purple    = M.gen_shades '#4C3889'
local grey      = M.gen_shades '#222A3D'
-- local black     = M.gen_shades '#0D1017'
local black     = M.gen_shades '#07080f'
local debug     = M.gen_shades '#FF00FF'

local c = {
  -- ui
  bg        = black[3],
  line      = black[2],
  bg_alt    = black[1],
  mg        = grey[1],
  fg        = white[1],
  match     = grey[10],
  fold      = grey[8],

  -- general
  err       = red[4],
  info      = cyan[4],
  warn      = yellow[4],
  hint      = purple[4],

  add       = green[1],
  mod       = blue[1],
  del       = red[1],
  mod_alt   = cyan[1],

  -- vsc
  dirty     = green[1],
  staged    = white[1],
  merge     = purple[1],
  renamed   = orange[1],
  deleted   = red[1],

  -- syntax
  comment   = grey[2],
  link      = cyan[3],
  note      = yellow[10],
  value     = red[10],
  variable  = purple[10],
  constant  = red[1],
  func      = yellow[1],
  keyword   = orange[1],
  operator  = orange[10],
  string    = green[10],
  type      = cyan[1],
  include   = lime[10],

  -- special   = yellow[5],
  -- tag       = grey[8],

  -- others
  debug     = debug[1]
}

M.highlights = {

  -- TS
  TSStrike            = { strikethrough = true },
  TSStrong            = { bold = true },
  TSTitle             = { bold = true },
  TSURI               = { underline = true, fg = c.link },
  TSTextReference     = { 'TSURI' },
  TSUnderline         = { underline = true },
  TSEmphasis          = { italic = true },
  TSText              = { fg = c.fg },

  TSComment           = { fg = c.comment },
  TSWarning           = { fg = c.warn },
  TSNote              = { fg = c.note },
  TSTodo              = { fg = c.note },
  TSError             = { fg = c.err },
  TSDanger            = { bg = c.err, fg = c.bg },
  TSDebug             = { fg = c.debug },

  TSNumber            = { fg = c.value },
  TSBoolean           = { 'TSNumber' },
  TSFloat             = { 'TSNumber' },

  TSString            = { fg = c.string },
  TSStringEscape      = { 'TSString' },
  TSStringRegex       = { 'TSString' },
  TSStringSpecial     = { 'TSString' },
  TSCharacter         = { 'TSString' },
  TSCharacterSpecial  = { 'TSString' },
  TSLiteral           = { 'TSString' },

  TSVariable          = { fg = c.variable },
  TSVariableBuiltin   = { 'TSVariable' },
  TSAttribute         = { 'TSVariable' },
  TSField             = { 'TSVariable' },
  TSProperty          = { 'TSVariable' },
  TSTagAttribute      = { 'TSVariable' },
  TSParameter         = { 'TSVariable' },
  TSSymbol            = { 'TSVariable' },

  TSConstant          = { fg = c.constant },
  TSConstBuiltin      = { 'TSConstant' },
  TSConstMacro        = { 'TSConstant' },
  TSEnvironmentName   = { 'TSConstant' },

  TSFunction          = { fg = c.func },
  TSFuncBuiltin       = { 'TSFunction' },
  TSFuncMacro         = { 'TSFunction' },
  TSConstructor       = { 'TSFunction' },
  TSMethod            = { 'TSFunction' },
  TSEnvironment       = { 'TSFunction' },

  TSKeyword           = { fg = c.keyword },
  TSKeywordFunction   = { 'TSKeyword' },
  TSKeywordOperator   = { 'TSKeyword' },
  TSKeywordReturn     = { 'TSKeyword' },
  TSConditional       = { 'TSKeyword' },
  TSRepeat            = { 'TSKeyword' },
  TSTag               = { 'TSKeyword' },
  TSPunctDelimiter    = { 'TSKeyword' },
  TSLabel             = { 'TSKeyword' },
  TSException         = { 'TSKeyword' },

  TSPunctBracket      = { fg = c.operator },
  TSTagDelimiter      = { 'TSPunctBracket' },
  TSOperator          = { 'TSPunctBracket' },
  TSPunctSpecial      = { 'TSPunctBracket' },

  TSInclude           = { fg = c.include },
  TSPreProc           = { 'TSInclude' },
  TSDefine            = { 'TSInclude' },

  TSType              = { fg = c.type },
  TSTypeBuiltin       = { 'TSType' },
  TSTypeDefinition    = { 'TSType' },
  TSTypeQualifier     = { 'TSType' },
  TSStorageClass      = { 'TSType' },
  TSNamespace         = { 'TSType' },

TSMath              = { 'TSDebug' },
TSNone              = { 'TSDebug' },
TSParameterReference= { 'TSDebug' },



  ColorColumn	    = { 'CursorLine' },
Conceal         = { 'TSDebug' },
  CurSearch       = { bg = c.fg, fg = c.bg, bold = true },
  Cursor          = { }, --
  CursorColumn    = { 'CursorLine' }, --
  CursorIM        = { }, --
  CursorLine      = { bg = c.line },
  CursorLineFold  = { 'CursorLine' },
  CursorLineNr    = { 'CursorLine' },
  CursorLineSign  = { 'CursorLine' },
  DiffAdd         = { fg = c.add },
  DiffChange      = { fg = c.mod },
  DiffDelete      = { fg = c.del },
  DiffText        = { fg = c.mod_alt },
  Directory       = { }, --
  EndOfBuffer     = { }, --
  ErrorMsg        = { fg = c.err },
  FoldColumn      = { }, --
  Folded          = { fg = c.fold, bold = true },
  lCursor         = { }, --
  IncSearch       = { 'Search' },
  LineNr          = { fg = c.comment },
  LineNrAbove     = { }, --
  LineNrBelow     = { }, --
  MatchParen      = { bold = true },
  ModeMsg         = { fg = c.fg, bold = true },
  MoreMsg         = { fg = c.info },
  MsgArea         = { fg = c.match },
  MsgSeparator    = { bg = c.bg, fg = c.mg },
NonText         = { 'TSDebug' },
  Normal          = { bg = c.bg },
  NormalFloat     = { }, --
  NormalNC        = { }, --
  Pmenu           = { bg = c.line, fg = c.fg },
  PmenuSel        = { bg = c.mg, fg = c.fg },
  PmenuSbar       = { 'Pmenu' },
  PmenuThumb      = { bg = c.fg },
  Question        = { fg = c.fg, bold = true },
  QuickFixLine    = { 'PmenuSel' },
  Search          = { bg = c.match, fg = c.bg, bold = true },
  SignColumn      = { }, --
  SpecialKey      = { fg = c.fold },
  SpellBad        = { undercurl = true, sp = c.err },
  SpellCap        = { }, --
  SpellLocal      = { }, --
  SpellRare       = { }, --
-- StatusLine      = { bg = c.debug }, --
  StatusLine      = { }, --
  StatusLineNC    = { reverse = true },
  Substitute      = { 'CurSearch' },
  TabLine         = { fg = c.fold },
  TabLineFill     = { bg = c.bg_alt },
  TabLineSel      = { }, --
  TermCursor      = { underline = true },
  TermCursorNC    = { 'TermCursor' },
  Title           = { 'TSTitle' },
  Visual          = { bg = c.fold, bold = true },
  VisualNOS       = { }, --
  WarningMsg      = { fg = c.warn },
Whitespace      = { 'TSDebug' },
  WildMenu        = { 'Pmenu' },
  WinBar          = { }, --
  WinBarNC        = { }, --
  WinSeparator    = { fg = c.mg },

  -- DEPRECATED
  VertSplit       = { 'WinSeparator' },
  FloatTitle      = { 'TSTitle' };


  
  -- LSP
  LspReferenceText            = { bold = true };
  LspReferenceRead            = { bold = true };
  LspReferenceWrite           = { bold = true };
LspCodeLens                 = { 'Debug' },
LspCodeLensSeparator        = { 'Debug' },
  LspSignatureActiveParameter = { underline = true, bold = true },


  
  -- Diagnostics
  DiagnosticError             = { fg = c.err },
  DiagnosticWarn              = { fg = c.warn },
  DiagnosticInfo              = { fg = c.info },
  DiagnosticHint              = { fg = c.hint },
  DiagnosticVirtualTextError  = { 'DiagnosticError' },
  DiagnosticVirtualTextWarn   = { 'DiagnosticWarn' },
  DiagnosticVirtualTextInfo   = { 'DiagnosticInfo' },
  DiagnosticVirtualTextHint   = { 'DiagnosticHint' },
  DiagnosticUnderlineError    = { undercurl = true, sp = c.err },
  DiagnosticUnderlineWarn     = { undercurl = true, sp = c.warn },
  DiagnosticUnderlineInfo     = { undercurl = true, sp = c.info },
  DiagnosticUnderlineHint     = { undercurl = true, sp = c.hint },
  DiagnosticFloatingError     = { 'DiagnosticError' },
  DiagnosticFloatingWarn      = { 'DiagnosticWarn' },
  DiagnosticFloatingInfo      = { 'DiagnosticInfo' },
  DiagnosticFloatingHint      = { 'DiagnosticHint' },
  DiagnosticSignError         = { 'DiagnosticError' },
  DiagnosticSignWarn          = { 'DiagnosticWarn' },
  DiagnosticSignInfo          = { 'DiagnosticInfo' },
  DiagnosticSignHint          = { 'DiagnosticHint' },



  -- Vim
  Comment        = { 'TSComment' },
  Constant       = { 'TSConstant' },
  String         = { 'TSString' },
  Character      = { 'TSCharacter' },
  Number         = { 'TSNumber' },
  Boolean        = { 'TSBoolean' },
  Float          = { 'TSFloat' },
  Identifier     = { 'TSVariable' },
  Function       = { 'TSFunction' },
  Statement      = { 'TSKeyword' },
  Keyword        = { 'TSKeyword' },
  Conditional    = { 'TSConditional' },
  Repeat         = { 'TSRepeat' },
  Label          = { 'TSLabel' },
  Operator       = { 'TSOperator' },
  Exception      = { 'TSException' },     --
  Include        = { 'TSInclude' },
  PreProc        = { 'TSPreProc' },
  Macro          = { 'TSPreProc' },       --
  PreCondit      = { 'TSPreProc' },
  Define         = { 'TSDefine' },
  Type           = { 'TSType' },
  StorageClass   = { 'TSStorageClass' },
  Structure      = { 'TSTypeBuiltin' },   --
  Typedef        = { 'TSTypeDefinition' },
  Special        = { 'TSStringSpecial' },
  SpecialChar    = { 'TSCharacterSpecial' },
  Tag            = { 'TSTag' },
  Delimiter      = { 'TSPunctDelimiter' },
  SpecialComment = { 'TSNote' },
  Debug          = { 'TSDebug' },
  Underlined     = { 'TSUnderline' },
  Error          = { 'TSError' },
Ignore         = { 'TSDebug' },         --
  Todo           = { 'TSTodo' },
 


  -- Plugins
  -- diff
  diffAdded               = { fg = c.add };
  diffChanged             = { fg = c.mod };
  diffRemoved             = { fg = c.del };
  diffOldFile             = { bg = c.del };
  diffNewFile             = { bg = c.add };
  diffFile                = { fg = c.comment };
  diffLine                = { fg = c.fg };
  diffIndexLine           = { fg = c.comment };

  -- gitsigns
  GitSignsAdd             = { fg = c.add };
  GitSignsAddNr           = { fg = c.add };
  GitSignsAddLn           = { fg = c.add };
  GitSignsChange          = { fg = c.mod };
  GitSignsChangeNr        = { fg = c.mod };
  GitSignsChangeLn        = { fg = c.mod };
  GitSignsDelete          = { fg = c.del };
  GitSignsDeleteNr        = { fg = c.del };
  GitSignsDeleteLn        = { fg = c.del };

  -- cmp
  CmpItemAbbr             = { fg = c.fold };
  CmpItemAbbrDeprecated   = { fg = c.fold, strikethrough = true };
  CmpItemAbbrMatch        = { fg = c.fg, bold = true };
  CmpItemAbbrMatchFuzzy   = { fg = c.fg };
  CmpItemKind             = { };
  CmpItemMenu             = { fg = c.comment  };
  CmpItemKindText         = { fg = c.fg       };
  CmpItemKindMethod       = { fg = c.func     };
  CmpItemKindFunction     = { fg = c.func     };
  CmpItemKindConstructor  = { fg = c.special  };
  CmpItemKindField        = { fg = c.entity   };
  CmpItemKindVariable     = { fg = c.keyword  };
  CmpItemKindClass        = { fg = c.type     };
  CmpItemKindInterface    = { fg = c.type     };
  CmpItemKindModule       = { fg = c.special  };
  CmpItemKindProperty     = { fg = c.entity   };
  CmpItemKindUnit         = { fg = c.keyword  };
  CmpItemKindValue        = { fg = c.string   };
  CmpItemKindEnum         = { fg = c.keyword  };
  CmpItemKindKeyword      = { fg = c.keyword  };
  CmpItemKindSnippet      = { fg = c.constant };
  CmpItemKindColor        = { fg = c.string   };
  CmpItemKindFile         = { fg = c.fg       };
  CmpItemKindReference    = { fg = c.entity   };
  CmpItemKindFolder       = { fg = c.fg       };
  CmpItemKindEnumMember   = { fg = c.string   };
  CmpItemKindConstant     = { fg = c.constant };
  CmpItemKindStruct       = { fg = c.string   };
  CmpItemKindEvent        = { fg = c.special  };
  CmpItemKindOperator     = { fg = c.operator };
  CmpItemKindTypeParameter= { fg = c.type     };

  -- scrollview
  ScrollView              = { bg = c.mg };

  -- scrollbar
  ScrollbarHandle         = { 'ScrollView' };
  ScrollbarSearchHandle   = { bg = c.mg, fg = c.fg };
  ScrollbarSearch         = { fg = c.fg };
  ScrollbarErrorHandle    = { bg = c.mg, fg = c.err };
  ScrollbarError          = { fg = c.err };
  ScrollbarWarnHandle     = { bg = c.mg, fg = c.warn };
  ScrollbarWarn           = { fg = c.warn };
  ScrollbarInfoHandle     = { bg = c.mg, fg = c.info };
  ScrollbarInfo           = { fg = c.info };
  ScrollbarHintHandle     = { bg = c.mg, fg = c.hint };
  ScrollbarHint           = { fg = c.hint };
  ScrollbarMiscHandle     = { bg = c.mg, fg = c.fg };
  ScrollbarMisc           = { fg = c.fg };

  -- nvim-tree
  -- NvimTreeNormal          = { bg = c.bg_alt };
  NvimTreeRootFolder      = { fg = c.fg };
  NvimTreeFolderIcon      = { fg = c.fg };
  NvimTreeFileIcon        = { fg = c.fg };
  NvimTreeSpecialFile     = { fg = c.fg };
  NvimTreeExecFile        = { bold = true };
  NvimTreeIndentMarker    = { fg = c.mg };
  NvimTreeOpenedFile      = { fg = c.fg };
  NvimTreeGitDirty        = { fg = c.dirty };
  NvimTreeGitStaged       = { fg = c.staged, gui = 'bold' };
  NvimTreeGitMerge        = { fg = c.merge };
  NvimTreeGitRenamed      = { fg = c.renamed };
  NvimTreeGitDeleted      = { fg = c.deleted };
  NvimTreeLspDiagnosticsError       = { 'DiagnosticSignError' };
  NvimTreeLspDiagnosticsWarning     = { 'DiagnosticSignWarn' };
  NvimTreeLspDiagnosticsInformation = { 'DiagnosticSignInfo' };
  NvimTreeLspDiagnosticsHint        = { 'DiagnosticSignHint' };

  -- vim-quickui
  QuickBG                 = { bg = c.bg, fg = c.fg };
  QuickSel                = { 'Search' };
  QuickKey                = { fg = c.err };
  QuickOff                = { fg = c.mg };
  QuickHelp               = { 'WarningMsg' };

  -- outline
  FocusedSymbol           = { 'Search' };
  SymbolsOutlineConnector = { fg = c.mg };

  -- telescope
  TelescopeBorder         = { fg = c.mg };
  TelescopeTitle          = { 'Title' };
  TelescopeMatching       = { 'Search' };

  -- harpoon
  HarpoonBorder           = { 'WinSeparator' };

  -- startup-time
  StartupTimeStartupKey   = { bold = true };
  StartupTimeStartupValue = { bold = true };
  StartupTimeHeader       = { 'Comment' };
  StartupTimeSourcingEvent= { fg = cyan[5] };
  StartupTimeOtherEvent   = { fg = purple[5] };
  StartupTimeTime         = { fg = red[5] };
  StartupTimePercent      = { fg = red[5] };
  StartupTimePlot         = { fg = red[1] };

  -- notify
  NotifyERRORBorder       = { 'DiagnosticVirtualTextError' };
  NotifyWARNBorder        = { 'DiagnosticVirtualTextWarn' };
  NotifyINFOBorder        = { 'DiagnosticVirtualTextInfo' };
  NotifyTRACEBorder       = { 'DiagnosticFloatingHint' };
  NotifyDEBUGBorder       = { 'DiagnosticVirtualTextHint' };
  NotifyERRORIcon         = { fg = c.fg };
  NotifyWARNIcon          = { fg = c.fg };
  NotifyINFOIcon          = { fg = c.fg };
  NotifyDEBUGIcon         = { fg = c.fg };
  NotifyTRACEIcon         = { fg = c.fg };
  NotifyERRORTitle        = { 'NotifyERRORBorder', bold = true};
  NotifyWARNTitle         = { 'NotifyWARNBorder',  bold = true};
  NotifyINFOTitle         = { 'NotifyINFOBorder',  bold = true};
  NotifyDEBUGTitle        = { 'NotifyDEBUGBorder', bold = true};
  NotifyTRACETitle        = { 'NotifyTRACEBorder', bold = true};
  NotifyERRORBody         = { 'Normal' };
  NotifyWARNBody          = { 'Normal' };
  NotifyINFOBody          = { 'Normal' };
  NotifyDEBUGBody         = { 'Normal' };
  NotifyTRACEBody         = { 'Normal' };

  -- ultest
  UltestPass              = { fg = c.add };
  UltestFail              = { fg = c.err };
  UltestRunning           = { fg = c.warn };
  UltestBorder            = { fg = c.mg };
  UltestSummaryInfo       = { fg = c.fold };
  UltestSummaryFile       = { 'UltestSummaryInfo', gui = 'bold'};
  UltestSummaryNamespace  = { 'UltestSummaryFile' };

  -- reach
  ReachBorder             = { 'WinSeparator' };
  ReachDirectory          = { 'Directory' };
  ReachModifiedIndicator  = { 'String' };
  ReachHandleBuffer       = { 'String' };
  ReachHandleDelete       = { 'Error' };
  ReachHandleSplit        = { 'Directory' };
  ReachTail               = { 'Normal' };
  ReachHandleMarkLocal    = { 'Type' };
  ReachHandleMarkGlobal   = { 'Number' };
  ReachMark               = { 'Normal' };
  ReachMarkLocation       = { 'Comment' };
  ReachHandleTabpage      = { 'TabLineSel' };
  ReachGrayOut            = { 'Comment' };
  ReachMatchExact         = { 'String' };
  ReachPriority           = { 'WarningMsg' };
  ReachCurrent            = { 'Folded', gui = 'bold' };

  -- navic
  NavicIconsFile          = { 'CmpItemKindFile' };
  NavicIconsModule        = { 'CmpItemKindModule' };
  NavicIconsNamespace     = { 'CmpItemKindModule' };
  NavicIconsPackage       = { 'CmpItemKindModule' };
  NavicIconsClass         = { 'CmpItemKindClass' };
  NavicIconsMethod        = { 'CmpItemKindMethod' };
  NavicIconsProperty      = { 'CmpItemKindProperty' };
  NavicIconsField         = { 'CmpItemKindField' };
  NavicIconsConstructor   = { 'CmpItemKindConstructor' };
  NavicIconsEnum          = { 'CmpItemKindEnum' };
  NavicIconsInterface     = { 'CmpItemKindInterface' };
  NavicIconsFunction      = { 'CmpItemKindFunction' };
  NavicIconsVariable      = { 'CmpItemKindVariable' };
  NavicIconsConstant      = { 'CmpItemKindConstant' };
  NavicIconsString        = { 'CmpItemKindValue' };
  NavicIconsNumber        = { 'CmpItemKindValue' };
  NavicIconsBoolean       = { 'CmpItemKindValue' };
  NavicIconsArray         = { 'CmpItemKindValue' };
  NavicIconsObject        = { 'CmpItemKindValue' };
  NavicIconsKey           = { 'CmpItemKindProperty' };
  NavicIconsNull          = { 'CmpItemKindConstant' };
  NavicIconsEnumMember    = { 'CmpItemKindEnumMember' };
  NavicIconsStruct        = { 'CmpItemKindStruct' };
  NavicIconsEvent         = { 'CmpItemKindEvent' };
  NavicIconsOperator      = { 'CmpItemKindOperator' };
  NavicIconsTypeParameter = { 'CmpItemKindTypeParameter' };
  NavicText               = { 'CmpItemKindText' };
  NavicSeparator          = { 'Folded' };

  -- CUTSOM GROUPS
  -- DebugFg                 = { fg = debug[10] };
  -- DebugBg                 = { bg = debug[1] };
  -- DebugAll                = { bg = debug[1], fg = debug[10] };
  -- NormalAlt               = { bg = c.bg_alt };
  SnippetPassiveIndicator = { 'Comment' };
  SnippetInsertIndicator  = { fg = c.fg };
  SnippetChoiceIndicator  = { fg = c.hint };
  CursorLineSelect        = { fg = c.fg, bg = c.line, bold = true },
  Camel                   = { 'WarningMsg' };

  ModeNormal              = { fg = c.mg, bold = true };
  ModeInsert              = { fg = c.del, bold = true };
  ModeVisual              = { fg = c.add, bold = true };
  ModeControl             = { fg = c.warn, bold = true };
  ModeSelect              = { fg = c.add, bold = true };
  ModeTerminal            = { fg = c.type, bold = true };
}

return M
