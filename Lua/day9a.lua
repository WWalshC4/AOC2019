local inputTape = {}

io.input ('day9_input.txt')

local data = io.read ('*all')

for op in string.gmatch (data, '(%d+)') do
    table.insert (inputTape, tonumber (op))
end

debug = true

local ops = {}

function runTape (luaTape, getInput, setOutput)

    local tape
    if (luaTape.pos == nil) then
        tape = {
			pos = 0,
			relPos = 0,
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

		if (debug) then
			print (opcode, parModes, tape [tape.pos + 1],tape [tape.pos + 2],tape [tape.pos + 3],tape [tape.pos + 4])
			io.stdin:read ()
		end

		if (ops [opcode]) then
			local halt = ops [opcode] (tape, parModes)

			if (halt) then
				return halt, tape
			end
		else
			print ('Missing opcode:', opcode)
			return
		end


	end
end

ops [1] = function (tape, parModes)
	local inputPars = GetInputPars (tape, parModes, 3, true)

	local outputTarget = inputPars [3]

	local val = inputPars [1] + inputPars [2]
	tape [outputTarget] = val

	tape.pos = tape.pos + 4

	if (debug) then
		print ('add', inputPars [1], inputPars [2], val, outputTarget)
	end
end

ops [2] = function (tape, parModes)
	local inputPars = GetInputPars (tape, parModes, 3, true)

	local outputTarget = inputPars [3]

	local val = inputPars [1] * inputPars [2]
	tape [outputTarget] = val

	tape.pos = tape.pos + 4

	if (debug) then
		print ('mlt', inputPars [1], inputPars [2], val, outputTarget)
	end
end

ops [3] = function (tape, parModes)
	local inputPars = GetInputPars (tape, parModes, 1, true)

	local outputTarget = inputPars [1]

	local val = tape.getInput ()

	tape [outputTarget] = val

	tape.pos = tape.pos + 2

	if (debug) then
		print ('read', inputPars [1], inputPars [2], val, outputTarget)
	end
end

ops [4] = function (tape, parModes)
	local inputPars = GetInputPars (tape, parModes, 1)

	tape.pos = tape.pos + 2

	local retVal = tape.setOutput (inputPars [1])

	if (debug) then
		print ('out', inputPars [1])
	end

	return retVal
end

ops [5] = function (tape, parModes)
	local inputPars = GetInputPars (tape, parModes, 2)

	if (inputPars [1] ~= 0) then
		tape.pos = inputPars [2]
	else
		tape.pos = tape.pos + 3
	end

	if (debug) then
		print ('JMP~0', inputPars [1], inputPars [2])
	end
end

ops [6] = function (tape, parModes)
	local inputPars = GetInputPars (tape, parModes, 2)

	if (inputPars [1] == 0) then
		tape.pos = inputPars [2]
	else
		tape.pos = tape.pos + 3
	end

	if (debug) then
		print ('JMP=0', inputPars [1], inputPars [2])
	end
end

ops [7] = function (tape, parModes)
	local inputPars = GetInputPars (tape, parModes, 3, true)

	local outputTarget = inputPars [3]

	local val = 0
	if (inputPars [1] < inputPars [2]) then
		val = 1
	end

	tape [outputTarget] = val

	tape.pos = tape.pos + 4

	if (debug) then
		print ('LESS', inputPars [1], inputPars [2], outputTarget)
	end
end

ops [8] = function (tape, parModes)
	local inputPars = GetInputPars (tape, parModes, 3, true)

	local outputTarget = inputPars [3]

	local val = 0
	if (inputPars [1] == inputPars [2]) then
		val = 1
	end

	tape [outputTarget] = val

	tape.pos = tape.pos + 4

	if (debug) then
		print ('EQU', inputPars [1], inputPars [2], outputTarget)
	end
end

ops [9] = function (tape, parModes)
	local inputPars = GetInputPars (tape, parModes, 1)

	tape.relPos = tape.relPos + inputPars [1]

	tape.pos = tape.pos + 2

	if (debug) then
		print ('REL', inputPars [1])
	end
end

ops [99] = function (tape, parModes)
	--print ('OP 99: first value is:', tape [0])
	tape.pos = tape.pos + 1
	return true
end

function GetInputPars (tape, parModes, count, lastIsTarget)
	local pos = tape.pos
	local vals = {}
	for i = 1, count do
		local par = tape [pos + i]

		local target
		if (lastIsTarget and i == count) then
			target = true
		end

		local mode = string.sub (parModes, -i, -i)

		if (mode == '0' or mode == '') then --position mode
			if (target) then
				table.insert (vals, par)
			else
				table.insert (vals, tape [par] or 0)
			end

		elseif (mode == '1') then --immediate mode
			if (target) then
				print ('Target not allowed in immediate mode')
			else
				table.insert (vals, par)
			end

		elseif (mode == '2') then --relative mode
			if (target) then
				table.insert (vals, (par + tape.relPos))
			else
				table.insert (vals, tape [par + tape.relPos] or 0)
			end

		else
			print ('hit default case for parameter mode')
			-- default case, same as zero
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

--runTape ({109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99}) -- each of these numbers
--runTape ({1102,34915192,34915192,7,4,7,99,0})	--1219070632396864
--runTape ({104,1125899906842624,99})	--1125899906842624
runTape (inputTape)
