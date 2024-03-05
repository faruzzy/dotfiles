-- undotree configs

local config = function()
  vim.g.undotree_WindowLayout = 2
  vim.g.undotree_HelpLine = 0
  vim.g.undotree_ShortIndicators = 1
  vim.g.undotree_TreeNodeShape = '⧂'
  vim.g.undotree_TreeVertShape = '│'
  vim.g.undotree_TreeSplitShape = '╱'
  vim.g.undotree_TreeReturnShape = '╲'
  vim.g.undotree_SetFocusWhenToggle = 1

  vim.keymap.set('n', '<leader>ut', vim.cmd.UndotreeToggle)
end

return {
  'mbbill/undotree',
  cmd = 'UndotreeToggle',
  config = config,
}
