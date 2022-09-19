local Keys = require('nvim-toggler.keys')
local u = require('nvim-toggler.utils')
local Inverse = { list = {} }

Inverse.update = function(list)
  list = vim.tbl_add_reverse_lookup(list or {})
  Inverse.list = vim.tbl_extend('force', Inverse.list, list)
  Keys.update(Inverse.list)
end

local c = {
  ['n'] = 'norm! ciw',
  ['v'] = 'norm! c',
}

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
  if u.assert(i, u.err.UNSUPPORTED_VALUE) then
    vim.cmd(m .. i)
  end
  Keys.reset()
end

return Inverse
