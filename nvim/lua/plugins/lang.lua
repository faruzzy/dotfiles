return {
  {
    'Sebastian-Nielsen/better-type-hover',
    ft = { 'typescript', 'typescriptreact' },
    config = function()
      require('better-type-hover').setup({
        openTypeDocKeymap = 'K',
      })
    end,
    desc = 'Improved TypeScript hover documentation'
  },
  ---@type LazySpec
  {
    'dmmulroy/tsc.nvim',
    cmd = 'TSC',
    ---@module 'tsc'
    ---@type Opts
    opts = {
      pretty_errors = false,
    },
  },

  {
    'pantharshit00/vim-prisma',
    ft = 'prisma',
    desc = 'Prisma file detection and syntax highlighting'
  },

  {
    'jparise/vim-graphql',
    ft = { 'graphql', 'javascript', 'typescript' },
    desc = 'GraphQL syntax highlighting and indentation'
  },

  {
    'udalov/javap-vim',
    ft = 'java',
    cmd = 'Javap',
    desc = 'Java bytecode decompiler'
  },

  {
    'fei6409/log-highlight.nvim',
    ft = { 'log', 'txt' },
    opts = {},
    desc = 'Syntax highlighting for log files'
  },
}
