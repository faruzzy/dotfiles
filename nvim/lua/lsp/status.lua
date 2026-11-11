-- Per-buffer LSP client state (starting, busy, running, crashed) for the incline label
local M = {}

---@type table<integer, table<integer|string, true>> client id -> active progress tokens
local busy = {}
---@type table<integer, { name: string, bufs: table<integer, true> }> crashed clients by id
local crashed = {}

local function refresh()
  if package.loaded['incline'] then require('incline').refresh() end
end

---on_exit for every server (set through vim.lsp.config('*'))
---@param code integer
---@param signal integer
---@param client_id integer
function M.on_exit(code, signal, client_id)
  busy[client_id] = nil
  -- Same test core uses for its "quit with exit code" warning; 15 is a normal SIGTERM stop
  local client = vim.lsp.get_client_by_id(client_id)
  if client and (code ~= 0 or (signal ~= 0 and signal ~= 15)) then
    crashed[client_id] = { name = client.name, bufs = vim.deepcopy(client.attached_buffers) }
  end
  vim.schedule(refresh)
end

---@param bufnr integer
---@return { starting: integer, busy: integer, running: integer, crashed: integer }
function M.counts(bufnr)
  local counts = { starting = 0, busy = 0, running = 0, crashed = 0 }
  -- _uninitialized: include clients still starting up, which get_clients skips by default
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr, _uninitialized = true })) do
    if not client.initialized then
      counts.starting = counts.starting + 1
    elseif next(busy[client.id] or {}) then
      counts.busy = counts.busy + 1
    else
      counts.running = counts.running + 1
    end
  end
  for _, c in pairs(crashed) do
    if c.bufs[bufnr] then counts.crashed = counts.crashed + 1 end
  end
  return counts
end

function M.setup()
  local group = vim.api.nvim_create_augroup('lsp_status', { clear = true })
  vim.api.nvim_create_autocmd('LspAttach', {
    group = group,
    callback = function(args)
      -- A restarted server replaces its crashed predecessor
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      for id, c in pairs(crashed) do
        if client and c.name == client.name then crashed[id] = nil end
      end
      refresh()
    end,
  })
  vim.api.nvim_create_autocmd('LspDetach', { group = group, callback = vim.schedule_wrap(refresh) })
  vim.api.nvim_create_autocmd('LspProgress', {
    group = group,
    pattern = { 'begin', 'end' }, -- 'report' fires constantly and doesn't change the state
    callback = function(args)
      local id, token = args.data.client_id, args.data.params.token
      busy[id] = busy[id] or {}
      busy[id][token] = args.match == 'begin' or nil
      refresh()
    end,
  })
end

return M
