
-- Frame configuration
local start_chirp_tx          =   0
local end_chirp_tx            =   11
local nchirp_loops            =   64               -- Number of chirps per frame
local nframes_master          =   1000             -- Number of Frames for Master
local nframes_slave           =   1000             -- Number of Frames for Slaves
local Inter_Frame_Interval    =   100              -- ms
local trigger_delay           =   0                -- us
local trig_list               =   {1,2,2,2}        -- 1: Software trigger, 2: Hardware trigger

-- devices for which the monitoring should be enabled
device_map                    =   15
-- Calibration Monitoring Time Unit
-- FTTI periodicity = Frame Periodicity * cal_mon_unit
cal_mon_unit                  =   4
-- Number of devices in active operation
num_devices                   =   4
-- Calibration periodicity multiplication factor.
-- Calibration periodicity = FTTI periodicity * calib_mult_factor
calib_mult_factor             =   4

stop_frame_mode               =   0                 -- 0: Frame boundary, 2: Sub-frame boundary, 
                                                    -- 3: Burst boundary, 4: HW/Sub-frame triggered

-- Function to start/stop frame
function Framing_Control(Device_ID, En1_Dis0)
    local status = 0         
    if (En1_Dis0 == 1) then 
        status = ar1.StartFrame_mult(dev_list[Device_ID]) --Start Trigger Frame
        if(status == 0) then
            WriteToLog("Device "..Device_ID.." : Start Frame Successful\n", "green")
        else
            WriteToLog("Device "..Device_ID.." : Start Frame Failed\n", "red")
            return -5
        end
    else
        status = ar1.StopFrame_mult(dev_list[Device_ID], stop_frame_mode) --Stop Trigger Frame
        if(status == 0) then
            WriteToLog("Device "..Device_ID.." : Stop Frame Successful\n", "green")
        else
            WriteToLog("Device "..Device_ID.." : Stop Frame Failed\n", "red")
            return -5
        end
    end
       
    return status
end

-- Frame Configuration
-- Master
if (0 == ar1.FrameConfig_mult(1, start_chirp_tx, end_chirp_tx, nframes_master, nchirp_loops, 
         Inter_Frame_Interval, trigger_delay, trig_list[1])) then
    WriteToLog("Master : Frame Configuration successful\n", "green")
else
    WriteToLog("Master : Frame Configuration failed\n", "red")
end
-- Slaves 
if (0 == ar1.FrameConfig_mult(14, start_chirp_tx, end_chirp_tx, nframes_slave, nchirp_loops, 
         Inter_Frame_Interval, trigger_delay, trig_list[2])) then
    WriteToLog("Slaves : Frame Configuration successful\n", "green")
else
    WriteToLog("Slaves : Frame Configuration failed\n", "red")
end

-------------------------------------------------------------------------------------------------

-- Logging of monitoring async events in Output console
-- 1: Disable, 0: Enable
ar1.DisableMonitoringLogging(1)

--[[
Calibration Time Unit Configuration
The API is of the format ar1.SetCalMonTimeUnitConfig_mult(device_map, cal_mon_unit, num_devices, device_id, monitor_mode)
1. cal_mon_unit = time unit as the period over which the monitors are cyclically executed
2. num_devices = number of devices active in the system
3. device_id = If same value is used for all devices (say 0), the monitoring reports from all devices 
will be sent out at the same time (will come in parallel). If values are different, 
for example device_id = 0, 1, 2 and 3 are set for the devices 1, 2, 3 and 4 respectively, 
then the reports are sent one after the other
4. monitor_mode = to control execution of monitoring types. If set to zero, then it is default
case - autonomous monitoring trigger. If set to 1, then it is API based monitoring trigger (controlled by host)
--]]
ar1.SetCalMonTimeUnitConfig_mult(1, cal_mon_unit, num_devices, 0, 0)
ar1.SetCalMonTimeUnitConfig_mult(2, cal_mon_unit, num_devices, 1, 0)
ar1.SetCalMonTimeUnitConfig_mult(4, cal_mon_unit, num_devices, 2, 0)
ar1.SetCalMonTimeUnitConfig_mult(8, cal_mon_unit, num_devices, 3, 0)

-- Run time Calibration Configuration
-- Calibration reports to be sent out every calibration periodicity
--ar1.RunTimeCalibConfTrig_mult(device_map, 1, 1, 1, 1, 1, 1, 1, 1, calib_mult_factor, 1, 0, 1, 1, 1, 0, 0, 0)

