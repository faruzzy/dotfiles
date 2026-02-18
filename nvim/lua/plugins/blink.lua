--[[
  Enhanced blink.cmp configuration for Neovim autocompletion.
  - Replaces nvim-cmp with a faster Rust-based completion engine.
  - Integrates with LSP, snippets, buffer, path, and lazydev sources.
  - Provides customized keybindings and UI styling.
  - Context-aware source selection and enhanced LSP details.
]]

-- Define your LSP kind icons (extracted from your original config)
local lspkind_icons = {
  Array = '󰅪 ',
  Boolean = '◩ ',
  Class = '󰠱 ',
  Color = '󰏘 ',
  Constant = '󰏿 ',
  Constructor = ' ',
  Enum = ' ',
  EnumMember = ' ',
  Event = ' ',
  Field = '󰜢 ',
  File = '󰈙 ',
  Folder = '󰉋 ',
  Function = '󰊕 ',
  Interface = ' ',
  Key = '󰌋 ',
  Keyword = '󰌋 ',
  Method = '󰆧 ',
  Module = ' ',
  Namespace = '󰌗 ',
  Null = '󰟢 ',
  Number = '󰎠 ',
  Object = '󰅩 ',
  Operator = ' ',
  Package = '󰏗 ',
  Property = ' ',
  Reference = '󰈇 ',
  Snippet = ' ',
  String = '󰉿 ',
  Struct = '󰙅 ',
  Text = '󰉿 ',
  TypeParameter = ' ',
  Unit = ' ',
  Value = '󰎠 ',
  Variable = '󰀫 ',
}

-- Enhanced LSP completion context function
local function get_lsp_completion_context(completion)
  local ok, source_name = pcall(function()
    return vim.lsp.get_client_by_id(completion.client_id).name
  end)
  if not ok then
    return nil
  end

  if source_name == 'ts_ls' or source_name == 'typescript-tools' then
    return completion.detail
  elseif source_name == 'pyright' and completion.labelDetails ~= nil then
    return completion.labelDetails.description
  elseif source_name == 'texlab' then
    return completion.detail
  elseif source_name == 'clangd' then
    local doc = completion.documentation
    if doc == nil then
      return
    end

    local import_str = doc.value
    import_str = import_str:gsub('[\n]+', '')

    local str
    str = import_str:match('<(.-)>')
    if str then
      return '<' .. str .. '>'
    end

    str = import_str:match('["\'](.-)["\']')
    if str then
      return '"' .. str .. '"'
    end

    return nil
  end
end

