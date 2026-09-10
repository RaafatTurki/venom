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
vim.o.foldtext = [[substitute(getline(v:foldstart),'\t',repeat(' ',&tabstop),'g').' ... '.trim(getline(v:foldend))]]


-- some file types that aren't mapped by treesitter yet
vim.treesitter.language.register("json", { "jsonc" })
vim.treesitter.language.register("robots_txt", { "robots" })
vim.treesitter.language.register("bash", { "env" })

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("treesitter-start", { clear = true }),
  callback = function(args)
    if vim.b[args.buf].large_buf then return end

    local lang = vim.treesitter.language.get_lang(args.match)
    if not lang then return end

    if not vim.tbl_contains(ts.get_installed "parsers", lang) then
      -- skip filetypes with no treesitter parsers
      if not vim.tbl_contains(ts.get_available(), lang) then return end

      local ok = pcall(function() ts.install(lang):wait(30 * 1000) end)
      if not ok or not vim.tbl_contains(ts.get_installed "parsers", lang) then return end
    end

    vim.treesitter.start(args.buf)
    vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})
