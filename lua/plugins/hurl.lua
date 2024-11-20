local plugins_info = require "helpers.plugins_info"

local M = { plugins_info.hurl }

M.dependencies = {
  plugins_info.plenary,
  plugins_info.nui,
}

M.ft = "hurl"

M.config = function()
  require "hurl".setup {
    -- show_notification = true,
    env_file = {
      '.env',
    },
    show_notification = true,
    mode = "popup",
    popup_position = '0%',
    popup_size = {
      width = '80%',
      height = '80%',
    },
    mappings = {
      close = 'q',
      next_panel = '<C-n>',
      prev_panel = '<C-p>',
    },
    fixture_vars = {
      {
        name = 'rand_int',
        callback = function()
          return math.random(1, 1000)
        end,
      },
      {
        name = 'rand_float',
        callback = function()
          local result = math.random() * 10
          return string.format('%.2f', result)
        end,
      },
    },
  }
end

return M
