-- Cascade TX Beamforming Configuration and Data Capture Script
--    
---------------------------------------- Summary ----------------------------------------------------
-- Purpose: Sets up a static TX Beamforming configuration using the 9 azimuth TX channel antenna of the 
-- MMWCAS-RF-EVM, 4-AWR2243 Cascade EVM. This data then then be processed to verify the angle vs. power 
-- response of the array for a single offset. 
--	- user should modify the psCalLUT matrix and with a TX beamforming calibration lookup table 
--	- user can select the beam-steering angle (select a row of psCalLUT) using the angleIdx variable
-- 	- script records frames to on host PC for later processing

----------------------------------------User Constants----------------------------------------------------
dev_list						=	{1, 2, 4, 8}                    -- Device map
RadarDevice						=	{1, 1, 1, 1}				    -- {dev1, dev2, dev3, dev4}, 1: Enable, 0: Disable
	
cascade_mode_list				=	{1, 2, 2, 2}				    -- 0: Single chip, 1: Master, 2: Slave

-- F/W Download Path

-- Uncomment the next line if you wish to pop-up a dialog box to select the firmware image file
-- Otherwise, hardcode the path to the firmware metaimage below
-- By default, the firmware filename is: xwr22xx_metaImage.bin
--
-- metaImagePath                   =   RSTD.BrowseForFile(RSTD.GetSettingsPath(), "bin", "Browse to .bin file")
-- For 2243 ES1.1 devices
-- metaImagePath            =   "C:\\ti\\mmwave_dfp_02_02_02_01\\firmware\\xwr22xx_metaImage.bin"
metaImagePath            =   "E:\\ti\\mmwave_dfp_02_02_04_00\\firmware\\xwr22xx_metaImage.bin"
-- For 2243 ES1.0 devices
-- metaImagePath            =   "C:\\ti\\mmwave_dfp_02_02_00_02\\firmware\\xwr22xx_metaImage.bin"

-- IP Address for the TDA2 Host Board
-- Change this accordingly for your setup
TDA_IPAddress                   =   "192.168.33.180"

runConfiguration = 1	-- optional flag to run whole configuration of MMWCAS-RF-EVM or just the device config (after firmware and RF connect)
runWithCalibration = 0	-- flag to run with or without calibrated phase shifter settings

-- Device map of all the devices to be enabled by TDA
-- 1 - master ; 2- slave1 ; 4 - slave2 ; 8 - slave3

deviceMapOverall                =   RadarDevice[1] + (RadarDevice[2]*2) + (RadarDevice[3]*4) + (RadarDevice[4]*8)
deviceMapSlaves                 =   (RadarDevice[2]*2) + (RadarDevice[3]*4) + (RadarDevice[4]*8)

    
------------------------------------------- Sensor Configuration ------------------------------------------------

-- The sensor configuration consists of 3 sections:
-- 		1) Profile Configuration (common to all 4 AWR devices)
--		2) Chirp Configuration (unique for each AWR device - mainly because TXs to use are different for each chirp)
--		3) Frame Configuration (common to all 4 AWR devices, except for the trigger mode for the master)
-- Change the values below as needed.



-- Profile configuration
local profile_indx              =   0
local start_freq				=	77								-- GHz
local slope						=	50  							-- MHz/us
local idle_time					=	20								-- us
local adc_start_time			=	6								-- us
local adc_samples				=	64							    -- Number of samples per chirp
local sample_freq				=	8000							-- ksps
local ramp_end_time				=	40								-- us
local rx_gain					=	40								-- dB
local tx0OutPowerBackoffCode    =   0
local tx1OutPowerBackoffCode    =   0
local tx2OutPowerBackoffCode    =   0
local tx0PhaseShifter           =   0
local tx1PhaseShifter           =   0
local tx2PhaseShifter           =   0
local txStartTimeUSec           =   0
local hpfCornerFreq1            =   0                               -- 0: 175KHz, 1: 235KHz, 2: 350KHz, 3: 700KHz
local hpfCornerFreq2            =   0                               -- 0: 350KHz, 1: 700KHz, 2: 1.4MHz, 3: 2.8MHz

