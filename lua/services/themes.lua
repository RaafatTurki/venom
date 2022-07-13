--- defines the theme functions and how their setting mechanisms.
-- @module themes
-- TODO: convert to a services based module
local M = {}

function M.default()
  vim.cmd [[colo default]]
end

function M.test(variant)
  vim.cmd [[set background=dark]]
  vim.cmd('colo '..variant)
end

function M.builtin()
  -- package.loaded['extras/builtin_colors'] = nil
  -- local builtin_colors = require 'extras/builtin_colors'
  -- local lush = require 'lush'
  -- lush(builtin_colors)

  new_color_scheme = require 'color_scheme'
  new_color_scheme.load()

  -- vim.api.nvim_command [[ hi def link LspReferenceText ErrorMsg ]]
  -- vim.api.nvim_command [[ hi def link LspReferenceWrite ErrorMsg ]]
  -- vim.api.nvim_command [[ hi def link LspReferenceRead ErrorMsg ]]

  -- local contrast = {
  --   filetypes = {
  --     "terminal",
  --     -- "packer",
  --     -- "qf",
  --     -- "NvimTree",
  --     -- "DiffviewFiles",
  --     -- "Outline",
  --   }
  -- }

  -- for _, ft in ipairs(contrast.filetypes) do
  --   if ft == "terminal" then
  --     U.create_augroup('autocmd TermOpen * setlocal winhighlight=Normal:NormalAlt,SignColumn:SignColumnFloat', 'builtin_theme_terminal')
  --   elseif ft == "NvimTree" then
  --     -- hi('NvimTreeNormal NormalAlt', '! link')
  --   else
  --     U.create_augroup('autocmd FileType ' .. ft .. ' setlocal winhighlight=Normal:NormalAlt,SignColumn:SignColumnFloat', 'builtin_theme_'..ft)
  --   end
  -- end

end

function M.material(variant)
  -- can be further configured through require('material').setup({...})
  require('material').setup({
    async_loading = false
  })
  U.gvar('material_style'):set(variant)
  vim.cmd 'colo material'
end


--- pre theme change hook
M.theme_change_pre = function()
  vim.cmd 'hi clear'
end

--- post theme change hook
M.theme_change_post = function()
  -- local c = require 'configs'
  -- if is_mod_exists('feline') then c.feline() end
end

M.themes = {}
M.prev_index = 1
M.curr_index = 1

--- sets the current theme
M.theme_set = function(n)
  n = tonumber(n)

  if (#M.themes == 0) then print('no themes registered') return end
  if type(n) ~= 'number' then print('argument must be a number') return end
  if U.is_within_range(n, 1, #M.themes) == false then print('number out of range') return end

  M.prev_index = M.curr_index
  M.curr_index = n

  M.theme_change_pre()
  local theme = M.themes[n]
  if (theme.args == {}) then theme.func() else theme.func(theme.args) end
  M.theme_change_post()
end

--- cycles through all registerd themes
M.theme_cycle = function()
  if (#M.themes == 1) then print('no other themes registered') return end
  if type(M.curr_index) ~= 'number' then print('argument must be a number') return end
  if U.is_within_range(M.curr_index, 1, #M.themes) == false then print('number out of range') return end

  M.curr_index = M.curr_index + 1
  if (M.curr_index > #M.themes) then M.curr_index = 1 end
  if (M.curr_index < 1) then M.curr_index = #M.themes end
  M.theme_set(M.curr_index)
end

--- re-applies the current theme
M.theme_reload = function()
  M.theme_set(M.curr_index)
end

vim.api.nvim_create_user_command('ThemeSet', function(opts) M.theme_set(opts.fargs[1]) end, { nargs = 1 })
vim.api.nvim_create_user_command('ThemeCycle', M.theme_cycle, {})
vim.api.nvim_create_user_command('ThemeReload', M.theme_reload, {})

--- initilizer
M.init = function(themes)
  M.themes = themes
  M.theme_set(M.curr_index)
end

return M
