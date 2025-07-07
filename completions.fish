complete -c lus -a "(lus --tags)" -f

complete -c lus -l help -s h '-d Print usage'
complete -c lus -l version -s v '-d Print version'
complete -c lus -l completion '-d Print completion'
complete -c lus -l config -s c -r '-d Set the config, defaults to ~/.config/lus/config.lua'
complete -c lus -l delete -s d '-d Delete any matching notes, will ask for confirmation'
complete -c lus -l edit -s e '-d Edit any matching notes in configured editor (defaults to $EDITOR)'
complete -c lus -l file -s f '-d Print the filenames of any matching notes instead of the contents'
complete -c lus -l number -s n -r '-d Limits the maximum number of matches'
complete -c lus -l or '-d One or more of the provided arguments must match rather than all'
complete -c lus -l short -s s '-d Print only the title of each note'
complete -c lus -l tags -s t '-d Print all the tags that exist among all notes'
