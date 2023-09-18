-- All the parameters used in this script are default parameters used in the mmWaveStudio GUI.
-- It captures the ADC data using DCA1000.
-- The user is expected to change the configuration according to specific use-cases.
-- Change "operating_mode" in line 15 based on the usecase

--BSS and MSS firmware download
info = debug.getinfo(1,'S');
file_path = (info.source);
file_path = string.gsub(file_path, "@","");
file_path = string.gsub(file_path, "DataCaptureDemo_xWR.lua","");
fw_path   = file_path.."..\\..\\rf_eval_firmware"

--Mode of operation.
--Legacy Framing mode = 0/Advanced framing mode = 1/Continous streaming mode = 2
operating_mode = 0

--Export bit operation file
bitopfile = file_path.."\\".."bitoperations.lua"
dofile(bitopfile)

--Read part ID
--This register address used to find part number
res, efusedevice = ar1.ReadRegister(0xFFFFE214, 0, 31)
efuseES2ES3Device = bit_and(efusedevice, 0x03FC0000)
efuseES2ES3Device = bit_rshift(efuseES2ES3Device, 18)

if(efuseES2ES3Device == 0x30 or efuseES2ES3Device == 0x6) then
	partId = 2243E0
elseif(efuseES2ES3Device == 0x31 or efuseES2ES3Device == 0x32) then
	partId = 2243E1
else
	WriteToLog("Invalid Device part number\n" ..partId)
end 

--ES version
res, ESVersion = ar1.ReadRegister(0xFFFFE218, 0, 31)
ESVersion = bit_and(ESVersion, 15)

--ADC_Data file path
data_path     = file_path.."..\\PostProc"
adc_data_path = data_path.."\\adc_data.bin"

-- Download Firmware
if(partId == 2243E0) then
    BSS_FW    = fw_path.."\\AWR2243_ES1_0\\radarss\\xwr22xx_radarss.bin"
    MSS_FW    = fw_path.."\\AWR2243_ES1_0\\masterss\\xwr22xx_masterss.bin"
elseif(partId == 2243E1) then
    BSS_FW    = fw_path.."\\AWR2243_ES1_1\\radarss\\xwr22xx_radarss.bin"
    MSS_FW    = fw_path.."\\AWR2243_ES1_1\\masterss\\xwr22xx_masterss.bin"
else
    WriteToLog("Invalid Device partId FW\n" ..partId)
    WriteToLog("Invalid Device ESVersion\n" ..ESVersion)
end

-- Download BSS Firmware
if (ar1.DownloadBSSFw(BSS_FW) == 0) then
    WriteToLog("BSS FW Download Success\n", "green")
else
    WriteToLog("BSS FW Download failure\n", "red")
end
RSTD.Sleep(100)

-- Download MSS Firmware
if (ar1.DownloadMSSFw(MSS_FW) == 0) then
    WriteToLog("MSS FW Download Success\n", "green")
else
    WriteToLog("MSS FW Download failure\n", "red")
end
RSTD.Sleep(100)

-- SPI Connect
if (ar1.PowerOn(1, 1000, 0, 0) == 0) then
    WriteToLog("Power On Success\n", "green")
else
   WriteToLog("Power On failure\n", "red")
end
RSTD.Sleep(100)

-- RF Power UP
if (ar1.RfEnable() == 0) then
    WriteToLog("RF Enable Success\n", "green")
else
    WriteToLog("RF Enable failure\n", "red")
end
RSTD.Sleep(100)

if (ar1.ChanNAdcConfig(1, 1, 0, 1, 1, 1, 1, 2, 1, 0) == 0) then
    WriteToLog("ChanNAdcConfig Success\n", "green")
else
    WriteToLog("ChanNAdcConfig failure\n", "red")
end
RSTD.Sleep(100)

if (ar1.LPModConfig(0, 0) == 0) then
    WriteToLog("Regualar mode Cfg Success\n", "green")
else
    WriteToLog("Regualar mode Cfg failure\n", "red")
end
RSTD.Sleep(100)

if (ar1.RfInit() == 0) then
    WriteToLog("RfInit Success\n", "green")
else
    WriteToLog("RfInit failure\n", "red")
end

RSTD.Sleep(1000)

if (ar1.DataPathConfig(1, 1, 0) == 0) then
    WriteToLog("DataPathConfig Success\n", "green")
else
    WriteToLog("DataPathConfig failure\n", "red")
end
RSTD.Sleep(100)

if (ar1.LvdsClkConfig(1, 1) == 0) then
    WriteToLog("LvdsClkConfig Success\n", "green")
else
    WriteToLog("LvdsClkConfig failure\n", "red")
end
RSTD.Sleep(100)

