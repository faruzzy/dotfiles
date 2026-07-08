local lspkind_icons = {
  Array = '󰅪 ',
  Boolean = '◩ ',
  Class = '󰠱 ',
  Color = '󰏘 ',
  Constant = '󰏿 ',
  Constructor = '',
  Enum = '',
  EnumMember = '',
  Event = '',
  Field = '󰜢 ',
  File = '󰈙 ',
  Folder = '󰉋 ',
  Function = '󰊕 ',
  Interface = '',
  Key = '󰌋 ',
  Keyword = '󰌋 ',
  Method = '󰆧 ',
  Module = '',
  Namespace = '󰌗 ',
  Null = '󰟢 ',
  Number = '󰎠 ',
  Object = '󰅩 ',
  Operator = '',
  Package = '󰏗 ',
  Property = '',
  Reference = '󰈇 ',
  Snippet = ' ',
  String = '󰉿 ',
  Struct = '󰙅 ',
  Text = '󰉿 ',
  TypeParameter = '',
  Unit = '',
  Value = '󰎠 ',
  Variable = '󰀫 ',
}

-- Enhanced LSP completion context function
local function get_lsp_completion_context(completion)
  local ok, source_name = pcall(function() return vim.lsp.get_client_by_id(completion.client_id).name end)
  if not ok then
    return nil
  end

  if source_name == 'ts_ls' or source_name == 'typescript-tools' or source_name == 'tsgo' then
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

local lsp_completion_labels_by_context = {}
local lsp_completion_context_id = nil

local function normalize_completion_label(label)
  label = tostring(label or '')
  return label:gsub('^#', ''):lower()
end

local function current_private_member_prefix()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local before_cursor = vim.api.nvim_get_current_line():sub(1, col)
  local prefix = before_cursor:match('#([%w_$]*)$')
  return prefix and prefix:lower() or nil
end

local function current_member_prefix()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local before_cursor = vim.api.nvim_get_current_line():sub(1, col)
  local prefix = before_cursor:match('[%.:]([%w_$]*)$') or before_cursor:match('%?%.([%w_$]*)$')

  if prefix then
    return prefix:lower()
  end

  return current_private_member_prefix()
end

local function current_object_property_position()
  if not vim.tbl_contains({
    'javascript',
    'javascriptreact',
    'typescript',
    'typescriptreact',
  }, vim.bo.filetype) then
    return false
  end

  local ok, tsgo_util = pcall(require, 'tsgo.util')
  if ok and tsgo_util.is_object_property_completion() then
    return true
  end

  local col = vim.api.nvim_win_get_cursor(0)[2]
  local before_cursor = vim.api.nvim_get_current_line():sub(1, col)
  if before_cursor:match('[:%.]%s*[%w_$]*$') then
    return false
  end

  if not before_cursor:match('^%s*[%w_$]*$') and not before_cursor:match('[{,]%s*[%w_$]*$') then
    return false
  end

  local success, node = pcall(vim.treesitter.get_node)
  if not success or not node then
    return false
  end

  local current = node
  while current do
    local ntype = current:type()
    if ntype == 'object' or ntype == 'object_pattern' then
      return true
    end
    current = current:parent()
  end

  return false
end

local function remember_lsp_completion_labels(ctx, items)
  if lsp_completion_context_id ~= ctx.id then
    lsp_completion_labels_by_context = {}
    lsp_completion_context_id = ctx.id
  end

  local labels = {}
  for _, item in ipairs(items) do
    labels[normalize_completion_label(item.label)] = true
    labels[normalize_completion_label(item.filterText)] = true
    labels[normalize_completion_label(item.insertText)] = true

    if item.textEdit and item.textEdit.newText then
      labels[normalize_completion_label(item.textEdit.newText)] = true
    end
  end

  lsp_completion_labels_by_context[ctx.id] = labels
end

