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
  remove_default_inverses = false,
}

local setup = function(opts)
  -- read flat (non-nested) options
  local flat_opts = vim.tbl_extend('force', default_opts, opts or {})
  -- handle inverses
  local inverses = opts.inverses or {}
  if not flat_opts.remove_default_inverses then
    inverses = vim.tbl_extend('force', default_opts.inverses, inverses)
  end
  Inverse.update(inverses)
  -- set keybinds
  if not flat_opts.remove_default_keybinds then
    vim.keymap.set(
      { 'n', 'v' },
      '<leader>i',
      Inverse.toggle,
      { noremap = true, silent = true }
    )
  end
end

return { setup = setup, toggle = Inverse.toggle }
