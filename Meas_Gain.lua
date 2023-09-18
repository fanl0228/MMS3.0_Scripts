function Meas_Gain(ADC_File_Path,RxChain,IF_Freq_MHz,Input_Pwr_dBm)
--	This code will create a global variable with the name Measured_Gain_dB which can be used by other scripts.
	-- Test Parameters
	RxChain = tonumber(RxChain)
	IF_Freq_MHz = tonumber(IF_Freq_MHz)
	Input_Pwr_dBm = tonumber(Input_Pwr_dBm)
	--Start of code.
	local Num_Samples_per_Channel = 8192 -- Enter any of: 4096,8192,16384,32768,65536,131072,262144,524288
	local Num_FFT_Points = 16*Num_Samples_per_Channel -- Affects number of zeros padded while taking FFT

	local Signal_Output_Power_dBm,Success,Signal_Output_Power_dBFs,Meas_Peak_IF_Freq_Hz,Meas_Peak_IF_Freq_MHz,Signal_Meas_RBW_Hz,FreqError_MHz

	--Set number of averages to 1 for Signal meas. Signal may drift between multiple captures and averaging will corrupt measurement
	Success = ar1.BasicConfigurationForAnalysis(Num_Samples_per_Channel, Num_FFT_Points, 1, 1, 1, 1, 2)
	if(Success ~= 0) then
		RSTD.Log("\n Basic Configuration Failure\n","red")	
		error("Basic Configuration Failure")
	end
	Success = ar1.CaptureContStreamADCData(ADC_File_Path, Num_Samples_per_Channel)
	if(Success ~= 0) then
		RSTD.Log("\n Capture Failure\n","red")	
		error("Capture Failure")
	end
	Success = ar1.ProcessContStreamADCData(ADC_File_Path)--TBD remove the extra parameter
	if(Success ~= 0) then
		RSTD.Log("\n Post Processing Failure\n","red")	
		error("Post Processing Failure")
	end
	Signal_Meas_RBW_Hz = 10e3 --10kHz
	Success, Signal_Output_Power_dBFs, Meas_Peak_IF_Freq_Hz =  ar1.MeasureFundPower(ADC_File_Path, Signal_Meas_RBW_Hz,  RxChain, 0)
	if(Success ~= 0) then
		RSTD.Log("\n Fund Power Calc Failure\n","red")	
		error("Fund Power Calc Failure")
	end
	RSTD.Log("\n Output Signal Power in dBFs ="..Signal_Output_Power_dBFs.."\n","blue")
	Meas_Peak_IF_Freq_MHz = Meas_Peak_IF_Freq_Hz/1e6
	FreqError_MHz =  math.abs(math.abs(Meas_Peak_IF_Freq_MHz) - math.abs(IF_Freq_MHz))
	print("\n Measured IF Frequency = "..tostring(math.floor(Meas_Peak_IF_Freq_MHz*10+0.5)/10).."MHz \n") -- Print with 0.1MHz rounding
	if (FreqError_MHz > 0.5) then
		RSTD.Log("\n Measured IF freq not matching expected. Check if signal generator frequency accounts for XTAL ppm\n","red")	
		error("Measured IF freq not matching expected. Check if signal generator frequency accounts for XTAL ppm")	
	end
	if (math.abs(Meas_Peak_IF_Freq_MHz) <= 0.7) then
		RSTD.Log("\n Measured IF freq too low. Check if signal generator frequency corresponds to IF frequency\n","red")	
		error("Measured IF freq too low. Check if signal generator frequency corresponds to IF frequency")	
	end
	-- dbFs to dBm conversion: 10dB, Same added for both signal and noise. So SNR remains the same. 
	Signal_Output_Power_dBm = Signal_Output_Power_dBFs + 10
	if ((Signal_Output_Power_dBm <= 7) and (Input_Pwr_dBm <= -10)) then
		Measured_Gain_dB = Signal_Output_Power_dBm - Input_Pwr_dBm
		RSTD.Log("\n Measured Gain in dB ="..Measured_Gain_dB.."\n","blue")	
		RSTD.Log("\n NOTE: Gain shown will be 3dB higher in complex mode compared to real mode\n" ,"blue")	
	else		
		RSTD.Log("\n Too high input and/ or output power. Device might have compressed\n","red")	
		error("Too high input and/ or output power. Device might have compressed")
		Measured_Gain_dB = -999
	end
--	This code will create a global variable with the name Measured_Gain_dB which can be used by other scripts.
end