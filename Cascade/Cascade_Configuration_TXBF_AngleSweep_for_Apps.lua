-- Cascade TX Beamforming Configuration and Data Capture Script
--
---------------------------------------- Summary ----------------------------------------------------
-- Purpose: Sets up a static TX Beamforming configuration using the 9 azimuth TX channel antenna of the 
-- MMWCAS-RF-EVM, 4-AWR2243 Cascade EVM. This script sweeps through all angles (rows) of the psCalLUT matrix, saving
-- a dataset for each row. This data then then be processed to verify the angle vs. power response of the array.  
-- - User should modify the psCalLUT matrix and with a TX beamforming calibration lookup table 
-- - script records frames to on host PC for later processing

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

-- temperature log file path
-- Change it according
temperaturelogFilePath = "E:\\ti\\mmwave_studio_03_00_00_14\\mmWaveStudio\\PostProc\\TXBF_AngleSweep_testdata\\"
temperatureLogFileName = "Cascade_TXBF_Temperature_Log_AWR2243_TXBF_Sweep.csv"

runConfiguration = 1	-- optional flag to run whole configuration of MMWCAS-RF-EVM or just the device config (after firmware and RF connect)
runWithCalibration = 1	-- flag to run with or without calibrated phase shifter settings

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

-- TX-BF Angle and calibration lookup table
local angle = 0; -- valid angle from -theta_max to +theta_max (degrees) based on calibration lookup table read

-- Profile configuration
local profile_indx              =   0
local start_freq                =   77     -- GHz
local slope                     =   50     -- MHz/us
local idle_time                 =   500      -- us
local adc_start_time            =   6      -- us
local adc_samples               =   128    -- Number of samples per chirp
local sample_freq               =   10000   -- ksps
local ramp_end_time             =   30     -- us
local rx_gain                   =   48     -- dB
local tx0OutPowerBackoffCode    =   0
local tx1OutPowerBackoffCode    =   0
local tx2OutPowerBackoffCode    =   0
local tx0PhaseShifter           =   0
local tx1PhaseShifter           =   0
local tx2PhaseShifter           =   0
local txStartTimeUSec           =   0
local hpfCornerFreq1            =   0      -- 0: 175KHz, 1: 235KHz, 2: 350KHz, 3: 700KHz
local hpfCornerFreq2            =   0      -- 0: 350KHz, 1: 700KHz, 2: 1.4MHz, 3: 2.8MHz

-- Frame configuration    
local start_chirp_tx            =   0
local end_chirp_tx              =   0
local nchirp_loops              =   252   -- Number of chirps per frame
local nframes_master            =   50     -- Number of Frames for Master
local nframes_slave             =   50     -- Number of Frames for Slaves
local Inter_Frame_Interval      =   150   -- ms
local trigger_delay             =   0     -- us
local trig_list                 =   {1,2,2,2} -- 1: Software trigger, 2: Hardware trigger  