-- Analog Global Monitors Enable
ar1.SetRfAnaMonConfig_mult(device_map, 0x4F07FFF, 0x0)

------------------------------------ ANALOG MONITORS ---------------------------------

-- Temperature
ar1.SetRfTempMonConfig_mult(device_map, 0, -40, 135, -40, 135, 30)

-- Rx Gain Phase
ar1.SetRfRxGainPhMonConfig_mult(device_map, 0, 1, 1, 1 , 0, 0, 50, 50, 50, 100, 0, 
              0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)

-- Rx Noise 
ar1.SetRfRxNoiseMonConfig_mult(device_map, 0, 1, 1, 1, 0, 30)

-- Rx IF Stage
ar1.SetRfRxIfStageMonConfig_mult(device_map, 0, 0, 20, 2.7, 3, 3)

-- Tx Power
ar1.SetRfTx0PowMonConfig_mult(device_map, 0, 1, 1, 1, 0, 3, 3)
ar1.SetRfTx1PowMonConfig_mult(device_map, 0, 1, 1, 1, 0, 3, 3)
ar1.SetRfTx2PowMonConfig_mult(device_map, 0, 1, 1, 1, 0, 3, 3)

-- Tx Ball Break
ar1.SetRfTx0BallbreakMonConfig_mult(device_map, 0, -6)
ar1.SetRfTx1BallbreakMonConfig_mult(device_map, 0, -6)
ar1.SetRfTx2BallbreakMonConfig_mult(device_map, 0, -6)

-- Tx Phase shifter
ar1.SetRfTx0PhShiftMonConfig_mult(device_map, 0, 0, 7, 3, 7, 0, 5.625, 11.25, 16.875, 0, 0, 0, 0, 10, 2)
ar1.SetRfTx1PhShiftMonConfig_mult(device_map, 0, 0, 7, 3, 7, 0, 5.625, 11.25, 16.875, 0, 0, 0, 0, 10, 2)
ar1.SetRfTx2PhShiftMonConfig_mult(device_map, 0, 0, 7, 3, 7, 0, 5.625, 11.25, 16.875, 0, 0, 0, 0, 10, 2)

-- Tx Gain Phase Mismatch
ar1.SetRfTxGainPhaseMismatchMonConfig_mult(device_map, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0,
                       10, 60, 0, 0, -5, 0, 0, -5, 0, 0, -5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)

-- Synth Freq
ar1.SetRfSynthFreqMonConfig_mult(device_map, 0, 0, 4000, 25, 0, 0, 1)

-- RX Mixer Input Power
ar1.SetRfMixerInpPowMonConfig_mult(device_map, 0, 0, 1, 1, 0, 115212288)

---------------------- DC BIST MONITORS ------------------------------

-- Internal PMCLKO Signals
ar1.SetRfPmClkLoIntAnaSignalsMonConfig_mult(device_map, 0, 0)

-- Internal GPADC Signals
ar1.SetRfGpadcIntAnaSignalsMonConfig_mult(device_map, 0)

-- PLL Control Voltage
ar1.SetRfPllContrlVoltMonConfig_mult(device_map, 0, 1, 1, 1)

-- Dual Clock Comparator
ar1.SetRfDualClkCompMonConfig_mult(device_map, 0, 1, 1, 1, 1, 1, 1)

--------------------- DIGITAL MONITORS --------------------------------

-- Digital Periodic
--ar1.SetRfDigMonPeriodicConfig_mult(device_map, 1, 0, 0xD, 0)
--RSTD.Sleep(1000)

--------------------- MSS MONITORS -----------------------------------

-- Device Periodic Test
--ar1.DevicePeriodicTestsConfig_mult(device_map, 150, 0x3, 2, 0)
--RSTD.Sleep(1000)

---------------------------------------------------------------------------------------------

framing_time                    =   102000                           -- ms
framing_type                    =   1                                -- 0: infinite, 1: finite
      
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

RSTD.Sleep(framing_time)
    
if(framing_type == 0) then
        
    -- Stop capturing
    WriteToLog("Starting Frame Stop sequence...\n", "blue")
    if (RadarDevice[4]==1)then
        Framing_Control(4,0)
    end
    
    if (RadarDevice[3]==1)then
        Framing_Control(3,0)
    end
    
    if (RadarDevice[2]==1)then
        Framing_Control(2,0)
    end
    
    Framing_Control(1,0)
end

WriteToLog("Capture sequence completed...\n", "blue")