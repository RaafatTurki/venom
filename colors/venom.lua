local M = {}

-- utils
M.rgb_to_hex = function(rgb)
  return string.format("#%02x%02x%02x", rgb[1], rgb[2], rgb[3])
end

M.hex_to_rgb = function(hex)
  hex = hex:gsub("#", "")
  local r = tonumber("0x" .. hex:sub(1, 2))
  local g = tonumber("0x" .. hex:sub(3, 4))
  local b = tonumber("0x" .. hex:sub(5, 6))
  return { r, g, b }
end

M.interpolate = function(color1, color2, t)
  local r = color1[1] + (color2[1] - color1[1]) * t
  local g = color1[2] + (color2[2] - color1[2]) * t
  local b = color1[3] + (color2[3] - color1[3]) * t

  return {r, g, b}
end

M.steps = { 0.1, 0.25, 0.5, 0.75, 0.9 }

M.fg = "#BFB8DC"
M.bg = "#07080f"

M.gen_shades = function(hex)
  local shades = {}
  shades[0] = hex

  local base = M.hex_to_rgb(hex)
  local fg = M.hex_to_rgb(M.fg)
  local bg = M.hex_to_rgb(M.bg)

  -- towards fg
  for i, step in ipairs(M.steps) do
    local shade = M.interpolate(base, fg, step)
    shades[i] = M.rgb_to_hex(shade)
  end

  -- towards bg
  for i, step in ipairs(M.steps) do
    local shade = M.interpolate(base, bg, step)
    shades[-i] = M.rgb_to_hex(shade)
  end

  -- log(shades)
  -- log(base)

  -- local shades = {}
  -- for i = 0, 9 do
  --   local new_col = M.mod(col, i*3)
  --   table.insert(shades, new_col)
  -- end
  return shades
end

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

M.setup = function(hl_table)
  for hl_group, opts in pairs(hl_table) do
    M.set_hl(hl_group, opts)
  end

  vim.g.colors_name = "venom"
end

M.bases = {
  red       = '#CB4251',
  orange    = '#F37A2E',
  yellow    = '#FFBE34',
  green     = '#AAD94C',
  blue      = '#409FFF',
  purple    = '#4C3889',
  grey      = '#222A3D',

  debug     = '#FF00FF',
}

M.shades = {
  red       = M.gen_shades(M.bases.red),
  orange    = M.gen_shades(M.bases.orange),
  yellow    = M.gen_shades(M.bases.yellow),
  green     = M.gen_shades(M.bases.green),
  blue      = M.gen_shades(M.bases.blue),
  purple    = M.gen_shades(M.bases.purple),
  grey      = M.gen_shades(M.bases.grey),
}

M.serialize_shades = function(shades)
  local ser_shades = {}
  for i = -#M.steps, #M.steps do
    table.insert(ser_shades, shades[i])
  end
  return ser_shades
end

-- function test()
--   vim.api.nvim_buf_set_lines(0, vim.api.nvim_win_get_cursor(0)[1] - 1, vim.api.nvim_win_get_cursor(0)[1], true, {
--     vim.inspect(M.serialize_shades(M.gen_shades(M.bases.red))),
--     vim.inspect(M.serialize_shades(M.gen_shades(M.bases.orange))),
--     vim.inspect(M.serialize_shades(M.gen_shades(M.bases.yellow))),
--     vim.inspect(M.serialize_shades(M.gen_shades(M.bases.green))),
--     vim.inspect(M.serialize_shades(M.gen_shades(M.bases.blue))),
--     vim.inspect(M.serialize_shades(M.gen_shades(M.bases.purple))),
--     vim.inspect(M.serialize_shades(M.gen_shades(M.bases.grey))),
--   })
-- end

local c = {
  -- common
  bg        = M.bg,
  fg        = M.fg,
  bg_float  = M.shades.grey[-3],
  mg        = M.shades.grey[0],
  line      = M.shades.grey[-4],

  acc       = M.shades.blue[-1],

  fold      = M.shades.grey[2],

  -- diag
  ok        = M.shades.green[1],
  err       = M.shades.red[1],
  info      = M.shades.blue[1],
  warn      = M.shades.yellow[1],
  hint      = M.shades.purple[1],

  ok_dim    = M.shades.green[-4],
  err_dim   = M.shades.red[-4],
  info_dim  = M.shades.blue[-4],
  warn_dim  = M.shades.yellow[-4],
  hint_dim  = M.shades.purple[-4],

  -- diff
  add       = M.shades.green[-1],
  mod       = M.shades.blue[-1],
  del       = M.shades.red[-1],
  add_alt   = M.shades.green[-2],
  mod_alt   = M.shades.blue[-2],
  del_alt   = M.shades.red[-2],

  -- vcs
  staged    = M.shades.green[2],
  unstaged  = M.shades.grey[2],
  conflict  = M.shades.red[1],
  deleted   = M.shades.red[1],
  renamed   = M.shades.blue[1],

  -- syntax
  comment   = M.shades.grey[1],
  note      = M.shades.blue[-3],
  todo      = M.shades.orange[-3],

  variable  = M.shades.purple[0],
  func      = M.shades.yellow[0],

  constant  = M.shades.red[0],
  value     = M.shades.red[1],

  type      = M.shades.blue[0],
  link      = M.shades.blue[1],

  string    = M.shades.green[0],
  include   = M.shades.green[1],

  keyword   = M.shades.orange[0],
  special   = M.shades.orange[1],
  operator  = M.shades.orange[2],

  -- others
  debug     = M.bases.debug
}

