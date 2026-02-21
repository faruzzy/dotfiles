-- Snippet Engine for Neovim written in Lua
local function key_map(map)
  local key, fn, args, desc, mode = unpack(map)

  return {
    key,
    function()
      require('luasnip')[fn](args)
    end,
    desc = desc,
    mode = mode,
  }
end

return {
  'L3MON4D3/LuaSnip',
  keys = vim.tbl_map(key_map, {
    { '<C-y>', 'expand',         nil, 'Expand snippet',                             'i' },
    { '<C-j>', 'expand_or_jump', nil, 'Expand snippet or jump to next placeholder', { 'i', 's' } },
    { '<C-k>', 'jump',           -1,  'Jump to previous placeholder',               { 'i', 's' } },
    { '<C-l>', 'unlink_current', nil, 'Exit snippet mode',                          { 'i', 's' } },
  }),
  config = function()
    local luasnip = require('luasnip')
    local snippet = luasnip.snippet
    local snippet_node = luasnip.snippet_node
    local dynamic_node = luasnip.dynamic_node
    local insert_node = luasnip.insert_node
    local text_node = luasnip.text_node
    local fmt = require('luasnip.extras.fmt').fmt

    require('luasnip.loaders.from_vscode').load({
      paths = { '~/github/dotfiles/vim-common/' },
    })

    require('luasnip.loaders.from_snipmate').load({
      paths = { '~/github/dotfiles/nvim/snippets/' },
    })

    luasnip.config.set_config({
      updateevents = 'TextChanged,TextChangedI',
    })

    -- React snippets for both JS and TS (hooks only - components come from VSCode snippets)
    local react_snippets = {
      snippet(
        { trig = 'us', name = 'useState', dscr = 'React useState hook' },
        fmt('const [{state}, set{State}] = useState({init})', {
          state = insert_node(1, 'state'),
          State = dynamic_node(2, function(args)
            local state_name = args[1][1]
            if state_name and #state_name > 0 then
              return snippet_node(nil, text_node(state_name:sub(1, 1):upper() .. state_name:sub(2)))
            end
            return snippet_node(nil, text_node('State'))
          end, { 1 }),
          init = insert_node(3),
        })
      ),
      snippet(
        { trig = 'ue', name = 'useEffect', dscr = 'React useEffect hook' },
        fmt(
          [[
useEffect(() => {{
  {body}
}}, [{deps}])
]],
          { body = insert_node(1), deps = insert_node(2) }
        )
      ),
      snippet(
        { trig = 'uec', name = 'useEffect with cleanup', dscr = 'React useEffect with cleanup' },
        fmt(
          [[
useEffect(() => {{
  {body}

  return () => {{
    {cleanup}
  }}
}}, [{deps}])
]],
          { body = insert_node(1), cleanup = insert_node(2), deps = insert_node(3) }
        )
      ),
      snippet(
        { trig = 'ur', name = 'useRef', dscr = 'React useRef hook' },
        fmt('const {ref} = useRef({init})', { ref = insert_node(1, 'ref'), init = insert_node(2, 'null') })
      ),
      snippet(
        { trig = 'um', name = 'useMemo', dscr = 'React useMemo hook' },
        fmt('const {name} = useMemo(() => {value}, [{deps}])', {
          name = insert_node(1, 'memoizedValue'),
          value = insert_node(2),
          deps = insert_node(3),
        })
      ),
      snippet(
        { trig = 'uc', name = 'useCallback', dscr = 'React useCallback hook' },
        fmt(
          [[
  const {name} = useCallback(({args}) => {{
    {body}
  }}, [{deps}])
  ]],
          { name = insert_node(1, 'callback'), args = insert_node(2), body = insert_node(3), deps = insert_node(4) }
        )
      ),
      snippet(
        { trig = 'uctx', name = 'useContext', dscr = 'React useContext hook' },
        fmt('const {value} = useContext({context})', {
          value = insert_node(1, 'value'),
          context = insert_node(2, 'Context'),
        })
      ),
      snippet(
        { trig = 'urd', name = 'useReducer', dscr = 'React useReducer hook' },
        fmt('const [{state}, {dispatch}] = useReducer({reducer}, {init})', {
          state = insert_node(1, 'state'),
          dispatch = insert_node(2, 'dispatch'),
          reducer = insert_node(3, 'reducer'),
          init = insert_node(4, 'initialState'),
        })
      ),

    }

    -- Add React snippets to both JavaScript and TypeScript React
    luasnip.add_snippets('javascriptreact', react_snippets)
    luasnip.add_snippets('typescriptreact', react_snippets)

    -- TypeScript-specific React snippets
    luasnip.add_snippets('typescriptreact', {
      snippet(
        { trig = 'ust', name = 'useState TypeScript', dscr = 'React useState with TypeScript' },
        fmt('const [{state}, set{State}] = useState<{type}>({init})', {
          state = insert_node(1, 'state'),
          State = dynamic_node(2, function(args)
            local state_name = args[1][1]
            if state_name and #state_name > 0 then
              return snippet_node(nil, text_node(state_name:sub(1, 1):upper() .. state_name:sub(2)))
            end
            return snippet_node(nil, text_node('State'))
          end, { 1 }),
          type = insert_node(3, 'type'),
          init = insert_node(4),
        })
      ),
    })
  end,
}
