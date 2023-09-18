-- This example showcases the usage of Advanced chirp configuration
-- It captures the ADC data using DCA1000.
-- The user is expected to change the configuration according to specific use-cases.

--BSS and MSS firmware download
info = debug.getinfo(1,'S');
file_path = (info.source);
file_path = string.gsub(file_path, "@","");
file_path = string.gsub(file_path, "Advanced_Chirp_Example.lua","");
fw_path   = file_path.."..\\..\\rf_eval_firmware"

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

-- ==========  Local variables ==========
local STATIC_CFG = {}
local SENSOR_CFG = {}
-- Watch dog timer - 0:Disable WDT, 1:Enable WDT
STATIC_CFG.EN_WDT                           = 1
-- Interburst Power Save - 0: Disable, 1: Enable
STATIC_CFG.DIS_POWER_SAVE                   = 0
-- Profile Config for x2xx Devices
SENSOR_CFG.PROFILE_CONFIG = {}
SENSOR_CFG.PROFILE_CONFIG.START_FREQ_0      = 77        -- GHz
SENSOR_CFG.PROFILE_CONFIG.START_FREQ_1      = 76.024    -- GHz
SENSOR_CFG.PROFILE_CONFIG.START_FREQ_2      = 76.5      -- GHz
SENSOR_CFG.PROFILE_CONFIG.START_FREQ_3      = 76.5      -- GHz
SENSOR_CFG.PROFILE_CONFIG.IDLE_TIME_0       = 10         -- us
SENSOR_CFG.PROFILE_CONFIG.IDLE_TIME_1       = 3         -- us
SENSOR_CFG.PROFILE_CONFIG.IDLE_TIME_2       = 3         -- us
SENSOR_CFG.PROFILE_CONFIG.IDLE_TIME_3       = 3         -- us
SENSOR_CFG.PROFILE_CONFIG.ADC_START         = 3         -- us
SENSOR_CFG.PROFILE_CONFIG.RAMP_END          = 15        -- us
SENSOR_CFG.PROFILE_CONFIG.SLOPE_0           = 29.982    -- MHz/us
SENSOR_CFG.PROFILE_CONFIG.SLOPE_1           = 29.982    -- MHz/us
SENSOR_CFG.PROFILE_CONFIG.SLOPE_2           = 0         -- MHz/us
SENSOR_CFG.PROFILE_CONFIG.SLOPE_3           = 0         -- MHz/us
SENSOR_CFG.PROFILE_CONFIG.TX_START          = 0         -- us
SENSOR_CFG.PROFILE_CONFIG.NUM_SAMPLES       = 256
SENSOR_CFG.PROFILE_CONFIG.ADC_RATE          = 40000     -- MHz
SENSOR_CFG.PROFILE_CONFIG.HPF_1             = 0
SENSOR_CFG.PROFILE_CONFIG.HPF_2             = 0
SENSOR_CFG.PROFILE_CONFIG.RX_GAIN           = 30
-- Advanced Frame Config
SENSOR_CFG.ADV_FRAME_CONFIG = {}
SENSOR_CFG.ADV_FRAME_CONFIG.NUM_SUB_FRAMES = 4
SENSOR_CFG.ADV_FRAME_CONFIG.NUM_FRAMES = 10
SENSOR_CFG.ADV_FRAME_CONFIG.SUB_FRAME_PERIOD = 75 -- Used only for delay calculation

local apiReturn

----------------- API Calls start here ---------------------------

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

-- SPI connect
apiReturn = ar1.PowerOn(0, 1000, 0, 0)
if (0 ~= apiReturn) then
    WriteToLog("FAIL : SPI Connection Failed\n", "red")
    test_result = 1
end
RSTD.Sleep(100)

--RF Power UP
apiReturn = ar1.RfEnable()
if (apiReturn ~= 0) then
    WriteToLog("FAIL : BSS PowerOn Failed\n","red")
    test_result = 1
end
RSTD.Sleep(500)

