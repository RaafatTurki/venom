local U = require "helpers.utils"
local buffers = require "helpers.buffers"

local filetypes = {
  bigfile = { highlight = false, indent = false },
}

require 'nvim-treesitter.configs'.setup {
  -- ensure_installed = "all",
  auto_install = true,
  ignore_install = {
    "csv",
    -- "json",
  },
  highlight = {
    enable = true,
    disable = function(lang, buf)
      local ft = vim.api.nvim_get_option_value('filetype', { buf = buf })
      local is_ft_blocked = vim.tbl_get(filetypes, ft, "highlight") == false

      return is_ft_blocked
    end,
  },
  indent = {
    enable = true,
    disable = function(lang, buf)
      local ft = vim.api.nvim_get_option_value('filetype', { buf = buf })
      local is_ft_blocked = vim.tbl_get(filetypes, ft, "indent") == false

      return is_ft_blocked
    end,
  },
}

vim.api.nvim_create_autocmd({ "BufEnter" }, {
  callback = function(ev)
    -- bigfile check
    local ft = vim.api.nvim_get_option_value('filetype', { buf = ev.buf })
    if ft == "bigfile" then return end

    -- folding
    vim.o.foldmethod  = "expr"
    vim.o.foldexpr    = "v:lua.vim.treesitter.foldexpr()"
    vim.o.foldtext    = "substitute(getline(v:foldstart),'\t',repeat(' ',&tabstop),'g').' ... '.trim(getline(v:foldend))"
    -- vim.o.foldtext    = "v:lua.vim.treesitter.foldtext()"
  end
})
