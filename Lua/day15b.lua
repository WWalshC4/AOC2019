local inputTape = {}

io.input ('day15_input.txt')

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

-----
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

function MoveDroid (tape)
	local grid = {
		[0] = {[0] = 'O'}
	}

	local undo = {
		N = 'S',
		E = 'W',
		W = 'E',
		S = 'N',
	}

	local moveDirs = {
		N = 1,
		E = 4,
		W = 3,
		S = 2,
	}

	local unknowns

	local history = {}

	local x = 0
	local y = 0
	local lastX = 0
	local lastY = 0


	local getInput = function ()
		local dir

		local vals = {
			N = grid [y - 1] and grid [y - 1] [x],
			W = grid [y] and grid [y] [x - 1],
			E = grid [y] and grid [y] [x + 1],
			S = grid [y + 1] and grid [y + 1] [x],
		}

		unknowns = 4
		for _, _ in pairs (vals) do
			unknowns = unknowns - 1
		end

		if (unknowns == 0) then
			local lastDir = table.remove (history)
			dir = undo [lastDir]
			if (not dir) then
				dir = 'N'
				print ('no dir, trying to end')
			end
		else
			for moveDir, _ in pairs (moveDirs) do
				if (vals [moveDir] == nil) then
					dir = moveDir
					break
				end
			end
		end

		lastX = x
		lastY = y

		if (dir == 'N') then
			y = y - 1

		elseif (dir == 'E') then
			x = x + 1

		elseif (dir == 'W') then
			x = x - 1

		elseif (dir == 'S') then
			y = y + 1
		end

		if (unknowns > 0) then
			table.insert (history, dir)
		end
		return moveDirs [dir]
	end

	local setOutput = function (out)
		if (out == 0) then
			grid [y] = grid [y] or {}

			grid [y] [x] = '#'

			x = lastX
			y = lastY

			table.remove (history)

		elseif (out == 1) then

			grid [y] = grid [y] or {}

			grid [y] [x] = '.'

		elseif (out == 2) then
			grid [lastY] = grid [lastY] or {}
			grid [lastY] [lastX] = '.'

			grid [y] = grid [y] or {}
			grid [y] [x] = 'O'
		end

		if (#history == 0 and unknowns == 0) then
			return true
		end
	end

	runTape (tape, getInput, setOutput)

	return grid, history
end

function printGrid (grid)

	print ('-------------------')

	local minX, maxX, minY, maxY = 0, 0 ,0 ,0

	for y, xLine in pairs (grid) do
		for x, _ in pairs (xLine) do
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

	for y = minY, maxY do
		local line = {}
		for x = minX, maxX do
			if (grid [y] and grid [y] [x]) then
				table.insert (line, grid [y] [x])
			else
				table.insert (line, ' ')
			end
		end
		print (table.concat (line))
	end

	print ('-------------------')
end

local grid, history = MoveDroid (inputTape)

function fillOxygen (grid)
	local full = false
	local steps = 0

	while (full == false) do
		steps = steps + 1
		full = true
		local newGrid = CopyTable (grid)

		for y, xLine in pairs (grid) do
			for x, _ in pairs (xLine) do
				if (grid [y] [x] == 'O') then
					if (grid [y - 1] and grid [y - 1] [x] and grid [y - 1] [x] == '.') then
						newGrid [y - 1] [x] = 'O'
						full = false
					end
					if (grid [y] and grid [y] [x - 1] and grid [y] [x - 1] == '.') then
						newGrid [y] [x - 1] = 'O'
						full = false
					end
					if (grid [y] and grid [y] [x + 1] and grid [y] [x + 1] == '.') then
						newGrid [y] [x + 1] = 'O'
						full = false
					end
					if (grid [y + 1] and grid [y + 1] [x] and grid [y + 1] [x] == '.') then
						newGrid [y + 1] [x] = 'O'
						full = false
					end
				end
			end
		end

		grid = newGrid
	end
	return steps
end

local steps = fillOxygen (grid)
print (steps)
