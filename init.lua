if vim.env.PROF then
  local snacks = vim.fn.stdpath("data") .. "/lazy/snacks.nvim"
  vim.opt.rtp:append(snacks)
  require("snacks.profiler").startup({
    startup = {
      -- event = "VimEnter", -- stop profiler on this event. Defaults to `VimEnter`
      event = "UIEnter",
      -- event = "VeryLazy",
    },
  })
end

log = require "helpers.logger"

function prequire(name)
  local ok, val = pcall(require, name)
  if ok then
    return val
  else
    return nil
  end
end

require "core.options"
require "core.keymaps"
require "core.autocmds"

require "helpers.bigfile"
require "helpers.colorschemes".set_a_colorscheme({ "venom", "minischeme", "industry" })
require "helpers.keys".set_leader(" ")
require "helpers.disable_builtins"
require "helpers.buffers"
require "helpers.sessions"
require "helpers.mkview"
require "helpers.mkdir_parents"
require "helpers.open_uri"
require "helpers.highlight_yank"
require "helpers.better_qflist"
require "helpers.clean_paste"
require "helpers.spell"
require "helpers.ignorecase"
require "helpers.fs_cmds"
require "helpers.kill_xclip"
require "helpers.qmacro"
-- require "helpers.osc52"
require "helpers.normal_mode_on_write"
require "helpers.text_object_all"
require "helpers.lsp_utils"

require "core.lazy"

-- External Tools

-- NOTE: IN USE
-- python-pynvim (nvim)
-- pnpm -g install neovim (nvim)
-- git (lazy.nvim, treesitter)
-- gcc (treesitter)
-- rg (mini.pick, telescope)

-- NOTE: NOT IN USE
-- fzf (telescope-fzf)
