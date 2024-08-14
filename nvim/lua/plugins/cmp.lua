local border_config = {
  border = vim.g.border_style,
  winhighlight = 'FloatBorder:FloatBorder',
}

local source_menu_map = {
  buffer = 'buff',
  lazydev = 'lazy',
  luasnip = 'snip',
  nvim_lsp = 'lsp',
  nvim_lsp_signature_help = 'sig',
  path = 'path',
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

    -- Adds a number of user-friendly snippets
    'rafamadriz/friendly-snippets',
    'onsails/lspkind.nvim', -- add fancy icons
  },
  config = function()
    local cmp = require 'cmp'
    local luasnip = require 'luasnip'
    require('luasnip.loaders.from_vscode').lazy_load()
    luasnip.config.setup {}

    cmp.setup {
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      completion = {
        completeopt = 'menu,menuone,noinsert',
      },
      mapping = cmp.mapping.preset.insert {
        ['<C-n>'] = cmp.mapping.select_next_item(),
        ['<C-p>'] = cmp.mapping.select_prev_item(),
        ['<C-d>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping(
          cmp.mapping.complete({ config = { sources = { { name = 'nvim_lsp' } } } }),
          { 'i', 'c' }
        ),
        ['<CR>'] = cmp.mapping.confirm {
          behavior = cmp.ConfirmBehavior.Insert,
          select = true,
        },
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
      },
      sources = {
        { name = 'nvim_lsp' },
        { name = 'nvim_lsp_signature_help' },
        { name = 'luasnip' },
        { name = 'emmet' },
        { name = 'path' },
        {
          name = 'buffer',
          option = { get_bufnrs = vim.api.nvim_list_bufs },
        }
      },
      window = {
        completion = cmp.config.window.bordered(border_config),
        documentation = cmp.config.window.bordered(border_config),
      },
      formatting = {
        format = require('lspkind').cmp_format({
          before = function(entry, vim_item)
            local source = entry.source.name

            vim_item.menu = source_menu_map[source]
            if source == 'nvim_lsp' then
              pcall(function()
                local utils = require('lsp.utils')
                vim_item.menu = '[' .. utils.get_server_display_name(entry.source.source.client.name) .. ']'
              end)
            end

            vim_item.abbr = string.sub(vim_item.abbr, 1, 50)

            return vim_item
          end,
        }),
      },
    }

    cmp.setup.cmdline(':', {
      sources = {
        { name = 'path' },
        { name = 'cmdline' },
      },
    })

    cmp.setup.cmdline('/', {
      sources = {
        { name = 'buffer' }
      },
    })
  end
}
