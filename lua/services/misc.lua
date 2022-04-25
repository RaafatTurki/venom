--- defines various miscellanous features.
-- @module misc
local M = {}

-- TODO: add required and provided features

--- defines command aliases
M.base = U.Service():new(function()
  --- commands
  -- write as sudo
  vim.cmd [[cnoreabbrev w!! w !sudo tee > /dev/null %]]
  -- new tab help page
  vim.cmd [[cnoreabbrev h tab help]]
  -- inspect lua utility
  vim.cmd [[cnoreabbrev insp lua inspect()]]
  -- new tab
  vim.cmd [[cnoreabbrev nt tabnew]]
  -- quit all
  vim.cmd [[cnoreabbrev Q qall]]
  -- edit config file
  vim.cmd [[cnoreabbrev conf tabnew $VIM_ROOT/init.vim]]

  --- variables

  --- auto groups
  -- disable LspInfo win, package.json folding
  name = name or 'end'

  vim.cmd [[
    augroup base
    autocmd!

    " buffer type"
    autocmd BufEnter .swcrc setlocal ft=json
    autocmd BufEnter tsconfig.json setlocal ft=jsonc
    autocmd BufEnter mimeapps.list setlocal ft=dosini

    " file type
    autocmd FileType lspinfo setlocal nofoldenable
    autocmd FileType packer setlocal nocursorline
    autocmd FileType alpha setlocal cursorline

    " terminal"
    autocmd FileType terminal setlocal nocursorline
    autocmd TermOpen * setlocal nonumber

    augroup base
    ]]

end)

--- shows diagnostics on cursor hold
M.diag_on_hold = U.Service():new(function()
  vim.cmd [[
    augroup diag_on_hold
    autocmd!

    autocmd CursorHold * lua vim.diagnostic.open_float()

    augroup diag_on_hold
  ]]
end)

--- defines OpenURIUnderCursor(), works on urls, uris, vim plugins
M.open_uri = U.Service():new(function()
  function OpenURIUnderCursor()
    local function open_uri(uri)
      if type(uri) ~= 'nil' then
        uri = string.gsub(uri, "#", "\\#") --double escapes any # signs
        uri = '"'..uri..'"'
        vim.cmd('!xdg-open '..uri..' > /dev/null')
        vim.cmd('mode')
        -- print(uri)
        return true
      else
        return false
      end
    end

    local word_under_cursor = vim.fn.expand("<cWORD>")

    -- any uri with a protocol segment
    local regex_protocol_uri = "%a*:%/%/[%a%d%#%[%]%-%%+:;!$@/?&=_.,~*()]*"
    if (open_uri(string.match(word_under_cursor, regex_protocol_uri))) then return end

    -- plugin github url
    local regex_plugin_url = "[%a%d%-%.%_]*%/[%a%d%-%.%_]*"
    if (open_uri('https://github.com/'..string.match(word_under_cursor, regex_plugin_url))) then return end
  end
  U.create_command('OpenURIUnderCursor lua OpenURIUnderCursor()')
end)

--- sets color colorcolumn on the below filetypes
M.color_col = U.Service():new(function()
  local seq_str = U.seq(120, 999, ',', 1)
  local ft = '*'
  U.create_augroup('autocmd FileType '..ft..' setlocal colorcolumn='..seq_str, 'color_col')
end)

--- highlights yanked text for a period of time
M.highlight_yank = U.Service():new(function()
  local timeout = 150
  local hl = 'Search'

  U.create_augroup([[
    au TextYankPost * silent! lua vim.highlight.on_yank { higroup=']]..hl..[[', timeout=]]..timeout..[[ }
  ]], 'highlight_yank')
end)

--- disables some of the builtin neovim plugins
M.disable_builtin_plugins = U.Service():new(function()
  local disabled_built_ins = {
    "2html_plugin",
    "getscript",
    "getscriptPlugin",
    "gzip",
    "logipat",
    "netrw",
    "netrwPlugin",
    "netrwSettings",
    "netrwFileHandlers",
    "matchit",
    "tar",
    "tarPlugin",
    "rrhelper",
    "spellfile_plugin",
    "vimball",
    "vimballPlugin",
    "zip",
    "zipPlugin",
  }

  for _, plugin in pairs(disabled_built_ins) do
    vim.g["loaded_" .. plugin] = 1
  end
end)

