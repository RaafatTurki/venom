-- TODO: disolve this file into helpers

local group = vim.api.nvim_create_augroup("UserAutocmds", { clear = true })

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
local ft_cms = {
  -- ['cs'] = "//%s",
  -- ['prisma'] = "//%s",
  -- ['sql'] = "--%s",
  ['go'] = "// %s",
  ['rhai'] = "// %s",
  ['systemd'] = "# %s",
  ['gitconfig'] = "# %s",
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

vim.api.nvim_create_autocmd({ "FileType" }, {
  group = group,
  pattern = vim.tbl_keys(ft_cms),
  callback = function(ev)
    vim.bo[ev.buf].commentstring = ft_cms[ev.match]
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
