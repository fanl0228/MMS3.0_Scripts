local debugging = false
local rttt_package = "V15"

RTTT = RSTD

function Load_AR1x_Client(automation_mode)
	local al_path
	local client_path
	local client_gui_path
	local registers_xml
	local ts18_controller_path
	local ocla_cc3100_controller_path
	local acmb_controller_path
	local bs_gui_controller_path
	
	AR1_GUI = true
	
	-- Set paths for AL and client DLLs
	ar1x_controller_path = RSTD_PATH .. "\\Clients\\AR1xController\\AR1xController.dll"

	
	registers_xml = RSTD_PATH .. "\\Clients\\AR1xController\\AR1x_Registers.xml"
	al_path = RSTD_PATH .. "\\RunTime\\SAL.dll"	
	client_path = RSTD_PATH .. "\\Clients\\\\LabClient.dll"
		

	client_gui_path = ""
		
	-- Unbuild a previous build
	RSTD.UnBuild()
	
	--RSTD.UnRegisterDll(ar1x_controller_path)
	
	--RSTD.RegisterDll("C:\\Program Files (x86)\\Texas Instruments\\RadarStudio\\Clients\\HSDCPRO\\Lua_CS_HSDCPro.dll")

	
	-- Set the AL and Clients to build
	RSTD.SetClientDll(al_path, client_path, client_gui_path, 0)

	-- Get updated variables values automatically for the wlan GUI
	RSTD.SetVar ("/Settings/AutoUpdate/Enabled" , "TRUE")
	RSTD.SetVar ("/Settings/AutoUpdate/Interval" , "1")
	
	-- Set if to update monitored variables display in the BrowseTree
	RSTD.SetVar ("/Settings/Monitors/UpdateDisplay" , "TRUE")

	-- Set to have a click on MonitorStart/MonitorStop in GUI automatically call GO/Stop
	RSTD.SetVar ("/Settings/Monitors/OneClickStart" , "TRUE")
	
	RSTD.SetVar ("/Settings/Automation/Automation Mode" , tostring(automation_mode))

	RSTD.Transmit("/")
	
	RSTD.SaveClientSettings()
	
	-- Run the TestScripter mapping functions
	dofile(RSTD_PATH .. "\\Scripts\\TestScripter_Mapping.lua")
    dofile(RSTD_PATH .. "\\Scripts\\AR1x\\BinDecHex.lua")
    dofile(RSTD_PATH .. "\\Scripts\\AR1x\\lib_math.lua")

	-- Build the HAL_WL (Trioscope DLL wrapper) and load the Trioscope DLL
	
	RSTD.Build()

	RSTD.RegisterDllEx(ar1x_controller_path, false)

	RSTD.SetExternalAL(ar1x_controller_path)		
					
	
	--RSTD.SetVersion("ar1: " .. RSTD.GetDllVersion(ar1x_controller_path))

	
	-- Load the register mapping
	RSTD.LoadExpose(registers_xml)
	
	dofile(RSTD_PATH .. "\\Scripts\\ar1.lua")


	ar1.ShowGui()		


end


