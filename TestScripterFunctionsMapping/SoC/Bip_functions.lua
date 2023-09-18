-----------------------------------------------BIP---------------------------------------------------
--int32 
function SoC_changeEfuse(PARAMS) --LuaTable luaParams
	local start_number = 0
	RSTD.SetVar ("/BIP/XTAL Bip/Efuse Parameters/2.4G-MaxGain"    	, PARAMS[start_number])
	RSTD.SetVar ("/BIP/XTAL Bip/Efuse Parameters/J-L,M-MaxGain" 	, PARAMS[start_number +1])
	RSTD.SetVar ("/BIP/XTAL Bip/Efuse Parameters/J-High-MaxGain" 	, PARAMS[start_number +2])
	RSTD.SetVar ("/BIP/XTAL Bip/Efuse Parameters/5G-1st-MaxGain" 	, PARAMS[start_number +3])
	RSTD.SetVar ("/BIP/XTAL Bip/Efuse Parameters/5G-2nd-MaxGain" 	, PARAMS[start_number +4])
	RSTD.SetVar ("/BIP/XTAL Bip/Efuse Parameters/5G-3rd-MaxGain" 	, PARAMS[start_number +5])
	RSTD.SetVar ("/BIP/XTAL Bip/Efuse Parameters/5G-4th-MaxGain" 	, PARAMS[start_number +6])
	RSTD.SetVar ("/BIP/XTAL Bip/Efuse Parameters/2.4G-LnaStep-4To3" , PARAMS[start_number +7])
	RSTD.SetVar ("/BIP/XTAL Bip/Efuse Parameters/2.4G-LnaStep-3To2" , PARAMS[start_number +8])
	RSTD.SetVar ("/BIP/XTAL Bip/Efuse Parameters/2.4G-LnaStep-2To1" , PARAMS[start_number +9])
	RSTD.SetVar ("/BIP/XTAL Bip/Efuse Parameters/2.4G-LnaStep-1To0" , PARAMS[start_number +10])
	RSTD.SetVar ("/BIP/XTAL Bip/Efuse Parameters/5G-LnaStep-4To3" 	, PARAMS[start_number +11])
	RSTD.SetVar ("/BIP/XTAL Bip/Efuse Parameters/5G-naStep-3To2" 	, PARAMS[start_number +12])
	RSTD.SetVar ("/BIP/XTAL Bip/Efuse Parameters/5G-LnaStep-2To1" 	, PARAMS[start_number +13])
	RSTD.SetVar ("/BIP/XTAL Bip/Efuse Parameters/5G-LnaStep-1To0" 	, PARAMS[start_number +14])
	RSTD.SetVar ("/BIP/XTAL Bip/Efuse Parameters/2.4G-TaStep-2To1" 	, PARAMS[start_number +15])
	RSTD.SetVar ("/BIP/XTAL Bip/Efuse Parameters/2.4G-TaStep-1To0" 	, PARAMS[start_number +16])
	RSTD.SetVar ("/BIP/XTAL Bip/Efuse Parameters/5G-TaStep-2To1" 	, PARAMS[start_number +17])
	RSTD.SetVar ("/BIP/XTAL Bip/Efuse Parameters/5G-TaStep-1To0" 	, PARAMS[start_number +18])
	RSTD.Transmit("/BIP/XTAL Bip/Efuse Parameters")
	local retVal = tonumber(RSTD.RunFunction("/RS_API/BIP/ChangeEfuse(".. PARAMS[start_number]     ..","
																	   .. PARAMS[start_number +1]  ..","
																	   .. PARAMS[start_number +2]  ..","
																	   .. PARAMS[start_number +3]  ..","
																	   .. PARAMS[start_number +4]  ..","
																	   .. PARAMS[start_number +5]  ..","
																	   .. PARAMS[start_number +6]  ..","
																	   .. PARAMS[start_number +7]  ..","
																	   .. PARAMS[start_number +8]  ..","
																	   .. PARAMS[start_number +9]  ..","
																	   .. PARAMS[start_number +10] ..","
																	   .. PARAMS[start_number +11] ..","
																	   .. PARAMS[start_number +12] ..","
																	   .. PARAMS[start_number +13] ..","
																	   .. PARAMS[start_number +14] ..","
																	   .. PARAMS[start_number +15] ..","
																	   .. PARAMS[start_number +16] ..","
																	   .. PARAMS[start_number +17] ..","
																	   .. PARAMS[start_number +18] .. ")"))
	return retVal                                                        
end
-----------------------------------------------------------------------------------------------------
--int32 
function SoC_runTxBip(REF_PWR, REF_DETVOLT, SBAND)
	local retVal 
	retVal = tonumber(RSTD.RunFunction("/RS_API/BIP/RunTXBip(".. REF_PWR ..","..REF_DETVOLT..","..SBAND..")"))
	return retVal
end
-----------------------------------------------------------------------------------------------------
--object
function SoC_runRxBip(PWR_LVL)
	local lna_compensations = {}
	local start_index = 0
	for i=start_index,start_index+7 do lna_compensations[i] = 0 end

	local retVal = tonumber(RSTD.RunFunction("/RS_API/BIP/RunRXBip(".. PWR_LVL ..")"))
	if (retVal == 0) then 
		RSTD.Receive("/BIP/RX Bip/Gains")
		for j=start_index+1,start_index+7 do
			lna_compensations[j] = RSTD.GetVar("/BIP/RX Bip/Gains/GainIndex#" .. j)
		end
	end
	lna_compensations[start_index] =  retVal
	return lna_compensations
end
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------