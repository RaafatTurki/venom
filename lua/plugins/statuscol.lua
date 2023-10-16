local plugins_info = require "helpers.plugins_info"

local M = { plugins_info.statuscol.url }

M.config = function()
  local builtin = require("statuscol.builtin")

  require "statuscol".setup {
    segments = {
      -- { sign = builtin.signfunc },
      { sign = { name = { "Diagnostic" }, maxwidth = 1 } },
      { text = { builtin.lnumfunc, "" } },
      { sign = { name = { "GitSign" }, maxwidth = 1 } },
      { text = { builtin.foldfunc } },
      { text = { " " } },
    },
  }
end

return M
