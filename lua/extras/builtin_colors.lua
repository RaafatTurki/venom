--- defines the built-in colorscheme.
-- @module colors

local lush = require('lush')
local hsl = lush.hsl

local function gen_shades(col)
  local shades = {}
  for i = 0, 9 do
    local new_col = col.li(i*3)
    table.insert(shades, new_col)
  end
  return shades
end

local green     = gen_shades(hsl'#1F5E3F')

local white     = gen_shades(hsl'#C0B9DD')
local pink      = gen_shades(hsl'#E988CF')
local red       = gen_shades(hsl'#CB4251')
local orange    = gen_shades(hsl'#F37A2E')
local yellow    = gen_shades(hsl'#FFBE34')
local lime      = gen_shades(hsl'#AAD94C')
local cyan      = gen_shades(hsl'#409FFF')
local blue      = gen_shades(hsl'#3C4879')
local purple    = gen_shades(hsl'#4C3889')
local grey      = gen_shades(hsl'#222A3D')
local black     = gen_shades(hsl'#0D1017')
local debug     = gen_shades(hsl'#FF00FF')

local c = {
  bg        = black[1],
  bg_alt    = hsl'#000000'.mix(black[1], 80),
  fg        = white[1],
  mg        = grey[1],
  line      = black[2],
  match     = white[1],
  fold      = grey[8],
  comment   = grey[2],

  err       = red[4],
  info      = cyan[4],
  warn      = yellow[4],
  hint      = purple[4],

  regexp    = cyan[1],
  entity    = cyan[1],
  tag       = cyan[5],
  func      = yellow[1],
  special   = yellow[5],
  keyword   = red[1],
  type      = red[5],
  string    = lime[1],
  operator  = orange[5],
  constant  = pink[1],

  add         = green[1],
  mod         = blue[1],
  del         = red[1],

  dirty       = green[1],
  staged      = white[1],
  merge       = purple[1],
  renamed     = orange[1],
  deleted     = red[1],
}

-- local second = os.date("*t").sec

