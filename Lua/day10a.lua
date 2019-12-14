

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

			if (xDiff == 0) then
				if (yDiff == math.abs (yDiff)) then
					yDiff = 1
				else
					yDiff = -1
				end

			elseif (yDiff == 0) then
				if (xDiff == math.abs (xDiff)) then
					xDiff = 1
				else
					xDiff = -1
				end

			elseif (xDiff == yDiff) then
				if (xDiff == math.abs (xDiff)) then
					xDiff = 1
				else
					xDiff = -1
				end
				yDiff = xDiff

			elseif (math.abs (xDiff) > math.abs (yDiff)) then
				xDiff = xDiff / math.abs (yDiff)
				if (yDiff == math.abs (yDiff)) then
					yDiff = 1
				else
					yDiff = -1
				end
				if (xDiff == math.floor (xDiff)) then
					xDiff = math.floor (xDiff)
				end

			elseif (math.abs (xDiff) < math.abs (yDiff)) then
				yDiff = yDiff / math.abs (xDiff)
				if (xDiff == math.abs (xDiff)) then
					xDiff = 1
				else
					xDiff = -1
				end
				if (yDiff == math.floor (yDiff)) then
					yDiff = math.floor (yDiff)
				end
			end


			local xCheck = x
			local yCheck = y
			print ('    ')
			print ('S', xCheck - 1, yCheck - 1)
			print ('D', xDiff, yDiff, ' ', x - startX, y - startY)

			while (true) do
				xCheck = xCheck + xDiff
				yCheck = yCheck + yDiff

				if (xCheck < 1 or xCheck > origMap.width) then
					break
				end
				if (yCheck < 1 or yCheck > origMap.height) then
					break
				end

				if (yCheck == math.floor (yCheck) and xCheck == math.floor (xCheck)) then

					if (asteroids [yCheck] and asteroids [yCheck] [xCheck]) then
						asteroids [yCheck] [xCheck] = false
						print ('C', xCheck - 1, yCheck - 1, 'HIT')
					else
						print ('C', xCheck - 1, yCheck - 1)
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

GetBest (parseMap (a)) 	-- 8 ; 3,4
GetBest (parseMap (b))	--33 ; 5,8
GetBest (parseMap (c))	--35 ; 1,2
GetBest (parseMap (d))	--41 ; 6,3
GetBest (parseMap (e))	--210 ; 11,13
GetBest (parseMap (inputMap))	--210 ; 11,13
