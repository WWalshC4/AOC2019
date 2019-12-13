local inputTape = {}

io.input ('day7_input.txt')

local data = io.read ('*all')

for op in string.gmatch (data, '(%d+)') do
    table.insert (inputTape, tonumber (op))
end

local ops = {}

function runTape (luaTape)

	local tape = {}
	for i = 1, #luaTape do
		tape [i-1] = luaTape [i]
	end

	local i = 0
	while (true) do
		local instruction = tostring (tape [i])

		local opcode = tonumber (string.sub (instruction, -2))

		local parModes = string.sub (instruction, 1, -3)

		local halt, skipCount, newPos = ops [opcode] (tape, i, parModes)

		if (halt) then
			return
		end

		if (newPos) then
			i = newPos
		else
			i = i + skipCount
		end
	end
end

ops [1] = function (tape, pos, parModes)
	local inputPars = GetInputPars (tape, pos, parModes, 2)

	local outputTarget = tape [pos + 3]

	local val = inputPars [1] + inputPars [2]
	tape [outputTarget] = val

	return nil, 4
end

ops [2] = function (tape, pos, parModes)
	local inputPars = GetInputPars (tape, pos, parModes, 2)

	local outputTarget = tape [pos + 3]

	local val = inputPars [1] * inputPars [2]
	tape [outputTarget] = val

	return nil, 4
end

ops [3] = function (tape, pos, parModes)
	local input = GetInput ()

	local outputTarget = tape [pos + 1]

	tape [outputTarget] = input

	return nil, 2
end

ops [4] = function (tape, pos, parModes)
	local inputPars = GetInputPars (tape, pos, parModes, 1)

	SetOutput (inputPars [1])

	return nil, 2
end

ops [5] = function (tape, pos, parModes)
	local inputPars = GetInputPars (tape, pos, parModes, 2)

	local val
	if (inputPars [1] ~= 0) then
		val = inputPars [2]
	end

	return nil, 3, val
end

ops [6] = function (tape, pos, parModes)
	local inputPars = GetInputPars (tape, pos, parModes, 2)

	local val
	if (inputPars [1] == 0) then
		val = inputPars [2]
	end

	return nil, 3, val
end

ops [7] = function (tape, pos, parModes)
	local inputPars = GetInputPars (tape, pos, parModes, 2)

	local outputTarget = tape [pos + 3]

	local val = 0
	if (inputPars [1] < inputPars [2]) then
		val = 1
	end

	tape [outputTarget] = val

	return nil, 4
end

ops [8] = function (tape, pos, parModes)
	local inputPars = GetInputPars (tape, pos, parModes, 2)

	local outputTarget = tape [pos + 3]

	local val = 0
	if (inputPars [1] == inputPars [2]) then
		val = 1
	end

	tape [outputTarget] = val

	return nil, 4
end

ops [99] = function (tape, pos, parModes)
	--print ('OP 99: first value is:', tape [0])
	return true, 1
end

function GetInputPars (tape, pos, parModes, count)
	local vals = {}
	for i = 1, count do
		local par = tape [pos + i]
		if (string.sub (parModes, -i, -i) == '1') then
			table.insert (vals, par)
		else
			table.insert (vals, tape [par])
		end
	end
	return vals
end

local inputArray = {}, {}

function GetInput ()
    print ('Enter a number for input')
	local val = io.stdin:read ()
	val = tonumber (val)
	return val
end

function SetOutput (out)
	print ('Output:', out)
end

function chainAmps (tape, inputs)
    local output = 0
    local flipFlop = false
    GetInput = function ()
        flipFlop = not flipFlop
        if (flipFlop) then
            local input = table.remove (inputs, 1)
            --print ('>>>: ', input)
            return input
        else
            --print ('Previous output:', output)
            return output
        end
    end

    SetOutput = function (out)
        --print ('<<<: ', out)
        output = out
    end

    for i = 1, 5 do
        runTape (tape)
    end

    return (output)
end

--print (chainAmps ({3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0}, {4,3,2,1,0}))    --43210
--print (chainAmps ({3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0}, {0,1,2,3,4}))    --54321
-- print (chainAmps ({3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0}, {1,0,4,3,2})) --65210

function getMax ()
    local maxValue, maxOrder = 0
    for a = 1, 5 do
        for b = 1, 5 do
            for c = 1, 5 do
                for d = 1, 5 do
                    for e = 1, 5 do
                        if ((a + b + c + d + e) == 15 and (a * b * c * d * e) == 120) then
                            local order = {a-1,b-1,c-1,d-1,e-1}
                            print (table.concat (order, ','))
                            local output = chainAmps (inputTape, order)
                            if (output > maxValue) then
                                maxValue = output
                                maxOrder = order
                            end
                        end
                    end
                end
            end
        end
    end
    print (maxValue)
end

getMax ()