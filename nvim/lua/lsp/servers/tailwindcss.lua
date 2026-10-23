return {
  cmd = { 'tailwindcss-language-server', '--stdio' },
  filetypes = {
    'html',
    'css',
    'scss',
    'javascript',
    'javascriptreact',
    'typescript',
    'typescriptreact',
    'vue',
    'svelte',
  },
  -- Tailwind v4 has no config file, so fall back to the project root
  root_markers = {
    { 'tailwind.config.js', 'tailwind.config.cjs', 'tailwind.config.mjs', 'tailwind.config.ts' },
    { 'package.json', '.git' },
  },
}
