local colors = require('colors').get_colors()

local border_config = {
  border = vim.g.border_style,
  winhighlight = 'FloatBorder:FloatBorder',
}

local source_menu_map = {
  buffer = 'buff',
  lazydev = 'lazy',
  luasnip = 'snip',
  nvim_lsp = 'lsp',
  -- nvim_lsp_signature_help = 'sig',
  path = 'path',
}

local lspkind_icons = {
  Class = '󰠱',
  Color = '󰏘',
  Constant = '󰏿',
  Constructor = '',
  Enum = '',
  EnumMember = '',
  Event = '',
  Field = '󰜢',
  File = '󰈙',
  Folder = '󰉋',
  Function = '󰊕',
  Interface = '',
  Keyword = '󰌋',
  Method = '󰆧',
  Module = '',
  Operator = '',
  Property = '',
  Reference = '󰈇',
  Snippet = '',
  Struct = '󰙅',
  Text = '󰉿',
  TypeParameter = '',
  Unit = '',
  Value = '󰎠',
  Variable = '󰀫',
}

return {
  'hrsh7th/nvim-cmp',
  dependencies = {
    'saadparwaiz1/cmp_luasnip',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-cmdline',

    -- Adds LSP completion capabilities
    'hrsh7th/cmp-nvim-lsp',
    -- 'hrsh7th/cmp-nvim-lsp-signature-help',
    'hrsh7th/cmp-path',
    'folke/lazydev.nvim',

    -- Adds a number of user-friendly snippets
    'rafamadriz/friendly-snippets',
    -- 'onsails/lspkind.nvim', -- add fancy icons
  },
  config = function()
    local cmp = require('cmp')
    local luasnip = require('luasnip')
    require('luasnip.loaders.from_vscode').lazy_load()
    luasnip.config.setup({})

    cmp.setup({
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      completion = {
        completeopt = 'menu,menuone,noinsert',
      },
      mapping = cmp.mapping.preset.insert({
        ['<C-n>'] = cmp.mapping.select_next_item(),
        ['<C-p>'] = cmp.mapping.select_prev_item(),
        ['<C-d>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping(
          cmp.mapping.complete({ config = { sources = { { name = 'nvim_lsp' } } } }),
          { 'i', 'c' }
        ),
        ['<CR>'] = cmp.mapping.confirm({
          behavior = cmp.ConfirmBehavior.Insert,
          select = true,
        }),
        ['<Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_locally_jumpable() then
            luasnip.expand_or_jump()
          else
            fallback()
          end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.locally_jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { 'i', 's' }),
      }),
      sources = {
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        { name = 'path' },
        -- { name = 'nvim_lsp_signature_help' },
        { name = 'emmet' },
        {
          name = 'buffer',
          option = { get_bufnrs = vim.api.nvim_list_bufs },
        },
        { name = 'lazydev', group_index = 0 },
      },
      window = {
        completion = cmp.config.window.bordered(border_config),
        documentation = cmp.config.window.bordered(border_config),
      },
      formatting = {
        expandable_indicator = true,
        fields = { 'kind', 'abbr', 'menu' },
        format = function(entry, vim_item)
          local source = entry.source.name
          -- local client_name = source == 'nvim_lsp'
          --     and require('lsp.utils').get_server_display_name(entry.source.source.client.name)
          --   or nil

          -- vim_item.menu = vim_item.menu and vim_item.menu or client_name or source_menu_map[source]
          vim_item.menu = vim_item.menu and vim_item.menu or source_menu_map[source]
          if vim_item.menu then
            vim_item.menu = ' ' .. vim_item.menu
          end

          local color_item = require('nvim-highlight-colors').format(entry, { kind = vim_item.kind })
          if color_item.abbr_hl_group then
            vim_item.kind_hl_group = color_item.abbr_hl_group
            vim_item.kind = color_item.abbr
          else
            vim_item.kind = lspkind_icons[vim_item.kind] or ''
          end
          vim_item.kind = vim_item.kind .. ' '

          local color = colors[vim_item.abbr]
          -- if client_name == 'lua_ls' and color then
          --   vim_item.abbr = vim_item.abbr .. ' ' .. color
          -- end
          vim_item.abbr = vim_item.abbr:sub(1, 50)

          return vim_item
        end,
      },
    })

    cmp.setup.cmdline(':', {
      sources = {
        { name = 'path' },
        { name = 'cmdline' },
      },
    })

    cmp.setup.cmdline('/', {
      sources = {
        { name = 'buffer' },
      },
    })
  end,
}
