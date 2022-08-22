local Inverse = require('nvim-toggler.inverse')
local Keys = require('nvim-toggler.keys')

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

local toggle = function()
  -- check character under cursor
  local x = vim.fn.col('.')
  local ch = vim.fn.getline('.'):sub(x, x)
  if not Keys.is_keyword(ch) then
    print("not keyword")
    return
  end
  -- toggle the word
  Inverse.toggle()
end

local setup = function(opts)
  opts = vim.tbl_extend('force', default_opts, opts or {})
  Inverse.update(opts.inverses or {})
  if not opts.remove_default_keybinds then
    vim.keymap.set(
      { 'n', 'v' },
      '<leader>i',
      toggle,
      { noremap = true, silent = true }
    )
  end
end

return { setup = setup, toggle = toggle }
