--[[
Function Name 	: ReadRegAbs
Description		: Read a Register given its absolute address
Input 			: abs_address - register absolute address
				  field_mask - in format "end_bit:start_bit" or number
Output  		: register/field value (nil on error)
Example 		: val = ar1.ReadRegAbs(0xFFFFE254, "5:0")
]]--
function ar1.ReadRegAbs(abs_address, field_mask)
	local res, val
	local start_bit, end_bit, n_bits
	
	res, val = ar1.Calling_ReadAddr_Single(abs_address)
	
	if (res == 0) then
		start_bit, end_bit = GetFieldBits(field_mask)
		n_bits = end_bit - start_bit + 1
		val = And(rshift(val, start_bit), (2^n_bits)-1)
	end

	return val;
end
-----------------------------------------------------------------------------------------------------
--[[
Function Name 	: WriteRegAbs
Description		: Write a Register given its absolute address
Input 			: abs_address - register absolute address
				  field_mask - in format "end_bit:start_bit" or number
				  value - value to write
Output  		: error code(0-success)
Example 		: res = ar1.WriteRegAbs(0xFFFFE254, "5:0", 0x1F)
]]--
function ar1.WriteRegAbs(abs_address, field_mask, value)
	local res, reg_val
	local start_bit, end_bit, n_bits, aligned_field_mask
	
	start_bit, end_bit = GetFieldBits(field_mask)
	n_bits = end_bit - start_bit + 1
	aligned_field_mask = lshift(2^n_bits - 1, start_bit)	
	value = TwosComp(start_bit, end_bit, value)
	
	if (n_bits == 32) then
		res = ar1.Calling_WriteAddr_Single(abs_address, value)
	else
		-- read, modify, write
		res, reg_val = ar1.Calling_ReadAddr_Single(abs_address)
		
		if (res == 0) then				
			-- new_val = (old_val & (~aligned_field_mask)) | (field_val << start_bit)
			reg_val = Or(And(reg_val, Not(aligned_field_mask)), lshift(value, start_bit))
			res = ar1.Calling_WriteAddr_Single(abs_address, reg_val)
		end
	end
	
	return res;
end

-----------------------------------------------------------------------------------------------------
--[[
Function Name 	: rbn(Read register By Name)
Description		: Read from a register/field given it's name (xml path)
Input 			: full_path - full register/field name
				  field_mask - in format "end_bit:start_bit" or number (optional)
Output  		: register/field value (nil on error)
Examples 		: res = ar1.rbn("/Registers/MSS_QSPI/SPI_DATA1")
				  res = ar1.rbn("/Registers/MSS_QSPI/SPI_DATA1", "31:0")
]]--
function ar1.rbn(full_path, field_mask)
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
Example 		: res = ar1.wbn("/Registers/MSS_QSPI/SPI_DATA1", 0xABCDEFAB)
				  res = ar1.wbn("/Registers/MSS_QSPI/SPI_DATA1", 0xABCDEFAB,"31:0")
]]--
--void
function ar1.wbn(full_path, value, field_mask)
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
