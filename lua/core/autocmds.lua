local U = require "helpers.utils"
-- local buffers = require "helpers.buffers"

-- set window based options on BufEnter depending if a buffer is huge or not
vim.api.nvim_create_autocmd({ "BufEnter" }, {
  callback = function(ev)
    if not U.is_buf_huge(ev.buf) then
      vim.opt.wrap = false
    else
      vim.opt.foldmethod = "manual"
      vim.opt.wrap = true
    end
  end
})

-- filetype based autocmd
vim.api.nvim_create_autocmd({ "Filetype" }, {
  callback = function(ev)

    local ft_handlers = {
      cs = function() vim.bo.commentstring = "// %s" end,
      cpp = function() vim.bo.commentstring = "// %s" end,
      dart = function() vim.bo.commentstring = "// %s" end,
      prisma = function() vim.bo.commentstring = "// %s" end,
      typst = function() vim.bo.commentstring = "// %s" end,
      glsl = function() vim.bo.commentstring = "// %s" end,
      dosini = function() vim.bo.commentstring = "# %s" end,
      resolv = function() vim.bo.commentstring = "# %s" end,
      hurl = function() vim.bo.commentstring = "# %s" end,
      iss = function() vim.bo.commentstring = "; %s" end,
    }

    if vim.tbl_contains(vim.tbl_keys(ft_handlers), ev.match) then
      ft_handlers[ev.match]()
    end
  end
})

-- filename based autocmd
vim.cmd [[
  augroup base
  au!

  " file name
  au BufEnter *.svx setlocal ft=svelte
  au BufEnter *.typ setlocal ft=typst
  au BufEnter *.hurl setlocal ft=hurl

  au BufEnter en.json setlocal wrap
  au BufEnter ar.json setlocal wrap
  " au BufEnter .swcrc setlocal ft=json
  " au BufEnter tsconfig.json setlocal ft=jsonc
  " au BufEnter mimeapps.list setlocal ft=dosini
  " au BufEnter PKGBUILD.* setlocal ft=PKGBUILD
  " au BufEnter README setlocal ft=markdown
  " au BufEnter nanorc setlocal ft=nanorc
  " au BufEnter pythonrc setlocal ft=python
  " au BufEnter sxhkdrc,*.sxhkdrc set ft=sxhkdrc
  " au BufEnter .classpath setlocal ft=xml
  au BufEnter .env* setlocal ft=sh
  " au BufEnter .replit setlocal ft=toml
  " au BufEnter package.json setlocal nofoldenable
  " au BufEnter tsconfig.json setlocal nofoldenable

  " " file type
  " au FileType lspinfo setlocal nofoldenable
  " au FileType alpha setlocal cursorline
  " au FileType lazy setlocal cursorline

  " " comment strings
  " au BufEnter ripgreprc* setlocal commentstring=#%s
  " au FileType sshdconfig setlocal commentstring=#%s
  " au FileType c setlocal commentstring=//%s
  " au FileType arduino setlocal commentstring=//%s
  " au FileType cs setlocal commentstring=//%s
  " au FileType gdscript setlocal commentstring=#%s
  " au FileType fish setlocal commentstring=#%s
  " au FileType prisma setlocal commentstring=//%s
  " au FileType sxhkdrc setlocal commentstring=#%s
  " au FileType dart setlocal commentstring=//%s

  " au BufEnter xorg.conf* setlocal ft=xf86conf
  " au BufRead,BufNewFile */xorg.conf.d/*.conf* setlocal ft=xf86conf

  " terminal
  " au FileType terminal setlocal nocursorline
  " au TermOpen * setlocal nonumber
  " au TermOpen * setlocal norelativenumber
  " au TermOpen * setlocal signcolumn=no

  " au InsertLeave,TextChanged * set foldmethod=expr
  " au BufWritePost * set foldmethod=expr

  augroup base
]]

-- -- huge buffer detection
-- vim.api.nvim_create_autocmd({ "BufReadPre" }, {
--   callback = function(ev)
--     if U.is_buf_huge(ev.buf) then
--       ---@diagnostic disable-next-line: inject-field
--       vim.b.huge = true
--     else
--       ---@diagnostic disable-next-line: inject-field
--       vim.b.huge = false
--     end
--   end,
-- })

-- vim.api.nvim_create_autocmd({ "InsertCharPre" }, {
--   callback = function(ev)
--     if (vim.v.char == "s") then
--       vim.v.char = ''
--     end
--   end
-- })

-- vim.api.nvim_create_autocmd({ "BufRead" }, {
--   callback = function(ev)
--     if vim.fn.getfsize(ev.match) >= huge_buffer_size then
--       -- print("AUTOCMDDDDDD")
--       -- vim.cmd [[syntax clear]]
--       -- vim.cmd [[filetype off]]
--       -- log(ev)

--       -- vim.cmd [[setlocal foldmethod=manual]]
--       -- vim.bo[ev.buf].undofile = false
--       -- vim.bo[ev.buf].swapfile = false
--       -- vim.wo.foldenable = false
--     end
--   end
-- })

-- vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
--   callback = function(ev)
--     local buf_i = buffers.buflist:get_buf_index({bufnr = ev.buf})
--     if not buf_i then return end
--     if buffers.buflist:get_buf_info(buf_i).buf.is_huge then
--     end
--   end
-- })

-- recompute folds if normal mode
-- vim.api.nvim_create_autocmd({ "BufWritePost" }, {
--   callback = function(ev)
--     -- if vimode == 'n' then
--     --   vim.cmd.edit()
--     --   vim.api.nvim_feedkeys("zx", '', true)
--     -- end
--   end,
-- })
