local ts = require "nvim-treesitter"
local query = require "vim.treesitter.query"

-- TODO: remove once unneeded
local function patch_query_predicates_for_nvim_012()
  if vim.fn.has("nvim-0.12") ~= 1 then
    return
  end

  local html_script_type_languages = {
    ["importmap"] = "json",
    ["module"] = "javascript",
    ["application/ecmascript"] = "javascript",
    ["text/ecmascript"] = "javascript",
  }

  local non_filetype_match_injection_language_aliases = {
    ex = "elixir",
    pl = "perl",
    sh = "bash",
    uxn = "uxntal",
    ts = "typescript",
  }

  local function get_parser_from_markdown_info_string(injection_alias)
    local match = vim.filetype.match({ filename = "a." .. injection_alias })
    return match or non_filetype_match_injection_language_aliases[injection_alias] or injection_alias
  end

  local function valid_args(name, pred, count, strict_count)
    local arg_count = #pred - 1

    if strict_count then
      if arg_count ~= count then
        vim.api.nvim_err_writeln(string.format("%s must have exactly %d arguments", name, count))
        return false
      end
    elseif arg_count < count then
      vim.api.nvim_err_writeln(string.format("%s must have at least %d arguments", name, count))
      return false
    end

    return true
  end

  local function capture_node(match, id)
    local nodes = match[id]
    if not nodes then
      return nil
    end
    if type(nodes) ~= "table" then
      return nodes
    end
    return nodes[1]
  end

  local opts = { force = true, all = false }

  query.add_predicate("nth?", function(match, _pattern, _bufnr, pred)
    if not valid_args("nth?", pred, 2, true) then
      return
    end

    local node = capture_node(match, pred[2])
    local n = tonumber(pred[3])
    if node and node:parent() and node:parent():named_child_count() > n then
      return node:parent():named_child(n) == node
    end

    return false
  end, opts)

  query.add_predicate("is?", function(match, _pattern, bufnr, pred)
    if not valid_args("is?", pred, 2) then
      return
    end

    local locals = require "nvim-treesitter.locals"
    local node = capture_node(match, pred[2])
    local types = { unpack(pred, 3) }

    if not node then
      return true
    end

    local _, _, kind = locals.find_definition(node, bufnr)
    return vim.tbl_contains(types, kind)
  end, opts)

  query.add_predicate("kind-eq?", function(match, _pattern, _bufnr, pred)
    if not valid_args(pred[1], pred, 2) then
      return
    end

    local node = capture_node(match, pred[2])
    local types = { unpack(pred, 3) }

    if not node then
      return true
    end

    return vim.tbl_contains(types, node:type())
  end, opts)

  query.add_directive("set-lang-from-mimetype!", function(match, _, bufnr, pred, metadata)
    local capture_id = pred[2]
    local node = capture_node(match, capture_id)
    if not node then
      return
    end

    local type_attr_value = vim.treesitter.get_node_text(node, bufnr)
    local configured = html_script_type_languages[type_attr_value]
    if configured then
      metadata["injection.language"] = configured
    else
      local parts = vim.split(type_attr_value, "/", {})
      metadata["injection.language"] = parts[#parts]
    end
  end, opts)

  query.add_directive("set-lang-from-info-string!", function(match, _, bufnr, pred, metadata)
    local capture_id = pred[2]
    local node = capture_node(match, capture_id)
    if not node then
      return
    end

    local injection_alias = vim.treesitter.get_node_text(node, bufnr):lower()
    metadata["injection.language"] = get_parser_from_markdown_info_string(injection_alias)
  end, opts)

  query.add_directive("downcase!", function(match, _, bufnr, pred, metadata)
    local id = pred[2]
    local node = capture_node(match, id)
    if not node then
      return
    end

    local text = vim.treesitter.get_node_text(node, bufnr, { metadata = metadata[id] }) or ""
    if not metadata[id] then
      metadata[id] = {}
    end
    metadata[id].text = string.lower(text)
  end, opts)
end

patch_query_predicates_for_nvim_012()

vim.api.nvim_create_autocmd("PackChanged", {
  group = vim.api.nvim_create_augroup("pack-build-treesitter", { clear = true }),
  pattern = { "nvim-treesitter" },
  callback = function(event)
    vim.notify("Updating treesitter parsers", vim.log.levels.INFO)
    ts.update(nil, { summary = true }):wait(30 * 1000)
  end
})


vim.o.foldmethod = 'expr'
vim.o.foldcolumn = '1'
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
-- vim.o.foldtext = ''
vim.o.foldtext = [[substitute(getline(v:foldstart),'\t',repeat(' ',&tabstop),'g').' ... '.trim(getline(v:foldend))]]
-- vim.o.foldtext = [[substitute(getline(v:foldstart),'\\t',repeat('\ ',&tabstop),'g').' ... ']]


vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

-- vim.o.foldmethod  = "expr"
-- vim.o.foldexpr    = "v:lua.vim.treesitter.foldexpr()"
-- vim.o.foldtext    = "v:lua.vim.treesitter.foldtext()"


-- require("treesitter-autoinstall").setup({
--   ignore = { "minimap", "neo-tree" },
--   highlight = true,
--   regex = {},
-- })

require 'nvim-treesitter.configs'.setup {
  -- ensure_installed = "all",
  auto_install = true,
  -- ignore_install = {
  --   -- "csv",
  --   -- "json",
  -- },
  highlight = {
    enable = true,
    disable = function(lang, buf)
      if vim.b[buf].large_buf then return true end
      -- local ft = vim.api.nvim_get_option_value('filetype', { buf = buf })
      -- local is_ft_blocked = vim.tbl_get(filetypes, ft, "highlight") == false

      -- return is_ft_blocked
      return false
    end,
  },
  indent = {
    enable = true,
    disable = function(lang, buf)
      if vim.b[buf].large_buf then return true end
      -- local ft = vim.api.nvim_get_option_value('filetype', { buf = buf })
      -- local is_ft_blocked = vim.tbl_get(filetypes, ft, "indent") == false
      --
      -- return is_ft_blocked
      return false
    end,
  },
}
