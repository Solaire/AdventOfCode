--- Day 23: Amphipod ---

require "shared"
PriorityQueue = require("pqueue")

ROOM_SIZE = 4 -- Initial, will be changed depending on Part A or B

-- Map of amphipod type (letter) to their correct row index
MAP_AMPHIPOD_TO_POSITION = 
{ 
	A = 4, 
	B = 6, 
	C = 8, 
	D = 10 
}

-- Map of row index (burrow) to the amphipod type
MAP_POSITION_TO_AMPHIPOD = 
{ 
	[4] = "A", 
	[6] = "B", 
	[8] = "C", 
	[10] = "D" 
}

-- Map of amphipod type to cost
AMPHIPOD_COST = 
{ 
	A = 1, 
	B = 10, 
	C = 100, 
	D = 1000 
}

-- Convert an x,y coordinate to a string hash
local function Point2Hash(x, y)
	return string.format("%d,%d", x, y) 
end

-- Convert a string hash to a pair of x,y coordinates
local function Hash2Point(hash)
	local x, y = string.match(hash, "(%d+),(%d+)")
	return tonumber(x), tonumber(y)
end

-- Return distance between two x,y points
-- Distance is the sum of the absolute differences on each axis
local function Distance(x1, y1, x2, y2)
	return math.abs(x1 - x2) + math.abs(y1 - y2) 
end

-- Return a string representation of the board
-- The 4 leftmost characters are the top values in the burrows, followed by 12 'hall' characters
-- finishing with all remaining burrow values
--
-- Example input table: 
-- {["4,3"] = "A", ["4,4"] = "D", ["6,3"] = "C", ["6,4"] = "D", ["8,3"] = "B", ["8,4"] = "A", ["10,3"] = "B", ["10,4"] = "C"}
-- Expected output string:
-- "ACBB...........DDAC"
local function ToString(board)
	-- Copy the top value (amphipod or '.') of each burrow into a buffer table
	local buf = {board["4,3"] or ".", board["6,3"] or ".", board["8,3"] or ".", board["10,3"] or "."}
	
	-- Iterate each "hall" cell and add the value (amphipod or '.') to the buffer
	for i = 2, 12 do 
		table.insert(buf, board[string.format("%d,%d",i,2)] or ".") 
	end

	-- Add remaining burrow values to the end of the buffer
	for i = 4, ROOM_SIZE + 2 do
		table.move(
		{board["4,"..i] or ".", board["6,"..i] or ".", board["8,"..i] or ".", board["10,"..i] or "."},
		1, 4, #buf + 1, buf
		)
	end
	return table.concat(buf)
end

-- Generate the end state for the serach function to move towards
-- Return the end state as a string representation
-- The amphipod positions at end state are as follows:
-- ###A#B#C#D###
--   #A#B#C#D#
--   #########
local function GenerateEndState()
	local state = {}
	for x = 4, 10, 2 do
		for y = 3, ROOM_SIZE + 2 do
			state[Point2Hash(x,y)] = MAP_POSITION_TO_AMPHIPOD[x]
		end
	end
	return ToString(state)
end

-- Calculate path from x1y1 to x2y2
local function CalculatePath(x1, y1, x2, y2)
	local steps = {}
	
	-- Move up
	if(y1 > 2) then 
		for i = y1 - 1, 2, -1 do 
			table.insert(steps, Point2Hash(x1, i)) 
		end
	end
		
	-- Move to the right
	if(x2 > x1) then 
		for i = x1 + 1, x2 do 
			table.insert(steps, Point2Hash(i, 2)) 
		end 
	end
	
	-- Move left
	if(x2 < x1) then 
		for i = x1 - 1, x2, -1 do 
			table.insert(steps, Point2Hash(i, 2)) 
		end 
	end
	
	-- Move down
	if(y2 > 2) then 
		for i = 3, y2 do 
			table.insert(steps, Point2Hash(x2, i)) 
		end 
	end
	
	return steps
end

-- Check if specified path can be traversed with current board state
-- A path can be traversed when all steps are not in the board
local function IsPathFree(board, steps)
	for _, step in ipairs(steps) do
		if(board[step]) then 
			return false
		end
	end
	return true
end

-- Perform the movements in the "moves" list and return the new state and movement cost
function DoMove(start, moves)
	
	-- Lambda function
	-- Perform a movement from position x1y1, to x2y2
	-- Return the new board state and the cost of movement
	local function Move(board, x1, y1, x2, y2)
		local newBoard, from = {}, board[Point2Hash(x1,y1)]
		for k, v in pairs(board) do 
			newBoard[k] = v 
		end
	
		newBoard[Point2Hash(x2,y2)] = from; 
		newBoard[Point2Hash(x1,y1)] = nil
		return newBoard, #CalculatePath(x1, y1, x2, y2) * AMPHIPOD_COST[from]
	end
	
	-- DoMove() function begin
	local cost, board = 0, start
	for _, m in ipairs(moves) do
		local nextBoard, nextCost = Move(board, m[1], m[2], m[3], m[4])
		cost = cost + nextCost
		board = nextBoard
	end
	return board, cost
end

