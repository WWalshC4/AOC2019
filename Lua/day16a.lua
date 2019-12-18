
sampleData0 = '12345678' -- 1 = 48226158, 2 = 34040438, 3 = 03415518, 4 = 01029498
sampleData1 = '80871224585914546619083218645595' -- 100 = 24176176
sampleData2 = '19617804207202209144916044189917' -- 100 = 73745418
sampleData3 = '69317163492948606335995924319873' -- 100 = 52432133


io.input ('day16_input.txt')

local inputData = io.read ('*line')

function buildTable (dataString)
	local data = {}

	for op in string.gmatch (dataString, '(%d)') do
		table.insert (data, tonumber (op))
	end
	return data
end

function phase (input, patternTable)
	local data = {}

	for i, _ in ipairs (input) do
		local thisVal = 0
		for index, val in ipairs (input) do
			local patternVal = patternTable [i] [index]
			thisVal = thisVal + (val * patternVal)
		end

		local newVal = math.abs (thisVal) % 10
		table.insert (data, newVal)
	end

	return data
end

function FFT (data, pattern, count)
	local input = buildTable (data)

	if (pattern == nil) then
		pattern = {0, 1, 0, -1}
	end

	local patternTable = {}

	for i, _ in ipairs (input) do
		patternTable [i] = {}

		local pT = patternTable [i]

		while (true) do
			for _, element in ipairs (pattern) do
				for j = 1, i do
					table.insert (pT, element)
					if (#pT  > (#input + 1)) then
						break
					end
				end
				if (#pT > (#input + 1)) then
					break
				end
			end
			if (#pT > (#input + 1)) then
				break
			end
		end
		table.remove (pT, 1)
	end

	for i = 1, count do
		input = phase (input, patternTable)
	end

	return input
end

local out = FFT (inputData, nil, 100)

print (string.sub (table.concat (out), 1, 8)) -- 40921727
