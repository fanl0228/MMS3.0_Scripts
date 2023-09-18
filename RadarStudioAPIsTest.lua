--Start
WriteToLog("LUA Script for System Check\n", "blue")
RSTD.Sleep(1000)

if (0 == ar1.SOPControl(2)) then
    WriteToLog("SOP Reset Success\n", "green")
else
    WriteToLog("SOP Reset Failure\n", "red")
end

RSTD.Sleep(1000)

if (0 == ar1.Connect(24,921600,1000)) then
    WriteToLog("RS232 Connect Success\n", "green")
else
    WriteToLog("RS232 Connect Failure\n", "red")
end

RSTD.Sleep(1000)

if (ar1.DownloadBSSFw("\\\\ar04\\c$\\WakeUp_SW\\Firmware\\BSS_1.0.0.16\\ar1xxx_bss.bin")) then
    WriteToLog("BSS FW Download Success\n", "green")
else
    WriteToLog("BSS FW Download Failure\n", "red")
end

RSTD.Sleep(1000)

if (0 == ar1.DownloadMSSFw("\\\\ar04\\c$\\WakeUp_SW\\Firmware\\MSS_1.0.0.13\\ar1xxx_mss.bin")) then
    WriteToLog("MSS FW Download Success\n", "green")
else
    WriteToLog("MSS FW Download Failure\n", "red")
end

RSTD.Sleep(1000)

if (0 == ar1.PowerOn(0, 0, 0, 0)) then
    WriteToLog("PowerOn Success\n", "green")
else
    WriteToLog("PowerOn Failure\n", "red")
    session:destroy();
end

RSTD.Sleep(1000)

if (0 == ar1.RfEnable()) then
    WriteToLog("RfEnable Success\n", "green")
else
    WriteToLog("RfEnable Failure\n", "red")
end

RSTD.Sleep(1000)


if (0 == ar1.ChanNAdcConfig(1, 1, 0, 1, 1, 1, 1, 2, 1, 0)) then
    WriteToLog("ChanNAdcConfig Success\n", "green")
else
    WriteToLog("ChanNAdcConfig Failure\n", "red")
end

RSTD.Sleep(1000)

if (0 == ar1.LPModConfig(0, 0)) then
    WriteToLog("LowPowerConfig Success\n", "green")
else
    WriteToLog("LowPowerConfig Failure\n", "red")
end

RSTD.Sleep(1000)

if (0 == ar1.RfInit()) then
    WriteToLog("RfInit Success\n", "green")
else
    WriteToLog("RfInit Failure\n", "red")
end

RSTD.Sleep(1000)

if (0 == ar1.DataPathConfig(1, 0, 0)) then
    WriteToLog("DataPathConfig Success\n", "green")
else
    WriteToLog("DataPathConfig Failure\n", "red")
end

RSTD.Sleep(1000)

if (0 == ar1.LvdsClkConfig(1, 0)) then
    WriteToLog("LvdsClkConfig Success\n", "green")
else
    WriteToLog("LvdsClkConfig Failure\n", "red")
end

RSTD.Sleep(1000)

if (0 == ar1.LVDSLaneConfig(0, 1, 1, 1, 1, 1, 0, 0, 0)) then
    WriteToLog("LVDSLaneConfig Success\n", "green")
else
    WriteToLog("LVDSLaneConfig Failure\n", "red")
end

if (0 == ar1.ProfileConfig(0, 76, 100, 3, 60, 0, 0, 0, 0, 0, 0, 30, 1, 256, 10000, 0, 0, 30)) then
    WriteToLog("ProfileConfig Success\n", "green")
else
    WriteToLog("ProfileConfig Failure\n", "red")
end

RSTD.Sleep(1000)

if (0 == ar1.ChirpConfig(0, 0, 0, 0, 0, 0, 0, 1, 1, 0)) then
    WriteToLog("ChirpConfig Success\n", "green")
else
    WriteToLog("ChirpConfig Failure\n", "red")
end

RSTD.Sleep(1000)

if (0 == ar1.SetTestSource(4, 3, 0, 0, 0, 0, -327, 0, -327, 327, 327, 327, -2, 327, 327, 0, 0, 0, 0, -327, 0, -327, 327, 327, 327, -237, 0, 0, 4, 0, 8, 0, 12, 0, 0, 0, 0, 0, 0, 0)) then
    WriteToLog("SetTestSource Success\n", "green")
else
    WriteToLog("SetTestSource Failure\n", "red")
end

RSTD.Sleep(1000)

if (0 == ar1.EnableTestSource(1)) then
    WriteToLog("EnableTestSource Success\n", "green")
else
    WriteToLog("EnableTestSource Failure\n", "red")
end

RSTD.Sleep(1000)

if (0 == ar1.FrameConfig(0, 0, 0, 8, 2, 0)) then
    WriteToLog("FrameConfig Success\n", "green")
else
    WriteToLog("FrameConfig Failure\n", "red")
end

RSTD.Sleep(1000)

-- Start Frame (Trigger Frame)
ar1.StartFrame()
RSTD.Sleep(3000)

-- Stop Frame 
ar1.StopFrame()
RSTD.Sleep(3000)

WriteToLog("Closing test\n", "blue")
RSTD.Sleep(2000)
WriteToLog("Doing Power-off\n", "green")
ar1.PowerOff()
RSTD.Sleep(3000)

