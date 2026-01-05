local U = require "helpers.utils"
local keys = require "helpers.keys"

local M = {}

-- events.buflist_update = U.Event("buflist_update"):new()

M.Buf = function()
  return {
    bufnr = nil,
    is_persistable = true,
    file_path = nil,
    -- event_listener = nil,

    new = function(self, bufnr, is_persistable)
      self.bufnr = bufnr
      self.file_path = vim.api.nvim_buf_get_name(self.bufnr)
      self.is_persistable = is_persistable
      -- self.event_listener = vim.uv.new_fs_event()
      -- self:watch()
      return self
    end,
    -- watch = function(self)
    --   self.event_listener:start(self.file_path, {}, vim.schedule_wrap(function(err, _fname, status)
    --     if status.rename then
    --       M.buflist:remove_buf(self.bufnr)
    --       events.fs_update()
    --     else
    --       vim.cmd.checktime()
    --       self.event_listener:stop()
    --       self:watch()
    --     end
    --   end))
    -- end,
  }
end

M.BufList = function()
  return {
    bufs = {},
    last_focused_buf_i = 0,
    labels = {
      '1', '2', '3',
      'q', 'w', 'e',
      'a', 's', 'd',
      'Q', 'W', 'E',
      'A', 'S', 'D',
    },

    focus_buf = function(self, index)
      if not index then return end
      if not U.is_within_range(index, 1, #self.bufs) then return end

      local file_path = self.bufs[index].file_path

      -- TODO: instead of this check filepath is a real path for real (be mindful of relative vs absolute pathing)
      if file_path == "" then return end

      vim.cmd.edit(file_path)

      self.last_focused_buf_i = index
    end,
    is_buf_addable = function(self, bufnr)
      -- if vim.api.nvim_buf_is_loaded(bufnr) then return false end
      -- if not vim.fn.bufexists(bufnr) == 1 then return false end
      -- if not vim.fn.buflisted(bufnr) == 1 then return false end
      -- log(self:get_buf_data({ bufnr == bufnr }).buf)

      if vim.api.nvim_get_option_value('buftype', { buf = bufnr }) ~= '' then return false end
      if self:get_buf_index({ bufnr = bufnr }) then return false end
      -- if vim.api.nvim_buf_get_name(bufnr) == '' then return false end

      return true
    end,
    is_buf_persistable = function(self, bufnr)
      if vim.api.nvim_buf_get_name(bufnr) == '' then return false end

      return true
    end,
    add_buf = function(self, bufnr)
      if self:is_buf_addable(bufnr) then
        local buf = M.Buf():new(bufnr, self:is_buf_persistable(bufnr))
        table.insert(self.bufs, buf)
        -- events.buflist_update()
      else
        -- log("UNACCEPTABLE BUFFER " .. bufnr)
      end
    end,
    remove_buf = function(self, bufnr)
      local index = self:get_buf_index({ bufnr = bufnr })
      if index then
        table.remove(self.bufs, index)
        self:focus_buf(index)
        -- events.buflist_update()
      end
    end,
    set_current_buf = function(self, opts)
      opts = {
        bufnr = opts.bufnr,
        index = opts.index,
        rel_index = opts.rel_index,
        label = opts.label,
      }

      local i = nil

      if opts.bufnr then
        i = self:get_buf_index({ bufnr = opts.bufnr })
      elseif opts.index then
        i = opts.index
      elseif opts.rel_index then
        i = self:get_buf_index({ current = true }) - opts.rel_index
      elseif opts.label then
        i = self:get_buf_index({ label = opts.label })
      end

      self:focus_buf(i)
      self.last_focused_buf_i = i
    end,
    swap_bufs = function(self, i1, i2)
      if (U.is_within_range(i1, 1, #self.bufs) and U.is_within_range(i2, 1, #self.bufs)) then
        local buf_tmp = self.bufs[i1]
        self.bufs[i1] = self.bufs[i2]
        self.bufs[i2] = buf_tmp
        vim.cmd.redrawtabline()
        -- events.buflist_update()
      end
    end,
    shift_buf = function(self, i, rel_i)
      -- shift current buf if i == 0
      if i == 0 then i = self:get_buf_index({ current = true }) end
      -- shift i by rel_i
      local target_index = i + rel_i
      -- use multiple swaps to shift the buffer while maintaining the order of the other buffers and not going out of bounds
      if U.is_within_range(i, 1, #self.bufs) and U.is_within_range(target_index, 1, #self.bufs) then
        if rel_i > 0 then
          for j = i, target_index - 1 do
            self:swap_bufs(j, j + 1)
          end
        elseif rel_i < 0 then
          for j = i, target_index + 1, -1 do
            self:swap_bufs(j, j - 1)
          end
        end
      end
      -- if U.is_within_range(target_index, 1, #self.bufs) then
      --   self:swap_bufs(i, target_index)
      -- end
    end,
    get_buf_index = function(self, opts)
      opts = opts or {}
      opts = { bufnr = opts.bufnr, label = opts.label, file_path = opts.file_path, current = opts.current }

      if opts.bufnr then
        for i, buf in ipairs(self.bufs) do
          if buf.bufnr == opts.bufnr then return i end
        end
      elseif opts.label then
        for i, buf in ipairs(self.bufs) do
          if self.labels[i] == opts.label then return i end
        end
      elseif opts.file_path then
        for i, buf in ipairs(self.bufs) do
          if buf.file_path == opts.file_path then return i end
        end
      elseif opts.current then
        return self:get_buf_index({ bufnr = vim.api.nvim_get_current_buf() })
      end
      return nil
    end,
    get_buf_info = function(self, i)
      if not i then return nil end
      if U.is_within_range(i, 1, #self.bufs) then
        local buf = self.bufs[i]
        return {
          buf = buf,
          index = i,
          label = self.labels[i],
          current = buf.bufnr == vim.api.nvim_get_current_buf(),
        }
      else
        return nil
      end
    end,
    renamed_buf = function(self, i, new_path)
      local buf_info = self:get_buf_info(i)

      vim.cmd("badd " .. vim.fn.fnameescape(U.get_relative_path(new_path)))
      local new_buf_info = self:get_buf_info(#self.bufs)

      vim.tbl_map(function(win_id)
        vim.api.nvim_win_set_buf(win_id, new_buf_info.buf.bufnr)
      end, vim.fn.win_findbuf(buf_info.buf.bufnr))

      vim.cmd.bdelete(buf_info.buf.bufnr)

      self:shift_buf(#self.bufs, i - #self.bufs)
      vim.cmd.redrawtabline()
    end,
  }
end

M.buflist = M.BufList()


vim.api.nvim_create_autocmd('VimEnter', {
  callback = function(ev)
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
      M.buflist:add_buf(bufnr)
    end
  end
})

vim.api.nvim_create_autocmd('BufAdd', {
  callback = function(ev)
    M.buflist:add_buf(ev.buf)
  end
})

vim.api.nvim_create_autocmd('BufDelete', {
  callback = function(ev)
    M.buflist:remove_buf(ev.buf)
  end
})

vim.api.nvim_create_autocmd('FileType', {
  callback = function(ev)
    if ev.match == "qf" then
      M.buflist:remove_buf(ev.buf)
    end
  end
})


-- override vanilla buffer navigation
keys.map("n", '<A-Left>',          function() M.buflist:set_current_buf({ rel_index = 1 }) end, "")
keys.map("n", '<A-Right>',         function() M.buflist:set_current_buf({ rel_index = -1 }) end, "")

-- buffer shifting
keys.map("n", '<A-S-Left>',        function() M.buflist:shift_buf(0, -1) end, "")
keys.map("n", '<A-S-Right>',       function() M.buflist:shift_buf(0, 1) end, "")

-- buffer navigation by label
for i, label in ipairs(M.buflist.labels) do
  keys.map("n", '<A-'..label..'>',      function() M.buflist:set_current_buf({ label = label }) end, "")
end


M.aggregate = function()
  local data = {
    file_paths = {},
    current_file_index = nil
  }

  for i, buf in ipairs(M.buflist.bufs) do
    if not buf.is_persistable then goto buffer_aggregate_loop_continue end

    table.insert(data.file_paths, U.get_relative_path(buf.file_path))

    local buf_info = M.buflist:get_buf_info(i)
    if buf_info and buf_info.current then data.current_file_index = i end
    ::buffer_aggregate_loop_continue::
  end

  return data
end

M.populate = function(data)
  local is_curr_file_added = false

  local function baddFile(path, useEdit)
    useEdit = useEdit or false

    if U.is_file_exists(path) then
      if useEdit then
        vim.cmd.edit(vim.fn.fnameescape(path))
      else
        vim.cmd.badd(vim.fn.fnameescape(path))
      end
      return true
    else
      -- log("file \"" .. path .. "\" missing from cwd")
      return false
    end
  end

  if data.current_file_index and data.current_file_index <= #data.file_paths then
    is_curr_file_added = baddFile(data.file_paths[data.current_file_index], true)
  end


  for i, file_path in ipairs(data.file_paths) do
    -- edit the first file to prevent the creation of a [No Name] buffer
    if i == 1 and not is_curr_file_added then
      baddFile(file_path, true)
    end

    if i ~= data.current_file_index then
      baddFile(file_path, false)
      -- M.buflist:get_buf_info(i).buf:focus()
      -- M.buflist:set_current_buf({ index = i })
    end
  end

  if is_curr_file_added then
    M.buflist:shift_buf(1, data.current_file_index-1)
  end

  -- events.buflist_update()
end

return M
