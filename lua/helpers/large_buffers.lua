local MAX_BYTES = 1024 * 1024 * 1
local MAX_LINES = 50000

local function is_large(bufnr)
  -- ensure buffer is valid
  if not vim.api.nvim_buf_is_valid(bufnr) then return false end
  if not vim.api.nvim_buf_is_loaded(bufnr) then return false end
  if vim.bo[bufnr].buftype ~= "" then return false end
  if vim.b[bufnr].large_buf then return true end

  -- max bytes check
  if MAX_BYTES and MAX_BYTES > 0 then
    local name = vim.api.nvim_buf_get_name(bufnr)
    if name ~= "" then
      local size = vim.fn.getfsize(name)
      if size >= MAX_BYTES then return true end
    end
  end

  -- max lines check
  if MAX_LINES and MAX_LINES > 0 then
    local line_count = vim.api.nvim_buf_line_count(bufnr)
    if line_count >= MAX_LINES then return true end
  end

  return false
end

local function apply_large_buf_settings(bufnr)
  if vim.b[bufnr].large_buf then return end

  vim.b[bufnr].large_buf = true
  vim.b[bufnr].completion = false

  vim.bo[bufnr].swapfile = false
  vim.bo[bufnr].undofile = false

  for _, win in ipairs(vim.fn.win_findbuf(bufnr)) do
    vim.api.nvim_set_option_value("wrap", false, { win = win })
    vim.api.nvim_set_option_value("foldmethod", "manual", { win = win })
    vim.api.nvim_set_option_value("conceallevel", 0, { win = win })
  end

  pcall(vim.treesitter.stop, bufnr)

  vim.api.nvim_exec_autocmds("User", { pattern = "LargeBuffer", data = { buf = bufnr } })
end

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile", "BufWinEnter", "BufWritePost", "TextChanged", "TextChangedI", }, {
  group = vim.api.nvim_create_augroup("LargeBuffer", { clear = true }),
  callback = function(ev)
    if is_large(ev.buf) then
      apply_large_buf_settings(ev.buf)
    end
  end,
})