-- Frame configuration	
local start_chirp_tx			=	0
local end_chirp_tx				=	0
local nchirp_loops				=	236								-- Number of chirps per frame
local nframes_master			=	10							    -- Number of Frames for Master
local nframes_slave			    =	10							    -- Number of Frames for Slaves
local Inter_Frame_Interval		=	200								-- ms
local trigger_delay             =   0                               -- us
local nDummy_chirp              =   0       
local trig_list					=	{1,2,2,2}	                    -- 1: Software trigger, 2: Hardware trigger    

-- Data capture
local capture_time					=	2000                             -- ms
local inter_loop_time				=	2000							 -- ms
local num_loops						=	1
local n_files_allocation            =   0
local data_packaging                =   0                                -- 0: 16-bit, 1: 12-bit
local capture_directory             =   "" -- setup below in code
local num_frames_to_capture			=	0								 -- 0: default case; Any positive value - number of frames to capture 
local framing_type                  =   1                                -- 0: infinite, 1: finite

-- Phase Shifter configuration
-- map calibration LUT to AWRx device phase-shifter configuration matrix
local psSettings = {}
local azAntIdx = 1
local angleIdx =  1 --> angle = 75 deg
--local angleIdx = 16 --> angle = 90 deg
--local angleIdx = 31 --> angle = 105deg
-- TX-BF Angle and calibration lookup table

-- initialize phase shifter value matrix based on steering angle requested
-- based on MMWCAS-RF-EVM layout, only TX from AWR2, AWR3 and AWR4 are used for azimuth beam-forming 
--  
-- 	Right array (-angle)  		  --> AWR #4, TX1
-- 	Center array (boresight axix) --> AWR #3, TX2
--  Left array (+angle)           --> AWR #2, TX3  
--

if (runWithCalibration) then
 
	-- LUT calibration table - copy and pasted from matlab output 
	psCalLUT = { 
	{0,40,21,29,8,47,60,33,12}, --> angle = 75
	{0,43,22,36,13,58,9,49,29},
	{0,46,30,42,25,8,19,63,47},
	{0,47,34,49,31,16,35,18,63},
	{0,50,36,57,39,27,46,31,21},
	{0,52,40,62,49,38,59,46,36},
	{0,55,46,5,60,49,10,61,53},
	{0,56,50,11,3,59,25,15,7},
	{0,58,55,21,11,7,36,30,23},
	{0,61,58,24,20,21,48,44,45},
	{0,62,62,31,29,29,61,59,59},
	{0,1,4,37,38,40,11,11,13},
	{0,4,10,44,47,52,24,27,34},
	{0,8,12,52,56,62,37,42,49},
	{0,10,16,60,1,11,52,58,4},
	{0,0,0,0,0,0,0,0,0},	--> angle = 90
	{0,12,26,7,21,32,14,26,38},
	{0,17,29,14,30,44,27,41,56},
	{0,16,33,20,36,54,40,56,11},
	{0,21,38,27,46,3,54,10,30},
	{0,20,44,33,54,15,4,23,46},
	{0,22,51,40,2,23,18,39,63},
	{0,26,52,47,10,36,29,57,21},
	{0,30,56,54,16,46,44,9,36},
	{0,29,61,61,28,60,56,25,53},
	{0,34,3,4,33,5,8,37,7},
	{0,33,6,11,44,18,21,53,24},
	{0,36,11,18,52,28,32,5,45},
	{0,38,17,25,61,37,46,19,59},
	{0,40,19,29,6,51,58,33,15},
	{0,43,22,36,17,58,7,50,29}, --> angle = 105 deg
	}  
	
	
