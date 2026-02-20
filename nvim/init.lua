-- Prepend NVM node to PATH so Neovim uses it instead of Homebrew's node
do
  local nvm_dir = vim.env.NVM_DIR or vim.fn.expand('~/.nvm')
  local node_dir = nvm_dir .. '/versions/node'
  if vim.uv.fs_stat(node_dir) then
    local version_hint
    -- Check for project-level .nvmrc or .node-version first
    for _, f in ipairs({ '.nvmrc', '.node-version' }) do
      if vim.uv.fs_stat(f) then
        version_hint = vim.trim(vim.fn.readfile(f)[1] or '')
        break
      end
    end
    -- Fall back to NVM default alias
    if not version_hint then
      local default_file = nvm_dir .. '/alias/default'
      if vim.uv.fs_stat(default_file) then
        version_hint = vim.trim(vim.fn.readfile(default_file)[1] or '')
      end
    end
    -- Try matching the hint as a version number
    local node_path
    if version_hint and version_hint:match('^%d') then
      local matches = vim.fn.glob(node_dir .. '/v' .. version_hint .. '*', false, true)
      if #matches > 0 then
        table.sort(matches)
        node_path = matches[#matches] .. '/bin'
      end
    end
    -- Fallback: use the latest installed version
    if not node_path then
      local all = vim.fn.glob(node_dir .. '/v*', false, true)
      if #all > 0 then
        table.sort(all)
        node_path = all[#all] .. '/bin'
      end
    end
    if node_path then
      vim.env.PATH = node_path .. ':' .. vim.env.PATH
    end
  end
end

require('config_variables')
require('faruzzy.settings')
require('faruzzy.remap')
require('faruzzy.autocmd')

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup('plugins', {
  change_detection = { notify = false },
  checker = { enabled = true, notify = false },
  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      task = '📌',
      start = '🚀',
      lazy = '💤 ',
    },
  },
})

-- -- Remap for dealing with word wrap
-- vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
-- vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
