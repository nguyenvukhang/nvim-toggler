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
require('nvim-toggler')
```

```vim
" init.vim or .vimrc
lua << EOF
require('nvim-toggler')
EOF
```

Once that is set, the default binding is `<leader>i` to invert the
word under your cursor.

## Custom inverses

You can specify custom togglables with the `setup()` function:

```lua
-- init.lua
require('nvim-toggler').setup({
  global_inversions = {
   ['vim'] = 'emacs'
   ['=='] = '!='
  },
  filetype_inversions = {  -- overwrite inversions in specific filetypes
    lua = {
      ['=='] = '~='
    }
  }
})
```

The defaults are defined in [the one and only lua file][source]

## Custom keymaps

To remap toggling to something else like `<leader>cl`, simply do

```lua
-- init.lua
vim.keymap.set({ 'n', 'v' }, '<leader>cl', require('nvim-toggler').toggle)
```

[source]: https://github.com/nguyenvukhang/nvim-toggler/blob/main/lua/nvim-toggler.lua
[packer]: https://github.com/wbthomason/packer.nvim
[vim-plug]: https://github.com/junegunn/vim-plug
