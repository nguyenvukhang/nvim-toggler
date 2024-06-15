vim.g.mapleader = ' '
vim.keymap.set('n', '<space>', '<nop>')

local clear_package = function()
  local all_packages = vim.tbl_keys(package.loaded)
  local related_packages = vim.tbl_filter(
    function(p) return vim.startswith(p, 'nvim-toggler') end,
    all_packages
  )
  vim.tbl_map(function(p)
    package.loaded[p] = nil -- unload it
  end, related_packages)
end
clear_package()
require('nvim-toggler').setup({
  inverses = {
    ['true'] = 'false',
    ['ru'] = 'fase',
  },
})

-- asserts that `received` == `expected`, and prints a pretty
-- assertion message with titled with `desc`.
local assert_eq = function(received, expected, desc)
  if received ~= expected then
    print(desc)
    print('received:', received)
    print('expected:', expected)
  end
  return received == expected
end

-- useful power-tool
local P = function(x) print(vim.inspect(x)) end

local test = { title = '', _config = {}, count = 0 }
local summary = setmetatable({
  ok = true,
  ran = false,
  update = function(self, result)
    self.ran = true
    self.ok = self.ok and result
  end,
}, {
  __call = function(self)
    if self.ok then
      print('[test.lua] all ok!\n')
    else
      print('[test.lua] some tests failed.\n')
    end
  end,
})

-- sets the inverses only (with override)
test.inverses = function(self, inverses)
  self._config = { remove_default_inverses = true, inverses = inverses }
end

-- sets the entire config as if called with require('nvim-toggler').setup()
test.setup = function(self, config) self._config = config end

test.run = function(self, start_state, cursor_pos)
  vim.api.nvim_set_current_line(start_state or '')
  vim.cmd('norm! ' .. cursor_pos .. '|')
  local nt = require('nvim-toggler')
  nt.reset()
  nt.setup(self._config)
  nt.toggle()
  return vim.api.nvim_get_current_line()
end

test.assert_mirror = function(self, a, b)
  if self:assert(a, b, 1) then self:assert(b, a, 1) end
end

test.assert = function(self, start_state, expected, cursor_pos)
  self.count = self.count + 1
  local title = ('%s, %d'):format(self.title, self.count)
  local result = assert_eq(self:run(start_state, cursor_pos), expected, title)
  summary:update(result)
  return result
end

test = setmetatable(test, {
  __call = function(self, title)
    self:setup()
    self.title = title
    self.count = 0
  end,
})

local function stable()
  -- ensures that a default actually exists
  test('Default true <-> false toggle exists')
  assert(test._config == nil)
  test:assert_mirror('true', 'false')

  test('Base override check')
  test:inverses({ ['vertical'] = 'horizontal' })
  test:assert_mirror('vertical', 'horizontal')

  test('Override existing pair')
  test:setup({ inverses = { ['true'] = 'maybe' } })
  test:assert_mirror('true', 'maybe')

  test('Override existing pair (inverted)')
  test:setup({ inverses = { ['maybe'] = 'true' } })
  test:assert_mirror('true', 'maybe')

  test('Default clipboard not polluted')
  test:inverses({ ['true'] = 'false' })
  vim.fn.setreg('"', 'clean')
  test:assert_mirror('true', 'false')
  assert_eq(vim.fn.getreg('"'), 'clean', test.title)

  test('Clustered inverses')
  test:inverses({ ['foo'] = 'bar' })
  test:assert('foobarfoo', 'barbarfoo', 3)
  test:assert('foobarfoo', 'foofoofoo', 4)
  test:assert('foobarfoo', 'foofoofoo', 5)
  test:assert('foobarfoo', 'foofoofoo', 6)
  test:assert('foobarfoo', 'foobarbar', 7)

  test('Clustered inverses with symbols')
  test:inverses({ ['!='] = '==', ['true'] = 'false' })
  test:assert('true!=false', 'false!=false', 4)
  test:assert('true!=false', 'true==false', 5)
  test:assert('true!=false', 'true==false', 6)
  test:assert('true!=false', 'true!=true', 7)

  test('Inverses with spaces')
  test:inverses({ ['check yes'] = 'juliet are' })
  test:assert('check yes you', 'juliet are you', 4)

  test('Toggle checkboxes')
  test:inverses({ ['- [ ]'] = '- [x]' })
  test:assert('- [ ] Buy milk', '- [x] Buy milk', 1)
  test:assert('- [ ] Buy milk', '- [x] Buy milk', 2)
  test:assert('- [ ] Buy milk', '- [x] Buy milk', 3)
  test:assert('- [ ] Buy milk', '- [x] Buy milk', 4)
  test:assert('- [ ] Buy milk', '- [x] Buy milk', 5)
  test:assert('- [ ] Buy milk', '- [ ] Buy milk', 6)

  test('LaTeX bug')
  test:inverses({ ['true'] = 'false' })
  test:assert('\\iffalse', '\\iftrue', 4)
  test:assert('\\iftrue', '\\iffalse', 4)
  test:assert('\\iftrue', '\\iffalse', 7)
  test:assert('\\iffalse', '\\iftrue', 6)

  test('Substring of inverse')
  test:inverses({ ['shift'] = 'unshift' })
  test:assert('\\shift', '\\unshift', 4)
  test:assert('\\unshift', '\\shift', 2)
  test:assert('\\unshift', '\\shift', 3)

  -- FAILING: this triggers a user interaction due to the ambiguity.
  -- test:assert('\\unshift', '\\shift', 4)
end

local function experimental() end

-- check with manual testing
-- test('Multiple matches')
-- test:inverses({ ['true'] = 'false', ['ru'] = 'falslyfalse' })
-- test:assert('foo true bar', 'foo true bar', 6)

stable()
experimental()
summary()