apiReturn = ar1.ChanNAdcConfig(1, 1, 1, 1, 1, 1, 1, 0, 3, 0)
if (0 ~= apiReturn) then
    WriteToLog("FAIL : Channel cfg Failed\n","red")
    test_result = 1
end

if (0 ~= ar1.RfLdoBypassConfig(0x3)) then
    WriteToLog("FAIL : LDO bypass Failed\n","red")
    test_result = 1
end

if (0 ~= ar1.LPModConfig(0, 0)) then
    WriteToLog("FAIL : Low power mode Failed\n","red")
    test_result = 1
end

if (0 ~= ar1.RfInit()) then
    WriteToLog("FAIL : RfInit failed\n", "red")
    test_result = 1
end
RSTD.Sleep(1000)

if (0 ~= ar1.SetRFDeviceConfig(5, 0, STATIC_CFG.DIS_POWER_SAVE, STATIC_CFG.EN_WDT, 0, 0, 0)) then
    WriteToLog("FAIL : Static cfg Failed\n","red")
    test_result = 1
end

if (0 ~= ar1.DataPathConfig(513, 1216644097, 0)) then
    WriteToLog("FAIL : Data path cfg Failed\n","red")
    test_result = 1
end

if (0 ~= ar1.LvdsClkConfig(1, 1)) then
    WriteToLog("FAIL : LVDS Clk cfg Failed\n","red")
    test_result = 1
end

if (0 ~= ar1.LVDSLaneConfig(0, 1, 1, 1, 1, 1, 0, 0)) then
    WriteToLog("FAIL : LVDS Lane cfg Failed\n","red")
    test_result = 1
end

-- Profile Config
if (0 ~= ar1.ProfileConfig(0, SENSOR_CFG.PROFILE_CONFIG.START_FREQ_0, SENSOR_CFG.PROFILE_CONFIG.IDLE_TIME_0,
    SENSOR_CFG.PROFILE_CONFIG.ADC_START, SENSOR_CFG.PROFILE_CONFIG.RAMP_END, 0, 0, 0, 0, 0, 0, SENSOR_CFG.PROFILE_CONFIG.SLOPE_0,
    SENSOR_CFG.PROFILE_CONFIG.TX_START, SENSOR_CFG.PROFILE_CONFIG.NUM_SAMPLES, SENSOR_CFG.PROFILE_CONFIG.ADC_RATE,
    SENSOR_CFG.PROFILE_CONFIG.HPF_1, SENSOR_CFG.PROFILE_CONFIG.HPF_2, SENSOR_CFG.PROFILE_CONFIG.RX_GAIN)) then
    WriteToLog("FAIL : Profile cfg Failed\n","red")
    test_result = 1
end

