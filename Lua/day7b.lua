local inputTape = {}

io.input ('day7_input.txt')

local data = io.read ('*all')

for op in string.gmatch (data, '(%d+)') do
    table.insert (inputTape, tonumber (op))
end

local ops = {}

function runTape (luaTape, getInput, setOutput)

    local tape
    if (luaTape.pos == nil) then
        tape = {
			pos = 0
		}
        for i = 1, #luaTape do
            tape [i-1] = luaTape [i]
        end
    else
        tape = luaTape
	end

	tape.getInput = getInput or GetInput
	tape.setOutput = setOutput or SetOutput

	while (true) do
		local instruction = tostring (tape [tape.pos])

		local opcode = tonumber (string.sub (instruction, -2))

		local parModes = string.sub (instruction, 1, -3)

		local halt = ops [opcode] (tape, parModes)

        if (halt) then
			return halt, tape
		end
	end
end

ops [1] = function (tape, parModes)
	local pos = tape.pos
	local inputPars = GetInputPars (tape, parModes, 2)

	local outputTarget = tape [pos + 3]

	local val = inputPars [1] + inputPars [2]
	tape [outputTarget] = val

	tape.pos = tape.pos + 4
end

ops [2] = function (tape, parModes)
	local pos = tape.pos
	local inputPars = GetInputPars (tape, parModes, 2)

	local outputTarget = tape [pos + 3]

	local val = inputPars [1] * inputPars [2]
	tape [outputTarget] = val

	tape.pos = tape.pos + 4
end

ops [3] = function (tape, parModes)
	local pos = tape.pos
	local input = tape.getInput ()

	local outputTarget = tape [pos + 1]

	tape [outputTarget] = input

	tape.pos = tape.pos + 2
end

ops [4] = function (tape, parModes)
	local pos = tape.pos
	local inputPars = GetInputPars (tape, parModes, 1)

	tape.pos = tape.pos + 2

	local retVal = tape.setOutput (inputPars [1])

	return retVal
end

ops [5] = function (tape, parModes)
	local pos = tape.pos
	local inputPars = GetInputPars (tape, parModes, 2)

	if (inputPars [1] ~= 0) then
		tape.pos = inputPars [2]
	else
		tape.pos = tape.pos + 3
	end
end

ops [6] = function (tape, parModes)
	local pos = tape.pos
	local inputPars = GetInputPars (tape, parModes, 2)

	if (inputPars [1] == 0) then
		tape.pos = inputPars [2]
	else
		tape.pos = tape.pos + 3
	end
end

ops [7] = function (tape, parModes)
	local pos = tape.pos
	local inputPars = GetInputPars (tape, parModes, 2)

	local outputTarget = tape [pos + 3]

	local val = 0
	if (inputPars [1] < inputPars [2]) then
		val = 1
	end

	tape [outputTarget] = val

	tape.pos = tape.pos + 4
end

ops [8] = function (tape, parModes)
	local pos = tape.pos
	local inputPars = GetInputPars (tape, parModes, 2)

	local outputTarget = tape [pos + 3]

	local val = 0
	if (inputPars [1] == inputPars [2]) then
		val = 1
	end

	tape [outputTarget] = val

	tape.pos = tape.pos + 4
end

ops [99] = function (tape, parModes)
	--print ('OP 99: first value is:', tape [0])
	return true
end

function GetInputPars (tape, parModes, count)
	local pos = tape.pos
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
    local getInput = function ()
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

    local setOutput = function (out)
        --print ('<<<: ', out)
        output = out
    end

    for i = 1, 5 do
        runTape (tape, getInput, setOutput)
    end

    return (output)
end

function chainAmpsLoop (inputTape, inputs)
	local tapes = {
		inputTape,
		inputTape,
		inputTape,
		inputTape,
		inputTape,
	}

	local output = 0

	local setOutput = function (out)
		--print ('<<<: ', out)
		output = out
		return out
	end

	local halted
	while (halted ~= true) do

		for i = 1, 5 do
			local getInput = function ()
				local retVal
				if (inputs [i]) then
					retVal = inputs [i]
					inputs [i] = nil
					--print ('Providing input ' , i, retVal)
				else
					--print ('Providing previous output ' , output)

					retVal = output
				end
				return retVal
			end

			local tape

			halted, tape = runTape (tapes [i], getInput, setOutput)
			tapes [i] = tape
		end
	end

	return output
end

print (chainAmps (
	{3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0},
	 {4,3,2,1,0}))    --43210

print (chainAmps (
	{3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0},
	 {0,1,2,3,4}))    --54321

print (chainAmps (
	{3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0},
	 {1,0,4,3,2})) --65210

print (chainAmpsLoop (
	{3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5},
	 {9,8,7,6,5})) -- 139629729

print (chainAmpsLoop (
	{3,52,1001,52,-5,52,3,53,1,52,56,54,1007,54,5,55,1005,55,26,1001,54,-5,54,1105,1,12,1,53,54,53,1008,54,0,55,1001,55,1,55,2,53,55,53,4,53,1001,56,-1,56,1005,56,6,99,0,0,0,0,10},
	{9,7,8,5,6})) -- 18216


function getMax ()
    local maxValue, maxOrder = 0
    for a = 1, 5 do
        for b = 1, 5 do
            for c = 1, 5 do
                for d = 1, 5 do
                    for e = 1, 5 do
                        if ((a + b + c + d + e) == 15 and (a * b * c * d * e) == 120) then
                            local order = {a-1,b-1,c-1,d-1,e-1}
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

getMax ()  -- 67023

function getMaxLoop ()
    local maxValue, maxOrder = 0
    for a = 5, 9 do
        for b = 5, 9 do
            for c = 5, 9 do
                for d = 5, 9 do
                    for e = 5, 9 do
                        if ((a + b + c + d + e) == 35 and (a * b * c * d * e) == 15120) then
                            local order = {a,b,c,d,e}
                            local output = chainAmpsLoop (inputTape, order)
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

getMaxLoop () --7818398
