-- Re-enable vim syntax alongside treesitter so the built-in
-- GetTypescriptIndent() works (it relies on synID() for string/comment detection)
if vim.b.ts_highlight then
  vim.bo.syntax = 'typescriptreact'
end
