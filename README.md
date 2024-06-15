# nvim-toggler

Invert text in vim, purely with lua.

![demo](https://user-images.githubusercontent.com/10664455/185724246-f7165f38-6058-46f3-809b-d55cf09255e3.gif)

[Install](#install)
&nbsp;&middot;&nbsp;
[Run](#run)
&nbsp;&middot;&nbsp;
[Custom inverses](#custom-inverses)
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

Once that is set, the default binding is `<leader>i` to invert the
word under your cursor.

## Custom inverses

You can configure `nvim-toggler` with the `setup()` function:

```lua
-- init.lua
require('nvim-toggler').setup({
  -- your own inverses
  inverses = {
    ['vim'] = 'emacs'
  },
  -- removes the default <leader>i keymap
  remove_default_keybinds = true,
  -- removes the default set of inverses
  remove_default_inverses = true,
  -- auto-selects the longest match when there are multiple matches
  autoselect_longest_match = false
})
```

## Custom keymaps

To map toggling to something else like `<leader>cl`, simply do

```lua
-- init.lua
vim.keymap.set({ 'n', 'v' }, '<leader>cl', require('nvim-toggler').toggle)
```

[packer]: https://github.com/wbthomason/packer.nvim
[vim-plug]: https://github.com/junegunn/vim-plug
