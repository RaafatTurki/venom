local U = require "helpers.utils"
local keys = require "helpers.keys"
local icons = require "helpers.icons".icons

local function lsp_rename()
  local curr_name = vim.fn.expand("<cword>")
  local input_opts = {
    prompt = 'LSP Rename: ',
    default = curr_name
  }
  -- ask user input
  vim.ui.input(input_opts, function(new_name)
    -- check new_name is valid
    if not new_name or #new_name == 0 or curr_name == new_name then return end

    -- request lsp rename
    local params = vim.lsp.util.make_position_params()
    params.newName = new_name

    vim.lsp.buf_request(0, "textDocument/rename", params, function(err, res, ctx, _)
      if err then
        if err.message then log.err(err.message) end
        return
      end
      if not res then return end

      -- apply renames
      local client = vim.lsp.get_client_by_id(ctx.client_id)
      vim.lsp.util.apply_workspace_edit(res, client.offset_encoding)

      -- display a message
      local changes = U.count_lsp_res_changes(res)
      local message = string.format("renamed %s instance%s in %s file%s. %s",
        changes.instances,
        changes.instances == 1 and '' or 's',
        changes.files,
        changes.files == 1 and '' or 's',
        changes.files > 1 and "To save them run ':wa'" or ''
      )
      vim.notify(message)
    end)
  end)
end

local function lsp_references()
  if prequire "telescope" then
    vim.cmd [[Telescope lsp_references]]
  else
    vim.lsp.buf.references()
  end
end

local function lsp_definition()
  if prequire "telescope" then
    vim.cmd [[Telescope lsp_definitions]]
  else
    vim.lsp.buf.definition()
  end
end

local function lsp_code_action()
  vim.lsp.buf.code_action()
end

local function lsp_hover()
  local fold_preview = prequire "fold-preview"
  if fold_preview then
    if not fold_preview.toggle_preview() then
      vim.lsp.buf.hover()
    end
  else
    vim.lsp.buf.hover()
  end
end

local function lsp_format()
  vim.lsp.buf.format()
end

local function lsp_diags_list()
  vim.diagnostic.setloclist()
  -- vim.diagnostic.setqflist()
end

local function lsp_diags_hover()
  vim.diagnostic.open_float({ border = "single" })
end


local function toggle_diags()
  -- TODO: ...
end

local function setup_buf_fmt_on_save(client, bufnr)
  if client.supports_method("textDocument/formatting") then
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      callback = function(ev) vim.lsp.buf.format() end,
    })
  end
end

-- keys.map("n", "<leader>D",         lsp_toggle_diags, {})
keys.map("n", "<leader>r",         lsp_rename, {})
keys.map("n", "<leader>R",         lsp_references, {})
keys.map("n", "<leader>d",         lsp_definition, {})
keys.map("n", "<leader>C",         lsp_code_action, {})
keys.map("n", "<leader>v",         lsp_hover, {})
keys.map("n", "<leader>x",         lsp_diags_hover, {})
keys.map("n", "<leader>X",         lsp_diags_list, {})

vim.api.nvim_create_user_command('LspRename', lsp_rename, {})
vim.api.nvim_create_user_command('LspReferences', lsp_references, {})
vim.api.nvim_create_user_command('LspDefinition', lsp_definition, {})
vim.api.nvim_create_user_command('LspCodeAction', lsp_code_action, {})
vim.api.nvim_create_user_command('LspHover', lsp_hover, {})
vim.api.nvim_create_user_command('LspDiagsList', lsp_diags_list, {})
vim.api.nvim_create_user_command('LspDiagsHover', lsp_diags_hover, {})
vim.api.nvim_create_user_command('LspFormat', lsp_format, {})

-- setup lsp signs
for type, icon in pairs(icons.diag) do
  local hl = "DiagnosticSign" .. type
  -- if (LSP_DIAG_ICONS == lsp_diag_icons.none) then icon = nil end
  vim.fn.sign_define(hl, { text = icon, texthl = hl })
end
