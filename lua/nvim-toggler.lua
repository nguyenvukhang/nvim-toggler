local log = {}
local banner = function(msg) return '[nvim-toggler] ' .. msg end
function log.warn(msg) vim.notify(banner(msg), vim.log.levels.WARN) end
function log.once(msg) vim.notify_once(banner(msg), vim.log.levels.WARN) end
function log.echo(msg) vim.api.nvim_echo({ { banner(msg), 'None' } }, false, {}) end

local defaults = {
  word_cycles = {
    {'up', 'down', 'left', 'right'},
  },
  inverses = {
    ['true'] = 'false',
    ['True'] = 'False',
    ['yes'] = 'no',
    ['on'] = 'off',
    ['enable'] = 'disable',
    ['!='] = '==',
  },
  opts = {
    remove_default_keybinds = false,
    remove_default_inverses = false,
    autoselect_longest_match = false,
  },
}

---@param str string
---@param byte integer
---@return boolean
local function contains_byte(str, byte)
  for i = 1, #str do
    if str:byte(i) == byte then return true end
  end
  return false
end

---@param line string
---@param word string
---@param c_pos integer
---@return integer|nil, integer|nil
local function surround(line, word, c_pos)
  local w, W = 0, #word
  local l, L = math.max(c_pos - #word, 0), math.min(c_pos + #word, #line)
  while w < W and l < L do
    local _w, _l = word:byte(w + 1), line:byte(l + 1)
    w, l = _w == _l and w + 1 or word:byte(1) == _l and 1 or 0, l + 1
  end
  if w == W then return l - w + 1, l end
end

local inv_tbl = { data = {} }

function inv_tbl:reset()
  self.data = {}
end

-- Adds word lists to the inv_tbl.
-- Each word in the list will be mapped to its next word in the list.
function inv_tbl:add(tbl, verbose)
  for _, word_list in ipairs(tbl or {}) do
    for i, word in ipairs(word_list) do
      local next_word = word_list[i % #word_list + 1]
      if not self.data[word] then
        self.data[word] = next_word
      elseif verbose then
        log.once('conflicts found in inverse config.')
      end
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
    if contains_byte(word, byte) then
      local lo, hi = surround(line, word, cursor)
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
  -- handle multiple results (`results` is guaranteed >= 2 entries from here)
  table.sort(results, function(a, b) return #a.word > #b.word end)
  if
    #results[1].word > #results[2].word and app.opts.autoselect_longest_match
  then
    return app.sub(line, results[1])
  end
  local prompt, fmt = {}, '[%d] %s -> %s'
  for i, result in ipairs(results) do
    table.insert(prompt, fmt:format(i, result.word, result.inverse))
  end
  table.insert(prompt, '[?] > ')
  local input = vim.fn.input(table.concat(prompt, '\n'))
  vim.cmd('redraw!')
  if input == nil or input == '' then return log.echo('nothing happened.') end
  local result = results[input:byte(1) - 48]
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
  self.inv_tbl:reset()
  
  -- First add inverses (legacy format)
  if opts and opts.inverses then
    local cycles = {}
    for k, v in pairs(opts.inverses) do
      table.insert(cycles, {k, v})
    end
    self.inv_tbl:add(cycles, true)
  end
  
  -- Then add word_cycles, which will overwrite any conflicts
  if opts and opts.word_cycles then
    self.inv_tbl:add(opts.word_cycles, true)
  end
  
  if not self.opts.remove_default_inverses then
    -- Add default inverses first
    local cycles = {}
    for k, v in pairs(defaults.inverses) do
      table.insert(cycles, {k, v})
    end
    self.inv_tbl:add(cycles)
    
    -- Then add default word_cycles, which will overwrite any conflicts
    self.inv_tbl:add(defaults.word_cycles)
  end
  
  if not self.opts.remove_default_keybinds then
    vim.keymap.set(
      { 'n', 'v' },
      '<leader>i',
      function() self:toggle() end,
      { silent = true }
    )
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
