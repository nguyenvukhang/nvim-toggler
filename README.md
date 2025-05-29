# nvim-toggler

Toggle text in vim, purely with lua.

![demo](https://user-images.githubusercontent.com/10664455/185724246-f7165f38-6058-46f3-809b-d55cf09255e3.gif)

[Install](#install)
&nbsp;&middot;&nbsp;
[Run](#run)
&nbsp;&middot;&nbsp;
[Configuration](#configuration)
&nbsp;&middot;&nbsp;
[Custom keymaps](#custom-keymaps)

## Install

Using [packer.nvim][packer]

```lua
use { 'nguyenvukhang/nvim-toggler' }
```

Using [vim-plug][vim-plug]

```vim
Plug 'nguyenvukhang/nvim-toggler'
```

## Run

```lua
-- init.lua
require('nvim-toggler').setup()
```

```vim
" init.vim or .vimrc
lua << EOF
require('nvim-toggler').setup()
EOF
```

Once that is set, the default binding is `<leader>i` to toggle the
word under your cursor.

## Configuration

You can configure `nvim-toggler` with the `setup()` function:

```lua
-- init.lua
require('nvim-toggler').setup({
  -- Word cycles (new format)
  word_cycles = {
    {'up', 'down', 'left', 'right'},  -- Cycle through directions
    {'true', 'false', 'maybe'},       -- Cycle through boolean states
  },
  
  -- Inverses (legacy format, still supported)
  inverses = {
    ['vim'] = 'emacs',
    ['yes'] = 'no'
  },
  
  -- removes the default <leader>i keymap
  remove_default_keybinds = true,
  
  -- removes the default set of inverses and word cycles
  remove_default_inverses = true,
  
  -- auto-selects the longest match when there are multiple matches
  autoselect_longest_match = false
})
```

### Word Cycles

The new `word_cycles` format allows you to define groups of related words that cycle through each other. For example:

```lua
word_cycles = {
  {'up', 'down', 'left', 'right'},  -- When on 'up', toggles to 'down', then 'left', then 'right', then back to 'up'
  {'true', 'false', 'maybe'},       -- Cycles through boolean states
}
```

### Legacy Inverses

The legacy `inverses` format is still supported for backward compatibility:

```lua
inverses = {
  ['vim'] = 'emacs',  -- Toggles between 'vim' and 'emacs'
  ['yes'] = 'no'      -- Toggles between 'yes' and 'no'
}
```

## Custom keymaps

To map toggling to something else like `<leader>cl`, simply do

```lua
-- init.lua
vim.keymap.set({ 'n', 'v' }, '<leader>cl', require('nvim-toggler').toggle)
```

[packer]: https://github.com/wbthomason/packer.nvim
[vim-plug]: https://github.com/junegunn/vim-plug
