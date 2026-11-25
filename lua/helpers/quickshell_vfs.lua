-- NOTE: quickshells qmlls resolves qs.* imports through its generated VFS under /run/user/<uid>/quickshell/vfs/
-- so go-to-definition (and references) land on symlinks there instead of the config files.
-- this renames those buffers to the real file
-- so nvim treats both paths as the same file
-- so :edit alone would reuse it

vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
  group = vim.api.nvim_create_augroup("quickshell_vfs", { clear = true }),
  pattern = "/run/user/*/quickshell/vfs/*",
  desc = "open the real file behind quickshell's vfs symlinks",
  callback = function(ev)
    local vfs_name = vim.api.nvim_buf_get_name(ev.buf)
    local real = vim.uv.fs_realpath(vfs_name)
    if not real or real == vfs_name then return end

    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(ev.buf) then return end

      local win = vim.fn.bufwinid(ev.buf)
      local cursor = win ~= -1 and vim.api.nvim_win_get_cursor(win)

      vim.api.nvim_buf_set_name(ev.buf, real)
      -- NOTE: re-edit so the buffer counts as the real file again (and lsp reattaches)
      -- that also restores the last known position, so put the jump target back
      vim.api.nvim_buf_call(ev.buf, function() vim.cmd("silent edit") end)
      if cursor then vim.api.nvim_win_set_cursor(win, cursor) end

      -- NOTE: renaming leaves an unlisted alternate buffer with the vfs name
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if buf ~= ev.buf and vim.api.nvim_buf_get_name(buf) == vfs_name then
          vim.api.nvim_buf_delete(buf, { force = true })
        end
      end
    end)
  end
})
