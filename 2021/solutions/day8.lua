--- Day 8: Seven Segment Search ---

require "shared"

-- Return the difference between segments A and B
local function SegmentDifference(a, b)
    local cpy = a
	for c in b:gmatch"." do
		cpy = cpy:gsub(c, "") 
	end
    return cpy
end

-- Return true if segment A contains all of segment B
local function ContainsSegments(a, b)
	for c in b:gmatch"." do
		if(not string.find(a, c)) then
            return false
        end
	end
    return true
end

-- Parse the second part of each input line (encoded numbers), and return the frequency of digits 1, 4, 7, and 8
-- Since all 4 digits have unique number of segments, just check the size of the encoded digit
function PartA(filename)
	local hFile = OpenFile(filename)
	if(hFile == nil) then
		return 0
	end
	
	local count = 0
	local line = hFile:read("*line")
	while(line) do
		local split = StringSplit(line, '|')
		for t in (split[2]..' '):gmatch("(.-)"..' ') do
			if( (#t >= 2 and #t <= 4) or #t == 7) then
				count = count + 1
			end
		end
		
		line = hFile:read("*line")
	end
	
    return count
end

-- For each input line, decode the segments and create a 4-digit number
-- Return the sum of all 4-digit numbers
-- Diguring out which number is which can be done with the following:
-- 		4 numbers have unique number of segments:
-- 		1 = 2 segments
-- 		4 = 4 segments
-- 		7 = 3 segments
-- 		8 = 7 segments (all)
-- 		
-- 		If number has 5 segments:
-- 		3 = if contains all segments of number 1
-- 		5 = if contains the difference of numbers 4 and 1 (little L shape)
-- 		2 = if both of the above are false
-- 		
-- 		If number has 6 segments:
-- 		9 = if contains all segments of number 4
-- 		6 = if contains the difference of numbers 4 and 1 (little L shape) (note) number 9 also contains the 'L' shape)
-- 		0 = if both of the above are false
function PartB(filename)
    local hFile = OpenFile(filename)
	if(hFile == nil) then
		return 0
	end
	
    local sum = 0
	local line = hFile:read("*line")
	while(line) do
        local split = StringSplit(line, '|')
        local patterns = StringSplit(split[1], " ")
        local encoded  = StringSplit(split[2], " ")
        
        table.sort(patterns, function(a, b) return string.len(a) < string.len(b) end)
	
        -- Once sorted, the first three are 1, 7, 4 and last one is 8
        local one   = patterns[1]
        local four  = patterns[3]
        local seven = patterns[2]
        local eight = patterns[10]
        local fourDiff = SegmentDifference(four, one) -- Get the small 'L' shape
        
		-- Create the 4 digit number
        local number = 0
        for i = 1, #encoded do
            local len = string.len(encoded[i])
            
            if(len == 2) then
                number = number + 1
            elseif(len == 3) then
                number = number + 7
            elseif(len == 4) then
                number = number + 4
            elseif(len == 7) then
                number = number + 8
                
            elseif(len == 5 and ContainsSegments(encoded[i], one)) then
                number = number + 3
            elseif(len == 5 and ContainsSegments(encoded[i], fourDiff)) then
                number = number + 5
            elseif(len == 5) then  
                number = number + 2
                
            elseif(len == 6 and ContainsSegments(encoded[i], four)) then
                number = number + 9
            elseif(len == 6 and ContainsSegments(encoded[i], fourDiff)) then
                number = number + 6
            end
            
            number = number * 10
        end
        sum = sum + (number / 10)
		line = hFile:read("*line")
    end
    
    return sum
end

local input = "inputs/day8.txt"
print(PartA(input))
print(PartB(input))