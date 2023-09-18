-----------------------------------------------TX----------------------------------------------------
--for debug only !
--[[
TX_PARAMS =  {
            iDelay      = 500,
            iRate       = 0x1000,
            iSize       = 1000,
            iAmount     = 0,
            iPower      = 10000,
            iSeed       = 10000,
            iPacketMode = 0x3,
            iDcfOnOff   = 1,
            iGI         = 0,
            iPreamble   = 0x4,
            iType       = 0x0,
            iScrambler  = 1,
            iEnableCLPC = 1,
            iSeqNumMode = 1,
            iSrcMacAddr = 0xdeadbeef,
            iDstMacAddr = 0xdeadbeef
            }
]]--
-----------------------------------------------------------------------------------------------------
--int32 
function SoC_startTx(TX_PARAMS) --txParams params) --(see TS_Enums.lua)  
	local TX_PCKT = "" .. TX_PARAMS.iDelay      .. "," .. TX_PARAMS.iRate     .. "," .. TX_PARAMS.iSize .. "," .. 
						  TX_PARAMS.iAmount     .. "," .. TX_PARAMS.iPower    .. "," .. TX_PARAMS.iSeed .. "," .. 
						  TX_PARAMS.iPacketMode .. "," .. TX_PARAMS.iDcfOnOff .. "," .. TX_PARAMS.iGI   .. "," .. 
						  TX_PARAMS.iPreamble   .. "," .. TX_PARAMS.iType     .. "," .. TX_PARAMS.iScrambler  .. ","..
						  TX_PARAMS.iEnableCLPC .. "," .. TX_PARAMS.iSeqNumMode  .. "," .. 
					      TX_PARAMS.iSrcMacAddr .. "," .. TX_PARAMS.iDstMacAddr  .. ""
					
	local retVal = tonumber(RSTD.RunFunction("/RS_API/TX/StartTXPckt(".. TX_PCKT ..")"))
	return retVal                                                             
end
-----------------------------------------------------------------------------------------------------
--int32 
function SoC_stopTx()
	local retVal = tonumber(RSTD.RunFunction("/RS_API/TX/StopTX()"))
end
-----------------------------------------------------------------------------------------------------
--int32 
function SoC_txGainAdjust(DESIRED_PWR, USE_INI_LIMIT_POWER)
	local retVal = tonumber(RSTD.RunFunction("/RS_API/TX/TXGainAdjust("..DESIRED_PWR..","..USE_INI_LIMIT_POWER..")"))
	return retVal
end
-----------------------------------------------------------------------------------------------------
--int32 
function SoC_ResetCLPC()
	local retVal = tonumber(RSTD.RunFunction("/RS_API/TX/ResetCLPC()"))
	return retVal
end
-----------------------------------------------------------------------------------------------------
--int32 
function SoC_DisableCLPC()
	local retVal = tonumber(RSTD.RunFunction("/RS_API/TX/DisableCLPC()"))
	return retVal
end
-----------------------------------------------------------------------------------------------------
--int32 
function SoC_EnableCLPC()
	local retVal = tonumber(RSTD.RunFunction("/RS_API/TX/EnableCLPC()"))
	return retVal
end
-----------------------------------------------------------------------------------------------------
--int32 
function SoC_SetCLPCActivationTime(ACTIVATION_TIME)
	local retVal = tonumber(RSTD.RunFunction("/RS_API/TX/SetCLPCActivationTime(" .. ACTIVATION_TIME .. ")"))
	return retVal
end
-----------------------------------------------------------------------------------------------------
--object 
function SoC_GetCLPCOutPut()
	local clpc_out = {}
	local start_index = 1
	local retVal = tonumber(RSTD.RunFunction("/RS_API/TX/GetCLPCOutPut()"))
	
	for i=start_index,start_index + 6 do 
		clpc_out[i] = 0 
	end	
	
	clpc_out[start_index] = retVal
	
	if(retVal == 0) then
		RSTD.Receive("/TX/Clpc/Offset")
		clpc_out[start_index + 1] = RSTD.GetVar("/TX/Clpc/Offset/MCS 7")
		clpc_out[start_index + 2] = RSTD.GetVar("/TX/Clpc/Offset/54_48")
		clpc_out[start_index + 3] = RSTD.GetVar("/TX/Clpc/Offset/36_24")
		clpc_out[start_index + 4] = RSTD.GetVar("/TX/Clpc/Offset/18_12")
		clpc_out[start_index + 5] = RSTD.GetVar("/TX/Clpc/Offset/9_6")
		clpc_out[start_index + 6] = RSTD.GetVar("/TX/Clpc/Offset/11n")		
	end
	return clpc_out
end
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