local function filter_buffer_duplicates(ctx, items)
  local lsp_labels = lsp_completion_labels_by_context[ctx.id]
  local private_prefix = current_private_member_prefix()
  if not lsp_labels and not private_prefix then
    return items
  end

  return vim.tbl_filter(function(item)
    local label = normalize_completion_label(item.label)
    if lsp_labels and lsp_labels[label] then
      return false
    end

    if private_prefix and private_prefix ~= '' and label:sub(1, #private_prefix) == private_prefix then
      return false
    end

    return true
  end, items)
end

local function prefer_lsp_member_match(a, b)
  if a.source_id == b.source_id then
    return nil
  end

  local lsp_item = a.source_id == 'lsp' and a or b.source_id == 'lsp' and b or nil
  local buffer_item = a.source_id == 'buffer' and a or b.source_id == 'buffer' and b or nil
  if not lsp_item or not buffer_item then
    return nil
  end

  local prefix = current_member_prefix()
  if not prefix or prefix == '' then
    return nil
  end

  local lsp_label = normalize_completion_label(lsp_item.label)
  if lsp_label:sub(1, #prefix) ~= prefix then
    return nil
  end

  return a.source_id == 'lsp'
end

local function prioritize_score_for_words(sorts)
  if current_member_prefix() ~= nil or current_object_property_position() then
    return sorts
  end

  local reordered = { 'exact', 'score' }
  for _, sort in ipairs(sorts or {}) do
    if sort ~= 'exact' and sort ~= 'score' then
      table.insert(reordered, sort)
    end
  end
  return reordered
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
        preset = 'inherit',
        ['<Tab>'] = { 'select_and_accept' },
        ['<CR>'] = { 'fallback' },
      },
    },
    completion = {
      accept = {
        auto_brackets = {
          semantic_token_resolution = {
            blocked_filetypes = { 'typescriptreact', 'typescript' },
          },
        },
      },
      trigger = {
        show_on_keyword = true,
        show_on_trigger_character = true,
        show_on_accept_on_trigger_character = true,
        show_on_insert_on_trigger_character = true,
        show_in_snippet = true,
        show_on_blocked_trigger_characters = { ' ', '\n', '\t', '{', '<' },
        show_on_x_blocked_trigger_characters = { '\'', '{' },
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
        auto_show = function(ctx)
          -- Don't auto-show completion right after ( or { with no keyword typed
          local col = ctx.cursor[2]
          if col > 0 then
            local line = vim.api.nvim_get_current_line()
            local char_before = line:sub(col, col)
            if char_before == '(' or char_before == '{' or char_before == '>' then
              return false
            end
          end
          return true
        end,
        border = 'rounded',
        min_width = 34,
        max_height = 10,
        draw = {
          treesitter = { 'lsp' },
          align_to = 'cursor',
          padding = 1,
          gap = 3,
          columns = {
            { 'kind_icon', gap = 1 },
            { 'label', 'label_description', gap = 1 },
            { 'source_name' },
          },
          components = {
            kind_icon = {
              ellipsis = false,
              text = function(ctx) return ctx.kind_icon end,
              highlight = function(ctx) return 'BlinkCmpKind' .. ctx.kind end,
            },
            label = {
              width = {
                fill = true,
                max = 60,
              },
              text = function(ctx) return ctx.label .. (ctx.label_detail or '') end,
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
              text = function(ctx) return get_lsp_completion_context(ctx.item) end,
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
                local name = source_map[ctx.source_name] or ctx.source_name
                if ctx.item.client_name then
                  name = name .. '[' .. ctx.item.client_name .. ']'
                end
                return name
              end,
            },
          },
        },
      },
    },
    fuzzy = {
      implementation = 'rust',
      frecency = { enabled = true },
      use_proximity = true,
      sorts = {
        'exact',
        'sort_text',
        'label',
        'score',
        'kind',
      },
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
        function(cmp) cmp.show() end,
      },
      ['<C-e>'] = {
        function(cmp)
          if cmp.is_visible() then
            return cmp.cancel()
          elseif require('luasnip').session.current_nodes[vim.api.nvim_get_current_buf()] then
            require('luasnip').unlink_current()
            return true
          end
        end,
        'fallback',
      },
      ['<CR>'] = { 'select_and_accept', 'fallback' },
      -- Disable arrow keys to encourage better habits
      ['<Up>'] = { 'fallback' },
      ['<Down>'] = { 'fallback' },
    },
    signature = {
      enabled = true,
      trigger = {
        enabled = true,
        show_on_trigger_character = true,
        show_on_insert_on_trigger_character = true,
        show_on_accept_on_trigger_character = true,
      },
      window = {
        border = 'rounded',
        max_width = 90,
        max_height = 14,
        show_documentation = true,
      },
    },
    snippets = {
      preset = 'luasnip',
    },
    sources = {
      -- Context-aware source selection
      default = function()
        local col = vim.api.nvim_win_get_cursor(0)[2]
        if col > 0 then
          local line = vim.api.nvim_get_current_line()
          if line:sub(col, col) == '.' then
            return { 'lsp' }
          end
        end

        local success, node = pcall(vim.treesitter.get_node)
        if success and node and vim.tbl_contains({ 'comment', 'line_comment', 'block_comment' }, node:type()) then
          return { 'buffer' } -- Only buffer completions in comments
        end

        return { 'lsp', 'path', 'snippets', 'buffer' }
      end,
      per_filetype = {
        lua = { inherit_defaults = true, 'lazydev' },
      },
      providers = {
        buffer = {
          name = 'Buffer',
          max_items = 10,
          score_offset = 0,
          transform_items = filter_buffer_duplicates,
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
          -- Keep buffer completions active alongside LSP instead of only using
          -- them when LSP returns no items.
          fallbacks = {},
          score_offset = 0,
          transform_items = function(ctx, items)
            -- Filter out emmet completions when cursor is not in a JSX/HTML markup context.
            -- Strategy: walk up the tree and find the *nearest* JSX-related ancestor.
            -- If it's jsx_expression we're in JS code — suppress emmet.
            -- If it's any other jsx_* node we're in markup — allow emmet.
            -- If no JSX ancestor is found, check the filetype as a fallback.
            local in_markup = false
            local success, node = pcall(vim.treesitter.get_node)
            if success and node then
              local current = node ---@type TSNode?
              while current do
                local ntype = current:type()
                if ntype == 'jsx_expression' then
                  in_markup = false
                  break
                elseif ntype:match('^jsx_') or ntype == 'html' then
                  in_markup = true
                  break
                end
                current = current:parent()
              end
              -- If no jsx ancestor found, allow emmet for HTML files
              if current == nil then
                in_markup = vim.bo.filetype == 'html'
              end
            end

            local seen = {}
            local filtered = vim.tbl_filter(function(item)
              -- Drop emmet items outside JSX markup
              if not in_markup and item.client_name == 'emmet_language_server' then
                return false
              end

              local key = item.label .. (item.kind or '')
              if seen[key] then
                return false
              end

              if current_member_prefix() == nil and tostring(item.label or ''):sub(1, 1) == '#' then
                item.score_offset = (item.score_offset or 0) - 8
              end

              seen[key] = true
              return true
            end, items)

            remember_lsp_completion_labels(ctx, filtered)
            return filtered
          end,
        },
        path = {
          name = 'Path',
          fallbacks = {},
          opts = {
            get_cwd = function(_) return vim.fn.getcwd() end,
          },
        },
        snippets = {
          name = 'Snippets',
          min_keyword_length = 2,
          score_offset = 0,
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
    local ok, tsgo = pcall(require, 'tsgo')
    if ok then
      opts = vim.tbl_deep_extend('force', opts, tsgo.compat.blink({
        default_sources = opts.sources.default,
        lsp_transform_items = opts.sources.providers.lsp.transform_items,
      }))
    end

    local tsgo_sorts = opts.fuzzy.sorts
    opts.fuzzy.sorts = function()
      local sorts = type(tsgo_sorts) == 'function' and tsgo_sorts() or tsgo_sorts
      local combined = { prefer_lsp_member_match }
      vim.list_extend(combined, prioritize_score_for_words(sorts))
      return combined
    end

    local blink = require('blink.cmp')
    blink.setup(opts)
    blink.add_filetype_source('gitcommit', 'buffer')
    blink.add_filetype_source('markdown', 'buffer')
  end,
}
