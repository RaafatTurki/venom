local keys = require "helpers.keys"

local M = {}

local open_cmd = nil

if vim.fn.has("unix") == 1 then
  open_cmd = 'xdg-open'
elseif vim.fn.has("mac") == 1 then
  open_cmd = 'open'
elseif vim.fn.has("win64") == 1 or vim.fn.has("win32") then
  open_cmd = 'start'
end

function M.open_uri_under_cursor()
  local word_under_cursor = vim.fn.expand("<cfile>")
  local uri = nil

  -- any uri with a protocol segment
  local regex_protocol_uri = "%a*:%/%/[%a%d%#%[%]%-%%+:;!$@/?&=_.,~*()]*"
  if string.match(word_under_cursor, regex_protocol_uri) then
    uri = word_under_cursor
  end

  -- anything that looks like string/string into a github repo
  local regex_plugin_url = "[%a%d%-%.%_]+%/[%a%d%-%.%_]+"
  if not uri and string.match(word_under_cursor, regex_plugin_url) then
    uri = 'https://github.com/' .. word_under_cursor
  end

  -- anything that looks like string-number into a jira link
  local regex_jira_url = "[%a%_]+%-[%d]+"
  if not uri and string.match(word_under_cursor, regex_jira_url) then
    uri = 'https://jira.example.com/browse/' .. word_under_cursor
  end

  if not uri then
    log.warn("unrecognizable URI")
    return
  end

  vim.fn.jobstart(open_cmd .. ' "' .. uri .. '"', {
    detach = true,
    on_exit = function(chan_id, data, name) log.info("URI opened") end,
  })
end

vim.api.nvim_create_user_command('OpenURIUnderCursor', M.open_uri_under_cursor, {})

keys.map("n", "gx", M.open_uri_under_cursor, {})

return M
