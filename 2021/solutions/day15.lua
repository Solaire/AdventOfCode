--- Day 15: Chiton ---

require "shared"
PriorityQueue = require("pqueue")

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

-- Calculate manhattan distance between points A and B
local function ManhattanDistance(a, b)
	return math.abs(a[1] - b[1]) + math.abs(a[2] - b[2])
end

-- Simple map structure
Map = {}
Map.__index = Map

-- Constructor
function Map:New()
	self = {}
	self.points = {}
	self.width = 0
	self.height = 0
	
	setmetatable(self, Map)
	return self
end

-- Add row to the map, incrementing the height and width if needed
function Map:AddRow(row)
	self.height = self.height + 1
	self.width = #row
	
	local x = 1
	for char in row:gmatch"." do
		local key = Point2Hash(x, self.height)
		self.points[key] = tonumber(char)
		x = x + 1
	end
end

-- Multiply the map in both directions
-- For each 'tile' increment the point's value by tile index
function Map:Multiply(factor)
	local cpy = {}
	for key, val in pairs(self.points) do
		for x = 0, factor - 1 do
			for y = 0, factor - 1 do
				local ox, oy = Hash2Point(key)
				local k = Point2Hash(ox + (self.width * x), oy + (self.height * y))
				cpy[k] = Tenery( (val + x + y) % 9 == 0, 9, (val + x + y) % 9)
			end
		end
	end
	
	self.points = nil
	self.points = cpy
	
	self.width = self.width * factor
	self.height = self.height * factor
end

-- Find shortest distance between start and finish
-- Return cost of the path
function Map:ShortestDistance(start, finish)
	local heap = PriorityQueue:new('min')
	heap:enqueue(start, 0)
	
	local position = nil
	local offsets = { {x = 1, y = 0}, {x = 0, y = 1},{x = -1, y = 0}, {x = 0, y = -1} }
	local visited = {}
	local cost = {}
	cost[start] = 0
	
	while(heap:len() > 0) do
		position = heap:dequeue()
		if(position == finish) then
			break
		end
		
		for i = 1, #offsets do
			local x, y = Hash2Point(position)
			local newPosition = Point2Hash(x + offsets[i].x, y + offsets[i].y)
			if(self.points[newPosition]) then
				local newCost = cost[position] + self.points[newPosition]
				if(not visited[newPosition] or newCost < cost[newPosition]) then
					cost[newPosition] = newCost
					local x1, y1 = Hash2Point(newPosition)
					local x2, y2 = Hash2Point(finish)
					local priority = newCost + ManhattanDistance({x1, y1}, {x2, y2})
					if(visited[newPosition]) then
						heap:update(newPosition, priority)
					else
						heap:enqueue(newPosition, priority)
					end
					
					visited[newPosition] = position
				end
			end
		end
	end
	return cost[position]
end

-- Shared internal function
-- Load the map from input. If isPartA is false, multiply the map by factor
-- Return the lowest cost of travel from (0,0) -> (w,h)
local function Solve(filename, factor)
	local hFile = OpenFile(filename)
	if(hFile == nil) then
		return 0
	end
	
	local map = Map:New()
	local line = hFile:read("*line")
	while(line) do
		map:AddRow(line, i)
		line= hFile:read("*line")
	end
	
	if(factor > 1) then
		map:Multiply(factor)
	end
	
	start = Point2Hash(1, 1)
	finish = Point2Hash(map.width, map.height)
	return map:ShortestDistance(start, finish)
end

-- Load the map and find the cheapest path
function PartA(filename)
	return Solve(filename, 1)
end

-- Load the map and multiply by 5. 
-- Return cheapest path
function PartB(filename)
	return Solve(filename, 5)
end

local input = "inputs/day15.txt"
print(PartA(input))
print(PartB(input))