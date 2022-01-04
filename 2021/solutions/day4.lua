--- Day 4: Giant Squid ---

require "shared"

-- Container structure for BingoPoints
-- Keeps track of which points are marked and of the boards total value
BingoGrid = {}
BingoGrid.__index = BingoGrid

-- BingoGrid constructor
function BingoGrid:New()
	self = {}
	self.total = 0
	self.points = {}
	
	-- Tally arrays for keeping track which points were marked
	self.rows = {}
	self.cols = {}
  
	setmetatable(self, BingoGrid)
	return self
end

-- Add a row of numbers to bingo grid
function BingoGrid:AddRow(row)
	local numbers = StringSplit(row, ' ')
	self.rows[#self.rows + 1] = 0
	
	for i = 1, #numbers do
		local n = tonumber(numbers[i])
		self.total = self.total + n
		
		self.points[n] = { #self.rows, i }
		self.cols[i] = 0
	end
end

-- If value exists, set to marked {-1, -1} and decrease the total value by point's value
-- Increment row and column counters
function BingoGrid:Mark(value)
	
	if(self.points[value] ~= nil and self.points[value] ~= {-1, -1}) then
		local xy = self.points[value]
		self.total = self.total - value
		self.rows[xy[1]] = self.rows[xy[1]] + 1
		self.cols[xy[2]] = self.cols[xy[2]] + 1
		
		self.points[value] = {-1, -1}
	end
end

-- Check if the board has a complete row or column
function BingoGrid:IsWinner()
	
	for i = 1, #self.rows do
		if(self.rows[i] == 5) then
			return true
		end
	end
	
	for i = 1, #self.cols do
		if(self.cols[i] == 5) then
			return true
		end
	end
    return false
end

-- Load the bingo number sequence (first line) and create bingo boards
-- Calculate the final score of the first winning board by multiplying 
-- the sum of that board with the last number called
function PartA(filename)
	local hFile = OpenFile(filename)
	if(hFile == nil) then
		return 0
	end
	
    local numbers = StringSplit(hFile:read("*line"), ',')
    local grids = {}
    local i = 1
    
    -- Create bingo grids
    local line = hFile:read("*line")
    while(line) do
        if(line == "") then
            local grid = BingoGrid:New()
            grids[#grids + 1] = grid
        else
            grids[#grids]:AddRow(line)
        end
        line = hFile:read("*line")
    end
    
    local winningBoard = 0
    local bingoSum = 0
    local lastNumber = 0
    
	-- Go through the bingo numbers until a board wins
    for i = 1, #numbers do
		local num = tonumber(numbers[i])
		
		for index, grid in pairs(grids) do
			grid:Mark(num)
			if(grid:IsWinner()) then
				winningBoard = index
				bingoSum = grid.total
				lastNumber = num
				break
			end
		end
		if(winningBoard > 0) then
			break
		end
    end
    return bingoSum * lastNumber
end

-- Load the bingo number sequence (first line) and create bingo boards
-- Calculate the final score of the last winning board by multiplying 
-- the sum of that board with the last number called
function PartB(filename)
	local hFile = OpenFile(filename)
	if(hFile == nil) then
		return 0
	end
	
	local numbers = StringSplit(hFile:read("*line"), ",")
    local grids = {}
    local i = 1
    
    -- Create bingo grids
    local line = hFile:read("*line")
    while(line) do
        if(line == "") then
            local grid = BingoGrid:New()
            grids[#grids + 1] = grid
        else
            grids[#grids]:AddRow(line)
        end
        line = hFile:read("*line")
    end
    
    local bingoSum = 0
    local lastNumber = 0
	
	-- Go through the bingo numbers and mark numbers on each grid
	-- We're iterating the grid table in reverse order as all winning grids are removed since it's easier than having to check which one is winner
	for i = 1, #numbers do
		local num = tonumber(numbers[i])
		
		for ii = #grids, 1, -1 do
			grids[ii]:Mark(num)
			if(grids[ii]:IsWinner()) then
				if(#grids == 2) then
					local s = 0
				end
				
				if(#grids == 1) then
					lastNumber = numbers[i]
					bingoSum = grids[ii].total
					table.remove(grids, ii)
				else
					table.remove(grids, ii)
				end
			end
		end
		if(#grids == 0) then
			break
		end
    end
	return bingoSum * lastNumber
end

local input = "inputs/day4.txt"
print(PartA(input))
print(PartB(input))