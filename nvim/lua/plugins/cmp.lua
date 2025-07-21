--[[
  blink.cmp configuration for Neovim autocompletion.
  - Replaces nvim-cmp with a faster Rust-based completion engine.
  - Integrates with LSP, snippets, buffer, path, and lazydev sources.
  - Provides customized keybindings and UI styling.
]]

-- Define your LSP kind icons (extracted from your original config)
local lspkind_icons = {
  Class = '󰠱',
  Color = '󰏘',
  Constant = '󰏿',
  Constructor = '',
  Enum = '',
  EnumMember = '',
  Event = '',
  Field = '󰜢',
  File = '󰈙',
  Folder = '󰉋',
  Function = '󰊕',
  Interface = '',
  Keyword = '󰌋',
  Method = '󰆧',
  Module = '',
  Operator = '',
  Property = '',
  Reference = '󰈇',
  Snippet = '',
  Struct = '󰙅',
  Text = '󰉿',
  TypeParameter = '',
  Unit = '',
  Value = '󰎠',
  Variable = '󰀫',
}

return {
  'saghen/blink.cmp',
  -- Use cargo build instead of nix for systems without nix
  build = 'cargo build --release',
  event = { 'InsertEnter', 'CmdlineEnter' },
  dependencies = {
    -- Optional: for snippet support
    {
      'L3MON4D3/LuaSnip',
      build = 'make install_jsregexp',
    },
    'rafamadriz/friendly-snippets',
    'folke/lazydev.nvim',
  },
  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    appearance = {
      kind_icons = lspkind_icons,
    },
    cmdline = {
      enabled = false,
      completion = {
        menu = { auto_show = false },
      },
      keymap = {
        ['<Tab>'] = { 'select_and_accept' },
        -- ['<CR>'] = { 'accept' },
      },
    },
    completion = {
      accept = {
        auto_brackets = { enabled = true },
      },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 500,
        window = {
          border = 'rounded',
        },
      },
      keyword = { range = 'full' },
      menu = {
        border = 'rounded',
        draw = {
          columns = {
            { 'kind_icon' },
            { 'label',      'label_description', gap = 1 },
            { 'source_name' },
          },
          components = {
            source_name = {
              text = function(ctx)
                local source_map = {
                  buffer = 'buff',
                  lazydev = 'lazy',
                  luasnip = 'snip',
                  lsp = 'lsp',
                  path = 'path',
                  snippets = 'snip',
                }
                return source_map[ctx.source_name] or ctx.source_name
              end,
            },
          },
        },
      },
    },
    fuzzy = {
      sorts = { 'exact', 'score', 'sort_text' },
    },
    keymap = {
      preset = 'default',
      -- Disable default Tab/S-Tab to customize them
      ['<Tab>'] = {
        function(cmp)
          if cmp.is_visible() then
            return cmp.select_next()
          else
            return cmp.snippet_forward() or false
          end
        end,
        'fallback',
      },
      ['<S-Tab>'] = {
        function(cmp)
          if cmp.is_visible() then
            return cmp.select_prev()
          else
            return cmp.snippet_backward() or false
          end
        end,
        'fallback',
      },
      -- Navigation similar to your original config
      ['<C-n>'] = { 'select_next', 'fallback' },
      ['<C-p>'] = { 'select_prev', 'fallback' },
      ['<C-d>'] = { 'scroll_documentation_up', 'fallback' },
      ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
      ['<C-Space>'] = {
        function(cmp)
          cmp.show({ providers = { 'lsp' } })
        end,
      },
      ['<C-e>'] = { 'cancel', 'fallback' },
      ['<CR>'] = { 'accept', 'fallback' },
    },
    signature = {
      enabled = true,
      trigger = { enabled = true },
      window = {
        show_documentation = true,
        border = 'rounded',
      },
    },
    snippets = {
      preset = 'luasnip',
    },
    sources = {
      default = { 'lazydev', 'lsp', 'path', 'snippets', 'buffer' },
      providers = {
        buffer = {
          name = 'Buffer',
          opts = {
            get_bufnrs = function()
              return vim.api.nvim_list_bufs()
            end,
          },
        },
        lazydev = {
          name = 'LazyDev',
          module = 'lazydev.integrations.blink',
          score_offset = 100,
        },
        lsp = {
          name = 'LSP',
        },
        path = {
          name = 'Path',
        },
        snippets = {
          name = 'Snippets',
        },
      },
    },
  },
  config = function(_, opts)
    require('blink.cmp').setup(opts)
  end,
}
