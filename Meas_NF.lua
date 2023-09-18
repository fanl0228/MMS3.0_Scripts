function Meas_NF(ADC_File_Path,RxChain,IF_Freq_MHz)
--	This code will create a global variable with the name NF_dB which can be used by other scripts.

	-- Test Parameters
	RxChain = tonumber(RxChain)
	IF_Freq_MHz = tonumber(IF_Freq_MHz)

	--Start of code.
	local Num_Noise_Averages = 5
	local Noise_IntegBW_Hz = 200e3
	local Num_Samples_per_Channel = 8192 -- Enter any of: 4096,8192,16384,32768,65536,131072,262144,524288
	local Num_FFT_Points = 16*Num_Samples_per_Channel -- Affects number of zeros padded while taking FFT

	local Noise_Output_Power_dBmperHz,Success,Noise_Pwr_Avg,Noise_dBFsperHz

	Success = ar1.BasicConfigurationForAnalysis(Num_Samples_per_Channel, Num_FFT_Points, 1, 1, 1, 1, 2)
	if(Success ~= 0) then
		RSTD.Log("\n Basic Configuration Failure\n","red")	
		error("Basic Configuration Failure")
	end
	Noise_Pwr_Avg = 0
	for i = 1,Num_Noise_Averages do
		
		Success = ar1.CaptureContStreamADCData(ADC_File_Path, Num_Samples_per_Channel)
		if(Success ~= 0) then
			RSTD.Log("\n Capture Failure\n","red")	
			error("Capture Failure")
		end
		Success = ar1.ProcessContStreamADCData(ADC_File_Path)
		if(Success ~= 0) then
			RSTD.Log("\n Post Processing Failure\n","red")	
			error("Post Processing Failure")
		end
		Success, Noise_dBFsperHz =  ar1.MeasurePowerSpectralDensity(ADC_File_Path,IF_Freq_MHz*1e6-Noise_IntegBW_Hz/2,Noise_IntegBW_Hz,RxChain, 0)
		if(Success ~= 0) then
			RSTD.Log("\n Noise Power Calc Failure\n","red")	
			error("Noise Power Calc Failure")
		end
		RSTD.Log("\n Noise Measurement Ongoing. Averaging "..i.."/"..Num_Noise_Averages.."\n","blue")	
		Noise_Pwr_Avg = Noise_Pwr_Avg + 10^(Noise_dBFsperHz/10)
	end
	Noise_Pwr_Avg = Noise_Pwr_Avg/Num_Noise_Averages
	-- dbFs to dBm conversion: 10dB, Same added for both signal and noise. So SNR remains the same. 
	Noise_Output_Power_dBmperHz = 10*math.log10(Noise_Pwr_Avg) + 10
	RSTD.Log("\n Output Noise Power in dBm/Hz ="..Noise_Output_Power_dBmperHz.."\n","black")
	
	if (Measured_Gain_dB ~= nil) then
		NF_dB = Noise_Output_Power_dBmperHz - Measured_Gain_dB + 174
		RSTD.Log("\n Noise Figure in dB ="..NF_dB.."\n","blue")
	else
		RSTD.Log("\n Measure gain before NF \n","red")	
	end
	--	This code will create a global variable with the name NF_dB which can be used by other scripts.

end