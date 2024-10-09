local U = require "helpers.utils"

vim.api.nvim_create_user_command("Chmod", function(opts)
  local sub_cmd = opts.fargs[1]
  U.chmod(sub_cmd)
end, {
    nargs = '+',
    complete = function(ArgLead, CmdLine, CursorPos)
      local args = vim.split(CmdLine, ' ', { trimempty = true })
      last_arg = args[#args]

      if last_arg == "Chmod" then
        return { '+x', '-x' }
      end
    end,
  })
