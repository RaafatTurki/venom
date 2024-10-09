local map = require "helpers.keys".map

function _G.qftf(info)
  local items
  local res = {}

  if info.quickfix == 1 then
    items = vim.fn.getqflist({id = info.id, items = 0}).items
  else
    items = vim.fn.getloclist(info.winid, {id = info.id, items = 0}).items
  end

  local limit = 31
  local fnameFmt1, fnameFmt2 = '%-' .. limit .. 's', '…%.' .. (limit - 1) .. 's'

  for i = info.start_idx, info.end_idx do
    local e = items[i]
    local fname = ''
    local str

    if e.valid == 1 then
      if e.bufnr > 0 then
        fname = vim.fn.bufname(e.bufnr)
        if fname == '' then
          fname = '[No Name]'
        else
          fname = fname:gsub('^' .. vim.env.HOME, '~')
        end
        -- char in fname may occur more than 1 width, ignore this issue in order to keep performance
        if #fname <= limit then
          fname = fnameFmt1:format(fname)
        else
          fname = fnameFmt2:format(fname:sub(1 - limit))
        end
      end

      local lnum = e.lnum > 99999 and -1 or e.lnum
      local col = e.col > 999 and -1 or e.col
      local qtype = e.type == '' and '' or ' ' .. e.type:sub(1, 1):upper()

      str = ("%5d:%-3d %s %s %s"):format(lnum, col, fname, qtype, e.text)
    else
      str = e.text
    end

    table.insert(res, str)
  end

  return res
end

vim.o.quickfixtextfunc = '{info -> v:lua._G.qftf(info)}'

vim.cmd [[
  if exists('b:current_syntax')
  finish
  endif

  " the lnum:col (e.g., 5:10) in the quickfix buffer
  syntax match qfLineNum /\d\+:\d\+/

  hi def link qfLineNum ErrorMsg

  let b:current_syntax = 'qf'
]]

-- keybinds
-- TODO: disable cnext and cprevious errors when going out of range
map({ "x", "n" }, "<S-Up>",    vim.cmd.cprevious, "QFList previous")
map({ "x", "n" }, "<S-Down>",  vim.cmd.cnext, "QFList next")

