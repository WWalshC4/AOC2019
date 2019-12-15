local inputTape = {}

io.input ('day11_input.txt')

local data = io.read ('*all')

for op in string.gmatch (data, '([%-%d]+)') do
    table.insert (inputTape, tonumber (op))
end

debug = false

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
		if (debug) then
			print (' \r\n')
		end
		local instruction = tostring (tape [tape.pos])

		local opcode = tonumber (string.sub (instruction, -2))

		local parModes = string.sub (instruction, 1, -3)

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
	local refs = {
		true, true, false,
	}
	local inputPars = GetInputPars (tape, parModes, refs)

	local outputTarget = inputPars [3]

	local val = inputPars [1] + inputPars [2]

	SetTapeVal (tape, outputTarget, val)

	if (debug) then
		print ('ADD', inputPars [1], inputPars [2], val, outputTarget)
	end
end

ops [2] = function (tape, parModes)
	local refs = {
		true, true, false,
	}
	local inputPars = GetInputPars (tape, parModes, refs)

	local outputTarget = inputPars [3]

	local val = inputPars [1] * inputPars [2]

	SetTapeVal (tape, outputTarget, val)

	if (debug) then
		print ('MULTIPLY', inputPars [1], inputPars [2], val, outputTarget)
	end
end

ops [3] = function (tape, parModes)
	local refs = {
		false,
	}
	local inputPars = GetInputPars (tape, parModes, refs)

	local outputTarget = inputPars [1]

	local val = tape.getInput ()

	SetTapeVal (tape, outputTarget, val)

	if (debug) then
		print ('INPUT', inputPars [1], val, outputTarget)
	end
end

ops [4] = function (tape, parModes)
	local refs = {
		true,
	}
	local inputPars = GetInputPars (tape, parModes, refs)

	local retVal = tape.setOutput (inputPars [1])

	if (debug) then
		print ('OUTPUT', inputPars [1])
	end

	return retVal
end

ops [5] = function (tape, parModes)
	local refs = {
		true, true,
	}
	local inputPars = GetInputPars (tape, parModes, refs)

	if (inputPars [1] ~= 0) then
		tape.pos = inputPars [2]
	end

	if (debug) then
		print ('JUMP-IF-TRUE', inputPars [1], inputPars [2])
	end
end

ops [6] = function (tape, parModes)
	local refs = {
		true, true,
	}
	local inputPars = GetInputPars (tape, parModes, refs)

	if (inputPars [1] == 0) then
		tape.pos = inputPars [2]
	end

	if (debug) then
		print ('JUMP-IF-FALSE', inputPars [1], inputPars [2])
	end
end

ops [7] = function (tape, parModes)
	local refs = {
		true, true, false,
	}
	local inputPars = GetInputPars (tape, parModes, refs)

	local outputTarget = inputPars [3]

	local val = 0
	if (inputPars [1] < inputPars [2]) then
		val = 1
	end

	SetTapeVal (tape, outputTarget, val)

	if (debug) then
		print ('LESSTHAN', inputPars [1], inputPars [2], outputTarget)
	end
end

ops [8] = function (tape, parModes)
	local refs = {
		true, true, false,
	}
	local inputPars = GetInputPars (tape, parModes, refs)

	local outputTarget = inputPars [3]

	local val = 0
	if (inputPars [1] == inputPars [2]) then
		val = 1
	end

	SetTapeVal (tape, outputTarget, val)

	if (debug) then
		print ('EQUALS', inputPars [1], inputPars [2], outputTarget)
	end
end

ops [9] = function (tape, parModes)
	local refs = {
		true,
	}
	local inputPars = GetInputPars (tape, parModes, refs)

	tape.relPos = tape.relPos + inputPars [1]

	if (debug) then
		print ('ADJUST-REL', inputPars [1], tape.relPos)
	end
end

ops [99] = function (tape, parModes)
	return true
end

