require "options"
require "keymaps"
require "autocmds"

require "helpers.colorschemes"
require "helpers.disable_builtins"
-- require "helpers.blackhole_blank_dy"
require "helpers.buffers"
require "helpers.sessions"
require "helpers.mkview"
require "helpers.mkdir_parents"
require "helpers.open_uri"
require "helpers.highlight_yank"
require "helpers.better_qflist"
-- require "helpers.clean_paste"
require "helpers.spell"
require "helpers.ignorecase"
require "helpers.large_buffers"
-- require "helpers.chmod"
-- require "helpers.kill_xclip"
-- require "helpers.qmacro"
require "helpers.normal_mode_on_write"
require "helpers.text_object_all"
require "helpers.lsp_utils"


-- plugins
vim.pack.add ({
  { src = "https://github.com/nvim-mini/mini.nvim" },
  { src = "https://github.com/folke/snacks.nvim" },
  { src = "https://github.com/rebelot/heirline.nvim" },
  { src = "https://github.com/MunifTanjim/nui.nvim" },
  { src = "https://github.com/nvim-lua/plenary.nvim" },
  { src = "https://github.com/mason-org/mason.nvim" },
  { src = "https://github.com/mason-org/mason-lspconfig.nvim" },
  { src = "https://github.com/neovim/nvim-lspconfig" },
  { src = "https://github.com/jghauser/fold-cycle.nvim" },
  { src = "https://github.com/supermaven-inc/supermaven-nvim" },
  { src = "https://github.com/kevinhwang91/promise-async" },
  { src = "https://github.com/stevearc/conform.nvim" },
  { src = "https://github.com/nvim-neo-tree/neo-tree.nvim" },
  { src = "https://github.com/b0o/schemastore.nvim" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "master" },
  -- { src = "https://github.com/mks-h/treesitter-autoinstall.nvim.git" },
  { src = "https://github.com/Saghen/blink.cmp", version = "v1.6.0" },
  { src = "https://github.com/artemave/workspace-diagnostics.nvim" },
  { src = "https://github.com/rhaiscript/vim-rhai" }, -- remove once a rhai treesitter parser is available
  { src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" },
  { src = "https://github.com/yetone/avante.nvim", version = "v0.0.27" },
  -- { src = "https://github.com/Chen-Yulin/ColorfulDiff.nvim" },

  -- { src = "https://github.com/KeepDrive/tts.nvim" }, -- are we even using this?
  -- { src = "file:///home/potato/sectors/lua/nvim/hex.nvim"},
}, { confirm = false })

-- vim.pack.del({"nvim-treesitter"})
-- vim.pack.del({"tts.nvim"})
-- vim.pack.update(nil, { force = true })

-- require all files in plugins dir
---@diagnostic disable-next-line: param-type-mismatch
for _, file in ipairs(vim.fn.readdir(vim.fn.stdpath('config')..'/lua/plugins', [[v:val =~ '\.lua$']])) do

  -- skip files that start with an underscore
  if (file:sub(1, 1) == "_") then
    vim.notify(file)
    goto continue_plugin_file_requiring_loop
  end

  require('plugins.'..file:gsub('%.lua$', ''))

  ::continue_plugin_file_requiring_loop::
end