if (ar1.LVDSLaneConfig(0, 1, 1, 1, 1, 1, 0, 0) == 0) then
    WriteToLog("LVDSLaneConfig Success\n", "green")
else
    WriteToLog("LVDSLaneConfig failure\n", "red")
end
RSTD.Sleep(100)

if((operating_mode == 0) or (operating_mode == 1)) then
    if(ar1.ProfileConfig(0, 77, 100, 6, 60, 0, 0, 0, 0, 0, 0, 29.982, 0, 256, 10000, 0, 0, 94) == 0) then
        WriteToLog("ProfileConfig Success\n", "green")
    else
        WriteToLog("ProfileConfig failure\n", "red")
    end
    RSTD.Sleep(100)
    if (ar1.ChirpConfig(0, 0, 0, 0, 0, 0, 0, 1, 1, 0) == 0) then
        WriteToLog("ChirpConfig Success\n", "green")
    else
        WriteToLog("ChirpConfig failure\n", "red")
    end
end
RSTD.Sleep(100)

if(operating_mode == 0) then
    if (ar1.FrameConfig(0, 0, 8, 128, 40, 0, 1) == 0) then
        WriteToLog("FrameConfig Success\n", "green")
    else
        WriteToLog("FrameConfig failure\n", "red")
    end
elseif(operating_mode == 1) then
    if (ar1.AdvanceFrameConfig(4, 1536, 0, 0, 1, 128, 8000000, 0, 1, 1, 8000000, 0, 0, 1, 128, 8000000, 0,1, 1, 8000000, 0, 0, 1, 128, 8000000, 0, 1, 1, 8000000, 0, 0, 1, 128,8000000, 0, 1, 1, 8000000, 8, 1, 0, 1, 128, 0, 1, 128, 1, 1, 128,1, 1, 128, 1, 1) == 0) then
        WriteToLog("AdvanceFrameConfig Success\n", "green")
    else
        WriteToLog("AdvanceFrameConfig failure\n", "red")
    end
end
RSTD.Sleep(100)

-- select Device type
if (ar1.SelectCaptureDevice("DCA1000") == 0) then
    WriteToLog("SelectCaptureDevice Success\n", "green")
else
    WriteToLog("SelectCaptureDevice failure\n", "red")
end

--DATA CAPTURE CARD API
if (ar1.CaptureCardConfig_EthInit("192.168.33.30", "192.168.33.180", "12:34:56:78:90:12", 4096, 4098) == 0) then
    WriteToLog("CaptureCardConfig_EthInit Success\n", "green")
else
    WriteToLog("CaptureCardConfig_EthInit failure\n", "red")
end

if (ar1.CaptureCardConfig_Mode(1, 1, 1, 2, 3, 30) == 0) then
    WriteToLog("CaptureCardConfig_Mode Success\n", "green")
else
    WriteToLog("CaptureCardConfig_Mode failure\n", "red")
end

if (ar1.CaptureCardConfig_PacketDelay(25) == 0) then
    WriteToLog("CaptureCardConfig_PacketDelay Success\n", "green")
else
    WriteToLog("CaptureCardConfig_PacketDelay failure\n", "red")
end

if((operating_mode == 0) or (operating_mode == 1)) then

    --Start Record ADC data
    ar1.CaptureCardConfig_StartRecord(adc_data_path, 1)
    RSTD.Sleep(2000)
    
    --Trigger frame
    ar1.StartFrame()
    RSTD.Sleep(5000)
    
    --Post process the Capture RAW ADC data
    ar1.StartMatlabPostProc(adc_data_path)
    WriteToLog("Please wait for a few seconds for matlab post processing .....!!!! \n", "green")
    RSTD.Sleep(10000)
    
else --Continuous streaming 

    if(ar1.ContStrConfig(77, 9000, 94, 0, 0, 0, 0, 0, 0, 0, 0) == 0) then
        WriteToLog("ContStrConfig Success\n", "green")
    else
        WriteToLog("ContStrConfig failure\n", "red")
    end
    
    -- Start Continuous streaming of AWR device
    ar1.ContStrModEnable()

    -- Number of samples to capture
    ar1.BasicConfigurationForAnalysis(16384, 16384, 1, 0, 0, 0, 1)
    
    --Start Record continuous data
    ar1.CaptureCardConfig_StartRecord_ContinuousStreamData(adc_data_path, 0)
    RSTD.Sleep(5000)
    
    -- Stop Continuous streaming of AWR device
    ar1.ContStrModDisable()
    
    --Post process the Capture data
    ar1.ProcessContStreamADCData(adc_data_path)
    WriteToLog("Please wait for a few seconds for matlab post processing .....!!!! \n", "green")
    RSTD.Sleep(10000)
end
