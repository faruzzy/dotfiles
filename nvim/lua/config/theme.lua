local module = {}

module.icons = {
  vim = ' ',
  debug = ' ',
  trace = '✎ ',
  code_action = '󰌵 ',
  code_lens_action = '󰄄 ',
  test = ' ',
  docs = ' ',
  clock = ' ',
  calendar = ' ',
  buffer = '󱡗 ',
  layers = ' ',
  settings = ' ',
  ls_active = '󰕮 ',
  ls_inactive = ' ',
  question = ' ',
  added = '  ',
  modified = ' ',
  removed = ' ',
  config = ' ',
  git = ' ',
  magic = ' ',
  exit = ' ',
  exit2 = ' ',
  session = '󰔚 ',
  project = '⚝ ',
  stuka = ' ',
  text = '󰊄 ',
  typos = '󰨸 ',
  files = ' ',
  file = '󰈚 ',
  zoxide = ' ',
  repo = ' ',
  term = ' ',
  palette = ' ',
  buffers = '󰨝 ',
  telescope = ' ',
  dashboard = '󰕮 ',
  boat = ' ',
  unmute = '',
  mute = ' ',
  quit = '󰗼 ',
  replace = ' ',
  find = ' ',
  comment = ' ',
  ok = ' ',
  no = ' ',
  moon = ' ',
  go = ' ',
  resume = ' ',
  codelens = '󰄄 ',
  folder = ' ',
  package = ' ',
  spelling = ' ',
  copilot = ' ',
  gpt = ' ',
  attention = ' ',
  Function = ' ',
  power = '󰚥 ',
  zen = ' ',
  music = ' ',
  nuclear = '☢ ',
  treesitter = ' ',
  lock = ' ',
  presence_on = '󰅠 ',
  presence_off = ' ',
  caret = '- ',
  flash = ' ',
  world = ' ',
  label = ' ',
  link = '󰲔 ',
  person = ' ',
  expanded = ' ',
  collapsed = ' ',
  circular = ' ',
  circle_left = '',
  circle_right = '',
  neotest = '󰙨 ',
  rename = ' ',
  amazon = ' ',
  inlay = ' ',
  pinned = ' ',
  mind = ' ',
  mind_tasks = '󱗽 ',
  mind_backlog = ' ',
  mind_on_going = ' ',
  mind_done = ' ',
  mind_cancelled = ' ',
  mind_notes = ' ',
  button_off = ' ',
  button_on = ' ',
  up = ' ',
  down = ' ',
  todo = ' ',
  right = ' ',
  left = ' ',
  outline = ' ',
  window = '󱂬 ',
  cmdline = '',
  search_down = ' ',
  search_up = ' ',
  bash = '$',
  lua = '',
  help = '󰘥',
  calculator = '',
  ui = ' ',
  snippets = '󱩽 ',
  floppy = ' ',
  commander = '󰘳 ',
  gitlab = '󰮠 ',
}

module.battery_icons = {
  _100 = '􀛨',
  _75 = '􀺸',
  _50 = '􀺶',
  _25 = '􀛩',
  _0 = '􀛪',
  _charging = '􀢋',
}

module.dap_icons = {
  breakpoint = '',
  breakpoint_rejected = '',
  breakpoint_condition = '',
  stopped = '',
}

module.symbol_usage = {
  circle_left = '',
  circle_right = '',
  def = '󰳽 ',
  ref = '󰌹 ',
  impl = '󰡱 ',
}

module.languages = {
  lua = ' ',
  c = ' ',
  rust = '󱘗 ',
  js = ' ',
  ts = ' ',
  ruby = ' ',
  vim = ' ',
  git = ' ',
  c_sharp = ' ',
  python = ' ',
  go = ' ',
  java = ' ',
  kotlin = ' ',
  toml = '󰏗 ',
}

module.file_icons = {
  Brown = { '' },
  Aqua = { '' },
  LightBlue = { '', '' },
  Blue = { '', '', '', '', '', '', '', '', '', '', '', '', '' },
  DarkBlue = { '', '' },
  Purple = { '', '', '', '', '' },
  Red = { '', '', '', '', '', '' },
  Beige = { '', '', '' },
  Yellow = { '', '', 'λ', '', '' },
  Orange = { '', '' },
  DarkOrange = { '', '', '', '', '' },
  Pink = { '', '' },
  Salmon = { '' },
  Green = { '', '', '', '', '', '󰌛' },
  LightGreen = { '', '', '', '󰡄' },
  White = { '', '', '', '', '', '' },
}

function module.alpha_banner()
  vim.api.nvim_set_hl(0, 'StartLogo1', { fg = '#1C506B' })
  vim.api.nvim_set_hl(0, 'StartLogo2', { fg = '#1D5D68' })
  vim.api.nvim_set_hl(0, 'StartLogo3', { fg = '#1E6965' })
  vim.api.nvim_set_hl(0, 'StartLogo4', { fg = '#1F7562' })
  vim.api.nvim_set_hl(0, 'StartLogo5', { fg = '#21825F' })
  vim.api.nvim_set_hl(0, 'StartLogo6', { fg = '#228E5C' })
  vim.api.nvim_set_hl(0, 'StartLogo7', { fg = '#239B59' })
  vim.api.nvim_set_hl(0, 'StartLogo8', { fg = '#24A755' })
  return {
    [[                                                                   ]],
    [[      ████ ██████           █████      ██                    ]],
    [[     ███████████             █████                            ]],
    [[     █████████ ███████████████████ ███   ███████████  ]],
    [[    █████████  ███    █████████████ █████ ██████████████  ]],
    [[   █████████ ██████████ █████████ █████ █████ ████ █████  ]],
    [[ ███████████ ███    ███ █████████ █████ █████ ████ █████ ]],
    [[██████  █████████████████████ ████ █████ █████ ████ ██████]],
  }
end

function module.poetry_run(args)
  local mason_install_path = vim.fn.stdpath('data') .. '/mason/bin'
  local file = vim.fn.findfile('poetry.lock', '.;')
  if file == 'poetry.lock' then
    args[1] = mason_install_path .. '/' .. args[1]
    table.insert(args, 1, 'poetry')
    table.insert(args, 2, 'run')
  end
  return args
end
return module
