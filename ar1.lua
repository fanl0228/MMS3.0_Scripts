
-----------------------------------------------------------------------------------------------------
--[[
Function Name 	: rbn(Read register By Name)
Description		: Read from a register/field given it's name (xml path)
Input 			: full_path - full register/field name
				  field_mask - in format "end_bit:start_bit" or number (optional)
Output  		: register/field value (nil on error)
Examples 		: res = rbn ("/Registers/BSS_GPADC_REG/REG13")
				  res = rbn ("/Registers/BSS_GPADC_REG/REG13", "1:1")
]]--
function rbn(full_path, field_mask)
	local start_bit, end_bit
	local res, val
	
	if (field_mask ~= nil) then
		start_bit, end_bit = GetFieldBits(field_mask)	
		res, val = ar1.ReadRegisterByName (full_path, tonumber(start_bit), tonumber(end_bit))
	else
		res, val = ar1.ReadByName (full_path)
	end
	
	if (res ~= 0) then
		val = nil;
		WriteToLog("ReadRegisterByName / ReadByName returned error code: " .. res, "red");
	end
	
	return val
end
-----------------------------------------------------------------------------------------------------
--[[
Function Name 	: wbn(Write register By Name)
Description		: write to a register/field given it's name (xml path) 
Input 			: full_path - full register/field name
				  value - value to write
				  field_mask - in format "end_bit:start_bit" or number (optional)
Output  		: error code(0-success)
Example 		: res = wbn ("/Registers/BSS_GPADC_REG/REG13", 0x1)
				  res = wbn ("/Registers/BSS_GPADC_REG/REG13", 0x1, "1:1")
]]--
--void
function wbn(full_path, value, field_mask)
	local start_bit, end_bit
	local res
	
	if (field_mask ~= nil) then
		start_bit, end_bit = GetFieldBits(field_mask)	
		res = ar1.WriteRegisterByName (full_path, tonumber(start_bit), tonumber(end_bit), value)
	else
		res = ar1.WriteByName (full_path, value)
	end
	
	return res
end
