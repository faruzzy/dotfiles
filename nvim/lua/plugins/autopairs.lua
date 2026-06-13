-- autopairs configs, powered by treesitter
-- https://github.com/kuntau/dotfiles/blob/develop/config/nvim/lua/config/plugins/autopairs.lua
local config = function()
  local apair = require('nvim-autopairs')
  local rule = require('nvim-autopairs.rule')
  local end_lua = require('nvim-autopairs.rules.endwise-lua')

  apair.setup({
    check_ts = true,
    fastwrap = {
      map = '<M-e>',
      chars = { '{', '[', '(', '"', '\'' },
      pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], '%s+', ''),
      offset = 0, -- Offset from pattern match
      end_key = '$',
      keys = 'qwertyuiopzxcvbnmasdfghjkl',
      check_comma = true,
      highlight = 'Search',
      highlight_grey = 'Comment',
    },
    ts_config = {
      -- lua = {'string'},
      javascript = { 'template_string' },
    },
    disable_filetype = {
      'TelescopePrompt',
      'vim',
    },
  })

  -- add spaces between parentheses.
  local add_space_paren = {
    rule(' ', ' '):with_pair(function(opts)
      local pair = opts.line:sub(opts.col - 1, opts.col)
      return vim.tbl_contains({ '()', '[]', '{}' }, pair)
    end),
    rule('( ', ' )')
      :with_pair(function() return false end)
      :with_move(function(opts) return opts.prev_char:match('.%)') ~= nil end)
      :use_key(')'),
    rule('{ ', ' }')
      :with_pair(function() return false end)
      :with_move(function(opts) return opts.prev_char:match('.%}') ~= nil end)
      :use_key('}'),
    rule('[ ', ' ]')
      :with_pair(function() return false end)
      :with_move(function(opts) return opts.prev_char:match('.%]') ~= nil end)
      :use_key(']'),
  }

  apair.add_rules(end_lua)
  apair.add_rules(add_space_paren)
end

return {
  'windwp/nvim-autopairs',
  event = 'InsertEnter *.*',
  config = config,
}
