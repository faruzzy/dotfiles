-- Buffer tab line with diagnostics, grouping, and slant separators
return {
  'akinsho/bufferline.nvim',
  version = '*',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  event = 'BufReadPost',
  keys = {
    { '<S-h>', '<cmd>BufferLineCyclePrev<cr>', desc = 'Previous buffer' },
    { '<S-l>', '<cmd>BufferLineCycleNext<cr>', desc = 'Next buffer' },
    { '<A-S-h>', '<cmd>BufferLineMovePrev<cr>', desc = 'Move buffer left' },
    { '<A-S-l>', '<cmd>BufferLineMoveNext<cr>', desc = 'Move buffer right' },
    { '<leader>bp', '<cmd>BufferLineTogglePin<cr>', desc = 'Buffer: Toggle pin' },
    { '<leader>bo', '<cmd>BufferLineCloseOthers<cr>', desc = 'Buffer: Close others' },
    { '<leader>br', '<cmd>BufferLineCloseRight<cr>', desc = 'Buffer: Close to the right' },
    { '<leader>bl', '<cmd>BufferLineCloseLeft<cr>', desc = 'Buffer: Close to the left' },
    { '<leader>1', '<cmd>BufferLineGoToBuffer 1<cr>', desc = 'Buffer 1' },
    { '<leader>2', '<cmd>BufferLineGoToBuffer 2<cr>', desc = 'Buffer 2' },
    { '<leader>3', '<cmd>BufferLineGoToBuffer 3<cr>', desc = 'Buffer 3' },
    { '<leader>4', '<cmd>BufferLineGoToBuffer 4<cr>', desc = 'Buffer 4' },
    { '<leader>5', '<cmd>BufferLineGoToBuffer 5<cr>', desc = 'Buffer 5' },
  },
  opts = function()
    local builtin = require('bufferline.groups').builtin
    return {
      options = {
        separator_style = 'slant',
        sort_by = 'insert_after_current',
        show_close_icon = false,
        show_buffer_close_icons = false,
        diagnostics = 'nvim_lsp',
        diagnostics_indicator = function(_, _, diagnostics)
          local symbols = { error = ' ', warning = ' ' }
          local result = {}
          for name, count in pairs(diagnostics) do
            if symbols[name] and count > 0 then
              table.insert(result, symbols[name] .. count)
            end
          end
          local res = table.concat(result, ' ')
          return #res > 0 and res or ''
        end,
        offsets = {
          {
            filetype = 'NvimTree',
            text = 'File Explorer',
            highlight = 'Directory',
            separator = true,
          },
        },
        groups = {
          options = { toggle_hidden_on_enter = true },
          items = {
            builtin.pinned:with({ icon = '' }),
            builtin.ungrouped,
            {
              name = 'rs',
              highlight = { sp = '#AE403F' },
              matcher = function(buf)
                return vim.fn.fnamemodify(buf.path, ':e') == 'rs'
              end,
            },
            {
              name = 'py',
              highlight = { sp = '#8FAA54' },
              matcher = function(buf)
                return vim.fn.fnamemodify(buf.path, ':e') == 'py'
              end,
            },
            {
              name = 'go',
              highlight = { sp = '#689FB6' },
              matcher = function(buf)
                return vim.fn.fnamemodify(buf.path, ':e') == 'go'
              end,
            },
            {
              name = 'lua',
              highlight = { sp = '#F09F17' },
              matcher = function(buf)
                return vim.fn.fnamemodify(buf.path, ':e') == 'lua'
              end,
            },
            {
              name = 'js',
              highlight = { sp = '#F09F17' },
              matcher = function(buf)
                local ext = vim.fn.fnamemodify(buf.path, ':e')
                return ext == 'js' or ext == 'jsx' or ext == 'ts' or ext == 'tsx'
              end,
            },
            {
              name = 'cfg',
              icon = '',
              matcher = function(buf)
                local name = vim.api.nvim_buf_get_name(buf.id)
                return name:match('Cargo.toml')
                  or name:match('go%.mod')
                  or name:match('go%.sum')
                  or name:match('Makefile')
                  or name:match('package%.json')
                  or name:match('tsconfig')
                  or name:match('pyproject%.toml')
                  or name:match('setup%.py')
                  or name:match('%.config%.')
              end,
            },
            {
              name = 'tests',
              icon = '',
              matcher = function(buf)
                local name = vim.api.nvim_buf_get_name(buf.id)
                return name:match('_spec') or name:match('_test') or name:match('test_') or name:match('%.test%.')
              end,
            },
            {
              name = 'docs',
              icon = '',
              matcher = function(buf)
                local ext = vim.fn.fnamemodify(buf.path, ':e')
                return vim.tbl_contains({ 'md', 'org', 'txt', 'rst', 'wiki' }, ext)
              end,
            },
          },
        },
      },
    }
  end,
}
