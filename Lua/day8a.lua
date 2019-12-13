io.input ('day8_input.txt')

local data = io.read ('*line')

local width, height = 25, 6

local layers = {}

local layerSize = width * height

for i = 1, #data, layerSize do
	local layer = string.sub (data, i, i + layerSize - 1)
	table.insert (layers, layer)
end

local minZeroLayer = 0
local minZeros = math.huge
local minZeroLayerOneByTwo

for layer, layerData in ipairs (layers) do
	local zeroCount, oneCount, twoCount = 0, 0, 0
	for char in string.gmatch (layerData, '(.)') do
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

print (minZeroLayerOneByTwo) --2806
