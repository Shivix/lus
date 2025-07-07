local home_dir = assert(os.getenv("HOME"))

local file <close> = assert(io.open(home_dir .. "/.local/share/jrnl/journal.txt", "r"))

local id = 0
local new_file
for line in file:lines() do
    -- [2024-11-25 08:39:47 PM]
    local begin_pos, end_pos = line:find("%[%d%d%d%d%-%d%d%-%d%d %d%d:%d%d:%d%d %a%a]")
    if begin_pos and end_pos then
        if new_file ~= nil then
            new_file:close()
        end
        id = id + 1
        new_file = assert(io.open(home_dir .. "/.local/state/lus/" .. id .. ".lus", "w"))
        new_file:write(line:sub(end_pos + 2) .. "\n")
    else
        new_file:write(line .. "\n")
    end
end
new_file:close()
