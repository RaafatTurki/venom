local M = {}

local group = vim.api.nvim_create_augroup("UserAutoSave", { clear = false })

local function should_write(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return false
  end

  return vim.bo[buf].buftype == ""
    and vim.bo[buf].modifiable
    and not vim.bo[buf].readonly
    and vim.bo[buf].modified
    and vim.api.nvim_buf_get_name(buf) ~= ""
end

function M.enable(buf)
  buf = buf or vim.api.nvim_get_current_buf()

  vim.api.nvim_clear_autocmds({ group = group, buffer = buf })
  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    group = group,
    buffer = buf,
    callback = function(ev)
      if not should_write(ev.buf) then
        return
      end

      vim.api.nvim_buf_call(ev.buf, function()
        vim.cmd("silent noautocmd write")
      end)
    end,
  })
end

vim.api.nvim_create_user_command("AutoSave", function()
  M.enable()
end, {})

return M
