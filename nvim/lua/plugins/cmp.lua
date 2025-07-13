--[[
  nvim-cmp configuration for Neovim autocompletion.
  - Integrates with LSP, luasnip, buffer, path, and lazydev sources.
  - Customizes completion UI with Catppuccin-themed borders and icons.
  - Provides keybindings for completion and snippet navigation.
  - Depends on: nvim-cmp, cmp_luasnip, cmp-nvim-lsp, nvim-highlight-colors
]]

local border_config = {
  border = { '╭', '─', '╮', '│', '╯', '─', '╰', '│' },
  winhighlight = 'NormalFloat:NormalFloat,FloatBorder:FloatBorder',
}

local source_menu_map = {
  buffer = 'buff',
  lazydev = 'lazy',
  luasnip = 'snip',
  nvim_lsp = 'lsp',
  nvim_lsp_signature_help = 'sig',
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
    'hrsh7th/cmp-nvim-lsp-signature-help',
    'hrsh7th/cmp-path',
    'folke/lazydev.nvim',

    -- Adds a number of user-friendly snippets
    'rafamadriz/friendly-snippets',
    -- 'onsails/lspkind.nvim', -- add fancy icons
  },
  config = function()
    local cmp = require('cmp')
    local ok, luasnip = pcall(require, 'luasnip')
    if not ok then
      vim.notify('nvim-cmp: luasnip not found, snippet expansion disabled', vim.log.levels.WARN)
    else
      require('luasnip.loaders.from_vscode').lazy_load()
      luasnip.config.setup({})
    end

    cmp.setup({
      snippet = {
        expand = function(args)
          if luasnip then
            luasnip.lsp_expand(args.body)
          end
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
        ['<C-e>'] = cmp.mapping.abort(),
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
        ['<S-Tab>'] = cmp.mapping(function()
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.locally_jumpable(-1) then
            luasnip.jump(-1)
          else
            vim.g.fallback()
          end
        end, { 'i', 's' }),
      }),
      sources = {
        { name = 'nvim_lsp', priority = 1000, keyword_length = 2 },
        { name = 'nvim_lsp_signature_help', priority = 900, keyword_length = 2 },
        { name = 'luasnip', priority = 800, keyword_length = 2 },
        { name = 'emmet', priority = 700, keyword_length = 2 },
        { name = 'path', priority = 600 },
        { name = 'buffer', priority = 500, keyword_length = 3, option = { get_bufnrs = vim.api.nvim_list_bufs } },
        { name = 'lazydev', priority = 900, group_index = 0 },
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
          vim_item.menu = source_menu_map[source] or source
          vim_item.menu = vim_item.menu and (' ' .. vim_item.menu) or ''

          local color_item = {}
          local okay, highlight_colors = pcall(require, 'nvim-highlight-colors')
          if okay then
            vim.color_item = highlight_colors.format(entry, { kind = vim_item.kind })
          end
          -- local color_item = require('nvim-highlight-colors').format(entry, { kind = vim_item.kind })
          if color_item.abbr_hl_group then
            vim_item.kind_hl_group = color_item.abbr_hl_group
            vim_item.kind = color_item.abbr
          else
            vim_item.kind = lspkind_icons[vim_item.kind] or ''
          end
          vim_item.kind = vim_item.kind .. ' '

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