-- Return the list of suitable movement targets for the amphipod
-- The amphipod target position and all valid hallway locations are checked
-- only free and non-blocking positions are returned
function GetPossibleTargets(board, x, y)
	local cell = board[Point2Hash(x, y)]

	-- If we're already in a possible final destination, stay there
	if(y > 2 and x == MAP_AMPHIPOD_TO_POSITION[cell]) then
		local shouldStay = true
		
		-- Can't stay if any of the values in cells below are wrong. Check
		for i = y, ROOM_SIZE + 2 do
			if(board[Point2Hash(x,i)] ~= cell) then 
				shouldStay = false 
			end 
		end
		
		-- All good
		if(shouldStay) then 
			return {} 
		end
	end

	-- Add the cell's target position as well as the hallway positions to a list for consideration
	local candidates = {}
	for i = 3, ROOM_SIZE + 2 do 
		table.insert(candidates, Point2Hash(MAP_AMPHIPOD_TO_POSITION[cell], i)) 
	end
	if(y > 2) then -- Only if in a cell
		table.move({"2,2", "3,2", "5,2", "7,2", "9,2", "11,2", "12,2"}, 1, 7, #candidates + 1, candidates)
	end

	-- Check each candidate and add good ones to the final list
	local final = {}
	for _, t in ipairs(candidates) do
		-- Target is already occupied or ...
		-- Target is self
		if(board[t] or t == cell) then 
			goto skip
		end

		-- Path to target is blocked
		local x2, y2 = Hash2Point(t)
		local steps = CalculatePath(x, y, x2, y2)
		if(not IsPathFree(board, steps)) then 
			goto skip 
		end

		-- If any free location is a possible final destination, return only that
		if(y2 > 2) then
			local isDestination = true
			for i = y2 + 1, ROOM_SIZE + 2 do
				if(board[Point2Hash(x2,i)] ~= cell) then 
					isDestination = false 
				end
			end
			if(isDestination) then 
				return {t} 
			else 
				goto skip 
			end
		end
		
    table.insert(final, t)
	
    ::skip::
	end

	return final
end

-- Returns the board we can transition to from the current
-- state. Try every possible move, although some obviously wasteful moves are
-- discarded by "GetPossibleTargets".
function Neighbours(state)
	local moves = {}
	
	-- Generate list of possible movements for this cell
	for k, v in pairs(state.board) do
		local x, y = Hash2Point(k)
		local targets = GetPossibleTargets(state.board, x, y)
		if(#targets > 0) then
			for _, t in ipairs(targets) do
				local x2, y2 = Hash2Point(t)
			table.insert(moves, {x, y, x2, y2})
			end
		end
	end

	-- Perform the movements and return the list of next states
	local nextStates = {}
	for _, m in ipairs(moves) do
		local newBoard, newCost = DoMove(state.board, {m})
		local newState = { board = newBoard, total = state.total + newCost, cost = newCost }
		local key = ToString(newState.board)
		newState.key = key
		table.insert(nextStates, newState)
	end
	return nextStates
end

-- going from one board state (which amphipod is where) to another is done
-- through a move, which has a cost. We can use this to find the best path from
-- start to the final state (which is known in advance) through Dijkstra.
function Dijkstra(start, finish)
	local allStates = {}
	local initState = { board = start, cost = 0, total = 0 }
	local initStateKey = initState.board
	initState.key = initStateKey
	
	allStates[initStateKey] = initState
	local heap = PriorityQueue:new('min')
	heap:enqueue(initStateKey, initState.total)
	
	while(heap:len() > 0) do
		local key = heap:dequeue()
		local state = allStates[key]
		if(key == finish) then
			break
		end
		
		local neighbours = Neighbours(state)
		for _, neighbour in ipairs(neighbours) do
			if(not allStates[neighbour.key])then
				allStates[neighbour.key] = neighbour
				heap:enqueue(neighbour.key, neighbour.total)
			end
			
			if(heap:contains(neighbour.key) and neighbour.total < allStates[neighbour.key].total) then
				allStates[neighbour.key].total = neighbour.total
				heap:update(neighbour.key, neighbour.total)
			end
		end
	end
	return allStates[finish]
end

-- Internal shared function
-- Load the board and find the cheapest sequence of movements to order the amphipods
-- If 'isPartA' is false, add two extra rows in the middle
-- Return the total cost of movement
local function Solve(filename, isPartA)
	local hFile = OpenFile(filename)
	if(hFile == nil) then
		return 0
	end
	
	local lines = {}
	for line in hFile:lines() do
		lines[#lines + 1] = line
	end
	
	-- Parse input.
	-- Create a "start" position and add the initial burrow values
	local start = {}
	for i = 3, 4 do
		a, b, c, d = string.match(lines[i], string.rep("(%u).", 4))
		start["4,"..i] = a
		start["6,"..i] = b
		start["8,"..i] = c
		start["10,"..i] = d
	end
		
	-- For part 2, there are two additional rows in the middle.
	-- Those rows are pre-defined
	if(isPartA) then
		ROOM_SIZE = 2
	else
		ROOM_SIZE = 4
		start["4,6"] = start["4,4"];
		start["6,6"] = start["6,4"];
		start["8,6"] = start["8,4"];
		start["10,6"] = start["10,4"];
		
		start["4,4"] = "D"; start["4,5"] = "D";  
		start["6,4"] = "C"; start["6,5"] = "B";  
		start["8,4"] = "B"; start["8,5"] = "A";  
		start["10,4"] = "A"; start["10,5"] = "C";
	end
	
	local final, boards = Dijkstra(start, GenerateEndState())
	return final.total
end

-- Load the board and find the cheapest sequence of movements to order the amphipods
-- Return the total cost of movement
function PartA(filename)
	return Solve(filename, true)
end

-- Load the board and find the cheapest sequence of movements to order the amphipods
-- Add two extra rows of amphipods into the board
-- Return the total cost of movement
function PartB(filename)
	return Solve(filename, false)
end

local input = "inputs/day23.txt"
print(PartA(input))
print(PartB(input))