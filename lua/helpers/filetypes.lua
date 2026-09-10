-- filename based filetypes
-- note: ".env"/".env.local"/etc. are already detected as filetype "env" by
-- core; see plugins/06_treesitter.lua for aliasing the bash parser onto it
-- instead of remapping the filetype (which would also affect LSP attach/indent/etc.)
vim.filetype.add {
  filename = {
    ["dunstrc"] = "ini",
    ["renamerrc"] = "ini",
    ["qt5ct.conf"] = "ini",
    ["qt6ct.conf"] = "ini",
  },
  pattern = {
    -- vim.filetype.add() implicitly anchors patterns to the whole filename
    [".*%.svx"] = "markdown",
    [".*%.swcrc"] = "json",
    ["xorg%.conf%a*"] = "xf86conf",
    -- ["docker%-compose%.ya?ml"] = "yaml.docker-compose",
    -- ["compose%.ya?ml"] = "yaml.docker-compose",
  },
}
