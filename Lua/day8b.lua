io.input ('day8_input.txt')

local data = io.read ('*line')

local width, height = 25, 6

--data = '0222112222120000'
--width, height = 2, 2

local layers = {}

local layerSize = width * height

for i = 1, #data, layerSize do
	local layer = {
		rawData = string.sub (data, i, i + layerSize - 1)
	}
	for char in string.gmatch (layer.rawData, '(.)') do
		table.insert (layer, char)
	end
	layer.display = {}
	for y = 1, height do
		layer.display [y] = {}
		for x = 1, width do
			local index = (width * (y - 1)) + x
			layer.display [y] [x] = layer [index]
		end
	end

	table.insert (layers, layer)
end

local minZeroLayer = 0
local minZeros = math.huge
local minZeroLayerOneByTwo

for layer, layerData in ipairs (layers) do
	local zeroCount, oneCount, twoCount = 0, 0, 0
	for char in string.gmatch (layerData.rawData, '(.)') do
		if (char == '0') then
			zeroCount = zeroCount + 1
		elseif (char == '1') then
			oneCount = oneCount + 1
		elseif (char == '2') then
			twoCount = twoCount + 1
		end
	end
	if (zeroCount < minZeros) then
		minZeros = zeroCount
		minZeroLayer = layer
		minZeroLayerOneByTwo = oneCount * twoCount
	end
end

--print (minZeroLayerOneByTwo) --2806

local display = {}

for _, layer in ipairs (layers) do
	for i = 1, #layer.rawData do
		if (display [i] == nil) then
			local char = string.sub (layer.rawData, i, i)
			if (char == '0') then
				display [i] = ' '
			elseif (char == '1') then
				display [i] = '#'
			end
		end
	end
end

display = table.concat (display)

for i = 1, #display, width do
	local line = string.sub (display, i, i + width - 1)
	print (line)
end

--ZBJAB
