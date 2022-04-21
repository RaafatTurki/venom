-- requires plenary, nvim-web-devicons

local Path = require 'plenary.path'
local button = require 'alpha.themes.dashboard'.button

local M = {}

M.opts = {
  devicons = {
    enabled = true,
    highlight = true,
  },
  mru = {
    ignore = function(path, ext)
      return (string.find(path, "COMMIT_EDITMSG")) or (vim.tbl_contains({ "gitcommit" }, ext))
    end,
    target_width = 35,
  },
  header = {
    type = "text",
    val = {
      [[                               __                ]],
      [[  ___     ___    ___   __  __ /\_\    ___ ___    ]],
      [[ / _ `\  / __`\ / __`\/\ \/\ \\/\ \  / __` __`\  ]],
      [[/\ \/\ \/\  __//\ \_\ \ \ \_/ |\ \ \/\ \/\ \/\ \ ]],
      [[\ \_\ \_\ \____\ \____/\ \___/  \ \_\ \_\ \_\ \_\]],
      [[ \/_/\/_/\/____/\/___/  \/__/    \/_/\/_/\/_/\/_/]],
    },
    opts = {
      position = "center",
      hl = "Type",
      -- wrap = "overflow";
    },
  }
}

local function get_icon(fn)
  local nwd = require 'nvim-web-devicons'
  local ext = U.fn():ext(fn)
  return nwd.get_icon(fn, ext, { default = true })
end

local function file_button(fn, key, short_fn)
  short_fn = short_fn or fn
  local ico_txt = ""
  local fb_hl = {}

  if M.opts.devicons.enabled then
    local ico, hl = get_icon(fn)
    local hl_option_type = type(M.opts.devicons.highlight)
    if hl_option_type == "boolean" then
      if hl and M.opts.devicons.highlight then
        table.insert(fb_hl, { hl, 0, 3 })
      end
    end
    if hl_option_type == "string" then
      table.insert(fb_hl, { M.opts.devicons.highlight, 0, 3 })
    end
    ico_txt = ico .. "  "
  end

  local file_button_el = button(key, ico_txt .. short_fn, "<cmd>e " .. fn .. " <CR>")
  local fn_start = short_fn:match(".*[/\\]")

  if fn_start ~= nil then
    table.insert(fb_hl, { "Comment", #ico_txt-2, #fn_start + #ico_txt })
  end

  file_button_el.opts.hl = fb_hl
  return file_button_el
end

local function spacer(amount)
  return { type = "padding", val = amount }
end

local function group(val)
  return {
    type = "group",
    position = "center",
    val = val
  }
end

local function section(title, content)
  return group {
    { type = "text", val = title, opts = { hl = "SpecialComment", position = "center" } },
    spacer(1),
    group(content),
  }
end


--- @param start number
--- @param cwd string optional
--- @param items_number number optional number of items to generate, default = 10
local function mru(start, cwd, items_number, opts)
  opts = opts or M.opts.mru
  items_number = items_number or 10

  -- filling recent files with proper recent files
  local res = {}

  for _, fn in pairs(vim.v.oldfiles) do
    if #res == items_number then break end

    local is_in_cwd
    if not cwd then
      is_in_cwd = true
    else
      is_in_cwd = vim.startswith(fn, cwd)
    end

    local ignore = (opts.ignore and opts.ignore(fn, U.fn():ext(fn))) or false
    local is_readable = vim.fn.filereadable(fn) == 1

    if is_readable and is_in_cwd and not ignore then table.insert(res, fn) end
  end

  -- path shortening, and icons
  for i, fn in ipairs(res) do
    local short_fn
    if cwd then
      short_fn = vim.fn.fnamemodify(fn, ":.")
    else
      short_fn = vim.fn.fnamemodify(fn, ":~")
    end

    if(#short_fn > M.opts.mru.target_width) then
      short_fn = Path.new(short_fn):shorten(1, {-2, -1})
      if(#short_fn > M.opts.mru.target_width) then
        short_fn = Path.new(short_fn):shorten(1, {-1})
      end
    end

    local shortcut = tostring(i+start-1)

    local file_button_el = file_button(fn, shortcut, short_fn)
    res[i] = file_button_el
  end

  return group(res)
end

M.config = {
  layout = {
    spacer(3),
    M.opts.header,
    spacer(2),
    section("Quick links", {
      button("e", "  New file",        "<CMD>ene<CR>"),
      button("c", "  Configuration",   "<CMD>cd ~/.config/nvim<CR>"),
      button("u", "  Update plugins" , "<CMD>PackerSync<CR>"),
      button("q", "  Quit",            "<CMD>qa<CR>"),
      -- button("SPC f f", "  Find file"),
      -- button("SPC f g", "  Live grep"),
    }),
    spacer(2),
    section("Recent files", function() return { mru(0, vim.fn.getcwd(), 5) } end),
  },

  opts = {
    setup = function()
      vim.cmd([[autocmd alpha_temp DirChanged * lua require('alpha').redraw()]])
    end,
    margin = 5,
  },
}

return M
