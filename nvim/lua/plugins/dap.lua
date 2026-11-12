-- Debugger for JavaScript/TypeScript (Rust gets its adapter from rustaceanvim). The adapter is
-- vscode-js-debug, installed by Mason as js-debug-adapter (see plugins/lsp.lua); neotest's
-- <Leader>Td debugs a test through it
local function dap() return require('dap') end

local js_filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' }

return {
  {
    'mfussenegger/nvim-dap',
    dependencies = { 'rcarriga/nvim-dap-ui' },
    keys = {
      { '<Leader>Db', function() dap().toggle_breakpoint() end, desc = 'Debug: Toggle breakpoint' },
      {
        '<Leader>DB',
        function() dap().set_breakpoint(vim.fn.input('Condition: ')) end,
        desc = 'Debug: Conditional breakpoint',
      },
      { '<Leader>Dc', function() dap().continue() end, desc = 'Debug: Start / continue' },
      { '<Leader>Dl', function() dap().run_last() end, desc = 'Debug: Run last' },
      { '<Leader>Dn', function() dap().step_over() end, desc = 'Debug: Step over' },
      { '<Leader>Di', function() dap().step_into() end, desc = 'Debug: Step into' },
      { '<Leader>Do', function() dap().step_out() end, desc = 'Debug: Step out' },
      { '<Leader>DC', function() dap().run_to_cursor() end, desc = 'Debug: Run to cursor' },
      { '<Leader>Dt', function() dap().terminate() end, desc = 'Debug: Terminate' },
      { '<Leader>Dr', function() dap().repl.toggle() end, desc = 'Debug: REPL' },
      { '<Leader>Du', function() require('dapui').toggle() end, desc = 'Debug: Toggle UI' },
      { '<Leader>De', function() require('dapui').eval() end, mode = { 'n', 'x' }, desc = 'Debug: Evaluate' },
    },
    config = function()
      local d = dap()

      d.adapters['pwa-node'] = {
        type = 'server',
        host = 'localhost',
        port = '${port}',
        executable = {
          command = vim.fn.stdpath('data') .. '/mason/bin/js-debug-adapter',
          args = { '${port}' },
        },
      }

      local configs = {
        {
          name = 'Launch file',
          type = 'pwa-node',
          request = 'launch',
          -- Node 22.18+ runs .ts files directly by stripping the types
          program = '${file}',
          cwd = '${workspaceFolder}',
          sourceMaps = true,
        },
        {
          name = 'Attach to process',
          type = 'pwa-node',
          request = 'attach',
          processId = function() return require('dap.utils').pick_process({ filter = 'node' }) end,
          cwd = '${workspaceFolder}',
          sourceMaps = true,
        },
      }
      for _, ft in ipairs(js_filetypes) do
        d.configurations[ft] = configs
      end

      local sign = vim.fn.sign_define
      sign('DapBreakpoint', { text = '\u{f111}', texthl = 'DiagnosticError' })
      sign('DapBreakpointCondition', { text = '\u{f192}', texthl = 'DiagnosticWarn' })
      sign('DapBreakpointRejected', { text = '\u{f05e}', texthl = 'DiagnosticHint' })
      sign('DapLogPoint', { text = '\u{f075}', texthl = 'DiagnosticInfo' })
      sign('DapStopped', { text = '\u{f0da}', texthl = 'DiagnosticOk', linehl = 'Visual' })

      -- The UI opens when a session starts and closes when it ends
      local dapui = require('dapui')
      dapui.setup()
      d.listeners.after.event_initialized.dapui = dapui.open
      d.listeners.before.event_terminated.dapui = dapui.close
      d.listeners.before.event_exited.dapui = dapui.close
    end,
  },
  {
    'rcarriga/nvim-dap-ui',
    lazy = true,
    dependencies = { 'nvim-neotest/nvim-nio' },
  },
}
