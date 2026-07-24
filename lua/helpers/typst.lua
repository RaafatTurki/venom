local M = {}

local current_watch = {
  job_id = nil,
  typ_path = nil,
  stopping_job_id = nil,
}

-- XXX:
local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "Typst" })
end

local function stop_current_watch()
  if current_watch.job_id then
    current_watch.stopping_job_id = current_watch.job_id
    vim.fn.jobstop(current_watch.job_id)
    current_watch.job_id = nil
    current_watch.typ_path = nil
  end
end

local function open_pdf(pdf_path)
  if vim.fn.executable("xdg-open") == 0 then
    notify("xdg-open is not available", vim.log.levels.ERROR)
    return
  end

  vim.fn.jobstart({ "xdg-open", pdf_path }, { detach = true })
end

M.watch = function()
  if vim.fn.executable("typst") == 0 then
    notify("typst is not available", vim.log.levels.ERROR)
    return
  end

  local typ_path = vim.api.nvim_buf_get_name(0)
  if typ_path == "" or vim.fn.fnamemodify(typ_path, ":e") ~= "typ" then
    notify("Current buffer is not a .typ file", vim.log.levels.WARN)
    return
  end

  if vim.bo.modified then
    local ok, err = pcall(vim.cmd.write)
    if not ok then
      notify("Could not write current buffer: " .. err, vim.log.levels.ERROR)
      return
    end
  end

  typ_path = vim.fs.normalize(typ_path)
  local pdf_path = vim.fn.fnamemodify(typ_path, ":r") .. ".pdf"

  if current_watch.job_id and current_watch.typ_path == typ_path then
    notify("Already watching " .. vim.fn.fnamemodify(typ_path, ":t"))
    open_pdf(pdf_path)
    return
  end

  stop_current_watch()

  local compile_job = vim.fn.jobstart({ "typst", "compile", typ_path, pdf_path }, {
    stderr_buffered = true,
    on_exit = function(_, code)
      vim.schedule(function()
        if code ~= 0 then
          notify("Initial compile failed", vim.log.levels.ERROR)
          return
        end

        open_pdf(pdf_path)
      end)
    end,
  })

  if compile_job <= 0 then
    notify("Failed to start typst compile", vim.log.levels.ERROR)
    return
  end

  local watch_job = vim.fn.jobstart({ "typst", "watch", typ_path, pdf_path }, {
    stderr_buffered = true,
    on_exit = function(job_id, code)
      vim.schedule(function()
        if current_watch.stopping_job_id == job_id then
          current_watch.stopping_job_id = nil
          return
        end

        current_watch.job_id = nil
        current_watch.typ_path = nil

        if code ~= 0 then
          notify("typst watch exited with code " .. code, vim.log.levels.ERROR)
        end
      end)
    end,
  })

  if watch_job <= 0 then
    notify("Failed to start typst watch", vim.log.levels.ERROR)
    return
  end

  current_watch.job_id = watch_job
  current_watch.typ_path = typ_path
  notify("Watching " .. vim.fn.fnamemodify(typ_path, ":t"))
end

-- TODO: add cmd group
vim.api.nvim_create_user_command('TypstWatch', M.watch, {})
vim.api.nvim_create_user_command('TypstStop', stop_current_watch, {})

return M
