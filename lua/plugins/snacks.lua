local plugins_info = require "helpers.plugins_info"
local icons = require "helpers.icons".icons
local keys = require "helpers.keys"

local M = {
  plugins_info.snacks
}

M.config = function()
  -- Toggle the profiler
  -- Snacks.toggle.profiler():map("<leader>pp")
  -- Toggle the profiler highlights
  -- Snacks.toggle.profiler_highlights():map("<leader>ph")

  -- require "snacks".setup {
  --   profiler = {
  --     keys = {
  --       { "<leader>ps", function() Snacks.profiler.scratch() end, desc = "Profiler Scratch Bufer" },
  --     },
  --   },
  --   -- picker = {},
  --   -- zen = {},
  -- }

  -- keys.map("n", "<leader>z", Snacks.zen.zen)
end

return M
