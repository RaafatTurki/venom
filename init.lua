log = require "helpers.logger"

huge_buffer_size = 1000000 -- 1MB
colorscheme = "default"

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

require "helpers.colorschemes".set_a_colorscheme({ "venom", "industry" })
require "helpers.keys".set_leader(" ")
require "helpers.disable_builtins"
require "helpers.buffers"
require "helpers.sessions"
require "helpers.mkview"
require "helpers.mkdir_parents"
require "helpers.open_uri"
require "helpers.curlinenr_vimode"
require "helpers.highlight_yank"
require "helpers.pretty_qflist"
require "helpers.normal_mode_on_write"

require "core.lazy"

-- required external tools
-- python-pynvim (nvim)
-- pnpm -g install neovim (nvim)
-- git (lazy.nvim, treesitter)
-- gcc (treesitter)
-- rg (telescope & mini.pick)
-- fzf (telescope-fzf)


