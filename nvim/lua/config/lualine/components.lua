-- Custom lualine components

local M = {}

-- Priority list for main language servers
M.PRIORITY_LSP_SERVERS = {
  'typescript-tools',
  'ts_ls',
  'lua_ls',
  'pyright',
  'rust_analyzer',
  'gopls',
  'clangd',
  'svelte',
  'cssls',
  'html',
  'graphql',
  'jsonls',
  'yamlls',
  'vimls',
}

-- LSP server name with count
M.active_lsp = {
  function()
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    if next(clients) == nil then
      return ''
    end

    -- Find priority server
    local main_server = nil
    for _, priority in ipairs(M.PRIORITY_LSP_SERVERS) do
      for _, client in ipairs(clients) do
        if client.name == priority then
          main_server = client.name
          break
        end
      end
      if main_server then
        break
      end
    end

    -- Count total non-null-ls clients
    local count = 0
    for _, client in ipairs(clients) do
      if client.name ~= 'null-ls' then
        count = count + 1
      end
    end

    if main_server then
      if count > 1 then
        return string.format('%s +%d', main_server, count - 1)
      end
      return main_server
    end

    -- Fallback to first non-null-ls client
    for _, client in ipairs(clients) do
      if client.name ~= 'null-ls' then
        return client.name
      end
    end

    return clients[1] and clients[1].name or ''
  end,
  icon = ' LSP:',
}

-- Macro recording indicator
M.macro_recording = {
  function()
    local reg = vim.fn.reg_recording()
    if reg == '' then
      return ''
    end
    return 'recording @' .. reg
  end,
  color = { fg = '#ff9e64', gui = 'bold' },
}

-- Search count
M.search_result = {
  function()
    if vim.v.hlsearch == 0 then
      return ''
    end
    local res = vim.fn.searchcount({ maxcount = 999, timeout = 500 })
    if res.total == 0 then
      return ''
    end
    return string.format('%d/%d', res.current, res.total)
  end,
}

-- Spell check indicator
M.spell_indicator = {
  function()
    return vim.wo.spell and '暈' or ''
  end,
  cond = function()
    return vim.wo.spell
  end,
  color = { fg = '#7aa2f7' },
}

-- Tmux zoom indicator
M.tmux_zoomed = {
  function()
    if vim.env.TMUX then
      local zoomed = vim.fn.system("tmux display-message -p '#{window_zoomed_flag}'")
      if vim.trim(zoomed) == '1' then
        return 'ZOOMED'
      end
    end
    return ''
  end,
  cond = function()
    return vim.env.TMUX ~= nil
  end,
  color = { fg = '#1a1b26', bg = '#f7768e', gui = 'bold' },
}

-- Smart filename with path shortening
M.filename = {
  'filename',
  path = 1, -- Relative path
  shorting_target = 40,
  symbols = {
    modified = ' ●',
    readonly = ' ',
    unnamed = '[No Name]',
  },
}

-- Diff source from gitsigns
M.diff_source = function()
  local gitsigns = vim.b.gitsigns_status_dict
  if gitsigns then
    return {
      added = gitsigns.added,
      modified = gitsigns.changed,
      removed = gitsigns.removed,
    }
  end
end

-- Filetype names for special buffers
M.filetype_names = {
  DiffviewFiles = 'Diff View',
  NeogitStatus = 'Neogit',
  NvimTree = 'Nvim Tree',
  Outline = 'Symbols Outline',
  aerial = 'Aerial',
  gitcommit = 'Git Commit',
  startify = 'Startify',
  startuptime = 'Startup Time',
  undotree = 'Undo Tree',
}

M.ft_upper = {
  'filetype',
  fmt = function(name)
    return M.filetype_names[name] or name
  end,
}

return M
