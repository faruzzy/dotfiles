-- StatusLine configuration for lualine: floating pills on the editor background
-- (style from https://github.com/WilliamHsieh/dotfiles). The file path is in the incline label.

local function opts()
  -- Required here, not at the top: lazy evaluates spec files before Catppuccin is set up,
  -- and the components read its palette
  local components = require('config.lualine.components')

  local ft_extension = {
    sections = { lualine_a = { components.ft_upper } },
    filetypes = {
      'DiffviewFiles',
      'neo-tree',
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
      lualine_b = { components.branch },
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

  return {
    options = {
      theme = components.theme,
      -- Pills draw their own rounded ends; nothing between sections
      section_separators = '',
      component_separators = '',
      disabled_filetypes = { 'startify' },
      always_divide_middle = false,
      globalstatus = true,
    },
    sections = {
      lualine_a = { components.mode, components.filetype },
      lualine_b = {
        components.branch,
        { 'diff', source = components.diff_source },
        { 'diagnostics', symbols = { error = '\u{f057} ', warn = '\u{f071} ', hint = '\u{f0eb} ', info = '\u{f05a} ' } },
      },
      lualine_c = {},
      lualine_x = {
        components.tmux_zoomed,
        components.macro_recording,
        components.search_result,
        components.spell_indicator,
        {
          'tabs',
          mode = 0,
          cond = function() return vim.fn.tabpagenr('$') > 1 end,
          tabs_color = {
            active = { fg = components.palette.base, bg = components.palette.lavender },
            inactive = { fg = components.palette.overlay1, bg = components.palette.surface0 },
          },
        },
        {
          require('lazy.status').updates,
          cond = require('lazy.status').has_updates,
          color = { fg = components.palette.peach },
        },
        components.lsp,
      },
      lualine_y = {},
      lualine_z = { components.cwd, components.host },
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
end

return {
  {
    'nvim-lualine/lualine.nvim',
    event = 'BufReadPost',
    opts = opts,
    config = function(_, o) require('lualine').setup(o) end,
  },
  { 'edkolev/tmuxline.vim', cmd = 'Tmuxline' },
}
