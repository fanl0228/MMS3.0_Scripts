-----------------------------------------------COMMON----------------------------------------------------
--int32
function SoC_setChannel(BAND, CHANNEL)
	local retVal
	retVal = tonumber(RSTD.RunFunction("/RS_API/Common/SetChannel(".. BAND ..",".. CHANNEL ..")"))	
	return retVal
end
-----------------------------------------------------------------------------------------------------
--string
function SoC_errNumToErrStr(ERR_NUM)
	return RSTD.RunFunction("/RS_API/Common/ErrorNumberToString(".. ERR_NUM  ..")")
end
-----------------------------------------------------------------------------------------------------
--int32
function SoC_setPwrMode(POWER_MODE)
	local retVal
	retVal = tonumber(RSTD.RunFunction("/RS_API/Common/SetPowerMode(".. POWER_MODE ..")"))
	return retVal
end
-----------------------------------------------------------------------------------------------------
--object
function SoC_GetTemperature() --obj[0] ErrInfo , obj[1] temerature)
	local temperature_table = {}
	for i=0,1 do temperature_table[i]= 0 end

	local retVal = tonumber(RSTD.RunFunction("/RS_API/Common/GetTemperature()"))
	if (retVal ==0) then
		temperature_table[1] = RSTD.ReceiveAndGet("/Global Settings/Settings/Current Temperature")
	end
	temperature_table[0]=retVal
	
	return temperature_table
end
-----------------------------------------------------------------------------------------------------
--object
function SoC_GetVbat() --obj[0] ErrInfo , obj[1] temerature)
	local vbat_table = {}
	for i=0,1 do vbat_table[i]= 0 end

	local retVal = tonumber(RSTD.RunFunction("/RS_API/Common/GetBatCharging()"))
	
	if (retVal == 0) then
		vbat_table[1] = RSTD.ReceiveAndGet("/Global Settings/Settings/Current Battery Charging")
	end
	
	vbat_table[0]=retVal
	
	return vbat_table
end

---------------------------------------------------------------------------------------------------
--int32
function SoC_TsCmd(CMD_NUM, OBJECT_PARAM)

	if (	 (OBJECT_PARAM ~= 0  ) 
		and  (OBJECT_PARAM ~= nil)	  ) then
		RSTD.MessageColor("SoC_TsCmd function does not supported in this format ", COLORS.red)
		return -1
	else
		local retVal = tonumber(RSTD.RunFunction("/RS_API/Common/TSTestCommand(".. CMD_NUM ..")"))
		return retVal
	end
end
-----------------------------------------------------------------------------------------------------
--object
function ChanNameToNumAndBand(CHAN_NAME) --(returns a table object[0] = frequency,  object[1] = iChanNum, object[2] = iBand)

	local index
	local count_entries = 0
	local found_index
	local retTable = {}
	
	for index = CHANNEL_FIRST_NAME, CHANNEL_LAST_NAME do
		if(CHANNEL_NAME[index] == CHAN_NAME) then
			found_index = index
			count_entries = count_entries + 1
		end
	end
	
	if (count_entries > 1) then
		RSTD.MessageColor("Found multiplle entries for channel" .. CHAN_NAME .. "", COLORS.yellow)		
	elseif(count_entries == 0) then 
		RSTD.MessageColor("Didn't find channel" .. CHAN_NAME .. "", COLORS.yellow)
		retTable[0] = -1
		retTable[1] = -1
		retTable[2] = -1
		return retTable
	end
	retTable[0] = CHANNEL_FREQ  [found_index]
	retTable[1] = CHANNEL_NUMBER[found_index]
	retTable[2] = CHANNEL_BAND  [found_index]	
	return retTable
end
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------