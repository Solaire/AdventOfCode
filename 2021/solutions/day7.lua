--- Day 7: The Treachery of Whales ---

require "shared"

-- Find the optimal value that yields to lowest fuel if the values were moved to the optional position
-- Fuel cost = abs(value - optimal value)
-- Bascially sort the array and find the median.
-- Out of the three possibilities (Mean, Modal and Median):
--		Modal (most frequent) is not good since the most occuring element might be biggest/largest
-- 		Mean (average) can be good for evenly distributed elements, but not great with radical elements
--		Modal (middle value) is best because it guarantees that (if set is odd) equal number of left and right numbers have to move
-- 
-- Consider this: [0, 1, 100]
-- Intuition will tell people that mean is best but for this example:
-- Mean = 33, fuel cost = 132 (abs(0 - 33) + abs(1 - 33) + (100 - 33))
-- Median = 1, fuel cost = 101 (abs(0 - 1) + (1 - 1) + (100 - 1))
function PartA(filename)
	local hFile = OpenFile(filename)
	if(hFile == nil) then
		return 0
	end
    
	-- Parse input
	local positions = {}
	for line in (hFile:read("*line")..','):gmatch("(.-)"..',') do
        if(line ~= "") then
			table.insert(positions, tonumber(line))
        end
    end
	table.sort(positions)
	    
	-- Get modal
    local half = #positions // 2
	local median = Tenery(#positions % 2 == 0, (positions[half] + positions[half + 1]) // 2, positions[half])
	    
    local fuel = 0
    for i = 1, #positions do
		fuel = fuel + math.abs(positions[i] - median)
    end
    return fuel
end

-- Find the optimal value that yields to lowest fuel if the values were moved to the optional position
-- Fuel cost = n(n+1)/2 where n = abs(value - optimal value)
-- Bascially, get the mean and calculate the fuel cost for both floor and ceiling and pick the smallest value
-- Out of the three possibilities (Mean, Modal and Median):
--		Modal (most frequent) is not good since the most occuring element might be biggest/largest
-- 		Mean (average) works because now we have to minimise the maximum distance travelled by each element
--		Modal (middle value) guarantees that (if set is odd) equal number of left and right numbers have to move
--			but considering the fuel cost progression, we should minimise the maximum movement distance
-- 
-- Consider the same example: [0, 1, 100]
-- Median = 1, fuel cost = 5050 ( (1(1+1)/2) + (0(0+1)/2) + (99(99+1)/2) )
-- Mean = 33, fuel cost = 3367 ( (34(34+1)/2) + (33(33+1)/2) + (66(66+1)/2) )
function PartB(filename)
	local hFile = OpenFile(filename)
	if(hFile == nil) then
		return 0
	end
    
	-- Parse input
	local total = 0
	local positions = {}
	for line in (hFile:read("*line")..','):gmatch("(.-)"..',') do
        if(line ~= "") then
			total = total + tonumber(line)
			table.insert(positions, tonumber(line))
        end
    end
	    
	-- Mean might have a deviations of +/- 0.5
	-- Consider both floor and ceiling values and pick the smallest result
    mean = {
		floor = math.floor(total / #positions), 
		ceiling = math.floor((total / #positions) + 0.5)
		}
    
    local a = 0
	local b = 0
    for i = 1, #positions do
		local diffFloor = math.abs(positions[i] - mean.floor)
		local diffCeil = math.abs(positions[i] - mean.ceiling)
		
		-- Sum of natural numbers: n(n+1)/2
		a = a + (diffFloor * (diffFloor + 1) / 2)
		b = b + (diffCeil * (diffCeil + 1) / 2)
    end
    return Tenery(a < b, a, b)
end

local input = "inputs/day7.txt"
print(PartA(input))
print(PartB(input))