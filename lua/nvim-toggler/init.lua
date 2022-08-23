local Inverse = require('nvim-toggler.inverse')

local default_opts = {
  inverses = {
    ['true'] = 'false',
    ['yes'] = 'no',
    ['on'] = 'off',
    ['left'] = 'right',
    ['up'] = 'down',
    ['!='] = '==',
  },
  remove_default_keybinds = false,
}

local setup = function(opts)
  opts = vim.tbl_deep_extend('force', default_opts, opts or {})
  Inverse.update(opts.inverses or {})
  if not opts.remove_default_keybinds then
    vim.keymap.set(
      { 'n', 'v' },
      '<leader>i',
      Inverse.toggle,
      { noremap = true, silent = true }
    )
  end
end

return { setup = setup, toggle = Inverse.toggle }
