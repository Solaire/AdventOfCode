--- Day 3: Binary Diagnostic ---

require "shared"

-- Crude node structure:
-- Filter incoming values on the node filter (if val & filter == filter)
-- All nodes are pre-created when the tree structure is created and values are stored in lists on the leaf nodes
Node = {}
Node.__index = Node

-- Node object constructor
function Node:Create(depth, filter)
	self = {}
	self.left = nil
	self.right = nil
	self.depth = depth
	self.count = 0
	self.leftValues = nil
	self.rightValues = nil
	self.filter = filter
	
	setmetatable(self, Node)
	return self
end

-- Recursively add nodes until specified depth is reached
-- When depth is reached, initialise the left and right value tables
-- Create node filters by right shifting the current node filter
-- (e.g) this.filter = 0x100 -> left.filter = 0x010, right.filter = 0x110
function Node:AddNode(depth)
	if(self.depth < depth) then
		self.left = Node:Create(self.depth + 1, (1 << (depth - (self.depth + 1))))
		self.left:AddNode(depth)
		
		self.right = Node:Create(self.depth + 1, self.filter | (1 << (depth - (self.depth + 1))))
		self.right:AddNode(depth)
	else
		self.leftValues = {}
		self.rightValues = {}
	end
end

-- Pass the value through the filters and insert into the leaf-node table
-- As the value passed through each node, increment the counter
function Node:Insert(value)
	if( (value & self.filter) == self.filter) then
		if(self.rightValues ~= nil) then
			table.insert(self.rightValues, value)
		elseif(self.right ~= nil) then
			self.right:Insert(value)			
		end
	else
		if(self.leftValues ~= nil) then
			table.insert(self.leftValues, value)
		elseif(self.left ~= nil) then
			self.left:Insert(value)			
		end
	end
	self.count = self.count + 1
end

-- Find and return a number based on the frequency of the bit at given position
-- 'maximise' parameter controls if looking for the most common or least common bit
function Node:GetRating(maximise)
	if(self.rightValues ~= nil and self.leftValues ~= nil) then
		if(maximise) then
			return Tenery(#self.rightValues >= #self.leftValues, self.rightValues[1], self.leftValues[1])
		elseif(#self.leftValues > 0 and #self.rightValues > 0) then
			return Tenery(#self.leftValues <= #self.rightValues, self.leftValues[1], self.rightValues[1])
		else
			return Tenery(#self.leftValues > 0, self.leftValues[1], self.rightValues[1])
		end
	else
		local n = nil
		if(maximise) then
			n = Tenery(self.right.count >= self.left.count, self.right, self.left)
		elseif(self.left.count > 0 and self.right.count > 0) then
			n = Tenery(self.left.count <= self.right.count, self.left, self.right)
		else
			n = Tenery(self.left.count > 0, self.left, self.right)
		end
		return n:GetRating(maximise)
	end
	return 0
end

-- Basic wrapper for the Node structure
-- Designed as a crude B-Tree
Tree = {}
Tree.__index = Tree

-- Constructor
function Tree:New(depth)
	self = {}
	self.root = Node:Create(1, (1 << depth - 1))
	self.root:AddNode(depth)
	
	setmetatable(self, Tree)
	return self
end

-- Insert value into the tree
function Tree:Insert(value)
	if(self.root ~= nil) then
		self.root:Insert(value)
	end
end

-- Find and return a number based on the frequency of the bit at given position
-- 'maximise' parameter controls if looking for the most common or least common bit
function Tree:GetRating(maximise)
	if(self.root ~= nil) then
		return self.root:GetRating(maximise)
	end
	return 0
end

-- Parse each input line character-by-character.
-- Increment the number of times '1' occured at given position
-- Create two numbers based on the most and least common bits
function PartA(filename)
	local hFile = OpenFile(filename)
	if(hFile == nil) then
		return 0
	end
	
    local bitCounter = {}
    local lineCounter = 0

    -- Count all  the times 1 appears in the given position
    local line = hFile:read("*line")
    while(line) do
        lineCounter = lineCounter + 1
        local i = 1

        for c in line:gmatch"." do
            if("1" == c and bitCounter[i] ~= nil) then
                bitCounter[i] = bitCounter[i] + 1
            elseif("1" == c) then
                bitCounter[i] = 1
            end
            i = i + 1
        end
        line = hFile:read("*line")
    end

    -- Create two lists which will represent the final binary numbers
    local mostCommon = ""
    local leastCommon = ""
    for i, val in ipairs(bitCounter) do
        if(val == lineCounter / 2) then
            -- Ignore
        elseif(val > lineCounter / 2) then
			mostCommon = mostCommon.."1"
			leastCommon = leastCommon.."0"
        else
			mostCommon = mostCommon.."0"
			leastCommon = leastCommon.."1"
        end
    end
	
	local gamma   = tonumber(mostCommon, 2)
	local epsilon = tonumber(leastCommon, 2)
	return gamma * epsilon
end

-- Parse the input file, adding each value to a B-Tree like structure
-- Find the two values based on the most and least common bits at each position
function PartB(filename)
	local hFile = OpenFile(filename)
	if(hFile == nil) then
		return 0
	end
	
	local line = hFile:read("*line")
	local tree = Tree:New(#line)
	
    while(line) do
		tree:Insert(tonumber(line, 2))
		line = hFile:read("*line")
	end
	local oxygen = tree:GetRating(true)
	local co2 = tree:GetRating(false)
	return oxygen * co2
end

local input = "inputs/day3.txt"
print(PartA(input))
print(PartB(input))