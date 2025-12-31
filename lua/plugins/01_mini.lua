local keys = require "helpers.keys"

-- extra
do
  require "mini.extra".setup()
end

-- icons
do
  require "mini.icons".setup {}
  -- MiniIcons.mock_nvim_web_devicons()
end

-- bufremove
do
  require 'mini.bufremove'.setup {}
  keys.map("n", "<A-c>", MiniBufremove.delete, "Delete buffer")
end

-- git
do
  require "mini.git".setup {}
end

-- diff
do
  require "mini.diff".setup {
    view = {
      style = 'sign',
      signs = { add = '│', change = '│', delete = '-' },
    },
    mappings = {
      apply = 'gs',
      reset = 'gr',
      textobject = 'gh',
      goto_prev = 'g<Left>',
      goto_next = 'g<Right>',
    },
  }
end

-- move
do
  require 'mini.move'.setup()
  keys.map("n", "<Tab>",      function() MiniMove.move_line('right') end, "Indent")
  keys.map("n", "<S-Tab>",    function() MiniMove.move_line('left') end, "Deindent")
  keys.map("x", "<Tab>",      function() MiniMove.move_selection('right') end, "Visual indent")
  keys.map("x", "<S-Tab>",    function() MiniMove.move_selection('left') end, "Visual deindent")
  keys.map("n", "<A-Down>",   function() MiniMove.move_line('down') end, "Shift line down")
  keys.map("n", "<A-Up>",     function() MiniMove.move_line('up') end, "Shift line up")
  keys.map("x", "<A-Down>",   function() MiniMove.move_selection('down') end, "Visual shift lines down")
  keys.map("x", "<A-Up>",     function() MiniMove.move_selection('up') end, "Visual shift lines up")
end

-- trailspace
do
  require 'mini.trailspace'.setup()
  vim.api.nvim_create_user_command('Trim', MiniTrailspace.trim, {})
  vim.api.nvim_create_user_command('TrimLastLines', MiniTrailspace.trim_last_lines, {})
  vim.api.nvim_create_user_command('TrimAll', function()
    MiniTrailspace.trim()
    MiniTrailspace.trim_last_lines()
  end, {})
end

-- pick
do
  require 'mini.pick'.setup {
    window = {
      config = function()
        height = math.floor(0.6 * vim.o.lines)
        width = math.floor(0.6 * vim.o.columns)

        return {
          anchor = 'NW',
          height = height,
          width = width,
          row = math.floor(0.5 * (vim.o.lines - height)),
          col = math.floor(0.5 * (vim.o.columns - width)),
        }
      end
    },
    mappings = {
      sys_paste = {
        char = "<C-v>",
        func = function()
          MiniPick.set_picker_query({ vim.fn.getreg("+") })
        end,
      },
    }
  }
  keys.map("n", "<leader><CR>", MiniPick.builtin.resume, "Pick resume")
  keys.map("n", "<leader>f",    MiniPick.builtin.files, "Pick find files")
  keys.map("n", "<leader>g",    MiniPick.builtin.grep_live, "Pick grep string")
  keys.map("n", "<leader>h",    MiniPick.builtin.help, "Pick help pages")
  -- keys.map("n", "<leader>b",    "<CMD>Pick buffer_lines<CR>", "Pick buffer lines")
  -- keys.map("n", "<leader>b",    "<CMD>Pick diagnostic<CR>", "Pick lsp diagnostics")
  -- keys.map("n", "<leader>b",    "<CMD>Pick explorer<CR>", "Pick file tree explorer")
  -- keys.map("n", "<leader>b",    "<CMD>Pick git_branches<CR>", "Pick git branches")
  -- keys.map("n", "<leader>b",    "<CMD>Pick git_commits<CR>", "Pick git commits")
  -- keys.map("n", "<leader>b",    "<CMD>Pick git_files<CR>", "Pick git files")
  -- keys.map("n", "<leader>b",    "<CMD>Pick git_hunks<CR>", "Pick git hunks")
  -- use mini pick as the default selection picker for vim
  vim.ui.select = MiniPick.ui_select
end

-- notify
do
  require "mini.notify".setup {
    content = {
      -- remove the timestamp
      format = function(str)
        local parts = vim.split(str.msg, ': ')
        if #parts == 2 then return parts[2] end
        return string.format('%s', str.msg)
      end,
    },
    lsp_progress = {
      enable = true,
      duration_last = 100,
    },
    window = {
      config   = function ()
        local pad = vim.o.cmdheight + (vim.o.laststatus > 0 and 1 or 0)

        return {
          row    = vim.o.lines - pad - 1,
          col    = vim.o.columns - 1, -- because of the scrollbar
          border = 'none',
          anchor = 'SE',
        }
      end,
      winblend = 0,
    },
  }
  -- use mini notify as the default notify function for vim
  vim.notify = MiniNotify.make_notify()
