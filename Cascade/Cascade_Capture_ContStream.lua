--[[
    A. STREAMING & CAPTURE
    1. Streaming Slave (3, 2, 1) sequentially.
    2. Streaming Master.
    
    B. TRANSFERRING FILES
    1. The data is stored in file(s) with max cap placed at 2 GB.
    2. The files can be retrieved from the SSD (/mnt/ssd folder) using WinSCP.

Note: Update lines 18 to 66 as needed before using this script.
    
--]]

---------------------------   Streaming Configuration -------------------------------------------
-- Change the values below as needed.

-- Streaming configuration
local start_freq                =   77               -- GHz
local sample_freq               =   9000             -- ksps
local rx_gain                   =   30               -- dB
local tx0OutPowerBackoffCode    =   0
local tx1OutPowerBackoffCode    =   0
local tx2OutPowerBackoffCode    =   0
local tx0PhaseShifter           =   0
local tx1PhaseShifter           =   0
local tx2PhaseShifter           =   0
local hpfCornerFreq1            =   0                -- 0: 175KHz, 1: 235KHz, 2: 350KHz, 3: 700KHz
local hpfCornerFreq2            =   0                -- 0: 350KHz, 1: 700KHz, 2: 1.4MHz, 3: 2.8MHz

-- Basic configuration for Analysis
local numSamples                =   524288

-- Streaming Configuration
if (0 == ar1.ContStrConfig_mult(deviceMapOverall, start_freq, sample_freq, rx_gain, hpfCornerFreq1,
         hpfCornerFreq2, tx0OutPowerBackoffCode, tx1OutPowerBackoffCode, tx2OutPowerBackoffCode, 
         tx0PhaseShifter, tx1PhaseShifter, tx2PhaseShifter)) then
    WriteToLog("Streaming Configuration successful\n", "green")
else
    WriteToLog("Streaming Configuration failed\n", "red")
    return -4
end

-- Note: "capture_time"  is a timeout till which the devices are streaming continuously.
-- It does not affect the amount of data/samples being captured by the TDA2XX.
-- Data captured by TDA2XX depends on the number of samples being programmed at line 31

capture_time                    =    2000                             -- ms
inter_loop_time                 =    2000                             -- ms
num_loops                       =    1

--[[
Note: 
Change the parameter as desired:
1. capture_directory: is the filename under which captures are stored on the SSD
   and is also the directory to which files will be transferred back to the host
   The captures are copied to the PostProc folder within mmWave Studio.
Note: 
If this script is called multiple times without changing the directory name, then all 
captured files will be in the same directory with filename suffixes incremented automatically. 
It may be hard to know which captured files correspond to which run of the script.
Note: 
It is strongly recommended to change this directory name between captures.
--]]
------------------------------DATA CAPTURE------------------------------
-- Function to start/stop Streaming 
function Streaming_Control(Device_ID, En1_Dis0)
    local status = 0         
        if (En1_Dis0 == 1) then 
            status = ar1.ContStrModEnable_mult(dev_list[Device_ID]) --Start Streaming
            if (status == 0) then
                WriteToLog("Device "..Device_ID.." : Start Streaming Successful\n", "green")
            else
                WriteToLog("Device "..Device_ID.." : Start Streaming Failed\n", "red")
                return -5
            end
        else
            status = ar1.ContStrModDisable_mult(dev_list[Device_ID]) --Stop Streaming
            if (status == 0) then
                WriteToLog("Device "..Device_ID.." : Stop Streaming Successful\n", "green")
            else
                WriteToLog("Device "..Device_ID.." : Stop Streaming Failed\n", "red")
                return -5
            end
        end
    
    return status
end


while (num_loops > 0)
do

WriteToLog("Loops Remaining : "..num_loops.."\n", "purple")    

-- Start Streaming
WriteToLog("Starting Streaming Start sequence...\n", "blue")

if (RadarDevice[4]==1)then
    Streaming_Control(4,1)
end

if (RadarDevice[3]==1)then
    Streaming_Control(3,1)
end

if (RadarDevice[2]==1)then
    Streaming_Control(2,1)
end

Streaming_Control(1,1)

RSTD.Sleep(1000)

-- Basic Configuration for Analysis
if (0 == ar1.BasicConfigurationForAnalysis(numSamples, numSamples, 1, 0, 0, 0, 1)) then
    WriteToLog("Basic Configuration for Analysis successful\n", "green")
else
    WriteToLog("Basic Configuration for Analysis failed\n", "red")
    return -4
end

RSTD.Sleep(1000)

-- TDA ARM
capture_directory               =   "Cascade_22xx_Cont_Stream_Capture_"..num_loops.."_iteration" 
WriteToLog("Starting TDA ARM for Cont Stream...\n", "blue")
status = ar1.TDAContStream_StartRecord_mult(15, capture_directory)
if (status == 0) then
    WriteToLog("TDA ARM for Cont Stream Successful\n", "green")
else
    WriteToLog("TDA ARM for Cont Stream Failed\n", "red")
    return -5
end

WriteToLog("Capturing AWR device data to the TDA SSD...\n", "blue")
RSTD.Sleep(capture_time)
    
-- Stop Streaming
WriteToLog("Starting Streaming Stop sequence...\n", "blue")
if (RadarDevice[4]==1)then
    Streaming_Control(4,0)
end

if (RadarDevice[3]==1)then
    Streaming_Control(3,0)
end

if (RadarDevice[2]==1)then
    Streaming_Control(2,0)
end

Streaming_Control(1,0)

WriteToLog("Capture sequence completed...\n", "blue")
    
num_loops = num_loops - 1
RSTD.Sleep(inter_loop_time)

end

-- Enable the below if required
WriteToLog("Starting Transfer files using WinSCP for Cont Stream..\n", "blue")
status = ar1.TransferFilesUsingWinSCPContStream_mult(1)
if(status == 0) then
    WriteToLog("Transferred files! COMPLETE!\n", "green")
else
    WriteToLog("Transferring files FAILED!\n", "red")
    return -5
end  
