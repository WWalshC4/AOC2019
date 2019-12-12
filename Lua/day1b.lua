local modules = {
	55131,
	114008,
	145297,
	76135,
	50317,
	134036,
	122136,
	97704,
	51245,
	141732,
	120427,
	142020,
	88166,
	55313,
	110391,
	112436,
	78195,
	74294,
	128984,
	68240,
	137098,
	142016,
	83577,
	89257,
	107744,
	67357,
	131342,
	98247,
	137501,
	134577,
	65696,
	84925,
	50159,
	110319,
	91921,
	103303,
	84505,
	84683,
	100811,
	82626,
	66774,
	123216,
	95151,
	88237,
	60705,
	124319,
	102926,
	143160,
	92780,
	64283,
	132434,
	113935,
	84907,
	113698,
	117240,
	129327,
	78837,
	144841,
	138054,
	130990,
	100191,
	141768,
	138941,
	108165,
	62138,
	121690,
	117305,
	90147,
	134422,
	78031,
	121331,
	120947,
	120235,
	138880,
	141076,
	119480,
	66844,
	77660,
	106364,
	99187,
	144244,
	120483,
	77715,
	135703,
	125521,
	123253,
	127556,
	96458,
	91965,
	73924,
	95176,
	87540,
	122083,
	146013,
	67761,
	100413,
	145994,
	149450,
	94330,
	112824,
}

function moduleFuel (mass)
	mass = tonumber (mass)
	if (mass == nil) then
		return 0
	end

	local fuel = math.floor (mass / 3) - 2

	if (fuel < 0) then
		return 0
	end

	return fuel
end

moduleFuelTotal = 0

function moduleAndFuelFuel (mass)
	local totalForModule = 0
	local neededExtra = mass
	repeat
		neededExtra = moduleFuel (neededExtra)
		totalForModule = totalForModule + neededExtra
	until
		neededExtra == 0

	return totalForModule
end


print (moduleAndFuelFuel (12)) --  expect 2
print (moduleAndFuelFuel (14)) --  expect 2
print (moduleAndFuelFuel (1969)) --  expect 966
print (moduleAndFuelFuel (100756)) -- expect 50346


for _, module in ipairs (modules) do
	moduleFuelTotal = moduleFuelTotal + moduleAndFuelFuel (module)
end

print (moduleFuelTotal)
