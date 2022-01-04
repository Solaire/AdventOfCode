--- Day 6: Lanternfish ---

require "shared"

-- Structure representing a group of fish with a specified timer
Fish = {}
Fish.__index = Fish

-- Constructor:
-- Set the timer and initial count
function Fish:New(timer, initCount)
	self = {}
	self.visited = false
	self.timer = timer
	self.count = initCount
	self.cache = 0
	self.left = nil
	self.right = nil
	
	setmetatable(self, Fish)
	return self
end

-- Link the fish group with up to two other fish groups
function Fish:Link(left, right)
	self.left = left
	self.right = right
end

-- Process fish group ageing
-- If group has not been visited:
-- 		Store the original fish count in the internal cache, and set the new count
--  	Pass the cached count to the left and right pointers (if available) by calling their own 'Age' functions
--  	After the function cycle is broken, clear cache and reset 'visited' flag to false
--
-- If group has already been visited:
--  	Clear cache, reset 'visited' flag to false and add the value parameter to the cinternal counter
-- 
-- This function will calculate and return the total number of fish at each cycle.
-- this is done by returning the sum of all 'newCount' parameters passed in the chain since they 
-- either represent the fish count in group (if not visited) or additional fish (if visited)
--
-- newCount : int -> if visited, increase the exisitng counter by the parameter, else set the counter to param value
function Fish:Age(newCount)
	if(self.visted) then -- Already been visited, apply value, clear cache and flag
		self.visted = false
		self.count = self.count + newCount
		self.cache = 0
		return newCount
	end
	
	local total = 0
	
	-- Set the visited flag so that we hit this part of code once per cycle
	self.visted = true
	self.cache = Tenery(self.count == nil, 0, self.count)
	self.count = newCount
	if(self.left ~= nil) then
		total = total + self.left:Age(self.cache)
	end
	if(self.right ~= nil) then
		total = total + self.right:Age(self.cache)
	end
	
	total = total + newCount
	
	-- Cleanup for next cycle
	self.visted = false
	self.cache = 0
	
	return total
end

-- Chaining structure
local NEW_FISH 	  = 8
local RESET_TIMER = 6

local FISH_TIMERS = {}
FISH_TIMERS[8] = {7, nil}
FISH_TIMERS[7] = {6, nil}
FISH_TIMERS[6] = {5, nil}
FISH_TIMERS[5] = {4, nil}
FISH_TIMERS[4] = {3, nil}
FISH_TIMERS[3] = {2, nil}
FISH_TIMERS[2] = {1, nil}
FISH_TIMERS[1] = {0, nil}
FISH_TIMERS[0] = {RESET_TIMER, NEW_FISH}

-- Since task A and B are pretty much the same with one tiny difference, this 
-- function will serve as the main internal solution function
-- Create a crude looped linked-list of fish groups and simulate their growth
-- 
-- This whole linked-list is probably an overkill and, frankly the original solution with arrays was better.
-- That being said, I wanted to try the cyclic linked-list implementation since after all the initialisation
-- only one function is called in the loop
local function Solve(filename, days)
	local hFile = OpenFile(filename)
	if(hFile == nil) then
		return 0
	end
	
	-- Parse input
	local timers = {}
	for line in (hFile:read("*line")..','):gmatch("(.-)"..',') do
        if(line ~= "") then
			local num = tonumber(line)
			if(timers[num] == nil) then
				timers[num] = 1
			else
				timers[num] = timers[num] + 1
			end
        end
    end
	
	-- Create Fish groups
	local fish = {}
	for i = 0, #FISH_TIMERS do
		fish[i] = Fish:New(i, timers[i])
		fish[i]:Link(fish[FISH_TIMERS[i][1]], fish[FISH_TIMERS[i][2]])
	end
	fish[0]:Link(fish[FISH_TIMERS[0][1]], fish[FISH_TIMERS[0][2]]) -- Set pointers from first object
	
	-- Simulate growth, starting from the group for new fish
	local counter = 0
	for i = 1, days do
		counter = fish[NEW_FISH]:Age(0)
	end
	
	return counter
end

-- Simulate fish growth for 80 days
-- Return number of lanternfish 
function PartA(filename)
	return Solve(filename, 80)
end

-- Simulate fish growth for 256 days
-- Return number of lanternfish 
function PartB(filename)
	return Solve(filename, 256)
end

local input = "inputs/day6.txt"
print(PartA(input))
print(PartB(input))