--- defines TermSmartEsc(), escapes term mode of running process isn't in blacklist
M.term_smart_esc = U.Service():new(function()
  local exclude_process_names = {
    nvim = true,
    lazygit = true,
  }

  function TermSmartEsc(term_pid, fallback_key)
    local function find_process(pid)
      local p = vim.api.nvim_get_proc(pid)
      if exclude_process_names[p.name] then return true end
      for _,v in ipairs(vim.api.nvim_get_proc_children(pid)) do
        if find_process(v) then return true end
      end
      return false
    end
    if find_process(term_pid) then
      return U.term_codes_esc(fallback_key)
    else
      return U.term_codes_esc [[<C-\><C-n>]]
    end
  end
end)

--- defines new/improved lsp functions
M.lsp_funcs = U.Service():new(function()
  -- better rename
  function LspRename()
    local curr_name = vim.fn.expand("<cword>")
    local input_opts = {
      prompt = 'LSP Rename',
      default = curr_name
    }

    -- ask yser input
    vim.ui.input(input_opts, function(new_name)
      -- check new_name is valid
      if not new_name or #new_name == 0 or curr_name == new_name then return end

      -- request lsp rename
      local params = vim.lsp.util.make_position_params()
      params.newName = new_name

      vim.lsp.buf_request(0, "textDocument/rename", params, function(_, res, ctx, _)
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
  end
end)

--- prompts to install ts parsers upon opening new file types with available ones.
M.automatic_treesitter = U.Service():new(function()
  local ask_install = {}

  function EnsureTSParserInstalled()
    local parsers = require 'nvim-treesitter.parsers'
    local lang = parsers.get_buf_lang()

    if parsers.get_parser_configs()[lang] and not parsers.has_parser(lang) and ask_install[lang] ~= false then
      vim.schedule_wrap(function()

        local is_confirmed = false
        -- TODO: implement a Y/n prompt util func
        print('Install treesitter parser for '..lang.. ' ? Y/n')
        local res = U.get_char_input()
        if res:match('\r') then is_confirmed = true end
        if res:match('y') then is_confirmed = true end
        if res:match('Y') then is_confirmed = true end
        U.clear_prompt()

        if (is_confirmed) then
          vim.cmd('TSInstall '..lang)
        else
          ask_install[lang] = false
        end

      end)()
    end

  end

  -- TODO: convert to auto group
  vim.cmd [[au FileType * :lua EnsureTSParserInstalled()]]
end)


--- (Linux) makes neovim support hex editing
-- function M.binary_editor()
--   -- this is achievable through a piece of software that resides within vim called xxd, one must either:
--   -- install vim
--   -- install xxd-standalone (aur)
--   -- sit back and let the scripts system do the work

--   -- install xxd if it doesn't exist
--   if (not IsBinInstalled('xxd')) then ScriptLaunchInstaller('install_xxd.sh') end

--   -- file extensions to treat as binaries
--   local ft = '*.bin,*.out'

--   augroup([[
--     au BufReadPre  ]]..ft..[[ let &bin=1
--     au BufReadPost ]]..ft..[[ if &bin | %!xxd
--     au BufReadPost ]]..ft..[[ set ft=xxd | endif
--     au BufWritePre ]]..ft..[[ if &bin | %!xxd -r
--     au BufWritePre ]]..ft..[[ endif
--     au BufWritePost ]]..ft..[[ if &bin | %!xxd
--     au BufWritePost ]]..ft..[[ set nomod | endif
--   ]], 'binary_edit')
-- end

--- (Linux x86_64) sets up tectonic for latex compiling
-- function M.latex_tectonic()
--   -- install tectonic if it doesn't exist
--   if (not IsBinInstalled('tectonic')) then ScriptLaunchInstaller('install_tectonic.sh') end

--   -- if (not is_file_exists(get_var('subdir_bin')..'tectonic')) then
--   --  script_launch('get_tectonic.sh', get_var('subdir_bin'))
--   -- end
-- end

return M
