-- Annotation generator for multiple languages (JSDoc, TSDoc, etc.)
return {
  'danymat/neogen',
  dependencies = 'nvim-treesitter/nvim-treesitter',
  opts = {
    enabled = true,
    snippet_engine = 'luasnip',
    languages = {
      javascript = {
        template = {
          annotation_convention = 'jsdoc',
        },
      },
      typescript = {
        template = {
          annotation_convention = 'tsdoc',
        },
      },
      javascriptreact = {
        template = {
          annotation_convention = 'jsdoc',
        },
      },
      typescriptreact = {
        template = {
          annotation_convention = 'tsdoc',
        },
      },
    },
  },
  keys = {
    {
      '<leader>nf',
      function()
        require('neogen').generate()
      end,
      desc = 'Generate annotation',
    },
    {
      '<leader>nc',
      function()
        require('neogen').generate({ type = 'class' })
      end,
      desc = 'Generate class annotation',
    },
    {
      '<leader>nt',
      function()
        require('neogen').generate({ type = 'type' })
      end,
      desc = 'Generate type annotation',
    },
  },
}
