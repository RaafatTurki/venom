--- defines commands, autocommands and keybinds
-- @module bind
local M = {}

M.bind_leader = U.Service():new(function()
  M.key({'<Space>', '<Nop>', mode = ''})
  vim.g.mapleader = ' '
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
  venom.events.write:sub(vim.cmd.write)
  venom.events.write:sub(vim.cmd.stopinsert)
  M.key {'<C-s>',             function() venom.events.write() end, mode = 'n v i'}
  M.key {'<C-z>',             function() vim.cmd.undo() end, mode = 'n v i'}
  M.key {'<C-c>',             function() vim.cmd.quit() end, mode = 'n v i'}
  M.key {'<C-q>',             function() vim.cmd.quitall() end, mode = 'n v i'}
  -- page shift up/down, select all
  M.key {'<C-Up>',            '<C-y>k'}
  M.key {'<C-Down>',          '<C-e>j'}
  -- M.key {'<C-a>',            ':%'}
  -- indent
  M.key {'<Tab>',             '>>_'}
  M.key {'<S-Tab>',           '<<_'}
  M.key {'<Tab>',             '>gv', mode = 'v'}
  M.key {'<S-Tab>',           '<gv', mode = 'v'}
  -- switch between last 2 windows
  M.key {'<A-Tab>',           '<C-w>p'}
  -- make x delete without copying
  -- M.key {'x',                '"_x', mode = 'v n'}
  M.key {'X',                 '"_x', mode = 'v n'}
  -- preserve cursor position after a yank
  M.key {'y',                 "ygv<ESC>", mode = 'v'}
  -- make Y copy to end of line
  M.key {'Y',                 'y$'}
  -- go to end after a join
  M.key {'J',                 'J$'}
  -- split (opposite of J)
  M.key {'S',                 'T hr<CR>k$'}
  -- open man pages in new tabs
  M.key {'K',                 ':tab Man<CR>'}
  -- zt and zb with arrows
  M.key {'z<Up>',             'zt'}
  M.key {'z<Down>',           'zb'}
  -- center line after n/N
  -- M.key {'n',                'nzzzv'}
  -- M.key {'N',                'Nzzzv'}
  -- refresh action
  venom.events.refresh:sub[[e]]
  M.key {'<F5>',              function() venom.events.refresh() end}
  -- clear action
  -- venom.actions.clear:sub [[let @/ = ""]]
  venom.events.clear:sub [[noh]]
  venom.events.clear:sub(U.clear_prompt)
  M.key {'<C-l>',             function() venom.events.clear() end}
  M.key {'<C-l>',             '<ESC>', mode = 'i'}
  -- terminal smart escape
  M.key {'<Esc>',             "v:lua.TermSmartEsc(b:terminal_job_pid, '"..'<Esc>'.."')", mode = 't', opts = { noremap = true, expr = true } }
  -- undo breakpoints
  local undo_break_points = {',', '.', '!', '?', '-'}
  for _, break_point in pairs(undo_break_points) do
    M.key {break_point,       break_point..'<C-g>u', mode = 'i'}
  end
  -- goto and display to nex/prev lsp diagnositc
  M.key {'d<Left>',           function() vim.diagnostic.goto_prev({ float = false }) end}
  M.key {'d<Right>',          function() vim.diagnostic.goto_next({ float = false }) end}
  -- tabs
  M.key {'<C-t>',             '<CMD>tabnew<CR>'}
  M.key {'<S-Right>',         '<CMD>tabnext<CR>'}
  M.key {'<S-Left>',          '<CMD>tabprevious<CR>'}
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
  M.key {'gx',                OpenURIUnderCursor}
  -- cycle theme
  -- M.key {'<leader>t',         Themes.theme_cycle}


  -- PLUGINS
  -- packer sync
  M.key {'<leader>p',         function() PluginManager.sync({ take_snapshot = true }) end}
  -- comment
  M.key{'<leader>c',          '<Plug>(comment_toggle_current_linewise)'}
  M.key{'<leader>c',          '<Plug>(comment_toggle_linewise_visual)', mode = 'v'}
  M.key {'Y',                 'ygv<Plug>(comment_toggle_linewise_visual)', mode = 'v'}

  -- nvim tree
  M.key {'<C-e>',             '<CMD>NvimTreeToggle<CR>', mode = 'i n'}
  -- reach
  local auto_handles = {
    '1', '2', '3',
    'q', 'w', 'e',
    'a', 's', 'd',
    'z', 'x', 'c',
    'Q', 'W', 'E',
    'A', 'S', 'D',
    'Z', 'X', 'C'
  }
  local auto_handles_bind_count = 8
  M.key {'<C-p>',            function()
    require 'reach'.buffers {
      show_current = true,
      grayout_current = false,
      modified_icon = '•',
      auto_handles = auto_handles,
      previous = {
        enable = false,
      },
      filter = function(bufnr)
        if vim.api.nvim_buf_get_name(bufnr) == '' then return false end
        return true
      end
    }
  end}
  for i, char in ipairs(auto_handles) do
    if (i > auto_handles_bind_count) then break end
    M.key {'<A-'..char..'>',      function() require 'reach'.switch_to_buffer(i) end}
  end
  -- fold-cycle
  M.key {'za',                function() require 'fold-cycle'.toggle_all() end}
  -- fold-preview
  M.key {'zq',                function() require 'fold-preview'.toggle_preview() end}
  -- gitsigns
  M.key {'gr',                '<CMD>Gitsigns reset_hunk<CR>'}
  M.key {'gr',                '<CMD>Gitsigns reset_hunk<CR>', mode = 'v'}
  M.key {'gp',                '<CMD>Gitsigns preview_hunk<CR>'}
  M.key {'gb',                '<CMD>Gitsigns blame_line<CR>'}
  M.key {'gd',                '<CMD>Gitsigns diffthis<CR>'}
  M.key {'gs',                '<CMD>Gitsigns stage_hunk<CR>'}
  M.key {'gs',                '<CMD>Gitsigns stage_hunk<CR>', mode = 'v'}
  M.key {'gu',                '<CMD>Gitsigns undo_stage_hunk<CR>'}
  M.key {'g<Left>',           '<CMD>Gitsigns prev_hunk<CR>zz'}
  M.key {'g<Right>',          '<CMD>Gitsigns next_hunk<CR>zz'}
  -- gomove
  M.key {'<A-Left>',          '<Plug>GoNSMLeft', mode = 'n' }
  M.key {'<A-Down>',          '<Plug>GoNSMDown', mode = 'n' }
  M.key {'<A-Up>',            '<Plug>GoNSMUp', mode = 'n' }
  M.key {'<A-Right>',         '<Plug>GoNSMRight', mode = 'n' }
  M.key {'<A-Left>',          '<Plug>GoVSMLeft', mode = 'x' }
  M.key {'<A-Down>',          '<Plug>GoVSMDown', mode = 'x' }
  M.key {'<A-Up>',            '<Plug>GoVSMUp', mode = 'x' }
  M.key {'<A-Right>',         '<Plug>GoVSMRight', mode = 'x' }
  -- lsp installer
  M.key {'<leader>l',         '<CMD>Mason<CR>'}
  -- lsp
  M.key {'<leader>r',         '<CMD>LspRename<CR>'}
  M.key {'<leader>R',         '<CMD>LspReferences<CR>'}
  M.key {'<leader>d',         '<CMD>LspDefinition<CR>'}
  M.key {'<leader>C',         '<CMD>LspCodeAction<CR>'}
  M.key {'<leader>v',         '<CMD>LspHover<CR>'}
  M.key {'<leader>dl',        '<CMD>LspDiagsList<CR>'}
  M.key {'<leader>dv',        '<CMD>LspDiagsHover<CR>'}
  -- fzf-lus
  M.key {'<leader>f',         '<CMD>FzfLua files<CR>'}
  M.key {'<leader>g',         '<CMD>FzfLua live_grep_native<CR>'}
  -- neotest
  M.key {'<leader>t',         '<CMD>NeotestToggleTree<CR>'}
end)

return M
