--- defines various miscellanous features.
-- @module misc
log = require 'logger'.log
U = require 'utils'

local M = {}

-- TODO: add required and provided features

--- defines command aliases
M.base = U.Service():new(function()
  --- commands
  -- write as sudo
  vim.cmd [[cnoreabbrev w!! w !sudo tee > /dev/null %]]
  -- vert split help page
  -- vim.cmd [[cnoreabbrev h vert help]]
  -- vim.cmd [[autocmd FileType help wincmd L]]

  -- new tab Man page
  -- vim.cmd [[cnoreabbrev m tab Man]]

  -- log
  vim.cmd [[cnoreabbrev l lua log]]

  --- variables
  vim.g.neovide_cursor_vfx_mode = 'pixiedust'
  -- vim.g.neovide_fullscreen = true
  -- vim.g.neovide_profiler = true
  vim.g.gui_font_size = 16
  vim.g.gui_font_face = "Iosevka"
  vim.opt.guifont = string.format("%s:h%s", vim.g.gui_font_face, vim.g.gui_font_size)


  -- TODO: use vim.filetype.add

  --- auto groups
  vim.cmd [[
    augroup base
    au!

    " file name
    au BufEnter .swcrc setlocal ft=json
    au BufEnter tsconfig.json setlocal ft=jsonc
    au BufEnter mimeapps.list setlocal ft=dosini
    au BufEnter PKGBUILD.* setlocal ft=PKGBUILD
    " au BufEnter README setlocal ft=markdown
    au BufEnter nanorc setlocal ft=nanorc
    au BufEnter pythonrc setlocal ft=python
    au BufEnter sxhkdrc,*.sxhkdrc set ft=sxhkdrc
    au BufEnter .classpath setlocal ft=xml
    au BufEnter .env* setlocal ft=sh
    au BufEnter package.json setlocal nofoldenable
    au BufEnter tsconfig.json setlocal nofoldenable

    " file type
    au FileType lspinfo setlocal nofoldenable
    au FileType alpha setlocal cursorline
    au FileType lazy setlocal cursorline

    " comment strings
    au FileType sshdconfig setlocal commentstring=#%s
    au FileType c setlocal commentstring=//%s
    au FileType cs setlocal commentstring=//%s
    au FileType gdscript setlocal commentstring=#%s
    au FileType fish setlocal commentstring=#%s
    au FileType prisma setlocal commentstring=//%s
    au FileType sxhkdrc setlocal commentstring=#%s
    au FileType dart setlocal commentstring=//%s

    " terminal
    au FileType terminal setlocal nocursorline
    au TermOpen * setlocal nonumber

    " au InsertLeave,TextChanged * set foldmethod=expr
    " au BufWritePost * set foldmethod=expr

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
  local open_cmd = nil

  if vim.fn.has("unix") == 1 then
    open_cmd = 'xdg-open'
  elseif vim.fn.has("mac") == 1 then
    open_cmd = 'open'
  elseif vim.fn.has("win64") == 1 or vim.fn.has("win32") then
    open_cmd = 'start'
  end

  function OpenURIUnderCursor()
    if not open_cmd then
      log.warn("OpenURIUnderCursor is not supported on this OS")
      return
    end

    local word_under_cursor = vim.fn.expand("<cfile>")
    local uri = nil

    -- any uri with a protocol segment
    local regex_protocol_uri = "%a*:%/%/[%a%d%#%[%]%-%%+:;!$@/?&=_.,~*()]*"
    if string.match(word_under_cursor, regex_protocol_uri) then uri = word_under_cursor end

    -- anything that looks like string/string into a github repo
    local regex_plugin_url = "[%a%d%-%.%_]+%/[%a%d%-%.%_]+"
    if not uri and string.match(word_under_cursor, regex_plugin_url) then uri = 'https://github.com/' ..
        word_under_cursor end

    -- anything that looks like string-number into a jira link
    local regex_jira_url = "[%a%_]+%-[%d]+"
    if not uri and string.match(word_under_cursor, regex_jira_url) then uri = 'https://jira.example.com/browse/' ..
        word_under_cursor end

    if not uri then
      log.warn("unrecognizable URI")
      return
    end

    vim.fn.jobstart(open_cmd .. ' "' .. uri .. '"', {
      detach = true,
      on_exit = function(chan_id, data, name)
        log.info("URI opened")
      end,
    })
  end

  vim.api.nvim_create_user_command('OpenURIUnderCursor', OpenURIUnderCursor, {})
end)

--- sets color colorcolumn on the below filetypes
M.color_col = U.Service():new(function()
  local seq_str = U.seq(120, 999, ',', 1)
  vim.wo.colorcolumn = seq_str
end)

--- highlights yanked text for a period of time
M.highlight_yank = U.Service():new(function()
  local timeout = 150
  local hl = 'Search'

  vim.api.nvim_create_autocmd('TextYankPost', {
    group = vim.api.nvim_create_augroup('highlight_yank', { clear = true }),
    callback = function(ctx)
      vim.highlight.on_yank({ higroup = hl, timeout = timeout })
    end
  })
end)

--- disables some of the builtin neovim plugins
M.disable_builtin_plugins = U.Service():new(function()
  local disabled_built_ins = {
    "gzip",
    "tar",
    "tarPlugin",
    "zip",
    "zipPlugin",

    "getscript",
    "getscriptPlugin",
    "vimball",
    "vimballPlugin",

    "2html_plugin",
    "logipat",
    "rrhelper",

    "spellfile_plugin",
    -- "matchit",

    "netrw",
    "netrwPlugin",
    "netrwSettings",
    "netrwFileHandlers",
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
      for _, v in ipairs(vim.api.nvim_get_proc_children(pid)) do
        if find_process(v) then return true end
      end
      return false
    end

    if find_process(term_pid) then
      return vim.api.nvim_replace_termcodes(fallback_key, true, true, true)
    else
      return vim.api.nvim_replace_termcodes([[<C-\><C-n>]], true, true, true)
    end
  end
end)

--- prompts to install ts parsers upon opening new file types with available ones.
M.auto_install_ts_parser = U.Service():new(function()
  local blacklist = {}

  vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('auto_install_ts_parser', { clear = true }),
    callback = function(ctx)
      local parsers = require 'nvim-treesitter.parsers'
      local parser_name = parsers.get_buf_lang()

      -- abort if parser is ensured
      if vim.tbl_contains(Lang.ts_parsers_ensure_installed, parser_name) then return end

      if parsers.get_parser_configs()[parser_name] and not parsers.has_parser(parser_name) and not blacklist[parser_name
          ] then
        local answer = U.confirm_yes_no('Install TS parser for ' .. parser_name .. '?')
        if answer then
          vim.cmd([[TSInstall ]] .. parser_name)
        end
        blacklist[parser_name] = true
      end
    end
  })
end)

--- camel!
M.camel = U.Service():new(function()
  local camels = {}
  local conf = { character = "", winblend = 100, speed = 1, width = 2 }

  local waddle = function(camel)
    local timer = vim.loop.new_timer()
    local new_camel = { name = camel, timer = timer }
    table.insert(camels, new_camel)

    local speed = math.abs(100 - (conf.speed or 1))
    vim.loop.timer_start(timer, 1000, speed, vim.schedule_wrap(function()
      if vim.api.nvim_win_is_valid(camel) then
        local config = vim.api.nvim_win_get_config(camel)
        local col, row = config["col"][false], config["row"][false]

        math.randomseed(os.time() * camel)
        local movement = math.ceil(math.random() * 4)
        if movement == 1 or row <= 0 then
          config["row"] = row + 1
        elseif movement == 2 or row >= vim.o.lines - 1 then
          config["row"] = row - 1
        elseif movement == 3 or col <= 0 then
          config["col"] = col + 1
        elseif movement == 4 or col >= vim.o.columns - 2 then
          config["col"] = col - 1
        end
        vim.api.nvim_win_set_config(camel, config)
      end
    end))
  end

  local function spawn(char)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, 1, true, { char or conf.character })

    local camel = vim.api.nvim_open_win(buf, false, {
      relative = 'cursor', style = 'minimal', row = 1, col = 1, width = conf.width or 2, height = 1
    })
    -- vim.api.nvim_win_set_option(camel, 'winblend', conf.winblend or 100)
    vim.api.nvim_win_set_option(camel, 'winhighlight', 'Normal:Camel')

    waddle(camel)
  end

  local function kill_all()
    local last_camel = camels[#camels]
    local camel = last_camel['name']
    local timer = last_camel['timer']
    table.remove(camels, #camels)
    timer:stop()
    timer:close()
    vim.api.nvim_win_close(camel, true)
  end

  function CamelSpawn() spawn() end

  function CamelKill() kill_all() end

  vim.api.nvim_create_user_command('CamelSpawn', CamelSpawn, {})
  vim.api.nvim_create_user_command('CamelKill', CamelKill, {})
end)

--- buffer edits (remove trailing spaces, EOLs)
M.buffer_edits = U.Service():new(function()
  function RemoveTrailingWS()
    -- Save cursor position to later restore
    local curpos = vim.api.nvim_win_get_cursor(0)

    -- Search and replace trailing whitespace
    vim.cmd([[keeppatterns %s/\s\+$//e]])
    vim.api.nvim_win_set_cursor(0, curpos)
  end

  vim.api.nvim_create_user_command('RemoveTrailingWS', RemoveTrailingWS, {})

  function FixEOLs()
    -- Save cursor position to later restore
    local curpos = vim.api.nvim_win_get_cursor(0)

    -- Search and replace trailing whitespace
    vim.cmd([[keeppatterns %s/\r\+$//e]])
    vim.api.nvim_win_set_cursor(0, curpos)
  end

  vim.api.nvim_create_user_command('FixEOLs', FixEOLs, {})
end)

--- minimal tabline
M.tabline_minimal = U.Service():new(function()
  vim.cmd [[
set tabline=%!MyTabLine()

function! MyTabLine()
  let s = ''

  " loop through each tab page
  for i in range(tabpagenr('$'))
    if i + 1 == tabpagenr()
      let s .= '%#TabLineSel#'
    else
      let s .= '%#TabLine#'
    endif
    if i + 1 == tabpagenr()
      let s .= '%#TabLineSel#' " WildMenu
    else
      let s .= '%#Title#'
    endif
    " set the tab page number (for mouse clicks)
    let s .= '%' . (i + 1) . 'T '
    " set page number string
    let s .= i + 1 . ''
    " get buffer names and statuses
    let n = ''  " temp str for buf names
    let m = 0   " &modified counter
    let buflist = tabpagebuflist(i + 1)
    " loop through each buffer in a tab
    for b in buflist
      if getbufvar(b, "&buftype") == 'help'
        " let n .= '[H]' . fnamemodify(bufname(b), ':t:s/.txt$//')
      elseif getbufvar(b, "&buftype") == 'quickfix'
        " let n .= '[Q]'
      elseif getbufvar(b, "&modifiable")
        let n .= fnamemodify(bufname(b), ':t') . ', ' " pathshorten(bufname(b))
      endif
      if getbufvar(b, "&modified")
        let m += 1
      endif
    endfor
    " let n .= fnamemodify(bufname(buflist[tabpagewinnr(i + 1) - 1]), ':t')
    let n = substitute(n, ', $', '', '')
    " add modified label
    if m > 0
      let s .= '+'
      " let s .= '[' . m . '+]'
    endif
    if i + 1 == tabpagenr()
      let s .= ' %#TabLineSel#'
    else
      let s .= ' %#TabLine#'
    endif
    " add buffer names
    if n == ''
      let s.= '[new]'
    else
      let s .= n
    endif
    " switch to no underlining and add final space
    let s .= ' '
  endfor

  " after last tab fill
  let s .= '%#TabLineFill#%T'

  " right-aligned close button
  " if tabpagenr('$') > 1
  "   let s .= '%=%#TabLineFill#%999Xclose'
  " endif
  return s
endfunction
]]
end)

--- automatically create missing directories in the file path
M.auto_create_dir = U.Service():new(function()
  vim.api.nvim_create_autocmd('BufWritePre', {
    group = vim.api.nvim_create_augroup('auto_create_dir', { clear = true }),
    callback = function(ctx)
      vim.fn.mkdir(vim.fn.fnamemodify(ctx.file, ':p:h'), 'p')
    end
  })
end)

--- defines LoremPicsum(), inserts a random image with prompted dimensions
-- TODO: add :require(FT.PLUGIN, 'plenary.nvim')
M.lorem_picsum = U.Service():new(function()
  local curl = require 'plenary.curl'

  local function parse_int(str) return str:match("^%-?%d+$") end

  function LoremPicsum()
    local width = parse_int(vim.fn.input("width: "))
    local height = parse_int(vim.fn.input("height: "))

    if width and height then
      local res = curl.get("https://picsum.photos/" .. width .. "/" .. height, {})
      local url = res.headers[3]:sub(11)

      local cursor = vim.api.nvim_win_get_cursor(0)
      local line = vim.api.nvim_get_current_line()
      local nline = line:sub(0, cursor[2] + 1) .. url .. line:sub(cursor[2] + 2)

      vim.api.nvim_set_current_line(nline)
      vim.api.nvim_win_set_cursor(0, { cursor[1], cursor[2] + url:len() })
    end
  end

  vim.api.nvim_create_user_command('LoremPicsum', LoremPicsum, {})
end)

--- defines GitIgnoreFill(), prompts for a gitignore template and inserts it
-- TODO: add :require(FT.PLUGIN, 'plenary.nvim')
M.auto_gitignore_io = U.Service():new(function()
  local curl = require 'plenary.curl'
  -- local is_in_progress = false

  function GitIgnoreFill()
    -- is_in_progress = true
    local res_list = curl.get("https://www.toptal.com/developers/gitignore/api/list", {})

    if res_list.status == 200 then
      available_gitignores = vim.split(res_list.body, '\n')
      available_gitignores = U.join(available_gitignores, ',')
      available_gitignores = vim.split(available_gitignores, ',')

      vim.ui.select(available_gitignores, { prompt = 'Select a gitignore template' }, function(template_name)
        local res_template = curl.get("https://www.toptal.com/developers/gitignore/api/" .. template_name, {})
        if res_template.status == 200 then
          local pos = vim.api.nvim_win_get_cursor(0)
          vim.api.nvim_buf_set_lines(0, pos[1] - 1, pos[1], false, vim.split(res_template.body, '\n'))
        end
      end)
    end
    -- is_in_progress = false
  end

  vim.api.nvim_create_user_command('GitIgnoreFill', GitIgnoreFill, {})

  -- vim.api.nvim_create_autocmd('BufEnter', {
  --   pattern = {'.gitignore'},
  --   group = vim.api.nvim_create_augroup('gitignore_io', { clear = true }),
  --   callback = function(ctx)
  --     if is_in_progress then return end
  --     local line_count = #vim.api.nvim_buf_get_lines(0, 0, -1, false)
  --
  --     if line_count == 1 then
  --       local answer = U.confirm_yes_no('Fill with a gitignore.io template?')
  --       if answer then
  --         GitIgnoreFill()
  --       end
  --     end
  --   end
  -- })
end)

--- (Linux x86_64) sets up tectonic for latex compiling
-- function M.latex_tectonic()
--   -- install tectonic if it doesn't exist
--   if (not IsBinInstalled('tectonic')) then ScriptLaunchInstaller('install_tectonic.sh') end

--   -- if (not is_file_exists(get_var('subdir_bin')..'tectonic')) then
--   --  script_launch('get_tectonic.sh', get_var('subdir_bin'))
--   -- end
-- end

return M
