-- heavily inspired by the bigfile implementation in LazyVim
-- https://github.com/LazyVim/LazyVim/commit/938a6718c6f0d5c6716a34bd3383758907820c52

local bigfile_size  = 1024 * 1024 * 1 -- 1 MB

vim.filetype.add({
  pattern = {
    [".*"] = {
      function(path, buf)
        return vim.bo[buf].filetype ~= "bigfile" and path and vim.fn.getfsize(path) > bigfile_size and "bigfile" or nil
      end,
    },
  },
})

vim.api.nvim_create_autocmd({ "FileType" }, {
  group = vim.api.nvim_create_augroup("bigfile", {}),
  pattern = "bigfile",
  callback = function(ev)
    -- vim
    vim.opt.wrap = false
    vim.bo.undofile = false
    vim.wo.foldmethod = "manual"
    -- vim.wo.statuscolumn = ""
    vim.wo.conceallevel = 0
    vim.o.syntax = "off"
    -- infer basic syntax highlighting from buffer contents
    -- vim.schedule(function()
      --   local ft = vim.filetype.match({ buf = ev.buf })
      --   vim.bo[ev.buf].syntax = ft or ""
      -- end)

    -- mini
    vim.b.minimap_disable = true

  end,
})
