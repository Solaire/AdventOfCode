--- Day 12: Passage Pathing ---

require "shared"

-- Map structure, containing nodes and links
Map = {}
Map.__index = Map

-- Constructor
function Map:New()
	self = {}
	self.all = {}
	self.upper = {}
	
	setmetatable(self, Map)
	return self
end

-- Insert node into the map
-- Ignore if node already exists
function Map:Insert(node)
	if(not self.all[node]) then
		self.all[node] = {}
		if(node:match("%u")) then
			self.upper[self.all[node]] = true
		end
	end
end

-- Connect node 1 with node 2 if the links is not "start" -> "end"
function Map:Connect(n1, n2)
	if(n1 ~= "start" and n2 ~= "end") then
		table.insert(self.all[n2], self.all[n1])
	end
end

-- Walk from current node, towards the end, keeping track of already visited nodes
-- Return number of paths from currentNode to "end"
-- Basically depth-first-search with memoization
function Map:Walk(visited, currentNode, canBacktrack)
	if(currentNode == self.all["end"]) then
		return 1
	end
	
	-- Lower case node, check if we can visit
	if(visited[currentNode] and not self.upper[currentNode]) then
		if(visited.first or not canBacktrack) then
			return 0
		end
		
		-- visited.first will remember the first lowercase node that has been visited twice
		if(currentNode ~= self.all["start"]) then
			visited.first = currentNode
		end
	end
	
	-- Mark this node as visited
	-- Iterate through all linked nodes and walk from there
	visited[currentNode] = true
	local count = 0
	for i, n in ipairs(currentNode) do
		count = count + self:Walk(visited, n, canBacktrack)
	end
	
	if(visited.first == currentNode) then
		visited.first = nil
	else
		visited[currentNode] = nil
	end
	return count
end

-- Internal shared function to selve part A or B
-- canBacktrack -> if true one lowercase cave can be visited twice, otherwise they can only be visited one
local function Solve(filename, canBacktrack)
	local hFile = OpenFile(filename)
	if(hFile == nil) then
		return 0
	end
	
	map = Map:New()
	local line = hFile:read("*line")
	while(line) do
		local path = StringSplit(line, '-')
		map:Insert(path[1])
		map:Insert(path[2])
		map:Connect(path[1], path[2])
		map:Connect(path[2], path[1])
		line = hFile:read("*line")
	end
	
	return map:Walk({}, map.all["start"], canBacktrack)
end

-- Return number of possible paths from [start] to [end] 
--   where lower case all can only be visited once
function PartA(filename)
	return Solve(filename, false)
end

-- Return number of possible paths from [start] to [end] 
--   where only one lower case all can be visited twice
function PartB(filename)
	return Solve(filename, true)
end

local input = "inputs/day12.txt"
print(PartA(input))
print(PartB(input))
