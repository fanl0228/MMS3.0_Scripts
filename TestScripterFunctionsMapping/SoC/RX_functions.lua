-----------------------------------------------RX----------------------------------------------------
--int32
function SoC_rxStatStart()
	local retVal
	retVal = tonumber (RSTD.RunFunction("/RS_API/RX/RXStatisticStart()"))
	return retVal
end
-----------------------------------------------------------------------------------------------------
--int32
function SoC_rxStatStop()
	local retVal
	retVal = tonumber (RSTD.RunFunction("/RS_API/RX/RXStatisticStop()"))
	return retVal
end
-----------------------------------------------------------------------------------------------------
--int32 
function SoC_rxStatReset()
	local retVal
	retVal = tonumber (RSTD.RunFunction("/RS_API/RX/RXStatisticReset()"))
	return retVal
end
-----------------------------------------------------------------------------------------------------
--object
function SoC_rxStatGet()
	local RX_Statistics = {}
	local start_index = 0
	--Init
	for i=start_index,start_index + 9 do RX_Statistics[i] = 0 end
	local retVal = tonumber (RSTD.RunFunction("/RS_API/RX/GetRXStatistic()"))	
	RX_Statistics[start_index] = retVal
	if (retVal == 0)then
		RSTD.Receive("/RX/Statistics")
		RX_Statistics[start_index+1]  = RSTD.GetVar("/RX/Statistics/Good")				--receivedValidPacketsNumber
		RX_Statistics[start_index+2]  = RSTD.GetVar("/RX/Statistics/FCS Error")   		--receivedFcsErrorPacketsNumber
		RX_Statistics[start_index+3]  = RSTD.GetVar("/RX/Statistics/Address Mismatch")	--receivedPlcpErrorPacketsNumber
		RX_Statistics[start_index+4]  = RSTD.GetVar("/RX/Statistics/SeqNumMissCount") 	--seqNumMissCount
		RX_Statistics[start_index+5]  = RSTD.GetVar("/RX/Statistics/SQM")					--averageSnr
		RX_Statistics[start_index+6]  = RSTD.GetVar("/RX/Statistics/RSSI")				--averageRssi
		RX_Statistics[start_index+7]  = RSTD.GetVar("/RX/Statistics/EVM")					--averageEvm
		RX_Statistics[start_index+8]  = RSTD.GetVar("/RX/Statistics/BasePacketId")    	--BasePacketId 
		RX_Statistics[start_index+9]  = RSTD.GetVar("/RX/Statistics/NumOfPackets")    	--NumberOfPackets
		RX_Statistics[start_index+10] = RSTD.GetVar("/RX/Statistics/NumOfMissedPackets")	--NumberOfMissedPackets
	end
	return RX_Statistics
end
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------