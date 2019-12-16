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

function applyGravity (a, b)
	if (a.x < b.x) then
		a.v_x = a.v_x + 1
		b.v_x = b.v_x - 1
	elseif (a.x > b.x) then
		a.v_x = a.v_x - 1
		b.v_x = b.v_x + 1
	end
	if (a.y < b.y) then
		a.v_y = a.v_y + 1
		b.v_y = b.v_y - 1
	elseif (a.y > b.y) then
		a.v_y = a.v_y - 1
		b.v_y = b.v_y + 1
	end
	if (a.z < b.z) then
		a.v_z = a.v_z + 1
		b.v_z = b.v_z - 1
	elseif (a.z > b.z) then
		a.v_z = a.v_z - 1
		b.v_z = b.v_z + 1
	end
end

function changePosition (planet)
	planet.x = planet.x + planet.v_x
	planet.y = planet.y + planet.v_y
	planet.z = planet.z + planet.v_z
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

function runSim (planets, steps)
	local energy = 0
	for stepCount = 1, steps do
		for a = 1, #planets do
			local planetA = planets [a]
			for b = a + 1, #planets do
				local planetB = planets [b]
				applyGravity (planetA, planetB)
			end
		end

		for _, planet in ipairs (planets) do
			changePosition (planet)
			getEnergy (planet)
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

runSim (planets, 1000)

printSimPosition (planets)
printSimEnergy (planets) --6423
