-- Undotree visualizes the undo history

local config = function()
  vim.g.undotree_WindowLayout = 2
  vim.g.undotree_HelpLine = 0
  vim.g.undotree_ShortIndicators = 1
  vim.g.undotree_TreeNodeShape = '⧂'
  vim.g.undotree_TreeVertShape = '│'
  vim.g.undotree_TreeSplitShape = '╱'
  vim.g.undotree_TreeReturnShape = '╲'
  vim.g.undotree_SetFocusWhenToggle = 1
end

return {
  {
    'mbbill/undotree',
    cmd = 'UndotreeToggle',
    config = config,
  },
  {
    -- Keeps the undo history of a file changed outside Neovim (git switch, a formatter, Claude);
    -- otherwise the undofile no longer matches and Neovim drops it
    'kevinhwang91/nvim-fundo',
    event = 'BufReadPre',
    dependencies = { 'kevinhwang91/promise-async' },
    opts = {},
  },
}
