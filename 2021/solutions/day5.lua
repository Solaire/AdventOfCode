--- Day 5: Hydrothermal Venture ---

require "shared"

-- Return the difference of vector a and b
local function LineDirection(a, b)
	local x = math.min(1, math.max(-1, a.x - b.x)) * -1
	local y = math.min(1, math.max(-1, a.y - b.y)) * -1
	return {x = x, y = y}
end

-- Create a map key based on x/y coordinates
local function PointHash(x, y)
	return string.format("%d;%d", x, y)
end

-- Grid object for storing points and number of point collisions
Grid = {}
Grid.__index = Grid

-- Grid constructor
function Grid:New()
	self = {}
	self.points = {} -- Map of points, with coord hash as key 
	self.overlapping = 0
  
	setmetatable(self, Grid)
	return self
end

-- Get the difference between vectors a and b and add the points to the grid.
-- increment collision counter for each overlapping point added.
-- If 'incDiagonal' is true, add diagonal lines as well
function Grid:AddLine(a, b, incDiagonal)
	local direction = LineDirection(a, b)
	if( (not (direction.x == 0) == not (direction.y == 0)) and not incDiagonal) then
		return
	end
	
	local x = a.x
	local y = a.y
	
	repeat 
		local key = PointHash(x, y)
		
		if(self.points[key] == nil) then
			self.points[key] = 1
		elseif(self.points[key] == 1) then
			self.points[key] = 2
			self.overlapping = self.overlapping + 1
		else
			self.points[key] = self.points[key] + 1
		end
		
		x = x + direction.x
		y = y + direction.y
	until(x == b.x + direction.x and y == b.y + direction.y)
end

-- Since task A and B are pretty much the same with one tiny difference, this 
-- function will serve as the main internal solution function
-- Add the lines to the grid and return number of overlapping points
local function Solve(filename, incDiagonal)
	local hFile = OpenFile(filename)
	if(hFile == nil) then
		return 0
	end
	
    local grid = Grid:New()
    
    local line = hFile:read("*line")
    while(line) do
        local points = StringSplit(line, "->")
        local vec1 = StringSplit(points[1], ",")
        local vec2 = StringSplit(points[2], ",")
        
        grid:AddLine(
			{x = tonumber(vec1[1]), y = tonumber(vec1[2])}, 
			{x = tonumber(vec2[1]), y = tonumber(vec2[2])}, incDiagonal)
		
        line = hFile:read("*line")
    end
    return grid.overlapping
end

-- Extract vector pairs and add lines to the grid, ignoring any diagonal lines
-- Return number of points where 2 or more lines overlap
function PartA(filename)
	return Solve(filename, false)
end

-- Extract vector pairs and add lines to the grid, including any diagonal lines
-- Return number of points where 2 or more lines overlap
function PartB(filename)
	return Solve(filename, true)
end

local input = "inputs/day5.txt"
print(PartA(input))
print(PartB(input))