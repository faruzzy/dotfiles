-- Headless checks for this config, run by tests/run (which sets up a scratch directory and
-- state dir, and opens first.lua as the startup file). Each check prints PASS, FAIL or SKIP;
-- SKIP means a tool the check needs isn't installed on this machine.
--
-- Add a check when fixing a regression, so it stays fixed.

local results = { pass = 0, fail = 0, skip = 0 }
local filter = vim.env.CHECK_FILTER or ''

local function out(line) io.stdout:write(line .. '\n') end

---@param name string
---@param fn fun(skip: fun(reason: string))
local function check(name, fn)
  if filter ~= '' and not name:find(filter, 1, true) then return end
  local skipped
  local ok, err = pcall(fn, function(reason)
    skipped = reason
    error('__skip__', 0)
  end)
  if skipped then
    results.skip = results.skip + 1
    out(('SKIP %s (%s)'):format(name, skipped))
  elseif ok then
    results.pass = results.pass + 1
    out('PASS ' .. name)
  else
    results.fail = results.fail + 1
    out(('FAIL %s: %s'):format(name, tostring(err)))
  end
  -- Each check starts from a clean slate
  pcall(vim.cmd, 'silent! %bwipeout!')
end

local function write(path, lines)
  vim.fn.mkdir(vim.fs.dirname(path), 'p')
  vim.fn.writefile(type(lines) == 'string' and vim.split(lines, '\n') or lines, path)
end

local function edit(path)
  vim.cmd.edit(vim.fn.fnameescape(path))
  return vim.api.nvim_get_current_buf()
end

local function wait_client(buf, name, timeout)
  return vim.wait(timeout, function() return #vim.lsp.get_clients({ bufnr = buf, name = name }) > 0 end, 100)
end

local function feed(keys)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), 'mx', false)
end

local function has_injection(buf, lang)
  local parser = vim.treesitter.get_parser(buf)
  parser:parse(true)
  for _, child in pairs(parser:children()) do
    if child:lang() == lang and #child:trees() > 0 then return true end
  end
  return false
end

local function executable(cmd) return vim.fn.executable(cmd) == 1 end

