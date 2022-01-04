--- Day 9: Smoke Basin ---

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

-- Grid structure
Heightmap = {}
Heightmap.__index = Heightmap

-- Constructor
function Heightmap:New()
	self = {}
  	self.points = {} -- Map of points, with coord hash as key
	self.width = 0
	self.height = 0
  
	setmetatable(self, Heightmap)
	return self
end

-- Add row to the map, incrementing the height and width if needed
function Heightmap:AddRow(row)
	self.height = self.height + 1
	self.width = #row
	
	local x = 1
	for char in row:gmatch"." do
		local key = Point2Hash(x, self.height)
		self.points[key] = tonumber(char)
		x = x + 1
	end
end

-- Return the value of target point and the 4 adjecent points
-- If any of the points is does not exist (e.g. edge), set that point to 10
function Heightmap:AdjecentPoints(x, y)
	local it    = Tenery(self.points[Point2Hash(x, y)] 	   ~= nil, self.points[Point2Hash(x, y)], 10)
	local up    = Tenery(self.points[Point2Hash(x, y - 1)] ~= nil, self.points[Point2Hash(x, y - 1)], 10)
	local down  = Tenery(self.points[Point2Hash(x, y + 1)] ~= nil, self.points[Point2Hash(x, y + 1)], 10)
	local left  = Tenery(self.points[Point2Hash(x - 1, y)] ~= nil, self.points[Point2Hash(x - 1, y)], 10)
	local right = Tenery(self.points[Point2Hash(x + 1, y)] ~= nil, self.points[Point2Hash(x + 1, y)], 10)
	
	return it, up, down, left, right
end

-- Return the sum of all low point risk levels
-- Risk level is the value of low point + 1
function Heightmap:RiskLevelSum()
	local sum = 0
	for x = 1, self.width do
		for y = 1, self.height do
			local it, u, d, l, r = self:AdjecentPoints(x, y)
			
			if(it < u and it < d and it < l and it < r) then
                sum = sum + (it + 1)
            end
		end
	end
	return sum
end

-- Return a list of all low points (points where all adjecent values are greater than point)
function Heightmap:GetLowPoints()
	local points = {}
	for x = 1, self.width do
		for y = 1, self.height do
			local it, u, d, l, r = self:AdjecentPoints(x, y)
			if(it < u and it < d and it < l and it < r) then
                points[Point2Hash(x, y)] = it
            end
		end
	end
	return points
end

-- Get the product of 3 largest basins
-- Basin value is the number of points that belong to it
-- For each low point:
--   Starting at low point, create a list of valid adjecent points to visit and increment basin size
--   Repeat until the list of points is empty
--   Valid adjecent point is (0 < p < 9) and does not exist in the 'visited' map
function Heightmap:BasinProduct()
	local lowPoints = self:GetLowPoints()
	local visited = {}
	local basins = {}
	
	for point, _ in pairs(lowPoints) do
		local toVisit = {}
		table.insert(toVisit, point)
		
		table.insert(basins, 1)
		
		while(#toVisit > 0) do
			local x, y = Hash2Point(toVisit[1])
			local it, up, down, left, right = self:AdjecentPoints(x, y)
			
			if((it < up and 0 <= up and up <= 8) and visited[Point2Hash(x, y - 1)] == nil) then
				table.insert(toVisit, Point2Hash(x, y - 1))
				visited[Point2Hash(x, y - 1)] = 1
				basins[#basins] = basins[#basins] + 1
			end
			if((it < down and 0 <= down and down <= 8) and visited[Point2Hash(x, y + 1)] == nil) then
				table.insert(toVisit, Point2Hash(x, y + 1))
				visited[Point2Hash(x, y + 1)] = 1
				basins[#basins] = basins[#basins] + 1
			end
			if((it < left and 0 <= left and left <= 8) and visited[Point2Hash(x - 1, y)] == nil) then
				table.insert(toVisit, Point2Hash(x - 1, y))
				visited[Point2Hash(x - 1, y)] = 1
				basins[#basins] = basins[#basins] + 1
			end
			if((it < right and 0 <= right and right <= 8) and visited[Point2Hash(x + 1, y)] == nil) then
				table.insert(toVisit, Point2Hash(x + 1, y))
				visited[Point2Hash(x + 1, y)] = 1
				basins[#basins] = basins[#basins] + 1
			end
			visited[toVisit[1]] = 1
			table.remove(toVisit, 1)
		end
	end
	table.sort(basins)
	return basins[#basins] * basins[#basins - 1] * basins[#basins - 2]
end

-- Shared internal solution function which creates a map and a part-specifi result
local function Solve(filename, isPartA)
	local hFile = OpenFile(filename)
	if(hFile == nil) then
		return 0
	end

    local map = Heightmap:New()
    local line = hFile:read("*line")
    
    while(line) do
		map:AddRow(line)
		line = hFile:read("*line")
    end
    
	if(isPartA) then
		return map:RiskLevelSum()
	else
		return map:BasinProduct()
	end
end

-- Create a height map and return the total risk level
-- Total risk level is defined as sum of all low point risk levels (low point value + 1)
function PartA(filename)
	return Solve(filename, true)
end

-- Create a height map and return the product of the 3 largest basins
-- A basin is collection of points aht flow downward to a single low point (exclusing points with value 9)
function PartB(filename)
	return Solve(filename, false)
end

local input = "inputs/day9.txt"
print(PartA(input))
print(PartB(input))