local keys = require "helpers.keys"

local kulala = require "kulala"

kulala.setup {
  -- keys = {
  --   { "s", desc = "Send request" },
  --   { "a", desc = "Send all requests" },
  --   { "b", desc = "Open scratchpad" },
  -- },
  -- ft = {"http", "rest"},
  -- opts = {
  --   global_keymaps = false,
  --   global_keymaps_prefix = "<leader>",
  --   kulala_keymaps_prefix = "<leader>",
  -- },
}

-- print(vim.inspect(kulala))

keys.map("n", "<leader>s", kulala.run, "Send request")
keys.map("n", "<leader>e", kulala.set_selected_env, "Set Selected Env")
