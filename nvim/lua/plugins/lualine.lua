-- StatusLine configuration for lualine
-- https://github.com/kuntau/dotfiles/blob/develop/config/nvim/lua/config/plugins/statusline.lua

local components = require('config.lualine.components')

local ft_extension = {
  sections = { lualine_a = { components.ft_upper } },
  filetypes = {
    'DiffviewFiles',
    'NvimTree',
    'Outline',
    'Trouble',
    'aerial',
    'startify',
    'startuptime',
    'undotree',
  },
}

local help_extension = {
  sections = {
    lualine_a = { components.ft_upper },
    lualine_c = { 'filename' },
    lualine_z = { 'progress' },
  },
  filetypes = { 'help', 'man' },
}

local neogit_extension = {
  sections = {
    lualine_a = { components.ft_upper },
    lualine_b = { 'branch' },
  },
  filetypes = {
    'gitcommit',
    'NeogitStatus',
    'NeogitCommitMessage',
    'NeogitPopup',
    'NeogitLogView',
    'NeogitGitCommandHistory',
  },
}

local opts = {
  options = {
    component_separators = { left = '', right = '' },
    disabled_filetypes = { 'startify' },
    always_divide_middle = false,
    globalstatus = true,
  },
  sections = {
    lualine_a = {
      {
        'tabs',
        mode = 0,
        cond = function() return vim.fn.tabpagenr('$') > 1 end,
        separator = { left = '', right = '' },
      },
      'mode',
    },
    lualine_b = {
      { 'b:gitsigns_head', icon = '' },
      { 'diff', source = components.diff_source },
      { 'diagnostics', symbols = { error = ' ', warn = ' ', hint = ' ', info = ' ' } },
    },
    lualine_c = {
      components.filename,
      { 'aerial' },
    },
    lualine_x = {
      components.macro_recording,
      components.search_result,
      components.spell_indicator,
      {
        'fileformat',
        separator = '',
      },
      {
        'filetype',
        colored = false,
        icon_only = true,
        separator = '',
      },
      {
        'encoding',
        fmt = string.upper,
      },
    },
    lualine_y = { 'location', 'progress' },
    lualine_z = {
      {
        require('lazy.status').updates,
        cond = require('lazy.status').has_updates,
      },
      components.active_lsp,
    },
  },
  inactive_sections = {
    lualine_c = { { 'filename', path = 1 } },
  },
  extensions = {
    'nvim-dap-ui',
    'quickfix',
    ft_extension,
    neogit_extension,
    help_extension,
  },
}

return {
  {
    'nvim-lualine/lualine.nvim',
    event = 'BufReadPost',
    opts = opts,
    config = function(_, opts) require('lualine').setup(opts) end,
  },
  { 'edkolev/tmuxline.vim', cmd = 'Tmuxline' },
}
