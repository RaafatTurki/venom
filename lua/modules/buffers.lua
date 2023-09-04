local U = require 'utils'

local M = {}

events.buflist_update = U.Event("buflist_update"):new()

M.Buf = function()
  return setmetatable(
    {
      bufnr = nil,
      event_listener = nil,
      file_path = nil,

      new = function(self, bufnr)
        self.bufnr = bufnr
        self.file_path = vim.api.nvim_buf_get_name(self.bufnr)
        self.event_listener = vim.loop.new_fs_event()
        self:watch()
        return self
      end,
      switch = function(self)
        vim.cmd.b(self.bufnr)
      end,
      watch = function(self)
        self.event_listener:start(self.file_path, {}, vim.schedule_wrap(function(err, _fname, status)
          if status.rename then
            M.buf_del(self.bufnr)
            events.fs_update()
          else
            vim.cmd.checktime()
            self.event_listener:stop()
            self:watch()
          end
        end))
      end,
    },
    {}
  )
end

M.BufList = function()
  return setmetatable(
    {
      bufs = {},
      labels = {
        '1', '2', '3',
        'q', 'w', 'e',
        'a', 's', 'd',
        'Q', 'W', 'E',
        'A', 'S', 'D',
      },

      is_buf_acceptable = function(self, bufnr)
        -- if vim.api.nvim_buf_is_loaded(bufnr) then return false end
        -- if not vim.fn.bufexists(bufnr) == 1 then return false end
        -- if not vim.fn.buflisted(bufnr) == 1 then return false end
        -- log(self:get_buf_data({ bufnr == bufnr }).buf)

        if self:get_buf_data({ bufnr = bufnr }) then return false end
        if vim.api.nvim_buf_get_name(bufnr) == '' then return false end

        return true
      end,
      add_buf = function(self, bufnr, opts)
        opts = opts or {}
        opts = {
          index = opts.index or #self.bufs
        }

        if self:is_buf_acceptable(bufnr) then
          local buf = M.Buf():new(bufnr)
          -- table.insert(self.bufs, opts.index, buf)
          table.insert(self.bufs, buf)
          events.buflist_update()
        else
          -- log("UNACCEPTABLE BUFFER " .. bufnr)
        end
      end,
      remove_buf = function(self, opts)
        opts = {
          bufnr = opts.bufnr,
          index = opts.index,
          label = opts.label,
        }

        if opts.bufnr then
          for i, buf in ipairs(self.bufs) do
            if buf.bufnr == opts.bufnr then table.remove(self.bufs, i) end
            events.buflist_update()
          end
        elseif opts.index then
          table.remove(self.bufs, opts.index)
          events.buflist_update()
        elseif opts.label then
          table.remove(self.bufs, self:get_buf_data({ label = opts.label }).index)
          events.buflist_update()
        end
      end,
      set_active_buf = function(self, opts)
        opts = {
          bufnr = opts.bufnr,
          index = opts.index,
          rel_index = opts.rel_index,
          label = opts.label,
        }

        if opts.bufnr then
          for i, buf in ipairs(self.bufs) do
            if buf.bufnr == opts.bufnr then buf:switch() end
          end
        elseif opts.index then
          self.bufs[opts.index]:switch()
        elseif opts.rel_index then
          local target_index = self:get_buf_data({ active = true }).index - opts.rel_index
          if U.is_within_range(target_index, 1, #self.bufs) then
            self.bufs[target_index]:switch()
          end
        elseif opts.label then
          local buf_data = self:get_buf_data({ label = opts.label })
          if buf_data then buf_data.buf:switch() end
        end
      end,
      swap_bufs = function(self, index1, index2)
        if (U.is_within_range(index1, 1, #self.bufs) and U.is_within_range(index1, 1, #self.bufs)) then
          local buf_tmp = self.bufs[index1]
          self.bufs[index1] = self.bufs[index2]
          self.bufs[index2] = buf_tmp
          vim.cmd.redrawtabline()
          events.buflist_update()
        end
      end,
      shift_buf = function(self, index, rel_index)
        local target_index = index + rel_index
        if U.is_within_range(target_index, 1, #self.bufs) then
          self:swap_bufs(index, target_index)
        end
      end,
      shift_active_buf = function(self, rel_index)
        local buf_data = self:get_buf_data({ active = true })
        local target_index = buf_data.index + rel_index
        if U.is_within_range(target_index, 1, #self.bufs) then
          self:swap_bufs(buf_data.index, target_index)
        end
      end,
      get_buf_data = function(self, opts)
        opts = {
          bufnr = opts.bufnr,
          index = opts.index,
          label = opts.label,
          active = opts.active,
        }

        if opts.bufnr then
          for i, buf in ipairs(self.bufs) do
            if buf.bufnr == opts.bufnr then
              return {
                buf = buf,
                index = i,
                label = self.labels[i],
                active = opts.bufnr == vim.api.nvim_get_current_buf(),
              }
            end
          end
          return nil
        elseif opts.index then
          if U.is_within_range(opts.index, 1, #self.bufs) then
            local buf = self.bufs[opts.index]
            return {
              buf = buf,
              index = opts.index,
              label = self.labels[opts.index],
              active = buf.bufnr == vim.api.nvim_get_current_buf(),
            }
          else
            return nil
          end
        elseif opts.label then
          for i, buf in ipairs(self.bufs) do
            local curr_label = self.labels[i]
            if curr_label == opts.label then
              return {
                buf = buf,
                index = i,
                label = curr_label,
                active = buf.bufnr == vim.api.nvim_get_current_buf(),
              }
            end
          end
          return nil
        elseif opts.active then
          return self:get_buf_data({ bufnr = vim.api.nvim_get_current_buf() })
        end
      end,
    },
    {}
  )
end

M.buflist = M.BufList()

M.setup = service(function()
  vim.api.nvim_create_autocmd('VimEnter', {
    callback = function()
      for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        M.buflist:add_buf(bufnr)
      end
    end
  })

  vim.api.nvim_create_autocmd('BufAdd', {
    callback = function()
      local bufnr = tonumber(vim.fn.expand('<abuf>'))
      M.buflist:add_buf(bufnr)
    end
  })

  vim.api.nvim_create_autocmd('BufDelete', {
    callback = function()
      local bufnr = tonumber(vim.fn.expand('<abuf>'))
      M.buflist:remove_buf({ bufnr = bufnr })
      -- print(index)
      -- if index and index > 1 then M.buf_switch_by_index(index - 1) end
    end
  })

  -- vim.cmd [[
  --   au FileType * if index(['wipe', 'delete', 'unload'], &bufhidden) >= 0 | set nobuflisted | endif
  -- ]]

  -- vim.api.nvim_create_user_command('HelpClose', function(opts) vim.cmd.helpclose() end, {})
  -- vim.api.nvim_create_user_command('ManOpen', function(opts)
  --   vim.cmd.Man(opts.fargs[1])
  --   vim.cmd.wincmd('o')
  -- end, { nargs = 1 })

  -- vim.cmd [[cnoreabbrev hc HelpClose]]
  -- vim.cmd [[cnoreabbrev m ManOpen]]
end)

M.aggregate = function()
  local data = {
    file_paths = {},
    active_file_path = nil
  }

  for i, buf in ipairs(M.buflist.bufs) do
    table.insert(data.file_paths, U.get_relative_path(buf.file_path))
    
    local buf_data = M.buflist:get_buf_data({ index = i })
    if buf_data and buf_data.active then data.active_file_path = i end
  end

  return data
end

M.populate = function(data)
  -- populating the buflist
  for i, file_path in ipairs(data.file_paths) do
    vim.cmd.edit(file_path)
  end

  -- swtich to active buf
  for i, buf in ipairs(M.buflist.bufs) do
    if i == data.active_file_path then
      buf:switch()
    end
  end
end

return M
