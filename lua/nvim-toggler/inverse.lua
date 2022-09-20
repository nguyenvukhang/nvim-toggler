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

-- m - mode
-- i - inverse
local toggle = function(m, i)
  if u.assert(i, u.err.UNSUPPORTED_VALUE) then
    -- execute the toggle
    vim.cmd(m .. i)
  end
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
  -- get word under cursor
  Keys.load()
  local i = Inverse.list[vim.fn.expand('<cword>')]
  if not i then
    Keys.reset()
    i = Inverse.list[vim.fn.expand('<cword>')]
    toggle(m, i)
  else
    toggle(m, i)
    Keys.reset()
  end
end

return Inverse