end

-- hipatterns
do
  local hipatterns = require 'mini.hipatterns'
  local highlighters = {}

  -- add the venom highlights
  local hls = vim.api.nvim_get_hl(0, {})

  function is_hl_empty(group)
    -- check if hl is empty
    local hl = hls[group]
    if hl == nil then return true end
    if vim.tbl_isempty(hl) then return true end

    -- recurse on link hl
    local group_link = hl.link
    local hl_link = hls[group_link]
    if hl_link ~= nil then return is_hl_empty(hl_link) end

    return false
  end
  function lsp_hl_get_closest_defined_parent_group(group)
    if (not is_hl_empty(group)) then return group end

    local segments = vim.split(group, '%.')
    table.remove(segments, #segments)
    parent_group = table.concat(segments, '.')
    if not is_hl_empty(parent_group) then
      return lsp_hl_get_closest_defined_parent_group(parent_group)
    end

    return "Comment"
  end

  for group, _ in pairs(hls) do
    highlighters[group] = {
      pattern = function(bufnr)
        if vim.api.nvim_buf_get_name(bufnr):match("venom.lua$") then
          -- match highlight groups in buffer that are standalone words and might be prefixed with a @
          -- return '%f[%w%@]()' .. group .. '()%f[%W]'
          return '%f[%w]()' .. group .. '()%f[%W]'
        end
      end,
      group = function(_, _, _)
        -- if string.sub(hl, 1, 1) == '@' then
        -- if string.sub(group, 1, 1) == '@' and is_hl_empty(group) then
        --   return lsp_hl_get_closest_defined_parent_group(group)
        -- end
        return group
      end
    }
  end

  highlighters["fixme"] = { pattern = 'FIXME:', group = 'MiniHipatternsFixme' }
  highlighters["xxx"] = { pattern = 'XXX:', group = 'MiniHipatternsFixme' }
  highlighters["hack"] = { pattern = 'HACK:',  group = 'MiniHipatternsHack' }
  highlighters["sanity_check"] = { pattern = 'SANITY_CHECK:',  group = 'MiniHipatternsHack' }
  highlighters["todo"] = { pattern = 'TODO:',  group = 'MiniHipatternsTodo' }
  highlighters["deprecated"] = { pattern = 'DEPRECATED:',  group = 'MiniHipatternsFixme' }
  highlighters["note"] = { pattern = 'NOTE:',  group = 'MiniHipatternsNote' }
  highlighters["<<<<<<<"] = { pattern = '<<<<<<<',  group = 'MiniHipatternsFixme' }
  highlighters[">>>>>>>"] = { pattern = '>>>>>>>',  group = 'MiniHipatternsFixme' }
  highlighters["======="] = { pattern = '=======',  group = 'MiniHipatternsFixme' }

  highlighters["hex"] = hipatterns.gen_highlighter.hex_color()

  hipatterns.setup {
    highlighters = highlighters
  }
end

-- map
do
local MiniMap = require "mini.map"
require "mini.map".setup {
  window = {
    width = 1,
    winblend = 0,
    show_integration_count = false,
  },
  symbols = {
    -- encode = MiniMap.gen_encode_symbols.dot('4x2'),
    -- encode = MiniMap.gen_encode_symbols.block('2x1'),
    -- encode = MiniMap.gen_encode_symbols.shade('2x1'),
    scroll_line = '┃',
    scroll_view = '│',
  },
  integrations = {
    -- MiniMap.gen_integration.builtin_search(),
    -- MiniMap.gen_integration.gitsigns(),
    -- MiniMap.gen_integration.diagnostic(),
  },
}

-- refresh on window resize
vim.api.nvim_create_autocmd('VimResized', {
  callback = function(ev) MiniMap.refresh() end
})

-- open on vim enter
vim.api.nvim_create_autocmd('VimEnter', {
  callback = function(ev) MiniMap.open() end
})

-- hide on insert
vim.api.nvim_create_autocmd('ModeChanged', {
  callback = function(ev)
    local mode = vim.api.nvim_get_mode().mode
    if mode == 'i' then
      MiniMap.close()
    else
      MiniMap.open()
    end
  end
})
end
