--- defines vanialla options, constants, enums and global variables.
-- @module options

-- use filetype.lua instead of filetype.vim
-- vim.g.did_load_filetypes = 0
-- vim.g.do_filetype_lua   = 1

vim.cmd.colorscheme 'venom'

-- vim builtin options
vim.o.number         = true
vim.o.wrap           = false
vim.o.cursorline     = true
vim.o.swapfile       = false
vim.o.showmode       = false
vim.o.hidden         = true -- (required by toggleterm)
vim.o.termguicolors  = true
vim.o.splitbelow     = true
vim.o.splitright     = true
vim.o.spell          = false
vim.o.writebackup    = false
vim.o.ignorecase     = true
vim.o.smartcase      = true
vim.o.autoread       = true
vim.o.hlsearch       = true
vim.o.incsearch      = true
vim.o.list           = false
vim.o.secure         = true
vim.o.breakindent    = true
vim.o.pumheight      = 16
vim.o.cmdheight      = 1
vim.o.showtabline    = 2
vim.o.laststatus     = 3
vim.o.scrolloff      = 4
vim.o.scroll         = 15
vim.o.updatetime     = 100
vim.o.timeoutlen     = 200
vim.o.conceallevel   = 1
vim.o.wildmenu       = false
vim.o.clipboard      = 'unnamedplus'
vim.o.signcolumn     = 'yes:3'
vim.o.encoding       = 'utf-8'
vim.o.fileencoding   = 'utf-8'
vim.o.guicursor      = 'a:hor25,v:block,i:ver25'
vim.o.completeopt    = 'menu,menuone,noselect'
vim.o.backspace      = 'indent,eol,nostop'
vim.o.listchars      = 'trail:_,tab:  │'
vim.o.shell          = '/usr/bin/fish'
-- folding
-- vim.o.foldcolumn        = '1'
-- vim.o.foldenable        = true
-- vim.o.foldlevel         = 99
vim.o.foldmethod     = 'expr' -- Tree sitter folding
vim.o.foldexpr       = 'nvim_treesitter#foldexpr()' -- Tree sitter folding
vim.o.foldtext       = "substitute(getline(v:foldstart),'\t',repeat(' ',&tabstop),'g').' ... '.trim(getline(v:foldend))" -- Sexy minimal folds
vim.o.foldnestmax    = 10 -- Maximum amount of nested folds
vim.o.foldminlines   = 1 -- Minimum amount of lines per fold
vim.o.sessionoptions = 'blank,buffers,curdir,folds,help,tabpages,winsize'
vim.o.viewoptions    = 'cursor,curdir'
-- indenting
vim.o.shiftwidth     = 2 -- How many whitespaces is an indent
vim.o.tabstop        = 2 -- How many whitespaces is a /t
vim.o.softtabstop    = 2 -- How many whitespaces is a <Tab> or <BS> key press
vim.o.expandtab      = true -- Use spaces instead of tabs
-- vim.o.copyindent        = true
-- vim.o.smartindent       = true
-- vim.o.autoindent        = false
-- opt options
vim.opt.fillchars    = {
  fold = ' ',
  eob  = ' ',
  diff = '╱',
  -- foldclose =	'>',
  -- foldopen  = ' ',
  -- foldsep   = ' ',
  -- foldopen  = '┬',
  -- foldsep   = '│',
}
vim.opt.spelllang    = { 'en_us' }
vim.opt.whichwrap:append '<,>,[,],h,l' -- Move to next line with theses keys
-- vim.opt.shortmess:append 'c' -- Don't pass messages to |ins-completion-menu| (required by compe)

-- diagnostic options
vim.diagnostic.config {
  signs = true,
  update_in_insert = false,
  severity_sort = true,
  -- underline = {
  --   -- severity = vim.diagnostic.severity.INFO,
  -- },
  virtual_text = false,
  -- virtual_text = {
  --   spacing = 2,
  --   prefix = '●',
  --   -- severity_limit = vim.diagnostic.severity.INFO,
  -- },
  float = {
    scope = 'cursor',
    border = 'single',
    header = '',
    prefix = '',
    -- format = function(diag)
    --   local msg = diag.message
    --   local src = diag.source
    --   local code = diag.user_data.lsp.code
    --   local icon = venom.icons.diagnostic_states[venom.severity_names[diag.severity]]
    --
    --   -- remove dots
    --   msg = msg:gsub('%.', '')
    --   src = src:gsub('%.', '')
    --   code = code:gsub('%.', '')
    --
    --   -- remove starting and trailing spaces
    --   msg = msg:gsub('[ \t]+%f[\r\n%z]', '')
    --   src = src:gsub('[ \t]+%f[\r\n%z]', '')
    --   code = code:gsub('[ \t]+%f[\r\n%z]', '')
    --
    --   return string.format("%s%s > %s (%s)", icon, msg, src, code)
    -- end,
  }
}
