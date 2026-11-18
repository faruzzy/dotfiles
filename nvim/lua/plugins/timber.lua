-- Insert log statements for the target under the cursor (glj/glk, gL + motion, glb batch).
-- Every inserted line carries timber's marker (🪵) so <Leader>lc / <Leader>lt can find them;
-- languages not listed keep timber's default templates, without the marker.
local js = {
  default = [[console.log("%log_marker %log_target", %log_target)]],
  plain = [[console.log("%log_marker %insert_cursor")]],
  batch = [[console.log("%log_marker", { %repeat<"%log_target": %log_target><, > })]],
}

local templates = {
  javascript = js,
  typescript = js,
  jsx = js,
  tsx = js,
  lua = {
    default = [[print("%log_marker %log_target", %log_target)]],
    plain = [[print("%log_marker %insert_cursor")]],
    batch = [[print(string.format("%log_marker %repeat<%log_target=%s><, >", %repeat<%log_target><, >))]],
  },
  go = {
    default = [[log.Printf("%log_marker %log_target: %v\n", %log_target)]],
    plain = [[log.Println("%log_marker %insert_cursor")]],
    batch = [[log.Printf("%log_marker %repeat<%log_target=%v><, >\n", %repeat<%log_target><, >)]],
  },
  ruby = {
    default = [[puts("%log_marker %log_target #{%log_target}")]],
    plain = [[puts("%log_marker %insert_cursor")]],
    batch = [[puts("%log_marker %repeat<%log_target=#{%log_target}><, >")]],
  },
  rust = {
    default = [[println!("%log_marker %log_target: {:#?}", %log_target);]],
    plain = [[println!("%log_marker %insert_cursor");]],
    batch = [[println!("%log_marker %repeat<%log_target={:#?}><, >", %repeat<%log_target><, >);]],
  },
}

local function by(kind)
  local out = {}
  for lang, t in pairs(templates) do
    out[lang] = t[kind]
  end
  return out
end

return {
  'Goose97/timber.nvim',
  version = '*',
  keys = {
    { 'glj', desc = 'Log: below' },
    { 'glk', desc = 'Log: above' },
    { 'glo', desc = 'Log: plain, below' },
    { 'gl<S-o>', desc = 'Log: plain, above' },
    { 'glb', mode = { 'n', 'x' }, desc = 'Log: batch' },
    { 'gla', mode = { 'n', 'x' }, desc = 'Log: add to batch' },
    { 'gL', mode = { 'n', 'x' }, desc = 'Log: operator' },
    {
      '<Leader>lc',
      function() require('timber.actions').clear_log_statements({ global = false }) end,
      desc = 'Log: clear marked logs in buffer',
    },
    {
      '<Leader>lt',
      function() require('timber.actions').toggle_comment_log_statements({ global = false }) end,
      desc = 'Log: comment / uncomment marked logs',
    },
  },
  opts = {
    log_templates = { default = by('default'), plain = by('plain') },
    batch_log_templates = { default = by('batch') },
  },
}
