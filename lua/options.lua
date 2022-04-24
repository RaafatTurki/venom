--- defines various settings, options, constants, enums and global variables.
-- @module options

-- vim builtin options
vim.o.number            = true
vim.o.wrap              = false
vim.o.cursorline        = true
vim.o.swapfile          = false
vim.o.showmode          = false
vim.o.hidden            = true                          -- (required by toggleterm)

vim.o.termguicolors     = true
vim.o.splitbelow        = true
vim.o.splitright        = true
vim.o.writebackup       = false
vim.o.ignorecase        = true
vim.o.smartcase         = true
vim.o.autoread          = true
vim.o.hlsearch          = true
vim.o.incsearch         = true
vim.o.list              = false
vim.o.secure            = true
vim.o.pumheight         = 16
vim.o.cmdheight         = 1
vim.o.showtabline       = 1
vim.o.laststatus        = 3
vim.o.scrolloff         = 4
vim.o.scroll            = 15
vim.o.updatetime        = 100
vim.o.timeoutlen        = 200
vim.o.mouse             = 'a'
vim.o.clipboard         = 'unnamedplus'
vim.o.inccommand        = 'split'
vim.o.signcolumn        = 'yes'
vim.o.encoding          = 'utf-8'
vim.o.fileencoding      = 'utf-8'
vim.o.guicursor         = 'a:hor25,v:block,i:ver25'
vim.o.completeopt       = 'menu,menuone,noselect'       -- (required by cmp)
vim.o.backspace         = 'indent,eol,nostop'
vim.o.listchars         = 'trail:_,tab:  │'
vim.o.shell             = '/usr/bin/fish'

-- folding
-- vim.o.foldcolumn        = '1'
vim.o.foldmethod        = 'expr'                        -- Tree sitter folding
vim.o.foldexpr          = 'nvim_treesitter#foldexpr()'  -- Tree sitter folding
vim.o.foldtext          = "substitute(getline(v:foldstart),'\t',repeat(' ',&tabstop),'g').' ... '.trim(getline(v:foldend))"   -- Sexy minimal folds
vim.o.foldnestmax       = 10                            -- Maximum amount of nested folds
vim.o.foldminlines      = 1                             -- Minimum amount of lines per fold
-- vim.o.sessionoptions    = 'blank,curdir,folds,help,tabpages,winsize,winpos,terminal,globals'

-- indenting
vim.o.shiftwidth        = 2                             -- How many whitespaces is an indent
vim.o.tabstop           = 2                             -- How many whitespaces is a /t
vim.o.softtabstop       = 2                             -- How many whitespaces is a <Tab> or <BS> key press
vim.o.expandtab         = true                          -- Use spaces instead of tabs
-- vim.o.copyindent        = true
-- vim.o.smartindent       = true
-- vim.o.autoindent        = false

-- opt options
vim.opt.fillchars = {
  fold      = ' ',
  eob       = ' ',
  diff      = '╱',
  foldclose =	'>',
  foldopen  = '┬',
  foldsep   = '│',
}
vim.opt.spelllang       = { 'en_us' }                   -- Spelling dictionary
vim.opt.whichwrap:append  '<,>,[,],h,l'                 -- Move to next line with theses keys
vim.opt.shortmess:append  'c'                           -- Don't pass messages to |ins-completion-menu| (required by compe)


-- diagnostic options
vim.diagnostic.config {
  signs = true,
  update_in_insert = true,
  severity_sort = true,
  underline = {
    -- severity = vim.diagnostic.severity.INFO,
  },
  virtual_text = {
    spacing = 2,
    prefix = '●',
    -- severity_limit = vim.diagnostic.severity.INFO,
  },
  float = {
    scope = "cursor",
    border = "single",
    header = "",
    prefix = "",
    focus = false,
    format = function(diagnostic) return string.format("%s: %s", diagnostic.source, diagnostic.message) end,
  }
}


