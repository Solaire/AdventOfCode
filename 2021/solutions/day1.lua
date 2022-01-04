--- Day 1: Sonar Sweep ---

require "shared"

-- Count the number of times the array element is greater than the one before it
-- Simple linear scan
function PartA(filename)
	local hFile = OpenFile(filename)
	if(hFile == nil) then
		return 0
	end
	
	local count = 0
	local line = hFile:read("*line")
	local previous = tonumber(line)
		
	while(line) do
		if(previous < tonumber(line)) then
			count = count + 1
		end
		previous = tonumber(line)
		line = hFile:read("*line")
	end
    return count
end

-- Using a sliding window which generates a sum of array elements (i, i + 1, i + 2)
-- Count the number of times the sum is greater than the sum of previous sliding window (i - 1)
-- As with part A, simple linear scan
function PartB(filename)
	local hFile = OpenFile(filename)
	if(hFile == nil) then
		return 0
	end
	
    local count = 0
	local previous = {}
	previous[1] = tonumber(hFile:read("*line"))
	previous[2] = tonumber(hFile:read("*line"))
	previous[3] = tonumber(hFile:read("*line"))
	previous[4] = tonumber(hFile:read("*line"))
	local line = nil
	
	repeat
		local sumA = previous[1] + previous[2] + previous[3]
        local sumB = previous[2] + previous[3] + previous[4]
		if(sumB > sumA) then
            count = count + 1
        end
		line = hFile:read("*line")
		previous[1] = previous[2]
		previous[2] = previous[3]
		previous[3] = previous[4]
		previous[4] = tonumber(line)
	until(line == nil)
    return count
end

local input = "inputs/day1.txt"
print(PartA(input))
print(PartB(input))