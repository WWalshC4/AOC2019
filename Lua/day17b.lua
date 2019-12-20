local inputTape = {}

io.input ('day17_input.txt')

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

function buildView (tape)
	local grid = {
	}

	local x = 0
	local y = 0

	local robotX
	local robotY

	local getInput = function ()

	end

	local setOutput = function (out)
		local char = string.char (out)

		if (char == '^') then
			robotX = x
			robotY = y
		end

		if (char == '\010') then
			x = 0
			y = y + 1
		else
			grid [y] = grid [y] or {}
			grid [y] [x] = char
			x = x + 1
		end
	end

	runTape (tape, getInput, setOutput)

	return grid, robotX, robotY
end

function getAdjacentVals (grid, x, y, checkVals)
	local vals = {
		N = grid [y - 1] and grid [y - 1] [x],
		S = grid [y + 1] and grid [y + 1] [x],
		W = grid [y] and grid [y] [x - 1],
		E = grid [y] and grid [y] [x + 1],
	}

	if (checkVals) then
		for k, v in pairs (CopyTable (vals)) do
			if (not (checkVals [v])) then
				vals [k] = nil
			end
		end
	end

	for k, v in pairs (CopyTable (vals)) do
		table.insert (vals, v)
	end

	return vals
end

function getIntersections (grid)
	local intersections = {}
	for y, xLine in pairs (grid) do
		for x, val in pairs (xLine) do
			if (val == '#') then
				local checkVals = {
					['#'] = true,
				}
				local adjacentVals = getAdjacentVals (grid, x, y, checkVals)
				if (#adjacentVals == 4) then
					table.insert (intersections, {x = x, y = y})
				end
			end
		end
	end
	return intersections
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

function walkGrid (grid, robotX, robotY)
	local moves = {}
	local count = 0

	local right = {
		N = 'E',
		E = 'S',
		S = 'W',
		W = 'N',
	}

	local left = {
		N = 'W',
		W = 'S',
		S = 'E',
		E = 'N',
	}

	local dir = 'N'

	local atEnd = false

	while (not atEnd) do
		local adjacentVals = getAdjacentVals (grid, robotX, robotY, {['#'] = true})

		if (adjacentVals [dir]) then
			count = count + 1
			if (dir == 'N') then
				robotY = robotY - 1

			elseif (dir == 'E') then
				robotX = robotX + 1

			elseif (dir == 'W') then
				robotX = robotX - 1

			elseif (dir == 'S') then
				robotY = robotY + 1
			end

		elseif (adjacentVals [right [dir]]) then
			if (count > 0) then
				table.insert (moves, count)
			end
			table.insert (moves, 'R')
			dir = right [dir]
			count = 0

		elseif (adjacentVals [left [dir]]) then
			table.insert (moves, count)
			table.insert (moves, 'L')
			dir = left [dir]
			count = 0

		else
			table.insert (moves, count)
			atEnd = true
		end
	end

	return (moves)
end

local grid, robotX, robotY = buildView (CopyTable (inputTape))

local moveTable = walkGrid (grid, robotX, robotY)

function findPatterns (moveString)
	local moveGroups = {}

	local function countMatches (s, match)
		local matches = 0
		for _, _ in string.gmatch (s, match) do
			matches = matches + 1
		end
		return matches
	end

	for moveGroup in string.gmatch (moveString, '([RL],.-%d+)') do
		if (moveGroups [moveGroup] == nil) then
			local matches = countMatches (moveGroup, moveString)
			moveGroups [moveGroup] = matches

		end
	end

	local moves = {}

	for moveGroup, _ in pairs (moveGroups) do
		table.insert (moves, moveGroup)
	end


	local subs = {}

	local function addMoveAndTest (move, add)
		local newMove = move .. ',' ..  add
		local matches = countMatches (moveString, newMove)
		return matches, newMove
	end

	local testAll

	testAll = function (start)
		for _, next in ipairs (moves) do
			local matches, newMove = addMoveAndTest (start, next)
			if (matches > 0) then

				subs [newMove] = matches
				testAll (newMove)
			end
		end
	end

	for _, next in ipairs (moves) do
		testAll (next)
	end

	return subs
end

local moveString = table.concat (moveTable, ',')

local subStrings = findPatterns (moveString)

for k,v in pairs (subStrings) do
	if (v < 3) then
		subStrings [k] = nil
	end
end

function checkPatterns (patternGroups)
	local goodPatterns = {}
	for a in pairs (patternGroups) do
		for b in pairs (patternGroups) do
			for c in pairs (patternGroups) do
				if (a ~= b and b ~= c and a ~= c) then
					local test = moveString
					test = string.gsub (test, a, 'A')
					test = string.gsub (test, b, 'B')
					test = string.gsub (test, c, 'C')

					if (not (string.find (test, 'R') or string.find (test, 'L') or string.find (test, '%d'))) then
						if (#a < 20 and #b < 20 and #c < 20 and #test <20) then
							table.insert (goodPatterns, {a = a, b = b, c = c, program = test})
						end
					end
				end
			end
		end
	end
	return goodPatterns
end

local goodPatterns = checkPatterns (subStrings) -- shows six options for completing

for _, pattern in pairs (goodPatterns) do
	print (pattern.a, '\t', pattern.b, '\t', pattern.c, '\t', pattern.program)
end

function runPatterns (patterns)
	for _, pattern in ipairs (patterns or {}) do
		local a = pattern.a
		local b = pattern.b
		local c = pattern.c
		local program = pattern.program

		local input = {}
		for char in string.gmatch (program, '(.)') do
			table.insert (input, string.byte (char))
		end
		table.insert (input, 10)
		for char in string.gmatch (a, '(.)') do
			table.insert (input, string.byte (char))
		end
		table.insert (input, 10)
		for char in string.gmatch (b, '(.)') do
			table.insert (input, string.byte (char))
		end
		table.insert (input, 10)
		for char in string.gmatch (c, '(.)') do
			table.insert (input, string.byte (char))
		end
		table.insert (input, 10)
		table.insert (input, string.byte ('n'))
		table.insert (input, 10)

		local tape = CopyTable (inputTape)
		tape [1] = 2

		local getInput = function ()
			local inputByte = table.remove (input, 1)
			if (inputByte) then
				return (inputByte)
			else
				print ('help help Im stuck on a scaffold')
			end
		end

		local setOutput = function (out)
			if (out < 255) then
				if (out == 88) then
					print ('pattern generated broken robot: ', pattern.program, pattern.a, pattern.b, pattern.c)
				end
			else
				print ('large output:', out)
			end
		end

		runTape (tape, getInput, setOutput)
	end
end

runPatterns (goodPatterns) --895965
