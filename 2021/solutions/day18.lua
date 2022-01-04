--- Day 18: Snailfish ---

require "shared"
PriorityQueue = require("pqueue")

-- Find the middle point of the string
-- The midpoint should be between pairs, on a ',' character as well as on
-- minimum possible depth since the pairs will be split into single numbers
local function FindMidPoint(line)
	local lowIdx = -1
	local lowDepth = math.huge
	local currentDepth = 0
	
	local i = 1
	for char in line:gmatch(".") do
		if(char == '[') then
			currentDepth = currentDepth + 1
		elseif(char == ']') then
			currentDepth = currentDepth - 1
		elseif(char == ',' and currentDepth < lowDepth) then
			lowDepth = currentDepth
			lowIdx = i
		end
		i = i + 1
	end
	return lowIdx
end

-- Tree node structure
Node = {}
Node.__index = Node

-- Node constructor:
-- Set left and right nodes
-- Set value to nil
function Node:New(parent, left, right)
	self = {}
	self.value = nil
	
	self.parent = parent
	self.left = left
	self.right = right
	
	setmetatable(self, Node)
	return self
end	

-- Leaf node constructor:
-- Set left and right nodes to nil
-- Set value
function Node:NewLeaf(parent, value)
	local root = Node:New(parent, nil, nil)
	root.value = value

	return root
end

