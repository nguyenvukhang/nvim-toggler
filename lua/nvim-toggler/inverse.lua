local Keys = require('nvim-toggler.keys')
local Inverse = { list = {} }

Inverse.update = function(list)
  Inverse.list = vim.tbl_extend(
    'force',
    Inverse.list,
    vim.tbl_add_reverse_lookup(list or {})
  )
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
  if not Keys.is_keyword(ch) then
    print('toggler: unsupported value.')
    return
  end
  Keys.load()
  local i = vim.tbl_get(Inverse.list, vim.fn.expand('<cword>'))
  xpcall(function()
    vim.cmd(vim.tbl_get(c, vim.api.nvim_get_mode().mode) .. i)
  end, function()
    print('toggler: unsupported value.')
  end)
  Keys.reset()
end

return Inverse
