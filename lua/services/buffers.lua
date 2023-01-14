--- defines buffer managment mechanisms
-- @module buffers
log = require 'logger'.log
U = require 'utils'

local M = {}

M.labels = {
  '1', '2', '3',
  'q', 'w', 'e',
  'a', 's', 'd',
  -- 'z', 'x', 'c',
  'Q', 'W', 'E',
  'A', 'S', 'D',
  -- 'Z', 'X', 'C'
}

M.buflist = {}

M.setup = U.Service():new(function()

  vim.api.nvim_create_autocmd('VimEnter', {
    callback = function()
      for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if M.is_buf_listable(bufnr) then
          M.buf_add(bufnr)
        end
      end
    end
  })

  vim.api.nvim_create_autocmd('BufAdd', {
    callback = function()
      local bufnr = tonumber(vim.fn.expand('<abuf>'))
      if M.is_buf_listable(bufnr) then
        M.buf_add(bufnr)
      end
    end
  })

  vim.api.nvim_create_autocmd('BufDelete', {
    callback = function()
      local bufnr = tonumber(vim.fn.expand('<abuf>'))
      M.buf_del(bufnr)
      -- local index = M.buf_get_index_from_bufnr(bufnr)
      -- print(index)
      -- if index and index > 1 then M.buf_switch_by_index(index - 1) end
    end
  })

  -- vim.cmd [[
  --   au FileType * if index(['wipe', 'delete', 'unload'], &bufhidden) >= 0 | set nobuflisted | endif
  -- ]]

  vim.api.nvim_create_user_command('HelpOpen', function(opts) M.open_help_buffer(opts.fargs[1]) end, { nargs = 1, complete='help' })
  vim.api.nvim_create_user_command('HelpClose', function(opts) M.close_help_buffer() end, {})
  vim.api.nvim_create_user_command('ManOpen', function(opts) M.open_man_buffer(opts.fargs[1]) end, { nargs = 1 })

  vim.cmd [[cnoreabbrev h HelpOpen]]
  vim.cmd [[cnoreabbrev hc HelpClose]]
  vim.cmd [[cnoreabbrev m ManOpen]]
end)

M.is_buf_listable = function (bufnr)
  local buftype = vim.api.nvim_buf_get_option(bufnr, 'buftype')

  if vim.api.nvim_buf_is_valid(bufnr)
    and (buftype == '' or buftype == 'terminal')
    and not vim.tbl_contains(M.buflist, bufnr)
  then
    M.buf_add(bufnr)
  end
end


M.buf_get_index_from_bufnr = function(bufnr)
  for i, cur_bufnr in ipairs(M.buflist) do
    if bufnr == cur_bufnr then
      return i
    end
  end
  return nil
end

M.buf_get_index_from_label = function(label)
  for i, cur_label in ipairs(M.labels) do
    if label == cur_label then
      return i
    end
  end
  return nil
end

M.buf_get_label_from_bufnr = function(bufnr)
  local i = M.buf_get_index_from_bufnr(bufnr)
  if i then return M.labels[i] end
  return ''
end



M.buf_add = function(bufnr)
  table.insert(M.buflist, bufnr)
end

M.buf_del = function(bufnr)
  local i = M.buf_get_index_from_bufnr(bufnr)
  if i then table.remove(M.buflist, i) end
end

M.buf_switch_by_index = function(i)
  if i then vim.cmd.b(M.buflist[i]) end
end

M.buf_switch_by_label = function(label)
  local i = M.buf_get_index_from_label(label)
  if i then vim.cmd.b(M.buflist[i]) end
end


M.open_help_buffer = function(term)
  vim.cmd.help(term)
  vim.cmd.wincmd('L')
  -- vim.cmd.wincmd('|')
  vim.cmd.wincmd('90 |')
end

M.close_help_buffer = function(term)
  vim.cmd.helpclose()
end

M.open_man_buffer = function(term)
  vim.cmd.Man(term)
  vim.cmd.wincmd('o')
end

return M
