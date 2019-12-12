local input = {}

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

		local halt, skipCount = ops [opcode] (tape, i, parModes)

		if (halt) then
			return
		end

		i = i + skipCount
	end
end

ops [1] = function (tape, pos, parModes)
	local par1 = tape [pos + 1]
	local par2 = tape [pos + 2]
	local par3 = tape [pos + 3]

	local i1, i2, target

	if (string.sub (parModes, -1, -1) == '1') then
		i1 = par1
	else
		i1 = tape [par1]
	end

	if (string.sub (parModes, -2, -2) == '1') then
		i2 = par2
	else
		i2 = tape [par2]
	end

	if (string.sub (parModes, -3, -3) == '1') then
		print ('Error: target for opcode 1 is immediate mode')
		return true
	else
		target = par3
	end

	local val = i1 + i2
	tape [target] = val

	return nil, 4
end

ops [2] = function (tape, pos, parModes)
	local par1 = tape [pos + 1]
	local par2 = tape [pos + 2]
	local par3 = tape [pos + 3]

	local i1, i2, target

	if (string.sub (parModes, -1, -1) == '1') then
		i1 = par1
	else
		i1 = tape [par1]
	end

	if (string.sub (parModes, -2, -2) == '1') then
		i2 = par2
	else
		i2 = tape [par2]
	end

	if (string.sub (parModes, -3, -3) == '1') then
		print ('Error: target for opcode 2 is immediate mode')
		return true
	else
		target = par3
	end

	local val = i1 * i2
	tape [target] = val

	return nil, 4
end

ops [3] = function (tape, pos, parModes)
	local val = GetInput ()

	local par1 = tape [pos + 1]

	local target

	if (string.sub (parModes, -1, -1) == '1') then
		print ('Error: target for opcode 3 is immediate mode')
		return true
	else
		target = par1
	end

	tape [target] = val

	return nil, 2
end

ops [4] = function (tape, pos, parModes)
	local par1 = tape [pos + 1]

	local i1

	if (string.sub (parModes, -1, -1) == '1') then
		i1 = par1
	else
		i1 = tape [par1]
	end

	local val = i1

	SetOutput (val)

	return nil, 2
end

ops [99] = function (tape, pos, parModes)
	print ('OP 99: first value is:', tape [0])
	return true, 1
end

function GetInput ()
	print ('Enter a number for input')
	local val = io.read ()
	val = tonumber (val)
	return val
end

function SetOutput (out)
	print ('Output:', out)
end

--runTape ({1,9,10,3,2,3,11,0,99,30,40,50}) -- 3500

--runTape ({1002,4,3,4,33})

--runTape ({3,0,4,0,99}) -- prints what it gets given

local input_a = {3,225,1,225,6,6,1100,1,238,225,104,0,1101,9,90,224,1001,224,-99,224,4,224,102,8,223,223,1001,224,6,224,1,223,224,223,1102,26,62,225,1101,11,75,225,1101,90,43,225,2,70,35,224,101,-1716,224,224,4,224,1002,223,8,223,101,4,224,224,1,223,224,223,1101,94,66,225,1102,65,89,225,101,53,144,224,101,-134,224,224,4,224,1002,223,8,223,1001,224,5,224,1,224,223,223,1102,16,32,224,101,-512,224,224,4,224,102,8,223,223,101,5,224,224,1,224,223,223,1001,43,57,224,101,-147,224,224,4,224,102,8,223,223,101,4,224,224,1,223,224,223,1101,36,81,225,1002,39,9,224,1001,224,-99,224,4,224,1002,223,8,223,101,2,224,224,1,223,224,223,1,213,218,224,1001,224,-98,224,4,224,102,8,223,223,101,2,224,224,1,224,223,223,102,21,74,224,101,-1869,224,224,4,224,102,8,223,223,1001,224,7,224,1,224,223,223,1101,25,15,225,1101,64,73,225,4,223,99,0,0,0,677,0,0,0,0,0,0,0,0,0,0,0,1105,0,99999,1105,227,247,1105,1,99999,1005,227,99999,1005,0,256,1105,1,99999,1106,227,99999,1106,0,265,1105,1,99999,1006,0,99999,1006,227,274,1105,1,99999,1105,1,280,1105,1,99999,1,225,225,225,1101,294,0,0,105,1,0,1105,1,99999,1106,0,300,1105,1,99999,1,225,225,225,1101,314,0,0,106,0,0,1105,1,99999,1008,226,677,224,1002,223,2,223,1005,224,329,1001,223,1,223,1007,677,677,224,102,2,223,223,1005,224,344,101,1,223,223,108,226,677,224,102,2,223,223,1006,224,359,101,1,223,223,108,226,226,224,1002,223,2,223,1005,224,374,1001,223,1,223,7,226,226,224,1002,223,2,223,1006,224,389,1001,223,1,223,8,226,677,224,1002,223,2,223,1006,224,404,1001,223,1,223,107,677,677,224,1002,223,2,223,1006,224,419,101,1,223,223,1008,677,677,224,102,2,223,223,1006,224,434,101,1,223,223,1107,226,677,224,102,2,223,223,1005,224,449,1001,223,1,223,107,226,226,224,102,2,223,223,1006,224,464,101,1,223,223,107,226,677,224,102,2,223,223,1005,224,479,1001,223,1,223,8,677,226,224,102,2,223,223,1005,224,494,1001,223,1,223,1108,226,677,224,102,2,223,223,1006,224,509,101,1,223,223,1107,677,226,224,1002,223,2,223,1005,224,524,101,1,223,223,1008,226,226,224,1002,223,2,223,1005,224,539,101,1,223,223,7,226,677,224,1002,223,2,223,1005,224,554,101,1,223,223,1107,677,677,224,1002,223,2,223,1006,224,569,1001,223,1,223,8,226,226,224,1002,223,2,223,1006,224,584,101,1,223,223,1108,677,677,224,102,2,223,223,1005,224,599,101,1,223,223,108,677,677,224,1002,223,2,223,1006,224,614,101,1,223,223,1007,226,226,224,102,2,223,223,1005,224,629,1001,223,1,223,7,677,226,224,1002,223,2,223,1005,224,644,101,1,223,223,1007,226,677,224,102,2,223,223,1005,224,659,1001,223,1,223,1108,677,226,224,102,2,223,223,1006,224,674,101,1,223,223,4,223,99,226}

--runTape (input_a) -- 13818007
