require "options"
require "keymaps"
require "autocmds"

-- TODO: relocate those outside the helpers folder
-- fold ffi
-- icons
-- keys
log = require "logger".log

-- disolve this into many helper files
-- utils

-- check if the commented ones are even needed anymore
require "helpers.colorschemes"
require "helpers.disable_builtins"
require "helpers.bigfile"
require "helpers.buffers"
require "helpers.sessions"
require "helpers.mkview"
require "helpers.mkdir_parents"
require "helpers.open_uri"
require "helpers.highlight_yank"
require "helpers.better_qflist"
-- require "helpers.clean_paste"
require "helpers.spell"
require "helpers.ignorecase"
-- require "helpers.chmod"
-- require "helpers.kill_xclip"
-- require "helpers.qmacro"
require "helpers.normal_mode_on_write"
require "helpers.text_object_all"
require "helpers.lsp_utils"

require "rocks_pm"


-- require all files in plugins dir
---@diagnostic disable-next-line: param-type-mismatch
for _, file in ipairs(vim.fn.readdir(vim.fn.stdpath('config')..'/lua/plugins', [[v:val =~ '\.lua$']])) do
  -- if (file ~= "8_mason.lua") then
  -- vim.notify(file)
  require('plugins.'..file:gsub('%.lua$', ''))
  -- end
end


-- git
-- xdg-open
-- wget
-- curl
-- make
-- unzip
-- fzf
-- ripgrep
