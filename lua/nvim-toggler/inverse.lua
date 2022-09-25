local Keys = require('nvim-toggler.keys')
local u = require('nvim-toggler.utils')
local Inverse = { list = {} }

Inverse.update = function(list)
  list = vim.tbl_add_reverse_lookup(list or {})
  Inverse.list = vim.tbl_extend('force', Inverse.list, list)
  Keys.update(Inverse.list)
end

local c = {
  ['n'] = 'norm! "_ciw',
  ['v'] = 'norm! "_c',
}

local contains = function(str, query)
  if string.find(str, query) then
    return true
  else
    return false
  end
end

-- m - mode
-- w - captured word under cursor
-- i - inverse
-- ch - character under cursor
--
-- doesn't toggle if `w` doesn't contain `ch`
local toggle = function(m, w, i, ch)
  if not u.assert(contains(w, ch), u.err.UNSUPPORTED_VALUE) then
    return
  end
  if u.assert(i, u.err.UNSUPPORTED_VALUE) then
    -- execute the toggle
    vim.cmd(m .. i)
  end
end

local invert = function()
  local w = vim.fn.expand('<cword>')
  local i = Inverse.list[w]
  return w, i
end

Inverse.toggle = function()
  -- check character under cursor
  local x = vim.fn.col('.')
  local ch = vim.fn.getline('.'):sub(x, x)
  if not u.assert(Keys.is_keyword(ch), u.err.UNSUPPORTED_VALUE) then
    return
  end
  -- get current mode
  local m = c[vim.api.nvim_get_mode().mode]
  if not u.assert(m, u.err.UNSUPPORTED_MODE) then
    return
  end
  -- attempt two toggles, with and without keys loaded
  Keys.load()
  local w, i = invert()
  if not i then
    Keys.reset()
    w, i = invert()
    toggle(m, w, i, ch)
  else
    toggle(m, w, i, ch)
    Keys.reset()
  end
end

return Inverse
