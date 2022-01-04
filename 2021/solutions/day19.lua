--- Day 19: Beacon Scanner ---

require "shared"
local Queue = require "queue"

-- Structure representing a single beacon
Beacon = {}
Beacon.__index = Beacon

-- Contructor
function Beacon:New(x, y, z)
	self = {}
	self.x = x
	self.y = y
	self.z = z
	
	setmetatable(self, Beacon)
	return self
end

-- Construct new point object from a hash
function Beacon:FromHash(hash)
	local split = StringSplit(hash, ';')
	return Beacon:New(tonumber(split[1]), tonumber(split[2]), tonumber(split[3]))
end

-- Convert beacon's x,y,z coordinates to a string hash
function Beacon:Hash()
	return string.format("%d;%d;%d", self.x, self.y, self.z)
end

-- Calculate the distance between this beacon and another
function Beacon:ManhattanDistance(other)
	return math.abs(other.x - self.x) + math.abs(other.y - self.y) + math.abs(other.z - self.z)
end

-- Add this point's coordinates to another's and return the sum as a new point object
function Beacon:Add(other)
	return Beacon:New(self.x + other.x, self.y + other.y, self.z + other.z)
end

-- Add this point's coordinates from another's and return the difference as a new point object
function Beacon:Subtract(other)
	return Beacon:New(self.x - other.x, self.y - other.y, self.z - other.z)
end

-- Invert this point's coordinates and return the inverse as a new point object
function Beacon:Invert()
	return Beacon:New(-self.x, -self.y, -self.z)
end

-- Rotate this point, according to rotation value and return the rotation as a new point object
-- The value of 'rotation' must be between 0..23
function Beacon:Rotate(rotation)
	local x = self.x
	local y = self.y
	local z = self.z
	
	if(rotation == 0) then
		return Beacon:New(x, y, z)
	end
    if(rotation == 1) then
        return Beacon:New(x, -z, y)
	end
    if(rotation == 2) then
        return Beacon:New(x, -y, -z)
	end
    if(rotation == 3) then
        return Beacon:New(x, z, -y)
	end
    if(rotation == 4) then
        return Beacon:New(-x, -y, z)
	end
    if(rotation == 5) then
        return Beacon:New(-x, -z, -y)
	end
	if(rotation == 6) then
        return Beacon:New(-x, y, -z)
	end
    if(rotation == 7) then
        return Beacon:New(-x, z, y)
	end
    if(rotation == 8) then
        return Beacon:New(y, x, -z)
	end
    if(rotation == 9) then
        return Beacon:New(y, -x, z)
	end
    if(rotation == 10) then
        return Beacon:New(y, z, x)
	end
    if(rotation == 11) then
        return Beacon:New(y, -z, -x)
	end
    if(rotation == 12) then
        return Beacon:New(-y, x, z)
	end
    if(rotation == 13) then
        return Beacon:New(-y, -x, -z)
	end
    if(rotation == 14) then
        return Beacon:New(-y, -z, x)
	end
	if(rotation == 15) then
        return Beacon:New(-y, z, -x)
	end
    if(rotation == 16) then
        return Beacon:New(z, x, y)
	end
    if(rotation == 17) then
        return Beacon:New(z, -x, -y)
	end
    if(rotation == 18) then
        return Beacon:New(z, -y, x)
	end
    if(rotation == 19) then
        return Beacon:New(z, y, -x)
	end
    if(rotation == 20) then
        return Beacon:New(-z, x, -y)
	end
    if(rotation == 21) then
        return Beacon:New(-z, -x, y)
	end
    if(rotation == 22) then
        return Beacon:New(-z, y, x)
	end
    if(rotation == 23) then
        return Beacon:New(-z, -y, -x)
	end
	return Beacon:New(0, 0, 0)
end

local function Solve(filename, isPartA)
	local hFile = OpenFile(filename)
	if(hFile == nil) then
		return 0
	end

	-- Store the beacons in groups i.e. clusters
	-- clusterQueue contains a queue of clusters, which will be processed one at a time
	local cluster = {}
	local clusterQueue = Queue:New()
	
	-- Create the clusters and queue
	local line = hFile:read("*line")
	local count = 0
	
	while(line) do
		if(line:sub(1, 3) == "---") then -- New scanner. Start new cluster
			if(count > 0) then
				Queue.pushright(clusterQueue, cluster)
			end
			cluster = nil
			cluster = {}
			count = 0
		elseif(line ~= "") then
			local split = StringSplit(line, ',')
			local beacon = Beacon:New(tonumber(split[1]), tonumber(split[2]), tonumber(split[3]))
			cluster[beacon:Hash()] = beacon
			count = count + 1
		end
		line = hFile:read("*line")
	end
	if(count > 0) then
		Queue.pushright(clusterQueue, cluster)
	end
	
	-- The orientation of all points and scanners is based from the first cluster's orientation
	local fullmap = {}
	local scannerPositions = {}
	fullmap = Queue.popleft(clusterQueue)
	table.insert(scannerPositions, Beacon:New(0, 0, 0))
	
	while(clusterQueue.first <= clusterQueue.last) do
		print(string.format("First: %d, Last: %d", clusterQueue.first, clusterQueue.last))
		
		local cluster = Queue.popleft(clusterQueue)
		local match = false
		
		-- We have to rotate the current scanner in all ways to find a match
		-- There are 24 possble rotations of a d6 
		for rotation = 0, 23 do
			local offsets = {}
			for _, beacon in pairs(fullmap) do
				for _, point in pairs(cluster) do
					local rotated = point:Rotate(rotation)
					local offset = rotated:Subtract(beacon)
					if(not offsets[offset:Hash()]) then
						offsets[offset:Hash()] = 1
					else
						offsets[offset:Hash()] = offsets[offset:Hash()] + 1
					end
				end
			end
			for hash, count in pairs(offsets) do
				if(count >= 12) then
					match = true
					local offset = Beacon:FromHash(hash)
					local scanner = offset:Invert()
					table.insert(scannerPositions, scanner)
					for _, point in pairs(cluster) do
						local rotated = point:Rotate(rotation)
						local pointSum = rotated:Add(scanner)
						fullmap[pointSum:Hash()] = pointSum
					end
				end
			end
			if(match) then -- Got match, break out
				break
			end
		end
		
		-- Could not find a match at this time
		-- Put this cluster back at the end of the queue
		if(not match) then
			Queue.pushright(clusterQueue, cluster)
		end
	end
	
	-- Return number of unique beacons
	if(isPartA) then
		local total = 0
		for _, _ in pairs(fullmap) do
			total = total + 1
		end
		return total
	end

	-- Calculate distance between pairs of scanners
	local distance = -1
	for i = 1, #scannerPositions do
		for ii = i + 1, #scannerPositions do
			if(scannerPositions[i]:ManhattanDistance(scannerPositions[ii]) > distance) then
				distance = scannerPositions[i]:ManhattanDistance(scannerPositions[ii])
			end
		end
	end
	
	return distance
end

-- Map all scanners and beacons onto a 3d grid
-- Return the number of unqiue scanners
function PartA(filename)
	return Solve(filename, true)
end

-- Map all scanners and beacons onto a 3d grid
-- Return the largest manhattan dsitance between two scanners
function PartB(filename)
	return Solve(filename, false)
end

local input = "inputs/day19.txt"
print(PartA(input))
print(PartB(input))