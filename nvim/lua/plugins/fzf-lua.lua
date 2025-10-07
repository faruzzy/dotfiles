local function smart_references_fzf()
  local current_file = vim.fn.expand('%:p')
  local current_pos = vim.api.nvim_win_get_cursor(0)
  local current_line = current_pos[1]
  local current_col = current_pos[2]

  vim.lsp.buf.references(nil, {
    on_list = function(options)
      -- Filter the items
      local filtered_items = {}
      for _, item in ipairs(options.items) do
        -- Skip current cursor position
        local is_current_position = (
          item.filename == current_file
          and item.lnum == current_line
          and math.abs((item.col or 1) - current_col - 1) <= 1
        )

        if not is_current_position then
          -- Skip import lines
          local line = item.text or ''
          if
              not line:match('^%s*import%s')
              and not line:match('^%s*export%s')
              and not line:match('^%s*from%s')
              and not line:match('^%s*type%s.*=')
          then
            table.insert(filtered_items, item)
          end
        end
      end

      if #filtered_items == 0 then
        vim.notify('No other references found', vim.log.levels.WARN)
        return
      end

      -- Jump directly if only one result
      if #filtered_items == 1 then
        local item = filtered_items[1]
        vim.cmd('edit ' .. vim.fn.fnameescape(item.filename))
        vim.api.nvim_win_set_cursor(0, { item.lnum, (item.col or 1) - 1 })
        return
      end

      -- Set quickfix list and use fzf-lua
      vim.fn.setqflist({}, 'r', {
        title = 'References (filtered)',
        items = filtered_items,
      })

      require('fzf-lua').quickfix({
        prompt = 'References (filtered)> ',
      })
    end,
  })
end

-- Smart LSP definitions that prioritizes class over constructor
local function smart_definitions()
  local params = vim.lsp.util.make_position_params(0, 'utf-8')

  vim.lsp.buf_request(0, 'textDocument/definition', params, function(err, result)
    if err then
      vim.notify('LSP definition error: ' .. err.message, vim.log.levels.ERROR)
      return
    end

    if not result or vim.tbl_isempty(result) then
      vim.notify('No definition found', vim.log.levels.WARN)
      return
    end

    -- Normalize result (can be Location or Location[])
    local locations = {}
    if result.uri then
      locations = { result }
    else
      locations = result
    end

    if #locations == 1 then
      -- Jump directly if only one result
      -- vim.lsp.util.jump_to_location(locations[1], 'utf-8')
      vim.lsp.util.show_document(locations[1], 'utf-8', { focus = true })
      return
    end

    -- Filter and prioritize definitions
    local class_definitions = {}
    local other_definitions = {}

    for _, location in ipairs(locations) do
      local uri = location.uri or location.targetUri
      local file_path = vim.uri_to_fname(uri)
      local line_num = (location.range or location.targetRange).start.line + 1

      -- Read the line to check what kind of definition it is
      local ok, lines = pcall(vim.fn.readfile, file_path, '', line_num)

      if ok and lines[line_num] then
        local line_content = lines[line_num]

        -- Check if it's a class definition
        if
            line_content:match('%s*class%s+%w+')
            or line_content:match('%s*export%s+class%s+%w+')
            or line_content:match('%s*export%s+default%s+class%s+%w+')
        then
          table.insert(class_definitions, location)
          -- Skip constructor definitions
        elseif not line_content:match('%s*constructor%s*%(') then
          table.insert(other_definitions, location)
        end
      else
        -- If we can't read the file, include it in other_definitions
        table.insert(other_definitions, location)
      end
    end

    -- Prioritize class definitions
    local final_locations = {}
    if #class_definitions > 0 then
      final_locations = class_definitions
    else
      final_locations = other_definitions
    end

    if #final_locations == 0 then
      vim.notify('No class definitions found', vim.log.levels.WARN)
      return
    end

    if #final_locations == 1 then
      -- Jump directly if only one result after filtering
      -- vim.lsp.util.jump_to_location(final_locations[1], 'utf-8')
      vim.lsp.util.show_document(final_locations, 'utf-8', { focus = true })
      return
    end

    -- Convert locations to quickfix format for fzf-lua
    local qf_items = vim.lsp.util.locations_to_items(final_locations, 'utf-8')

    -- Use fzf-lua's quickfix list interface
    require('fzf-lua').quickfix({
      list = qf_items,
      prompt = 'Definitions (classes prioritized)> ',
    })
  end)
end

