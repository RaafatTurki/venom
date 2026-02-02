-- TODO: disolve this file into helpers

local group = vim.api.nvim_create_augroup("UserAutocmds", { clear = true })

-- filename based filetypes
vim.api.nvim_create_autocmd({ "BufEnter" }, {
  group = group,
  callback = function(ev)

    local fn_pattern_ft = {
      ['%.env.*'] = "sh",
      ['%.*%.svx'] = "sh",
      ['%.*%.swcrc'] = "json",
      ['xorg%.conf%a*'] = "xf86conf",
      ['qt5ct%.conf'] = "ini",
      ['qt6ct%.conf'] = "ini",
      ['dunstrc'] = "ini",
      ['renamerrc'] = "ini",
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
  group = group,
  callback = function(ev)
    vim.wo.number = false
  end
})

-- open help in a vertical split
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = "help",
  group = group,
  callback = function(ev)
    vim.api.nvim_cmd({ cmd = "wincmd", args = { "L" } }, {})
  end
})

-- auto-resize splits on resize
vim.api.nvim_create_autocmd({ "VimResized" }, {
  group = group,
  callback = function(ev)
    vim.api.nvim_cmd({ cmd = "wincmd", args = { "=" } }, {})
  end
})

-- no auto-continue comments
vim.api.nvim_create_autocmd({ "FileType" }, {
  group = group,
  callback = function(ev)
    vim.opt.formatoptions:remove({"c", "r", "o"})
  end
})

-- filetype based commentstring
vim.api.nvim_create_autocmd({ "FileType" }, {
  group = group,
  callback = function(ev)

    local ft_cms = {
      -- ['cs'] = "//%s",
      -- ['prisma'] = "//%s",
      -- ['sql'] = "--%s",
      ['go'] = "// %s",
      ['rhai'] = "// %s",
      ['systemd'] = "# %s",
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

-- go uses literal tabs with 2-width display
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = "go",
  group = group,
  callback = function(ev)
    vim.bo.expandtab = false
    vim.bo.shiftwidth = 2
    vim.bo.tabstop = 2
    vim.bo.softtabstop = 2
  end
})
