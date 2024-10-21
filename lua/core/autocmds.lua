local U = require "helpers.utils"

-- filename based filetypes
vim.api.nvim_create_autocmd({ "BufEnter" }, {
  callback = function(ev)

    local fn_pattern_ft = {
      ['%.env.*'] = "sh",
      ['%.*%.svx'] = "sh",
      ['%.*%.swcrc'] = "json",
      ['xorg%.conf%a*'] = "xf86conf",
      -- ['docker-compose%.yaml'] = "yaml.docker-compose",
      -- ['docker-compose%.yml'] = "yaml.docker-compose",
      -- ['compose%.yaml'] = "yaml.docker-compose",
      -- ['compose%.yml'] = "yaml.docker-compose",

      -- au BufRead,BufNewFile */xorg.conf.d/*.conf* setlocal ft=xf86conf
    }

    local filename = vim.fs.basename(ev.file)

    for pattern, ft in pairs(fn_pattern_ft) do
      local match = string.match(filename, pattern)
      if match and #match == #filename then
        vim.bo.filetype = ft
      end
    end
  end
})

-- set integrated terminal opts
vim.api.nvim_create_autocmd({ "TermOpen" }, {
  callback = function(ev)
    vim.wo.number = false
  end
})
