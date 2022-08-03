--- defines how language servers are installed and setup
-- @module lsp

local M = {}

M.apply_shared_server_config = U.Service():new(function(server_config)

  -- subscribe on_attach to events.on_attach and change on_attach to events.on_attach invoker
  server_config.events.on_attach:sub(server_config.opts.on_attach)
  server_config.opts.on_attach = server_config.events.on_attach:wrap()

  -- skip here if NO_SHARED_CONFIG tag exists
  if U.has_value(server_config.tags, LST.NO_SHARED_CONFIG) then
    return server_config
  end

  -- shared opts (more at vim.lsp.start_client)
  local shared_capabilities = vim.lsp.protocol.make_client_capabilities()
  if venom.features:has(FT.PLUGIN, 'nvim-cmp') then
    shared_capabilities = require 'cmp_nvim_lsp'.update_capabilities(shared_capabilities)
  end

  local shared_handlers = {
    ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'single' }),
    ["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'single' }),
  }
  local shared_on_attach = function(client, bufnr)
    -- set gq command to use the lsp formatter for this buffer
    vim.api.nvim_buf_set_option(0, 'formatexpr', 'v:lua.vim.lsp.formatexpr()')

    -- document highlight on cursor hold if available
    if venom.features:has(FT.PLUGIN, 'vim-illuminate') then
      require 'illuminate'.on_attach(client)
    end

    -- context aware breadcrumbs
    require 'nvim-navic'.attach(client, bufnr)

    --- signatureHelper capability
    if client.server_capabilities.signatureHelpProvider then
      require 'lsp-overloads'.setup(client, {
        ui = {
          border = "single"
        },
        keymaps = {
          next_signature = "<C-Down>",
          previous_signature = "<C-Up>",
          next_parameter = "<S-Right>",
          previous_parameter = "<S-Left>",
        },
      })
    end
  end

  if not U.has_value(server_config.tags, LST.NO_SHARED_CAPABILITIES) then
    server_config.opts.capabilities = shared_capabilities
  end
  if not U.has_value(server_config.tags, LST.NO_SHARED_HANDLERS) then
    server_config.opts.handlers = shared_handlers
  end
  if not U.has_value(server_config.tags, LST.NO_SHARED_ON_ATTACH) then
    server_config.events.on_attach:sub_front(shared_on_attach)
  end

  return server_config
end)

M.setup_servers = U.Service():require(FT.LSP, 'setup'):new(function(lsp_servers_configs)
  require 'mason-lspconfig'.setup()
  local lspconf = require 'lspconfig'
  
  -- seting up all servers in servers_configs
  for _, server_config in pairs(lsp_servers_configs) do
    server_config = M.apply_shared_server_config(server_config)
  
    -- setting up server
    if U.has_value(server_config.tags, LST.AUTO_SETUP) then
      lspconf[server_config.name].setup(server_config.opts)
    end
  end
end)

M.setup = U.Service():provide(FT.LSP, 'setup')
:require(FT.PLUGIN, 'mason.nvim')
:require(FT.PLUGIN, 'nvim-lspconfig')
:require(FT.PLUGIN, 'inc-rename.nvim')
:new(function()
  -- per line nvim diagnostics
  for type, icon in pairs(venom.icons.diagnostic_states.cozette) do
    local hl = "DiagnosticSign" .. type
    -- if (LSP_DIAG_ICONS == lsp_diag_icons.none) then icon = nil end
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
  end

  vim.api.nvim_create_user_command('LspRename', function() M.rename() end, {})
  vim.api.nvim_create_user_command('LspReferences', function() M.references() end, {})
  vim.api.nvim_create_user_command('LspDefinition', function() M.definition() end, {})
  vim.api.nvim_create_user_command('LspCodeAction', function() M.code_action() end, {})
  vim.api.nvim_create_user_command('LspHover', function() M.hover() end, {})
  vim.api.nvim_create_user_command('LspDiagsList', function() M.diags_list() end, {})
  vim.api.nvim_create_user_command('LspDiagsHover', function() M.diags_hover() end, {})
  vim.api.nvim_create_user_command('LspFormat', function() M.format() end, {})
  -- vim.api.nvim_create_user_command('LspDiagsToggle', function() M.diags_toggle() end, {})
  
  require 'inc_rename'.setup()
  
end)

M.progress_spinner = {
  time = 0,
  curr = 1,
  stages = {
    -- '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏',
    '∙∙∙', '●∙∙', '●∙∙', '∙●∙', '∙●∙', '∙●∙', '∙∙●', '∙∙●', '∙∙∙',
    -- '▁', '▂', '▃', '▄', '▅', '▆', '▇', '█', '▓', '▒', '░', '▒', '▓', '█', '▉', '▊', '▋', '▌', '▍', '▎', '▏',
  },
}

M.get_progress_spinner = U.Service():require(FT.LSP, 'setup'):new(function()
  local res = ''
  if #vim.lsp.buf_get_clients() == 0 then return res end
  if #vim.lsp.util.get_progress_messages() == 0 then return res end
  res = M.progress_spinner.stages[M.progress_spinner.curr]
  M.progress_spinner.curr = M.progress_spinner.curr + 1
  if (M.progress_spinner.curr > #M.progress_spinner.stages) then M.progress_spinner.curr = 1 end
  return res
end)

M.rename = U.Service():new(function()
  require 'inc_rename'.rename {
    default = vim.fn.expand("<cword>")
  }
end)

M.rename_old = U.Service():new(function()
  local curr_name = vim.fn.expand("<cword>")
  local input_opts = {
    prompt = 'LSP Rename',
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
        changes.instances== 1 and '' or 's',
        changes.files,
        changes.files == 1 and '' or 's',
        changes.files > 1 and "To save them run ':wa'" or ''
      )
      vim.notify(message)
    end)
  end)
end)

M.references = U.Service():new(function()
  vim.lsp.buf.references()
end)

M.definition = U.Service():new(function()
  vim.lsp.buf.definition()
end)

M.code_action = U.Service():new(function()
  vim.lsp.buf.code_action()
end)

M.hover = U.Service():require(FT.PLUGIN, 'hover.nvim'):new(function()
  -- vim.lsp.buf.hover()
  require 'hover'.hover()
end)

M.format = U.Service():new(function()
  vim.lsp.buf.format()
end)

M.diags_list = U.Service():new(function()
  vim.diagnostic.setloclist()
  -- vim.diagnostic.setqflist()
end)

M.diags_hover = U.Service():new(function()
  vim.diagnostic.open_float()
end)

-- M.diags_toggle = U.Service():new(function()
--   venom.vals.is_disagnostics_visible = not venom.vals.is_disagnostics_visible
--   if venom.vals.is_disagnostics_visible then vim.diagnostic.show() else vim.diagnostic.hide() end
-- end)

M.setup_buf_fmt_on_save = U.Service():new(function(client, bufnr)
  local augroup_fmt_on_save = vim.api.nvim_create_augroup('format_on_save', {})
	if client.supports_method("textDocument/formatting") then
		vim.api.nvim_clear_autocmds({ group = augroup_fmt_on_save, buffer = bufnr })
		vim.api.nvim_create_autocmd("BufWritePre", {
			group = augroup_fmt_on_save,
			buffer = bufnr,
			callback = function() vim.lsp.buf.format() end,
		})
	end
end)

return M