-- Data capture
local capture_time					=	8000                             -- ms 
local inter_loop_time				=	5000							 -- ms   SSD data transfer time
local num_loops						=	1
local n_files_allocation            =   0
local data_packaging                =   0                                -- 0: 16-bit, 1: 12-bit
local capture_directory             =   "" -- setup below in code
local num_frames_to_capture			=	0								 -- 0: default case; Any positive value - number of frames to capture 
local framing_type                  =   1                                -- 0: infinite, 1: finite

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
		{	0,15,32,53,3,19,40,55,7		},  -- 1 -> angle -60
		{	0,16,34,56,7,25,47,62,16	},
		{	0,17,37,59,12,31,54,6,25	},
		{	0,19,39,63,17,37,61,15,35	},
		{	0,20,41,2,22,43,4,23,45		},
		{	0,21,44,6,26,49,12,32,55	},
		{	0,23,47,10,32,56,20,41,1	},
		{	0,24,49,14,37,63,27,51,12	},
		{	0,25,52,18,43,5,36,60,23	},
		{	0,26,55,22,48,12,44,6,34	},-- 10
		{	0,28,58,26,54,19,53,16,45	},
		{	0,29,61,31,60,26,61,26,57	},
		{	0,31,63,35,2,34,6,36,5		},
		{	0,33,2,40,8,42,15,47,17		},
		{	0,34,5,45,14,49,24,58,29	},
		{	0,36,9,49,20,58,34,5,42		},  --  16     angle： -45 deg
		{	0,37,12,54,26,1,44,16,55	},
		{	0,39,15,59,33,9,53,27,3		},
		{	0,41,18,63,40,17,63,39,16	},
		{	0,42,22,5,47,26,9,50,30		},--20
		{	0,44,25,10,53,34,19,0,44	},
		{	0,46,28,15,60,43,29,10,58	},
		{	0,48,32,20,3,52,40,23,7		},
		{	0,49,36,26,10,61,51,35,21	}, 
		{	0,51,39,31,17,5,62,48,36	},
		{	0,53,43,36,24,15,8,60,50	},
		{	0,55,47,42,32,24,19,9,1		},
		{	0,57,50,48,39,33,30,22,16	},
		{	0,59,54,54,47,43,42,35,31	},
		{	0,60,58,59,55,52,54,49,46	},--30
		{	0,0,0,0,0,0,0,0,0			},
		{	0,1,2,6,6,7,12,12,13		},
		{	0,2,5,12,14,17,24,25,29		},
		{	0,4,10,18,22,27,36,40,45	},
		{	0,6,13,24,30,37,48,54,61	},
		{	0,8,17,30,38,47,60,3,13		},
		{	0,10,22,37,46,58,9,18,29	},
		{	0,12,26,43,55,3,21,32,46	},
		{	0,14,30,49,0,14,33,47,62	},
		{	0,16,34,56,7,24,46,61,15	},
		{	0,18,38,62,15,35,59,12,32	},
		{	0,21,42,4,23,45,7,26,48		},
		{	0,23,47,10,32,56,20,41,1	},
		{	0,25,51,16,41,2,32,57,18	},
		{	0,27,56,23,49,13,45,7,35	}, -- -45
		{	0,29,59,29,58,24,58,22,53	},
		{	0,31,63,36,2,35,7,37,6		},
		{	0,33,4,42,11,46,20,53,23	},
		{	0,36,9,49,20,57,33,4,41		},
		{	0,38,13,56,28,3,46,19,59	},--50
		{	0,40,17,62,37,14,60,35,12	},
		{	0,42,22,5,46,25,9,50,29		},
		{	0,45,26,11,56,37,22,2,47	},
		{	0,47,30,18,63,48,35,17,1	},
		{	0,49,35,24,9,59,48,33,19	},
		{	0,51,40,31,17,6,62,48,36	},
		{	0,54,44,38,26,17,11,63,54	},
		{	0,56,48,45,35,28,24,15,8	},
		{	0,58,53,52,45,40,38,31,26	},
		{	0,60,58,59,54,50,52,47,44	},--60
		{	0,0,0,0,0,0,0,0,0			},
		{	0,1,2,8,7,9,14,14,15		},
		{	0,3,6,14,16,20,27,29,34		},
		{	0,5,11,21,25,31,41,45,51	},
		{	0,7,15,27,34,42,55,61,5		},
		{	0,10,20,34,43,54,4,12,23	},
		{	0,11,24,41,52,1,17,27,41	},
		{	0,14,29,48,61,11,30,44,59	},
		{	0,16,33,55,5,23,44,59,12	},
		{	0,18,38,61,14,34,58,10,30	},--70
		{	0,20,42,3,23,45,6,26,48		},
		{	0,23,47,10,32,56,19,41,1	},
		{	0,25,51,16,41,3,33,57,19	},
		{	0,27,56,23,49,14,46,8,36	},
		{	0,29,60,30,59,24,59,23,54	},
		{	0,31,63,36,3,35,8,38,6		},
		{	0,34,4,43,11,46,20,54,24	},
		{	0,36,9,49,20,57,33,4,41		},
		{	0,38,13,56,28,3,46,19,59	},
		{	0,40,17,62,37,14,59,34,11	},--80
		{	0,42,21,4,46,24,7,49,28		},
		{	0,44,25,10,54,35,20,63,45	},
		{	0,46,29,16,62,46,33,14,61	},
		{	0,48,34,23,6,56,45,28,14	},
		{	0,50,38,29,14,2,58,43,30	},
		{	0,53,42,35,23,12,5,58,47	},
		{	0,55,46,41,31,22,17,7,63	},
		{	0,57,50,47,39,32,29,21,14	},
		{	0,59,54,53,47,42,41,35,30	},
		{	0,60,58,59,55,52,53,49,46	},--90
		{	0,62,61,63,62,61,63,62,61	},
		{	0,1,2,6,6,7,12,12,13		},
		{	0,2,5,12,13,17,24,25,28		},
		{	0,4,9,18,21,26,35,38,44		},
		{	0,6,13,23,28,36,46,52,59	},
		{	0,8,16,29,36,45,58,1,9		},
		{	0,10,20,35,43,54,4,13,23	},
		{	0,11,24,40,50,63,15,25,38	},
		{	0,13,27,45,58,8,26,38,52	},
		{	0,15,31,51,1,16,36,50,2		},--100
		{	0,16,34,56,7,25,47,62,16	},
		{	0,18,38,61,14,34,57,10,29	},
		{	0,20,41,2,21,42,3,22,43		},
		{	0,21,44,7,27,50,12,33,57	},
		{	0,23,48,11,34,59,22,45,5	},
		{	0,24,51,16,40,2,32,56,18	}, -- 106 -- angle +45 deg
		{	0,26,54,21,47,10,41,3,30	},
		{	0,27,58,26,53,18,51,13,43	},
		{	0,29,60,30,59,25,60,24,55	},
		{	0,31,63,35,1,33,4,34,2		},--110
		{	0,32,2,39,6,40,13,45,14		},
		{	0,34,5,43,12,47,22,55,25	},
		{	0,35,7,47,17,54,30,1,37		},
		{	0,36,10,52,23,61,38,10,48	},
		{	0,38,13,56,28,3,46,19,59	},
		{	0,39,15,59,34,10,54,28,4	},
		{	0,40,18,63,39,16,62,37,15	},
		{	0,42,20,3,44,22,5,46,24		},
		{	0,43,23,6,48,28,12,54,34	},
		{	0,44,25,10,53,34,19,0,44	},--120
		{	0,45,27,13,58,40,26,6,53	},
	}  
	
	
