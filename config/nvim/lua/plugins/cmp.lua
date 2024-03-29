local M = {
  'hrsh7th/nvim-cmp',
  dependencies = {
    'hrsh7th/cmp-nvim-lsp',
    'saadparwaiz1/cmp_luasnip',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-cmdline',
    'hrsh7th/cmp-path',
  },
}

function M.config()
  local cmp = require 'cmp'
  local luasnip = require 'luasnip'

  -- Didn't really feel like installing another plug for icons
  local kind_icons = {
    Text = "",
    Method = "",
    Function = "",
    Constructor = "",
    Field = "",
    Variable = "",
    Class = "ﴯ",
    Interface = "",
    Module = "",
    Property = "ﰠ",
    Unit = "",
    Value = "",
    Enum = "",
    Keyword = "",
    Snippet = "",
    Color = "",
    File = "",
    Reference = "",
    Folder = "",
    EnumMember = "",
    Constant = "",
    Struct = "",
    Event = "",
    Operator = "",
    TypeParameter = ""
  }

  local has_words_before = function()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))

    return col ~= 0 and vim.api.nvim_buf_get_lines(
      0,
      line - 1,
      line,
      true
    )[1]:sub(col, col):match("%s") == nil
  end

  local select_next_item = cmp.mapping(function(fallback)
    if cmp.visible() then cmp.select_next_item()
    elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
    elseif has_words_before() then cmp.complete()
    else fallback()
    end
  end, { "i", "s"})

  luasnip.config.setup {}

  cmp.setup {
    snippet = {
      expand = function(args)
	luasnip.lsp_expand(args.body)
      end,
    },
    mapping = cmp.mapping.preset.insert {
      ['<C-d>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete {},
      ['<C-e>'] = cmp.mapping.close(),
      ['<CR>'] = cmp.mapping.confirm {
	-- behavior = cmp.ConfirmBehavior.Replace,
	select = true,
      },
      ['<C-j>'] = select_next_item,
      ['<Tab>'] = cmp.mapping(function(fallback)
	if cmp.visible() then
	  cmp.select_next_item()
	elseif luasnip.expand_or_jumpable() then
	  luasnip.expand_or_jump()
	else
	  fallback()
	end
      end, { 'i', 's' }),
      ['<S-Tab>'] = cmp.mapping(function(fallback)
	if cmp.visible() then
	  cmp.select_prev_item()
	elseif luasnip.jumpable(-1) then
	  luasnip.jump(-1)
	else
	  fallback()
	end
      end, { 'i', 's' }),
    },
    -- Order dictates priority
    sources = {
      { name = 'luasnip' },
      { name = 'nvim_lsp' },
      { name = 'emmet' },
      { name = 'path' },
      {
	name = 'buffer',
	option = { get_bufnrs = vim.api.nvim_list_bufs },
      }
    },
    formatting = {
      format = function(entry, vim_item)
	vim_item.kind = string.format(
	  '%s %s',
	  kind_icons[vim_item.kind], vim_item.kind
	)

	vim_item.menu = ({
	  luasnip = '[Snippet]',
	  nvim_lsp = '[LSP]',
	  buffer = '[Buffer]',
	  path = '[Path]',
	})[entry.source.name]

	return vim_item
      end
    }
  }

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
end

return M