else 
	-- ideal values (no calibration applied) 
	psCalLUT = { 
	{	0,30,61,28,59,26,57,24,54	},
	{	0,33,2,35,4,37,6,39,8		},
	{	0,35,6,41,12,48,19,54,25	},
	{	0,37,10,48,21,58,32,5,43	},
	{	0,39,15,54,30,5,45,21,60	},
	{	0,41,19,61,39,16,58,36,14	},
	{	0,43,23,3,47,27,7,51,31		},
	{	0,46,28,10,56,38,21,3,49	},
	{	0,48,32,17,1,50,34,18,3		},
	{	0,50,37,23,10,61,47,34,20	},
	{	0,52,41,30,19,8,61,49,38	},
	{	0,55,46,37,28,19,10,1,56	},
	{	0,57,50,43,37,30,23,17,10	},
	{	0,59,55,50,46,41,37,32,28	},
	{	0,61,59,57,55,52,50,48,46	},
	{	0,0,0,0,0,0,0,0,0			},
	{	0,2,4,6,8,11,13,15,17		},
	{	0,4,8,13,17,22,26,31,35		},
	{	0,6,13,20,26,33,40,46,53	},
	{	0,8,17,26,35,44,53,62,7		},
	{	0,11,22,33,44,55,2,14,25	},
	{	0,13,26,40,53,2,16,29,43	},
	{	0,15,31,46,62,13,29,45,60	},
	{	0,17,35,53,7,25,42,60,14	},
	{	0,20,40,60,16,36,56,12,32	},
	{	0,22,44,2,24,47,5,27,49		},
	{	0,24,48,9,33,58,18,42,3		},
	{	0,26,53,15,42,5,31,58,20	},
	{	0,28,57,22,51,15,44,9,38	},
	{	0,30,61,28,59,26,57,24,55	},
	{	0,33,2,35,4,37,6,39,9		}, --> angle = 105 deg 
	} 

end


-- create psSettings matrix which will be used to program the individual devices
for devIdx = 1, 4 do 

	psSettings[devIdx] = {}

	for txIdx = 1, 3 do	

		if(devIdx == 1) then
			psSettings[devIdx][txIdx] = 0 -- ignore at AWR #1
		else
			psSettings[devIdx][txIdx] = psCalLUT[angleIdx][azAntIdx]
			azAntIdx = azAntIdx + 1
		end

	end
end

-- debug print back of phase shifter settings
WriteToLog("psSettings[devIdx][txIdx]: \n", "green")
for devIdx = 1, 4 do -- start at AWR #2
	for txIdx = 1, 3 do		
		WriteToLog(psSettings[devIdx][txIdx]..", ", "green")
	end
	WriteToLog("\n", "green")
end

-- Function to start/stop frame
function Framing_Control(Device_ID, En1_Dis0)
	local status = 0 		
        if (En1_Dis0 == 1) then 
			status = ar1.StartFrame_mult(dev_list[Device_ID]) --Start Trigger Frame
            if (status == 0) then
                WriteToLog("Device "..Device_ID.." : Start Frame Successful\n", "green")
            else
                WriteToLog("Device "..Device_ID.." : Start Frame Failed\n", "red")
                return -5
            end
        else
			status = ar1.StopFrame_mult(dev_list[Device_ID]) --Stop Trigger Frame
            if (status == 0) then
                WriteToLog("Device "..Device_ID.." : Stop Frame Successful\n", "green")
            else
                WriteToLog("Device "..Device_ID.." : Stop Frame Failed\n", "red")
                return -5
            end
        end
    
    return status
end
 
-- Function to capture data 
function CaptureData(angleIdx)

	--------------------------- Data Capture -------------------------
			print("Capturing Data...\n")
			
			-- add leading zero to angle offset value for dataset name ordering
			if (angleIdx < 10) then
				angleIdxString = "0"..tostring(angleIdx)
			else
				angleIdxString = tostring(angleIdx)
			end
			
			-- TDA ARM
			WriteToLog("Starting TDA ARM...\n", "blue")
			capture_directory = "TXBF_BeamAngle"..tostring(angleIdxString)
			status = ar1.TDACaptureCard_StartRecord_mult(1, n_files_allocation, data_packaging, capture_directory, num_frames_to_capture)
			if (status == 0) then
				WriteToLog("TDA ARM Successful\n", "green")
			else
				WriteToLog("TDA ARM Failed\n", "red")
				return -5
			end 
					
			RSTD.Sleep(1500)
			
			-- Triggering the data capture
			WriteToLog("Starting Frame Trigger sequence...\n", "blue")

			if (RadarDevice[4]==1)then
				Framing_Control(4,1)
			end

			if (RadarDevice[3]==1)then
				Framing_Control(3,1)
			end

			if (RadarDevice[2]==1)then
				Framing_Control(2,1)
			end

			Framing_Control(1,1)

			WriteToLog("Capturing AWR device data to the TDA SSD...\n", "blue")
			RSTD.Sleep(capture_time)
			WriteToLog("Capture sequence completed...\n", "blue")
				
			WriteToLog("Starting Transfer files using WinSCP..\n", "blue")
			status = ar1.TransferFilesUsingWinSCP_mult(1)
			if(status == 0) then
				WriteToLog("Transferred files! COMPLETE!\n", "green")
			else
				WriteToLog("Transferring files FAILED!\n", "red")
				return -5
			end  
			
			RSTD.Sleep(inter_loop_time)			

