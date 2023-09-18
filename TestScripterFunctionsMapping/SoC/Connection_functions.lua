-----------------------------------------------CONNECTION----------------------------------------------------
--bool
function SoC_isConnected()
	local return_string
	return_string = RSTD.RunFunction("/RS_API/Connection/isConnected()")
	if("TRUE" == return_string) then return true
	elseif ("FALSE" == return_string) then return false
	end
end
------------------------------------------------------------------------------------------------------------------
--int32
function SoC_Connect(PORT , BAUD_RATE)
	local retVal
	retVal = tonumber (RSTD.RunFunction("/RS_API/Connection/Connect(".. PORT ..",".. BAUD_RATE .. ")"))
	return retVal
end
------------------------------------------------------------------------------------------------------------------
--bool
function SoC_isFwRunning()
	local return_string
	return_string = RSTD.RunFunction("/RS_API/Connection/isFwRunning()")
	if("TRUE" == return_string) then return true
	elseif ("FALSE" == return_string) then return false
	end
end
------------------------------------------------------------------------------------------------------------------
--int32
function SoC_downFW(FILE_NAME)
	local retVal
	retVal = tonumber (RSTD.RunFunction("/RS_API/Connection/Download FirmWare("..FILE_NAME ..")"))
	return retVal
end
------------------------------------------------------------------------------------------------------------------
--int32
function SoC_disConnect()
	local retVal
	retVal = tonumber (RSTD.RunFunction("/RS_API/Connection/Disconnect()"))
	return retVal
end
------------------------------------------------------------------------------------------------------------------
--int32
function SoC_readIniFile(FILE_NAME)
	local retVal
	retVal = tonumber (RSTD.RunFunction("/RS_API/Connection/Read INI File(".. FILE_NAME ..")"))
	return retVal
end
------------------------------------------------------------------------------------------------------------------
--int32
function SoC_sendIniFile()
	local retVal
	retVal = tonumber (RSTD.RunFunction("/RS_API/Connection/Send INI File()"))
	return retVal
end
------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------