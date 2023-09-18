
for i=1, 100 do
ar1.FullReset()
RSTD.Sleep(100)
ar1.SOPControl(2)
RSTD.Sleep(100)
ar1.Connect(100,921600,1000)
RSTD.Sleep(400)

ar1.DownloadBSSFw("C:\\Users\\a0393390\\Desktop\\ar1xxx_bss.bin")
-- RSTD.Sleep(300)
ar1.DownloadMSSFw("C:\\Users\\a0393390\\Desktop\\ar1xxx_mss.bin")

ar1.PowerOn(0, 0, 0, 0)
ar1.RfEnable()

-- static config
ar1.ChanNAdcConfig(1, 1, 0, 1, 1, 1, 1, 2, 2, 0)
ar1.LPModConfig(0, 0)
ar1.RfInit()

-- Data Config
ar1.DataPathConfig(1, 0, 0)
ar1.LvdsClkConfig(1, 0)
ar1.LVDSLaneConfig(0, 1, 1, 1, 1, 1, 0, 0)

-- sensor config
ar1.ProfileConfig(0, 77, 100, 6, 60, 0, 0, 0, 0, 0, 0, 30, 1, 256, 10000, 0, 0, 30)
ar1.ChirpConfig(0, 0, 0, 0, 0, 0, 0, 1, 1, 0)
ar1.FrameConfig(0, 0, 0, 8, 2, 0)
ar1.StartFrame()
ar1.StopFrame()
end
