local icons = require "helpers.icons".icons

-- misc
vim.o.termguicolors   = true
vim.o.confirm         = false
vim.o.updatetime      = 100  -- used for the CursorHold event
vim.o.timeoutlen      = 200  -- used for keymap squences timeout

-- wrapping
vim.o.wrap            = false
-- vim.o.wrapscan        = true

-- indentation
vim.o.shiftwidth      = 2
vim.o.tabstop         = 2
vim.o.expandtab       = true

-- auxilary files
vim.o.swapfile        = false
vim.o.undofile        = true
vim.o.writebackup     = false
vim.o.viewoptions     = "cursor,folds"
-- vim.o.viewoptions     = "cursor"

-- cursor
-- vim.o.cursorline      = true
vim.o.guicursor       = 'a:hor25,v:block,i:ver25'

-- text display
vim.o.list            = true
vim.o.conceallevel    = 1
vim.o.termbidi        = true
-- vim.o.arabic          = true

-- UI layout
vim.o.laststatus      = 3
vim.o.showtabline     = 2
vim.o.cmdheight       = 0
vim.o.showcmdloc      = 'statusline'
vim.o.splitkeep       = 'screen'
vim.o.splitbelow      = true
vim.o.splitright      = true
vim.o.showmode        = false
vim.o.inccommand      = 'split'
vim.o.showcmdloc      = 'statusline'
vim.o.signcolumn      = 'no'
vim.o.number          = true
-- vim.o.colorcolumn     = "120"

-- mouse
vim.o.mouse           = 'a'
-- vim.o.mousescroll     = "ver:0,hor:0"

-- keyboard
vim.o.backspace       = 'indent,eol,nostop'
vim.o.delcombine      = true

-- os
vim.o.clipboard       = 'unnamed,unnamedplus'
vim.o.shell           = '/usr/bin/fish'

-- folding
vim.o.foldenable      = true
-- vim.o.foldmethod      = 'indent'
-- vim.o.foldcolumn      = '1'
-- vim.o.foldlevel       = 99
-- vim.o.foldlevelstart  = -1
-- vim.o.foldnestmax     = 10 -- Maximum amount of nested folds
-- vim.o.foldminlines    = 1 -- Minimum amount of lines per fold

-- typing
-- vim.o.iskeyword       = '@,48-57,192-255' -- removed '_' so that motion commands work with underscores
-- vim.o.completeopt      = 'menuone,noinsert,noselect,popup'

-- casing
-- vim.o.ignorecase      = true
-- vim.o.smartcase       = true


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
  tab = "▏ ",
  trail = ".",
  extends = "»",
  precedes = "«",
}
vim.opt.nrformats:append 'unsigned'
vim.opt.whichwrap:append '<,>,[,]' -- arrow keys can wrap around to next line
vim.opt.display:append 'uhex'
vim.opt.spelllang     = { 'en_us' }


-- spell            = true,
-- scrolloff        = 4,
-- wildmenu         = false,
-- encoding         = 'utf-8',
-- fileencoding     = 'utf-8',
-- sessionoptions   = 'blank,buffers,curdir,help,tabpages,winsize,globals'