local highlights = {

  -- TREE SITTER
  ['@variable']                     = { fg = c.fg },
  ['@variable.builtin']             = { '@variable' },
  ['@variable.parameter']           = {},
  ['@variable.parameter.builtin']   = { '@variable.parameter' },
  ['@variable.member']              = {},
  ['@constant']                     = { fg = c.constant },
  ['@constant.builtin']             = { '@constant' },
  ['@constant.macro']               = {},
  ['@module']                       = {},
  ['@module.builtin']               = { '@module' },
  ['@label']                        = { '@keyword' },
  ['@string']                       = { fg = c.string },
  -- ['@string.documentation']         = {},
  -- ['@string.regexp']                = {},
  -- ['@string.escape']                = {},
  ['@string.special']               = { '@type' },
  -- ['@string.special.symbol']        = {},
  -- ['@string.special.path']          = {},
  -- ['@string.special.url']           = {},
  ['@character']                    = { fg = c.string },
  -- ['@character.special']            = {},
  ['@boolean']                      = { fg = c.value },
  ['@number']                       = { fg = c.value },
  -- ['@number.float']                 = {},
  ['@type']                         = { fg = c.type },
  ['@type.builtin']                 = { '@type' },
  -- ['@type.definition']              = {},
  ['@attribute']                    = { '@variable' },
  ['@attribute.builtin']            = { '@attribute' },
  ['@property']                     = { '@variable' },
  ['@function']                     = { fg = c.func },
  ['@function.builtin']             = { '@function' },
  -- ['@function.call']                = {},
  -- ['@function.macro']               = {},
  -- ['@function.method']              = {},
  -- ['@function.method.call']         = {},
  ['@constructor']                  = { '@function' },
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
  ['@punctuation']                  = { '@operator' },
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
  ['@markup.quote']                 = { '@string' },
  ['@markup.math']                  = {},
  ['@markup.link']                  = { '@operator' },
  ['@markup.link.label']            = { '@keyword' },
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
  ['@tag']                          = { '@keyword' },
  ['@tag.builtin']                  = { '@tag' },
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
  ['Normal']          = { bg = c.bg, fg = c.fg },
  ['NormalFloat']     = { 'Normal' },
  ['NormalNC']        = { 'Normal' },

  ['Search']          = { bg = c.fold },
  ['IncSearch']       = { 'Search' },
  ['CurSearch']       = { 'Search' },
  ['Substitute']      = { 'Search' },

  ['CursorLine']      = { bg = c.line },
  ['CursorLineNr']    = {},
  ['CursorLineFold']  = {},
  ['CursorLineSign']  = {},
  ['CursorColumn']    = {},

  ['ColorColumn']     = { bg = c.line },

  ['Visual']          = { bg = c.mg },
  ['VisualNOS']       = { 'Visual' },

  ['ErrorMsg']        = { fg = c.err },
  ['WarningMsg']      = { fg = c.warn },

  ['LineNr']          = { 'Comment' },

  ['Folded']          = { fg = c.fold },

  ['TermCursor']      = { underline = true },
  ['TermCursorNC']    = { 'TermCursor' },

  ['SpecialKey']      = { fg = c.special },
  ['Whitespace']      = { fg = c.comment },

  ['DiffAdd']         = { '@diff.plus' },
  ['DiffChange']      = { '@diff.delta' },
  ['DiffDelete']      = { '@diff.minus' },
  ['DiffText']        = {},

  ['SpellBad']        = { undercurl = true, sp = c.warn },

  ['FoldColumn']      = { 'Folded' },
  ['Title']           = { '@markup.heading' },

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

  ['Conceal']         = { 'Folded' },

  ['MatchParen']      = {},

  ['EndOfBuffer']     = {},
  ['WildMenu']        = { bg = c.mg },
  ['ModeMsg']         = {},
  ['Question']        = {},
  ['Directory']       = {},
  ['SignColumn']      = {},

  ['FloatBorder']     = { 'WinSeparator' },
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
  ['Comment']         = { '@comment' },
  ['Constant']        = { '@constant' },
  ['String']          = { '@string' },
  ['Character']       = { '@character' },
  ['Number']          = { '@number' },
  ['Boolean']         = { '@boolean' },
  ['Float']           = { '@number.float' },
  ['Identifier']      = { '@variable' },
  ['Function']        = { '@function' },
  ['Statement']       = {},
  ['Conditional']     = { '@keyword' },
  ['Repeat']          = { '@keyword' },
  ['Label']           = { '@keyword' },
  ['Operator']        = { '@operator' },
  ['Keyword']         = { '@keyword' },
  ['Exception']       = { '@keyword' },
  ['PreProc']         = { '@constant' },
  ['Include']         = { '@constant' },
  ['Define']          = { '@constant' },
  ['Macro']           = { '@constant' },
  ['PreCondit']       = { '@constant' },
  ['Type']            = { '@type' },
  ['StorageClass']    = { '@module' },
  ['Structure']       = { '@module' },
  ['Typedef']         = { '@type' },
  ['Special']         = { '@string.special'},
  ['SpecialChar']     = { '@character.special' },
  ['Tag']             = { '@tag' },
  ['Delimiter']       = { '@punctuation.delimiter' },
  ['SpecialComment']  = { '@comment.documentation' },
  ['Underlined']      = { '@markup.underline' },
  ['Debug']           = { '@keyword.debug' },
  ['Ignore']          = {},
  ['Error']           = {},
  ['Todo']            = { '@comment.todo' },
  ['keywords']        = { '@keyword' },
  ['Added']           = { '@diff.plus' },
  ['Changed']         = { '@diff.delta' },
  ['Removed']         = { '@diff.minus' },


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
  ['DiagnosticUnnecessary']       = { '@comment' },


  -- LspInfo
  ['LspInfoBorder']               = { 'FloatBorder' },


  -- Mason
  ['MasonNormal'] = { link = "NormalFloat" },
  ['MasonHeader'] = { '@markup.heading.1' },
  ['MasonHeaderSecondary'] = { '@markup.heading2' },
  ['MasonHighlight'] = { fg = c.type },
  ['MasonHighlightBlock'] = { bg = c.type, fg = c.bg_float },
  ['MasonHighlightBlockBold'] = { bg = c.type, fg = c.bg_float, bold = true },
  ['MasonHighlightSecondary'] = { fg = c.warn },
  ['MasonHighlightBlockSecondary'] = { bg = c.warn, fg = c.bg_float },
  ['MasonHighlightBlockBoldSecondary'] = { bg = c.warn, fg = c.bg_float, bold = true },
  ['MasonLink'] = { '@markup.link.url' },
  ['MasonMuted'] = { fg = c.fold },
  ['MasonMutedBlock'] = { bg = c.fold, fg = c.bg_float },
  ['MasonMutedBlockBold'] = { bg = c.fold, fg = c.bg_float, bold = true },
  ['MasonError'] = { 'ErrorMsg' },
  ['MasonWarning'] = { 'WarningMsg' },
  ['MasonHeading'] = { '@markup.heading' },


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

  -- Blink
  ['BlinkCmpMenu']                          = { fg = c.fg },
  ['BlinkCmpMenuBorder']                    = { "FloatBorder" },
  ['BlinkCmpMenuSelection']                 = { bg = c.mg },
  ['BlinkCmpLabel']                         = { "Normal" },
  ['BlinkCmpLabelDeprecated']               = { strikethrough = true },
  ['BlinkCmpLabelMatch']                    = { fg = c.acc },
  ['BlinkCmpDoc']                           = {},
  ['BlinkCmpDocBorder']                     = { "FloatBorder" },
  ['BlinkCmpDocCursorLine']                 = {},
  ['BlinkCmpSignatureHelp']                 = {},
  ['BlinkCmpSignatureHelpBorder']           = { "FloatBorder" },
  ['BlinkCmpSignatureHelpActiveParameter']  = { bg = c.fg },
  ['BlinkCmpKind']                          = { "CmpItemKind" },
  ['BlinkCmpKindText']                      = { fg = c.fg },
  ['BlinkCmpKindMethod']                    = { fg = c.func },
  ['BlinkCmpKindFunction']                  = { fg = c.func },
  ['BlinkCmpKindConstructor']               = { fg = c.special },
  ['BlinkCmpKindField']                     = { fg = c.entity },
  ['BlinkCmpKindVariable']                  = { fg = c.keyword },
  ['BlinkCmpKindClass']                     = { fg = c.type },
  ['BlinkCmpKindInterface']                 = { fg = c.type },
  ['BlinkCmpKindModule']                    = { fg = c.special },
  ['BlinkCmpKindProperty']                  = { fg = c.type },
  ['BlinkCmpKindUnit']                      = { fg = c.keyword },
  ['BlinkCmpKindValue']                     = { fg = c.string },
  ['BlinkCmpKindEnum']                      = { fg = c.keyword },
  ['BlinkCmpKindKeyword']                   = { fg = c.keyword },
  ['BlinkCmpKindSnippet']                   = { fg = c.constant },
  ['BlinkCmpKindColor']                     = { fg = c.string },
  ['BlinkCmpKindFile']                      = { fg = c.fg },
  ['BlinkCmpKindReference']                 = { fg = c.entity },
  ['BlinkCmpKindFolder']                    = { fg = c.fg },
  ['BlinkCmpKindEnumMember']                = { fg = c.string },
  ['BlinkCmpKindConstant']                  = { fg = c.constant },
  ['BlinkCmpKindStruct']                    = { fg = c.string },
  ['BlinkCmpKindEvent']                     = { fg = c.special },
  ['BlinkCmpKindOperator']                  = { fg = c.operator },
  ['BlinkCmpKindTypeParameter']             = { fg = c.type },


  -- MINI
  -- Map
  ['MiniMapNormal']             = {},
  ['MiniMapSymbolView']         = { 'Folded' },
  -- Notify
  ['MiniNotifyNormal']          = { 'Folded' },
  -- Pick
  ['MiniPickBorder']            = { 'FloatBorder' },
  ['MiniPickBorderBusy']        = { fg = c.fold },
  -- ['MiniPickIconDirectory']     = { fg = c.fg },
  -- ['MiniPickIconFile']          = { fg = c.fg },
  ['MiniPickHeader']            = { '@markup.heading.1' },
  ['MiniPickMatchCurrent']      = { 'PmenuSel' },
  ['MiniPickMatchMarked']       = { fg = c.acc },
  ['MiniPickMatchRanges']       = { fg = c.acc, bold = true },
  ['MiniPickNormal']            = { fg = c.fg },
  ['MiniPickPreviewLine'] = {},   -- target line in preview.
  ['MiniPickPreviewRegion'] = {}, -- target region in preview.
  ['MiniPickPrompt']            = { fg = c.fg },
  -- Icons
  ['MiniIconsBlue']             = { fg = M.shades.blue[0] },
  ['MiniIconsAzure']            = { fg = M.shades.blue[2] },
  ['MiniIconsCyan']             = { fg = M.shades.blue[4] },
  ['MiniIconsGreen']            = { fg = M.shades.green[0] },
  ['MiniIconsGrey']             = { fg = M.shades.grey[2] },
  ['MiniIconsOrange']           = { fg = M.shades.orange[0] },
  ['MiniIconsPurple']           = { fg = M.shades.purple[0] },
  ['MiniIconsRed']              = { fg = M.shades.red[0] },
  ['MiniIconsYellow']           = { fg = M.shades.yellow[0] },


  -- Neotree
  -- NeoTreeBufferNumber       The buffer number shown in the buffers source.
  -- NeoTreeCursorLine         |hl-CursorLine| override in Neo-tree window.
  NeoTreeDimText            = { fg = c.fold }, -- Greyed out text used in various places.
  NeoTreeDirectoryIcon      = { 'MiniIconsGrey' },
  -- NeoTreeDirectoryName      Directory name.
  NeoTreeDotfile            = { fg = c.comment }, -- Used for icons and names when dotfiles are filtered.
  NeoTreeFileIcon           = { 'MiniIconGrey' },
  -- NeoTreeFileName           File name, when not overwritten by another status.
  -- NeoTreeFileNameOpened     File name when the file is open. Not used yet.
  -- NeoTreeFilterTerm         The filter term, as displayed in the root node.
  NeoTreeFloatBorder        = { "FloatBorder" }, --The border for pop-up windows.
  NeoTreeFloatTitle         = { "Title" },
  NeoTreeTitleBar           = { "Title" },

  NeoTreeGitAdded           = { 'DiffAdd' },
  NeoTreeGitConflict        = { fg = c.conflict },
  NeoTreeGitDeleted         = { fg = c.deleted },
  NeoTreeGitIgnored         = { 'Comment' },
  NeoTreeGitModified        = { 'DiffAdd' },
  NeoTreeGitUntracked       = { 'Folded' },

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

M.setup(highlights)