end

-- Note: The syntax for this API is:
-- 		ar1.ChirpConfig_mult(RadarDeviceId, chirpStartIdx, chirpEndIdx, profileId, startFreqVar, freqSlopeVar, idleTimeVar, adcStartTimeVar, tx0Enable, tx1Enable, tx2Enable)

-- For TX Beamforming only a single chirp is used on each device. 
-- The pre-calculated, calibrated phase offset is applied to each TX channel
function Configure_Chirps(i) 
	
	if (i == 1) then
            
            -- Chirp 0
			if (0 == ar1.ChirpConfig_mult(dev_list[i], 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)) then
				WriteToLog("Device "..i.." : Chirp 0 Configuration successful\n", "green")
			else
				WriteToLog("Device "..i.." : Chirp 0 Configuration failed\n", "red")
				return -4
			end
            
		
	elseif (i == 2) then
    
            -- Chirp 0
			if (0 == ar1.ChirpConfig_mult(dev_list[i], 0, 0, 0, 0, 0, 0, 0, 1, 1, 1)) then
				WriteToLog("Device "..i.." : Chirp 0 Configuration successful\n", "green")
			else
				WriteToLog("Device "..i.." : Chirp 0 Configuration failed\n", "red")
				return -4
			end
            
            
    elseif (i == 3) then
    
            -- Chirp 0
			if (0 == ar1.ChirpConfig_mult(dev_list[i], 0, 0, 0, 0, 0, 0, 0, 1, 1, 1)) then
				WriteToLog("Device "..i.." : Chirp 0 Configuration successful\n", "green")
			else
				WriteToLog("Device "..i.." : Chirp 0 Configuration failed\n", "red")
				return -4
			end
   
            
    elseif (i == 4) then
    
            -- Chirp 0
			if (0 == ar1.ChirpConfig_mult(dev_list[i], 0, 0, 0, 0, 0, 0, 0, 1, 1, 1)) then
				WriteToLog("Device "..i.." : Chirp 0 Configuration successful\n", "green")
			else
				WriteToLog("Device "..i.." : Chirp 0 Configuration failed\n", "red")
				return -4
			end
  
	end

end
 

------------------------------------------- API Configuration ------------------------------------------------    

