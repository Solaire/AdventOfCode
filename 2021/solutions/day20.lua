--- Day 20: Trench Map ---

require "shared"

-- Create a map key based on x/y coordinates
local function Point2Hash(x, y)
	return string.format("%d;%d", x, y)
end

-- Convert a hash to an x/y point
local function Hash2Point(hash)
	local i = hash:find(';')
	local x = tonumber(hash:sub(1, i - 1))
	local y = tonumber(hash:sub(i + 1, #hash))
	return x, y
end

-- Image structure
Image = {}
Image.__index = Image

-- Constructor
function Image:New()
	self = {}
	self.pixels = {}
	self.rows = 0
	self.cols = 0
	
	setmetatable(self, Image)
	return self
end

-- Add row of pixels to the image
-- Pixels are 0-indexed
function Image:AddRow(row)
	local x = 0
	for char in row:gmatch"." do
		local key = Point2Hash(self.rows, x)
		self.pixels[key] = char
		x = x + 1
	end
	
	self.rows = self.rows + 1
	self.cols = #row
end

-- Create a blank copy of the image, making every pixel '.'
-- Increase the width and height of the copy by 2
function Image:BlankCopy(source)
	local copy = Image:New()
	copy.cols = source.cols + 2
	copy.rows = source.rows + 2
	
	for y = 0, copy.rows do
		for x = 0, copy.cols do
			local key = Point2Hash(y, x)
			copy.pixels[key] = '.'
		end
	end

	return copy
end

-- Print image to output
function Image:Print()
	for row = 0, self.rows do
		local line = ""
			for col = 0, self.cols do
			local key = Point2Hash(row, col)
			line = line..self.pixels[key]
		end
		print(line)
	end
	print("")
end

-- Internal shared function
-- Enhance the image, by creaing a 9-bit number from a 3x3 image kernel
-- Replace the central pixel with the pixel found in the 512 algorithm string (first input line)
-- iterations -> number of times the image should be enhanced
local function Solve(filename, iterations)
	local hFile = OpenFile(filename)
	if(hFile == nil) then
		return 0
	end

	local algorithm = {}
	local line = hFile:read("*line") 
	for char in line:gmatch(".") do
		table.insert(algorithm, char)
	end
	
	local image = Image:New()
	line = hFile:read("*line")
	line = hFile:read("*line") 
	while(line) do
		image:AddRow(line)
		line = hFile:read("*line") 
	end

	-- Offsets for the 9 pixels to be checked, starting in top-left and finishing in bottom-right
	local OFFSETS = {{-1, -1}, {-1, 0}, {-1, 1}, {0, -1}, {0, 0}, {0, 1}, {1, -1}, {1, 0}, {1, 1}}
	local infinite = "0"
	
	for _ = 1, iterations do
		-- Store the output in a copy object
		-- The enhanced image will grow by 1 in all 4 directions
		local enhanced = Image:BlankCopy(image)
		for row = -1, image.rows + 1 do
			for col = -1, image.cols + 1 do
				local pixel = ""
				-- Convert the 3x3 kernel to binary number
				for i = 1, #OFFSETS do
					local key = Point2Hash(row + OFFSETS[i][1], col + OFFSETS[i][2])
					if(not image.pixels[key]) then
						pixel = pixel..infinite
					else
						pixel = Tenery(image.pixels[key] == "#", pixel.."1", pixel.."0")
					end
				end
				-- Set the central pixel in the copy image
				local key = Point2Hash(row + 1, col + 1)
				enhanced.pixels[key] = algorithm[tonumber(pixel, 2) + 1]
			end
		end		
		
		-- Set the new "infinite" pixel value.
		-- The algorithm index is 1-based so either index 1 (first) or 513 (last)
		local check = Tenery(infinite == "1", 513, 1)
		infinite = Tenery(algorithm[check] == "#", "1", "0")
		
		-- Free the original image and copy the refernce
		image = nil
		image = enhanced
	end

	image:Print()
	
	local sum = 0
	for _, val in pairs(image.pixels) do
		if(val == "#") then
			sum = sum + 1
		end
	end
	return sum
end

-- Enhance the inout image 2 times
function PartA(filename)
	return Solve(filename, 2)
end

-- Enhance the inout image 50 times
function PartB(filename)
	return Solve(filename, 50)
end

local input = "inputs/day20.txt"
print(PartA(input))
print(PartB(input))