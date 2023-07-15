--- defines buffer managment mechanisms
-- @module buffers
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

function M.Buffer()
  return setmetatable(
    {
      bufnr = nil,
      event_listener = nil,
      file_path = nil,

      new = function(self, bufnr)
        self.bufnr = bufnr
        self.event_listener = vim.loop.new_fs_event()
        self.file_path = vim.api.nvim_buf_get_name(self.bufnr)
        self:watch_file()
        return self
      end,
      switch_to = function(self)
        vim.cmd.b(self.bufnr)
      end,
      watch_file = function(self)
        self.event_listener:start(self.file_path, {}, vim.schedule_wrap(function(err, _fname, status)
          if status.rename then
            M.buf_del(self.bufnr)
            Events.fs_update()
          else
            vim.cmd.checktime()
            self.event_listener:stop()
            self:watch_file()
          end
        end))
      end,
    },
    {}
  )
end

M.setup = U.Service(function()
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

  vim.api.nvim_create_user_command('HelpClose', function(opts) vim.cmd.helpclose() end, {})
  vim.api.nvim_create_user_command('ManOpen', function(opts)
    vim.cmd.Man(opts.fargs[1])
    vim.cmd.wincmd('o')
  end, { nargs = 1 })

  vim.cmd [[cnoreabbrev hc HelpClose]]
  vim.cmd [[cnoreabbrev m ManOpen]]
end)

M.is_buf_listable = function(bufnr)
  -- local buftype = vim.api.nvim_buf_get_option(bufnr, 'buftype')

  if 
    not M.get_buflist_index_by_bufnr(bufnr)
    and vim.api.nvim_buf_get_name(bufnr) ~= ''
    -- and vim.api.nvim_buf_is_valid(bufnr)
    -- and (buftype == '' or buftype == 'terminal')
  then
    return true
  else
    return false
  end

  -- return true
end

M.get_buflist_index_by_label = function(label)
  for i, cur_label in ipairs(M.labels) do
    if label == cur_label then return i end
  end
  return nil
end

M.get_buflist_index_by_bufnr = function(bufnr)
  for i, cur_buf in ipairs(M.buflist) do
    if cur_buf.bufnr == bufnr then return i end
  end
  return nil
end

M.get_buf_by_label = function(label)
  local index = M.get_buflist_index_by_label(label)
  if index then return M.buflist[index] else return nil end
end

M.get_label_by_bufnr = function(bufnr)
  local index = M.get_buflist_index_by_bufnr(bufnr)
  local label = M.labels[index]
  if label then return label else return nil end
end

M.get_current_buf = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local index = M.get_buflist_index_by_bufnr(bufnr)
  if index then return M.buflist[index] else return nil end
end

M.buf_add = function(bufnr)
  local buffer = M.Buffer():new(bufnr)
  table.insert(M.buflist, buffer)
  Events.buflist_update()
end

M.buf_del = function(bufnr)
  for i, buf in ipairs(M.buflist) do
    if bufnr == buf.bufnr then
      table.remove(M.buflist, i)
      Events.buflist_update()
    end
  end
end

M.buf_switch_by_buflist_index = function(i)
  if i then M.buflist[i]:switch_to() end
end

M.buf_switch_by_label = function(label)
  local buffer = M.get_buf_by_label(label)
  if buffer then buffer:switch_to() end
end

M.shift_buf_in_buflist_by_index = function(index, delta)
  local target_index = index + delta
  if (index and target_index <= #M.buflist and target_index > 0) then
    local buffer = table.remove(M.buflist, index)
    table.insert(M.buflist, target_index, buffer)
  end
  vim.cmd.redrawtabline()
  Events.buflist_update()
end

M.shift_curr_buf_in_buflist = function(delta)
  local bufnr = vim.api.nvim_get_current_buf()
  local index = M.get_buflist_index_by_bufnr(bufnr)
  M.shift_buf_in_buflist_by_index(index, delta)
end

M.serialize = function()
  local data = {
    file_paths = {},
    active_file_path = nil
  }

  for i, buffer in ipairs(M.buflist) do
    table.insert(data.file_paths, buffer.file_path)
    if (buffer.bufnr == vim.api.nvim_get_current_buf()) then
      data.active_file_path = i
    end
  end

  return data
end

M.deserialize = function(data)
  -- local data = {
  --   file_paths = {},
  --   active_file_path = nil
  -- }

  -- populating the buflist
  for i, file_path in ipairs(data.file_paths) do
    vim.cmd.edit(file_path)
  end

  for i, buffer in ipairs(M.buflist) do
    if i == data.active_file_path then
      buffer:switch_to()
    end
  end
end

return M
