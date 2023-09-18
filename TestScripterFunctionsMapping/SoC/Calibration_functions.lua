-----------------------------------------------Calibration----------------------------------------------------
--int32 
function SoC_runCalib(CAL_NUM)
	local retVal 
	retVal = tonumber(RSTD.RunFunction("/RS_API/Calibrations/RunCalibration(".. CAL_NUM ..")"))
	return retVal
end
-----------------------------------------------------------------------------------------------------
--object 
function SoC_GetCalibsStatus()
	local Calibrations = {}
	local calibration_index = 25 -- from TestScripter - TrioscopeDll.cs
	local start_index = 0
	--Init
	for i=start_index,calibration_index  do Calibrations[i] = 0 end
	RSTD.RunFunction("/RS_API/Calibrations/GetCalibrationStatus()")
	RSTD.Receive("/Calibrations/Calibration Output Codes")
	Calibrations[start_index   ] = RSTD.GetVar("/Calibrations/Calibration Output Codes/DRPw_TX_LPF"			)
	Calibrations[start_index+1 ] = RSTD.GetVar("/Calibrations/Calibration Output Codes/DRPw_Tune"			)--
	Calibrations[start_index+2 ] = RSTD.GetVar("/Calibrations/Calibration Output Codes/DRPw_RTRIM"			)
	Calibrations[start_index+3 ] = RSTD.GetVar("/Calibrations/Calibration Output Codes/CM_TX_LO_LEAKAGE"	)
	Calibrations[start_index+4 ] = RSTD.GetVar("/Calibrations/Calibration Output Codes/DRPw_RX_LPF"			)
	Calibrations[start_index+5 ] = RSTD.GetVar("/Calibrations/Calibration Output Codes/TX_IQ_MM"			)
	Calibrations[start_index+6 ] = RSTD.GetVar("/Calibrations/Calibration Output Codes/DRPw_TA_COMMON"		)
	Calibrations[start_index+7 ] = RSTD.GetVar("/Calibrations/Calibration Output Codes/DRPw_RX_MAX_LNA_GAIN_CORR")
	Calibrations[start_index+8 ] = RSTD.GetVar("/Calibrations/Calibration Output Codes/DRPw_RF_2_GAIN"		)
	Calibrations[start_index+9 ] = RSTD.GetVar("/Calibrations/Calibration Output Codes/DRPw_RX_DACs"		)
	Calibrations[start_index+10] = RSTD.GetVar("/Calibrations/Calibration Output Codes/DRPw_LNA_TANK"		)
	Calibrations[start_index+11] = RSTD.GetVar("/Calibrations/Calibration Output Codes/ANALOG_RX_CORRECTION")
	Calibrations[start_index+12] = RSTD.GetVar("/Calibrations/Calibration Output Codes/RX_IQMM_CORRECTION"	)
	Calibrations[start_index+13] = RSTD.GetVar("/Calibrations/Calibration Output Codes/SMART_REFLEX"		)
	
	return Calibrations
end
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------