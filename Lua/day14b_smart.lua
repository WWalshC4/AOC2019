do	--generate inputData from input text
	io.input ('day14_input.txt')

	inputData = {}

	local data

	repeat
		data = io.read ('*line')
		table.insert (inputData, data)
	until
		data == nil
end

sampleData1 = { --31
	'10 ORE => 10 A',
	'1 ORE => 1 B',
	'7 A, 1 B => 1 C',
	'7 A, 1 C => 1 D',
	'7 A, 1 D => 1 E',
	'7 A, 1 E => 1 FUEL	',
}

sampleData2 = { --165
	'9 ORE => 2 A',
	'8 ORE => 3 B',
	'7 ORE => 5 C',
	'3 A, 4 B => 1 AB',
	'5 B, 7 C => 1 BC',
	'4 C, 1 A => 1 CA',
	'2 AB, 3 BC, 4 CA => 1 FUEL',
}

sampleData3 = { --13312
	'157 ORE => 5 NZVS',
	'165 ORE => 6 DCFZ',
	'44 XJWVT, 5 KHKGT, 1 QDVJ, 29 NZVS, 9 GPVTF, 48 HKGWZ => 1 FUEL',
	'12 HKGWZ, 1 GPVTF, 8 PSHF => 9 QDVJ',
	'179 ORE => 7 PSHF',
	'177 ORE => 5 HKGWZ',
	'7 DCFZ, 7 PSHF => 2 XJWVT',
	'165 ORE => 2 GPVTF',
	'3 DCFZ, 7 NZVS, 5 HKGWZ, 10 PSHF => 8 KHKGT	',
}

sampleData4 = { -- 180697
	'2 VPVL, 7 FWMGM, 2 CXFTF, 11 MNCFX => 1 STKFG',
	'17 NVRVD, 3 JNWZP => 8 VPVL',
	'53 STKFG, 6 MNCFX, 46 VJHF, 81 HVMC, 68 CXFTF, 25 GNMV => 1 FUEL',
	'22 VJHF, 37 MNCFX => 5 FWMGM',
	'139 ORE => 4 NVRVD',
	'144 ORE => 7 JNWZP',
	'5 MNCFX, 7 RFSQX, 2 FWMGM, 2 VPVL, 19 CXFTF => 3 HVMC',
	'5 VJHF, 7 MNCFX, 9 VPVL, 37 CXFTF => 6 GNMV',
	'145 ORE => 6 MNCFX',
	'1 NVRVD => 8 CXFTF',
	'1 VJHF, 6 MNCFX => 4 RFSQX',
	'176 ORE => 6 VJHF	',
}

sampleData5 = { -- 2210736
	'171 ORE => 8 CNZTR',
	'7 ZLQW, 3 BMBT, 9 XCVML, 26 XMNCP, 1 WPTQ, 2 MZWV, 1 RJRHP => 4 PLWSL',
	'114 ORE => 4 BHXH',
	'14 VRPVC => 6 BMBT',
	'6 BHXH, 18 KTJDG, 12 WPTQ, 7 PLWSL, 31 FHTLT, 37 ZDVW => 1 FUEL',
	'6 WPTQ, 2 BMBT, 8 ZLQW, 18 KTJDG, 1 XMNCP, 6 MZWV, 1 RJRHP => 6 FHTLT',
	'15 XDBXC, 2 LTCX, 1 VRPVC => 6 ZLQW',
	'13 WPTQ, 10 LTCX, 3 RJRHP, 14 XMNCP, 2 MZWV, 1 ZLQW => 1 ZDVW',
	'5 BMBT => 4 WPTQ',
	'189 ORE => 9 KTJDG',
	'1 MZWV, 17 XDBXC, 3 XCVML => 2 XMNCP',
	'12 VRPVC, 27 CNZTR => 2 XDBXC',
	'15 KTJDG, 12 BHXH => 5 XCVML',
	'3 BHXH, 2 VRPVC => 7 MZWV',
	'121 ORE => 7 VRPVC',
	'7 XCVML => 6 RJRHP',
	'5 BHXH, 4 VRPVC => 5 LTCX',
}

function processLine (line)
	local input, output = string.match (line, '^(.-) => (.-)$')

	local inputs, outputs = {}, {}

	for count, chem in string.gmatch (input, '(%d+) (%a+)')  do
		count = tonumber (count)
		inputs [chem] = count
	end

	for count, chem in string.gmatch (output, '(%d+) (%a+)')  do
		count = tonumber (count)
		outputs [chem] = count
	end

	return inputs, outputs
end

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

function CompareTables (tabA, tabB)
	for k,v in pairs (tabA) do
		if (tabB [k]) then
			if (type (v) == 'table') then
				local out = CompareTables (tabA [k], tabB [k])
				if (out == false) then
					return false
				end
			else
				if (tabA [k] ~= tabB [k]) then
					return false
				end
			end
		else
			return false
		end
	end
	return true
end

function gcd( m, n )
    while n ~= 0 do
        local q = m
        m = n
        n = q % n
    end
    return m
end

function lcm( m, n )
    return ( m ~= 0 and n ~= 0 ) and m * n / gcd( m, n ) or 0
end

function getChemTable (data)
	local reactions = {}

	for _, line in ipairs (data) do
		local i, o = processLine (line)
		table.insert (reactions, {output = o, input = i})
	end

	return reactions
end

function getChems (reactions, fuel)
	local chems = {
		FUEL = fuel or 1,
	}

	local wasted = {}

	while (true) do
		for chem, neededCount in pairs (chems) do
			if (neededCount > 0) then
				for _, reaction in ipairs (reactions) do
					local perReactionCount = reaction.output [chem]
					if (perReactionCount) then
						local multiplier = neededCount / perReactionCount

						chems [chem] = chems [chem] - (multiplier * perReactionCount)
						for inChem, inChemCount in pairs (reaction.input) do
							chems [inChem] = (chems [inChem] or 0) + (multiplier * inChemCount)
						end
					end
				end

			elseif (neededCount == 0) then
				chems [chem] = nil

			elseif (neededCount < 0) then
				wasted [chem] = math.abs (chems [chem])
				chems [chem] = nil
			end
		end

		local justOre = true

		for chem, _ in pairs (chems) do
			if (chem ~= 'ORE') then
				justOre = false
				break
			end
		end

		if (justOre) then
			return chems.ORE, wasted
		end
	end
end

function buildEquation (data)

	local min, max = 1, 10000000000

	local reactions = getChemTable (data)

	while (max - min > 1) do
		local fuel = math.floor (min + ((max - min) / 2))

		local ore = getChems (reactions, fuel)

		if (ore < 1000000000000) then
			min = fuel
		elseif (ore > 1000000000000) then
			max = fuel
		elseif (ore == 1000000000000) then
			print (fuel)
		end
	end

	print (min)
end

--buildEquation (sampleData1) --
--buildEquation (sampleData2) --
--buildEquation (sampleData3) --  82892753
--buildEquation (sampleData4) --  5586022
--buildEquation (sampleData5) --  460664
buildEquation (inputData) --  5650230
