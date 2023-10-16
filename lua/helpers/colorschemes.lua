local M = {}

local function is_colorscheme_valid(name)
  if vim.tbl_contains(vim.fn.getcompletion("", "color"), name) then
    return true
  else
    return false
  end
end

function M.set_a_colorscheme(colorschemes)
  for _, name in ipairs(colorschemes) do
    if is_colorscheme_valid(name) then
      vim.cmd.colorscheme(name)
      colorscheme = name
      break
    end
  end
end

return M
