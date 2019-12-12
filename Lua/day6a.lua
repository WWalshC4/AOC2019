local example = {
	'COM)B',
	'B)C',
	'C)D',
	'D)E',
	'E)F',
	'B)G',
	'G)H',
	'D)I',
	'E)J',
	'J)K',
	'K)L',
} -- 42

local input = {}

io.input ('day6_input.txt')

for line in io.lines () do
	table.insert (input, line)
end

function GetOrbits (map)
	local orbitsByCenter = {}

	for _, orbit in ipairs (map) do
		local c, o = string.match (orbit, '(.+)%)(.+)')

		orbitsByCenter [c] = orbitsByCenter [c] or {}
		orbitsByCenter [c] [o] = {}
	end

	for center, orbit in pairs (orbitsByCenter) do
		if (orbitsByCenter [orbit]) then
			table.insert (orbitsByCenter [center] [orbit], orbitsByCenter [orbit])
		end
	end

	local orbitCount = 0
	local orbitDepth = 0

	local getChildOrbits

	getChildOrbits = function (center)
		orbitDepth = orbitDepth + 1
		for childCenter, _ in pairs (orbitsByCenter [center] or {}) do
			orbitCount = orbitCount + orbitDepth
			if (orbitsByCenter [childCenter]) then
				getChildOrbits (childCenter)
			end
		end
		orbitDepth = orbitDepth - 1
	end

	getChildOrbits ('COM')
	print (orbitCount)
end


--GetOrbits (example) -- 42
GetOrbits (input)
