---
name: lus
description: A way to create and manage notes that the user can easily interact with outside of the agent.
---

# Lus Note Taking Tool
Lus is a CLI tool written for simple and consistent note taking. It's primary use is from the
commandline, where the user can easily and quickly write and view notes.

lus --help can be used for more information.

## Creating notes
Lus' first use case is to create a new note.
This is done by calling `lus` with no arguments and piping in the note contents into stdin.

It is a common standard to start the first line of the note with at least one tag.
Check existing tags before adding new ones.

## Viewing notes
Lus' second use case is viewing notes. To view notes, call `lus` with at least one argument. Lus
will then print all notes that include all of those patterns in any order. The words do not need to
be contiguous unless provided as one argument.
If the pattern unintentionally contains characters used in Lua pattern matching `--fixed-strings`
can be used.
For more advanced searches, the Lua pattern matching can be utilised.
Smart case sensitivity used by default.

You can search for all notes by calling `lus ""` however to avoid returning too many results, this
should be combined with `-n <num>` to limit the number of results.

## Deleting notes
Deleting notes must *only* be done through the `$HOME/.codex/skills/lus/scripts/delete.sh` script,
and never directly using lus.
This is done by providing the delete.sh script with the entire fixed string pattern of the note header.

## Tags
Tags are @ followed by a single word. These are useful for grouping notes together. Try to reuse
relevant tags where possible. Use `--tags` to list existing tags.

These are used to quickly get a group of notes, such as all notes with tasks todo. Keep this in
mind when creating new tags. Use them when there is a useful potential grouping.

Avoid using similar tags (@llm and @gpt)
Usually best to keep them lowercase unless already specified as uppercase

## Headers
The first line of each note is considered to be the "header" of the note. If the `--short` option
is passed to lus, it will only print the headers.

## Quality Rules
- If a note involves a task that must be done, the @todo tag should be used.
- If the user is asking for multiple notes, it's a good idea to use --short first to reduce output.
- Avoid using generic tags such as @notes.
- Use a single long string as the pattern when trying to find an exact match.