--=====================================================================
function AdvChirpConfig()
    local apiReturn
    local test_result = 0
    -- Enable Advance Chirp
    apiReturn = ar1.SetMiscConfig(1, 1, 0, 0)
    if (0 ~= apiReturn) then
        WriteToLog("FAIL : Radar Misc cfg Failed\n", "red")
        test_result = 1
    end
    apiReturn = ar1.ClearAdvChirpLUTConfig()
    if (0 ~= apiReturn) then
        WriteToLog("FAIL : ClearAdvChirpLUTConfig cfg Failed\n","red")
        test_result = 1
    end
    apiReturn = ar1.SetProfileAdvChirpConfigLUT(0, 4, 0, 0, 0, 0)
    if (0 ~= apiReturn) then
        WriteToLog("FAIL : Adv Chirp Profile LUT cfg Failed\n","red")
        test_result = 1
    end
    apiReturn = ar1.SetStartFreqAdvChirpConfigLUT(16, 4, 0, 0, 0, 0.01, 0.02, 0.03)
    if (0 ~= apiReturn) then
        WriteToLog("FAIL : Adv Chirp Start Freq LUT cfg Failed\n","red")
        test_result = 1
    end
    apiReturn = ar1.SetTxEnAdvChirpConfigLUT(32, 4, 3, 7, 3, 7)
    if (0 ~= apiReturn) then
        WriteToLog("FAIL : Adv Chirp TX LUT cfg Failed\n","red")
        test_result = 1
    end
    apiReturn = ar1.SetTx0PhShiftAdvChirpConfigLUT(48, 4, 5.625, 11.25, 16.875, 22.5)
    if (0 ~= apiReturn) then
        WriteToLog("FAIL : ADV Chirp Tx0 PhShifter LUT cfg Failed\n","red")
        test_result = 1
    end
    apiReturn = ar1.AdvChirpLUTConfig(0, 64)
    if (0 ~= apiReturn) then
        WriteToLog("FAIL : Adv Chirp LUT transfer Failed\n","red")
        test_result = 1
    end

    local paramIndex

    -- Profile
    paramIndex = 0
    apiReturn = ar1.AdvChirpConfig(0, 0, 0, 0, 0, 0, 0, 0, 4, 1, 0,  4, 0, 0, 0, 0, 0)
    if (apiReturn ~= 0) then
        local reportString = string.format("FAIL : Advanced Chirp Config %d Failed with %d\n",paramIndex, apiReturn)
        WriteToLog(reportString,"red")
        test_result = 1
    end
    -- Start Frequency
    paramIndex = 1
    apiReturn = ar1.AdvChirpConfig(1, 0, 8, 1, 18641, 18641, 18641, 18641, 4, 1, 16, 4, 0, 0, 0, 0, 0)
    if (apiReturn ~= 0) then
        local reportString = string.format("FAIL : Advanced Chirp Config %d Failed with %d\n",paramIndex, apiReturn)
        WriteToLog(reportString,"red")
        test_result = 1
    end
    -- Slope
    paramIndex = 2
    apiReturn = ar1.AdvChirpConfig(2, 0, 0, 0, 0, 0, 0, 0, 4, 1, 0,  4, 0, 0, 0, 0, 0)
    if (apiReturn ~= 0) then
        local reportString = string.format("FAIL : Advanced Chirp Config %d Failed with %d\n",paramIndex, apiReturn)
        WriteToLog(reportString,"red")
        test_result = 1
    end
    -- Idle Time
    paramIndex = 3
    apiReturn = ar1.AdvChirpConfig(3, 0, 0, 0, 0, 0, 0, 0, 4, 1, 0,  4, 0, 0, 0, 0, 0)
    if (apiReturn ~= 0) then
        local reportString = string.format("FAIL : Advanced Chirp Config %d Failed with %d\n",paramIndex, apiReturn)
        WriteToLog(reportString,"red")
        test_result = 1
    end
    -- ADC Start
    paramIndex = 4
    apiReturn = ar1.AdvChirpConfig(4, 0, 0, 0, 0, 0, 0, 0, 4, 1, 0,  4, 0, 0, 0, 0, 0)
    if (apiReturn ~= 0) then
        local reportString = string.format("FAIL : Advanced Chirp Config %d Failed with %d\n",paramIndex, apiReturn)
        WriteToLog(reportString,"red")
        test_result = 1
    end
    -- TX Enable
    paramIndex = 5
    apiReturn = ar1.AdvChirpConfig(5, 0, 0, 0, 0, 0, 0, 0, 4, 1, 32, 4, 0, 0, 0, 0, 0)
    if (apiReturn ~= 0) then
        local reportString = string.format("FAIL : Advanced Chirp Config %d Failed with %d\n",paramIndex, apiReturn)
        WriteToLog(reportString,"red")
        test_result = 1
    end
    -- BPM
    paramIndex = 6
    apiReturn = ar1.AdvChirpConfig(6, 0, 0, 0, 0, 0, 0, 0, 4, 1, 0,  4, 0, 0, 0, 0, 0)
    if (apiReturn ~= 0) then
        local reportString = string.format("FAIL : Advanced Chirp Config %d Failed with %d\n",paramIndex, apiReturn)
        WriteToLog(reportString,"red")
        test_result = 1
    end
    -- Phase Shifter 1
    paramIndex = 7
    apiReturn = ar1.AdvChirpConfig(7, 0, 0, 0, 0, 0, 0, 0, 4, 1, 48,  4, 0, 0, 0, 0, 0)
    if (apiReturn ~= 0) then
        local reportString = string.format("FAIL : Advanced Chirp Config %d Failed with %d\n",paramIndex, apiReturn)
        WriteToLog(reportString,"red")
        test_result = 1
    end
    -- Phase Shifter 2
    paramIndex = 8
    apiReturn = ar1.AdvChirpConfig(8, 0, 0, 0, 0, 0, 0, 0, 4, 1, 48,  4, 0, 0, 0, 0, 0)
    if (apiReturn ~= 0) then
        local reportString = string.format("FAIL : Advanced Chirp Config %d Failed with %d\n",paramIndex, apiReturn)
        WriteToLog(reportString,"red")
        test_result = 1
    end
    -- Phase Shifter 3
    paramIndex = 9
    apiReturn = ar1.AdvChirpConfig(9, 0, 0, 0, 0, 0, 0, 0, 4, 1, 48,  4, 0, 0, 0, 0, 0)
    if (apiReturn ~= 0) then
        local reportString = string.format("FAIL : Advanced Chirp Config %d Failed with %d\n",paramIndex, apiReturn)
        WriteToLog(reportString,"red")
        test_result = 1
    end
    return test_result
