fazif allows you to search over selected items in Yazi with your configuration of search and fuzzy filter command.

You can config search command ([fd](https://github.com/sharkdp/fd), [rg](https://github.com/BurntSushi/ripgrep), [rga](https://github.com/phiresky/ripgrep-all), [ag](https://github.com/ggreer/the_silver_searcher), [astgrep](https://github.com/ast-grep/ast-grep) ...), fuzzy filter command ([fzf](https://github.com/junegunn/fzf), [fzy](https://github.com/jhawthorn/fzy), [zf](https://github.com/natecraddock/zf), [skim](https://github.com/lotabout/skim)), and options in a script and spawn all your scripts easily into yazi. Here are some use cases.

1. Search within the current working directory when none are selected.

For example, a simple directory jumper. Simply create a file in `~/.config/yazi/plugins/fazif.yazi` with one of the following, make it executable, and set a keybinding.

```
#!/usr/bin/env zsh
fd -H -t d|fzf
```

or

```
#!/usr/bin/env zsh
fd -H -t d|zf
```

or jump to a dir. outside CWD by applying your query to a upper dir. with a shortcut key.

```
#!/usr/bin/env zsh
fd -H -t d|fzf \
--bind 'ctrl-e:transform:echo "change-prompt(Home_Dir> )+reload(fd . ~ --hidden --type d)"' \
```

2. Search within selected files and directories

Example 1: to jump to some dir. in the selected folders, simply create a file in `~/.config/yazi/plugins/fazif.yazi` with one of the following, make it executable, and set a keybinding.


```
#!/usr/bin/env zsh
fd -H -t d "$@"|fzf
```

or

```
#!/usr/bin/env zsh
fd -H -t d "$@"|zf
```

Example 2: use `fazifrga` script to search for a pattern in selected PDFs and preview the matching pages that have the pattern with fzf.

3. Reveal the selected file or enter the selected directory in a new yazi tab; if multiple items are selected in fzf (using the `-multi` option in fzf), then show the selected items in the search result view.

For example, find relevant books using `faziffd` and reveal them in yazi's search result view, then use `fazifrga` to search for a pattern in these books.

4. show recent modified files.
```
#!/usr/bin/env zsh
fd -H -t f --changed-within 1d|fzf 
```
## How It Works

This plugin acts as a bridge between Yazi and standalone scripts. The main.lua file serves as a generic wrapper that:
1. Passes the current working directory and selected files/directories from Yazi (`"$@"` in the script) to the script
2. Executes the specified script (passed as an argument in the keymap)
3. Send results in Yazi search pane if multiple selected or reveal/enter the selected item in a yazi new tab

## Installation

1. Install via ya:

```bash
ya pkg -a Shallow-Seek/fazif
```

or

```bash
git clone https://github.com/Shallow-Seek/fazif.yazi.git ~/.config/yazi/plugins/fazif.yazi
```

2. The 3 default scripts `faziffd`, `fazifrg`, and `fazifrga` provided are examples with features shown in the next section. The plugin still works with your scripts without them.

Simple put your script in `~/.config/yazi/plugins/fazif.yazi` and set a keybinding to use them. To make your script search on selected items, just add `"$@"` to the search command.  Check `faziffd` to see that. 

Also you need change your `rg` or `rga`'s delimiter to `U+00A0` by adding the option `--field-match-separator $'\u00a0'`
to your `rg` or `rga` commmand and `--delimiter $'\u00a0'` option to `fzf`. See the default `fazifrg` as an example. 

but you can modify the following line in `main.lua` to use your prefered delimiter.

```lua
local file = line:find("\xC2\xA0") and line:sub(1, line:find("\xC2\xA0") - 1) or line
```

> UTF-8 encoding of `U+00A0` is `\xC2\xA0`

Make sure your scripts are executable:

```bash
chmod +x ~/.config/yazi/plugins/fazif.yazi/faziffd
chmod +x ~/.config/yazi/plugins/fazif.yazi/fazifrg
chmod +x ~/.config/yazi/plugins/fazif.yazi/fazifrga
chmod +x ~/.config/yazi/plugins/fazif.yazi/yourscript1
...
```
You may need to update the shebang (`#!`) in the example scripts.

## Add Keymaps to Your Script

The plugin can be configured to run any of your scripts by passing the script name as an argument. Add the following to your `~/.config/yazi/keymap.toml` to bind each script to a key combination:

### Setting up all scripts:

```toml
# File/Directory finder using fd + fzf
[[mgr.prepend_keymap]]
on = [ "b", "d" ]
run = "plugin fazif faziffd"
desc = "Find files/directories with fd and fzf"

# Content finder using ripgrep + fzf
[[mgr.prepend_keymap]]
on = [ "b", "r" ]
run = "plugin fazif fazifrg"
desc = "Find content in files with ripgrep and fzf"

# Document content finder using ripgrep-all + fzf
[[mgr.prepend_keymap]]
on = [ "b", "a" ]
run = "plugin fazif fazifrga"
desc = "Find content in documents with ripgrep-all and fzf"
...
```

That's it.  is not the default `:`, you will need to change the delimiter in main.lua.

---
## Example scripts 
Read this section if you use the default scripts `faziffd`, `fazifrg`, and `fazifrga`.

### Features

1. **faziffd** - File/directory jumper using `fd`. Txt preview with `bat` and Directory preview with `eza`
2. **fazifrg** - `ripgrep` on selected. Preview shows file content with `bat` when started with no input. With any input, `rg` kicks in, and the preview highlights the matching line.
3. **fazifrga** - `ripgrep-all`  search in selected PDFs and DjVu. Preview shows the first page of a document when started with no input. With any input, `rga` kicks in, and the preview shows the matching page in the document.
 
The 3 scripts use the following tools:

- [fzf](https://github.com/junegunn/fzf) 
- [fd](https://github.com/sharkdp/fd) - Used by `faziffd`
- [ripgrep](https://github.com/BurntSushi/ripgrep) - Used by `fazifrg`
- [ripgrep-all](https://github.com/phiresky/ripgrep-all) - Used by `fazifrga`
- [rga djvu adaptor](https://github.com/phiresky/ripgrep-all/discussions/166) - Used by `fazifrga` to search in djvu
- Additional tools for document previews:
  - [kitty](https://sw.kovidgoyal.net/kitty/) Image preview uses kitty icat. You can also use other terminals that support image or use ueberzugpp.
  - [bat](https://github.com/sharkdp/bat) - Used by `faziffd`, `fazifrg` 
  - [eza](https://github.com/eza-community/eza) - Used by `faziffd`
  - `pdftoppm` from [poppler-utils](https://github.com/freedesktop/poppler) - Used by `faziffd`, `fazifrga` for pdf prevew.
  - `ddjvu` from [djvulibre](https://github.com/DjVuLibre/djvulibre) - Used by `faziffd`, `fazifrga` for djvu preview.
  - [libreoffice](https://github.com/LibreOffice/core) for office documents  - Used by `faziffd` for office file preview.

### Usage

#### faziffd - File/Directory jumper

- `Ctrl-w`: Search files in the home directory
- `Ctrl-e`: Search directories in the home directory
- `Alt-c`: Search directories in the current working directory
- `Ctrl-t`: Search files in the current working directory
- `Ctrl-f`: Search directories from the root
- `Ctrl-p`: Toggle the preview window/position
- `Ctrl-x`: Open in Yazi (new instance)(if `setsid` is not available, use `nohup`)


#### fazifrg, fazifrga

- `Ctrl-y`: Switch between rga search mode and fzf filtering mode
- `Ctrl-p`: Toggle the preview window/position
- `Ctrl-o`: `fazifrg` open file in Neovim at the matched line. `fazifrga` open document in Zathura at the matched page and highlight the query.

## License

This plugin is released under the MIT License.

## Acknowledgement
Plugin is based on the default [Yazi](https://github.com/sxyazi/yazi) fzf plugin and vcs-files plugin. Fzf scripts grow out of [fzf](https://github.com/junegunn/fzf)'s wiki and examples. 

