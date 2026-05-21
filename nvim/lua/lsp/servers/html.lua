return {
  cmd = { 'vscode-html-language-server', '--stdio' },
  filetypes = { 'html', 'templ' },
  root_markers = { 'package.json', '.git' },
  on_attach = function(client, bufnr)
    require('lsp.utils').setup_auto_close_tag(client, bufnr, 'html/autoInsert')
  end,
}
