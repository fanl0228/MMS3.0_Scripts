	--This script will throw error if the configuration is not successful
	
	----------------------------------------User Constants----------------------------------------------------
	-- Constants for Continuous stream
	local Test_freq						= 77							-- GHz
	local Sample_Rate					= 10000							-- ksps
	local Rx_Gain						= 30							-- dB
	local HPF1_Corner_Freq				= 0								-- 0:175k,1:235K,2:350K,3:700K
	local HPF2_Corner_Freq				= 0								-- 0:350K,1:700K,2:1.4M,3:2.8M
	local Tx_Backoff					= 0								-- dB
	
	
	-- Test constants
	local Tx_0_Rx_1						= 1 							-- 0: Tests for Tx, 1: Tests for Rx
	local Temp_chck_period				= 5000							-- ms; The time delay to check the temperature for the Tx test
	local Cont_Stream_ON_Time			= 30							--s; The time till which the continuous stream should run
	
	
	--HSDC Pro constants
	Samples_per_ch						= 8192							-- No. of samples per channel to capture in HSDC Pro
	---------------------------------------------------------------------------------------------------------------------

	--*************Start of Code, don't edit the below lines*******************************--
	----------------------------------------Derived Constants-------------------------------------------------------------
	local status						= 0
	local trigger_capture_start_time	= 0
	local Run_time_Cal_Disable					= {1,1,1,1}
	
	--Verify if the Cont_Stream_ON_Time greater than Temp_chck_period
	if(Temp_chck_period > (Cont_Stream_ON_Time*1000)) then 
		Cont_Stream_ON_Time				= Temp_chck_period*(1.5/1000) 
	end
	
	local n_iterations					= math.floor(((Cont_Stream_ON_Time*1000)/Temp_chck_period)+0.5)
	
	--Post Proc constants
	local Xaxis_Freq0_Range1		=	0								-- 0:Xaxis will be Freq 1: Xaxis will be Range 
	local slope						= 	0								-- CW mode
	post_proc_command_string		=	data_format.." "..tostring(Sample_Rate*1000).." 4 "..Samples_per_ch.." 1 1 1 "..RadarDevice[1].." "..RadarDevice[2].." "..RadarDevice[3].." "..RadarDevice[4].." "..Dump_FFT_Results_in_XLS.." "..slope.." "..Xaxis_Freq0_Range1
	
	---------------------------------------------------------------------------------------------------------------------
	
	--------------------------------------Initialization-------------------------------------------------------------
	-- Initialize HSDC Pro
	if ((re_initialize_HSDC_Pro	==	1) and (Tx_0_Rx_1 == 1)) then -- Check Global variable whether to initialize HSDC Pro or not	
		-- Initialize HSDC Pro: Download fw, select ADC, Set the Analysis window and the ADC Output data rate
		if (0 ~= Initialize_HSDCPro()) then
			return -1
		end
	end

	-- Disable the stream if already enabled
	Disable_Continuous_Stream(CW_Test_Dev)
	
	WriteToLog("Initialization successful\n", "blue")
	if (0 ~= Display_Temperature(delay_time[CW_Test_Dev],CW_Test_Dev)) then 
		return -1
	end
	---------------------------------------------------------------------------------------------------------------------
	
	--------------------------------------Configuration-------------------------------------------------------------
	-- Configuration of the stream parameters
	status 			= ar1.ContStrConfig_mult(1,Test_freq, Sample_Rate, Rx_Gain, HPF1_Corner_Freq, HPF2_Corner_Freq, Tx_Backoff,Tx_Backoff,Tx_Backoff, 0, 0, 0)
	RSTD.Sleep(delay_time[1])
    
	if (CW_Test_Dev~=1) then -- if NOT Master
		status		=	status + ar1.ContStrConfig_mult(dev_list[CW_Test_Dev],Test_freq, Sample_Rate, Rx_Gain, HPF1_Corner_Freq, HPF2_Corner_Freq, Tx_Backoff, Tx_Backoff, Tx_Backoff, 0, 0, 0)
		RSTD.Sleep(delay_time[CW_Test_Dev])
	end

	if (0 == status) then
		WriteToLog("Configuration Successful\n", "green")
	else
		WriteToLog("Configuration Failed \n", "red")
		return -1
	end		
	
	-- Enable Continuous stream for Master and 20G signal out
	status			= Stream_Control_CW_Chirp(1,1,1) -- Enable master Cont Stream 

	-- Enable Continuous stream for Slave and use 20G input signal
	if (CW_Test_Dev~=1) then -- if NOT Master
		status		= status + Stream_Control_CW_Chirp(CW_Test_Dev,1,1) 
	end	

	if (0 == status) then
		WriteToLog("Stream Enabled Successfully\n", "green")
	else
		WriteToLog("Stream Enabling Failed \n", "red")
		return -1
	end		
	---------------------------------------------------------------------------------------------------------------------
	
	--------------------------------------Testing-------------------------------------------------------------
	if (0 ~= Display_Temperature(delay_time[CW_Test_Dev],CW_Test_Dev)) then 
		Disable_Continuous_Stream(CW_Test_Dev)
		return -1
	end
		
	if(Tx_0_Rx_1 == 1) then		
		--Capture data from HSDC Pro
		status,trigger_capture_start_time	= capture_cw(CW_Test_Dev,Samples_per_ch)
		if (0 ~= status) then
			Disable_Continuous_Stream(CW_Test_Dev)
			return -1
		end
		
		--Save HSDC Pro data to file
		if (0 ~= save_data(adc_data_capture_file_path,trigger_capture_start_time)) then
			Disable_Continuous_Stream(CW_Test_Dev)
			return -1
		end
		
		--Display the temperature after the capture
		if (0 ~= Display_Temperature(delay_time[CW_Test_Dev],CW_Test_Dev)) then 
			Disable_Continuous_Stream(CW_Test_Dev)
			return -1
		end

		-- Disable the stream if already enabled
		Disable_Continuous_Stream(CW_Test_Dev)		
		
		WriteToLog("post processing started and the command string = "..post_proc_command_string.."\n", "blue")
		status = RSTD.Run(post_proc_exe_path, post_proc_command_string)
		WriteToLog("ans="..status.."\n", "blue")
	else
		for i= 1,n_iterations do
			if (0 ~= Display_Temperature(Temp_chck_period,CW_Test_Dev)) then 
				Disable_Continuous_Stream(CW_Test_Dev)
				return -1
			end
		end
		
		-- Disable the stream if already enabled
		Disable_Continuous_Stream(CW_Test_Dev)			
	end

	---------------------------------------------------------------------------------------------------------------------
	
	if((status==0)and (Tx_0_Rx_1 == 1)) then
		re_initialize_HSDC_Pro	=	0
	end
	
	return status