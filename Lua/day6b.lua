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

	local centersByOrbit = {}

	for _, orbit in ipairs (map) do
		local c, o = string.match (orbit, '(.+)%)(.+)')

		orbitsByCenter [c] = orbitsByCenter [c] or {}
		orbitsByCenter [c] [o] = {}

		centersByOrbit [o] = centersByOrbit [o] or {}
		centersByOrbit [o] [c] = {}
	end

	for center, orbit in pairs (orbitsByCenter) do
		if (orbitsByCenter [orbit]) then
			table.insert (orbitsByCenter [center] [orbit], orbitsByCenter [orbit])
		end
	end

	for orbit, center in pairs (centersByOrbit) do
		if (centersByOrbit [center]) then
			table.insert (centersByOrbit [orbit] [center], centersByOrbit [center])
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

	local getParentOrbit

	getParentOrbit = function (orbit, orbitPath)
		orbitPath = orbitPath or {}
		table.insert (orbitPath, 1, orbit)
		if (centersByOrbit [orbit]) then
			return getParentOrbit (next (centersByOrbit [orbit]), orbitPath)
		else
			return orbitPath
		end
	end

	local SAN = getParentOrbit ('SAN')
	local YOU = getParentOrbit ('YOU')


	local route = {}

	for i, v in ipairs (YOU) do
		if (SAN [i] == YOU [i]) then
		else
			table.insert (route, 1, YOU [i])
			table.insert (route, SAN [i])
		end
	end

	print (#route - 2) -- 241
	print (table.concat (route, ','))
end


--GetOrbits (example) -- 42
GetOrbits (input)
