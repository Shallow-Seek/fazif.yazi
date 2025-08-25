# fazif: Search over selected items with `fd`, `rg`, `rga` and spawn any FZF configuration in Yazi

## What fazif Does

With fazif, you can:
- Spawn all your fzf scripts into the [Yazi](https://github.com/sxyazi/yazi) file manager
- Search within selected folders and directories
- Search within current folder when none are selected (the default Yazi fzf behavior)
- Reveal selected items in new tabs (if you add the `-multi` fzf option in the script)

## To Do
* Send selected files to the search result panel like the default Yazi `fd`, `rg`

## How It Works

This plugin acts as a bridge between Yazi and standalone fzf scripts. The main.lua file serves as a generic wrapper that:
1. Passes the current working directory and selected files/directories from Yazi (`$*` in the script) to the fzf script
2. Executes the specified script (passed as an argument in the keymap)
3. Processes the output and opens results in new Yazi tabs

## Installation

1. Install via ya:

```bash
ya pkg -a Shallow-Seek/fazif
```

or

```bash
git clone https://github.com/Shallow-Seek/fazif.yazi.git ~/.config/yazi/plugins/fazif.yazi
```

2. The 3 default scripts `faziffd`, `fazifrg`, and `fazifrga` provided are examples with features shown in the next section. To spawn your own fzf script into Yazi, you just need to add `$*` to the search command (fd, rg, ...) as the path and put them in `~/.config/yazi/plugins/fazif.yazi/`. Check `faziffd` to see that. 
Make sure your scripts are executable:

```bash
chmod +x ~/.config/yazi/plugins/fazif.yazi/faziffd
chmod +x ~/.config/yazi/plugins/fazif.yazi/fazifrg
chmod +x ~/.config/yazi/plugins/fazif.yazi/fazifrga
chmod +x ~/.config/yazi/plugins/fazif.yazi/yourscript1
...
```
Open a terminal in `~/.config/yazi/plugins/fazif.yazi` and test the script by running `./faziffd`. You may need to update the shebang (`#!`) at the top of the script to match your system's shell interpreter path. Run `which sh` at the terminal to find it.



## Add Keymaps to Your Script

The plugin can be configured to run any of your scripts by passing the script name as an argument. Add the following to your `~/.config/yazi/keymap.toml` to bind each script to a key combination:

### Setting up all scripts:

```toml
# File/Directory finder using fd + fzf
[[manager.prepend_keymap]]
on = [ "b", "d" ]
run = "plugin fazif faziffd"
desc = "Find files/directories with fd and fzf"

# Content finder using ripgrep + fzf
[[manager.prepend_keymap]]
on = [ "b", "r" ]
run = "plugin fazif fazifrg"
desc = "Find content in files with ripgrep and fzf"

# Document content finder using ripgrep-all + fzf
[[manager.prepend_keymap]]
on = [ "b", "a" ]
run = "plugin fazif fazifrga"
desc = "Find content in documents with ripgrep-all and fzf"
```

That's it. However, if your rg or rga's delimiter is not the default `:`, you will need to change the delimiter in main.lua.

---

Read this section if you use the default scripts `faziffd`, `fazifrg`, and `fazifrga`.

## Features

1. **faziffd** - File/directory finder using `fd` 
2. **fazifrg** - search in text using `ripgrep` 
3. **fazifrga** - `ripgrep-all`  search in PDFs and DjVu 

## Preview Features

- The `fazifrg` preview shows file content with `bat` when started with no input. With any input, `rg` kicks in, and the preview highlights the matching line with context.
- The `fazifrga` preview shows the first page of a document when started with no input. With any input, `rga` kicks in, and the preview shows the matching page in the document.
- **Directory listings with `eza`**

## Prerequisites

Before using this plugin, ensure you have the following tools installed:

- [Yazi](https://github.com/sxyazi/yazi) 
- [fzf](https://github.com/junegunn/fzf) 
- [fd](https://github.com/sharkdp/fd) - Used by: `faziffd`
- [ripgrep](https://github.com/BurntSushi/ripgrep) - Used by: `fazifrg`
- [ripgrep-all](https://github.com/phiresky/ripgrep-all) - Used by: `fazifrga`
- [rga djvu adaptor](https://github.com/phiresky/ripgrep-all/discussions/166) - Used by: `fazifrga`
- [bat](https://github.com/sharkdp/bat) - Used by: `faziffd`, `fazifrg` 
- [eza](https://github.com/eza-community/eza) - Used by: `faziffd`
- [kitty](https://sw.kovidgoyal.net/kitty/) 
- Additional tools for document previews:
  - pdftoppm (from poppler-utils) - Used by: `faziffd`, `fazifrga`
  - ddjvu (from djvulibre) - Used by: `faziffd`, `fazifrga`
  - libreoffice (for office documents) - Used by: `faziffd`

## Usage

### faziffd - File/Directory Finder

Launch with the `bd` keybinding:
- `Ctrl-w`: Search files in the home directory
- `Ctrl-e`: Search directories in the home directory
- `Alt-c`: Search directories in the current working directory
- `Ctrl-t`: Search files in the current working directory
- `Ctrl-f`: Search directories from the root
- `Ctrl-r`: Search files from the root
- `Ctrl-p`: Toggle the preview window
- `Ctrl-x`: Open in Yazi (new instance)(if `setsid` is not available, use `nohup`)

### fazifrg - Search in Text

Launch with the `br` keybinding:
- Type to search content in files using ripgrep
- `Ctrl-y`: Switch between ripgrep search mode and fzf filtering mode
- `Ctrl-p`: Toggle the preview window position
- `Ctrl-o`: Open file in Neovim at the matched line

### fazifrga - Search in PDF and DjVu

Launch with the `ba` keybinding:
- Searches content in PDFs and DjVu documents
- `Ctrl-y`: Switch between rga search mode and fzf filtering mode
- `Ctrl-p`: Toggle the preview window
- `Ctrl-o`: Open document in Zathura(or your viewer) at the matched page

## License

This plugin is released under the MIT License.

## Credits

- [Yazi](https://github.com/sxyazi/yazi) 
- [fzf](https://github.com/junegunn/fzf)
