	----------------------------------------User Constants----------------------------------------------------

	--RadarDevice constants
	Chirp0_CW1						=	0								-- 1: CW Mode, 0: Chirp Mode; 
	local ADC_Mode					=	0								-- 0:Regular ADC, 1:Low Power ADC

	-- Post Proc Config
	Dump_FFT_Results_in_XLS			=	0								-- 0: Dont export XLS 1: Export XLS
	local Xaxis_Freq0_Range1		=	1								-- 0:Xaxis will be Freq 1: Xaxis will be Range 
	
	--Update below if CW mode
	CW_Test_Dev						=	2								-- Applicable in CW mode 1:Dev1,2:Dev2,3:Dev3,4:Dev4
	
	--Update below if Chirp mode
	RadarDevice						=	{1,1,1,1}						-- Applicable in Chirp mode {dev1,	dev2, dev3, dev4}, 1:Enable, 0:Disable

	---Sensor Configuration
	--Profile config
	local start_freq				=	77								-- GHz
	local slope						=	30								-- MHz/us
	local idle_time					=	100								-- us
	local adc_start_time			=	6								-- us
	local adc_samples				=	1024							-- Number of samples per chirp
	local sample_freq				=	10000							-- ksps
	local ramp_end_time				=	109								-- us
	local rx_gain					=	30								-- dB

	--Chirp config					=	{dev1,	dev2, dev3, dev4}		-- 1:Enable, 0:Disable
	local Tx1_Enable				=	{1,		0	, 0	  , 1	}
	local Tx2_Enable				=	{0,		0	, 0	  , 0	}
	local Tx3_Enable				=	{0,		0	, 0	  , 0	}	
	                                                                
	-- Frame config	
	local nchirp_loops				=	128								-- Number of chirps per frame
	local nframes					=	2								-- Number of Frames
	local Inter_Frame_Interval		=	60								-- ms 
	---------------------------------------------------------------------------------------------------------------------

	--*************Start of Code, don't edit the below lines*******************************--
	----------------------------------------Derived Constants-------------------------------------------------------------
	-- General
	if(RadarDevice[1] == 0) then
		WriteToLog("Master is not enabled \n", "red")	
		return -1
	end

	if(Chirp0_CW1 == 1) then
		RadarDevice						=	{1,0,0,0}
		RadarDevice[CW_Test_Dev]		= 	1
	end
	
	--Assign global variable to initialize the HSDC Pro for the first data capture
	re_initialize_HSDC_Pro			=	1
	
	--path constants
	RSTD_env_path					=	RSTD.GetSettingsPath()
	RSTD_installed_folder			=	RSTD.GetRstdPath()
	
	HSDC_Pro_installed_folder		=	"C:\\Program Files (x86)\\Texas Instruments\\High Speed Data Converter Pro"			--Represent with double slash
	adc_data_capture_file_path		=	RSTD_env_path.."\\adc_data.bin"
	post_proc_exe_path				=	RSTD_installed_folder.."\\Scripts\\Plot_RangeFFT.exe"

	--Misc constants
	dev_list						=	{1,2,4,8}

	--Connection
	sop_mode						=	tonumber(RTTT.InputMessageBox("SOP Mode: Enter 2 if Not-Flashed  or 4 if Flashed"))
	Master_COM						=	tonumber(RTTT.InputMessageBox("Enter COM# for Master FTDI"))

	if (sop_mode == 2) then
		Slave_COM					=	tonumber(RTTT.InputMessageBox("Enter COM# for Slave FTDI"))
		BSS_firmware				=	RSTD.BrowseForFile(RSTD.GetSettingsPath(), "bin", "Browse to ar12xx_bss.bin file")
		MSS_firmware				=	RSTD.BrowseForFile(RSTD.GetSettingsPath(), "bin", "Browse to ar1xxx_mss.bin file")
	elseif (sop_mode ~= 4) then
		WriteToLog("Only 2 & 4 SOP modes are supported\n", "red")
		return -1
	end
	com_list						=	{Master_COM,Slave_COM,Slave_COM,Slave_COM}

	---Static Configuration

	local Tx1, Tx2, Tx3
	if (Chirp0_CW1 ==1) then -- if CW mode
		Tx1 = Tx1_Enable
		Tx2 = Tx2_Enable
		Tx3 = Tx3_Enable
	else --if Chirp mode
		-- Enabling all the transmitters so that chirp configuration can enable what ever is required
		--Tx/Rx1				=	{dev1,	 dev2,	 dev3,	 dev4}
		Tx1						=	{1   ,		1,		1,		1}
		Tx2						=	{1   ,		1,		1,		1}
		Tx3						=	{1   ,		1,		1,		1}	
	end
	--*[[Note= The FPGA FW of the current TSW14J56 RevD board and the post processing works/ tested only for the below combination
	---Static Configuration
	local Rx1						=	1
	local Rx2						=	1
	local Rx3						=	1
	local Rx4						=	1
			
	local nbits						=	2						--0:12bits, 1:14bits, 2:16bits
	data_format						=	2						--0:Real, 1:complex1x, 2:complex2x, 3:Pseudo real
	local IQ_swap					=	0						--0:I first, 1:Qfirst
	cascade_mode_list				=	{1,2,2,2}					--0:single, 1: master, 2: slave
	local LDO_en					=	1						-- Should be 1 for the existing setup
	
	--- Data Configuration
	local lvds_data_rate			=	0						--0:900Mbps
	local lane1						=	1
	local lane2						=	1
	local lane3						=	0
	local lane4						=	0
	local MSB_on					=	0
	
	--End of Note]]*--

	--- Sensor configuration
	local trig_list					=	{1,2,2,2}	--1: Software trigger, 2: Hardware trigger

	-- Frame config	
	local start_chirp_tx			=	0
	local end_chirp_tx				=	0

	--- Misc constants
	delay_time						=	{500, 500, 500, 500}
	hsdc_pro_wait					=	500
	capture_time					=	nframes * Inter_Frame_Interval
	
	-- Function for the Soaking time
	function Display_Temperature(wait_time,CW_Test_Dev)

		local ErrStatus,Time_ms,Rx1_Temp,Rx2_Temp,Rx3_Temp,Rx4_Temp,Tx1_Temp,Tx2_Temp,Tx3_Temp,PM_Temp,Dig_Temp
		
		-- Waiting for the soak time
		RSTD.Sleep(wait_time)
		
		-- Getting the temperature Values
		ErrStatus,Time_ms,Rx1_Temp,Rx2_Temp,Rx3_Temp,Rx4_Temp,Tx1_Temp,Tx2_Temp,Tx3_Temp,PM_Temp,Dig_Temp = ar1.RFTemperatureGet_mult(dev_list[CW_Test_Dev])

		if(0 == ErrStatus) then
			-- Display of the values
			RSTD.Log("\n Rx1 Temp degC= "..Rx1_Temp..", Rx2 Temp degC="..Rx2_Temp..", Rx3 Temp degC="..Rx3_Temp..", Rx4 Temp degC="..Rx4_Temp..", Tx1 Temp degC="..Tx1_Temp..", Tx2 Temp degC="..Tx2_Temp..", Tx3 Temp degC="..Tx3_Temp..", PM Temp degC="..PM_Temp..", Dig Temp degC="..Dig_Temp.."\n","blue")
		else
			WriteToLog("Reading Temperature Values failed\n","red")
		end
		
		return ErrStatus
	end

	--Function to control the chirp or continuous stream
	function Stream_Control_CW_Chirp(Device_ID,Chirp0_CW1,En1_Dis0)
		local status = 0 
		
		if (Chirp0_CW1 == 1) then
			status = ar1.CustomCommand_mult(dev_list[Device_ID], 0x1, 0x0, 0x8, 0x1, 0x104, 0x4,"0"..En1_Dis0.."000000") --Enable/disable Continuous Stream 	
			status = status + ar1.CustomCommand_mult(dev_list[Device_ID], 0x5, 0x0, 0x202, 0x1, 0x4046, 0x4,"0"..En1_Dis0.."000000") --Enable the continuous mode data transfer
		else
			--status = ar1.CustomCommand_mult(dev_list[Device_ID], 0x1, 0x0, 0xa, 0x1, 0x140, 0x4,"0"..En1_Dis0.."000000") --Start / Stop Trigger Frame
            --status = ar1.StartFrame_mult(dev_list[Device_ID]) --Start Trigger Frame
            --Start frame(1)
            if (En1_Dis0 == 1) then 
				status = ar1.StartFrame_mult(dev_list[Device_ID]) --Start Trigger Frame
            --Stop frame(0)
            else
				--status = ar1.StopFrame_mult(dev_list[Device_ID]) --Stop Trigger Frame
            end
            
            
		end
	
		return status
	end
	
	--Function for disabling the continuous stream of master and selected device
	function Disable_Continuous_Stream(CW_Test_Dev)
		if (CW_Test_Dev ~= 1) then -- if NOT Master
			Stream_Control_CW_Chirp(CW_Test_Dev,1,0)
			RSTD.Sleep(delay_time[CW_Test_Dev])
		end
		Stream_Control_CW_Chirp(1,1,0) -- Disabling master.
		RSTD.Sleep(delay_time[1])
	end
	
	---HSDC Pro configuration
	Samples_per_ch					=	(adc_samples * (end_chirp_tx - start_chirp_tx + 1) * nchirp_loops * nframes)

	--Function definitions for AR1xxx HSDC Pro control
	function AR1xx_HSDCPro_control(command,error_status_file_path)
	
		--[[************
		Note: Make sure that file paths doesn't have spaces		
		****************]]--
		local status							=	0
		local AR1xx_HSDCPro_control_exe_path	=	HSDC_Pro_installed_folder.."\\14J56revD Details\\AR1xxx HSDC Pro Control\\AR1xxx_HSDC_Pro_Control.exe"

		--Calling the EXE to execute the command
		--WriteToLog("command is: "..command.."\n",'blue')
		--WriteToLog("error Status file path is: "..error_status_file_path.."\n",'blue')
		RSTD.Run(AR1xx_HSDCPro_control_exe_path, command)
		
		--Reading the Result
		local file 								=	io.open(error_status_file_path, "r")
		local result							=	file:read()
		
		if(result == "Error") then
			WriteToLog(result.."\n",'red')
			WriteToLog(file:read("*a"),'red')
			status 								=	-1
		end
		file:close()
		
		return status	
	end
	
	function Initialize_HSDCPro()
		local J56_Firmware_Name				=	"AR12XX_2LANE_4CHIP_FIRMWARE.rbf"
		local ADC_File_Name					=	"AR12xx_4chip_LSB_LVDS_2lanes_16bit"
		local error_status_file_path		=	RSTD.GetSettingsPath().."\\HSDC_Pro_control_error.txt"
		local command						=	"initialize".." "..error_status_file_path.." "..J56_Firmware_Name.." "..ADC_File_Name.." 11.25M"
		
		if (0 == AR1xx_HSDCPro_control(command,error_status_file_path)) then
			WriteToLog("HSDC Pro Initialization successful\n", "green")
		else
			WriteToLog("HSDC Pro Initialization Failed\n", "red")
			return -1
		end
		
		return 0
	end
	
	function reset_board(RadarDevice1,RadarDevice2,RadarDevice3,RadarDevice4,Samples_per_ch)
		local error_status_file_path		=	RSTD.GetSettingsPath().."\\HSDC_Pro_control_error.txt"
		local command						=	"reset".." "..error_status_file_path.." "..RadarDevice1.." "..RadarDevice2.." "..RadarDevice3.." "..RadarDevice4.." "..Samples_per_ch
		
		if (0 == AR1xx_HSDCPro_control(command,error_status_file_path)) then
			WriteToLog("Reset Board Successfully\n", "green")
		else
			WriteToLog("Resetting of the board failed failed\n", "red")
			return -1
		end	
		
		return 0
	end
	
	function capture_cw(CW_Test_Dev,Samples_per_ch)
		local HSDC_RadarDevice 				=	{0,0,0,0}
		local error_status_file_path		=	RSTD.GetSettingsPath().."\\HSDC_Pro_control_error.txt"
		local trigger_capture_start_time 	=	os.date()
		
		--Command for the AR1xx_HSDCPro_control exe
		if (CW_Test_Dev <= 4) then
			HSDC_RadarDevice[CW_Test_Dev] 	=	1
		else
			WriteToLog("Select a valid device\n", "red")
			return -1		
		end
	
		local command						=	"capture_cw".." "..error_status_file_path.." "..HSDC_RadarDevice[1].." "..HSDC_RadarDevice[2].." "..HSDC_RadarDevice[3].." "..HSDC_RadarDevice[4].." "..Samples_per_ch
		
		if (0 == AR1xx_HSDCPro_control(command,error_status_file_path)) then
			WriteToLog("Captured data from continuous stream is successfully\n", "green")
		else
			WriteToLog("Capturing data from continuous stream failed\n", "red")
			return -1
		end	
		
		return 0,trigger_capture_start_time
	end
	
	function trigger_capture()
		local error_status_file_path		=	RSTD.GetSettingsPath().."\\HSDC_Pro_control_error.txt"
		local command						=	"capture".." "..error_status_file_path
		local trigger_capture_start_time 	=	os.date()
		
		if (0 == AR1xx_HSDCPro_control(command,error_status_file_path)) then
			WriteToLog("Trigger given Successfully\n", "green")
		else
			WriteToLog("Triggering failed\n", "red")
		return -1
		end	
		
		return 0,trigger_capture_start_time
	end
	
	function save_data(adc_data_file_path,trigger_capture_start_time)
		local error_status_file_path		=	RSTD.GetSettingsPath().."\\HSDC_Pro_control_error.txt"
		local command						=	"save".." "..error_status_file_path.." "..adc_data_file_path.." "..trigger_capture_start_time
		
		if (0 == AR1xx_HSDCPro_control(command,error_status_file_path)) then
			WriteToLog("Save Data Successful\n", "green")
		else
			WriteToLog("Saving Data failed\n", "red")
		return -1
		end

		return 0
	end

	--Post Proc constants
	if (tonumber(slope) ==0) then
		Xaxis_Freq0_Range1 = 0	-- No range plot for zero slope cases
	end
	post_proc_command_string		=	data_format.." "..tostring(sample_freq*1000).." 4 "..adc_samples.." "..nchirp_loops.." "..nframes.." 1 "..RadarDevice[1].." "..RadarDevice[2].." "..RadarDevice[3].." "..RadarDevice[4].." "..Dump_FFT_Results_in_XLS.." "..slope.." "..Xaxis_Freq0_Range1
	
	-- Below is a workaround needed for SOP4
	if (sop_mode == 4) then
			WriteToLog("Workaround for SOP4 started\n", "blue")
			RSTD.Sleep(delay_time[1])
			if (0 == ar1.SOPControl_mult(dev_list[1],sop_mode)) then
				WriteToLog("Device 1 : SOP Reset Successful\n", "green")
			else
				WriteToLog("Device 1 : SOP Reset Failed\n", "red")
				return -1
			end
			RSTD.Sleep(delay_time[1])
			if (0 == ar1.Connect_mult(1,com_list[1],921600,1000)) then
				WriteToLog("Device 1 : RS232 Connect Successful\n", "green")
			else
				WriteToLog("Device 1 : RS232 Connect Failed\n", "red")
				return -1
			end
			RSTD.Sleep(delay_time[1])
			if (0 == ar1.Disconnect()) then
				WriteToLog("RS232 disconnected for the device1\n", "green")
			else
				WriteToLog("RS232 disconnection failed for the device1\n", "red")
				return -5
			end			
			WriteToLog("Workaround for SOP4 Successful\n", "blue")	
	end
	----------------------------------------------------------------------------------------------------------------------
	for i=1,table.getn(RadarDevice) do 
	
		local status	=	0
		
		--------------------------------------Configuration of AR Devices-------------------------------------------------
		if ((RadarDevice[1]==1) and (RadarDevice[i]==1)) then
			--Initialize string
			WriteToLog("Device"..i.." Configuration Started... \n", "blue")
			RSTD.Sleep(delay_time[i])
			---------------------------Connection Tab in Radarstudio-------------------------
			--SOP
			if (0 == ar1.SOPControl_mult(dev_list[i],sop_mode)) then
				WriteToLog("Device "..i.." : SOP Reset Successful\n", "green")
			else
				WriteToLog("Device "..i.." : SOP Reset Failed\n", "red")
				return -1
			end
			RSTD.Sleep(delay_time[i])	

			if (sop_mode == 2) then
				--Connecting to FTDI Port
				if (0 == ar1.Connect_mult(1,com_list[i],921600,1000)) then
					WriteToLog("Device "..i.." : RS232 Connect Successful\n", "green")
				else
					WriteToLog("Device "..i.." : RS232 Connect Failed\n", "red")
					return -1
				end
				RSTD.Sleep(delay_time[i])
				
				--Loading the BSS firmware
				WriteToLog("Loading the BSS firmware from "..BSS_firmware.."\n", "blue")
				if (0 == ar1.DownloadBSSFw_mult(dev_list[i],BSS_firmware)) then
					WriteToLog("Device "..i.." : BSS FW Download Successful\n", "green")
				else
					WriteToLog("Device "..i.." : BSS FW Download Failed\n", "red")
					return -1
				end
				RSTD.Sleep(delay_time[i])

				--Loading the MSS firmware
				WriteToLog("Loading the MSS firmware from "..MSS_firmware.."\n", "blue")
				if (0 == ar1.DownloadMSSFw_mult(dev_list[i],MSS_firmware)) then
					WriteToLog("Device "..i.." : MSS FW Download Successful\n", "green")
				else
					WriteToLog("Device "..i.." : MSS FW Download Failed\n", "red")
					return -1
				end
				RSTD.Sleep(delay_time[i])
			else
				WriteToLog("Device "..i.." : FW Download Skipped for SOP4\n", "green")
			end
			--SPI connect
			if (i==1) then
				status	=	ar1.PowerOn_mult(dev_list[i],0, 1000, 0, 0)
			else
				status	=	ar1.AddDevice(dev_list[i])
			end
		
			if (0 == status) then
				WriteToLog("Device "..i.." : SPI Connection Successful\n", "green")
			else
				WriteToLog("Device "..i.." : SPI Connection Failed\n", "red")
				return -1
			end
			RSTD.Sleep(delay_time[i])

			--RF Power UP
			if (0 == ar1.RfEnable_mult(dev_list[i])) then
				WriteToLog("Device "..i.." : RF POwer UP Successful\n", "green")
			else
				WriteToLog("Device "..i.." : RF POwer UP Failed\n", "red")
				return -1
			end
			RSTD.Sleep(delay_time[i])
			
			---------------------------Static Configuration-------------------------
			--Basic Configuration
			if (0 == ar1.ChanNAdcConfig_mult(dev_list[i],Tx1[i],Tx2[i],Tx3[i],Rx1,Rx2,Rx3,Rx4,nbits,data_format,IQ_swap,cascade_mode_list[i])) then
				WriteToLog("Device "..i.." : Basic Configuration Successful\n", "green")
			else
				WriteToLog("Device "..i.." : Basic Configuration Failed\n", "red")
				return -2
			end
			RSTD.Sleep(delay_time[i])
			
			--LDO configuration
			if (0 == ar1.RfLdoBypassConfig_mult(dev_list[i], LDO_en)) then
				WriteToLog("Device "..i.." : LDO Bypass done\n", "green")
			else
				WriteToLog("Device "..i.." : LDO Bypass failed\n", "red")
				return -2
			end
			RSTD.Sleep(delay_time[i])
			
			--Advanced Configuration
			if (0 == ar1.LPModConfig_mult(dev_list[i],0, ADC_Mode)) then
				WriteToLog("Device "..i.." : Advance Configuration Successful\n", "green")
			else
				WriteToLog("Device "..i.." : Advance Configuration failed\n", "red")
				return -2
			end
			RSTD.Sleep(delay_time[i])

			--RF Initialization
			if (0 == ar1.RfInit_mult(dev_list[i])) then
				WriteToLog("Device "..i.." : RfInit Successful\n", "green")
			else
				WriteToLog("Device "..i.." : RfInit failed\n", "red")
				return -2
			end
			RSTD.Sleep(delay_time[i])
			------------------------------------------------------------------------------
			
			---------------------------Data Configuration----------------------------------
			--Data path Configuration
			if (0 == ar1.DataPathConfig_mult(dev_list[i],1,1,0)) then
				WriteToLog("Device "..i.." : DataPathConfig Successful\n", "green")
			else
				WriteToLog("Device "..i.." : DataPathConfig failed\n", "red")
				return -3
			end
			RSTD.Sleep(delay_time[i])

			--Clock Configuration
			if (0 == ar1.LvdsClkConfig_mult(dev_list[i],1,lvds_data_rate)) then
				WriteToLog("Device "..i.." : LvdsClkConfig Successful\n", "green")
			else
				WriteToLog("Device "..i.." : LvdsClkConfig failed\n", "red")
				return -3
			end
			RSTD.Sleep(delay_time[i])

			--LVDS Lane Configuration
			if (0 == ar1.LVDSLaneConfig_mult(dev_list[i],0, lane1, lane2, lane3, lane4, MSB_on, 0, 0)) then
				WriteToLog("Device "..i.." : LVDSLaneConfig Successful\n", "green")
			else
				WriteToLog("Device "..i.." : LVDSLaneConfig failed\n", "red")
				return -3
			end
			RSTD.Sleep(delay_time[i])
			------------------------------------------------------------------------------	
			
			if (Chirp0_CW1 ~= 1) then
				---------------------------Sensor Configuration-------------------------
				--Profile
				if (0 == ar1.ProfileConfig_mult(dev_list[i],0, start_freq, idle_time, adc_start_time, ramp_end_time, 0, 0, 0, 0, 0, 0, slope, 0, adc_samples, sample_freq, 0, 0, rx_gain)) then
					WriteToLog("Device "..i.." : Profile Configuration successful\n", "green")
				else
					WriteToLog("Device "..i.." : Profile Configuration failed\n", "red")
					return -4
				end
				RSTD.Sleep(delay_time[i])

				--chirp0
				if (0 == ar1.ChirpConfig_mult(dev_list[i],0, 0, 0, 0, 0, 0, 0,Tx1_Enable[i],Tx2_Enable[i],Tx3_Enable[i])) then
					WriteToLog("Device "..i.." : Chirp config1 successful\n", "green")
				else
					WriteToLog("Device "..i.." : Chirp config1 failed\n", "red")
					return -4
				end
				RSTD.Sleep(delay_time[i])
				
				--Frame Configuration
				if (0 == ar1.FrameConfig_mult(dev_list[i],start_chirp_tx,end_chirp_tx,nframes, nchirp_loops, Inter_Frame_Interval, 0, trig_list[i])) then --n*2 for the work around to handle an issue in the TSW14J56 FW
					WriteToLog("Device "..i.." : Frame Config successful\n", "green")
				else
					WriteToLog("Device "..i.." : Frame Conig failed\n", "red")
					return -4
				end
				RSTD.Sleep(delay_time[i])
			end

			------------------------------------------------------------------------------		
			if (sop_mode == 2) then			
				--Disconnecting RS232 before other device connect to it
				if (0 == ar1.Disconnect()) then
					WriteToLog("RS232 disconnected for the device"..dev_list[i].."\n", "green")
				else
					WriteToLog("RS232 disconnection failed for the device"..dev_list[i].."\n", "red")
					return -5
				end
			end
			RSTD.Sleep(3*delay_time[i]) -- wait between devices

			WriteToLog("AR Device"..i.." Configuration Successful :) :) \n", "blue")
		else
			WriteToLog("Skipping AR Device"..i.." Configuration \n", "red")			
		end
		----------------------------------------------------------------------------------------------------------------------
	end
	
	
	--[[if(Chirp0_CW1 == 1) then
		dofile(RSTD_installed_folder.."\\Scripts\\adc_data_capture_cw.lua")
	else
		dofile(RSTD_installed_folder.."\\Scripts\\adc_data_capture.lua")
	end
	]]--
	return 0