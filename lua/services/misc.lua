--- defines various miscellanous features.
-- @module misc
local M = {}

-- TODO: add required and provided features

--- defines command aliases
M.base = U.Service(function()
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
    au BufEnter README setlocal ft=markdown
    au BufEnter nanorc setlocal ft=nanorc
    au BufEnter pythonrc setlocal ft=python
    au BufEnter sxhkdrc,*.sxhkdrc set ft=sxhkdrc
    au BufEnter .classpath setlocal ft=xml
    au BufEnter .env* setlocal ft=sh
    au BufEnter .replit setlocal ft=toml
    au BufEnter package.json setlocal nofoldenable
    au BufEnter tsconfig.json setlocal nofoldenable

    " file type
    au FileType lspinfo setlocal nofoldenable
    au FileType alpha setlocal cursorline
    au FileType lazy setlocal cursorline

    " comment strings
    au FileType sshdconfig setlocal commentstring=#%s
    au FileType c setlocal commentstring=//%s
    au FileType arduino setlocal commentstring=//%s
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
M.diag_on_hold = U.Service(function()
  vim.cmd [[
    augroup diag_on_hold
    autocmd!

    autocmd CursorHold * lua vim.diagnostic.open_float()

    augroup diag_on_hold
  ]]
end)

--- defines OpenURIUnderCursor(), works on urls, uris, vim plugins
M.open_uri = U.Service(function()
  local open_cmd = nil

  if vim.fn.has("unix") == 1 then
    open_cmd = 'xdg-open'
  elseif vim.fn.has("mac") == 1 then
    open_cmd = 'open'
  elseif vim.fn.has("win64") == 1 or vim.fn.has("win32") then
    open_cmd = 'start'
  end

  function OpenURIUnderCursor()
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
      on_exit = function(chan_id, data, name) log.info("URI opened") end,
    })
  end

  vim.api.nvim_create_user_command('OpenURIUnderCursor', OpenURIUnderCursor, {})
end)

--- sets color colorcolumn on the below filetypes
M.color_col = U.Service(function()
  local seq_str = U.seq(120, 999, ',', 1)
  vim.wo.colorcolumn = seq_str
end)

--- highlights yanked text for a period of time
M.highlight_yank = U.Service(function()
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
M.disable_builtin_plugins = U.Service(function()
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
M.term_smart_esc = U.Service(function()
  local exclude_process_names = {
    nvim = true,
    lazygit = true,
  }

  -- function TermSmartEsc(term_pid, fallback_key)
  function TermSmartEsc(fallback_key, term_pid)
    fallback_key = fallback_key or [[<ESC>]]
    ---@diagnostic disable-next-line: undefined-field
    term_pid = term_pid or vim.b.terminal_job_pid

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
M.auto_install_ts_parser = U.Service(function()
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

--- pets!
M.pets = U.Service(function()
  local pets = {}
  local conf = { character = 'x', speed = 2 }

  local waddle = function(pet)
    local timer = vim.loop.new_timer()
    local new_pet = { name = pet, timer = timer }
    table.insert(pets, new_pet)

    local speed = math.abs(100 - (conf.speed or 1))
    vim.loop.timer_start(timer, 1000, speed, vim.schedule_wrap(function()
      if vim.api.nvim_win_is_valid(pet) then
        local pet_cfg = vim.api.nvim_win_get_config(pet)
        local col, row = pet_cfg["col"][false], pet_cfg["row"][false]

        math.randomseed(os.time() * pet)
        local movement = math.ceil(math.random() * 4)
        if movement == 1 or row <= 0 then
          pet_cfg["row"] = row + 1
        elseif movement == 2 or row >= vim.o.lines - 1 then
          pet_cfg["row"] = row - 1
        elseif movement == 3 or col <= 0 then
          pet_cfg["col"] = col + 1
        elseif movement == 4 or col >= vim.o.columns - 2 then
          pet_cfg["col"] = col - 1
        end
        vim.api.nvim_win_set_config(pet, pet_cfg)
      end
    end))
  end

  local function spawn()
    local pet_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(pet_buf, 0, 1, true, { conf.character })

    local pet_win = vim.api.nvim_open_win(pet_buf, false, {
      relative = 'win',
      style = 'minimal',
      row = vim.api.nvim_win_get_height(0)-vim.o.cmdheight,
      col = 0,
      width = 1,
      height = 1
    })
    -- vim.api.nvim_win_set_option(camel, 'winblend', conf.winblend or 100)
    vim.api.nvim_win_set_option(pet_win, 'winhighlight', 'Normal:Camel')
    waddle(pet_win)
  end

  local function kill_last()
    local last_pet = pets[#pets]
    local pet = last_pet['name']
    local timer = last_pet['timer']
    table.remove(pets, #pets)
    timer:stop()
    timer:close()
    vim.api.nvim_win_close(pet, true)
  end

  function PetSpawn() spawn() end
  function PetKillLast() kill_last() end
  vim.api.nvim_create_user_command('PetSpawn', PetSpawn, {})
  vim.api.nvim_create_user_command('PetKillLast', PetKillLast, {})
end)

--- buffer edits (remove trailing spaces, EOLs)
M.buffer_edits = U.Service(function()
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

--- automatically create missing directories in the file path
M.auto_create_dir = U.Service(function()
  vim.api.nvim_create_autocmd('BufWritePre', {
    group = vim.api.nvim_create_augroup('auto_create_dir', { clear = true }),
    callback = function(ctx)
      vim.fn.mkdir(vim.fn.fnamemodify(ctx.file, ':p:h'), 'p')
    end
  })
end)

--- defines LoremPicsum(), inserts a random image with prompted dimensions
-- TODO: add :require(FT.PLUGIN, 'plenary.nvim')
M.lorem_picsum = U.Service(function()
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
M.auto_gitignore_io = U.Service(function()
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

--- conceals html classes
M.conceal_html_classes = U.Service({}, function()
  local namespace = vim.api.nvim_create_namespace("class_conceal")
  local group = vim.api.nvim_create_augroup("class_conceal", { clear = true })

  local conceal_html_class = function(bufnr)
    local language_tree = vim.treesitter.get_parser(bufnr, "html")
    local syntax_tree = language_tree:parse()
    local root = syntax_tree[1]:root()

    local query = vim.treesitter.parse_query("html",
      [[
        ((attribute
          (attribute_name) @att_name (#eq? @att_name "class")
          (quoted_attribute_value (attribute_value) @class_value) (#set! @class_value conceal "…")
        ))
      ]]
    )

    for _, captures, metadata in query:iter_matches(root, bufnr, root:start(), root:end_()) do
      local start_row, start_col, end_row, end_col = captures[2]:range()
      vim.api.nvim_buf_set_extmark(bufnr, namespace, start_row, start_col, {
        end_line = end_row,
        end_col = end_col,
        conceal = metadata[2].conceal,
      })
    end
  end

  vim.api.nvim_create_autocmd({ "BufWritePost", "TextChanged", "BufEnter" }, {
    group = group,
    pattern = "*.html,*.svelte",
    callback = function()
      local bufnr = vim.api.nvim_get_current_buf()
      conceal_html_class(bufnr)
    end,
  })
end)

return M
