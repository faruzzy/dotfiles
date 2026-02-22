return {
  'chrishrb/gx.nvim',
  keys = { { 'gx', '<cmd>Browse<cr>', mode = { 'n', 'x' } } },
  cmd = { 'Browse' },
  init = function()
    vim.g.netrw_nogx = 1 -- disable netrw gx
  end,
  submodules = false,
  config = function()
    require('gx').setup({
      handlers = {
        plugin = true,
        github = true,
        brewfile = true,
        package_json = true,
        search = true,
      },
      handler_options = {
        search_engine = 'google',
      },
    })
  end,
}
