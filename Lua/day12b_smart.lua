do	--generate inputData from input text
	io.input ('day12_input.txt')

	inputPlanetData = {}

	local data

	repeat
		data = io.read ('*line')
		table.insert (inputPlanetData, data)
	until
		data == nil
end

function makePlanets (planetData)

	local planets = {}

	for _, planet in ipairs (planetData) do
		local x = string.match (planet, 'x=([%-%d]+)')
		local y = string.match (planet, 'y=([%-%d]+)')
		local z = string.match (planet, 'z=([%-%d]+)')

		x = tonumber (x)
		y = tonumber (y)
		z = tonumber (z)

		local planet = {x = x, y = y, z = z, v_x = 0, v_y = 0, v_z = 0}
		table.insert (planets, planet)
	end

	--[[ -- confirm input
	for _,planet in pairs (planets) do
		for k,v in pairs (planet) do
			print (k,v)
		end
		print (' ')
	end
	]]

	return planets
end

function applyGravity (a, b, plane)
	if (not plane or plane == 'x') then
		if (a.x < b.x) then
			a.v_x = a.v_x + 1
			b.v_x = b.v_x - 1
		elseif (a.x > b.x) then
			a.v_x = a.v_x - 1
			b.v_x = b.v_x + 1
		end
	end
	if (not plane or plane == 'y') then
		if (a.y < b.y) then
			a.v_y = a.v_y + 1
			b.v_y = b.v_y - 1
		elseif (a.y > b.y) then
			a.v_y = a.v_y - 1
			b.v_y = b.v_y + 1
		end
	end
	if (not plane or plane == 'z') then
		if (a.z < b.z) then
			a.v_z = a.v_z + 1
			b.v_z = b.v_z - 1
		elseif (a.z > b.z) then
			a.v_z = a.v_z - 1
			b.v_z = b.v_z + 1
		end
	end
end

function changePosition (planet, plane)
	if (not plane or plane == 'x') then
		planet.x = planet.x + planet.v_x
	end
	if (not plane or plane == 'y') then
		planet.y = planet.y + planet.v_y
	end
	if (not plane or plane == 'z') then
		planet.z = planet.z + planet.v_z
	end
end

function getEnergy (planet)
	local potential = math.abs (planet.x) + math.abs (planet.y) + math.abs (planet.z)
	local kinetic = math.abs (planet.v_x) + math.abs (planet.v_y) + math.abs (planet.v_z)

	planet.potential = potential
	planet.kinetic = kinetic
	planet.total = potential * kinetic
end

function printSimPosition (planets)
	for _, planet in pairs (planets) do
		local line = {
			'pos = < x=\t',
			planet.x,
			'\t, y=\t',
			planet.y,
			'\t, z=\t',
			planet.z,
			'\t>,\t vel = < x=\t',
			planet.v_x,
			'\t, y=\t',
			planet.v_y,
			'\t, z=\t',
			planet.v_z,
			'>',
		}
		print (table.concat (line))
	end
end

function printSimEnergy (planets)
	local potential, kinetic, total = 0, 0, 0
	for _, planet in pairs (planets) do
		potential = potential + planet.potential
		kinetic = kinetic + planet.kinetic
		total = total + planet.total

		local line = {
			'potential = \t',
			planet.potential,
			'\t, kinetic = \t',
			planet.kinetic,
			'\t, total = \t',
			planet.total,
			'>',
		}
		print (table.concat (line))
	end
	local line = {
		'potential = \t',
		potential,
		'\t, kinetic = \t',
		kinetic,
		'\t, total = \t',
		total,
		'>',
	}

	print (table.concat (line))
end

function CopyTable (tab)
	local t = {}
	for k, v in pairs (tab) do
		if (type (v) == 'string') then
			t [k] = v
		elseif (type (v) == 'number') then
			t [k] = v
		elseif (type (v) == 'boolean') then
			t [k] = v
		elseif (type (v) == 'table') then
			t [k] = CopyTable (v)
		end
	end

	return t
end

function CompareTables (tabA, tabB)
	for k,v in pairs (tabA) do
		if (tabB [k]) then
			if (type (v) == 'table') then
				local out = CompareTables (tabA [k], tabB [k])
				if (out == false) then
					return false
				end
			else
				if (tabA [k] ~= tabB [k]) then
					return false
				end
			end
		else
			return false
		end
	end
	return true
end

function runSim (planets, plane)
	local stepCount = 0

	if (plane) then
		for _, planet in pairs (planets) do
			for k,v in pairs (planet) do
				if (not (k == plane or k == 'v_' .. plane)) then
					planet [k] = nil
				end
			end
		end
	end

	local initialStates = CopyTable (planets)

	local comp = CompareTables

	while (true) do
		stepCount = stepCount + 1
		for a = 1, #planets do
			local planetA = planets [a]
			for b = a + 1, #planets do
				local planetB = planets [b]
				applyGravity (planetA, planetB, plane)
			end
		end

		for _, planet in ipairs (planets) do
			changePosition (planet, plane)
		end

		local match = comp (planets, initialStates)

		if (match) then
			return stepCount
		end
	end
end

local samplePlanetData1 = {
	'<x=-1, y=0, z=2>',
	'<x=2, y=-10, z=-7>',
	'<x=4, y=-8, z=8>',
	'<x=3, y=5, z=-1>',
}

local samplePlanetData2 = {
	'<x=-8, y=-10, z=0>',
	'<x=5, y=5, z=10>',
	'<x=2, y=-7, z=3>',
	'<x=9, y=-8, z=-3>',
}

local planets = makePlanets (inputPlanetData)

local planets_x = CopyTable (planets)
local planets_y = CopyTable (planets)
local planets_z = CopyTable (planets)

local x_StepCount = runSim (planets_x, 'x')
local y_StepCount = runSim (planets_y, 'y')
local z_StepCount = runSim (planets_z, 'z')

function gcd( m, n )
    while n ~= 0 do
        local q = m
        m = n
        n = q % n
    end
    return m
end

function lcm( m, n )
    return ( m ~= 0 and n ~= 0 ) and m * n / gcd( m, n ) or 0
end

local period = lcm (x_StepCount, lcm (y_StepCount, z_StepCount))

print (period, x_StepCount, y_StepCount, z_StepCount) -- 327636285682704,       167624  135024  231614
