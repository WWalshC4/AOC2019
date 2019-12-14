

io.input ('day10_input.txt')

local inputMap = io.read ('*all')



function parseMap (mapStr)
	local map = {
		totalCount = 0,
		width = nil,
		height = nil,
	}
	local asteroids = {}

	local y = 0

	for line in string.gmatch (mapStr, '(.-)\n')  do
		y = y + 1
		local xLine = {}
		local x = 0
		for char in string.gmatch (line, '(.)') do
			x = x + 1
			if (char == '.') then
				table.insert (xLine, false)
			elseif (char == '#') then
				table.insert (xLine, true)
				map.totalCount = map.totalCount + 1
				asteroids [y] = asteroids [y] or {}
				asteroids [y] [x] = true
			else
				x = x - 1
			end
		end
		if (#xLine > 0) then
			table.insert (map, xLine)
			map.width = #xLine
		end
	end
	map.height = #map

	return map, asteroids
end

function countVisible (startX, startY, origMap, origAsteroids)
	local asteroids = CopyTable (origAsteroids)

	asteroids [startY] [startX] = nil

	for y, xLine in pairs (asteroids) do
		for x, _ in pairs (xLine) do
			local xDiff = x - startX
			local yDiff = y - startY

			local angle = math.atan (yDiff, xDiff)

			for y2, xLine2 in pairs (asteroids) do
				for x2, _ in pairs (xLine2) do
					if (not (y == y2 and x == x2)) then
						local xDiff2 = x2 - startX
						local yDiff2 = y2 - startY

						local angle2 = math.atan (yDiff2, xDiff2)

						if (angle == angle2) then
							local distance1 = math.sqrt ((xDiff ^ 2) + (yDiff ^ 2))
							local distance2 = math.sqrt ((xDiff2 ^ 2) + (yDiff2 ^ 2))

							if (distance1 < distance2) then
								asteroids [y2] [x2] = false
							else
								asteroids [y] [x] = false
							end
						end
					end
				end
			end
		end
	end

	local count = 0

	for _, yLine in pairs (asteroids) do
		for _, stillVisible in pairs (yLine) do
			if (stillVisible) then
				count = count + 1
			end
		end
	end

	return count
end

function markAngles (startX, startY, origMap, origAsteroids)
	local asteroids = CopyTable (origAsteroids)

	asteroids [startY] [startX] = nil

	local angleMap = {}

	for y, xLine in pairs (asteroids) do
		for x, _ in pairs (xLine) do
			local xDiff = x - startX
			local yDiff = y - startY

			local angle = math.atan (yDiff, xDiff)
			angle = math.deg (angle)
			if (angle < 0) then
				angle = 360 + angle
			end

			angle = angle - 270
			if (angle < 0) then
				angle = 360 + angle
			end

			local distance = math.sqrt ((xDiff ^ 2) + (yDiff ^ 2))

			table.insert (angleMap, {angle = angle, distance = distance, x = x, y = y})
		end
	end
	return angleMap
end

function GetBest (map, asteroids)
	local maxCount = 0
	local maxCoords = ''

	for y, yLine in pairs (asteroids) do
		for x, _ in pairs (yLine) do
			local count = countVisible (x, y, map, asteroids)
			local coords = tostring (x - 1) .. ',' .. tostring (y - 1)
			if (count > maxCount) then
				maxCount = count
				maxCoords = coords
			end
		end
	end
	print (maxCount, maxCoords)
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

local a = [[
	.#..#
	.....
	#####
	....#
	...##
]]	--5x5

local b = [[
	......#.#.
	#..#.#....
	..#######.
	.#.#.###..
	.#..#.....
	..#....#.#
	#..#....#.
	.##.#..###
	##...#..#.
	.#....####
]] -- 10x10

local c = [[
	#.#...#.#.
	.###....#.
	.#....#...
	##.#.#.#.#
	....#.#.#.
	.##..###.#
	..#...##..
	..##....##
	......#...
	.####.###.
]]	--10x10

local d = [[
	.#..#..###
	####.###.#
	....###.#.
	..###.##.#
	##.##.#.#.
	....###..#
	..#.#..#.#
	#..#.#.###
	.##...##.#
	.....#.#..
]] --10x10

local e = [[
	.#..##.###...#######
	##.############..##.
	.#.######.########.#
	.###.#######.####.#.
	#####.##.#.##.###.##
	..#####..#.#########
	####################
	#.####....###.#.#.##
	##.#################
	#####.##.###..####..
	..######..##.#######
	####.##.####...##..#
	.#####..#.######.###
	##...#.##########...
	#.##########.#######
	.####.#.###.###.#.##
	....##.##.###..#####
	.#.#.###########.###
	#.#.#.#####.####.###
	###.##.####.##.#..##
]]	--20x20

--GetBest (parseMap (a)) 	-- 8 ; 3,4
--GetBest (parseMap (b))	--33 ; 5,8
--GetBest (parseMap (c))	--35 ; 1,2
--GetBest (parseMap (d))	--41 ; 6,3
--GetBest (parseMap (e))	--210 ; 11,13
--GetBest (parseMap (inputMap))	--340 ; 28,29

local map, asteroids = parseMap (inputMap)

angles = markAngles (29, 30, map, asteroids)

table.sort (angles, function (a, b)
	if (a.angle == b.angle) then
		return a.distance > b.distance
	else
		return a.angle > b.angle
	end
end)

local order = {}

local sortedAngles = {}

while (#angles > 0) do
	local lastAngle
	for i = #angles, 1, -1 do
		local angle = angles [i]
		if (angle.angle ~= lastAngle) then
			lastAngle = angle.angle
			table.insert (sortedAngles, angle)
			table.remove (angles, i)
		end
	end
end

print (((sortedAngles [200].x - 1) * 100) + (sortedAngles [200].y - 1)) --2628
