return {
  'stevearc/aerial.nvim',
  dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' },
  event = 'LspAttach',
  opts = {
    backends = { 'lsp', 'treesitter', 'markdown', 'man' },
    layout = {
      min_width = 30,
      default_direction = 'right',
    },
    filter_kind = false,
    show_guides = true,
  },
  keys = {
    { '<leader>ao', '<cmd>AerialToggle<CR>', desc = 'Aerial: Toggle outline' },
    { '<leader>an', '<cmd>AerialNavToggle<CR>', desc = 'Aerial: Toggle nav' },
    { '{', '<cmd>AerialPrev<CR>', desc = 'Aerial: Previous symbol' },
    { '}', '<cmd>AerialNext<CR>', desc = 'Aerial: Next symbol' },
  },
}
