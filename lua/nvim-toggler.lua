local log = {}
local banner = function(msg) return '[nvim-toggler] ' .. msg end
function log.warn(msg) vim.notify(banner(msg), vim.log.levels.WARN) end
function log.once(msg) vim.notify_once(banner(msg), vim.log.levels.WARN) end
function log.echo(msg) vim.api.nvim_echo({ { banner(msg), 'None' } }, false, {}) end

local defaults = {
  inverses = {
    ['true'] = 'false',
    ['yes'] = 'no',
    ['on'] = 'off',
    ['left'] = 'right',
    ['up'] = 'down',
    ['!='] = '==',
  },
  opts = {
    remove_default_keybinds = false,
    remove_default_inverses = false,
  },
}

function string:contains_byte(byte)
  for i = 1, self:len() do
    if self:byte(i) == byte then return true end
  end
  return false
end

function string:surround(query, cursor)
  local len_b, len_s = query:len(), math.min(cursor + #query, self:len())
  local b, s = 0, math.max(cursor - #query, 0)
  while b < len_b and s < len_s do
    b = query:byte(b + 1) == self:byte(s + 1) and b + 1 or 0
    s = s + 1
  end
  if b == len_b then return s - b + 1, s end
end

local inv_tbl = { data = {}, hash = {} }

function inv_tbl:reset()
  self.hash, self.data = {}, {}
end

-- Adds unique key-value pairs to the inv_tbl.
--
-- If either the `key` or the `value` is found to be already in
-- `inv_tbl`, then the `key`-`value` pair will not be added.
function inv_tbl:add(tbl, verbose)
  for k, v in pairs(tbl or {}) do
    if not self.hash[k] and not self.hash[v] then
      self.data[k], self.data[v], self.hash[k], self.hash[v] = v, k, true, true
    elseif verbose then
      log.once('conflicts found in inverse config.')
    end
  end
end

local app = { inv_tbl = inv_tbl, opts = {} }

function app:load_opts(opts)
  opts = opts or {}
  for k in pairs(defaults.opts) do
    if type(opts[k]) == type(defaults.opts[k]) then
      self.opts[k] = opts[k]
    elseif opts[k] ~= nil then
      log.once('incorrect type found in config.')
    end
  end
end

function app.sub(line, result)
  local lo, hi, inverse = result.lo, result.hi, result.inverse
  line = table.concat({ line:sub(1, lo - 1), inverse, line:sub(hi + 1) }, '')
  return vim.api.nvim_set_current_line(line)
end

-- `word` is the string to be replaced
-- `inverse` is the string that will replace `word`
--
-- Toggle is executed on the first keyword found such that
--   1. `word` contains the character under the cursor.
--   2. current line contains `word`.
--   3. cursor is on that `word` in the current line.
function app:toggle()
  local line, cursor = vim.fn.getline('.'), vim.fn.col('.')
  local byte = line:byte(cursor)
  local results = {}
  for word, inverse in pairs(self.inv_tbl.data) do
    if word:contains_byte(byte) then
      local lo, hi = line:surround(word, cursor)
      if lo and lo <= cursor and cursor <= hi then
        table.insert(
          results,
          { lo = lo, hi = hi, inverse = inverse, word = word }
        )
      end
    end
  end
  if #results == 0 then return log.warn('unsupported value.') end
  if #results == 1 then return self.sub(line, results[1]) end
  -- handle multiple results
  table.sort(results, function(a, b) return a.word < b.word end)
  local prompt, fmt = {}, '[%d] %s -> %s'
  for i, result in ipairs(results) do
    table.insert(prompt, fmt:format(i, result.word, result.inverse))
  end
  table.insert(prompt, '[?] > ')
  local result = results[vim.fn.input(table.concat(prompt, '\n')):byte(1) - 48]
  vim.cmd('redraw!')
  if result then
    app.sub(line, result)
    log.echo(('%s -> %s'):format(result.word, result.inverse))
  else
    log.echo('nothing happened.')
  end
end

function app:setup(opts)
  self:load_opts(defaults.opts)
  self:load_opts(opts)
  self.inv_tbl:add((opts or {}).inverses, true)
  if not self.opts.remove_default_inverses then
    self.inv_tbl:add(defaults.inverses)
  end
  if not self.opts.remove_default_keybinds then
    vim.keymap.set({ 'n', 'v' }, '<leader>i', self.toggle, { silent = true })
  end
end

return {
  setup = function(opts) app:setup(opts) end,
  toggle = function() app:toggle() end,
  reset = function()
    app.inv_tbl:reset()
    app.opts = {}
  end,
}