else 
	-- ideal values (no calibration applied) 
	psCalLUT = { 
	
	} 
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

	---------------------------Calibration Data Capture -------------------------
			print("Capturing Data...\n")
			
			-- add leading zero to angle offset value for dataset name ordering
			if (angleIdx < 10) then
				angleIdxString = "00"..tostring(angleIdx)
			elseif (angleIdx < 100) then
				angleIdxString = "0"..tostring(angleIdx)
			else
				angleIdxString = tostring(angleIdx)
			end
			
			-- TDA ARM
			WriteToLog("Starting TDA ARM...\n", "blue")
			capture_directory = "BeamAngle"..tostring(angleIdxString) .. "_Sample05"
			WriteToLog("capture_directory:  "..capture_directory.."  --------\n", "blue")
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
			
			-- Delete TDA SSD floder
			--  Delete a folder from TDA file system at /mnt/ssd directory
			-- status = ar1.TDAFolderDelete(capture_directory, "COM10", 115200)
			-- if(status == 0) then
			--	WriteToLog("TDAFolderDelete in SSD! COMPLETE!\n", "green")
			--end    

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

-- setup temperature logging
local StatusFlag = 0
local Errorcode  = 0
local Timestamp  = 0	

local Rx1TempVal 	= {}	 
local Rx2TempVal 	= {}	 
local Rx3TempVal 	= {}	 
local Rx4TempVal 	= {}	 
local Tx1TempVal 	= {}	 
local Tx2TempVal 	= {}	 
local Tx3TempVal 	= {}	 
local PMTempVal	  	= {}
local Dig1TempVal 	= {} 
local Dig2TempVal 	= {}	 

