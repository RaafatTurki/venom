local M = {}

-- Lua Utils

--- checks if number is within min - max range
function M.is_within_range(n, min, max) return ((n >= min) and (n <= max)) end

--- returns joined array into string
function M.join(arr, delimiter)
  delimiter = delimiter or ' '
  local str = ""
  for i, v in ipairs(arr) do
    str = str .. arr[i]
    if (i < #arr) then str = str .. delimiter end
  end
  return str
end

--- writes content to file
function M.file_write(path, content)
  path = vim.fs.normalize(path)
  local fh = assert(io.open(path, "wb"))
  fh:write(content)
  fh:flush()
  fh:close()
end

--- reads file content
function M.file_read(path)
  path = vim.fs.normalize(path)
  local fh = assert(io.open(path, "rb"))
  local content = assert(fh:read(_VERSION <= "Lua 5.2" and "*a" or "a"))
  fh:close()
  return content
end

--- deletes a file from disk
function M.file_del(path)
  path = vim.fs.normalize(path)
  local ok = os.remove(path)
  return ok == true
end

function M.get_relative_path(abs_path)
  return vim.fs.relpath(vim.fn.stdpath("config"), abs_path) or abs_path
end

--- returns boolean if a file exists or not
function M.is_file_exists(path)
  path = vim.fs.normalize(path)
  local name = vim.fs.basename(path)
  local dir = vim.fs.dirname(path)
  local matches = vim.fs.find(name, { path = dir, type = "file", limit = 1 })
  if not matches or #matches == 0 then return false end
  return vim.fs.normalize(matches[1]) == path
end


-- Neovim Utils
--- returns the extmarks of the current line within a specific namespace
function M.get_lnum_extmark_signs(ns, trim, lnum)
  trim = trim or false
  lnum = lnum and lnum-1 or vim.v.lnum-1

  local extmarks = vim.api.nvim_buf_get_extmarks(0, ns, {lnum, 0}, {lnum, 0}, { type = "sign", details = true })
  local signs = {}

  if extmarks then
    signs = vim.tbl_map(function(extmark)
      -- extmark[4] is sign data
      local sign = extmark[4]
      if sign then

        if trim and sign.sign_text and #sign.sign_text > 1 then
          -- trim the last character
          sign.sign_text = sign.sign_text:sub(1, -2)
        end

        return sign
      end
    end, extmarks)
  end

  return signs
end

--- returns the (strongest) severity level of the current line diagnostics (nil if none)
function M.get_lnum_diag_severity()
  local diagnostics = vim.diagnostic.get(0, { lnum = vim.v.lnum - 1 })

  local severity_level = nil

  for i, diag in ipairs(diagnostics) do
    if severity_level == nil then
      severity_level = diag.severity
    elseif diag.severity < severity_level then
      severity_level = diag.severity
    end
  end

  return severity_level
end

--- returns current vim mode name

--- prompts a multiple choice confirmation prompt
function M.confirm(msg, choices)
  choices = M.join(choices, '\n')
  local ok, answer = pcall(vim.fn.confirm, msg, choices)
  if ok then return answer end
end

--- prompts a yes/no confirmation prompt
function M.confirm_yes_no(msg)
  return true and M.confirm(msg, { 'Yes', 'No' }) == 1 or false
end

--- change the mod of current file
function M.chmod(mod)
  vim.cmd([[silent! !chmod ]] .. mod .. [[ %]])
end

--- read .env
function M.load_dotenv(path)
  path = path or vim.fn.stdpath("config") .. "/.env"

  local env = {}

  local ok_read, lines = pcall(vim.fn.readfile, path)
  if not ok_read then return env end

  -- parse and extract keys
  for _, line in ipairs(lines) do
    local trimmed = line:gsub("^%s+", ""):gsub("%s+$", "")
    if trimmed ~= "" and not trimmed:match("^#") then
      local key, value = trimmed:match("^([A-Za-z_][A-Za-z0-9_]*)=(.*)$")
      if key then
        value = value:gsub("^%s+", ""):gsub("%s+$", "")
        value = value:gsub('^"(.*)"$', "%1"):gsub("^'(.*)'$", "%1")
        if value ~= "" then
          env[key] = value
        end
      end
    end
  end

  -- set keys in vim.env
  for key, value in pairs(env) do
    vim.env[key] = value
  end

  return env
end

return M
