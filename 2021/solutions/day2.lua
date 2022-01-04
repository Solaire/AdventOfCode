--- Day 2: Dive! ---

require "shared"

-- Parse the input and modify a submarine's position based on the commands and values
-- Return the product of depth and horizontal position
local function PartA(filename)
	local hFile = OpenFile(filename)
	if(hFile == nil) then
		return 0
	end
	
	local depth = 0
    local horizontal = 0
	local line = hFile:read("*line")
	
	while(line) do
		local split = StringSplit(line, " ")
        
        if("forward" == split[1]:lower()) then
            horizontal = horizontal + tonumber(split[2])
        elseif("down" == split[1]:lower()) then
            depth = depth + tonumber(split[2])
        elseif("up" == split[1]:lower()) then
            depth = depth - tonumber(split[2])
        end
		line = hFile:read("*line")
	end
	
    return depth * horizontal
end

-- Parse the input and modify a submarine's position based on the commands and values
-- Return the product of depth and horizontal position
local function PartB(filename)
	local hFile = OpenFile(filename)
	if(hFile == nil) then
		return 0
	end
	
    local depth = 0
    local horizontal = 0
    local aim = 0
	local line = hFile:read("*line")
	
	while(line) do
		local split = StringSplit(line, " ")
        
        if("forward" == split[1]:lower()) then
            horizontal = horizontal + tonumber(split[2])
            depth = depth + (aim * tonumber(split[2]))
        elseif("down" == split[1]:lower()) then
            aim = aim + tonumber(split[2])
        elseif("up" == split[1]:lower()) then
            aim = aim - tonumber(split[2])
        end
		line = hFile:read("*line")
	end
    return depth * horizontal
end

local input = "inputs/day2.txt"
print(PartA(input))
print(PartB(input))