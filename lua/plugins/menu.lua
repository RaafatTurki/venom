local plugins_info = require "helpers.plugins_info"
local icons = require "helpers.icons".icons
local map = require "helpers.keys".map

local M = { plugins_info.menu }

M.dependencies = {
  plugins_info.volt
}

M.config = function()
  local menu = require "menu"
  local opts = {
    border = true,
    -- mouse = true,
  }
  local sep = { name = "separator" }

  local m_misc = {

    {
      name = "Hurl",
      items = {
        {
          name = " Run File",
          cmd = "HurlRunner",
          hl = "WarningMsg",
        },
        sep,
        {
          name = " Run At",
          cmd = "HurlRunnerAt",
          hl = "WarningMsg",
        },
        {
          name = " Run To Entry",
          cmd = "HurlRunnerToEntry",
          hl = "WarningMsg",
        },
      },
    },

  }

  map({ "n" }, "<leader>m", function() menu.open(m_misc, opts) end, "Open Misc Menu")
end

return M
