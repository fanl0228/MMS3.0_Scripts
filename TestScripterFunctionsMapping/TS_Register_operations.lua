------------------------------------------------------------
--Register operations
------------------------------------------------------------
function TwosComp(START_BIT, END_BIT, value)
	local numOfBits = END_BIT - START_BIT + 1
	if value < 0 then
		value = value + 2^(numOfBits)
	end
	return value
end

--[[
Function Name 	: rbn(Read register By Name)
Description		: the main purpose is to use same scripts for different boards in case there are same register names  with different addresses
			 Also can read from not mapped part of register
Input 		: String - full register name (with full path), String bit mask
Output  		: Numeric value
Example 		: res = rbn ("/Registers/phy/Test_Port_Interface/PRAM_IQ_SAMPLES_CFG", "15:0")
]]--
function rbn(FULL_REGISTER_NAME, BIT_MASK)
	local retVal = RSTD.RunFunction("/Global Settings/ReadPortByRegisterName(".. FULL_REGISTER_NAME ..",".. BIT_MASK ..")")
	return tonumber(retVal)
end
-----------------------------------------------------------------------------------------------------
--[[
Function Name 	: wbn(Write register By Name)
Description		: the main purpose is to use same scripts for different boards in case there are same register names  with different addresses
			 Also can write to not mapped part of register
Input 		: String - full register name (with full path), String bit mask, Numeric value 
Output  		: void
Example 		: wbn ("/Registers/phy/Test_Port_Interface/PRAM_IQ_SAMPLES_CFG", "15:0", 0)
]]--
--void
function wbn(FULL_REGISTER_NAME, BIT_MASK, VALUE)
	local START_BIT, END_BIT = GetFieldBits(BIT_MASK)
	VALUE = TwosComp(START_BIT, END_BIT, VALUE)
	RSTD.RunFunction("/Global Settings/WritePortByRegisterName(".. FULL_REGISTER_NAME ..",".. BIT_MASK ..",".. VALUE ..")")
end
-----------------------------------------------------------------------------------------------------
--[[
Function Name 	: rpb(Read Phy register Bits)
Description		: Read  not mapped phy register or part of it.
Input 		: Num - address, String - bit mask
Output  		: Numeric value
Example 		: res = rpb(0x3302, "5:0")
]]--
--int32
function rpb(ADDR, FIELD_BITS)
	local START_BIT, END_BIT = GetFieldBits(FIELD_BITS)
	return ReadRegister(REGISTER_TYPE.phy, ADDR, START_BIT, END_BIT)
end
-----------------------------------------------------------------------------------------------------
--[[
Function Name 	: rmb(Read Mac register Bits)
Description		: Read  not mapped mac register or part of it.
Input 		: Num - address, String - bit mask
Output  		: Numeric value
Example 		: res = rmb(0x30041C, "5:0")
]]--
--int32[] 
function rmb(ADDR, FIELD_BITS)
	local START_BIT, END_BIT = GetFieldBits(FIELD_BITS)
	return ReadRegister(REGISTER_TYPE.mac, ADDR, START_BIT, END_BIT)
end
-----------------------------------------------------------------------------------------------------
--[[
Function Name 	: rdb(Read Drpw register Bits)
Description		: Read  not mapped Drpw register or part of it.
Input 		: Num - address, String - bit mask
Output  		: Numeric value
Example 		: res = rdb(0xE44, "5:0")
]]--
--int32[] 
function rdb(ADDR, FIELD_BITS)
	local START_BIT, END_BIT = GetFieldBits(FIELD_BITS)
	return ReadRegister(REGISTER_TYPE.drpw, ADDR, START_BIT, END_BIT)
end
-----------------------------------------------------------------------------------------------------
--[[
Function Name 	: rob(Read Ocp register Bits)
Description		: Read  not mapped Ocp register or part of it.
Input 		: Num - address, String - bit mask
Output  		: Numeric value
Example 		: res = rob(0x8E, "5:0")
]]--
--int32[] 
function rob(ADDR, FIELD_BITS)
	local START_BIT, END_BIT = GetFieldBits(FIELD_BITS)
	return ReadRegister(REGISTER_TYPE.ocp, ADDR, START_BIT, END_BIT)
