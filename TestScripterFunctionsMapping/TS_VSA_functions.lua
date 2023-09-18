-------------------------------------------//////////////////////////////////////----------------------------
function vsa_init ()
	vsa.init();
end
function vsa_reset ()
	vsa.reset();
end
function vsa_close ()
	vsa.close();
end
function vsa_recallState (FILE_NAME)
	vsa.recallState(FILE_NAME);
end
function vsa_saveState (FILE_NAME)
	vsa.saveState(FILE_NAME);
end
-------------------------------------------//////////////////////////////////////----------------------------
-- VSA CONFIGURATION
-------------------------------------------//////////////////////////////////////----------------------------
function vsa_cfgToStd (STD)
	vsa.cfgToStd(STD);
end
function vsa_cfgTrig (FREE_RUN, LEVEL, DELAY, HOLD_OFF)
	vsa.cfgTrig(FREE_RUN, LEVEL, DELAY, HOLD_OFF);
end
function vsa_msrStart ()
	vsa.msrStart();
end
function vsa_msrContious (ENABLE)
	vsa.msrContious(ENABLE);
end
function vsa_setFreq (BBAND, FREQ, SPAN)
	vsa.setFreq(BBAND, FREQ, SPAN);
end
function vsa_setRange (RANGE_DBM)
	vsa.setRange(RANGE_DBM);
end
function vsa_setAmplOffs (AMPL_OFFS_DB)
	vsa.setAmplOffs(AMPL_OFFS_DB);
end
function vsa_setAverage (AVG_NUM)
	vsa.setAverage(AVG_NUM);
end
function vsa_setMsrTime (TIME)
	vsa.setMsrTime(TIME);
end
function vsa_setBandPwrMrker (START, STOP)
	vsa.setBandPwrMrker(START, STOP);
end
-------------------------------------------//////////////////////////////////////----------------------------
-- VSA TRACE
-------------------------------------------//////////////////////////////////////----------------------------
function vsa_setAutoScaleToAll ()
	vsa.setAutoScaleToAll();
end
function vsa_setTraceYScale (TRACE_IDX, REF_LEVEL, PER_DIV)
	vsa.setTraceYScale(TRACE_IDX, REF_LEVEL, PER_DIV);
end
function vsa_setTraceXScale (TRACE_IDX, LEFT, RIGHT)
	vsa.setTraceXScale(TRACE_IDX, LEFT, RIGHT);
end
--object
function vsa_getAllAvilabelTraceDataNames (TRACE_IDX)
	return vsa.getAllAvilabelTraceDataNames(TRACE_IDX);
end
function vsa_setTraceDataName (TRACE_IDX, TRACE_NAME)
	vsa.setTraceDataName(TRACE_IDX, TRACE_NAME);
end
-------------------------------------------//////////////////////////////////////----------------------------
-- VSA Measurement
-------------------------------------------//////////////////////////////////////----------------------------
--double
function vsa_getBandPwrMsr ()
	return vsa.getBandPwrMsr();
end
--object
function vsa_getTraceD_Res ()
	return vsa.getTraceD_Res();
end
function vsa_waitForMeasDone (TIME_OUT)
	vsa.waitForMeasDone(TIME_OUT);
end
--bool
function vsa_isOverLoaded ()
	return vsa.isOverLoaded();
end
