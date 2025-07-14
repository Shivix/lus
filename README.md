# lus
Lus (pronounced loose) is a simple and lightweight note taking/ journaling tool written in Lua.

Fish shell completion is provided.

## Usage
Some examples of how to use. Please see lus --help for more details.
```sh
$ lus # Create new note
$ lus @todo --short # Print the titles of all notes containing @todo tags
$ lus "lus usage" # Print the notes that contain "lus usage"
$ lus lus usage # Print the notes that contain both the words lus and usage in any position
$ lus lus usage --or # Print the notes that contain either lus or usage
```

## Examples
Example config:
```lua
return {
    editor = "nvim -c 'set ft=markdown'", -- Defaults to $EDITOR
    directory = "~/.local/state/lus", -- This is default
}
```

Here is an example fish function to use fzf to find notes
```fish
function fzflus
    lus "" --short | fzf --multi --preview 'lus {} --fixed-strings --file | xargs bat -H 1 --language markdown --color=always'
end
```
