--- Day 16: Packet Decoder ---

require "shared"

-- Return the sum of arguments
local function Sum(arguments)
	local sum = 0
	for i = 1, #arguments do
		sum = sum + arguments[i]
	end
	return sum
end

-- Return product of arguments
-- If size of arguments is 1, return 1
local function Product(arguments)
	local product = arguments[1]
	for i = 2, #arguments do
		product = product * arguments[i]
	end
	return product
end

-- Return the smallest number in the argument list
local function Minimum(arguments)
	table.sort(arguments)
	return arguments[1]
end

-- Return the largest number in the argument list
local function Maximum(arguments)
	table.sort(arguments)
	return arguments[#arguments]
end

-- Return 1 if first element > second element, otherwise 0
local function GreaterThan(arguments)
	return Tenery(arguments[1] > arguments[2], 1, 0)
end

-- Return 1 if first element < second element, otherwise 0
local function LessThan(arguments)
	return Tenery(arguments[1] < arguments[2], 1, 0)
end

-- Return 1 if first element == second element, otherwise 0
local function EqualTo(arguments)
	return Tenery(arguments[1] == arguments[2], 1, 0)
end

-- Hex-to-binary lookup table
local BIT_DICTIONARY =
{
	["0"] = "0000",
	["1"] = "0001",
	["2"] = "0010",
	["3"] = "0011",
	["4"] = "0100",
	["5"] = "0101",
	["6"] = "0110",
	["7"] = "0111",
	["8"] = "1000",
	["9"] = "1001",
	["A"] = "1010",
    ["B"] = "1011",
    ["C"] = "1100",
    ["D"] = "1101",
    ["E"] = "1110",
    ["F"] = "1111"
}

-- Map to operation function pointers, based on packet typeID
local OPERATOR_FUNCTIONS = 
{
	[0] = Sum,
	[1] = Product,
	[2] = Minimum,
	[3] = Maximum,
	[5] = GreaterThan,
	[6] = LessThan,
	[7] = EqualTo
}

-- Add bits to the table, one bit per index
local function AddBits(arr, bits)
	for bit in bits:gmatch"." do
		table.insert(arr, bit)
	end
end

-- Structure representing a packet
-- Only real use to is encapsulate the version and cursor variables (I don't want to use globals)
Packet = {}
Packet.__index = Packet

-- Constructor
function Packet:New(binaryStream)
	self = {}
	self.stream = binaryStream
	self.cursor = 1
	self.version = 0
	
	setmetatable(self, Packet)
	return self
end

-- Extract n number of bits starting at cursor position
-- Increment the cursor by n + 1
-- If 'toString' is true, return string of bits
-- If 'toString' is false, return decimal number representation
function Packet:ExtractNumber(n, toString)
	local tmp = ""
	for i = self.cursor, self.cursor + n - 1 do
		tmp = tmp..self.stream[i]
	end
	
	self.cursor = self.cursor + n
	return Tenery(toString, tmp, tonumber(tmp, 2))
end

-- Recursively process the packet, extracting literals and evaluating operations
-- Use cursor internal to the Packet object, but if isRoot is true, reset cursor to 1
function Packet:Process(isRoot)
	if(isRoot) then
		self.cursor = 1
	end
	
	self.version = self.version + self:ExtractNumber(3)
	local typeID  = self:ExtractNumber(3)
	
	if(typeID == 4) then -- Literal number 
		local last = false
		local count = 0
		local firstBit = self:ExtractNumber(1)
		local literalBits = ""
		
		while(not last) do
			count = count + 1
			if(firstBit == 0) then
				last = true
			end
			
			literalBits = literalBits..self:ExtractNumber(4, true)
			if(not last) then
				firstBit = self:ExtractNumber(1)
			end
		end

		return tonumber(literalBits, 2)
		
	else -- Operator packet 
		local arguments = {}
		local firstBit = self:ExtractNumber(1)
		
		if(firstBit == 0) then
			local len = self:ExtractNumber(15)
			local endPacket = self.cursor + len
			
			while(self.cursor < endPacket) do
				table.insert(arguments, self:Process(false))
			end
		else
			local count = self:ExtractNumber(11)
						
			for i = 1, count do
				table.insert(arguments, self:Process(false))
			end
		end
		
		return OPERATOR_FUNCTIONS[typeID](arguments)
	end
end

-- Shared internal function
-- Load the stream, extract literals and operations
-- If isPartA, return the total packet version, else return the operation result
local function Solve(filename, isPartA)
	local hFile = OpenFile(filename)
	if(hFile == nil) then
		return 0
	end
	
	-- Load the hex string and decode it into binary
	-- Store the bits in a table for fast index access 
	local bitArr = {}
	local line = hFile:read("*line")
	
	for hex in line:gmatch"." do
		if(BIT_DICTIONARY[hex]) then
			AddBits(bitArr, BIT_DICTIONARY[hex])
		end
	end
	
	-- Start processing
	local packet = Packet:New(bitArr)
	local result = packet:Process(true)
	
	return Tenery(isPartA, packet.version, result)
end

-- Load the packet hex stream, and process
-- Return the packet's total version
function PartA(filename)
	return Solve(filename, true)
end

-- Load the packet hex stream, and process
-- Return the packet's operation result
function PartB(filename)
	return Solve(filename, false)
end

local input = "inputs/day16.txt"
print(PartA(input))
print(PartB(input))
