local U = require "helpers.utils"
local buffers = require "helpers.buffers"

local ts = require "nvim-treesitter"

vim.api.nvim_create_autocmd("PackChanged", {
  group = vim.api.nvim_create_augroup("pack-build-treesitter", { clear = true }),
  pattern = { "nvim-treesitter" },
  callback = function(event)
    vim.notify("Updating treesitter parsers", vim.log.levels.INFO)
    ts.update(nil, { summary = true }):wait(30 * 1000)
  end
})


vim.o.foldmethod = 'expr'
vim.o.foldcolumn = '1'
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
-- vim.o.foldtext = ''
vim.o.foldtext = [[substitute(getline(v:foldstart),'\t',repeat(' ',&tabstop),'g').' ... '.trim(getline(v:foldend))]]
-- vim.o.foldtext = [[substitute(getline(v:foldstart),'\\t',repeat('\ ',&tabstop),'g').' ... ']]


vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

-- vim.o.foldmethod  = "expr"
-- vim.o.foldexpr    = "v:lua.vim.treesitter.foldexpr()"
-- vim.o.foldtext    = "v:lua.vim.treesitter.foldtext()"


-- local filetypes = {
--   bigfile = { highlight = false, indent = false },
-- }

-- require("treesitter-autoinstall").setup({
--   ignore = { "minimap", "neo-tree" },
--   highlight = true,
--   regex = {},
-- })

require 'nvim-treesitter.configs'.setup {
  -- ensure_installed = "all",
  auto_install = true,
  -- ignore_install = {
  --   -- "csv",
  --   -- "json",
  -- },
  highlight = {
    enable = true,
    disable = function(lang, buf)
      -- local ft = vim.api.nvim_get_option_value('filetype', { buf = buf })
      -- local is_ft_blocked = vim.tbl_get(filetypes, ft, "highlight") == false

      -- return is_ft_blocked
      return false
    end,
  },
  indent = {
    enable = true,
    disable = function(lang, buf)
      -- local ft = vim.api.nvim_get_option_value('filetype', { buf = buf })
      -- local is_ft_blocked = vim.tbl_get(filetypes, ft, "indent") == false
      --
      -- return is_ft_blocked
      return false
    end,
  },
}