end


-- Advanced Chirp Config
if (0 ~= AdvChirpConfig(TEST_INPUT)) then
    WriteToLog("FAIL : Adv Chirp cfg Failed\n","red")
    test_result = 1
end

-- Advanced Frame Config
    -- chirpStartIdx = 0
    -- chirpEndIdx = 0
    -- numLoops = 96
    -- numFrames = 520
    -- burstPeriodicity = 2.7ms
    -- triggerSelect = 1 (SW Trigger)
    -- frameTriggerDelay = 0
    -- Num of subframes = 4
    -- Num of bursts = 10
    -- num of burst loops  = 2
    -- Subframe period = 54.045ms (for each 4 subframes)
res = ar1.AdvanceFrameConfig(SENSOR_CFG.ADV_FRAME_CONFIG.NUM_SUB_FRAMES, 1536, 0, 0, 1, 96, 540000, 0, 10, 2, 10809000, 0, 0, 1, 96, 540000, 0,10, 2, 10809000, 0, 0, 1, 96, 540000, 0, 10, 2, 10809000, 0, 0, 1, 96,540000, 0, 10, 2, 22000000, SENSOR_CFG.ADV_FRAME_CONFIG.NUM_FRAMES, 1, 0, 4, 1920, 256, 1, 1920, 256, 1, 1920,256, 1, 1920, 256, 1)
if (0 ~= res) then
    WriteToLog("FAIL : Adv Frame cfg Failed\n","red")
    test_result = 1
end

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

--Start Record ADC data
ar1.CaptureCardConfig_StartRecord(adc_data_path, 1)
RSTD.Sleep(2000)

--Trigger frame
if (0 ~= ar1.StartFrame()) then
    WriteToLog("FAIL : Frame start cfg Failed\n","red")
    test_result = 1
end
local frameDelay = SENSOR_CFG.ADV_FRAME_CONFIG.NUM_FRAMES * SENSOR_CFG.ADV_FRAME_CONFIG.NUM_SUB_FRAMES * SENSOR_CFG.ADV_FRAME_CONFIG.SUB_FRAME_PERIOD + 4000
RSTD.Sleep(frameDelay)

--Post process the Capture RAW ADC data
ar1.StartMatlabPostProc(adc_data_path)
WriteToLog("Please wait for a few seconds for matlab post processing .....!!!! \n", "green")
RSTD.Sleep(10000)