if (runConfiguration == 1) then
	-- 1. Connection to TDA. 2. Selecting Cascade/Single Chip.  3. Selecting 2-chip/4-chip

	WriteToLog("Setting up Studio for Cascade started..\n", "blue")

	if(0 == ar1.ConnectTDA(TDA_IPAddress, 5001, deviceMapOverall)) then
		WriteToLog("ConnectTDA Successful\n", "green")
	else
		WriteToLog("ConnectTDA Failed\n", "red")
		return -1
	end

	if(0 == ar1.selectCascadeMode(1)) then
		WriteToLog("selectCascadeMode Successful\n", "green")
	else
		WriteToLog("selectCascadeMode Failed\n", "red")
		return -1
	end

	WriteToLog("Setting up Studio for Cascade ended..\n", "blue")
			 
	--Master Initialization
		  
	-- SOP Mode Configuration
	if (0 == ar1.SOPControl_mult(1, 4)) then
		WriteToLog("Master : SOP Reset Successful\n", "green")
	else
		WriteToLog("Master : SOP Reset Failed\n", "red")
		return -1
	end
			
	-- SPI Connect		
	if (0 == ar1.PowerOn_mult(1, 0, 1000, 0, 0)) then
		WriteToLog("Master : SPI Connection Successful\n", "green")
	else
		WriteToLog("Master : SPI Connection Failed\n", "red")
		return -1
	end

	-- Firmware Download. (SOP 4 - MetaImage)
	if (0 == ar1.DownloadBssFwOvSPI_mult(1, metaImagePath)) then
		WriteToLog("Master : FW Download Successful\n", "green")
	else
		WriteToLog("Master : FW Download Failed\n", "red")
		return -1
	end

			 
	-- RF Power Up
	if (0 == ar1.RfEnable_mult(1)) then
		WriteToLog("Master : RF Power Up Successful\n", "green")
	else
		WriteToLog("Master : RF Power Up Failed\n", "red")
		return -1
	end			
			 
	-- Channel & ADC Configuration
	if (0 == ar1.ChanNAdcConfig_mult(1,1,1,1,1,1,1,1,2,1,0,1)) then
		WriteToLog("Master : Channel & ADC Configuration Successful\n", "green")
	else
		WriteToLog("Master : Channel & ADC Configuration Failed\n", "red")
		return -2
	end
		
	-- Slaves Initialization
	   
	for i=2,table.getn(RadarDevice) do 
		local status	=	0		        
		if ((RadarDevice[1]==1) and (RadarDevice[i]==1)) then
		  
			-- SOP Mode Configuration
			if (0 == ar1.SOPControl_mult(dev_list[i], 4)) then
				WriteToLog("Device "..i.." : SOP Reset Successful\n", "green")
			else
				WriteToLog("Device "..i.." : SOP Reset Failed\n", "red")
				return -1
			end
					
			-- SPI Connect	
			if (0 == ar1.AddDevice(dev_list[i])) then
				WriteToLog("Device "..i.." : SPI Connection Successful\n", "green")
			else
				WriteToLog("Device "..i.." : SPI Connection Failed\n", "red")
				return -1
			end
			   
		end
	end  
		
	-- Firmware Download. (SOP 4 - MetaImage)
	if (0 == ar1.DownloadBssFwOvSPI_mult(deviceMapSlaves, metaImagePath)) then
		WriteToLog("Slaves : FW Download Successful\n", "green")
	else
		WriteToLog("Slaves : FW Download Failed\n", "red")
		return -1
	end
			 
	-- RF Power Up
	if (0 == ar1.RfEnable_mult(deviceMapSlaves)) then
		WriteToLog("Slaves : RF Power Up Successful\n", "green")
	else
		WriteToLog("Slaves : RF Power Up Failed\n", "red")
		return -1
	end	
			 
	-- Channel & ADC Configuration
	if (0 == ar1.ChanNAdcConfig_mult(deviceMapSlaves,1,1,1,1,1,1,1,2,1,0,2)) then
		WriteToLog("Slaves : Channel & ADC Configuration Successful\n", "green")
	else
		WriteToLog("Slaves : Channel & ADC Configuration Failed\n", "red")
		return -2
	end
				
	-- All devices together        
			  
	-- Including this depends on the type of board being used.
	-- LDO configuration
	if (0 == ar1.RfLdoBypassConfig_mult(deviceMapOverall, 3)) then
		WriteToLog("LDO Bypass Successful\n", "green")
	else
		WriteToLog("LDO Bypass failed\n", "red")
		return -2
	end

	-- Low Power Mode Configuration
	if (0 == ar1.LPModConfig_mult(deviceMapOverall,0, 0)) then
		WriteToLog("Low Power Mode Configuration Successful\n", "green")
	else
		WriteToLog("Low Power Mode Configuration failed\n", "red")
		return -2
	end

	-- Miscellaneous Control Configuration
	if (0 == ar1.SetMiscConfig_mult(deviceMapOverall, 0, 0, 0, 0)) then -- enables the per chirp phase shifter enable
		WriteToLog("Misc Control Configuration Successful\n", "green")
	else
		WriteToLog("Misc Control Configuration failed\n", "red")
		return -2
	end

	-- Edit this API to enable/disable the boot time calibration. Enabled by default.
	-- RF Init Calibration Configuration
	if (0 == ar1.RfInitCalibConfig_mult(deviceMapOverall, 1, 1, 1, 1, 1, 1, 1, 65537)) then
		WriteToLog("RF Init Calibration Successful\n", "green")
	else
		WriteToLog("RF Init Calibration failed\n", "red")
		return -2
	end
			 
	-- RF Init
	if (0 == ar1.RfInit_mult(deviceMapOverall)) then
		WriteToLog("RF Init Successful\n", "green")
	else
		WriteToLog("RF Init failed\n", "red")
		return -2
	end

	---------------------------Data Configuration----------------------------------
			
	-- Data path Configuration
	if (0 == ar1.DataPathConfig_mult(deviceMapOverall, 0, 1, 0)) then
		WriteToLog("Data Path Configuration Successful\n", "green")
	else
		WriteToLog("Data Path Configuration failed\n", "red")
		return -3
	end

	-- Clock Configuration
	if (0 == ar1.LvdsClkConfig_mult(deviceMapOverall, 1, 1)) then
		WriteToLog("Clock Configuration Successful\n", "green")
	else
		WriteToLog("Clock Configuration failed\n", "red")
		return -3
	end

	-- CSI2 Configuration
	if (0 == ar1.CSI2LaneConfig_mult(deviceMapOverall, 1, 0, 2, 0, 4, 0, 5, 0, 3, 0, 0)) then
		WriteToLog("CSI2 Configuration Successful\n", "green")
	else
		WriteToLog("CSI2 Configuration failed\n", "red")
		return -3
	end

