--- Day 25: Sea Cucumber ---

require "shared"

-- Create a map key based on x/y coordinates
local function Point2Hash(x, y)
	return string.format("%d;%d", x, y)
end

-- Convert a hash to an x/y point
local function Hash2Point(hash)
	local i = hash:find(';')
	local x = tonumber(hash:sub(1, i - 1))
	local y = tonumber(hash:sub(i + 1, #hash))
	return x, y
end

-- Map structure, holind the east and north herds of cucumbers
Seamap = {}
Seamap.__index = Seamap

-- Constructor
function Seamap:New()
	self = {}
	--self.total = {}
	self.east = {}
	self.south = {}
	self.width = 0
	self.height = 0
	
	setmetatable(self, Seamap)
	return self
end

-- Add row to the map
-- The east-facing and south-facing cucumbers will be added to separate lists
function Seamap:AddRow(row)
	self.height = self.height + 1
	self.width = #row
	local x = 1
	
	for char in row:gmatch(".") do
		local key = Point2Hash(x, self.height)
		if(char == ">") then
			self.east[key] = char
		elseif(char == "v") then
			self.south[key] = char
		end
		x = x + 1
	end
end

-- Perform a step and return number of moves
-- First, perform all steps on east-facing list
-- Second, perform all steps on south-facing list
function Seamap:Step()
	local moves = 0
	
	-- Since all elements are supposed to move at the same time, use a temp list
	local tmpEast = {}
	for key, val in pairs(self.east) do
		local x, y = Hash2Point(key)
		x = x + 1
		if(x > self.width) then
			x = 1
		end
		
		local right = Point2Hash(x, y)
		if(not self.east[right] and not self.south[right]) then
			tmpEast[right] = val
			moves = moves + 1
		else
			tmpEast[key] = val
		end
	end
	self.east = nil
	self.east = tmpEast
	
	local tmpSouth = {}
	for key, val in pairs(self.south) do
		local x, y = Hash2Point(key)
		y = y + 1
		if(y > self.height) then
			y = 1
		end
		
		local down = Point2Hash(x, y)
		if(not self.east[down] and not self.south[down]) then
			tmpSouth[down] = val
			moves = moves + 1
		else
			tmpSouth[key] = val
		end
	end
	self.south = nil
	self.south = tmpSouth
	
	return moves
end

-- Print the map
function Seamap:Print()
	for y = 1, self.height do
		local line = ""
		for x = 1, self.width do
			local key = Point2Hash(x, y)
			if(self.east[key]) then
				line = line..">"
			elseif(self.south[key]) then
				line = line.."v"
			else
				line = line.."."
			end
		end
		print(line)
	end
	print("")
end

-- Perform steps, moving the cucumbers to the next tile (either right or down) until no movements are made
function PartA(filename)
	local hFile = OpenFile(filename)
	if(hFile == nil) then
		return 0
	end

	local map = Seamap:New()

	local line = hFile:read("*line")	
	while(line) do
		map:AddRow(line)
		line = hFile:read("*line")	
	end
	
	local steps = 0
	
	repeat
		steps = steps + 1
	until(map:Step() == 0)
	
	return steps
end

-- There is no TaskB for day 25, Christmas is saved!!!
-- Return -1
function PartB(filename)
	return -1
end

local input = "inputs/day25.txt"
print(PartA(input))
print(PartB(input))