monitorTempLogFile = io.open(temperaturelogFilePath..temperatureLogFileName, "w")

ar1.SetRfAnaMonConfig_mult(15, 0x9, 0x0)
ar1.SetRfTempMonConfig_mult(15, 2, 0, 0, 0, 0, 0)
RSTD.Sleep(1000)

-- write headers
monitorTempLogFile:write("Timestamp, Rx1TempVal[1], Rx2TempVal[1], Rx3TempVal[1], Rx4TempVal[1], Tx1TempVal[1], Tx2TempVal[1], Tx3TempVal[1], PMTempVal[1], Dig1TempVal[1], Dig2TempVal[1], Rx1TempVal[2], Rx2TempVal[2], Rx3TempVal[2], Rx4TempVal[2], Tx1TempVal[2], Tx2TempVal[2], Tx3TempVal[2], PMTempVal[2], Dig1TempVal[2], Dig2TempVal[2], Rx1TempVal[3], Rx2TempVal[3], Rx3TempVal[3], Rx4TempVal[3], Tx1TempVal[3], Tx2TempVal[3], Tx3TempVal[3], PMTempVal[3], Dig1TempVal[3], Dig2TempVal[3], Rx1TempVal[4], Rx2TempVal[4], Rx3TempVal[4], Rx4TempVal[4], Tx1TempVal[4], Tx2TempVal[4], Tx3TempVal[4], PMTempVal[4], Dig1TempVal[4], Dig2TempVal[4]\n")


-- loop through all angle offset settings and take a few frames of data
for angleIdx = 31, 91, 10 do

	local psSettings = {}
	local azAntIdx = 1
	local phaseShifterStepinDeg = 5.625

	for devIdx = 1, 4 do 

		psSettings[devIdx] = {}

		for txIdx = 1, 3 do	-- map calibration LUT to AWRx device phase-shifter configuration matrix

			if(devIdx == 1) then
				psSettings[devIdx][txIdx] = 0 -- ignore at AWR #1, psCalLUT table only applies to 9 TX of azimuth antenna array
			else
				psSettings[devIdx][txIdx] = psCalLUT[angleIdx][azAntIdx] * phaseShifterStepinDeg
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

	-- temperature logging
	for devIdx = 1, 4 do
		dummy1, Timestamp, Rx1TempVal[devIdx], Rx2TempVal[devIdx], Rx3TempVal[devIdx], Rx4TempVal[devIdx], Tx1TempVal[devIdx], Tx2TempVal[devIdx], Tx3TempVal[devIdx], PMTempVal[devIdx], Dig1TempVal[devIdx], Dig2TempVal[devIdx] = ar1.RFTemperatureGet_mult(dev_list[devIdx]) 	
		if (devIdx == 1) then
			monitorTempLogFile:write(Timestamp..", "..Rx1TempVal[devIdx]..", "..Rx2TempVal[devIdx]..", "..Rx3TempVal[devIdx]..", "..Rx4TempVal[devIdx]..", "..Tx1TempVal[devIdx]..", "..Tx2TempVal[devIdx]..", "..Tx3TempVal[devIdx]..", "..PMTempVal[devIdx]..", "..Dig1TempVal[devIdx]..", "..Dig2TempVal[devIdx])
		else
			monitorTempLogFile:write(", "..Rx1TempVal[devIdx]..", "..Rx2TempVal[devIdx]..", "..Rx3TempVal[devIdx]..", "..Rx4TempVal[devIdx]..", "..Tx1TempVal[devIdx]..", "..Tx2TempVal[devIdx]..", "..Tx3TempVal[devIdx]..", "..PMTempVal[devIdx]..", "..Dig1TempVal[devIdx]..", "..Dig2TempVal[devIdx])
		end	
	end
	monitorTempLogFile:write("\n")
	
end


--close temperature logging file handle
io.close(monitorTempLogFile)
