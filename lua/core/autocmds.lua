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

-- kill xclip on VimLeave
vim.api.nvim_create_autocmd("VimLeave", {
  group = vim.api.nvim_create_augroup("KillXclip", { clear = true }),
  callback =  function()
    os.execute("pkill xclip")
  end
})

-- filename based filetypes
vim.api.nvim_create_autocmd({ "BufEnter" }, {
  callback = function(ev)

    local fn_pattern_ft = {
      ['%.env.*'] = "sh",
      ['%.*%.svx'] = "sh",
      ['%.*%.swcrc'] = "json",
      ['xorg%.conf%a*'] = "xf86conf",

      -- au BufRead,BufNewFile */xorg.conf.d/*.conf* setlocal ft=xf86conf
    }

    local filename = vim.fs.basename(ev.file)

    for pattern, ft in pairs(fn_pattern_ft) do
      local match = string.match(filename, pattern)
      if match and #match == #filename then
        log(match)
        vim.bo.filetype = ft
      end
    end
  end
})

-- filetype based comment strings
vim.api.nvim_create_autocmd({ "Filetype" }, {
  callback = function(ev)

    local ft_cms = {
      typescript = "// %s",
      javascript = "// %s",
      sshdconfig = "# %s",
      sql = "-- %s",
      css = "/* %s */",
    }

    if vim.tbl_contains(vim.tbl_keys(ft_cms), ev.match) then
      vim.bo.commentstring = ft_cms[ev.match]
    end
  end
})

-- set integrated terminal opts
vim.api.nvim_create_autocmd({ "TermOpen" }, {
  callback = function(ev)
    vim.wo.number = false
  end
})

-- filename based autocmd
-- vim.cmd [[
--   augroup base
--   au!
--
--   " terminal
--   " au FileType terminal setlocal nocursorline
--   " au TermOpen * setlocal nonumber
--   " au TermOpen * setlocal norelativenumber
--   " au TermOpen * setlocal signcolumn=no
--
--   " au InsertLeave,TextChanged * set foldmethod=expr
--   " au BufWritePost * set foldmethod=expr
--
--   augroup base
-- ]]

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
