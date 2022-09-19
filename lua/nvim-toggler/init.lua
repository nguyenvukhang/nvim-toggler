local Inverse = require('nvim-toggler.inverse')
local u = require('nvim-toggler.utils')

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
  opts = opts or {}
  -- read flat (non-nested) options
  local flat_opts = vim.tbl_extend('force', default_opts, opts)
  -- handle inverses
  local user_inverses = opts.inverses or {}
  if flat_opts.remove_default_inverses then
    default_opts.inverses = {}
  end
  local inverses = u.merge(default_opts.inverses, user_inverses)
  Inverse.update(inverses)
  -- set keybinds
  if not flat_opts.remove_default_keybinds then
    vim.keymap.set({ 'n', 'v' }, '<leader>i', Inverse.toggle, { silent = true })
  end
end

return { setup = setup, toggle = Inverse.toggle }