return {
  {
    'ibhagwan/fzf-lua',
    dependencies = { 'echasnovski/mini.icons' },
    event = 'VeryLazy',
    opts = {
      winopts = {
        backdrop = 100,
        border = vim.g.border_style,
        preview = { border = 'border-double', wrap = 'wrap', flip_columns = 160 },
      },
      fzf_opts = {
        ['--border'] = 'none',
        ['--cycle'] = true,
        ['--marker'] = '+',
        ['--pointer'] = '>',
      },
      grep = {
        rg_opts = table.concat({
          -- custom opts
          '--hidden',
          '-g="!.git"',
          -- default opts
          '--column',
          '--line-number',
          '--no-heading',
          '--color=always',
          '--smart-case',
          '--max-columns=4096',
          '-e',
        }, ' '),
      },
      keymap = {
        builtin = {
          true,
          ['<F1>'] = 'toggle-help',
          ['<F2>'] = 'toggle-fullscreen',
          ['<C-c>'] = 'toggle-preview',
          ['<C-f>'] = 'preview-page-down',
          ['<C-b>'] = 'preview-page-up',
        },
        fzf = {
          true,
          ['alt-a'] = 'toggle-all',
          ['ctrl-q'] = 'select-all+accept',
          ['ctrl-c'] = 'toggle-preview',
          ['ctrl-a'] = 'beginning-of-line',
          ['ctrl-e'] = 'end-of-line',
          ['ctrl-f'] = 'preview-page-down',
          ['ctrl-b'] = 'preview-page-up',
        },
        lsp = {
          code_actions = { previewer = 'codeaction_native' },
          ignore_current_line = true,
          includeDeclaration = false,
        },
        oldfiles = { cwd_only = true },
      },
    },
    keys = {
      {
        '<C-p>',
        function()
          require('fzf-lua').files({ file_icons = false, git_icons = false })
        end,
        desc = 'files / git files',
      },
      {
        '<leader>sg',
        [[<cmd>lua require('fzf-lua').grep_project({ file_icons=false, git_icons=false })<CR>]],
        desc = 'file lines',
      },
      --- Buffer
      { '<Leader><CR>', [[<cmd>lua require('fzf-lua').buffers()<CR>]],      desc = 'buffers' },
      { '<C-g>',        [[<cmd>lua require('fzf-lua').resume()<CR>]],       desc = 'resume' },
      { '<leader>of',   [[<cmd>lua require('fzf-lua').oldfiles()<CR>]],     desc = '[O]ld [F]iles' },

      --- Search
      { '<leader>/',    [[<cmd>lua require('fzf-lua').lgrep_curbuf()<CR>]], desc = 'Search current buffer Lines' },
      {
        '<leader>fw',
        [[<cmd>lua require('fzf-lua').grep_cword()<CR>]],
        desc = 'Search word under the cursor globally',
      },
      {
        '<leader>fW',
        [[<cmd>lua require('fzf-lua').grep_cWORD()<CR>]],
        desc = 'Search word under the cursor in current buffer',
      },

      --- Code Navigation
      { '<Leader>dw', [[<cmd>lua require('fzf-lua').diagnostics_workspace()<CR>]], desc = 'Workspace diagnostics' },
      { '<Leader>ws', [[<cmd>lua require('fzf-lua').lsp_workspace_symbols()<CR>]], desc = 'Workspace Symbols' },
      { '<Leader>ds', [[<cmd>lua require('fzf-lua').lsp_document_symbols()<CR>]],  desc = 'Document Symbols' },
      {
        'gr',
        smart_references_fzf,
        desc = '[G]o to [R]eferences',
      },
      {
        'gd',
        [[<cmd>lua require('fzf-lua').lsp_definitions({ jump1 = true })<CR>]],
        desc = '[G]o to [D]efinition',
      },
      {
        'gi',
        [[<cmd>lua require('fzf-lua').lsp_implementations({ jump1 = true })<CR>]],
        desc = '[G]o to [I]mplementation',
      },
      {
        'D',
        [[<cmd>lua require('fzf-lua').lsp_implementations({ jump1 = true })<CR>]],
        desc = 'Type Definition',
      },

      --- Git
      { '<Leader>gx', [[<cmd>lua require('fzf-lua').git_commits()<CR>]],  desc = 'git commits' },
      { '<Leader>gX', [[<cmd>lua require('fzf-lua').git_bcommits()<CR>]], desc = 'git buffer commits' },
      { '<Leader>gS', [[<cmd>lua require('fzf-lua').git_status()<CR>]],   desc = 'git status' },
      { '<Leader>gB', [[<cmd>lua require('fzf-lua').git_branches()<CR>]], desc = 'git branches' },

      --- Misc
      { '<Leader>k',  [[<cmd>lua require('fzf-lua').keymaps()<CR>]],      desc = 'keymaps' },
      { '<Leader>m',  [[<cmd>lua require('fzf-lua').marks()<CR>]],        desc = 'marks' },
      {
        '<Leader>hi',
        [[<cmd>lua require('fzf-lua').command_history()<CR>]],
        desc = 'command history',
      },
      { [[<Leader>"]], [[<cmd>lua require('fzf-lua').registers()<CR>]], desc = 'registers' },
      { '<Leader>:',   [[<cmd>lua require('fzf-lua').commands()<CR>]],  desc = 'vim commands' },
      { '<leader>sh',  [[<cmd>lua require('fzf-lua').help_tags()<CR>]], desc = 'help tags' },
      { '<leader>au',  [[<cmd>lua require('fzf-lua').autocmds()<CR>]],  desc = 'autocmds' },
    },
  },
}
