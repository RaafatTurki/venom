local plugins_info = require "helpers.plugins_info"
local icons = require "helpers.icons".icons

local M = { plugins_info.cmp.url }

M.dependencies = {
  plugins_info.lspconfig.url,
  -- plugins_info.luasnip.url,
  -- plugins_info.snippets.url,
  -- plugins_info.friendly_snippets.url,
  plugins_info.cmp_buffer.url,
  -- plugins_info.cmp_rg.url,
  plugins_info.cmp_path.url,
  plugins_info.cmp_nvim_lsp.url,
  -- plugins_info.cmp_luasnip.url,
  plugins_info.cmp_cmdline.url,
  { plugins_info.lazydev.url, dependencies = plugins_info.luvit_meta.url, ft = "lua" },
  -- plugins_info.cmp_nvim_lsp_signature_help.url,
}

M.config = function()
  -- TODO: optimize for huge buffers

  local snippets = prequire "snippets"
  local ls = prequire "luasnip"
  local cmp = require "cmp"

  local lazydev = prequire "lazydev"
  if lazydev then
    -- lazydev.setup { library = { plugins = false } }
    lazydev.setup {
      library = {
        -- vim.env.LAZY .. "/luvit-meta/library",
        vim.fn.stdpath("data") .. "/lazy/luvit-meta/library"
        -- vim.env.LAZY .. "/",
      }
    }
  end

  cmp.setup {
    snippet = {
      expand = function(args)
        vim.snippet.expand(args.body)
      end
    },
    mapping = {
      ["<Tab>"]   = cmp.mapping({
        i = function(fb)
          if vim.snippet.jump(1) then
          else fb() end
        end,
        c = function(fb)
          if cmp.visible() then cmp.select_next_item()
          else cmp.complete() end
        end
      }),
      ["<S-Tab>"] = cmp.mapping({
        i = function(fb)
          if vim.snippet.jump(-1) then
          else fb() end
        end,
        c = function(fb)
          if cmp.visible() then cmp.select_prev_item()
          else cmp.complete() end
        end
      }),
      ['<PageDown>']  = cmp.mapping.scroll_docs(4),
      ['<PageUp>']    = cmp.mapping.scroll_docs(-4),
      ['<C-Space>']   = function(fb)
        if cmp.visible() then
          if cmp.visible_docs() then cmp.close_docs() else cmp.open_docs() end
        else
          cmp.complete({})
        end
      end,
      ['<C-e>']       = cmp.mapping.abort(),
      ['<Esc>']       = cmp.mapping.close(),
      -- ['<CR>']        = cmp.mapping.confirm({ select = false, behavior = cmp.ConfirmBehavior.Replace }),
      ['<CR>']        = cmp.mapping.confirm({ select = false }),
      ['<Down>']      = function(fb) cmp.close(); fb() end,
      ['<Up>']        = function(fb) cmp.close(); fb() end,
      ['<C-Down>']    = cmp.mapping.select_next_item(),
      ['<C-Up>']      = cmp.mapping.select_prev_item(),
    },
    sources = {
      -- { name = 'nvim_lua' },
      -- { name = 'rg', option = { additional_arguments = '--smart-case --hidden' }},
      { name = 'path' },
      { name = 'codeium', max_item_count = 3 },
      { name = 'buffer', max_item_count = 3 },
      { name = 'nvim_lsp',
        option = {
          markdown_oxide = {
            keyword_pattern = [[\(\k\| \|\/\|#\)\+]]
          }
        }
      },
      {
        name = "lazydev",
        group_index = 0, -- skip loading LuaLS completions
      }
      -- { name = 'luasnip' },
      -- { name = 'snippets' },
      -- { name = 'omni' },
      -- { name = 'spell' },
      -- { name = 'nvim_lsp_signature_help' },
      -- { name = 'digraphs' },
    },
    formatting = {
      fields = { "kind", "abbr", "menu" },
      format = function(entry, vim_item)
        if entry.source.name == "codeium" then
          vim_item.kind = icons.copilot.Codeium or ''
        else
          vim_item.kind = icons.kind[vim_item.kind] or ''
        end
        return vim_item
      end
    },
    window = {
      -- completion = cmp.config.window.bordered(),
      completion = {
        border = 'single',
        -- winhighlight = '',
        winhighlight = 'CursorLine:PmenuSel',
      },
      documentation = {
        border = 'single',
        winhighlight = '',
      },
    },
    completion = {
      get_trigger_characters = function(trigger_chars)
        local new_trigger_chars = {}
        for _, char in ipairs(trigger_chars) do
          if char ~= '>' then
            table.insert(new_trigger_chars, char)
          end
        end
        return new_trigger_chars
      end
    },
    -- view = {
    --   docs = {
    --     auto_open = false
    --   }
    -- },
    -- experimental = {
    --   ghost_text = { hl_group = 'LspCodeLens' },
    -- }
  }

  cmp.setup.cmdline({ '/', '?' }, {
    sources = {
      { name = 'buffer' },
    }
  })

  cmp.setup.cmdline(':', {
    sources = {
      { name = 'path' },
      { name = 'cmdline' },
    },
  })
end

return M
