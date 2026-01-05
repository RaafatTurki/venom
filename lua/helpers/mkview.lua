vim.api.nvim_create_autocmd({ "BufWinLeave", "BufWritePost" }, {
  callback = function(ev)
    if vim.b[ev.buf].large_buf then return end

    -- buftype check
    local ft = vim.api.nvim_get_option_value('buftype', { buf = ev.buf })
    if ft == "nofile" then return end

    -- disk file check
    if ev.file == "" then return end

    vim.api.nvim_cmd({ cmd = "mkview" }, {})
  end
})

vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
  callback = function(ev)
    if vim.b[ev.buf].large_buf then return end

    -- buftype check
    local ft = vim.api.nvim_get_option_value('buftype', { buf = ev.buf })
    if ft == "nofile" then return end

    -- disk file check
    if ev.file == "" then return end

    ---@diagnostic disable-next-line: missing-fields
    vim.api.nvim_cmd({ cmd = "loadview", args = {}, mods = { silent = true, emsg_silent = true } }, {})
  end
})
