local U = require "helpers.utils"
local icons = require "helpers.icons".icons

-- key-val options
local opts = {
  termguicolors   = true,
  shiftwidth      = 2,
  tabstop         = 2,
  expandtab       = true,
  swapfile        = false,
  showmode        = false,
  writebackup     = false,
  splitbelow      = true,
  splitright      = true,
  -- ignorecase      = true,
  wrapscan        = true,
  -- smartcase       = true,
  list            = true,
  cursorline      = true,
  confirm         = true,
  undofile        = true,
  wrap            = false,
  updatetime      = 100, -- used for the CursorHold event
  timeoutlen      = 200, -- used for keymap squences timeout
  conceallevel    = 1,
  laststatus      = 3,
  showtabline     = 2,
  -- mousescroll     = "ver:0,hor:0",
  mouse           = 'a',
  inccommand      = 'split',
  showcmdloc      = 'statusline',
  splitkeep       = 'screen',
  clipboard       = 'unnamed,unnamedplus',
  guicursor       = 'a:hor25,v:block,i:ver25',
  backspace       = 'indent,eol,nostop',
  shell           = '/usr/bin/fish',
  foldmethod      = 'indent',
  foldtext        = "substitute(getline(v:foldstart),'\t',repeat(' ',&tabstop),'g').' ... '.trim(getline(v:foldend))",
  viewoptions     = "cursor,folds",

  number          = true,
  foldcolumn      = '1',
  signcolumn      = 'no',
  -- iskeyword       = '@,48-57,192-255', -- removed '_' so that motion commands work with underscores

  -- colorcolumn     = U.seq(120, 999, ',', 1),
  -- colorcolumn     = "120",

  -- cmdheight       = 0,
  -- completeopt      = 'menuone,noinsert,noselect,popup',

  -- foldcolumn       = '1',
  -- foldlevel        = 99
  -- foldlevelstart   = -1
  -- foldnestmax      = 10 -- Maximum amount of nested folds
  -- foldminlines     = 1 -- Minimum amount of lines per fold

  -- nvim 0.10
  -- foldexpr       = "v:lua.vim.treesitter.foldexpr()",
  -- foldtext       = "v:lua.vim.treesitter.foldtext()",
}

for opt, val in pairs(opts) do
  vim.o[opt] = val
end


-- opt options
vim.opt.fillchars:append {
  fold = ' ',
  eob  = ' ',
  diff = '╱',
  foldclose = icons.misc.collapsed,
  foldopen  = icons.misc.expanded,
  foldsep   = ' ',
}
vim.opt.listchars:append {
  trail = "."
}
vim.opt.whichwrap:append '<,>,[,]' -- arrow keys can wrap around to next line
vim.opt.display:append 'uhex'
vim.opt.spelllang     = { 'en_us' }


-- spell            = true,
-- scrolloff        = 4,
-- wildmenu         = false,
-- encoding         = 'utf-8',
-- fileencoding     = 'utf-8',
-- sessionoptions   = 'blank,buffers,curdir,help,tabpages,winsize,globals'
