colorschemes = require "helpers.colorschemes"

-- install lazy.nvim if not already installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- use a protected call so we don't error out on first use
local lazy = prequire "lazy"
if not lazy then return end

-- load plugins from specifications (The leader key must be set before this)
lazy.setup("plugins", {
  dev = {
    path = "~/sectors/nvim/",
  },
  install = {
    colorscheme = { colorschemes.colorscheme }
  },
  ui = {
    size = { width = 0.8, height = 0.8 },
    wrap = false,
    border = 'single',
    backdrop = 100,
    -- pills = false,
    custom_keys = {
      ["<localleader>l"] = false,
      ["<localleader>g"] = {
        function(plugin) require("lazy.util").float_term({ "gitui" }, { cwd = plugin.dir }) end,
        desc = "Open gitui in plugin dir",
      },
      ["<localleader>t"] = {
        function(plugin) require("lazy.util").float_term(nil, { cwd = plugin.dir }) end,
        desc = "Open terminal in plugin dir",
      },
    },
  },
  checker = {
    enabled = true,
    notify = false,
    frequency = 1800,
  },
  change_detection = {
    enabled = false,
  },
})

-- keybinding
require "helpers.keys".map("n", "<leader>p", lazy.show, "Plugin manager")
