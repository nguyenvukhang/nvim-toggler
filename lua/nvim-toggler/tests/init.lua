-- tests don't need these
vim.opt.swapfile = false
vim.opt.backup = false

-- set space as leader
vim.g.mapleader = ' '
vim.keymap.set('n', '<space>', '<nop>')

local starts_with = function(text, prefix)
  return text:find(prefix, 1, true) == 1
end

-- clears this package
local clear_package = function()
  for k, _ in pairs(package.loaded) do
    if starts_with(k, 'nvim-toggler') then
      package.loaded[k] = nil
    end
  end
end

clear_package()
pcall(function()
  -- source the test config file
  require('./config').setup()
end)
