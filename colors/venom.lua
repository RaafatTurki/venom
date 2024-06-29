
-- utils
local clamp = function(n, min, max)
  return math.min(math.max(n, min), max)
end

local mod = function(hex, amt)
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

  r = clamp(r, 0, 255)
  g = clamp(g, 0, 255)
  b = clamp(b, 0, 255)

  local rgb = (r * 0x10000) + (g * 0x100) + b
  return string.format("#%06x", rgb)
end

local mix = function(color1, color2, weight1, weight2)
  color1 = string.sub(color1, 2)
  color2 = string.sub(color2, 2)
  -- convert hex colors to decimal values
  local r1, g1, b1 = tonumber("0x"..string.sub(color1, 1, 2)), tonumber("0x"..string.sub(color1, 3, 4)), tonumber("0x"..string.sub(color1, 5, 6))
  local r2, g2, b2 = tonumber("0x"..string.sub(color2, 1, 2)), tonumber("0x"..string.sub(color2, 3, 4)), tonumber("0x"..string.sub(color2, 5, 6))
  -- calculate weighted average values to get the mixed color
  local totalWeight = weight1 + weight2
  local r = (r1 * weight1 + r2 * weight2) / totalWeight
  local g = (g1 * weight1 + g2 * weight2) / totalWeight
  local b = (b1 * weight1 + b2 * weight2) / totalWeight
  -- convert decimal values back to hex
  return string.format("#%02x%02x%02x", r, g, b)
end

local gen_shades = function(col)
  local shades = {}
  for i = 0, 9 do
    local new_col = mod(col, i*3)
    table.insert(shades, new_col)
  end
  return shades
end


local set_hl = function(group_name, opts)

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

  if opts.blend ~= nil then hl_opts.blend = clamp(opts.blend, 0, 100) end

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

local set_hls = function(hl_table)
  for hl_group, opts in pairs(hl_table) do
    set_hl(hl_group, opts)
  end

  vim.g.colors_name = "venom"
end

local green     = gen_shades '#1F5E3F'
local white     = gen_shades '#C0B9DD'
local red       = gen_shades '#CB4251'
local orange    = gen_shades '#F37A2E'
local yellow    = gen_shades '#FFBE34'
local lime      = gen_shades '#AAD94C'
local cyan      = gen_shades '#409FFF'
local blue      = gen_shades '#3C4879'
local purple    = gen_shades '#4C3889'
local grey      = gen_shades '#222A3D'
local black     = gen_shades '#07080f'
local debug     = gen_shades '#FF00FF'

local c = {
  -- common
  bg        = black[1],
  bg_float  = black[3],
  mg        = grey[1],
  fg        = white[1],
  line      = black[2],

  acc       = cyan[1],

  fold      = grey[8],

  -- diag
  ok        = green[4],
  err       = red[4],
  info      = cyan[4],
  warn      = yellow[4],
  hint      = purple[4],
  ok_dim    = mix(green[4], black[1], 0.1, 0.9),
  err_dim   = mix(red[4], black[1], 0.1, 0.9),
  info_dim  = mix(cyan[4], black[1], 0.1, 0.9),
  warn_dim  = mix(yellow[4], black[1], 0.1, 0.9),
  hint_dim  = mix(purple[4], black[1], 0.1, 0.9),

  -- diff
  add       = green[2],
  mod       = blue[1],
  del       = red[1],
  add_alt   = mix(green[2], black[1], 0.6, 0.4),
  mod_alt   = mix(blue[1], black[1], 0.6, 0.4),
  del_alt   = mix(red[1], black[1], 0.6, 0.4),

  -- vcs
  staged    = green[4],
  unstaged  = grey[2],
  conflict  = red[1],
  deleted   = red[1],
  renamed   = blue[1],

  -- syntax
  comment   = grey[2],
  link      = cyan[3],
  note      = blue[10],
  todo      = orange[5],
  value     = red[10],
  variable  = purple[10],
  constant  = red[1],
  func      = yellow[1],
  keyword   = orange[1],
  operator  = orange[10],
  string    = green[10],
  type      = cyan[1],
  include   = lime[10],
  special   = orange[2],

  -- others
  debug     = debug[1]
}

