# lus
Lus (pronounced loose) is a simple and lightweight note taking/ journaling tool written in Lua.

Fish shell completion is provided.

## Usage
Some examples of how to use. Please see lus --help for more details.
```sh
$ lus # Create a new note interactively using $EDITOR
$ echo @todo task | lus # Create new note using stdin
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

## Skill
When using AI agents (don't worry this code base has not been written by AI) it's often nice to have
it condense down the current chat sessions into some notes to use for future reference. I don't want
to replace my note taking system with an AI based one, as it is grossly overkill for most cases, but
I also don't want to throw away that ability. Therefor, I have provided a skill to allow an agent to
easily and safely create and manage notes using Lus.

See skills/ directory.
