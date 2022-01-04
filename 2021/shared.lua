-- Split the string according to the delimiter.
-- Return array of string tokens.
function StringSplit(str, delimiter)
    local result = {};
    for match in (str..delimiter):gmatch("(.-)"..delimiter) do
        if(match ~= "") then
			table.insert(result, match)
        end
    end
    return result
end

-- Open a file from given filename
-- Return file handle on open, or nil on failure
function OpenFile(filename)
    local hFile = io.open(filename, "r")
    if(hFile == nil) then
        print(string.format("Could not open file: %s", filename))
    end
    return hFile
end

-- Wrapper mimicking a tenary operator (cond ? T : F;), hiding away the ugly code
function Tenery(cond, T, F)
	if(cond) then return T else return F end
end

-- Create a new table and copy all elements from old
function table.ShallowCopy(t)
	local t2 = {}
	for k, v in pairs(t) do
		t2[k] = v
	end
	return t2
end
