local U = require "helpers.utils"
-- local buffers = require "helpers.buffers"

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
