--- Day 21: Dirac Dice ---

require "shared"

-- Pairs of possible result after 3 d3 throws and how many times they appear given all 27 permutations
local d3Sums = {}
d3Sums[3] = 1
d3Sums[4] = 3
d3Sums[5] = 6
d3Sums[6] = 7
d3Sums[7] = 6
d3Sums[8] = 3
d3Sums[9] = 1

-- Recursive function which will calculate winner across different die permutations
-- Basically:
-- 3 d3 throws = 27 total combinations (7 are unique)
-- Start at level 1, iterate through each possible d3 score, apply the position/score
-- and go one level deeper (and repeat), until a player reaches 21 points
-- Instead of doing all 27 permutations, we only do the unique ones and multiply by occurence, since they will yield the same result
local function DiracDie(leftPos, rightPos, leftScore, rightScore)
	if(leftScore >= 21) then
		return 1, 0
	end
	if(rightScore >= 21) then
		return 0, 1
	end
	
	local totalWinCountLeft = 0
	local totalWinCountRight = 0
	
	for sum, count in pairs(d3Sums) do
		local newPos = (leftPos + sum) % 10
		local newScore = leftScore + newPos + 1
		
		local winCountRight, winCountLeft = DiracDie(rightPos, newPos, rightScore, newScore)
		
		totalWinCountLeft = totalWinCountLeft + (winCountLeft * count)
		totalWinCountRight = totalWinCountRight + (winCountRight * count)
	end
	
	return totalWinCountLeft, totalWinCountRight
end

-- Roll the dice, moving player position and increasing the score
-- If a player reaches 1000 points, return the score of the losing player multiplied by the last die thrown
function PartA(filename)
	local hFile = OpenFile(filename)
	if(hFile == nil) then
		return 0
	end
	
    local players = {p1 = {}, p2 = {}}
	
	local line = hFile:read("*line")
	local pos  = line:find(':')
	players.p1 = { pos = tonumber(line:sub(pos + 1, #line)), score = 0 }
	
	line = hFile:read("*line")
	pos  = line:find(':')
	players.p2 = { pos = tonumber(line:sub(pos + 1, #line)), score = 0 }
	
	local die = 0
	local turn = 1
	repeat
		-- Note for self:
		-- There are 3 ways of calculating the die throw:
		-- 1) Multiply the middle number by 3, since the throw is always (n + n+1 + n+2)
		-- 2) Add the three numbers together (n + n+1 + n+2)
		-- 3) Multiply ((n-1) * 3) + 5
		-- The problem with the first two is that any 10s will be turned into 0 due to mod.
		-- Method 3 will return 1 less than the actual die throw but after the mod operator, we can add the 1 resulting in correct number and correct behaviour for position 10
		local dieThrow = (die * 3) + 5
		local player = Tenery((turn % 2) == 1, players.p1, players.p2)
		
		player.pos = ((player.pos + dieThrow) % 10) + 1
		player.score = score + player.pos
		
		die = die + 3
		turn = turn + 1
	until(players.p1.score >= 1000 or players.p2.score >= 1000)
	
	local loserScore = Tenery(players.p1.score < players.p2.score, players.p1.score, players.p2.score)
	return loserScore * die
end

-- Parse input and call 'DiracDie' function which will return the winner's win count across the multiverse
function PartB(filename)
	local hFile = OpenFile(filename)
	if(hFile == nil) then
		return 0
	end
	
    local players = {p1 = {}, p2 = {}}
	
	local line = hFile:read("*line")
	local pos  = line:find(':')
	players.p1 = { pos = tonumber(line:sub(pos + 1, #line)), score = 0 }
	
	line = hFile:read("*line")
	pos  = line:find(':')
	players.p2 = { pos = tonumber(line:sub(pos + 1, #line)), score = 0 }
	
	winsP1, winsP2 = DiracDie(players.p1.pos - 1, players.p2.pos - 1, players.p1.score, players.p2.score)
	
	return Tenery(winsP1 > winsP2, winsP1, winsP2)
end
