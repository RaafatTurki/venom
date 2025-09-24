local U = require "helpers.utils"
local keys = require "helpers.keys"
local icons = require "helpers.icons".icons

-- better logging (lsp log file)
vim.lsp.log.set_format_func(vim.inspect)
-- vim.lsp.set_log_level(vim.log.levels.DEBUG)

local function lsp_rename()
  vim.lsp.buf.rename()
end

local function lsp_references()
  vim.lsp.buf.references()
end

local function lsp_definition()
  vim.lsp.buf.definition()
end

local function lsp_code_action()
  vim.lsp.buf.code_action()
end

local function lsp_hover()
  vim.lsp.buf.hover({ border = 'single' })
end

local function lsp_format()
  vim.lsp.buf.format()
end

local function lsp_diags_list()
  -- vim.diagnostic.setloclist()
  vim.diagnostic.setqflist()
end

local function lsp_diags_hover()
  vim.diagnostic.open_float({
    border = "single",
    scope = "line",
    source = false,
  })
end

local function lsp_signature_help()
  vim.lsp.buf.signature_help({
    border = 'single',
    anchor_bias = "above",
    focusable = false,
    focus = false,
    wrap = false,
    relative = "cursor",
  })
end


-- TODO: disolve in favor of the new nvim 11 lsp stuff
-- keys.map("n", "<leader>D",         lsp_toggle_diags)
keys.map("n", "<leader>r",         lsp_rename)
keys.map("n", "<leader>R",         lsp_references)
keys.map("n", "<leader>d",         lsp_definition)
keys.map("n", "<leader>C",         lsp_code_action)
keys.map("n", "<leader>v",         lsp_hover)
-- keys.map("n", "<leader>v",         lsp_inspect)
keys.map("n", "<leader>x",         lsp_diags_hover)
keys.map("n", "<leader>X",         lsp_diags_list)

vim.api.nvim_create_user_command('LspRename', lsp_rename, {})
vim.api.nvim_create_user_command('LspReferences', lsp_references, {})
vim.api.nvim_create_user_command('LspDefinition', lsp_definition, {})
vim.api.nvim_create_user_command('LspCodeAction', lsp_code_action, {})
vim.api.nvim_create_user_command('LspHover', lsp_hover, {})
vim.api.nvim_create_user_command('LspDiagsList', lsp_diags_list, {})
vim.api.nvim_create_user_command('LspDiagsHover', lsp_diags_hover, {})
vim.api.nvim_create_user_command('LspFormat', lsp_format, {})
vim.api.nvim_create_user_command('LspSigHelp', lsp_signature_help, {})


-- setup lsp signs
for type, icon in pairs(icons.diag) do
  local hl = "DiagnosticSign" .. type
  -- if (LSP_DIAG_ICONS == lsp_diag_icons.none) then icon = nil end
  -- vim.fn.sign_define(hl, { text = icon, texthl = hl })
end
