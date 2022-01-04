--- Day 17: Trick Shot ---

require "shared"

-- Calculate the minimum velocity required to reach between the range (left..right)
local function FindMinVelocityX(left, right)
	-- With each step, the horizontal velocity decreases by 1
	-- The distance covered by velocity v = v(v+1)/2
	-- e.g. velocity = 2, max distance = 3
	--      velocity = 5, max distance = 15
	--
	-- Since the horizontal distance is a triangular number we can
	--  reverse the n(n+1)/2 formula and calculate the n needed to reach the target
	--
	-- n(n+1) / 2t
	-- Completing the square
	-- n^2 + n + 1/4 = 2t + 1/4
	-- solve for positive n
	-- sqrt(2t + 1/4) - 1/2
	
	-- Edge cases first
	if(left < 0 and right > 0) then -- Already here
		return 0
	elseif(left < 0 and right < 0) then -- Negative
		return -(math.ceil(math.sqrt((-right * 2) + 0.25) - 0.5))
	else
		return math.ceil(math.sqrt((left * 2) + 0.25) - 0.5)
	end
end

-- Calculate the initial velocity that yields the maximum height while reaching the target area
-- Vertical distance is also a triangular number so...
-- 	velocity is n(n+1)/2 where n is abs(targetRect.top) - 1
local function FindMaxVelocityY(targetRect)
	local minVelocityX = FindMinVelocityX(targetRect.left, targetRect.right)
	local maxVelocityY = math.abs(targetRect.top) - 1
	local ret = 
	{ 
		velocity = 
		{
			x = minVelocityX, 
			y = maxVelocityY
		}, 
		height = maxVelocityY * (math.abs(targetRect.top)) // 2
	}
	return ret
end

-- Calculate distinct starting velocities that will result in the probe arriving in the target area
-- Return the list of x,y velocities
local function FindInitialVelocities(targetRect)
	local velocities = {}
	
	-- Find out min and max valid velocities for x and y coordinates and 
	-- 	test valocities in the min..max range
	local minVelocityX = FindMinVelocityX(targetRect.left, targetRect.right)
	local maxVelocityX = targetRect.right
	
	local minVelocityY = targetRect.top
	local maxVelocityY = math.abs(targetRect.top) - 1
	
	for x = minVelocityX, maxVelocityX + 1 do
		for y = minVelocityY, maxVelocityY + 1 do
			local vx = x 
			local vy = y
			local xpos = 0
			local ypos = 0

			while(xpos <= targetRect.right and ypos >= targetRect.top) do
				if(xpos >= targetRect.left and ypos <= targetRect.bottom) then
					table.insert(velocities, {x = x, y = y})
					break
				end
				
				xpos = xpos + vx;
				ypos = ypos + vy;
				
				vx = vx - math.min(1, vx)
				vy = vy - 1
			end
		end
	end
	
	return velocities
end

-- Shared internal function.
-- If 'isPartA' is true return the highest possible height achieved by the probe 
--	otherwise return the number of possible velocities
local function Solve(filename, isPartA)
	local hFile = OpenFile(filename)
	if(hFile == nil) then
		return 0
	end

	local line = hFile:read("*line")	
	line = line:gsub("%..", "__")
	local ix, _ = string.find(line, "x=")
	local iy, _ = string.find(line, "y=")
	
	x = StringSplit(string.sub(line, ix + 2, iy - 3), "__")
	y = StringSplit(string.sub(line, iy + 2, #line), "__")
		
	local targetRect = 
	{
		left   = math.min(tonumber(x[1]), tonumber(x[2])),
		right  = math.max(tonumber(x[1]), tonumber(x[2])),
		top    = math.min(tonumber(y[1]), tonumber(y[2])),
		bottom = math.max(tonumber(y[1]), tonumber(y[2]))
	}

	if(isPartA) then
		local velocity = FindMaxVelocityY(targetRect)
		return velocity.height
	else
		local distinct = FindInitialVelocities(targetRect)
		return #distinct
	end
end

-- Find the initial velocity that causes the probe to reach the highest y position 
--   and still eventually be within the target area after any step.
function PartA(filename)
	return Solve(filename, true)
end

-- Find the number of distinct velocities that causes the probe to be within the target after any step
function PartB(filename)
	return Solve(filename, false)
end

local input = "inputs/day17.txt"
print(PartA(input))
print(PartB(input))