local min = 372037
local max = 905157

local matches = {}

for i = min, max do
	local s = tostring (i) .. ':' -- : is one higher than 9 in ASCII

	local adjacentDigits = 1 -- each digit is always adjacent to itself
	local foundTwo = false
	local increase = true
	local lastChar = '/' -- : / is one lower than 0 in ASCII
	for char in string.gmatch (s, '(.)') do
		if (char == lastChar) then
			adjacentDigits = adjacentDigits + 1
		else
			if (adjacentDigits == 2) then
				foundTwo = true
			end
			adjacentDigits = 1
		end

		if (string.byte (char) < string.byte (lastChar)) then
			increase = false
		end

		lastChar = char
	end

	if (foundTwo and increase) then
		table.insert (matches, i)
	end
end

print (#matches)
