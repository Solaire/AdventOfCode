--- Day 14: Extended Polymerization ---

require "shared"

-- Shared internal function
-- Load the polymer template (long string) and the rules for pair insertion
-- In each step, find suitable pairs and apply their rule to them, inserting a character between them
local function Solve(filename, steps)
	local hFile = OpenFile(filename)
	if(hFile == nil) then
		return 0
	end
	
	local rulemap = {}
	local pair = {}
	local element = {}
	
	-- Extract and process the template, counting occuring elements and pairs
	local line = hFile:read("*line")
	local previous = nil
	for char in line:gmatch"." do
		if(element[char]) then element[char] = element[char] + 1 else element[char] = 1 end
		
		if(previous) then
			local p = previous..char		
			if(pair[p]) then pair[p] = pair[p] + 1 else pair[p] = 1 end
		end
		previous = char
	end
	
	line = hFile:read("*line") -- empty space
	line = hFile:read("*line")
	
	while(line) do
		local rule = StringSplit(line, "->")
		rule[1] = rule[1]:gsub("%s+", "")
		rule[2] = rule[2]:gsub("%s+", "")
		rulemap[rule[1]] = rule[2]
		line = hFile:read("*line")
	end
	
	for i = 1, steps do
		local cpy = table.ShallowCopy(pair)
		for key, val in pairs(pair) do
			if(rulemap[key]) then
				local rule = rulemap[key]
				local l = key:sub(1, 1)..rule
				local r = rule..key:sub(2, 2)
				
				if(cpy[key]) 	  then cpy[key] 	 = cpy[key] - val	   end
				if(cpy[l])   	  then cpy[l]   	 = cpy[l] + val		   else cpy[l] = val end
				if(cpy[r])   	  then cpy[r]   	 = cpy[r] + val		   else cpy[r] = val end
				if(element[rule]) then element[rule] = element[rule] + val else element[rule] = val end
			end
		end
		pair = table.ShallowCopy(cpy)
	end
	
	-- Ugly copy code and find min and max values
	local top = -1
	local bottom = -1
	
	for key, val in pairs(element) do
		if(top == -1 or top < val) then
			top = val		
		elseif(bottom == -1 or bottom > val) then
			bottom = val
		end
	end
	return top - bottom
end

-- Load the polymer template and rules
-- Apply 10 pair insertions and return difference between most common and least common element
function PartA(filename)
	return Solve(filename, 10)
end

-- Load the polymer template and rules
-- Apply 40 pair insertions and return difference between most common and least common element
function PartB(filename)
	return Solve(filename, 40)
end

local input = "inputs/day14.txt"
print(PartA(input))
print(PartB(input))
