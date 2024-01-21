local map = require "helpers.keys".map

-- NOTE: this is a modified version of https://vi.stackexchange.com/a/24811

map("n", "<Plug>(RestoreView)",        ":call winrestview(g:restore_position)<CR>")

vim.cmd [[
  function TextObjectAll()
    let g:restore_position = winsaveview()
    normal! ggVG

    if index(['c','d'], v:operator) == 1
      " For delete/change ALL, we don't wish to restore cursor position.
    else
      call feedkeys("\<Plug>(RestoreView)")
    end

  endfunction
]]

map("o", "aa",        ":<c-u>call TextObjectAll()<CR>")
