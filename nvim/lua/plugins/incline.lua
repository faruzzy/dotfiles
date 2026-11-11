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
        placement = { vertical = 'bottom', horizontal = 'right' },
        margin = { horizontal = 0 },
      },
      hide = {
        cursorline = true, -- hide while the cursor is on the line it covers
        focused_win = false,
        only_win = true,
      },
      render = function(props)
        local bufname = vim.api.nvim_buf_get_name(props.buf)
        if bufname == '' then
          return '[No name]'
        end
        -- Git revision buffers (fugitive://, diffview://) have URL names, not useful paths;
        -- an empty result hides the label
        if bufname:match('^%a[%w+.-]*://') then
          return ''
        end

        local icon, color = devicons.get_icon_color(bufname, nil, { default = true })
        local parts = vim.split(vim.fn.fnamemodify(bufname, ':.'), '/')
        local result = { { icon .. ' ', guifg = color } }

        -- Keep the file and its directory whole; shorten the directories above them to their
        -- first letter (.config -> .c), dimmed, and drop all but the nearest 3
        local head = #parts - 2
        if head > 3 then table.insert(result, { '… > ', group = 'Comment' }) end
        for idx, part in ipairs(parts) do
          if idx <= head then
            if idx > head - 3 then
              table.insert(result, { part:match('^%.?[^.]') or part, group = 'Comment' })
              table.insert(result, { ' > ', group = 'Comment' })
            end
          elseif next(parts, idx) then
            table.insert(result, { part })
            table.insert(result, { ' > ', guifg = 'Directory' })
          else
            table.insert(result, { part, gui = 'bold' })
          end
        end

        -- One dot per server state, with a count when several share it
        local counts = require('lsp.status').counts(props.buf)
        for _, s in ipairs({
          { 'starting', 'DiagnosticWarn' },
          { 'busy', 'DiagnosticWarn' },
          { 'running', 'DiagnosticOk' },
          { 'crashed', 'DiagnosticError' },
        }) do
          local n = counts[s[1]]
          if n > 0 then
            table.insert(result, { (n > 1 and ' ' .. n or ' ') .. (s[1] == 'busy' and '◐' or '●'), group = s[2] })
          end
        end

        return result
      end,
    })
  end,
}
