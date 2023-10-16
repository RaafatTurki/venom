local map = require "helpers.keys".map

-- common
map("n", "<C-s>",     vim.cmd.write, "Write")
map("i", "<C-s>",     vim.cmd.write, "Write")
map("n", "<C-c>",     vim.cmd.quit, "Quit")
map("n", "<C-q>",     vim.cmd.quitall, "Quit All")
map("n", "<C-l>",     vim.cmd.nohl, "Clear highlights")
map("n", "<C-z>",     vim.cmd.undo, "Undo")

-- diagnostics
map("n", "<leader>x", vim.diagnostic.open_float, "Show diagnostics under cursor")

-- buffer navigation
map("n", "<A-Right>", ":bnext<CR>", "Next buffer")
map("n", "<A-Left>",  ":bprevious<CR>", "Previous buffer")

-- goto and display to nex/prev lsp diagnositc
map("n", 'd<Left>',           function() vim.diagnostic.goto_prev({ float = false }) end, "")
map("n", 'd<Right>',          function() vim.diagnostic.goto_next({ float = false }) end, "")

-- tabs
-- map("n", '<C-t>',             vim.cmd.tabnew, "")
-- map("n", '<S-Right>',         vim.cmd.tabnext, "")
-- map("n", '<S-Left>',          vim.cmd.tabprevious, "")

-- indent
map("n", "<S-Tab>",   "<<", "Deindent")
map("n", "<Tab>",     ">>", "Indent")
map("v", "<S-Tab>",   "<gv", "Visual deindent")
map("v", "<Tab>",     ">gv", "Visual indent")

-- page shift
map("n", "<C-Up>",    "<C-y>k", "Shift page up one line")
map("n", "<C-Down>",  "<C-e>j", "Shift page down one line")

-- quic fix list
map("n", "<S-Up>",    vim.cmd.cprevious, "QFList previous")
map("n", "<S-Down>",  vim.cmd.cnext, "QFList next")

-- beginning and end of line
map("n", "<S-Left>", "^", "Go to beginning of line")
map("n", "<S-Right>", "$", "Go to end of line")
map("x", "<S-Left>", "^", "Go to beginning of line")
map("x", "<S-Right>", "$", "Go to end of line")

-- resize with arrows
-- map("n", "<C-w><C-Up>", ":resize +2<CR>")
-- map("n", "<C-w><C-Down>", ":resize -2<CR>")
-- map("n", "<C-w><C-Left>", ":vertical resize +2<CR>")
-- map("n", "<C-w><C-Right>", ":vertical resize -2<CR>")


-- misc
-- preserve cursor position on visual yank
map("x", "y",         "ygv<ESC>", "")
-- move cursor to the start of the line on format
map("n", "==",        "==_", "")
map("x", "=",         "=gv_", "")
-- copy and retain visual selection in visual mode
map("x", "Y",         "ygv", "")
-- make Y copy to end of line in normal mode
map("n", "Y",         "y$", "")
-- go to end after a join
map("n", "J",         "J$", "")
-- split (opposite of J)
map("n", "S",         "T hr<CR>k$", "")


-- motions
-- entire buffer (https://vi.stackexchange.com/a/2321)
map("o", "aa",        ":<c-u>normal! mzggVG<cr>`z")

