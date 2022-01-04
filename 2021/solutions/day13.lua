--- Day 13: Transparent Origami ---

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

-- Grid structure holding points, which can be folded
Paper = {}
Paper.__index = Paper

-- Constructor
function Paper:New()
	self = {}
	self.points = {}
	self.count = 0
	self.width = 0
	self.height = 0
	
	setmetatable(self, Paper)
	return self
end

-- Add point to the grid
function Paper:AddPoint(x, y)
	local key = Point2Hash(x, y)
	if(not self.points[key]) then
		self.points[key] = true
		self.count = self.count + 1
		
		if(self.width < x) then
			self.width = x
		end
		if(self.height < y) then
			self.height = y
		end
	end
end

-- Fold paper along axis, adding and removing points
function Paper:Fold(axis, position)
	local remove = {}
	local add = {}
	
	-- Iterate the map of points
	-- For each point on the folind side, calculate its mirror position and add to 'add' list
	-- Remove any points from map which are >= folding line
	for key, value in pairs(self.points) do
		local x, y = Hash2Point(key)
		
		if(axis == "x" and x > position) then
			local mirror = position - (x - position)
			local k = Point2Hash(mirror, y)
			
			if(self.points[k]) then
				self.count = self.count - 1
			else
				table.insert(add, k)
			end
			table.insert(remove, key)
			
		elseif(axis == "y" and y > position) then
			local mirror = position - (y - position)
			local k = Point2Hash(x, mirror)
			
			if(self.points[k]) then
				self.count = self.count - 1
			else
				table.insert(add, k)
			end
			table.insert(remove, key)
			
		elseif( (axis == "x" and x == position) or (axis == "y" and y == position) ) then
			self.count = self.count - 1
			table.insert(remove, key)
		end
	end
	
	-- Add and remove points
	-- Since we're iterating a map, it's not safe to mutate it mid-loop
	for i = 1, #add do
		self.points[add[i]] = true
	end
	for i = 1, #remove do
		self.points[remove[i]] = nil
	end
	
	-- Adjust paper size
	if(axis == "x") then
		self.width = position - 1
	else
		self.height = position - 1
	end
end

-- Draw the current paper
-- '#' represents a valid point, '.' is empty space
function Paper:Draw()
	for y = 0, self.height do
		local line = ""
		for x = 0, self.width do
			line = line..Tenery(self.points[Point2Hash(x, y)], '#', '.')
		end
		print(line)
	end
	print("")
end

-- Shared internal function
-- Create grid from input and fold the grid according to instructions
-- isPartA -> If true, return number of points after first fold
--			  If false, fold completly and print the 8-letter code
local function Solve(filename, isPartA)
	local hFile = OpenFile(filename)
	if(hFile == nil) then
		return 0
	end
	
	local page = Paper:New()
	local line = hFile:read("*line")
	while(line) do
		if(line == "") then 
			line = hFile:read("*line")
			break -- instructions part of the input
		end
		local xy = StringSplit(line, ',')
		page:AddPoint(tonumber(xy[1]), tonumber(xy[2]))
		line = hFile:read("*line")
	end
	
	-- Start folding
	while(line) do
		local split = StringSplit(line, ' ')
		local fold  = StringSplit(split[3], '=')
		
		page:Fold(fold[1], tonumber(fold[2]))
		
		if(isPartA) then
			return page.count
		end
		
		line = hFile:read("*line")
	end
	
	page:Draw()
	return -1
end

-- Load the grid and fold once.
-- Return number of points
function PartA(filename)
	return Solve(filename, true)
end

-- Load the grid and fold according to input instructions.
-- Return -1 since the output are some ASCII-art letters
function PartB(filename)
	return Solve(filename, false)
end

local input = "inputs/day13.txt"
print(PartA(input))
print(PartB(input))
