---@module 'gx'

---@type { is_personal_machine: boolean, additional_servers: table<string, { config: table, server: table }>, supported_servers: string[], supported_debuggers: string[], supported_formatters: string[], supported_linters: string[], border_style: string, custom_gx_handlers: table[] }
local MY_CONFIG = {
  is_personal_machine = false,
  additional_servers = {},
  supported_servers = {},
  supported_debuggers = {},
  supported_formatters = {},
  supported_linters = {},
  border_style = 'rounded',
  custom_gx_handlers = {},
}

return MY_CONFIG