local highlights = {

  -- TREE SITTER
  ['@variable']                     = { fg = c.fg },
  ['@variable.builtin']             = { "@variable" },
  ['@variable.parameter']           = {},
  ['@variable.parameter.builtin']   = { "@variable.parameter" },
  ['@variable.member']              = {},
  ['@constant']                     = { fg = c.constant },
  ['@constant.builtin']             = { "@constant" },
  ['@constant.macro']               = {},
  ['@module']                       = {},
  ['@module.builtin']               = { "@module" },
  ['@label']                        = { "@keyword" },
  ['@string']                       = { fg = c.string },
  -- ['@string.documentation']         = {},
  -- ['@string.regexp']                = {},
  -- ['@string.escape']                = {},
  ['@string.special']               = { "@type" },
  -- ['@string.special.symbol']        = {},
  -- ['@string.special.path']          = {},
  -- ['@string.special.url']           = {},
  ['@character']                    = { fg = c.string },
  -- ['@character.special']            = {},
  ['@boolean']                      = { fg = c.value },
  ['@number']                       = { fg = c.value },
  -- ['@number.float']                 = {},
  ['@type']                         = { fg = c.type },
  ['@type.builtin']                 = { "@type" },
  -- ['@type.definition']              = {},
  ['@attribute']                    = { "@variable" },
  ['@attribute.builtin']            = { "@attribute" },
  ['@property']                     = { "@variable" },
  ['@function']                     = { fg = c.func },
  ['@function.builtin']             = { "@function" },
  -- ['@function.call']                = {},
  -- ['@function.macro']               = {},
  -- ['@function.method']              = {},
  -- ['@function.method.call']         = {},
  ['@constructor']                  = { "@function" },
  ['@operator']                     = { fg = c.operator },
  ['@keyword']                      = { fg = c.keyword },
  -- ['@keyword.coroutine']            = {},
  -- ['@keyword.function']             = {},
  -- ['@keyword.operator']             = {},
  -- ['@keyword.import']               = {},
  -- ['@keyword.type']                 = {},
  -- ['@keyword.modifier']             = {},
  -- ['@keyword.repeat']               = {},
  -- ['@keyword.return']               = {},
  ['@keyword.debug']                = { fg = c.debug },
  -- ['@keyword.exception']            = {},
  -- ['@keyword.conditional']          = {},
  -- ['@keyword.conditional.ternary']  = {},
  -- ['@keyword.directive']            = {},
  -- ['@keyword.directive.define']     = {},
  ['@punctuation']                  = { "@operator" },
  -- ['@punctuation.delimiter']        = {},
  -- ['@punctuation.bracket']          = {},
  -- ['@punctuation.special']          = {},
  ['@comment']                      = { fg = c.comment },
  -- ['@comment.documentation']        = {},
  ['@comment.error']                = { fg = c.err },
  ['@comment.warning']              = { fg = c.warn },
  ['@comment.todo']                 = { fg = c.todo },
  ['@comment.note']                 = { fg = c.note },
  ['@markup.strong']                = { bold = true },
  ['@markup.italic']                = { italic = true },
  ['@markup.strikethrough']         = { strikethrough = true },
  ['@markup.underline']             = { underline = true },
  ['@markup.heading']               = { bold = true },
  ['@markup.heading.1']             = { fg = c.err },
  ['@markup.heading.2']             = { fg = c.warn },
  ['@markup.heading.3']             = { fg = c.type },
  ['@markup.heading.4']             = {},
  ['@markup.heading.5']             = {},
  ['@markup.heading.6']             = {},
  ['@markup.quote']                 = { "@string" },
  ['@markup.math']                  = {},
  ['@markup.link']                  = { "@operator" },
  ['@markup.link.label']            = { "@keyword" },
  ['@markup.link.url']              = { fg = c.link, underline = true },
  ['@markup.raw']                   = {},
  ['@markup.raw.block']             = {},
  ['@markup.list']                  = { fg = c.string, bold = true },
  ['@markup.list.checked']          = {},
  ['@markup.list.unchecked']        = {},
  -- ['@diff']                         = {},
  ['@diff.plus']                    = { fg = c.add },
  ['@diff.minus']                   = { fg = c.del },
  ['@diff.delta']                   = { fg = c.mod },
  ['@tag']                          = { "@keyword" },
  ['@tag.builtin']                  = { "@tag" },
  -- ['@tag.attribute']                = {},
  -- ['@tag.delimiter']                = {},



  -- LSP SEMANTIC HIGHLIGHT (turrning off some lsp semantic highlights)
  -- visit https://gist.github.com/swarn/fb37d9eefe1bc616c2a7e476c0bc0316
  -- ['@lsp.type.class']             = {},
  ['@lsp.type.comment']           = {},
  -- ['@lsp.type.decorator']         = {},
  -- ['@lsp.type.enum']              = {},
  -- ['@lsp.type.enumMember']        = {},
  -- ['@lsp.type.event']             = {},
  -- ['@lsp.type.function']          = {},
  -- ['@lsp.type.interface']         = {},
  -- ['@lsp.type.keyword']           = {},
  -- ['@lsp.type.macro']             = {},
  -- ['@lsp.type.method']            = {},
  -- ['@lsp.type.modifier']          = {},
  -- ['@lsp.type.namespace']         = {},
  -- ['@lsp.type.number']            = {},
  -- ['@lsp.type.operator']          = {},
  -- ['@lsp.type.parameter']         = {},
  -- ['@lsp.type.property']          = {},
  -- ['@lsp.type.regexp']            = {},
  -- ['@lsp.type.string']            = {},
  -- ['@lsp.type.struct']            = {},
  -- ['@lsp.type.type']              = {},
  -- ['@lsp.type.typeParameter']     = {},
  ['@lsp.type.variable']          = {},
  -- ['@lsp.mod.abstract']           = {},
  -- ['@lsp.mod.async']              = {},
  -- ['@lsp.mod.declaration']        = {},
  -- ['@lsp.mod.defaultLibrary']     = {},
  -- ['@lsp.mod.definition']         = {},
  -- ['@lsp.mod.deprecated']         = {},
  -- ['@lsp.mod.documentation']      = {},
  -- ['@lsp.mod.modification']       = {},
  -- ['@lsp.mod.readonly']           = {},
  -- ['@lsp.mod.static']             = {},



  -- LEGACY
  ['Normal']          = { fg = c.fg },
  ['NormalFloat']     = { "Normal" },
  ['NormalNC']        = { "Normal" },

  ['Search']          = { bg = c.fold },
  ['IncSearch']       = { "Search" },
  ['CurSearch']       = { "Search" },
  ['Substitute']      = { "Search" },

  ['CursorLine']      = { bg = c.line },
  ['CursorLineNr']    = {},
  ['CursorLineFold']  = {},
  ['CursorLineSign']  = {},
  ['CursorColumn']    = {},

  ['ColorColumn']     = { bg = c.line },

  ['Visual']          = { bg = c.mg },
  ['VisualNOS']       = { "Visual" },

  ['ErrorMsg']        = { fg = c.err },
  ['WarningMsg']      = { fg = c.warn },

  ['LineNr']          = { "Comment" },

  ['Folded']          = { fg = c.fold },

  ['TermCursor']      = { underline = true },
  ['TermCursorNC']    = { "TermCursor" },

  ['SpecialKey']      = { fg = c.special },
  ['Whitespace']      = { fg = c.comment },

  ['DiffAdd']         = { "@diff.plus" },
  ['DiffChange']      = { "@diff.delta" },
  ['DiffDelete']      = { "@diff.minus" },
  ['DiffText']        = {},

  ['SpellBad']        = { undercurl = true, sp = c.warn },

  ['FoldColumn']      = { "Folded" },
  ['Title']           = { "@markup.heading" },

  ['StatusLine']      = { bg = c.bg },
  ['StatusLineNC']    = { bg = c.bg },

  ['TabLine']         = { bg = c.bg, fg = c.mg },
  ['TabLineFill']     = { bg = c.bg },
  ['TabLineSel']      = { bg = c.bg, fg = c.fg, bold = true },

  ['Pmenu']           = { bg = c.bg_float }, -- should be c.bg when it gets borders
  ['PmenuSel']        = { bg = c.mg },
  ['PmenuKind']       = { fg = c.comment },
  ['PmenuKindSel']    = { fg = c.comment },
  ['PmenuExtra']      = {},
  ['PmenuExtraSel']   = {},
  ['PmenuSbar']       = { bg = c.mg },
  ['PmenuThumb']      = { bg = c.fg },

  -- UNWANTED
  ['Cursor']          = {},
  ['lCursor']         = {},
  ['CursorIM']        = {},

  ['Conceal']         = { "Folded" },

  ['MatchParen']      = {},

  ['EndOfBuffer']     = {},
  ['WildMenu']        = {},
  ['ModeMsg']         = {},
  ['Question']        = {},
  ['Directory']       = {},
  ['SignColumn']      = {},

  ['FloatBorder']     = { "WinSeparator" },
  ['FloatTitle']      = {},
  ['FloatFooter']     = {},
  ['WinSeparator']    = { fg = c.comment },

  ['LineNrAbove']     = {},
  ['LineNrBelow']     = {},

  ['MsgArea']         = {},
  ['MsgSeparator']    = {},
  ['MoreMsg']         = {},
  ['NonText']         = {},

  ['SpellCap']        = {},
  ['SpellLocal']      = {},
  ['SpellRare']       = {},

  -- GUI
  -- ['User1']           = {},
  -- ['User2']           = {},
  -- ['User3']           = {},
  -- ['User4']           = {},
  -- ['User5']           = {},
  -- ['User6']           = {},
  -- ['User7']           = {},
  -- ['User8']           = {},
  -- ['User9']           = {},
  -- ['Menu']            = {},
  -- ['Scrollbar']       = {},
  -- ['Tooltip']         = {},

  -- UNSET
  ['QuickFixLine']    = {},

  ['WinBar']          = {},
  ['WinBarNC']        = {},


  -- EXTRA
  ['Comment']         = { "@comment" },
  ['Constant']        = { "@constant" },
  ['String']          = { "@string" },
  ['Character']       = { "@character" },
  ['Number']          = { "@number" },
  ['Boolean']         = { "@boolean" },
  ['Float']           = { "@number.float" },
  ['Identifier']      = { "@variable" },
  ['Function']        = { "@function" },
  ['Statement']       = {},
  ['Conditional']     = { "@keyword" },
  ['Repeat']          = { "@keyword" },
  ['Label']           = { "@keyword" },
  ['Operator']        = { "@operator" },
  ['Keyword']         = { "@keyword" },
  ['Exception']       = { "@keyword" },
  ['PreProc']         = { "@constant" },
  ['Include']         = { "@constant" },
  ['Define']          = { "@constant" },
  ['Macro']           = { "@constant" },
  ['PreCondit']       = { "@constant" },
  ['Type']            = { "@type" },
  ['StorageClass']    = { "@module" },
  ['Structure']       = { "@module" },
  ['Typedef']         = { "@type" },
  ['Special']         = { "@string.special"},
  ['SpecialChar']     = { "@character.special" },
  ['Tag']             = { "@tag" },
  ['Delimiter']       = { "@punctuation.delimiter" },
  ['SpecialComment']  = { "@comment.documentation" },
  ['Underlined']      = { "@markup.underline" },
  ['Debug']           = { "@keyword.debug" },
  ['Ignore']          = {},
  ['Error']           = {},
  ['Todo']            = { "@comment.todo" },
  ['keywords']        = { "@keyword" },
  ['Added']           = { "@diff.plus" },
  ['Changed']         = { "@diff.delta" },
  ['Removed']         = { "@diff.minus" },


  -- DIAGS
  ['DiagnosticError']             = { fg = c.err },
  ['DiagnosticWarn']              = { fg = c.warn },
  ['DiagnosticInfo']              = { fg = c.info },
  ['DiagnosticHint']              = { fg = c.hint },
  ['DiagnosticOk']                = { fg = c.ok },

  ['DiagnosticUnderlineError']    = { undercurl = true, sp = c.err },
  ['DiagnosticUnderlineWarn']     = { undercurl = true, sp = c.warn },
  ['DiagnosticUnderlineInfo']     = { undercurl = true, sp = c.info },
  ['DiagnosticUnderlineHint']     = { undercurl = true, sp = c.hint },
  ['DiagnosticUnderlineOk']       = { undercurl = true, sp = c.ok },

  ['DiagnosticVirtualTextError']  = { bg = c.err_dim, fg = c.err },
  ['DiagnosticVirtualTextWarn']   = { bg = c.warn_dim, fg = c.warn },
  ['DiagnosticVirtualTextInfo']   = { bg = c.info_dim, fg = c.info },
  ['DiagnosticVirtualTextHint']   = { bg = c.hint_dim, fg = c.hint },
  ['DiagnosticVirtualTextOk']     = { bg = c.ok_dim, fg = c.ok },

  ['DiagnosticFloatingError']     = { fg = c.err },
  ['DiagnosticFloatingWarn']      = { fg = c.warn },
  ['DiagnosticFloatingInfo']      = { fg = c.info },
  ['DiagnosticFloatingHint']      = { fg = c.hint },
  ['DiagnosticFloatingOk']        = { fg = c.ok },

  ['DiagnosticSignError']         = { fg = c.err },
  ['DiagnosticSignWarn']          = { fg = c.warn },
  ['DiagnosticSignInfo']          = { fg = c.info },
  ['DiagnosticSignHint']          = { fg = c.hint },
  ['DiagnosticSignOk']            = { fg = c.ok },

  ['DiagnosticDeprecated']        = {},
  ['DiagnosticUnnecessary']       = { "@comment" },


  -- LspInfo
  ['LspInfoBorder']               = { "FloatBorder" },


  -- Mason
  ['MasonNormal'] = { link = "NormalFloat" },
  ['MasonHeader'] = { "@markup.heading.1" },
  ['MasonHeaderSecondary'] = { "@markup.heading2" },
  ['MasonHighlight'] = { fg = c.type },
  ['MasonHighlightBlock'] = { bg = c.type, fg = c.bg_float },
  ['MasonHighlightBlockBold'] = { bg = c.type, fg = c.bg_float, bold = true },
  ['MasonHighlightSecondary'] = { fg = c.warn },
  ['MasonHighlightBlockSecondary'] = { bg = c.warn, fg = c.bg_float },
  ['MasonHighlightBlockBoldSecondary'] = { bg = c.warn, fg = c.bg_float, bold = true },
  ['MasonLink'] = { "@markup.link.url" },
  ['MasonMuted'] = { fg = c.fold },
  ['MasonMutedBlock'] = { bg = c.fold, fg = c.bg_float },
  ['MasonMutedBlockBold'] = { bg = c.fold, fg = c.bg_float, bold = true },
  ['MasonError'] = { "ErrorMsg" },
  ['MasonWarning'] = { "WarningMsg" },
  ['MasonHeading'] = { "@markup.heading" },


  -- Cmp
  ['CmpItemAbbr']               = {},
  ['CmpItemAbbrDeprecated']     = { strikethrough = true },
  ['CmpItemAbbrMatch']          = { fg = c.acc },
  ['CmpItemAbbrMatchFuzzy']     = {},
  ['CmpItemKind']               = {},
  ['CmpItemMenu']               = { fg = c.comment },
  ['CmpItemKindText']           = { fg = c.fg },
  ['CmpItemKindMethod']         = { fg = c.func },
  ['CmpItemKindFunction']       = { fg = c.func },
  ['CmpItemKindConstructor']    = { fg = c.special },
  ['CmpItemKindField']          = { fg = c.entity },
  ['CmpItemKindVariable']       = { fg = c.keyword },
  ['CmpItemKindClass']          = { fg = c.type },
  ['CmpItemKindInterface']      = { fg = c.type },
  ['CmpItemKindModule']         = { fg = c.special },
  ['CmpItemKindProperty']       = { fg = c.type },
  ['CmpItemKindUnit']           = { fg = c.keyword },
  ['CmpItemKindValue']          = { fg = c.string },
  ['CmpItemKindEnum']           = { fg = c.keyword },
  ['CmpItemKindKeyword']        = { fg = c.keyword },
  ['CmpItemKindSnippet']        = { fg = c.constant },
  ['CmpItemKindColor']          = { fg = c.string },
  ['CmpItemKindFile']           = { fg = c.fg },
  ['CmpItemKindReference']      = { fg = c.entity },
  ['CmpItemKindFolder']         = { fg = c.fg },
  ['CmpItemKindEnumMember']     = { fg = c.string },
  ['CmpItemKindConstant']       = { fg = c.constant },
  ['CmpItemKindStruct']         = { fg = c.string },
  ['CmpItemKindEvent']          = { fg = c.special },
  ['CmpItemKindOperator']       = { fg = c.operator },
  ['CmpItemKindTypeParameter']  = { fg = c.type },


  -- MINI
  -- Map
  ['MiniMapNormal']             = {},
  ['MiniMapSymbolView']         = { 'Folded' },
  -- Notify
  ['MiniNotifyNormal']          = { 'Folded' },
  -- Pick
  ['MiniPickBorder']            = { "FloatBorder" },
  ['MiniPickBorderBusy']        = { fg = c.fold },
  ['MiniPickIconDirectory']     = { fg = c.fg },
  ['MiniPickIconFile']          = { fg = c.fg },
  ['MiniPickHeader']            = { "@markup.heading.1" },
  ['MiniPickMatchCurrent']      = { "PmenuSel" },
  ['MiniPickMatchMarked']       = { fg = c.acc },
  ['MiniPickMatchRanges']       = { fg = c.acc, bold = true },
  ['MiniPickNormal']            = { fg = c.fg },
  ['MiniPickPreviewLine'] = {},   -- target line in preview.
  ['MiniPickPreviewRegion'] = {}, -- target region in preview.
  ['MiniPickPrompt']            = { fg = c.fg },


  -- Neotree
  -- NeoTreeBufferNumber       The buffer number shown in the buffers source.
  -- NeoTreeCursorLine         |hl-CursorLine| override in Neo-tree window.
  NeoTreeDimText               = { fg = c.fold }, -- Greyed out text used in various places.
  -- NeoTreeDirectoryIcon      Directory icon.
  -- NeoTreeDirectoryName      Directory name.
  NeoTreeDotfile               = { fg = c.comment }, -- Used for icons and names when dotfiles are filtered.
  -- NeoTreeFileIcon           File icon, when not overridden by devicons.
  -- NeoTreeFileName           File name, when not overwritten by another status.
  -- NeoTreeFileNameOpened     File name when the file is open. Not used yet.
  -- NeoTreeFilterTerm         The filter term, as displayed in the root node.
  NeoTreeFloatBorder           = { fg = c.fg }, --The border for pop-up windows.
  -- NeoTreeFloatTitle         Used for the title text of pop-ups when the border-style
  --                           is set to another style than "NC". This is derived
  --                           from NeoTreeFloatBorder.
  -- NeoTreeTitleBar           Used for the title bar of pop-ups, when the border-style
  --                           is set to "NC". This is derived from NeoTreeFloatBorder.

  NeoTreeGitAdded           = { "DiffAdd" },
  NeoTreeGitConflict        = { fg = c.conflict },
  NeoTreeGitDeleted         = { fg = c.deleted },
  NeoTreeGitIgnored         = { "Comment" },
  NeoTreeGitModified        = { "DiffAdd" },
  NeoTreeGitUntracked       = { "Folded" },

  NeoTreeGitUnstaged        = { fg = c.unstaged },
  NeoTreeGitStaged          = { fg = c.staged },

  NeoTreeMessage            = { fg = c.comment, italic = true },

  -- NeoTreeHiddenByName       Used for icons and names when `hide_by_name` is used.
  -- NeoTreeIndentMarker       The style of indentation markers (guides). By default,
  --                           the "Normal" highlight is used.
  -- NeoTreeExpander           Used for collapsed/expanded icons.
  -- NeoTreeNormal             |hl-Normal| override in Neo-tree window.
  -- NeoTreeNormalNC           |hl-NormalNC| override in Neo-tree window.
  -- NeoTreeSignColumn         |hl-SignColumn| override in Neo-tree window.
  -- NeoTreeStats              Used for "stat" columns like size, last modified, etc.
  -- NeoTreeStatsHeader        Used for the header (top line) of the above columns.
  -- NeoTreeStatusLine         |hl-StatusLine| override in Neo-tree window.
  -- NeoTreeStatusLineNC       |hl-StatusLineNC| override in Neo-tree window.
  -- NeoTreeVertSplit          |hl-VertSplit| override in Neo-tree window.
  -- NeoTreeWinSeparator       |hl-WinSeparator| override in Neo-tree window.
  -- NeoTreeEndOfBuffer        |hl-EndOfBuffer| override in Neo-tree window.
  -- NeoTreeRootName           The name of the root node.
  -- NeoTreeSymbolicLinkTarget Symbolic link target.
  -- NeoTreeTitleBar           Used for the title bar of pop-ups, when the border-style
  --                           is set to "NC". This is derived from NeoTreeFloatBorder.
  -- NeoTreeWindowsHidden      Used for icons and names that are hidden on Windows.


}

set_hls(highlights)