-- venom options
venom = {
  -- actions are tables that can hold lua functions and vim commands for later execution (when invoked)
  -- TODO: make it the responsibility of the related service to instantiate an action here
  actions = {
    pm_post_complete = U.Action():new(),
    clear = U.Action():new(),
  },
  -- features is a table that can hold strings representing the availability of said feature for later querying.
  -- each string must be in the form of <TYPE>:<name> where TYPE is one of the FT enum values (for example "PLUGIN:nvim-cmp" means the plugin cmp is available)
  features = {
    list = {},
    add = function(self, feature_type, feature_name) table.insert(self.list, feature_type..":"..feature_name) end,
    add_str = function(self, feature_str) table.insert(self.list, feature_str) end,
    has = function(self, feature_type, feature_name) return U.has_value(self.list, feature_type..":"..feature_name) end,
    has_str = function(self, feature_str) return U.has_value(self.list, feature_str) end,
  },
  icons = {
    --  
    diagnostic_states = {
      outline = { Error = " ",   Warn = " ",  Hint = " ",  Info = " "  },
      full    = { Error = " ",   Warn = " ",  Hint = " ",  Info = " "  },
      cozette = { Error = " ",   Warn = "⚠ ",  Hint = "🌳",  Info = " "  },
      letters = { Error = "E ",   Warn = "W ",  Hint = "H ",  Info = "I "  },
      none    = { Error = "  ",   Warn = "  ",  Hint = "  ",  Info = "  "  },
    },
    item_kinds = {
        -- ⌂ θ ғ  Ω
      cozette = {
        Text            = '',
        Method          = 'ƒ',
        Function        = 'ƒ',
        Constructor     = 'ƒ',
        Field           = 'ғ',
        Variable        = 'v',
        Class           = '',
        Interface       = '',
        Module          = '',
        Property        = '',
        Unit            = 'Θ',
        Value           = '⚐',
        Enum            = '⚐',
        Keyword         = 'ĸ',
        Snippet         = '□',
        Color           = 'c',
        File            = '',
        Reference       = '',
        Folder          = '',
        EnumMember      = '⚑',
        Constant        = 'π',
        Struct          = '☴',
        Event           = '',
        Operator        = '∓',
        TypeParameter   = '',
      },
      -- 
      codeicons = {
        Text            = ' ',
        Method          = ' ',
        Function        = ' ',
        Constructor     = ' ',
        Field           = ' ',
        Variable        = ' ',
        Class           = ' ',
        Interface       = ' ',
        Module          = ' ',
        Property        = ' ',
        Unit            = ' ',
        Value           = ' ',
        Enum            = ' ',
        Keyword         = ' ',
        Snippet         = '⛶ ',
        Color           = ' ',
        File            = ' ',
        Reference       = ' ',
        Folder          = ' ',
        EnumMember      = ' ',
        Constant        = ' ',
        Struct          = ' ',
        Event           = ' ',
        Operator        = ' ',
        TypeParameter   = ' ',
      },
      nerdfont = {
        Text            = ' ',
        Method          = ' ',
        Function        = ' ',
        Constructor     = ' ',
        Field           = 'ﴲ ',
        Variable        = ' ',
        Class           = ' ',
        Interface       = 'ﰮ ',
        Module          = ' ',
        Property        = '襁',
        Unit            = ' ',
        Value           = ' ',
        Enum            = ' ',
        Keyword         = ' ',
        Snippet         = ' ',
        Color           = ' ',
        File            = ' ',
        Reference       = ' ',
        Folder          = ' ',
        EnumMember      = ' ',
        Constant        = ' ',
        Struct          = 'ﳤ ',
        Event           = ' ',
        Operator        = ' ',
        TypeParameter   = ' ',
      },
    },
  }
}


-- enums
--- log levels
LL = {
  DEBUG = vim.log.levels.DEBUG,
  ERROR = vim.log.levels.ERROR,
  INFO = vim.log.levels.INFO,
  TRACE = vim.log.levels.TRACE,
  WARN = vim.log.levels.WARN,
}

--- feature types
FT = {
  PLUGIN = "PLUGIN",
  KEY = "KEY",
  THEME = "THEME",
  MISC = "MISC",
  BIN = "BIN",
  FUNC = "FUNC",
  LSP = "LSP",
}