-- Recursively construct a number tree from a string (whole line)
-- The string will be split according to the midpoint (basically shallow area in between pairs)
-- Return the root of the number tree
function Node:FromString(parent, line)
	local root = Node:New(parent, nil, nil)
	
	line = string.gsub(line, ' ', '')
	if(string.find(line, ',')) then
		local split = line:sub(2, #line - 1)
		local mid = FindMidPoint(split)
		root.left = Node:FromString(root, string.sub(split, 1, mid - 1))
		root.right = Node:FromString(root, string.sub(split, mid + 1))
	else
		root.value = tonumber(line)
	end
	return root
end

-- Check if the node is a leaf node
-- Leaf node will have a non-nil value
function Node:IsLeaf()
	return self.value ~= nil
end

-- Return the depth of the number tree
-- If not root, call this function recursively
function Node:Depth()
	if(not self.parent) then
		return 1
	end
	return self.parent:Depth() + 1
end

-- Find the node suitable for performing an explosion
-- A node is suitable if it's a middle node (non-leaf) and has the depth > 4
function Node:FindExplode()
	if(self.left) then
		local left = self.left:FindExplode()
		if(left) then
			return left
		end
	end
	
	if(self:Depth() > 4 and not self:IsLeaf()) then
		return self
	end
	
	if(self.right) then
		local right = self.right:FindExplode()
		if(right) then
			return right
		end
	end
	
	return nil
end

-- Perform explosion on a node
-- To explode a pair, the pair's left value is added to the first regular 
-- 	 number to the left of the exploding pair (if any), and the pair's right 
-- 	 value is added to the first regular number to the right of the exploding 
-- 	 pair (if any). Exploding pairs will always consist of two regular numbers. 
-- 	 Then, the entire exploding pair is replaced with the regular number 0.
--
-- Traverse up the tree and find the rightmost leaf node to the left of this node 
-- and the leftmost leaf to the right of this node
function Node:DoExplode()
	local pathToRoot = {}	
	local current = self
	
	while(current) do
		pathToRoot[current] = true
		current = current.parent
	end
	
	-- Explode leftwards
	local heap = PriorityQueue:new('min')
	local visited = {}
	heap:enqueue(self.parent, 3)
	visited[self] = true
	
	while(heap:len() > 0) do
		local node = heap:dequeue()
		if(not visited[node]) then
			visited[node] = true
			
			if(node:IsLeaf()) then
				node.value = node.value + self.left.value
				break
			end
			
			if(node.right and not pathToRoot[node] and not visited[node.right]) then
				heap:enqueue(node.right, 1)
			end
			if(node.left and not visited[node.left]) then
				heap:enqueue(node.left, 2)
			end
			if(node.parent and not visited[node.parent]) then
				heap:enqueue(node.parent, 3)
			end
		end
	end
	
	-- Explode rightwards
	heap = nil
	visited = nil
	
	heap = PriorityQueue:new('min')
	visited = {}
	heap:enqueue(self.parent, 3)
	visited[self] = true
	
	while(heap:len() > 0) do
		local node = heap:dequeue()
		if(not visited[node]) then
			visited[node] = true
			
			if(node:IsLeaf()) then
				node.value = node.value + self.right.value
				break
			end
			
			if(node.left and not pathToRoot[node] and not visited[node.left]) then
				heap:enqueue(node.left, 1)
			end
			if(node.right and not visited[node.right]) then
				heap:enqueue(node.right, 2)
			end
			if(node.parent and not visited[node.parent]) then
				heap:enqueue(node.parent, 3)
			end
		end
	end
	
	self.value = 0
	self.left = nil
	self.right = nil
end

-- Find node suitable for splitting, which is a leaf node with a valud >= 10
function Node:FindSplit()
	if(self.left) then
		local left = self.left:FindSplit()
		if(left) then
			return left
		end
	end
	
	if(self:IsLeaf() and self.value >= 10) then
		return self
	end
	
	if(self.right) then
		local right = self.right:FindSplit()
		if(right) then
			return right
		end
	end
	
	return nil
end

-- Perform a split operation, creating two leaf nodes - left and right.
-- Left node's value is floor(self.value/2)
-- Right node's value is ceil(self.value/2)
-- Set this node into a non-leaf node
function Node:DoSplit()
	if(self.value and self.left and self.right) then
		print("This note is not splitable!")
		return
	end
	
	self.left = Node:NewLeaf(self, math.floor(self.value / 2.0))
	self.right = Node:NewLeaf(self, math.ceil(self.value / 2.0))
	self.value = nil
end

-- Reduce the number tree
-- Find nodes suitable for explosions and splitting and perform those actions
-- Repeat until no suitable nodes are found
function Node:Reduce()
	local hasDoneSomething = false
	repeat
		hasDoneSomething = false
		
		local explode = self:FindExplode()
		local split	  = self:FindSplit()
		if(explode) then
			explode:DoExplode()
			hasDoneSomething = true
		elseif(split) then
			split:DoSplit()
			hasDoneSomething = true
		end
	until(not hasDoneSomething)
end

-- Recursively build a string from the number tree
-- The string should look just like equivalent input
function Node:ToString()
	if(self.value) then
		return string.format("%d", self.value)
	end
	return string.format("[%s,%s]", self.left:ToString(), self.right:ToString())
end

-- Create new root node, set the left and right nodes to copies of nodes a and b
-- Reduce the number tree
function Node:Add(a, b)
	local left = Node:FromString(nil, a:ToString())
	local right = Node:FromString(nil, b:ToString())
	
	local root = Node:New(nil, left, right)
	left.parent = root
	right.parent = root
	
	root:Reduce()
	return root
end

-- Recursively return the magnitute of the number tree
function Node:Magnitude()
	if(self:IsLeaf()) then
		return self.value
	end
	return (3 * self.left:Magnitude()) + (2 * self.right:Magnitude())
end

-- Shared internal function
-- Load the expressions and create a number tree for each
-- If isPartA, add all expressions together and return the magnitude of the final sum
--  otherwise, find out the largest magnitude from adding just two of the numbers
local function Solve(filename, isPartA)
	local hFile = OpenFile(filename)
	if(hFile == nil) then
		return 0
	end

	local nodes = {}
	local line = hFile:read("*line")	
	while(line) do
		table.insert(nodes, Node:FromString(nil, line))
		line = hFile:read("*line")	
	end
	
	-- Sum all expressions up and get maximum magnitude
	if(isPartA) then
		local sum = nodes[1]
		for i = 2, #nodes do
			sum = Node:Add(sum, nodes[i])
		end
		print(sum:ToString())
		return sum:Magnitude()
	end
	
	-- Add just two of the numbers up and return the largest magnitude
	-- Important to note that the addition will have different result based on the order
	-- a + b != b + a
	local max = 0
	for i = 1, #nodes do
		for ii = i + 1, #nodes do
			local a = Node:Add(nodes[i], nodes[ii]):Magnitude()
			local b = Node:Add(nodes[ii], nodes[i]):Magnitude()
			if(max < a) then
				max = a
			end
			if(max < b) then
				max = b
			end
		end
	end
	
	return max
end

-- Add all numbers in the input list and return the magnitute of the final sum
function PartA(filename)
	return Solve(filename, true)
end

-- Create sums of two expressions at a time
-- Return the maximum magnitude
function PartB(filename)
	return Solve(filename, false)
end

local input = "inputs/day18.txt"
print(PartA(input))
print(PartB(input))