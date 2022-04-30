--- defines commands, autocommands and keybinds
-- @module bind
local M = {}

M.bind_leader = U.Service():new(function()
  M.key:invoke({'<Space>', '<Nop>', mode = ''})
  U.gvar('mapleader'):set(' ')
end)

M.keys = {}

-- a keymap object is {string, string, opts = {}, mode = string}
M.key = U.Service():new(function(keymap)
  keymap.opts = keymap.opts or { noremap = true, silent = true }
  keymap.mode = keymap.mode and vim.split(keymap.mode, ' ') or 'n'

  vim.keymap.set(keymap.mode, keymap[1], keymap[2], keymap.opts)
  table.insert(M.keys, keymap)
end)

M.setup = U.Service():new(function()
  -- BASE
  -- write, undo, quit
  M.key:invoke {'<C-s>',            '<CMD>write<CR><ESC>', mode = 'n v i'}
  M.key:invoke {'<C-z>',            '<CMD>undo<CR>', mode = 'n v i'}
  M.key:invoke {'<C-q>',            '<CMD>quit<CR>', mode = 'n v i'}
  -- page shift up/down, select all
  M.key:invoke {'<C-Up>',           '<C-y>k'}
  M.key:invoke {'<C-Down>',         '<C-e>j'}
  -- M.key:invoke {'<C-a>',            ':%'}
  -- indent
  M.key:invoke {'<Tab>',            '>>_'}
  M.key:invoke {'<S-Tab>',          '<<_'}
  M.key:invoke {'<Tab>',            '>gv', mode = 'v'}
  M.key:invoke {'<S-Tab>',          '<gv', mode = 'v'}
  -- switch between last 2 windows
  M.key:invoke {'<A-Tab>',          '<C-w>p'}
  -- make x delete without copying
  -- M.key:invoke {'x',                '"_x', mode = 'v n'}
  M.key:invoke {'X',                '"_x', mode = 'v n'}
  -- make Y copy to end of line
  M.key:invoke {'Y',                'y$'}
  -- go to end after a join
  M.key:invoke {'J',                'J$'}
  -- split (opposite of J)
  M.key:invoke {'S',                'T hr<CR>k$'}
  -- open man pages in new tabs
  M.key:invoke {'K',                ':tab Man<CR>'}
  -- center line after n/N
  M.key:invoke {'n',                'nzzzv'}
  M.key:invoke {'N',                'Nzzzv'}
  -- re-edit current buffer
  M.key:invoke {'<F5>',             '<CMD>e<CR>'}
  -- clear action
  venom.actions.clear:subscribe [[let @/ = ""]]
  venom.actions.clear:subscribe(U.clear_prompt)
  M.key:invoke {'<c-l>',           function() venom.actions.clear:invoke() end}
  -- terminal smart escape
  M.key:invoke {'<Esc>',            "v:lua.TermSmartEsc(b:terminal_job_pid, '"..'<Esc>'.."')", mode = 't', opts = { noremap = true, expr = true } }
  -- undo breakpoints
  local undo_break_points = {',', '.', '!', '?', '-'}
  for _, break_point in pairs(undo_break_points) do
    M.key:invoke {break_point,     break_point..'<C-g>u', mode = 'i'}
  end
  -- goto and display to nex/prev lsp diagnositc
  M.key:invoke {'d<Left>',          function() vim.diagnostic.goto_prev({ float = false }) end}
  M.key:invoke {'d<Right>',         function() vim.diagnostic.goto_next({ float = false }) end}
  -- tabs
  M.key:invoke {'<C-t>',            '<CMD>tabnew<CR>'}
  M.key:invoke {'<A-Right>',        '<CMD>tabnext<CR>'}
  M.key:invoke {'<A-Left>',         '<CMD>tabprevious<CR>'}

  M.key:invoke {'<A-z>',            function() vim.notify("hi friend") end}

  -- MOTIONS
  -- M.key:invoke {'a',                ':<c-u>normal! $v^<CR>', mode = 'o'}
  M.key:invoke {'a',                ':<c-u>normal! ggVG<CR>', mode = 'o'}

  -- old
  -- shifting line
  -- M.key:invoke {'<A-Down>',         '<CMD>m .+1<CR>'}
  -- M.key:invoke {'<A-Up>',           '<CMD>m .-2<CR>'}
  -- M.key:invoke {'<A-Down>',         '<CMD>m .+1<CR><ESC>i', mode = 'i'}
  -- M.key:invoke {'<A-Up>',           '<CMD>m .-2<CR><ESC>i', mode = 'i'}
end)

M.setup_plugins = U.Service():new(function()
  -- TODO move to related services
  -- open uri under cursor
  M.key:invoke {'gx',               OpenURIUnderCursor}
  -- cycle theme
  M.key:invoke {'<leader>t',        Themes.theme_cycle}


  -- PLUGINS
  -- packer sync
  M.key:invoke {'<leader>p',        '<CMD>PackerSync<CR>'}
  -- nvim tree
  M.key:invoke {'<C-e>',            '<CMD>NvimTreeToggle<CR>', mode = 'i n'}
  -- harpoon
  M.key:invoke {'<C-p>',            require 'harpoon.ui'.toggle_quick_menu}
  M.key:invoke {'<C-k>',            require 'harpoon.mark'.add_file}
  for n = 1, 9 do
    M.key:invoke {'<A-'..n..'>',      '<CMD>lua require("harpoon.ui").nav_file('..n..')<CR>'}
  end
  -- gitsigns
  M.key:invoke {'gr',               '<CMD>Gitsigns reset_hunk<CR>'}
  M.key:invoke {'gr',               '<CMD>Gitsigns reset_hunk<CR>', mode = 'v'}
  M.key:invoke {'gp',               '<CMD>Gitsigns preview_hunk<CR>'}
  M.key:invoke {'gb',               '<CMD>Gitsigns blame_line<CR>'}
  M.key:invoke {'gd',               '<CMD>Gitsigns diffthis<CR>'}
  M.key:invoke {'gs',               '<CMD>Gitsigns stage_hunk<CR>'}
  M.key:invoke {'gs',               '<CMD>Gitsigns stage_hunk<CR>', mode = 'v'}
  M.key:invoke {'gu',               '<CMD>Gitsigns undo_stage_hunk<CR>'}
  M.key:invoke {'g<Left>',          '<CMD>Gitsigns prev_hunk<CR>zz'}
  M.key:invoke {'g<Right>',         '<CMD>Gitsigns next_hunk<CR>zz'}
  -- move
  M.key:invoke {'<A-Up>',           '<CMD>MoveLine(-1)<CR>', mode = 'n i'}
  M.key:invoke {'<A-Down>',         '<CMD>MoveLine(1)<CR>', mode = 'n i'}
  M.key:invoke {'<A-Up>',           ':MoveBlock(-1)<CR>', mode = 'v'}
  M.key:invoke {'<A-Down>',         ':MoveBlock(1)<CR>', mode = 'v'}
  -- hover
  M.key:invoke {'<leader>v',        require 'hover'.hover}
  -- M.key:invoke {'<leader>v',        require 'hover'.hover_select}
end)

return M
