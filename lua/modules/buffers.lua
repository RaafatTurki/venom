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

      is_buf_addable = function(self, bufnr)
        -- if vim.api.nvim_buf_is_loaded(bufnr) then return false end
        -- if not vim.fn.bufexists(bufnr) == 1 then return false end
        -- if not vim.fn.buflisted(bufnr) == 1 then return false end
        -- log(self:get_buf_data({ bufnr == bufnr }).buf)

        if vim.api.nvim_buf_get_option(bufnr, 'buftype') ~= '' then return false end
        if self:get_buf_index({ bufnr = bufnr }) then return false end
        if vim.api.nvim_buf_get_name(bufnr) == '' then return false end

        return true
      end,
      add_buf = function(self, bufnr)
        if self:is_buf_addable(bufnr) then
          local buf = M.Buf():new(bufnr)
          table.insert(self.bufs, buf)
          events.buflist_update()
        else
          -- log("UNACCEPTABLE BUFFER " .. bufnr)
        end
      end,
      remove_buf = function(self, bufnr)
        for i, buf in ipairs(self.bufs) do
          if buf.bufnr == bufnr then
            table.remove(self.bufs, i)
            events.buflist_update()
          end
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
          local target_index = self:get_buf_index({ active = true }) - opts.rel_index
          if U.is_within_range(target_index, 1, #self.bufs) then
            self.bufs[target_index]:switch()
          end
        elseif opts.label then
          local buf_info = self:get_buf_info(self:get_buf_index({ label = opts.label }))
          if buf_info then buf_info.buf:switch() end
        end
      end,
      swap_bufs = function(self, i1, i2)
        if (U.is_within_range(i1, 1, #self.bufs) and U.is_within_range(i1, 1, #self.bufs)) then
          local buf_tmp = self.bufs[i1]
          self.bufs[i1] = self.bufs[i2]
          self.bufs[i2] = buf_tmp
          vim.cmd.redrawtabline()
          events.buflist_update()
        end
      end,
      shift_buf = function(self, i, rel_i)
        -- shift active buf if i == 0
        if i == 0 then i = self:get_buf_index({ active = true }) end
        -- shift i by rel_i
        local target_index = i + rel_i
        if U.is_within_range(target_index, 1, #self.bufs) then
          self:swap_bufs(i, target_index)
        end
      end,
      get_buf_index = function(self, opts)
        opts = opts or {}
        opts = { bufnr = opts.bufnr, label = opts.label, active = opts.active }

        if opts.bufnr then
          for i, buf in ipairs(self.bufs) do
            if buf.bufnr == opts.bufnr then return i end
          end
        elseif opts.label then
          for i, buf in ipairs(self.bufs) do
            if self.labels[i] == opts.label then return i end
          end
        elseif opts.active then
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
            active = buf.bufnr == vim.api.nvim_get_current_buf(),
          }
        else
          return nil
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
      M.buflist:remove_buf(bufnr)
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
    active_file_index = nil
  }

  for i, buf in ipairs(M.buflist.bufs) do
    table.insert(data.file_paths, U.get_relative_path(buf.file_path))
    
    local buf_info = M.buflist:get_buf_info(i)
    if buf_info and buf_info.active then data.active_file_index = i end
  end

  return data
end

M.populate = function(data)
  -- populating the buflist
  for i, file_path in ipairs(data.file_paths) do
    if U.is_file_exists(file_path) then
      vim.cmd.badd(vim.fn.fnameescape(file_path))

      if i == data.active_file_index then
        M.buflist:get_buf_info(i).buf:switch()
      end
    else
      log("file \"" .. file_path .. "\" missing from cwd")
    end
  end

  events.buflist_update()
end

return M