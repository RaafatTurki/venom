-- TODO: disolve this file into helpers

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

-- filename based commentstring
vim.api.nvim_create_autocmd({ "FileType" }, {
  callback = function(ev)

    local ft_cms = {
      -- ['cs'] = "//%s",
      -- ['prisma'] = "//%s",
      -- ['sql'] = "--%s",
      -- ['go'] = "// %s",
      -- ['pug'] = "// %s",
      -- ['typst'] = "//%s",
      -- ['svelte'] = "<!-- %s -->",
      -- ['vue'] = "<!-- %s -->",
      -- ['pro'] = "# %s",
      -- ['javascriptreact'] = "{/*%s*/}",
      -- ['typescriptreact'] = "{/*%s*/}",
      -- ['javascript'] = "//%s}",
      -- ['typescript'] = "//%s}",
    }

    local filetype = vim.bo.filetype

    for ft, cms in pairs(ft_cms) do
      if ft == filetype then
        vim.bo.cms = cms
      end
    end
  end
})
