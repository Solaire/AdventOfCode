--- Day 24: Arithmetic Logic Unit ---

require "shared"

-- Return the sum of a and b
local function Add(a, b)
	return a + b
end

-- Return the product of a and b
local function Mul(a, b)
	if(a == 0 or b == 0) then 
		return 0
	end
	return a * b
end

-- Return a / b, rounded towards 0
-- If a or b are 0, return 0
local function Div(a, b)
	if(a == 0 or b == 0) then
		return 0
	end
	return math.floor(a / b)
end

-- Return the remainder of a / b
-- If a < 0 and b < 0, return 0
local function Mod(a, b)
	if(a < 0 or b < 0) then
		return 0
	end
	return a % b
end

-- Return 1 if a == b, else return 0
local function Eql(a, b)
	return Tenery(a == b, 1, 0)
end

-- String to function pointer map
local INSTRUCTIONS = 
{
	["add"] = Add,
	["mul"] = Mul,
	["div"] = Div,
	["mod"] = Mod,
	["eql"] = Eql
}

-- Arithmetic Logic Unit structure
ALU = {}
ALU.__index = ALU

-- Constructor
function ALU:New(filename)
	self = {}
	self.filename = filename
	self.registers = {['x'] = 0, ['y'] = 0, ['z'] = 0, ['w'] = 0}
	
	setmetatable(self, ALU)
	return self
end

-- Reset all registers to 0
-- Execute the internal routine against the input
-- Input must be a string of digits
function ALU:Validate(input)
	local hFile = OpenFile(self.filename)
	if(hFile == nil) then
		return 0
	end
	
	self.registers = {['x'] = 0, ['y'] = 0, ['z'] = 0, ['w'] = 0}
	local inDigits = {}
	for char in input:gmatch(".") do
		table.insert(inDigits, tonumber(char))
	end
	
	local line = hFile:read("*line")
	local index = 1
	while(line) do
		local split = StringSplit(line, ' ')
		
		local instruction = split[1]
		local a = split[2]
		local b = split[3]
		
		if(instruction == "inp" and self.registers[a] ~= nil) then
			self.registers[a] = inDigits[index]
			index = index + 1
		else
			local b = Tenery(self.registers[b] ~= nil, self.registers[b], tonumber(b))
			self.registers[a] = INSTRUCTIONS[instruction](self.registers[a], b)
		end
		
		line = hFile:read("*line")
	end
	
	return self.registers['z']
end

-- Generator object for creating input model numbers
-- Supposed to mimic python's itertools.product
--
-- Given a range min..max and a length, a list of digits will be returned
-- The generator behaves like binary counting:
-- Ascending  [1, 1, 1] -> [1, 2, 1] -> [1, 3, 1] -> [1, 2, 1] -> [2, 2, 1]
-- Descending [3, 3, 3] -> [3, 3, 2] -> [3, 3, 1] -> [3, 2, 3] -> [3, 2, 2]
Generator = {}
Generator.__index = Generator

-- Constructor
-- Set the range and the length of the output array
-- Both ascending and descending range is supported
function Generator:New(minimum, maximum, length)
	self = {}
	self.minimum = minimum
	self.maximum = maximum
	self.length = length
	
	self.delta  = Tenery(minimum - maximum > 0, -1, 1)
	self.cursor = Tenery(minimum > maximum, 1, length)
	self.digits = nil
	
	setmetatable(self, Generator)
	return self
end

-- Apply the delta to the current digit.
-- If current digit is outside of range, move the cursor and set the next value
-- Apply recursively
function Generator:Overflow(cursor, delta)
	self.digits[cursor] = self.digits[cursor] + delta
	if(delta < 0 and self.digits[cursor] < self.maximum) then
		self.digits[cursor] = self.minimum
		self:Overflow(cursor - delta, delta)
	elseif(delta > 0 and self.digits[cursor] > self.maximum) then
		self.digits[cursor] = self.minimum
		self:Overflow(cursor - delta, delta)
	end	
end

-- Return the next set of digits
function Generator:Next()
	if(not self.digits) then
		self.digits = {}
		for i = 1, self.length do
			table.insert(self.digits, self.minimum)
		end
		return self.digits
	end
	
	self:Overflow(self.cursor, self.delta)
		
	return self.digits
end

-- Check if the specified combination of digits works as a model number
-- The input program is split into 14 subroutines, which manipulate the register
-- Model number is valid if the final value of z is 0 (initial value is 0)
--
-- The 14 subroutines are equally split into 2 "modes":
-- 	 * Inflate (Multiply z by 26)
--   * Deflate (Divide z by 26)
-- Those two modes are essentialy bit shift left or right (if pretenting z is base 26)
-- 
-- Inflate:
-- 	* The final value of z is always (26z + w + v) (v is an arbitrary value on line 15 of the subroutine)
-- Deflate:
--  * Depending on the initial value of z, the subroutine will return either:
--    * if ((z % 26) - 11 == w), then return z // 26
--	  * else return (26 * z / 26) (z stays the same)
-- 
-- The goal is to find the correct numbers such that the deflate subroutines will reduce the value of z
-- We only need to find the correct combination of 7 digits
local function CheckDigits(digits, steps, required)
	local result = ""		
	local z = 0
	local idxDigits = 1
	
	for i = 1, 14 do
		local increment = steps[i]
		local mod_req   = required[i]
		
		if(not increment and mod_req) then
			local digit = (z % 26) - mod_req
			result = result..tostring(digit)
			z = z // 26
			if(digit < 1 or 9 < digit) then
				return false, ""
			end
		else
			z = z * 26 + digits[idxDigits] + increment
			result = result..tostring(digits[idxDigits])
			idxDigits = idxDigits + 1
		end
	end
	
	return true, result
end

-- Shared internal function.
-- If 'isPartA' is true return the highest possible height achieved by the probe 
--	otherwise return the number of possible velocities
local function Solve(filename, isPartA)
	local hFile = OpenFile(filename)
	if(hFile == nil) then
		return 0
	end
	
	local steps 	= {}
	local required 	= {}
	
	local line = hFile:read("*line")
	local i = 0
	local block = 0
	
	-- Go through the program
	-- A block starts with "inp w" - there are 14 of those
	-- For each block, we're only interested in two lines:
	-- Line 5 "add x val" - if val <= 0, add it to the required map, otherwise
	-- Line 8 "add y val" - if val on line 5 is positive, add this to the steps map
	while(line) do
		local split = StringSplit(line, ' ')
		local val = tonumber(split[3])
		if(split[1] == 'inp') then 
			i = 0
			block = block + 1
		elseif(i == 5 and val <= 0) then
			required[block] = math.abs(val)
		elseif(i == 15 and not required[block]) then
			steps[block] = val
		end
		
		i = i + 1
		line = hFile:read("*line")
	end
	
	local gen = Tenery(isPartA, Generator:New(9, 1, 7), Generator:New(1, 9, 7))
	local digitsCorrect = false
	local modelNumber = ""
	
	repeat
		digitsCorrect, modelNumber = CheckDigits(gen:Next(), steps, required)
	until(digitsCorrect)
	
	return modelNumber
end

-- Find the initial velocity that causes the probe to reach the highest y position 
--   and still eventually be within the target area after any step.
function PartA(filename)
	return Solve(filename, true)
end

-- Find the number of distinct velocities that causes the probe to be within the target after any step
function PartB(filename)
	return Solve(filename, false)
end

local input = "inputs/day24.txt"
print(PartA(input))
print(PartB(input))
