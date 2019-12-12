local min = 372037
local max = 905157

local matches = {}

for i = min, max do
	local s = tostring (i)

	local adjacentDigits = false
	local increase = true
	local lastChar = '/'
	for char in string.gmatch (s, '(%d)') do
		if (char == lastChar) then
			adjacentDigits = true
		end
		if (string.byte (char) < string.byte (lastChar)) then
			increase = false
		end
		lastChar = char
	end

	if (adjacentDigits and increase) then
		table.insert (matches, i)
	end
end

print (#matches)
