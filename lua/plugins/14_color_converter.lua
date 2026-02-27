local keys = require "helpers.keys"

local color_converter = require 'color-converter'
color_converter.setup {}

-- #FFFFFF

keys.map("n", "<leader>h", color_converter.cycle, "Cycle color format")
