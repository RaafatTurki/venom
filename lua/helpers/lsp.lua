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

local function lsp_signature_help()
  local function handler(_, res, ctx, cfg)
    cfg = cfg or {}
    cfg.border = 'single'
    cfg.focus_id = ctx.method
    -- cfg.active_signature = cfg.active_signature or 1

    -- ignore result since buffer changed. This happens for slow language servers.
    -- if vim.api.nvim_get_current_buf() ~= ctx.bufnr then return end

    -- when use `autocmd CompleteDone <silent><buffer> lua vim.lsp.buf.signature_help()` to call signatureHelp handler
    -- if the completion item doesn't have signatures It will make noise. Change to use `print` that can use `<silent>` to ignore
    if not (res and res.signatures) then
      if cfg.silent ~= true then print('No signature help available') end
      return
    end

    -- set active signature if cfg.sel_signature is set
    if cfg.sel_signature and U.is_within_range(cfg.sel_signature, 1, #res.signatures) then
      res.activeSignature = cfg.sel_signature-1
    end
    -- log(#res.signatures)

    local client = vim.lsp.get_client_by_id(ctx.client_id)
    local triggers = vim.tbl_get(client.server_capabilities, 'signatureHelpProvider', 'triggerCharacters')
    local ft = vim.api.nvim_buf_get_option(ctx.bufnr, 'filetype')
    local lines, hl = vim.lsp.util.convert_signature_help_to_markdown_lines(res, ft, triggers)

    -- lines = vim.lsp.util.trim_empty_lines(lines)

    -- quit w respect to the silent cfg if nothing came out of parsing the signature response
    if vim.tbl_isempty(lines) then
      if cfg.silent ~= true then print('No signature help available') end
      return
    end

    local fbuf, fwin = vim.lsp.util.open_floating_preview(lines, 'markdown-inline', cfg)
    if hl then vim.api.nvim_buf_add_highlight(fbuf, -1, 'LspSignatureActiveParameter', 0, unpack(hl)) end
    return fbuf, fwin
  end

  vim.lsp.buf_request(0, 'textDocument/signatureHelp', vim.lsp.util.make_position_params(),
    -- vim.lsp.with(handler, { active_signature = 5 })
    vim.lsp.with(handler, {})
  )
end

local function lsp_inspect()
  local hover_res
  local hover_res_done = false
  local hover_lsp_name
  local sig_help_res
  local sig_help_res_done = false
  local sig_help_lsp_name

  vim.lsp.buf_request(0, 'textDocument/hover', vim.lsp.util.make_position_params(),
    vim.lsp.with(function(_, res, ctx, cfg)
      hover_lsp_name = vim.lsp.get_client_by_id(ctx.client_id).name
      hover_res = res
      hover_res_done = true
    end, {})
  )

  vim.lsp.buf_request(0, 'textDocument/signatureHelp', vim.lsp.util.make_position_params(),
    vim.lsp.with(function(_, res, ctx, cfg)
      sig_help_lsp_name = vim.lsp.get_client_by_id(ctx.client_id).name
      sig_help_res = res
      sig_help_res_done = true
    end, {})
  )

  -- lines.contents.value = lines.contents.value:gsub("```csharp", "```cs")

  hover_res_modifiers = {
    omnisharp = function(lines)
      for i, line in ipairs(lines) do
        if line:find("```csharp") then
          lines[i] = line:gsub("```csharp", "```cs")
        end
      end
      return lines
    end
  }

  sig_help_res_modifiers = {
    omnisharp = function(lines)
      for i, line in ipairs(lines) do
        if line:find("```csharp") then
          lines[i] = line:gsub("```csharp", "```cs")
        end
      end
      return lines
    end
  }

  sig_help_res_ft = {
    omnisharp = "cs"
  }

  -- keeps trying to display the window until both hover and signature help requests are done or timedout reached
  local timedout = 10000 -- 10s
  local timestep = 100 -- 0.1s
  local function display()
    if hover_res_done and sig_help_res_done then
      local content = {}

      -- log(hover_res)
      -- log(sig_help_res)
      -- lines = vim.split(hover_res.contents.value, '\n', { plain = true, trimempty = true })

      -- add hover content if there is any
      if hover_res and hover_res.contents.value and #hover_res.contents.value > 0 then
        vim.list_extend(content, {"", "# Hover", ""})
        lines = vim.lsp.util.convert_input_to_markdown_lines(hover_res.contents.value)

        if hover_res_modifiers[hover_lsp_name] then
          lines = hover_res_modifiers[hover_lsp_name](lines)
        end

        vim.list_extend(content, lines)
      end

      -- add signature help content if there is any
      if sig_help_res then
        vim.list_extend(content, {"", "# Signature", ""})

        local ft = sig_help_res_ft[sig_help_lsp_name]
        local lines = vim.lsp.util.convert_signature_help_to_markdown_lines(sig_help_res, ft, {}) or {}

        if sig_help_res_modifiers[sig_help_lsp_name] then
          lines = hover_res_modifiers[sig_help_lsp_name](lines)
        end

        vim.list_extend(content, lines)
      end

      -- display window if there is content
      if #content > 0 then
        local bufnr, winnr = vim.lsp.util.open_floating_preview(content, "markdown", { border = 'single'})
      end
    else
      vim.defer_fn(display, timestep)
      timedout = timedout - timestep
      if timedout <= 0 then
        log.err("LSP inspect timedout")
        return
      end
    end
  end

  display()
end

local function toggle_diags()
  -- TODO: ...
end

-- keys.map("n", "<leader>D",         lsp_toggle_diags, {})
keys.map("n", "<leader>r",         lsp_rename, {})
keys.map("n", "<leader>R",         lsp_references, {})
keys.map("n", "<leader>d",         lsp_definition, {})
keys.map("n", "<leader>C",         lsp_code_action, {})
keys.map("n", "<leader>v",         lsp_hover, {})
-- keys.map("n", "<leader>v",         lsp_inspect, {})
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
vim.api.nvim_create_user_command('LspSigHelp', lsp_signature_help, {})
vim.api.nvim_create_user_command('LspInspect', lsp_inspect, {})


-- setup lsp signs
for type, icon in pairs(icons.diag) do
  local hl = "DiagnosticSign" .. type
  -- if (LSP_DIAG_ICONS == lsp_diag_icons.none) then icon = nil end
  vim.fn.sign_define(hl, { text = icon, texthl = hl })
end