--- @diagnostic disable: undefined-global
local theme = lush(function()
  return {
    Normal          { bg = c.bg },                      -- normal text
    NormalFloat     { Normal },                         -- normal text in floating windows.
    NormalNC        { Normal },                         -- normal text in non-current windows

    StatusLine      { bg = c.line },                         -- status line of current window
    StatusLineNC    { Normal, fg = c.bg },              -- status lines of not-current windows Note: if this is equal to "StatusLine" Vim will use "^^^" in the status line of the current window.

    TabLine         { bg = c.line },                    -- tab pages line, not active tab page label
    TabLineFill     { Normal },                         -- tab pages line, where there are no labels
    TabLineSel      { bg = c.mg, gui = 'bold' },        -- tab pages line, active tab page label

    ColorColumn     { bg = c.bg_alt },                  -- used for the columns set with 'colorcolumn'
    Conceal         { fg = yellow[1] },                                -- placeholder characters substituted for concealed text (see 'conceallevel')

    Cursor          { },
    lCursor         { Cursor },
    CursorIM        { Cursor },

    CursorColumn    { bg = c.line },                    -- Screen-column at the cursor, when 'cursorcolumn' is set.
    CursorLine      { },                                -- Screen-line at the cursor, when 'cursorline' is set.  Low-priority if foreground (ctermfg OR guifg) is not set.
    EndOfBuffer     { fg = c.bg },                      -- filler lines (~) after the end of the buffer.  By default, this is highlighted like |hl-NonText|.
    Folded          { fg = c.fold },                    -- line used for closed folds
    FoldColumn      { Folded },                         -- 'foldcolumn'
    SpecialKey      { fg = c.fold },                    -- Unprintable characters: text displayed differently from what it really is.  But not 'listchars' whitespace. |hl-Whitespace|

    SignColumn      { bg = c.bg },                      -- column where |signs| are displayed

    Comment         { fg = c.comment },                 -- any comment

    DiffAdd         { bg = c.add.mix(c.bg,  75) },
    DiffChange      { bg = c.mod.mix(c.bg,  75) },
    DiffDelete      { fg = c.del.mix(c.bg,  80) },
    DiffText        { bg = c.mod },

    TermCursor      { gui = 'underline', sp = c.fg },   -- cursor in a focused terminal
    TermCursorNC    { TermCursor },                     -- cursor in an unfocused terminal

    VertSplit       { fg = c.mg },                      -- the column separating vertically split windows
    WinSeparator    { VertSplit },

    LineNr          { Comment },                        -- Line number for ":number" and ":#" commands, and when 'number' or 'relativenumber' option is set.
    CursorLineNr    { fg = c.fg, gui = 'bold' },                      -- Like LineNr when 'cursorline' or 'relativenumber' is set for the cursor line.

    NonText         { fg = c.mg },                      -- '@' at the end of the window, characters from 'showbreak' and other characters that do not really exist in the text (e.g., ">" displayed when a double-wide character doesn't fit at the end of the line). See also |hl-EndOfBuffer|.

    Pmenu           { bg = c.line, fg = c.fg },         -- Popup menu: normal item.
    PmenuSel        { bg = c.mg, fg = c.fg },           -- Popup menu: selected item.
    PmenuSbar       { Pmenu },                          -- Popup menu: scrollbar.
    PmenuThumb      { bg = c.fg },                      -- Popup menu: Thumb of the scrollbar.

    Directory       { fg = c.fg },                      -- directory names (and other special names in listings)
    QuickFixLine    { CursorLine, gui = 'bold' },       -- Current |quickfix| item in the quickfix window. Combined with |hl-CursorLine| when the cursor is there.

    Search          { bg = c.match, fg = c.bg },  -- Last search pattern highlighting (see 'hlsearch').  Also used for similar items that need to stand out.
    IncSearch       { Search },                         -- 'incsearch' highlighting; also used for the text replaced with ":s///c"
    Substitute      { Search },                         -- |:substitute| replacement text highlighting

    -- Typography
    Title           { fg = c.fg, gui = 'bold' },        -- titles for output from ":set all", ":autocmd" etc.
    Question        { fg = c.fg },                      -- |hit-enter| prompt and yes/no questions
    ErrorMsg        { fg = c.err },                     -- error messages on the command line
    WarningMsg      { fg = c.warn },                    -- warning messages
    MoreMsg         { fg = c.info },                    -- |more-prompt|
    ModeMsg         { fg = c.fg, gui = 'bold' },        -- 'showmode' message (e.g., "-- INSERT -- ")
    MsgArea         { fg = c.fg },                      -- Area for messages and cmdline
    MsgSeparator    { bg = c.bg, fg = c.mg },           -- Separator for scrolled messages, `msgsep` flag of 'display'

    Visual          { bg = c.line },                    -- Visual mode selection
    -- VisualNOS    { },                                -- Visual mode selection when vim is "Not Owning the Selection".

    Whitespace      { fg = c.comment.mix(c.bg, 30) },   -- "nbsp", "space", "tab" and "trail" in 'listchars'
    WildMenu        { bg = debug[1] },                  -- current match in 'wildmenu' completion

    healthError     { fg = c.err },                     -- :checkhealth errors
    healthWarning   { fg = c.warn },                    -- :checkhealth warns
    healthSuccess   { fg = c.add },                     -- :checkhealth OKs
    healthHelp      { fg = c.info },                    -- :checkhealth help messages


    -- Defacto Syntax
    Tag             { fg = pink[1] },                   --    you can use CTRL-] on this

    Constant        { fg = purple[10] },

    String          { fg = green[10] },                 --   a string constant: "this is a string"
    Character       { String },                         --  a character constant: 'c', '\n'

    Number          { fg = red[5] },
    Boolean         { Number },
    Float           { Number },

    Identifier      { fg = c.fg },

    Function        { fg = c.entity },

    Statement       { fg = c.fg, gui = 'bold' },
    MatchParen      { fg = c.fg, gui = 'bold' };

    Operator        { fg = red[1] },

    Keyword         { fg = orange[1] },
    Conditional     { Keyword },
    Repeat          { Keyword },
    Label           { Keyword },
    Exception       { Keyword },
    Delimiter       { Keyword },

    PreProc         { fg = lime[1], gui = 'bold' },
    Include         { PreProc },
    Define          { PreProc },
    Macro           { PreProc },
    PreCondit       { PreProc },
    
    Special         { fg = lime[1] },
    SpecialChar     { Special },

    Type            { fg = cyan[1], gui = 'bold' },
    StorageClass    { Type },
    Structure       { Type },
    Typedef         { Type },
    
    SpecialComment  { fg = c.warn },
    Todo            { SpecialComment };

    Debug           { bg = purple[1], gui = 'bold' },
    Ignore          { fg = c.bg };
    Error           { fg = c.err };
    Underlined      { gui = "underline" };
    Bold            { gui = "bold" };
    Italic          { gui = "italic" };

    UnderlineError  { gui = 'undercurl', sp = c.err };
    UnderlineWarn   { gui = 'undercurl', sp = c.warn };
    UnderlineInfo   { gui = 'undercurl', sp = c.info };
    UnderlineHint   { gui = 'undercurl', sp = c.hint };
 

    -- LSP
    LspReferenceText                      { Bold, bg = c.mg };
    LspReferenceRead                      { Bold, bg = c.mg };
    LspReferenceWrite                     { Bold, bg = c.mg };

    LspDiagnosticsDefaultError            { fg = c.err };
    LspDiagnosticsDefaultWarning          { fg = c.warn };
    LspDiagnosticsDefaultInformation      { fg = c.info };
    LspDiagnosticsDefaultHint             { fg = c.hint };

    LspDiagnosticsVirtualTextError        { fg = c.err.mix(c.bg,   60) };
    LspDiagnosticsVirtualTextWarning      { fg = c.warn.mix(c.bg,  60) };
    LspDiagnosticsVirtualTextInformation  { fg = c.info.mix(c.bg,  60) };
    LspDiagnosticsVirtualTextHint         { fg = c.hint.mix(c.bg,  60) };

    -- LspDiagnosticsUnderlineError       { UnderlineError };
    -- LspDiagnosticsUnderlineWarning     { UnderlineWarn };
    -- LspDiagnosticsUnderlineInformation { UnderlineInfo };
    -- LspDiagnosticsUnderlineHint        { UnderlineHint };

    -- LspDiagnosticsFloatingError        { };
    -- LspDiagnosticsFloatingWarning      { };
    -- LspDiagnosticsFloatingInformation  { };
    -- LspDiagnosticsFloatingHint         { };

    -- LspDiagnosticsSignError            { };
    -- LspDiagnosticsSignWarning          { };
    -- LspDiagnosticsSignInformation      { };
    -- LspDiagnosticsSignHint             { };

    -- LSP 0.6 
    DiagnosticVirtualTextError            { LspDiagnosticsVirtualTextError };
    DiagnosticVirtualTextWarn             { LspDiagnosticsVirtualTextWarning };
    DiagnosticVirtualTextInfo             { LspDiagnosticsVirtualTextInformation };
    DiagnosticVirtualTextHint             { LspDiagnosticsVirtualTextHint };

    DiagnosticFloatingError               { fg = c.err };
    DiagnosticFloatingWarn                { fg = c.warn };
    DiagnosticFloatingInfo                { fg = c.info };
    DiagnosticFloatingHint                { fg = c.hint };

    DiagnosticSignError                   { fg = c.err };
    DiagnosticSignWarn                    { fg = c.warn };
    DiagnosticSignInfo                    { fg = c.info };
    DiagnosticSignHint                    { fg = c.hint };

    DiagnosticUnderlineError              { UnderlineError };
    DiagnosticUnderlineWarn               { UnderlineWarn };
    DiagnosticUnderlineInfo               { UnderlineInfo };
    DiagnosticUnderlineHint               { UnderlineHint };


    -- Spelling
    SpellBad                { gui = 'undercurl', sp = c.err }; -- Word that is not recognized by the spellchecker. |spell| Combined with the highlighting used otherwise. 
    SpellCap                { }; -- Word that should start with a capital. |spell| Combined with the highlighting used otherwise.
    SpellLocal              { }; -- Word that is recognized by the spellchecker as one that is used in another region. |spell| Combined with the highlighting used otherwise.
    SpellRare               { }; -- Word that is recognized by the spellchecker as one that is hardly ever used.  |spell| Combined with the highlighting used otherwise.


    -- Tree Sitter
    TSError                 { LspDiagnosticsVirtualTextError };     -- For syntax/parser errors.
    TSURI                   { Underlined, fg = cyan[1] };           -- Any URI like a link or email.

    TSEmphasis              { Italic };    -- For text to be represented with emphasis.
    TSUnderline             { Underlined };    -- For text to be represented with an underline.
    TSStrong                { Bold }, -- For text to be represented with strong.
    TSTitle                 { Title };    -- Text that is part of a title.

    TSPunctDelimiter        { Delimiter }, -- For delimiters ie: `.`
    TSPunctBracket          { TSPunctDelimiter }, -- For brackets and parens.
    TSPunctSpecial          { TSPunctDelimiter }, -- For special punctutation that does not fall in the catagories before.

    TSConstant              { Constant }, -- For constants
    TSConstBuiltin          { Constant }, -- For constant that are built in the language: `nil` in Lua.
    TSConstMacro            { Constant }, -- For constants that are defined by macros: `NULL` in C.

    -- TSFuncMacro          { }, -- For macro defined fuctions (calls and definitions): each `macro_rules` in Rust.
    -- TSNamespace          { }, -- For identifiers referring to modules and namespaces.
    -- TSInclude            { }, -- For includes: `#include` in C, `use` or `extern crate` in Rust, or `require` in Lua.
    -- TSAnnotation         { }, -- For C++/Dart attributes, annotations that can be attached to the code to denote some kind of meta information.

    -- TSStringEscape       { }, -- For escape characters within a string.
    -- TSVariableBuiltin    { }, -- Variable names that are defined by the languages, like `this` or `self`.
    -- TSFuncBuiltin        { }, -- For builtin functions: `table.insert` in Lua.

    TSConstructor           { }, -- For constructor calls and definitions: `{ }` in Lua, and Java constructors.

    -- TSString             { }, -- For strings.
    -- TSStringRegex        { }, -- For regexes.
    -- TSCharacter          { }, -- For characters.
    -- TSLiteral            { }, -- Literal text.

    -- TSNumber             { }, -- For integers.
    -- TSBoolean            { }, -- For booleans.
    -- TSFloat              { }, -- For floats.

    TSTag                   { fg = orange[10] },  -- html tags

    -- TSFunction           { }, -- For function (calls and definitions).
    -- TSParameter          { fg = blue[10] }, -- For parameters of a function.
    -- TSParameterReference { TSParameter }, -- For references to parameters of a function.
    -- TSMethod             { }, -- For method calls and definitions.
    -- TSField              { }, -- For fields.
    -- TSProperty           { }, -- Same as `TSField`.

    -- TSOperator           { }, -- For any operator: `+`, but also `->` and `*` in C.

    -- TSConditional        { }, -- For keywords related to conditionnals.
    -- TSRepeat             { }, -- For keywords related to loops.
    -- TSLabel              { }, -- For labels: `label:` in C and `:label:` in Lua.
    -- TSKeyword            { }, -- For keywords that don't fall in previous categories.
    -- TSKeywordFunction    { }, -- For keywords used to define a fuction.
    -- TSException          { }, -- For exception related keywords.

    -- TSType               { }, -- For types.
    -- TSTypeBuiltin        { }, -- For builtin types (you guessed it, right ?).

    -- TSText               { }, -- For strings considered text in a markup language.
    TSVariable              { fg = c.fg }, -- Any variable name that does not have another highlight.



    -- Other Pluyins
    -- diff
    diffAdded               { fg = c.add };
    diffChanged             { fg = c.mod };
    diffRemoved             { fg = c.del };
    diffOldFile             { bg = c.del };
    diffNewFile             { bg = c.add };
    diffFile                { fg = c.comment };
    diffLine                { fg = c.fg };
    diffIndexLine           { fg = c.comment };

    -- gitsigns
    GitSignsAdd             { fg = c.add };
    GitSignsAddNr           { fg = c.add };
    GitSignsAddLn           { fg = c.add };
    GitSignsChange          { fg = c.mod };
    GitSignsChangeNr        { fg = c.mod };
    GitSignsChangeLn        { fg = c.mod };
    GitSignsDelete          { fg = c.del };
    GitSignsDeleteNr        { fg = c.del };
    GitSignsDeleteLn        { fg = c.del };

    -- cmp
    CmpItemAbbr             { fg = c.fold };
    CmpItemAbbrDeprecated   { CmpItemAbbr,      gui = 'strikethrough' };
    CmpItemAbbrMatch        { fg = c.fg,        gui = 'bold' };
    CmpItemAbbrMatchFuzzy   { CmpItemAbbrMatch, gui = '' };
    -- CmpItemKind             { };
    -- CmpItemMenu             { bg = debug[1], fg = debug[10] };   
    CmpItemKindText         { fg = c.fg       };
    CmpItemKindMethod       { fg = c.func     };
    CmpItemKindFunction     { fg = c.func     };
    CmpItemKindConstructor  { fg = c.special  };
    CmpItemKindField        { fg = c.entity   };
    CmpItemKindVariable     { fg = c.keyword  };
    CmpItemKindClass        { fg = c.type     };
    CmpItemKindInterface    { fg = c.type     };
    CmpItemKindModule       { fg = c.special  };
    CmpItemKindProperty     { fg = c.entity   };
    CmpItemKindUnit         { fg = c.keyword  };
    CmpItemKindValue        { fg = c.string   };
    CmpItemKindEnum         { fg = c.keyword  };
    CmpItemKindKeyword      { fg = c.keyword  };
    CmpItemKindSnippet      { fg = c.constant };
    CmpItemKindColor        { fg = c.string   };
    CmpItemKindFile         { fg = c.fg       };
    CmpItemKindReference    { fg = c.entity   };
    CmpItemKindFolder       { fg = c.fg       };
    CmpItemKindEnumMember   { fg = c.string   };
    CmpItemKindConstant     { fg = c.constant };
    CmpItemKindStruct       { fg = c.string   };
    CmpItemKindEvent        { fg = c.special  };
    CmpItemKindOperator     { fg = c.operator };
    CmpItemKindTypeParameter{ fg = c.type     };

    -- scrollview
    ScrollView              { bg = c.mg };

    -- scrollbar
    ScrollbarHandle         { ScrollView };
    ScrollbarSearchHandle   { ScrollView, fg = c.fg };
    ScrollbarSearch         { fg = c.fg };
    ScrollbarErrorHandle    { ScrollView, fg = c.err };
    ScrollbarError          { fg = c.err };
    ScrollbarWarnHandle     { ScrollView, fg = c.warn };
    ScrollbarWarn           { fg = c.warn };
    ScrollbarInfoHandle     { ScrollView, fg = c.info };
    ScrollbarInfo           { fg = c.info };
    ScrollbarHintHandle     { ScrollView, fg = c.hint };
    ScrollbarHint           { fg = c.hint };
    ScrollbarMiscHandle     { ScrollView, fg = c.fg };
    ScrollbarMisc           { fg = c.fg };

    -- nvim-tree
    -- NvimTreeNormal          { bg = ui.bg_alt };
    NvimTreeRootFolder      { fg = c.fg };
    NvimTreeFolderIcon      { fg = c.fg };
    NvimTreeFileIcon        { fg = c.fg };
    NvimTreeSpecialFile     { fg = c.fg };
    NvimTreeExecFile        { gui = 'bold' };
    NvimTreeIndentMarker    { fg = c.mg };
    NvimTreeOpenedFile      { fg = c.fg };
    NvimTreeGitDirty        { fg = c.dirty.mix(c.fg, 20) };
    NvimTreeGitStaged       { fg = c.staged.mix(c.fg, 20), gui = 'bold' };
    NvimTreeGitMerge        { fg = c.merge.mix(c.fg, 20) };
    NvimTreeGitRenamed      { fg = c.renamed.mix(c.fg, 20) };
    NvimTreeGitDeleted      { fg = c.deleted.mix(c.fg, 20) };
    NvimTreeLspDiagnosticsError       { DiagnosticSignError };
    NvimTreeLspDiagnosticsWarning     { DiagnosticSignWarn };
    NvimTreeLspDiagnosticsInformation { DiagnosticSignInfo };
    NvimTreeLspDiagnosticsHint        { DiagnosticSignHint };

    -- vim-quickui
    QuickBG                 { bg = c.bg, fg = c.fg };
    QuickSel                { Search };
    QuickKey                { fg = c.err };
    QuickOff                { fg = c.mg };
    QuickHelp               { WarningMsg };

    -- outline
    FocusedSymbol           { Search };
    SymbolsOutlineConnector { fg = c.mg };

    -- telescope
    TelescopeBorder         { fg = c.mg };
    TelescopeTitle          { fg = c.fg };
    TelescopeMatching       { Search };

    -- harpoon
    HarpoonBorder           { fg = c.mg };

    -- startup-time
    StartupTimeStartupKey   { Bold };
    StartupTimeStartupValue { Bold };
    StartupTimeHeader       { Comment };
    StartupTimeSourcingEvent{ fg = cyan[5] };
    StartupTimeOtherEvent   { fg = purple[5] };
    StartupTimeTime         { fg = red[5] };
    StartupTimePercent      { fg = red[5] };
    StartupTimePlot         { fg = red[1] };

    -- notify
    NotifyERRORBorder       { fg = c.err };
    NotifyWARNBorder        { fg = c.warn };
    NotifyINFOBorder        { fg = c.info };
    NotifyDEBUGBorder       { fg = debug[10] };
    NotifyTRACEBorder       { fg = debug[1] };
    NotifyERRORIcon         { NotifyERRORBorder };
    NotifyWARNIcon          { NotifyWARNBorder };
    NotifyINFOIcon          { NotifyINFOBorder };
    NotifyDEBUGIcon         { NotifyDEBUGBorder };
    NotifyTRACEIcon         { NotifyTRACEBorder };
    NotifyERRORTitle        { NotifyERRORBorder };
    NotifyWARNTitle         { NotifyWARNBorder };
    NotifyINFOTitle         { NotifyINFOBorder };
    NotifyDEBUGTitle        { NotifyDEBUGBorder };
    NotifyTRACETitle        { NotifyTRACEBorder };
    NotifyERRORBody         { Normal };
    NotifyWARNBody          { Normal };
    NotifyINFOBody          { Normal };
    NotifyDEBUGBody         { Normal };
    NotifyTRACEBody         { Normal };

    -- ultest
    UltestPass              { fg = c.add };
    UltestFail              { fg = c.err };
    UltestRunning           { fg = c.warn };
    UltestBorder            { fg = c.mg };
    UltestSummaryInfo       { fg = c.fold };
    UltestSummaryFile       { UltestSummaryInfo, gui = 'bold'};
    UltestSummaryNamespace  { UltestSummaryFile };

    -- custom groups (convenience color groups that won't automatically apply)
    DebugFg                 { fg = debug[10] };
    DebugBg                 { bg = debug[1] };
    DebugAll                { bg = debug[1], fg = debug[10] };
    NormalAlt               { bg = c.bg_alt };
    SnippetPassiveIndicator { Comment };
    SnippetInsertIndicator  { fg = c.fg };
    SnippetChoiceIndicator  { fg = c.hint };
  }
end)

return theme

-- rotate(), saturate(), desaturate(), lighten(), darken()
-- ro(), sa() de(), li(), da(), mix(), readable()
-- hue(), saturation(), lightness()
-- .h, .s, .l
-- tostring(), "Concatenation: " .. color
