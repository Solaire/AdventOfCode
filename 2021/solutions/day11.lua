--- Day 11: Dumbo Octopus ---

require "shared"

-- Create a map key based on x/y coordinates
local function Point2Hash(x, y)
	return string.format("%d;%d", x, y)
end

-- Grid structure for holind octopods
OctopusMap = {}
OctopusMap.__index = OctopusMap

-- Constructor
function OctopusMap:New()
	self = {}
  	self.points = {} -- Map of octopods, with coord hash as key
	self.flashTotal = 0
	self.flashStep  = 0
	self.width = 0
	self.height = 0
  
	setmetatable(self, OctopusMap)
	return self
end

-- Add row to the map, incrementing the height and width if needed
function OctopusMap:AddRow(row)
	self.height = self.height + 1
	self.width = #row
	
	local x = 1
	for char in row:gmatch"." do
		local key = Point2Hash(x, self.height)
		self.points[key] = tonumber(char)
		x = x + 1
	end
end

-- Increment energy level at point x,y
-- If energy level >= 9, set to zero and increment flash counters
-- Return true if flashed
function OctopusMap:IncrementEnergy(x, y)
	local key = Point2Hash(x, y)
	if(self.points[key] == nil or self.points[key] == 0) then
		return false
	end
	
	if(self.points[key] >= 9) then
		self.points[key] = 0
		self.flashTotal = self.flashTotal + 1
		self.flashStep = self.flashStep + 1
		return true
	end
	
	self.points[key] = self.points[key] + 1
	return false
end

-- Return a list of points adjecent to x, y
function GetAdjecentPoints(x, y)
	local points = {}
	table.insert(points, { x - 1, y - 1 })
	table.insert(points, { x	, y - 1 })
	table.insert(points, { x + 1, y - 1 })
	table.insert(points, { x - 1, y		})
	table.insert(points, { x + 1, y	 	})
	table.insert(points, { x - 1, y + 1 })
	table.insert(points, { x	, y + 1 })
	table.insert(points, { x + 1, y + 1 })
	return points
end

-- Increment energy for adjecent points
-- If any point flashes, increment points of that one (and so on)
function OctopusMap:IncrementAdjecent(x, y)
	local points = GetAdjecentPoints(x, y)
	for i = 1, #points do
		local ax = points[i][1]
		local ay = points[i][2]
		
		if(self:IncrementEnergy(ax, ay)) then
			self:IncrementAdjecent(ax, ay)
		end
	end
end

-- Perform a single step
-- Reset flashStep counter to 0 and increment all energy levels by 1
-- For each energy level >= 9, increment adjecent cells (repeat until all flashes occur)
function OctopusMap:Step()
	for x = 1, self.width do
		for y = 1, self.height do
			local key = Point2Hash(x, y)
			self.points[key] = self.points[key] + 1
		end
	end
	
	self.flashStep = 0
	for x = 1, self.width do
		for y = 1, self.height do
			local key = Point2Hash(x, y)
			if(self.points[key] > 9) then
				self.points[key] = 0
				self.flashTotal = self.flashTotal + 1
				self.flashStep = self.flashStep + 1
				self:IncrementAdjecent(x, y)
			end
		end
	end
	
	return self.flashStep
end

-- Create map and add rows
-- Perform 100 steps and return the sum of all flashes
function PartA(filename)
	local hFile = OpenFile(filename)
	if(hFile == nil) then
		return 0
	end
	
	map = OctopusMap:New()
	local line = hFile:read("*line")
	while(line) do
        map:AddRow(line)
        line = hFile:read("*line")
    end
	
	for i = 1, 100 do
		map:Step()
	end
	return map.flashTotal
end

-- Create map and add rows
-- Perform steps until the number of flashes for the step equals to map size
function PartB(filename)
	local hFile = OpenFile(filename)
	if(hFile == nil) then
		return 0
	end
	
	map = OctopusMap:New()
	local line = hFile:read("*line")
	while(line) do
        map:AddRow(line)
        line = hFile:read("*line")
    end
	
	local steps = 1
	while(steps < 1000000) do -- Timeout
		if(map:Step() == map.width * map.height) then
			break
		end
		steps = steps + 1
	end
	return steps
end

local input = "inputs/day11.txt"
print(PartA(input))
print(PartB(input))
