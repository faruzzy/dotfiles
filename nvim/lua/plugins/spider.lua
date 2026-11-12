-- w/e/b/ge stop at subword boundaries (camelCase, snake_case) and skip lone punctuation
local function motion(key)
  return {
    key,
    function() require('spider').motion(key) end,
    mode = { 'n', 'o', 'x' },
    desc = 'Spider ' .. key,
  }
end

return {
  'chrisgrieser/nvim-spider',
  keys = {
    motion('w'),
    motion('e'),
    motion('b'),
    motion('ge'),
    -- Vim treats cw as ce; keep that with spider's e
    { 'cw', 'ce', remap = true, desc = 'Change to end of subword' },
  },
}
