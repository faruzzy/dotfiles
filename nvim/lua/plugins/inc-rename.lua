-- LSP rename with a live preview of every occurrence while typing the new name
-- (<Leader>rn in lsp/on_attach.lua; noice's inc_rename preset styles the prompt)
return {
  'smjonas/inc-rename.nvim',
  cmd = 'IncRename',
  opts = {},
}
