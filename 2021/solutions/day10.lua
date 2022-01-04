--- Day 10: Syntax Scoring ---

require "shared"

-- Map of opening brackets to closing brackets
local BRACKETS = {}
BRACKETS['('] = ')'
BRACKETS['['] = ']'
BRACKETS['{'] = '}'
BRACKETS['<'] = '>'

-- Map of closing brackets to their error and autocomplete scores
-- Index 1 = syntax error score
-- Index 2 = autocomplete score
local BRACKET_SCORE = {}
BRACKET_SCORE[')'] = { 3	, 1 }
BRACKET_SCORE[']'] = { 57	, 2 }
BRACKET_SCORE['}'] = { 1197	, 3 }
BRACKET_SCORE['>'] = { 25137, 4 }

-- Parse each line until an incorrect closing bracket is found
-- Return the total syntax error score (sum of all incorrect brackets)
-- Incomplete lines are ignored (lines where closing brackets are missing)
function PartA(filename)
	local hFile = OpenFile(filename)
	if(hFile == nil) then
		return 0
	end

	local score = 0
    local line = hFile:read("*line")
    while(line) do
		local stack = {}
		
		for char in line:gmatch"." do
			if(char == "") then
				-- Ignore
			elseif(BRACKETS[char] ~= nil) then
				table.insert(stack, char)
			elseif(char == BRACKETS[stack[#stack]]) then
				table.remove(stack, #stack)
			else
				score = score + BRACKET_SCORE[char][1]
				break
			end
		end
		line = hFile:read("*line")
    end
	
	return score
end

-- Parse each incomplete line and autocomplete the brackets, adding points for each bracket added
-- Return the median score (sum of all autofilled brackets per line)
-- Lines with incorrect closing brackets are ignored
function PartB(filename)
	local hFile = OpenFile(filename)
	if(hFile == nil) then
		return 0
	end

	local score = {}
    local line = hFile:read("*line")
    while(line) do
		local stack = {}
		for char in line:gmatch"." do
			if(char == "") then
				-- Ignore
			elseif(BRACKETS[char] ~= nil) then
				table.insert(stack, char)
			elseif(char == BRACKETS[stack[#stack]]) then
				table.remove(stack, #stack)
			else
				goto skip -- Syntax error, skip
			end
		end
		
		table.insert(score, 0)
		repeat
			local char = stack[#stack]
			score[#score] = (score[#score] * 5) + BRACKET_SCORE[BRACKETS[char]][2]
			table.remove(stack, #stack)
		until(#stack == 0)
		
		::skip::
		line = hFile:read("*line")
    end
	table.sort(score)
    return score[((#score + 1) // 2)]
end

local input = "inputs/day10.txt"
print(PartA(input))
print(PartB(input))
