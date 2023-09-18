CHANNEL_FIRST_NAME = 1

CHANNEL_LAST_NAME  = 1 + 48 

CHANNEL_NAME  = {"1"  ,"2"  ,"3"  ,"4"  ,"5"  ,"6"  ,"7"  ,"8"  ,"9"  ,"10" ,
				 "11" ,"12" ,"13" ,"14" ,"j1" ,"j2" ,"j3" ,"j4" ,"j8" ,"j12",
				 "j16","j34","36" ,"j38","40" ,"j42","44" ,"j46","48" ,"52" ,
				 "56" ,"60" ,"64" ,"100","104","108","112","116","120","124",
				 "128","132","136","140","149","153","157","161","165"       }

CHANNEL_NUMBER = {1  ,2  ,3  ,4  ,5  ,6  ,7  ,8  ,9  ,10 ,
				  11 ,12 ,13 ,14 ,16 ,12 ,8  ,4  ,8  ,12 ,
				  16 ,34 ,36 ,38 ,40 ,42 ,44 ,46 ,48 ,52 ,
				  56 ,60 ,64 ,100,104,108,112,116,120,124,
				  128,132,136,140,149,153,157,161,165     }
				 
CHANNEL_FREQ   = {2412000000,2417000000,2422000000,2427000000,2432000000,2437000000,2442000000,2447000000,2452000000,2457000000,
				  2462000000,2467000000,2472000000,2484000000,4920000000,4940000000,4960000000,4980000000,5040000000,5060000000,
				  5080000000,5170000000,5180000000,5190000000,5200000000,5210000000,5220000000,5230000000,5240000000,5260000000,
				  5280000000,5300000000,5320000000,5500000000,5520000000,5540000000,5560000000,5580000000,5600000000,5620000000,
				  5640000000,5660000000,5680000000,5700000000,5745000000,5765000000,5785000000,5805000000,5825000000            }
				 
CHANNEL_BAND  = {0,0,0,0,0,0,0,0,0,0,
			     0,0,0,0,2,2,2,2,1,1,
				 1,1,1,1,1,1,1,1,1,1,
				 1,1,1,1,1,1,1,1,1,1,
				 1,1,1,1,1,1,1,1,1   }
					
COLORS = {	red 	= 1,
			blue    = 3,
			green 	= 4,
			black   = 5,
			yellow  = 6,
			orange  = 7,
			purple  = 8
		 }
-----------------------------------------------------------------------------------------------------
REGISTER_TYPE = {
					phy   = 1,
					mac   = 2,
					drpw  = 3,
					ocp   = 4
				}
-----------------------------------------------------------------------------------------------------				
function ReadRegister(REGISTER_TYPE, ADDRESS, START_BIT, END_BIT)
	local retVal = RSTD.RunFunction("/Global Settings/Read("..ADDRESS .."," ..REGISTER_TYPE .. "," ..START_BIT .."," ..END_BIT ..")")
	return (tonumber(retVal))
end
-----------------------------------------------------------------------------------------------------
function WriteRegister(REGISTER_TYPE, ADDRESS, START_BIT, END_BIT, VALUE)
	RSTD.RunFunction("/Global Settings/Write("..ADDRESS .."," ..REGISTER_TYPE .. "," ..START_BIT .."," ..END_BIT .."," ..VALUE ..")")
end
-----------------------------------------------------------------------------------------------------
function Split(text, sep, plain)
	local res={}
	local searchPos=1
	while true do
		local matchStart, matchEnd=string.find(text, sep, searchPos, plain)
		if matchStart and matchEnd >= matchStart then
			-- insert string up to separator into result
			table.insert(res, string.sub(text, searchPos, matchStart-1))
			-- continue search after separator
			searchPos=matchEnd+1
		else
			-- insert whole reminder as result
			table.insert(res, string.sub(text, searchPos))
			break
		end
	end
	return res
end

function GetFieldBits(MASK)
	local field_bits_table = {}
	local start_bit = 0
	local end_bit = 0
	local tmp_mask = MASK
	
	if (type(tmp_mask) == "string") then
		field_bits_table = Split (tmp_mask,":",false)
		start_bit = field_bits_table[2]
		end_bit = field_bits_table[1]
	else
		if (tmp_mask == 0) then
			RSTD.MessageColor("Invalid mask!\n", COLORS.red)
			return -1, -1
		end		
		
		-- Get to first "on" bit starting from lsb
		while (tmp_mask % 2 == 0) do
			start_bit = start_bit + 1
			tmp_mask = math.floor(tmp_mask / 2)			
		end
		end_bit = start_bit - 1
		
		-- Count number of consecutive "on" bits towards msb
		while (tmp_mask % 2 ~= 0) do
			end_bit = end_bit + 1
			tmp_mask = math.floor(tmp_mask / 2)
		end
		
		if (2^(end_bit+1) - 2^start_bit ~= MASK) then
			RSTD.MessageColor("Invalid mask!\n", COLORS.red)
			return -1, -1
		end		
	end
	
	return start_bit, end_bit
end
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------