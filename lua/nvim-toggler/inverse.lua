local Keys = require('nvim-toggler.keys')
local Inverse = { list = {} }

Inverse.update = function(list)
  Inverse.list = vim.tbl_extend(
    'force',
    Inverse.list,
    vim.tbl_add_reverse_lookup(list or {})
  )
  local u = {}
  for k in pairs(Inverse.list) do
    k:gsub('.', function(c)
      u[c] = true
    end)
  end
  for c in pairs(u) do
    Keys.add_char(c)
  end
  Keys.update_keys()
end

local c = {
  ['n'] = 'norm! ciw',
  ['v'] = 'norm! c',
}

Inverse.toggle = function()
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
