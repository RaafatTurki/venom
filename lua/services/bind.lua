--- defines commands, autocommands and keybinds
-- @module bind
local M = {}

M.bind_leader = U.Service():new(function()
  M.key({'<Space>', '<Nop>', mode = ''})
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
  -- DISABLES
  -- ctrl-x submode, c-p and c-n
  M.key {'<C-x>',            '<Nop>', mode = 'i'}
  -- disable arrow keys
  -- M.key {'<Down>',           '<Nop>', mode = 'n v i'}
  -- M.key {'<Up>',             '<Nop>', mode = 'n v i'}
  -- M.key {'<Left>',           '<Nop>', mode = 'n v i'}
  -- M.key {'<Right>',          '<Nop>', mode = 'n v i'}
  -- home and end
  -- M.key {'<Home>',           '<Nop>', mode = 'n v i'}
  -- M.key {'<End>',            '<Nop>', mode = 'n v i'}

  -- CURSED
  --- hjkl to jkil
  -- M.key {'i',                'k', mode = 'n v i'}
  -- M.key {'k',                'j', mode = 'n v i'}
  -- M.key {'j',                'h', mode = 'n v i'}
  -- M.key {'h',                '<Nop>', mode = 'n v i'}


  -- BASE
  -- write, undo, quit
  M.key {'<C-s>',            '<CMD>write<CR><ESC>', mode = 'n v i'}
  M.key {'<C-z>',            '<CMD>undo<CR>', mode = 'n v i'}
  M.key {'<C-q>',            '<CMD>quit<CR>', mode = 'n v i'}
  -- page shift up/down, select all
  M.key {'<C-Up>',           '<C-y>k'}
  M.key {'<C-Down>',         '<C-e>j'}
  -- M.key {'<C-a>',            ':%'}
  -- indent
  M.key {'<Tab>',            '>>_'}
  M.key {'<S-Tab>',          '<<_'}
  M.key {'<Tab>',            '>gv', mode = 'v'}
  M.key {'<S-Tab>',          '<gv', mode = 'v'}
  -- switch between last 2 windows
  M.key {'<A-Tab>',          '<C-w>p'}
  -- make x delete without copying
  -- M.key {'x',                '"_x', mode = 'v n'}
  M.key {'X',                '"_x', mode = 'v n'}
  -- make Y copy to end of line
  M.key {'Y',                'y$'}
  -- go to end after a join
  M.key {'J',                'J$'}
  -- split (opposite of J)
  M.key {'S',                'T hr<CR>k$'}
  -- open man pages in new tabs
  M.key {'K',                ':tab Man<CR>'}
  -- center line after n/N
  -- M.key {'n',                'nzzzv'}
  -- M.key {'N',                'Nzzzv'}
  -- re-edit current buffer
  M.key {'<F5>',             '<CMD>e<CR>'}
  -- clear action
  -- venom.actions.clear:subscribe [[let @/ = ""]]
  venom.actions.clear:subscribe [[noh]]
  venom.actions.clear:subscribe(U.clear_prompt)
  M.key {'<c-l>',           function() venom.actions.clear() end}
  -- terminal smart escape
  M.key {'<Esc>',            "v:lua.TermSmartEsc(b:terminal_job_pid, '"..'<Esc>'.."')", mode = 't', opts = { noremap = true, expr = true } }
  -- undo breakpoints
  local undo_break_points = {',', '.', '!', '?', '-'}
  for _, break_point in pairs(undo_break_points) do
    M.key {break_point,     break_point..'<C-g>u', mode = 'i'}
  end
  -- goto and display to nex/prev lsp diagnositc
  M.key {'d<Left>',          function() vim.diagnostic.goto_prev({ float = false }) end}
  M.key {'d<Right>',         function() vim.diagnostic.goto_next({ float = false }) end}
  -- tabs
  M.key {'<C-t>',            '<CMD>tabnew<CR>'}
  M.key {'<A-Right>',        '<CMD>tabnext<CR>'}
  M.key {'<A-Left>',         '<CMD>tabprevious<CR>'}
  -- lsp
  M.key {'<leader>r',         '<CMD>LspRename<CR>'}


  -- MOTIONS
  M.key {'aa',                ':<c-u>normal! ggVG<CR>', mode = 'o'}

  -- TESTING
  -- M.key {'<A-z>',            function() vim.notify("hi friend") end}

  -- old
  -- shifting line
  -- M.key {'<A-Down>',         '<CMD>m .+1<CR>'}
  -- M.key {'<A-Up>',           '<CMD>m .-2<CR>'}
  -- M.key {'<A-Down>',         '<CMD>m .+1<CR><ESC>i', mode = 'i'}
  -- M.key {'<A-Up>',           '<CMD>m .-2<CR><ESC>i', mode = 'i'}
end)

