-- `=` runs the tiers below, in order, stopping at the first one that
-- handles the buffer. Reorder/trim `M.chain` to change that order.

local M = {}

M.active = false


-- prevent edits while formatting
local blocked_keys = {
  "i", "I", "a", "A", "o", "O", "s", "S", "C", "R",
  "x", "X", "D", "p", "P", "u", "<C-r>", "d", "c", "J", "r", "~",
}

local function block_edits(buf)
  for _, key in ipairs(blocked_keys) do
    vim.keymap.set("n", key, function()
      vim.notify("formatting...", vim.log.levels.WARN)
    end, { buffer = buf })
  end
end

local function unblock_edits(buf)
  if not vim.api.nvim_buf_is_valid(buf) then return end
  for _, key in ipairs(blocked_keys) do
    pcall(vim.keymap.del, "n", key, { buffer = buf })
  end
end


-- spinner
local spinner_frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
local spinner_idx = 1
local spinner_timer = nil

function M.spinner_icon()
  return spinner_frames[spinner_idx]
end

local function start_spinner(buf)
  M.active = true
  spinner_idx = 1
  block_edits(buf)

  spinner_timer = vim.uv.new_timer()
  spinner_timer:start(0, 80, vim.schedule_wrap(function()
    spinner_idx = (spinner_idx % #spinner_frames) + 1
    vim.api.nvim_exec_autocmds("User", { pattern = "FormatProgress" })
  end))
end

local function stop_spinner(buf)
  M.active = false
  if spinner_timer then
    spinner_timer:stop()
    spinner_timer:close()
    spinner_timer = nil
  end
  unblock_edits(buf)
  vim.api.nvim_exec_autocmds("User", { pattern = "FormatProgress" })
end


-- fallback
local function fallback_conform(buf, r, done)
  local ok, conform = pcall(require, "conform")
  if not ok then return done(false) end

  start_spinner(buf)

  local attempted = conform.format({
      bufnr = buf,
      range = r.range,
      async = true,
      lsp_format = "never",
      timeout_ms = 3000
    },
    function(err) done(true, err) end
  )

  if not attempted then
    stop_spinner(buf)
    return done(false)
  end
end

local function fallback_lsp(buf, r, done)
  local ok, conform = pcall(require, "conform")
  if not ok then return done(false) end

  start_spinner(buf)
  -- NOTE: formatters = {} keeps this independent of tier_conform, whatever the chain order.
  local attempted = conform.format({
      bufnr = buf,
      range = r.range,
      formatters = {},
      async = true,
      lsp_format = "prefer",
      timeout_ms = 3000
    },
    function(err) done(true, err) end
  )
  if not attempted then
    stop_spinner(buf)
    return done(false)
  end
end

local function fallback_indentexpr(buf, r, done)
  -- last resort: plain `=` via 'indentexpr', always synchronous.
  vim.cmd(("normal! %dGV%dG="):format(r.start_line, r.end_line))
  done(true)
end

M.fallbacks = { fallback_conform, fallback_lsp, fallback_indentexpr }

local function run_fallback(buf, r, index)
  local fb = M.fallbacks[index]
  if not fb then return end

  fb(buf, r, function(is_handled, err)
    if M.active then stop_spinner(buf) end
    if err then vim.notify("format: " .. err, vim.log.levels.WARN) end
    if not is_handled then run_fallback(buf, r, index + 1) end
  end)
end




local function format(buf, start_line, end_line)
  local line_count = vim.api.nvim_buf_line_count(buf)
  local whole_buffer = start_line <= 1 and end_line >= line_count

  local range = nil
  if not whole_buffer then
    local last_line = vim.api.nvim_buf_get_lines(buf, end_line - 1, end_line, true)[1] or ""
    range = { start = { start_line, 1 }, ["end"] = { end_line, #last_line + 1 } }
  end

  run_fallback(buf, { range = range, start_line = start_line, end_line = end_line }, 1)
end

function M.operator(motion_type)
  if M.active then
    vim.notify("already formatting...", vim.log.levels.WARN)
    return
  end

  local buf = vim.api.nvim_get_current_buf()
  local start_line, end_line

  if motion_type == "visual" then
    -- NOTE: '</'> aren't set yet here; read the live selection instead
    start_line, end_line = vim.fn.getpos("v")[2], vim.fn.getpos(".")[2]
  else
    start_line, end_line = vim.fn.line "'[", vim.fn.line "']"
  end

  if end_line < start_line then start_line, end_line = end_line, start_line end

  format(buf, start_line, end_line)
end

vim.keymap.set("n", "=", function()
  vim.o.operatorfunc = "v:lua.require'helpers.format'.operator"
  return "g@"
end, { expr = true })

vim.keymap.set("x", "=", function() M.operator "visual" end)


return M
