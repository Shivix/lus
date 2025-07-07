#!/usr/bin/env lua

local lualib_args = require("lualib.args")

local function create_note(config)
    local id_path = config.directory .. "id"
    local file <close> = io.open(id_path, "r")
    local new_id
    if file == nil then
        os.execute("echo 0 >" .. id_path)
        new_id = 0
    else
        new_id = file:read("*n")
        assert(new_id, "id file is corrupted") -- TODO: Recreate based on current highest file name
    end
    new_id = new_id + 1

    local note_path = config.directory .. new_id .. ".lus"
    os.execute(config.editor .. " " .. note_path)

    if os.execute("ls " .. note_path .. " 2>/dev/null") then
        os.execute(string.format([[
            if [ ! -s %q ]; then
                rm -i %q
            fi
        ]], note_path, note_path))
        os.execute("echo " .. new_id .. " >" .. id_path)
    end
end

local valid_opts = {
    {
        long = "help",
        short = "h",
        description = "Print usage",
    },
    {
        long = "version",
        short = "v",
        description = "Print version",
    },
    {
        long = "completion",
        description = "Print completion",
    },
    {
        long = "config",
        short = "c",
        value = true,
        description = "Set the config, defaults to ~/.config/lus/config.lua",
    },
    {
        long = "delete",
        short = "d",
        description = "Delete any matching notes, will ask for confirmation",
    },
    {
        long = "edit",
        short = "e",
        description = "Edit any matching notes in configured editor (defaults to $EDITOR)",
    },
    {
        long = "file",
        short = "f",
        description = "Print the filenames of any matching notes instead of the contents",
    },
    {
        long = "number",
        short = "n",
        value = true,
        description = "Limits the maximum number of matches",
    },
    {
        long = "or",
        description = "One or more of the provided arguments must match rather than all",
    },
    {
        long = "short",
        short = "s",
        description = "Print only the title of each note",
    },
    {
        long = "tags",
        short = "t",
        description = "Print all the tags that exist among all notes",
    },
}

local version = "1.0.0"
local opts, args = lualib_args.parse_args(valid_opts)

if opts.help then
    local usage = "lus " .. version .. [[

A simple note taking/ journaling tool.

Usage:
    lus [Pattern] [Options]

]] .. lualib_args.generate_usage(valid_opts) .. [[

https://github.com/Shivix/lus]]
    print(usage)
    os.exit(0)
elseif opts.version then
    print("lus " .. version)
    os.exit(0)
elseif opts.completion then
    print(lualib_args.generate_completion("lus", valid_opts))
    os.exit(0)
end

local config_path = opts.config or "~/.config/lus/config.lua"
config_path = config_path:gsub("^~", assert(os.getenv("HOME")))
local ok, config = pcall(dofile, config_path)
if not ok then
    config = {}
end

config.directory = config.directory or "~/.local/state/lus/"
if not config.directory:match("/$") then
    config.directory = config.directory .. "/"
end
config.directory = config.directory:gsub("^~", assert(os.getenv("HOME")))

config.editor = config.editor or "$EDITOR"

if opts.tags then
    os.execute(string.format("rg --only-matching --no-filename '@\\w+' %q | sort | uniq", config.directory))
    os.exit(0)
end

local handler = function(files)
        files = files:gsub("\n", " ")
        os.execute("bat -H 1 --language markdown " .. files)
    end
if opts.short then
    handler = function(files)
        files = files:gsub("\n", " ")
        os.execute("head -n 1 --quiet " ..files .. " | rg --no-filename --colors 'match:fg:magenta' -e '@\\w+'")
    end
end
if opts.file then
    handler = function(files)
        print(files)
    end
end
if opts.delete then
    handler = function(files)
        files = files:gsub("\n", " ")
        os.execute("bat --line-range :1 " .. files)
        os.execute("rm -i " .. files)
    end
end
if opts.edit then
    handler = function(files)
        files = files:gsub("\n", " ")
        os.execute(config.editor .. " " .. files)
    end
end
-- Will cause awk to fail if no directories are found.
local all_notes = config.directory .. "*.lus"

if #args == 0 then
    create_note(config)
else
    local separator = "&&"
    if opts["or"] then
        separator = "||"
    end
    local pattern = ""
    for _, a in ipairs(args) do
        if a:sub(1, 1) == "@" and not a:find(" ") then
            -- Only match whole tags (@tod should not match @todo)
            pattern = pattern .. " /" .. a .. "([^[:alnum:]]|$)/ " .. separator
        else
            pattern = pattern .. " index($0, \"" .. a .. "\") " .. separator
        end
    end
    -- Remove final separator
    pattern = pattern:sub(1, -4)

    local nextfile = "nextfile"
    if opts.number == "1" then
        nextfile = "exit"
    elseif opts.number then
        nextfile = "if (++i == "..opts.number..") exit"
    end

    local awk_script = string.format("awk '%s { print FILENAME; %s }' %s", pattern, nextfile, all_notes)
    local find_files <close> = assert(io.popen(awk_script))
    local files = find_files:read("*all")
    if files ~= "" then
        handler(files)
    end
end
