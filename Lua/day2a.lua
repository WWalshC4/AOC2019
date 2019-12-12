local input = {1,0,0,3,1,1,2,3,1,3,4,3,1,5,0,3,2,1,9,19,1,5,19,23,1,6,23,27,1,27,10,31,1,31,5,35,2,10,35,39,1,9,39,43,1,43,5,47,1,47,6,51,2,51,6,55,1,13,55,59,2,6,59,63,1,63,5,67,2,10,67,71,1,9,71,75,1,75,13,79,1,10,79,83,2,83,13,87,1,87,6,91,1,5,91,95,2,95,9,99,1,5,99,103,1,103,6,107,2,107,13,111,1,111,10,115,2,10,115,119,1,9,119,123,1,123,9,127,1,13,127,131,2,10,131,135,1,135,5,139,1,2,139,143,1,143,5,0,99,2,0,14,0}


function runTape (tape)
	local i = 1
	while (true) do
		local opcode = tape [i]
		local i1 = tape [i + 1] + 1
		local i2 = tape [i + 2] + 1
		local target = tape [i + 3] + 1

		local skipCount

		if (opcode == 1) then
			local val = tape [i1] + tape [i2]
			tape [target] = val
			skipCount = 4

		elseif (opcode == 2) then
			local val = tape [i1] * tape [i2]
			tape [target] = val
			skipCount = 4

		elseif (opcode == 99) then
			return (tape [1])
		end
		i = i + skipCount
	end
end

--print (runTape ({1,9,10,3,2,3,11,0,99,30,40,50})) -- 3500

local day1aTape = {}
for k,v in pairs (input) do
	day1aTape [k] = v
	day1aTape [2] = 12
	day1aTape [3] = 2
end

print (runTape (day1aTape))right

for noun = 1, 100 do
	for verb = 1, 100 do
		local tape = {}
		for k,v in pairs (input) do
			tape [k] = v
		end
		tape [2] = noun
		tape [3] = verb
		if (runTape (tape) == 19690720) then
			print (noun, verb)
		end
	end
end
