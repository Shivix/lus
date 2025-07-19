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
        long = "case-sensitive",
        description = "Match notes case sensitively",
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
        long = "fixed-strings",
        short = "F",
        description = "treat arguments as plain strings and avoid lua pattern matching",
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

local version = "1.0.1"
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

if #args == 0 then
    create_note(config)
else
    local patterns = {}
    for _, a in ipairs(args) do
        -- If case-sensitive is not provided then use smart case
        if opts["case-sensitive"] == nil and a:lower() ~= a then
            opts["case-sensitive"] = true
        end
        if a:sub(1, 1) == "@" and not a:find(" ") and not opts["fixed-strings"] then
            -- Only match whole tags (@tod should not match @todo)
            table.insert(patterns, a .. "[^%w]")
        else
            table.insert(patterns, a)
        end
    end

    local files = ""
    local n = 0
    -- sort -V avoids 10..19, 1 ordering. -r reverses so newer notes are first.
    local notes = assert(io.popen('ls "' .. config.directory .. '"*.lus | sort -Vr'))
    for file in notes:lines() do
        local f <close> = io.open(file, "r")
        if f then
            local content = f:read("*a")
            if not opts["case-sensitive"] then
                content = content:lower()
            end
            f:close()
            local patterns_found = 0
            for _, pattern in ipairs(patterns) do
                -- Use smartcase (only make case sensitive if pattern given includes uppercase)
                if content:find(pattern, 1, opts["fixed-strings"]) then
                    if opts["or"] then
                        patterns_found = #patterns
                        break
                    end
                    patterns_found = patterns_found + 1
                end
            end
            if patterns_found == #patterns then
                files = files .. " " .. file
                n = n + 1
                if n == tonumber(opts.number) then
                    break
                end
            end
        end
    end

    if files ~= "" then
        handler(files)
    end
end
