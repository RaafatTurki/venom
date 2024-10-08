-- precomputing color values for named colors
local M = {}

-- M.camelcase = vim.tbl_map(function(v) return string.format('#%06x', v) end, vim.api.nvim_get_color_map())

-- M.lowercase = {}
-- for k, v in pairs(M.camelcase) do M.lowercase[string.lower(k)] = v end

-- M.uppercase = {}
-- for k, v in pairs(M.camelcase) do M.uppercase[string.upper(k)] = v end

M.hlgroups = {}
for hl, _ in pairs(vim.api.nvim_get_hl(0, {})) do M.hlgroups[hl] = { pattern = '%f[%w]()' .. hl .. '()%f[%W]', group = hl } end

-- M.all = vim.tbl_extend("error", M.hlgroups, {})
M.all = {}

return M