local function run_checks()
  -- Read before any check runs: each one wipes all buffers when it finishes
  local first_buf = vim.fn.bufnr('first.lua')
  local first_ft = vim.bo[first_buf].filetype
  local first_highlighted = vim.treesitter.highlighter.active[first_buf] ~= nil
  local startup_messages = vim.api.nvim_exec2('messages', { output = true }).output

  check('startup: no errors in :messages', function()
    local errors = vim.tbl_filter(
      function(line) return line:match('E%d+:') or line:match('[Ee]rror') end,
      vim.split(startup_messages, '\n')
    )
    assert(#errors == 0, table.concat(errors, ' | '))
  end)

  -- Regression: sessions sourced inside VimEnter left the first buffer without its FileType
  check('treesitter: first file gets its filetype and highlighting', function()
    assert(first_ft == 'lua', 'filetype is ' .. first_ft)
    assert(first_highlighted, 'no treesitter highlighter')
  end)

  check('lsp: lua_ls attaches', function(skip)
    if not executable('lua-language-server') then skip('lua-language-server not installed') end
    local buf = edit('first.lua')
    assert(wait_client(buf, 'lua_ls', 15000), 'lua_ls did not attach')
  end)

  check('lsp: tsgo attaches to a loose .ts file', function(skip)
    if not executable('tsgo') then skip('tsgo not on PATH') end
    write('ts/app.ts', 'export const answer: number = 42')
    local buf = edit('ts/app.ts')
    assert(wait_client(buf, 'tsgo', 20000), 'tsgo did not attach')
  end)

  -- Ruby LSP only indexes *.rb by default; scripts are matched by their shebang
  check('lsp: ruby_lsp attaches to an extensionless ruby script', function(skip)
    if not executable('ruby-lsp') then skip('ruby-lsp not installed') end
    write('bin/tool', { '#!/usr/bin/env ruby', 'puts "hi"' })
    local buf = edit('bin/tool')
    assert(vim.bo[buf].filetype == 'ruby', 'filetype is ' .. vim.bo[buf].filetype)
    -- The first start builds a small bundle, which takes a few seconds
    assert(wait_client(buf, 'ruby_lsp', 30000), 'ruby_lsp did not attach')
  end)

  check('treesitter: SQL inside Prisma raw queries (ts, tsx, js)', function(skip)
    if not pcall(vim.treesitter.language.add, 'sql') then skip('sql parser not installed') end
    local ts = {
      'const rows = await prisma.$queryRaw<{ id: number }[]>`SELECT id FROM users`;',
      'await prisma.$executeRawUnsafe("DELETE FROM users");',
    }
    for _, file in ipairs({ 'sql/a.ts', 'sql/a.tsx' }) do
      write(file, ts)
      assert(has_injection(edit(file), 'sql'), 'no sql injection in ' .. file)
    end
    write('sql/a.js', 'const rows = await prisma.$queryRaw`SELECT id FROM users`;')
    assert(has_injection(edit('sql/a.js'), 'sql'), 'no sql injection in a.js')
  end)

  check('textobjects: iv/ik (various-textobjs) and ax (treesitter)', function()
    write('obj/a.ts', { 'const config = {', '  timeout: 5000,', '};' })
    edit('obj/a.ts')
    vim.api.nvim_win_set_cursor(0, { 2, 0 })
    feed('civ9000<Esc>')
    assert(vim.fn.getline(2) == '  timeout: 9000,', 'civ: ' .. vim.fn.getline(2))
    vim.api.nvim_win_set_cursor(0, { 2, 0 })
    feed('cikdelay<Esc>')
    assert(vim.fn.getline(2) == '  delay: 9000,', 'cik: ' .. vim.fn.getline(2))

    write('obj/b.tsx', 'const B = () => <button className="x" disabled>go</button>;')
    edit('obj/b.tsx')
    vim.api.nvim_win_set_cursor(0, { 1, 28 })
    feed('dax')
    assert(not vim.fn.getline(1):find('className'), 'dax: ' .. vim.fn.getline(1))
  end)

  -- Regression: both adapters rooted at any package.json, so jest files could run under vitest
  check('neotest: jest and vitest only claim projects that use them', function()
    write('jest/package.json', '{ "devDependencies": { "jest": "^29.0.0" } }')
    write('vitest/package.json', '{ "devDependencies": { "vitest": "^3.0.0" } }')
    require('neotest')
    local adapters = {}
    for _, adapter in ipairs(require('neotest.config').adapters) do
      adapters[adapter.name] = adapter
    end
    local jest, vitest = assert(adapters['neotest-jest'], 'no jest adapter'), assert(adapters['neotest-vitest'])
    local jest_dir, vitest_dir = vim.fn.getcwd() .. '/jest', vim.fn.getcwd() .. '/vitest'
    assert(jest.root(jest_dir) == jest_dir, 'jest does not claim the jest project')
    assert(not jest.root(vitest_dir), 'jest claims the vitest project')
    assert(vitest.root(vitest_dir) == vitest_dir, 'vitest does not claim the vitest project')
    assert(not vitest.root(jest_dir), 'vitest claims the jest project')
  end)

  check('dap: JavaScript adapter points at an installed js-debug-adapter', function(skip)
    local adapter = require('dap').adapters['pwa-node']
    assert(adapter, 'no pwa-node adapter')
    if not executable(adapter.executable.command) then skip('js-debug-adapter not installed') end
  end)

  check('autocmd: :w creates missing parent folders', function()
    vim.cmd.edit('new/nested/dir/file.txt')
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'x' })
    vim.cmd('silent write')
    assert(vim.uv.fs_stat('new/nested/dir/file.txt'), 'file was not written')
  end)

  -- CLAUDE.md: a mapping that is also the prefix of others waits 'timeoutlen' before firing
  check('keymaps: no normal-mode <Leader> mapping is the prefix of another', function()
    local leader = vim.g.mapleader or '\\'
    local lhss = {}
    for _, map in ipairs(vim.api.nvim_get_keymap('n')) do
      if vim.startswith(map.lhs, leader) and #map.lhs > #leader then lhss[map.lhs] = true end
    end
    local clashes = {}
    for lhs in pairs(lhss) do
      for other in pairs(lhss) do
        if other ~= lhs and vim.startswith(other, lhs) then
          table.insert(clashes, vim.fn.keytrans(lhs) .. ' < ' .. vim.fn.keytrans(other))
          break
        end
      end
    end
    table.sort(clashes)
    assert(#clashes == 0, table.concat(clashes, ', '))
  end)

  check('lazy-lock.json is valid JSON', function()
    local path = vim.fn.stdpath('config') .. '/lazy-lock.json'
    local ok, err = pcall(vim.json.decode, table.concat(vim.fn.readfile(path), '\n'))
    assert(ok, err)
  end)

  out(('\n%d passed, %d failed, %d skipped'):format(results.pass, results.fail, results.skip))
  -- tsgo and ruby-lsp exit with code 1 even on a clean shutdown, and Neovim reports it after
  -- the summary; nothing is checked past this point, so silence it
  vim.notify = function() end
  vim.cmd(('cquit %d'):format(results.fail > 0 and 1 or 0))
end

-- After startup has settled: VimEnter, plus the scheduled session restore and VeryLazy plugins
vim.api.nvim_create_autocmd('VimEnter', {
  once = true,
  callback = function() vim.defer_fn(run_checks, 500) end,
})
