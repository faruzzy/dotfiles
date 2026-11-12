-- Run tests from inside Neovim: results show as signs next to each test, failures as
-- diagnostics on the failing line, and the summary is a tree of the project's tests.
-- Debugging a test goes through nvim-dap (plugins/dap.lua)
local function neotest() return require('neotest') end

-- Both adapters root at the nearest package.json, so both register for every JS project, and
-- whichever registered first may get the file: vitest running a jest file marks every test
-- skipped. Only root where the runner is a dependency (or of the git root, for monorepos)
local function root_if_uses(runner)
  return function(path)
    local root = vim.fs.root(path, 'package.json')
    if not root then return nil end
    for _, dir in ipairs({ root, vim.fs.root(path, '.git') }) do
      local ok, pkg = pcall(function() return vim.json.decode(table.concat(vim.fn.readfile(dir .. '/package.json'), '\n')) end)
      if ok and type(pkg) == 'table' then
        for _, field in ipairs({ 'dependencies', 'devDependencies' }) do
          if type(pkg[field]) == 'table' and pkg[field][runner] then return root end
        end
      end
    end
  end
end

return {
  'nvim-neotest/neotest',
  dependencies = {
    'nvim-neotest/nvim-nio',
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    'marilari88/neotest-vitest',
    'nvim-neotest/neotest-jest',
  },
  cmd = 'Neotest',
  keys = {
    { '<Leader>Tt', function() neotest().run.run() end, desc = 'Test: Run nearest' },
    { '<Leader>Tf', function() neotest().run.run(vim.fn.expand('%')) end, desc = 'Test: Run file' },
    { '<Leader>Ta', function() neotest().run.run(vim.uv.cwd()) end, desc = 'Test: Run all' },
    { '<Leader>Td', function() neotest().run.run({ strategy = 'dap' }) end, desc = 'Test: Debug nearest' },
    { '<Leader>Tl', function() neotest().run.run_last() end, desc = 'Test: Run last' },
    { '<Leader>Tw', function() neotest().watch.toggle(vim.fn.expand('%')) end, desc = 'Test: Watch file' },
    { '<Leader>TS', function() neotest().run.stop() end, desc = 'Test: Stop' },
    { '<Leader>Ts', function() neotest().summary.toggle() end, desc = 'Test: Summary' },
    { '<Leader>To', function() neotest().output.open({ enter = true, auto_close = true }) end, desc = 'Test: Output' },
    { '<Leader>TO', function() neotest().output_panel.toggle() end, desc = 'Test: Output panel' },
    { ']T', function() neotest().jump.next({ status = 'failed' }) end, desc = 'Next failed test' },
    { '[T', function() neotest().jump.prev({ status = 'failed' }) end, desc = 'Previous failed test' },
  },
  opts = function()
    local vitest = require('neotest-vitest')({
      filter_dir = function(name) return name ~= 'node_modules' end,
    })
    vitest.root = root_if_uses('vitest')
    local jest = require('neotest-jest')
    jest.root = root_if_uses('jest')

    return {
      adapters = { vitest, jest },
      status = { virtual_text = true },
      output = { open_on_run = false },
      quickfix = { open = false },
    }
  end,
}