end

-------------------------Sensor Configuration-------------------------
				

-- Profile Configuration
--Int32 ar1.ProfileConfig_mult(UInt16 RadarDeviceId, UInt16 profileId, Single startFreqConst, Single idleTimeConst, Single adcStartTimeConst, Single rampEndTime, UInt32 tx0OutPowerBackoffCode, UInt32 tx1OutPowerBackoffCode, UInt32 tx2OutPowerBackoffCode, Single tx0PhaseShifter, Single tx1PhaseShifter, Single tx2PhaseShifter, Single freqSlopeConst, Single txStartTime, UInt16 numAdcSamples, UInt16 digOutSampleRate, UInt32 hpfCornerFreq1, UInt32 hpfCornerFreq2, Char rxGain)

for devIdx = 1, 4 do -- loop through all devices and program chirp profile

	if (0 == ar1.ProfileConfig_mult(dev_list[devIdx], 0, start_freq, idle_time, adc_start_time, ramp_end_time, 0, 0, 0, psSettings[devIdx][1], psSettings[devIdx][2], psSettings[devIdx][3], slope, 0, adc_samples, sample_freq, 0, 0, rx_gain)) then
		WriteToLog("Profile Configuration successful\n", "green")
	else
		WriteToLog("Profile Configuration failed\n", "red")
		return -4
	end

end

-- Chirp Configuration 
for i=1,table.getn(RadarDevice) do    
	if ((RadarDevice[1]==1) and (RadarDevice[i]==1)) then			                           
		Configure_Chirps(i)				
	end
end
    
-- Frame Configuration               
-- Master
if (0 == ar1.FrameConfig_mult(1,start_chirp_tx,end_chirp_tx,nframes_master, nchirp_loops, Inter_Frame_Interval, 0, 1)) then
    WriteToLog("Master : Frame Configuration successful\n", "green")
else
    WriteToLog("Master : Frame Configuration failed\n", "red")
end
-- Slaves 
if (0 == ar1.FrameConfig_mult(deviceMapSlaves,start_chirp_tx,end_chirp_tx,nframes_slave, nchirp_loops, Inter_Frame_Interval, 0, 2)) then
    WriteToLog("Slaves : Frame Configuration successful\n", "green")
else
    WriteToLog("Slaves : Frame Configuration failed\n", "red")
end

RSTD.Sleep(500) -- Wait after frame configuration programmed before starting framing

-- capture data
CaptureData(angleIdx)