return {
  'saghen/blink.cmp',
  version = '1.*',
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
      nerd_font_variant = 'mono',
    },
    cmdline = {
      completion = {
        menu = { auto_show = true },
      },
      keymap = {
        ['<Tab>'] = { 'select_and_accept' },
        ['<C-p>'] = { 'select_prev', 'fallback' },
        ['<C-n>'] = { 'select_next', 'fallback' },
      },
    },
    completion = {
      accept = {
        auto_brackets = { enabled = false },
      },
      ghost_text = {
        enabled = true,
      },
      trigger = {
        show_in_snippet = true,
      },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 200,
        treesitter_highlighting = true,
        window = {
          border = 'rounded',
          min_width = 40,
          max_width = 70,
          max_height = 20,
        },
      },
      keyword = { range = 'full' },
      list = {
        selection = { preselect = true, auto_insert = false },
      },
      menu = {
        border = 'rounded',
        min_width = 34,
        max_height = 10,
        draw = {
          treesitter = { 'lsp' },
          align_to = 'cursor',
          padding = 1,
          gap = 3,
          columns = {
            { 'kind_icon',  gap = 1 },
            { 'label',      'label_description', gap = 1 },
            { 'source_name' },
          },
          components = {
            kind_icon = {
              ellipsis = false,
              text = function(ctx)
                return ctx.kind_icon
              end,
              highlight = function(ctx)
                return 'BlinkCmpKind' .. ctx.kind
              end,
            },
            label = {
              width = {
                fill = true,
                max = 60,
              },
              text = function(ctx)
                return ctx.label .. (ctx.label_detail or '')
              end,
              highlight = function(ctx)
                local highlights = {
                  {
                    0,
                    #ctx.label,
                    group = ctx.deprecated and 'BlinkCmpLabelDeprecated' or 'BlinkCmpLabel',
                  },
                }
                if ctx.label_detail then
                  table.insert(highlights, {
                    #ctx.label,
                    #ctx.label + #ctx.label_detail,
                    group = 'BlinkCmpLabelDetail',
                  })
                end

                for _, idx in ipairs(ctx.label_matched_indices or {}) do
                  table.insert(highlights, { idx, idx + 1, group = 'BlinkCmpLabelMatch' })
                end

                return highlights
              end,
            },
            label_description = {
              text = function(ctx)
                return get_lsp_completion_context(ctx.item)
              end,
              highlight = 'BlinkCmpLabelDescription',
            },
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
      frecency = { enabled = true },
      use_proximity = true,
      sorts = { 'score', 'kind', 'sort_text' },
    },
    keymap = {
      preset = 'default',
      -- Enhanced Tab behavior with snippet awareness
      ['<Tab>'] = {
        function(cmp)
          if cmp.snippet_active() then
            return cmp.snippet_forward()
          elseif cmp.is_visible() then
            return cmp.select_next()
          else
            return cmp.snippet_forward() or false
          end
        end,
        'fallback',
      },
      ['<S-Tab>'] = {
        function(cmp)
          if cmp.snippet_active() then
            return cmp.snippet_backward()
          elseif cmp.is_visible() then
            return cmp.select_prev()
          else
            return cmp.snippet_backward() or false
          end
        end,
        'fallback',
      },
      -- Navigation
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
      -- Disable arrow keys to encourage better habits
      ['<Up>'] = { 'fallback' },
      ['<Down>'] = { 'fallback' },
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
      -- Context-aware source selection
      default = function()
        local success, node = pcall(vim.treesitter.get_node)
        if success and node and vim.tbl_contains({ 'comment', 'line_comment', 'block_comment' }, node:type()) then
          return { 'buffer' } -- Only buffer completions in comments
        end

        return { 'lazydev', 'lsp', 'path', 'snippets', 'buffer' }
      end,
      providers = {
        buffer = {
          name = 'Buffer',
          max_items = 4,
          score_offset = -2,
          min_keyword_length = 3,
          opts = {
            get_bufnrs = function()
              -- Only search visible buffers instead of all buffers
              local bufs = {}
              for _, win in ipairs(vim.api.nvim_list_wins()) do
                bufs[vim.api.nvim_win_get_buf(win)] = true
              end
              return vim.tbl_keys(bufs)
            end,
          },
        },
        lazydev = {
          name = 'LazyDev',
          module = 'lazydev.integrations.blink',
          score_offset = 100,
          fallbacks = { 'LSP' },
        },
        lsp = {
          name = 'LSP',
          score_offset = 0,
        },
        path = {
          name = 'Path',
          opts = {
            get_cwd = function(_)
              return vim.fn.getcwd()
            end,
          },
        },
        snippets = {
          name = 'Snippets',
          min_keyword_length = 2,
          score_offset = -1,
          should_show_items = function(ctx)
            -- Don't show snippets when completing object properties
            local line = vim.api.nvim_get_current_line()
            local col = vim.api.nvim_win_get_cursor(0)[2]
            if line:sub(col, col):match('[.:]') then
              return false
            end
            return ctx.trigger.initial_kind ~= 'trigger_character'
          end,
        },
      },
    },
  },
  config = function(_, opts)
    local blink = require('blink.cmp')
    blink.setup(opts)
    blink.add_filetype_source('gitcommit', 'buffer')
    blink.add_filetype_source('markdown', 'buffer')
  end,
}
