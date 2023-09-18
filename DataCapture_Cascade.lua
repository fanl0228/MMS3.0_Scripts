	--This function will throw error if the configurations are not called
	local status						=	0
	local trigger_capture_start_time	=	0
	
	if (re_initialize_HSDC_Pro	==	1) then -- Check Global variable whether to initialize HSDC Pro or not
		-- Initialize HSDC Pro: Download fw, select ADC, Set the Analysis window and the ADC Output data rate
		if (0 ~= Initialize_HSDCPro()) then
			return -1
		end
	end	

	--Resetting the board to clear any stale data
	if (0 ~= reset_board(RadarDevice[1],RadarDevice[2],RadarDevice[3],RadarDevice[4],Samples_per_ch)) then
		return -1
	end
	
	--Triggering the data capture
	if (RadarDevice[4]==1)then
		Stream_Control_CW_Chirp(4,0,0)
		Stream_Control_CW_Chirp(4,0,1)
	end
	
	if (RadarDevice[3]==1)then
		Stream_Control_CW_Chirp(3,0,0)
		Stream_Control_CW_Chirp(3,0,1)
	end
	
	if (RadarDevice[2]==1)then
		Stream_Control_CW_Chirp(2,0,0)
		Stream_Control_CW_Chirp(2,0,1)
	end
	
	Stream_Control_CW_Chirp(1,0,0)
	Stream_Control_CW_Chirp(1,0,1)
	
	WriteToLog("Capturing the AWR device data to the on-board memory...\n", "blue")
	RSTD.Sleep(capture_time)
	
	--Capture data in HSDC Pro
	status,trigger_capture_start_time	= trigger_capture()
	if (0 ~= status) then
		return -1
	end
	
	--Save HSDC Pro data to file
	if (0 ~= save_data(adc_data_capture_file_path,trigger_capture_start_time)) then
		return -1
	end
	
	WriteToLog("post processing started and the command string = "..post_proc_command_string.."\n", "blue")
	status = RSTD.Run(post_proc_exe_path, post_proc_command_string)
	WriteToLog("ans="..status.."\n", "blue")
	
	if(status==0) then
		re_initialize_HSDC_Pro	=	0
	end
	
	return status