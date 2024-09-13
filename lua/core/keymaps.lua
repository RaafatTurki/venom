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
map("n", 'd<Left>',           function() vim.diagnostic.goto_prev({ float = false }) end, "Go To Previous Diagnostic")
map("n", 'd<Right>',          function() vim.diagnostic.goto_next({ float = false }) end, "Go To Next Diagnostic")

-- commenting
-- VimEnter because it needs to be set after the _defaults.lua has executed
map("n", "<leader>c", "gcc", { remap = true, desc = "Comment line" }, { "VimEnter" })
map("x", "<leader>c", "gc", { remap = true, desc = "Comment visual" }, { "VimEnter" })

-- tabs
-- map("n", '<C-t>',             vim.cmd.tabnew, "")
-- map("n", '<S-Right>',         vim.cmd.tabnext, "")
-- map("n", '<S-Left>',          vim.cmd.tabprevious, "")

-- indent
map("n", "<S-Tab>",   "<<", "Deindent")
map("n", "<Tab>",     ">>", "Indent")
map("x", "<S-Tab>",   "<gv", "Visual deindent")
map("x", "<Tab>",     ">gv", "Visual indent")

-- page shift
map("n", "<C-Up>",    "<C-y>k", "Shift page up one line")
map("n", "<C-Down>",  "<C-e>j", "Shift page down one line")

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
map("x", "y",         "ygv<ESC>")
-- preserve cursor position on *
map("n", "*",         "*N")
-- preserve last yarn on visual paste
-- map('v', 'p',         '"_dP')
-- move cursor to the start of the line on format
-- map("n", "==",        "==_", "")
-- map("x", "=",         "=gv_", "")
-- copy and retain visual selection in visual mode
map("x", "Y",         "ygv")
-- go to end after a join
map("n", "J",         "J$")
-- split (opposite of J)
map("n", "S",         "T hr<CR>k$")
-- make x use the black hole register
map("n", "x",         '"_x')
map("x", "x",         '"_x')
