--- Day 22: Reactor Reboot ---

require "shared"

-- Returns the common part of the ranges from "low" -> "high"
-- and from -> to. The function doesn't check if "low" is indeed less than
-- "high", for example.
function CommonCubeRange(low, high)
	return function (from, to)
		if(to < low or from > high) then 
			return nil, nil 
		end
		return math.max(low, from), math.min(high, to)
	end
end

-- Returns the intersection between cubes a and b
function CubeIntersection(a, b)
	local x1a, x2a, y1a, y2a, z1a, z2a = a.x1, a.x2, a.y1, a.y2, a.z1, a.z2
	local x1b, x2b, y1b, y2b, z1b, z2b = b.x1, b.x2, b.y1, b.y2, b.z1, b.z2
	local x1, x2 = CommonCubeRange(x1a, x2a)(x1b, x2b)
	local y1, y2 = CommonCubeRange(y1a, y2a)(y1b, y2b)
	local z1, z2 = CommonCubeRange(z1a, z2a)(z1b, z2b)
	if(x1 and y1 and z1) then 
		return {x1 = x1, x2 = x2, y1 = y1, y2 = y2, z1 = z1, z2 = z2}
	end
	return nil
end

-- Return volume of a cube
-- The dimensions are adjusted by 1 on each axis so that cube 0x0x0 returns 1
function GetVolume(cube) 
	return (cube.x2 + 1 - cube.x1) * (cube.y2 + 1 - cube.y1) * (cube.z2 + 1 - cube.z1) 
end

-- Split cube a such that it no longer intersects with cube b
-- Return list of subcubes
function CubeSplit(a, b)
	x1a, x2a, y1a, y2a, z1a, z2a = a.x1, a.x2, a.y1, a.y2, a.z1, a.z2
	x1b, x2b, y1b, y2b, z1b, z2b = b.x1, b.x2, b.y1, b.y2, b.z1, b.z2

	-- The directions here describe the scene, when you're standing in front of
	-- the cubes, meaning the horizon is the x-axis, the z-axis is increasing
	-- towards you, and y-axis is just up and down. We first slice on the sides,
	-- then we slide of what's in front and behind of cube b, and finally we
	-- slice off the top and bottom chunks from the remaining block.
	local newCubes = {}
	
	rightside_x1, rightside_x2 = CommonCubeRange(x2b + 1, math.maxinteger)(x1a, x2a)
	if(rightside_x1) then
		table.insert(newCubes, {x1 = rightside_x1, x2 = rightside_x2, y1 = y1a, y2 = y2a, z1 = z1a, z2 = z2a})
	end

	leftside_x1, leftside_x2 = CommonCubeRange(math.mininteger, x1b - 1)(x1a, x2a)
	if(leftside_x1) then
		table.insert(newCubes, {x1 = leftside_x1, x2 = leftside_x2, y1 = y1a, y2 = y2a, z1 = z1a, z2 = z2a})
	end

	-- these can be re-used so I'm just calling them (rem)aining_x*
	rem_x1, rem_x2 = CommonCubeRange(x1a, x2a)(x1b, x2b)
	here_z1, here_z2 = CommonCubeRange(z2b + 1, math.maxinteger)(z1a, z2a)
	if(rem_x1 and here_z1) then
		table.insert(newCubes, {x1 = rem_x1, x2 = rem_x2, z1 = here_z1, z2 = here_z2, y1 = y1a, y2 = y2a})
	end

	other_z1, other_z2 = CommonCubeRange(math.mininteger, z1b-1)(z1a, z2a)
	if rem_x1 and other_z1 then
		table.insert(newCubes, {x1=rem_x1,x2=rem_x2,z1=other_z1,z2=other_z2,y1=y1a,y2=y2a})
	end

	top_z1, top_z2 = CommonCubeRange(z1a, z2a)(z1b, z2b)
	top_y1, top_y2 = CommonCubeRange(y2b + 1, math.maxinteger)(y1a, y2a)
	if(rem_x1 and top_z1 and top_y1) then
		table.insert(newCubes, {x1 = rem_x1, x2 = rem_x2, z1 = top_z1, z2 = top_z2, y1 = top_y1, y2 = top_y2})
	end
	
	bot_y1, bot_y2 = CommonCubeRange(math.mininteger, y1b - 1)(y1a, y2a)
	if rem_x1 and top_z1 and bot_y1 then
		table.insert(newCubes, {x1 = rem_x1, x2 = rem_x2, z1 = top_z1, z2 = top_z2, y1 = bot_y1, y2 = bot_y2})
	end
	
	return newCubes
end

-- Internal shared function
-- Load all cubes into a list, for each intersecting cube, split it into subcubes
-- Return volume of lit up cubes
local function Solve(filename, isPartA)
	local hFile = OpenFile(filename)
	if(hFile == nil) then
		return 0
	end
	
	local cubes = {}
	local line = hFile:read("*line")
	while(line) do
		local x1, x2, y1, y2, z1, z2 = string.match(line, string.rep("(%-?%d+).-", 6))
		x1, x2, y1, y2, z1, z2 = tonumber(x1), tonumber(x2), tonumber(y1), tonumber(y2), tonumber(z1), tonumber(z2)
		
		local currentCube, newCubes = {x1 = x1, x2 = x2, y1 = y1, y2 = y2, z1 = z1, z2 = z2}, {}

		for _, cube in ipairs(cubes) do
			if(not CubeIntersection(cube, currentCube)) then 
				table.insert(newCubes, cube)
			else
				local subcubes = CubeSplit(cube, currentCube)
				if(#subcubes > 0) then 
					table.move(subcubes, 1, #subcubes, #newCubes + 1, newCubes) 
				end
			end
		end

		if(string.match(line, "on")) 
			then table.insert(newCubes, currentCube) 
		end
		cubes = newCubes
		line = hFile:read("*line")
	end
	
	local sum = 0
	local focus = {x1 = -50, x2 = 50, y1 = -50, y2 = 50, z1 = -50, z2 = 50}
	
	for _, cube in pairs(cubes) do
		if(isPartA) then
			local intersection = CubeIntersection(cube, focus)
			if(intersection) then
				sum = sum + GetVolume(intersection)
			end
		else
			sum = sum + GetVolume(cube)
		end
	end
	return sum
end

-- Load all cubes into a list, for each intersecting cube, split it into subcubes
-- Only check the cubes inside a region -50x-50x-50...50x50x50
-- Return volume of lit up cubes
function PartA(filename)
	return Solve(filename, true)
end

-- Load all cubes into a list, for each intersecting cube, split it into subcubes
-- Return volume of lit up cubes
function PartB(filename)
	return Solve(filename, false)
end

local input = "inputs/day22.txt"
print(PartA(input))
print(PartB(input))