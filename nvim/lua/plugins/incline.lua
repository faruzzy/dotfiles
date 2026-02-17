-- Floating filename labels for splits
return {
  'b0o/incline.nvim',
  event = { 'BufReadPost', 'BufNew' },
  config = function()
    local devicons = require('nvim-web-devicons')

    require('incline').setup({
      window = {
        zindex = 49,
        width = 'fit',
        padding = { left = 2, right = 1 },
        placement = { vertical = 'top', horizontal = 'right' },
        margin = { horizontal = 0 },
      },
      hide = {
        cursorline = false,
        focused_win = false,
        only_win = true,
      },
      render = function(props)
        local bufname = vim.api.nvim_buf_get_name(props.buf)
        if bufname == '' then
          return '[No name]'
        end

        local icon, color = devicons.get_icon_color(bufname, nil, { default = true })
        local parts = vim.split(vim.fn.fnamemodify(bufname, ':.'), '/')
        local result = { { icon .. ' ', guifg = color } }

        for idx, part in ipairs(parts) do
          if next(parts, idx) then
            table.insert(result, { part })
            table.insert(result, { ' > ', guifg = 'Directory' })
          else
            table.insert(result, { part, gui = 'bold' })
          end
        end

        return result
      end,
    })
  end,
}
