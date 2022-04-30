local stages_util = require 'notify.stages.util'

return {
  function(state)
    local next_height = state.message.height + 2
    local next_row = stages_util.available_row(state.open_windows, next_height)

    if not next_row then return nil end

    return {
      relative = "editor",
      anchor = "NE",
      width = state.message.width,
      height = state.message.height,
      col = vim.opt.columns:get(),
      row = next_row,
      border = "single",
      style = "minimal",
      opacity = 100,
    }
  end,

  function()
    return {
      col = { vim.opt.columns:get() },
    }
  end,

  function()
    return {
      col = { vim.opt.columns:get() },
      time = true,
    }
  end,

  function()
    return {
      opacity = {
        0,
        frequency = 2,
        complete = function(cur_opacity)
          return cur_opacity <= 4
        end,
      },
      col = { vim.opt.columns:get() },
    }
  end,
}