end
-----------------------------------------------------------------------------------------------------
--[[
Function Name 	: wpb(Write Phy register Bits)
Description		: Write to not mapped phy register or part of it.
Input 		: Num - address, String - bit mask, Num - value
Output  		: void
Example 		: wpb(0x3302, "5:0", 0x1)
]]--
--void
function wpb(ADDR, FIELD_BITS, VALUE)
	local START_BIT, END_BIT = GetFieldBits(FIELD_BITS)
	VALUE = TwosComp(START_BIT, END_BIT, VALUE)
	WriteRegister(REGISTER_TYPE.phy, ADDR, START_BIT, END_BIT, VALUE)
end
-----------------------------------------------------------------------------------------------------
--[[
Function Name 	: wmb(Write Mac register Bits)
Description		: Write to not mapped Mac register or part of it.
Input 		: Num - address, String - bit mask, Num - value
Output  		: void
Example 		: wmb(0x30041C, "5:0", 0x1)
]]--
--void
function wmb(ADDR, FIELD_BITS, VALUE)
	local START_BIT, END_BIT = GetFieldBits(FIELD_BITS)
	VALUE = TwosComp(START_BIT, END_BIT, VALUE)
	WriteRegister(REGISTER_TYPE.mac, ADDR, START_BIT, END_BIT, VALUE)
end
-----------------------------------------------------------------------------------------------------
--[[
Function Name 	: wdb(Write Drpw register Bits)
Description		: Write to not mapped Drpw register or part of it.
Input 		: Num - address, String - bit mask, Num - value
Output  		: void
Example 		: wdb(0xE44, "5:0", 0x1)
]]--
--void
function wdb(ADDR, FIELD_BITS, VALUE)
	local START_BIT, END_BIT = GetFieldBits(FIELD_BITS)
	VALUE = TwosComp(START_BIT, END_BIT, VALUE)
	WriteRegister(REGISTER_TYPE.drpw, ADDR, START_BIT, END_BIT, VALUE)
end
-----------------------------------------------------------------------------------------------------
--[[
Function Name 	: wob(Write Ocp register Bits)
Description		: Write to not mapped Ocp register or part of it.
Input 		: Num - address, String - bit mask, Num - value
Output  		: void
Example 		: wob(0x8E, "5:0", 0x1)
]]--
--void
function wob(ADDR, FIELD_BITS, VALUE)
	local START_BIT, END_BIT = GetFieldBits(FIELD_BITS)
	VALUE = TwosComp(START_BIT, END_BIT, VALUE)
	WriteRegister(REGISTER_TYPE.ocp, ADDR, START_BIT, END_BIT, VALUE)
end
-----------------------------------------------------------------------------------------------------
--[[
Function Name 	: rrf(Read Register Field)
Description		: Read from any register or part of it by specifying the bit mask
Input 		: String - reg_type, Num - address, String - bit mask, Num - value
Output  		: void
Example 		: res = rrf("phy",0x8E, "5:0")
]]--
function rrf(REG_TYPE, ADDR, MASK)
	if 	(REG_TYPE == "phy") then
		return rpb(ADDR, MASK)
    elseif REG_TYPE == "mac" then
		return rmb(ADDR, MASK)
    elseif REG_TYPE == "drpw" then
		return rdb(ADDR, MASK)
    elseif REG_TYPE == "ocp" then
		return rob(ADDR, MASK)
    else--default--
      RSTD.MessageColor("Invalid register type!\n", COLORS.red)
	  return 0
    end
end
-----------------------------------------------------------------------------------------------------------
function readRegBlock(START_ADDR, STOP_ADDR, INTERVAL, FILE_NAME)
	RSTD.MessageColor("readRegBlock Function Not Supported", COLORS.yellow)
end
-----------------------------------------------------------------------------------------------------------
--[[
Function Name 	: wrf(Write Register Field)
Description		: Write to any register or part of it by specifying the bit mask
Input 		: String - reg_type, Num - address, String - bit mask, Num - value
Output  		: void
Example 		: wrf("phy",0x8E, "5:0", 0x1)
]]--
--void
function wrf(REG_TYPE, ADDR, MASK, NEW_VALUE)
	if 	(REG_TYPE == "phy") then
		wpb(ADDR, MASK, NEW_VALUE)
    elseif REG_TYPE == "mac" then
		wmb(ADDR, MASK, NEW_VALUE)
    elseif REG_TYPE == "drpw" then
		wdb(ADDR, MASK, NEW_VALUE)
    elseif REG_TYPE == "ocp" then
		wob(ADDR, MASK, NEW_VALUE)
    else--default--
      RSTD.MessageColor("Invalid register type!\n", COLORS.red)
    end
end
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------