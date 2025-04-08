local M = {}

-- disable legacy providers
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

M.built_in_plugins = {
  -- "editorconfig",
  -- "health",

  -- "man",
  -- "spellfile_plugin",
  -- "shada_plugin",

  "matchit",
  "matchparen",
  -- "netrwPlugin",
  "2html_plugin",
  "tutor_mode_plugin",
  "gzip",
  "tarPlugin",
  "zipPlugin",
}

for _, plugin in pairs(M.built_in_plugins) do
  vim.g["loaded_" .. plugin] = 1
end

return M
