local log = {}
local banner = function(msg) return '[nvim-toggler] ' .. msg end
log.warn = function(msg) vim.notify(banner(msg), vim.log.levels.WARN) end
log.once =
  function(msg) vim.api.nvim_echo({ { banner(msg), 'None' } }, false, {}) end
log.text = {
  NO_OP = 'nothing happened.',
  UNSUPPORTED_VALUE = 'unsupported value.',
  DUPLICATE_INVERSE = 'conflicts found in inverse config.',
  BAD_CONFIG_TYPE = 'incorrect type found in config.',
}

-- looks for char in string
string.contains = function(self, char)
  local byte = char:byte(1)
  for i = 1, self:len() do
    if self:byte(i) == byte then return true end
  end
  return false
end

-- looks for character sequence in string
string.find_byte_sequence = function(self, char_seq, after_idx)
  local c_ptr, s_ptr = 0, after_idx - 1
  local cs_len, str_len = char_seq:len(), self:len()
  while c_ptr < cs_len and s_ptr < str_len do
    if char_seq:byte(c_ptr + 1) == self:byte(s_ptr + 1) then
      s_ptr, c_ptr = s_ptr + 1, c_ptr + 1
    else
      s_ptr = s_ptr + 1
      c_ptr = 0
    end
  end
  if c_ptr == cs_len then return s_ptr - c_ptr + 1, s_ptr end
end

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

local inv_tbl = { data = {}, hash = {} }

inv_tbl.reset = function(self)
  self.hash, self.data = {}, {}
end

-- Adds unique key-value pairs to the inv_tbl.
--
-- If either the `key` or the `value` is found to be already in
-- `inv_tbl`, then the `key`-`value` pair will not be added.
inv_tbl.add = function(self, tbl)
  for k, v in pairs(tbl or {}) do
    if not self.hash[k] and not self.hash[v] then
      self.data[k], self.data[v], self.hash[k], self.hash[v] = v, k, true, true
    else
      log.warn(log.text.DUPLICATE_INVERSE)
    end
  end
end

local app = { inv_tbl = inv_tbl, opts = {} }

app._reset = function(self)
  self.inv_tbl:reset()
  self.opts = {}
end
app.reset = function() app:_reset() end

app.load_opts = function(self, opts)
  opts = opts or {}
  for k in pairs(defaults.opts) do
    if type(opts[k]) == type(defaults.opts[k]) then
      self.opts[k] = opts[k]
    elseif opts[k] ~= nil then
      log.warn(log.text.BAD_CONFIG_TYPE)
    end
  end
end

---@class Packet
---index of the left-bound of the word found in line (inclusive)
---@field public lo number
---index of the right-bound of the word found in line (inclusive)
---@field public hi number
---@field public inverse string
---@field public word string

-- Executes the swap in-buffer
---@param packet Packet
app.sub = function(line, packet)
  local lo, hi, inverse = packet.lo, packet.hi, packet.inverse
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
app._toggle = function(self)
  local line, cursor = vim.fn.getline('.'), vim.fn.col('.')
  local char = vim.fn.nr2char(line:byte(cursor))
  local packets = {}
  for word, inverse in pairs(self.inv_tbl.data) do
    if word:contains(char) then
      local lo, hi =
        line:find_byte_sequence(word, math.max(cursor - #word + 1, 1))
      if lo and hi and lo <= cursor and cursor <= hi then
        table.insert(
          packets,
          { lo = lo, hi = hi, inverse = inverse, word = word }
        )
      end
    end
  end
  if #packets == 0 then return log.warn(log.text.UNSUPPORTED_VALUE) end
  if #packets == 1 then return app.sub(line, packets[1]) end
  return app.multi(line, packets)
end
app.toggle = function() app:_toggle() end

---@param line string
---@param packets table<Packet>
app.multi = function(line, packets)
  table.sort(packets, function(a, b) return a.word > b.word end)
  local prompt, format = {}, '[%d] %s -> %s'
  for i, packet in ipairs(packets) do
    table.insert(prompt, format:format(i, packet.word, packet.inverse))
  end
  table.insert(prompt, '[?] > ')
  local packet = packets[vim.fn.input(table.concat(prompt, '\n')):byte(1) - 48]
  vim.cmd('redraw!')
  if packet then
    app.sub(line, packet)
    log.once(('%s -> %s'):format(packet.word, packet.inverse))
  else
    log.once(log.text.NO_OP)
  end
end

app._setup = function(self, opts)
  self:load_opts(defaults.opts)
  self:load_opts(opts)
  self.inv_tbl:add((opts or {}).inverses)
  if not self.opts.remove_default_inverses then
    self.inv_tbl:add(defaults.inverses)
  end
  if not self.opts.remove_default_keybinds then
    vim.keymap.set({ 'n', 'v' }, '<leader>i', app.toggle, { silent = true })
  end
end
app.setup = function(opts) app:_setup(opts) end

return { setup = app.setup, toggle = app.toggle, reset = app.reset }