function GetInputPars (tape, parModes, getReferencedVals)
	local modes = {}
	for i = 1, #getReferencedVals do
		modes [i] = string.sub (parModes or '', -i, -i)
		modes [i] = tonumber (modes [i]) or 0
	end

	local debugOutput = {}

	local vals = {}
	for i = 1, #getReferencedVals do
		tape.pos = tape.pos + 1

		local par = tape [tape.pos]
		table.insert (debugOutput, par)

		local mode = modes [i]
		local getReferencedVal = getReferencedVals [i]

		local val

		if (mode == 0) then --position mode
			table.insert (debugOutput, 'POS')
			if (getReferencedVal) then
				if (tape [par] == nil) then
					tape [par] = 0
					print (mode, 'Initializing mem at: ', par)
				end
				val = tape [par]
			else
				val = par
			end

		elseif (mode == 1) then --immediate mode
			table.insert (debugOutput, 'IMM')
			if (getReferencedVal) then
				val = par
			else
				print ('Immediate mode not allowed to dereference')
				val = 'ERROR'
			end

		elseif (mode == 2) then --relative mode
			table.insert (debugOutput, 'REL')
			if (getReferencedVal) then
				if (tape [par + tape.relPos] == nil) then
					tape [par + tape.relPos] = 0
					print (mode, 'Initializing mem at: ', par + tape.relPos)
				end
				val = tape [par + tape.relPos]
			else
				val = par + tape.relPos
			end

		else
			print ('unhandled mode case')
			val = 'ERROR'
		end

		table.insert (debugOutput, tostring (getReferencedVal))
		table.insert (debugOutput, val)
		table.insert (vals, val)
	end
	tape.pos = tape.pos + 1

	if (debug) then
		print (table.concat (debugOutput, '\t'))
	end
	return vals
end

function SetTapeVal (tape, index, val)
	if (debug) then
		if (tape [index] == nil) then
			print ('Writing to uninitialized index')
		end
		print ('Writing:', val, 'to index:', index)
	end
	if (index < 0) then
		print ('Writing to negative index in tape')
	end
	tape [index] = val
end

function GetInput ()
	local inputNum
	while (inputNum == nil) do
		print ('Enter a number for input')
		inputNum = io.stdin:read ()
		inputNum = tonumber (inputNum)
	end
	return inputNum
end

function SetOutput (out)
	print ('Output:', out)
end

function PaintShip (tape, ship, facing, posX, posY)
	local ship = ship or {}

	local facing = facing or 'U'

	local posX = posX or 0
	local posY = posY or 0

	local getInput = function ()
		local color = 0
		if (ship [posY] and ship [posY] [posX]) then
			color = ship [posY] and ship [posY] [posX]
		end
		return color
	end

	local outputFun

	local paintShip = function (color)
		ship [posY] = ship [posY] or {}
		ship [posY] [posX] = color
	end


	local moveRobot = function ()
		if (facing == 'U') then
			posY = posY - 1
		elseif (facing == 'D') then
			posY = posY + 1
		elseif (facing == 'L') then
			posX = posX - 1
		elseif (facing == 'R') then
			posX = posX + 1
		end
	end

	local turnRobot = function (dir)
		if (dir == 0) then
			if (facing == 'U') then
				facing = 'L'
			elseif (facing == 'D') then
				facing = 'R'
			elseif (facing == 'L') then
				facing = 'D'
			elseif (facing == 'R') then
				facing = 'U'
			end
		elseif (dir == 1) then
			if (facing == 'U') then
				facing = 'R'
			elseif (facing == 'D') then
				facing = 'L'
			elseif (facing == 'L') then
				facing = 'U'
			elseif (facing == 'R') then
				facing = 'D'
			end
		end
		moveRobot ()
	end

	local setOutput = function (out)
		if (outputFun == paintShip) then
			outputFun = turnRobot
		else
			outputFun = paintShip
		end
		outputFun (out)
	end

	runTape (tape, getInput, setOutput)

	return ship
end

local oneWhitePanelStart = {[16] = {[28] = 1}}
local paintedShip = PaintShip (inputTape, oneWhitePanelStart, nil, 28, 16)

local squareCount = 0

local minX, maxX, minY, maxY = 0, 0 ,0 ,0

for y, xLine in pairs (paintedShip) do
	for x, color in pairs (xLine) do
		squareCount = squareCount  + 1

		--print (x, y)

		if (x == math.abs (x)) then
			if (x > maxX) then
				maxX = x
			end
		else
			if (x < minX) then
				minX = x
			end
		end
	end
	if (y == math.abs (y)) then
		if (y > maxY) then
			maxY = y
		end
	else
		if (y < minY) then
			minY = y
		end
	end
end

print (squareCount, minX, maxX, minY, maxY)

for y = 0, 21 do
	local line = {}
	for x = 0, 70 do
		if (paintedShip [y] and paintedShip [y][x] and paintedShip[y][x] == 1) then
			table.insert (line, '#')
		else
			table.insert (line, ' ')
		end
	end
	print (table.concat (line))
end

-- KBUEGZBK
