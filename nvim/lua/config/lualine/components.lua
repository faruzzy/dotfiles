-- Custom lualine components. Required from the lualine spec's opts function, so Catppuccin
-- is already set up and its palette can be read here.

local p = require('catppuccin.palettes').get_palette()

local M = {}

M.palette = p

-- The bar itself is the editor background; only the pills carry colour, so they float
local bar = { a = { fg = p.overlay1, bg = p.base }, b = { fg = p.overlay1, bg = p.base }, c = { fg = p.overlay1, bg = p.base } }
M.theme = { normal = bar, insert = bar, visual = bar, replace = bar, command = bar, terminal = bar, inactive = bar }

local mode_colors = {
  n = p.lavender,
  i = p.green,
  v = p.mauve,
  V = p.mauve,
  ['\22'] = p.mauve,
  s = p.teal,
  S = p.teal,
  ['\19'] = p.teal,
  c = p.peach,
  R = p.red,
  r = p.red,
  ['!'] = p.lavender,
  t = p.sapphire,
}

-- Two-tone pill on the left: mode, then the filetype. The mode's rounded end bleeds into the
-- filetype half; lualine colours a table separator from the neighbouring components
M.mode = {
  'mode',
  icon = '\u{e62b}',
  color = function() return { fg = p.base, bg = mode_colors[vim.fn.mode():sub(1, 1)] or p.lavender, gui = 'bold' } end,
  separator = { left = '\u{e0b6}', right = '\u{e0b4}' },
}

M.filetype = {
  'filetype',
  colored = false,
  color = { fg = p.base, bg = p.pink },
  separator = { right = '\u{e0b4}' },
}

M.branch = { 'b:gitsigns_head', icon = '\u{e725}' }

-- Two-tone pill on the right: working directory, then the host (tells the two Macs apart)
M.cwd = {
  function() return vim.fn.fnamemodify(vim.fn.getcwd(), ':t') end,
  icon = '\u{f07b}',
  color = { fg = p.base, bg = p.pink, gui = 'bold' },
  separator = { left = '\u{e0b6}' },
}

local host = vim.fn.hostname():gsub('%.local$', '')
M.host = {
  function() return host end,
  icon = '󰒋',
  color = { fg = p.base, bg = p.peach, gui = 'bold' },
  separator = { left = '\u{e0b6}', right = '\u{e0b4}' },
}

-- Attached language servers by name (state dots are in the incline label)
local lsp_hidden = { copilot = true }
M.lsp = {
  function()
    local names = {}
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
      if not lsp_hidden[client.name] then names[#names + 1] = client.name end
    end
    return table.concat(names, ' ')
  end,
  icon = '\u{f013}',
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
  color = { fg = p.red, gui = 'bold' },
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
  icon = '\u{f002}',
  color = { fg = p.mauve },
}

-- Spell check indicator
M.spell_indicator = {
  function()
    return vim.wo.spell and '󰓆' or ''
  end,
  cond = function()
    return vim.wo.spell
  end,
  color = { fg = p.blue },
}

-- Tmux zoom indicator. The flag is cached and re-read asynchronously when the
-- pane is resized (zoom/unzoom resizes it) or regains focus, not on every redraw.
local tmux_zoomed = false
if vim.env.TMUX then
  -- Target this Neovim's pane, not whichever pane the client is focused on
  local cmd = vim.env.TMUX_PANE and { 'tmux', 'display-message', '-p', '-t', vim.env.TMUX_PANE, '#{window_zoomed_flag}' }
    or { 'tmux', 'display-message', '-p', '#{window_zoomed_flag}' }
  local function update_tmux_zoomed()
    vim.system(cmd, { text = true }, function(out)
      local zoomed = vim.trim(out.stdout or '') == '1'
      if zoomed ~= tmux_zoomed then
        tmux_zoomed = zoomed
        vim.schedule(function() require('lualine').refresh() end)
      end
    end)
  end
  vim.api.nvim_create_autocmd({ 'VimResized', 'FocusGained' }, {
    group = vim.api.nvim_create_augroup('lualine_tmux_zoomed', { clear = true }),
    callback = update_tmux_zoomed,
  })
  update_tmux_zoomed()
end

M.tmux_zoomed = {
  function()
    return tmux_zoomed and 'ZOOMED' or ''
  end,
  cond = function()
    return vim.env.TMUX ~= nil
  end,
  color = { fg = p.base, bg = p.red, gui = 'bold' },
  separator = { left = '\u{e0b6}', right = '\u{e0b4}' },
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
  ['neo-tree'] = 'Neo-tree',
  Outline = 'Symbols Outline',
  aerial = 'Aerial',
  gitcommit = 'Git Commit',
  startify = 'Startify',
  startuptime = 'Startup Time',
  undotree = 'Undo Tree',
}

-- Lead pill for extensions (neo-tree, help, ...)
M.ft_upper = {
  'filetype',
  fmt = function(name)
    return M.filetype_names[name] or name
  end,
  colored = false,
  color = { fg = p.base, bg = p.lavender, gui = 'bold' },
  separator = { left = '\u{e0b6}', right = '\u{e0b4}' },
}

return M