-- TODO load each conditionally depending on registered features
M.setup_plugins = U.Service():new(function()
  -- open uri under cursor
  M.key {'gx',               OpenURIUnderCursor}
  -- cycle theme
  M.key {'<leader>t',        Themes.theme_cycle}


  -- PLUGINS
  -- packer sync
  M.key {'<leader>p',        function() PluginManager.sync () end}
  -- nvim comment
  M.key {'<leader>c',        ':CommentToggle<CR>'}
  M.key {'<leader>c',        ':CommentToggle<CR>',    mode = 'v'}
  M.key {'Y',                'ygv:CommentToggle<CR>', mode = 'v'}
  -- nvim tree
  M.key {'<C-e>',            '<CMD>NvimTreeToggle<CR>', mode = 'i n'}
  -- harpoon
  -- M.key {'<C-p>',            require 'harpoon.ui'.toggle_quick_menu}
  -- M.key {'<C-k>',            require 'harpoon.mark'.add_file}
  -- for n = 1, 9 do
  --   M.key {'<A-'..n..'>',      '<CMD>lua require("harpoon.ui").nav_file('..n..')<CR>'}
  -- end
  -- reach
  M.key {'<C-p>',            function()
    require 'reach'.buffers {
      show_current = true,
      grayout_current = false,
      modified_icon = '•',
      previous = {
        enable = false,
      },
    }
  end}
  for n = 1, 9 do
    M.key {'<A-'..n..'>',      function() require 'reach'.switch_to_buffer(n) end}
  end

  -- gitsigns
  M.key {'gr',               '<CMD>Gitsigns reset_hunk<CR>'}
  M.key {'gr',               '<CMD>Gitsigns reset_hunk<CR>', mode = 'v'}
  M.key {'gp',               '<CMD>Gitsigns preview_hunk<CR>'}
  M.key {'gb',               '<CMD>Gitsigns blame_line<CR>'}
  M.key {'gd',               '<CMD>Gitsigns diffthis<CR>'}
  M.key {'gs',               '<CMD>Gitsigns stage_hunk<CR>'}
  M.key {'gs',               '<CMD>Gitsigns stage_hunk<CR>', mode = 'v'}
  M.key {'gu',               '<CMD>Gitsigns undo_stage_hunk<CR>'}
  M.key {'g<Left>',          '<CMD>Gitsigns prev_hunk<CR>zz'}
  M.key {'g<Right>',         '<CMD>Gitsigns next_hunk<CR>zz'}
  -- move
  M.key {'<A-Up>',           '<CMD>MoveLine(-1)<CR>', mode = 'n i'}
  M.key {'<A-Down>',         '<CMD>MoveLine(1)<CR>', mode = 'n i'}
  M.key {'<A-Up>',           ':MoveBlock(-1)<CR>', mode = 'v'}
  M.key {'<A-Down>',         ':MoveBlock(1)<CR>', mode = 'v'}
  -- lsp installer
  M.key {'<leader>l',        '<CMD>LspInstallInfo<CR>'}
  -- lsp
  M.key {'<leader>r',        '<CMD>LspRename<CR>'}
  M.key {'<leader>R',        '<CMD>LspReferences<CR>'}
  M.key {'<leader>C',        '<CMD>LspCodeAction<CR>'}
  M.key {'<leader>v',        '<CMD>LspHover<CR>'}
  M.key {'<leader>dl',       '<CMD>LspDiagsList<CR>'}
  M.key {'<leader>dv',       '<CMD>LspDiagsHover<CR>'}
end)

return M
