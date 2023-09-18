local debugging = false
local RSTD_package = "V14"

-- Options for WLAN Register mapping
DUT_VER = {WLAN_1273 = 1, WLAN_1283 = 2, WLAN_1381 = 3, WLAN_18xx = 4, WLAN_19xx = 5}

--[[
Function for loading the Wlan Client
Input:
	TrioscopeDLL	 - The Trioscope dll full path
	Dut_Ver 		 - The Wlan DUT (1273,1283,1381)
	Load_GUI_Client  - Load the GUI client or not
	automation_mode  - Is automation mode on/off
]]--
function Load_WLAN_Client(TrioscopeDLL, dut_version, Load_GUI_Client, automation_mode)
	local al_path
	local client_path
	local client_gui_path
	local registers_xml
	local ts18_controller_path
	local ocla_controller_path
	local ocla_wl9_controller_path
	local ocla_cc3100_controller_path
	
	-- Set paths for AL and client DLLs
	if (debugging == true) then
		
		if (dut_version == DUT_VER.WLAN_1273) then
			registers_xml = RSTD_PATH .. "\\Clients\\RegisterMapping\\WLAN_1273_registers.xml"
			al_path       = RSTD_PATH .. "\\..\\..\\InfrastructureExport\\Debug\\HAL_WL_1273.dll"
		elseif(dut_version == DUT_VER.WLAN_1283) then
			registers_xml = RSTD_PATH .. "\\Clients\\RegisterMapping\\WLAN_1283_registers.xml"
		    al_path       = RSTD_PATH .. "\\..\\..\\InfrastructureExport\\Debug\\HAL_WL.dll"
		elseif(dut_version == DUT_VER.WLAN_1381) then
			registers_xml = RSTD_PATH .. "\\Clients\\RegisterMapping\\WLAN_1381_registers.xml"
			al_path = RSTD_PATH .. "\\..\\..\\InfrastructureExport\\Debug\\HAL_WL.dll"
		elseif(dut_version == DUT_VER.WLAN_18xx) then
            if (REG_MAP_PG_VER < 2) then
                registers_xml = RSTD_PATH .. "\\Clients\\RegisterMapping\\WLAN_18xx_registers.xml"
            else
                registers_xml = RSTD_PATH .. "\\Clients\\RegisterMapping\\WLAN_18xx_registers_PG2.xml"
            end
			al_path = RSTD_PATH .. "\\..\\..\\InfrastructureExport\\Debug\\SAL.dll"	
		else
			registers_xml = RSTD_PATH .. "\\Clients\\RegisterMapping\\WLAN_19xx_registers.xml"			
			al_path = RSTD_PATH .. "\\..\\..\\InfrastructureExport\\Debug\\SAL.dll"			
		end
		
		client_path = RSTD_PATH .. "\\..\\..\\Lab\\LabClient\\Release\\LabClient.dll"
		
		ts18_controller_path = RSTD_PATH .. "\\..\\..\\Utils\\TrioScopeController\\TrioScopeController\\bin\\Debug\\TrioScopeController.dll"			
		ts19_controller_path = RSTD_PATH .. "\\..\\..\\Utils\\Ts19xxController\\Ts19xxController\\bin\\Debug\\Ts19xxController.dll"
		gt_controller_path = RSTD_PATH .. "\\Clients\\GlobalsTools\\PhyGlobalsTool.dll"
		gtm_controller_path = RSTD_PATH .. "\\Clients\\GlobalsTools\\MacGlobalsTool.dll"
        ocla_controller_path = RSTD_PATH .. "\\..\\..\\Utils\\OCLATool\\OCLATool\\bin\\Debug\\OCLATool.exe"
		ocla_wl9_controller_path = RSTD_PATH .. "\\..\\..\\Utils\\Ocla_wl9\\Ocla_wl9\\bin\\Debug\\Ocla_wl9.exe"
        ocla_cc3100_controller_path = RSTD_PATH .. "\\..\\..\\Utils\\Ocla_cc3100\\Ocla_cc3100\\bin\\Debug\\Ocla_cc3100.exe"      

		if (    (Load_GUI_Client == false) 
			 or (dut_version == DUT_VER.WLAN_18xx) 
			 or (dut_version == DUT_VER.WLAN_19xx)
			) then
			client_gui_path = ""
		else
			client_gui_path = RSTD_PATH .. "\\..\\..\\Lab\\WlanFwGui\\WlanFwGui\\bin\\Release\\WlanFwGui.dll"
		end	
		
	else	
		if (dut_version == DUT_VER.WLAN_1273) then
			registers_xml = RSTD_PATH .. "\\Clients\\RegisterMapping\\WLAN_1273_registers.xml"
			al_path       = RSTD_PATH .. "\\RunTime\\HAL_WL_1273.dll"
		elseif(dut_version == DUT_VER.WLAN_1283) then
			registers_xml = RSTD_PATH .. "\\Clients\\RegisterMapping\\WLAN_1283_registers.xml"
			al_path       = RSTD_PATH .. "\\RunTime\\HAL_WL.dll"
		elseif(dut_version == DUT_VER.WLAN_1381) then
			registers_xml = RSTD_PATH .. "\\Clients\\RegisterMapping\\WLAN_1381_registers.xml"
			al_path = RSTD_PATH .. "\\RunTime\\HAL_WL.dll"
		elseif(dut_version == DUT_VER.WLAN_18xx) then
            if (REG_MAP_PG_VER < 2) then
                registers_xml = RSTD_PATH .. "\\Clients\\RegisterMapping\\WLAN_18xx_registers.xml"
            else
                registers_xml = RSTD_PATH .. "\\Clients\\RegisterMapping\\WLAN_18xx_registers_PG2.xml"
            end                
			al_path = RSTD_PATH .. "\\RunTime\\SAL.dll"		
		else
			registers_xml = RSTD_PATH .. "\\Clients\\RegisterMapping\\WLAN_19xx_registers.xml"			
			al_path = RSTD_PATH .. "\\RunTime\\SAL.dll"		
		end
		
		client_path = RSTD_PATH .. "\\Clients\\\\LabClient.dll"
		
		ts18_controller_path = RSTD_PATH .. "\\Clients\\TrioScope\\18xx\\TrioScopeController.dll"
		ts19_controller_path = RSTD_PATH .. "\\Clients\\TrioScope\\19xx\\Ts19xxController.dll"
		gt_controller_path = RSTD_PATH .. "\\Clients\\GlobalsTools\\PhyGlobalsTool.dll"
		gtm_controller_path = RSTD_PATH .. "\\Clients\\GlobalsTools\\MacGlobalsTool.dll"
		ocla_controller_path = RSTD_PATH .. "\\Clients\\OCLA\\OCLATool.exe"
		ocla_wl9_controller_path = RSTD_PATH .. "\\Clients\\Ocla_wl9\\Ocla_wl9.exe"
		ocla_cc3100_controller_path = RSTD_PATH .. "\\Clients\\Ocla_cc3100\\Ocla_cc3100.exe"
		
		if (    (Load_GUI_Client == false) 
			 or (dut_version == DUT_VER.WLAN_18xx) 
			 or (dut_version == DUT_VER.WLAN_19xx)
			) then
			client_gui_path = ""
		else
			client_gui_path = RSTD_PATH .. "\\Clients\\WlanFwGui.dll"	
		end
	end

	-- Unbuild a previous build
	RSTD.UnBuild()
	
	RSTD.UnRegisterDll(gtm_controller_path)
	RSTD.UnRegisterDll(gt_controller_path)	
	RSTD.UnRegisterDll(ocla_controller_path)
	RSTD.UnRegisterDll(ocla_wl9_controller_path)
	RSTD.UnRegisterDll(ocla_cc3100_controller_path)
	RSTD.UnRegisterDll(ts18_controller_path)
	RSTD.UnRegisterDll(ts19_controller_path)
	
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

	-- Build the HAL_WL (Trioscope DLL wrapper) and load the Trioscope DLL
	if (dut_version == DUT_VER.WLAN_18xx) then
		RSTD.Build()
		RSTD.RegisterDllEx(ocla_controller_path, false)
		RSTD.RegisterDllEx(gt_controller_path, false)
		RSTD.RegisterDllEx(gtm_controller_path, false)
		RSTD.RegisterDllEx(ts18_controller_path, false)
		RSTD.SetExternalAL(ts18_controller_path)		
						
		-- Load the Trioscope Dll
		ts18.LoadTsDll(TrioscopeDLL)
		
		RSTD.SetVersion(RSTD_package .. " || ts18: " .. RSTD.GetDllVersion(ts18_controller_path) .. 
				" || ocla: " .. RSTD.GetDllVersion(ocla_controller_path))
		
		-- Load the register mapping
		RSTD.LoadExpose(registers_xml)
		
		dofile(RSTD_PATH .. "\\Scripts\\18xx\\wlan\\ts18.lua")
		dofile(RSTD_PATH .. "\\Scripts\\18xx\\wlan\\ts18gui.lua")
		dofile(RSTD_PATH .. "\\Scripts\\18xx\\wlan\\TS_mapping_for_18xx.lua")
		
		if (Load_GUI_Client == true) then
			gt.ShowGui()
			gt.LoadXml(GT_XML_PATH)
			gtm.ShowGui()
			gtm.LoadXml(GTM_XML_PATH)
			ts18.ShowGui()		
		end
	elseif (dut_version == DUT_VER.WLAN_19xx) then
		RSTD.Build()
		RSTD.RegisterDllEx(ocla_wl9_controller_path, false)
		RSTD.RegisterDllEx(gt_controller_path, false)
		RSTD.RegisterDllEx(ts19_controller_path, false)
		RSTD.SetExternalAL(ts19_controller_path)
							
		-- Load the Trioscope Dll
		ts19.LoadTsDll(TrioscopeDLL)
		
		RSTD.SetVersion(RSTD_package .. " || ts19: " .. RSTD.GetDllVersion(ts19_controller_path) .. 
				" || ocla_wl9: " .. RSTD.GetDllVersion(ocla_wl9_controller_path))
		
		-- Load the register mapping
		RSTD.LoadExpose(registers_xml)
		
		dofile(RSTD_PATH .. "\\Scripts\\19xx\\wlan\\ts19.lua")
		dofile(RSTD_PATH .. "\\Scripts\\19xx\\wlan\\ts19gui.lua")
		dofile(RSTD_PATH .. "\\Scripts\\19xx\\wlan\\TS_mapping_for_19xx.lua")
		
		if (Load_GUI_Client == true) then
			gt.ShowGui()
			gt.LoadXml(GT_XML_PATH)
			ts19.ShowGui()		
		end
	else
		RSTD.RunFunction("/Settings/Methods/AL Build()")
		RSTD.SetAndTransmit ("/Global Settings/Settings/TrioScope.dll path" , TrioscopeDLL)
		RSTD.RunFunction("/Settings/Methods/AL Init()")
		RSTD.RegisterDllEx(ocla_cc3100_controller_path, false)
		local trioscope_dll_loaded = RSTD.Receive("/Global Settings/Settings/TrioScopeDllLoaded")

		if (trioscope_dll_loaded == "TRUE") then
			RSTD.RunFunction("/Settings/Methods/AL Reset()")		
			RSTD.RunFunction("/Settings/Methods/Clients Build()") -- Load the Register mapping
			RSTD.LoadExpose(registers_xml)
		else
			RSTD.RunFunction("/Settings/Methods/AL UnBuild()") -- Rollback
		end
	end
end

function Load_18xx_reg_map()
	local al_path
	local client_path
	local client_gui_path
	local registers_xml

	if (debugging == true) then
		al_path = RSTD_PATH .. "\\..\\..\\InfrastructureExport\\Debug\\SAL.dll"
		client_path = RSTD_PATH .. "\\..\\..\\Lab\\LabClient\\Release\\LabClient.dll"
		client_gui_path = ""
	else
		al_path = RSTD_PATH .. "\\RunTime\\SAL.dll"
		client_path = RSTD_PATH .. "\\Clients\\\\LabClient.dll"
		client_gui_path = ""
	end
    
    if (REG_MAP_PG_VER == 1) then
        registers_xml = RSTD_PATH .. "\\Clients\\RegisterMapping\\WLAN_18xx_registers.xml"
    else
        registers_xml = RSTD_PATH .. "\\Clients\\RegisterMapping\\WLAN_18xx_registers_PG2.xml"
    end	
	
	-- Unbuild a previous build
	RSTD.UnBuild()

	-- Set the AL and Clients to build
	RSTD.SetClientDll(al_path, client_path, client_gui_path, 0)	
	RSTD.Transmit("/")	
	RSTD.SaveClientSettings()
	
	RSTD.Build()
	
	RSTD.LoadExpose(registers_xml)
end

function Load_19xx_reg_map()
    local al_path
    local client_path
    local client_gui_path
    local registers_xml

    if (debugging == true) then
        al_path = RSTD_PATH .. "\\..\\..\\InfrastructureExport\\Debug\\SAL.dll"
        client_path = RSTD_PATH .. "\\..\\..\\Lab\\LabClient\\Release\\LabClient.dll"
        client_gui_path = ""
    else
        al_path = RSTD_PATH .. "\\RunTime\\SAL.dll"
        client_path = RSTD_PATH .. "\\Clients\\\\LabClient.dll"
        client_gui_path = ""
    end

    registers_xml = RSTD_PATH .. "\\Clients\\RegisterMapping\\WLAN_19xx_registers.xml"
    
    -- Unbuild a previous build
    RSTD.UnBuild()

    -- Set the AL and Clients to build
    RSTD.SetClientDll(al_path, client_path, client_gui_path, 0) 
    RSTD.Transmit("/")          
    RSTD.SaveClientSettings()
    
    RSTD.Build()
    
    RSTD.LoadExpose(registers_xml)
end

--[[
Function for loading the BT Client
Input:
	hci_connection_params - An hci_connection_params struct holding info sent to the HCI Tester
	automation_mode 	  - Is automation mode on/off
]]--
function Load_BT_Client(hci_connection_params, automation_mode, registers_xml)
	--local debugging = false -- for internal use
	local al_path
	local client_path

	if (registers_xml == nil) then
		registers_xml = RSTD_PATH .. "\\Clients\\RegisterMapping\\BT_65nm_registers.xml"
	end
	if(NFC_MODE == nil) then
		NFC_MODE = false
	end
	
	-- Disable autoupdate
	RSTD.SetAndTransmit ("/Settings/AutoUpdate/Enabled" , "FALSE")
	
	if (CLEARCASE_VIEW_PATH ~= nil) then
		RSTD_PATH = CLEARCASE_VIEW_PATH .. "\\m_Grid\\LabTools\\RSTD" -- For backwards compatibility
	end

	if (debugging) then
		al_path     = RSTD_PATH .. "\\..\\..\\..\\m_Grid\\InfrastructureExport\\Debug\\HAL_6450.dll"
		client_path = RSTD_PATH .. "\\..\\..\\Lab\\LabClient\\Release\\LabClient.dll"
	else
		al_path     = RSTD_PATH .. "\\RunTime\\HAL_6450.dll"
		client_path = RSTD_PATH .. "\\Clients\\LabClient.dll"
	end
	
	RSTD.UnBuild()
	
	RSTD.SetVersion(RSTD_package)
				
	RSTD.SetClientDll(al_path, client_path, "", 0)

	-- Set if to update monitored variables display in the BrowseTree
	RSTD.SetVar ("/Settings/Monitors/UpdateDisplay" , "TRUE")

	-- Set to have a click on MonitorStart/MonitorStop in GUI automatically call GO/Stop
	RSTD.SetVar ("/Settings/Monitors/OneClickStart" , "TRUE")
	
	RSTD.SetVar ("/Settings/Automation/Automation Mode" , tostring(automation_mode))

	RSTD.Transmit("/")
	
	RSTD.SaveClientSettings()

	RSTD.RunFunction("/Settings/Methods/AL Build()")

	RSTD.SetVar ("/HAL6450/HCI/Settings/IP Port" 				           , hci_connection_params.IP_PORT		   				)
	RSTD.SetVar ("/HAL6450/HCI/Settings/Keep Alive" 				       , hci_connection_params.KEEP_ALIVE    		   		)
	RSTD.SetVar ("/HAL6450/HCI/Settings/IPType" 				           , hci_connection_params.IP_TYPE				   		)
	RSTD.SetVar ("/HAL6450/HCI/Settings/IP Address" 				       , hci_connection_params.IP_ADDRESS			   		)
	RSTD.SetVar ("/HAL6450/HCI/Settings/Use Ascii"                         , hci_connection_params.ASCII                        )

	RSTD.SetVar ("/HAL6450/HCI/Settings/COM Port Number" 				   , hci_connection_params.COM_PORT_NUMBER		   		)
	RSTD.SetVar ("/HAL6450/HCI/Settings/Port Type" 						   , hci_connection_params.PORT_TYPE				   	)
	RSTD.SetVar ("/HAL6450/HCI/Settings/Flow Control Type" 				   , hci_connection_params.FLOW_CONTROL_TYPE		   	)
	RSTD.SetVar ("/HAL6450/HCI/Settings/Boud Rate" 						   , hci_connection_params.BAUD_RATE				   	)
	RSTD.SetVar ("/HAL6450/HCI/Settings/Port Sleep Type" 				   , hci_connection_params.PORT_SLEEP_TYPE		   		)
	RSTD.SetVar ("/HAL6450/HCI/Settings/Three Wire Sliding Window"         , hci_connection_params.THREE_WIRE_SLIDING_WINDOW 	)
	RSTD.SetVar ("/HAL6450/HCI/Settings/RTS on EOP"                        , hci_connection_params.RTS_ON_EOP				   	)
	RSTD.SetVar ("/HAL6450/HCI/Settings/Data Integrity"                    , hci_connection_params.DATA_INTEGRITY			   	)
	RSTD.SetVar ("/HAL6450/HCI/Settings/Port Buffers"                      , hci_connection_params.PORT_BUFFERS			   		)
	RSTD.SetVar ("/HAL6450/HCI/Settings/Three Wire Flow Control"  		   , hci_connection_params.THREE_WIRE_FLOW_CONTROL   	)
	RSTD.SetVar ("/HAL6450/HCI/Settings/16Bit Alignment"                   , hci_connection_params._16BIT_ALIGNMENT		   		)
	RSTD.SetVar ("/HAL6450/HCI/Settings/Full HCI EXE Path" 			       , hci_connection_params.FULL_HCI_EXE_PATH		   	)
	RSTD.SetVar ("/HAL6450/HCI/Settings/Full HCI XML Script Path" 		   , hci_connection_params.FULL_HCI_XML_SCRIPT_PATH  	)
	RSTD.SetVar ("/HAL6450/HCI/Settings/HCI visible mode" 				   , hci_connection_params.HCI_VISIBLE_MODE		   		)
	RSTD.SetVar ("/HAL6450/HCI/Settings/Additional params"                 , hci_connection_params.ADDITIONAL_PARAMS            )

	RSTD.Transmit("/")

	RSTD.RunFunction("/Settings/Methods/AL Init()")
	RSTD.RunFunction("/Settings/Methods/AL Reset()")
	RSTD.RunFunction("/Settings/Methods/Clients Build()")
	
	RSTD.LoadExpose(registers_xml)
	
	RSTD.SetAndTransmit ("/HAL6450/Global Settings/Initial Wait For HCI Status Update" , "3000")
	if(NFC_MODE == true) then
		RSTD.SetAndTransmit ("/NFC/Configuration/NFC Test Chip" , "1")
	end

	dofile(RSTD_PATH .. "\\Scripts\\BT_Lab_Functions.lua")
end

--[[
Function for Setting WL client
--]]
function Set_WL_Client(client_name)
	if (client_name == "WLAN_1273") then return 1
	elseif(client_name == "WLAN_1283")then return 2
	elseif(client_name == "WLAN_1381")then return 3
	elseif(client_name == "WLAN_18xx")then return 4
	elseif(client_name == "WLAN_19xx")then return 5
	else return 0
	end
end

function Load_18xx_Clients(TrioscopeDLL, hci_connection_params, bt_reg_xml, automation_mode)

	-------------------------------[[ WLAN ]]-------------------------------
	local al_path
	local client_path
	local wlan_reg_xml
	local ts18_controller_path
	local ocla_controller_path
	local gt_controller_path
	local gtm_controller_path
	
	-- Set paths for AL and client DLLs
	if (debugging == true) then	
		wlan_reg_xml = RSTD_PATH .. "\\Clients\\RegisterMapping\\CoEx\\WLAN_18xx_registers.xml"
		ts18_controller_path = RSTD_PATH .. "\\..\\..\\Utils\\TrioScopeController\\TrioScopeController\\bin\\Debug\\TrioScopeController.dll"			
		ocla_controller_path = RSTD_PATH .. "\\Clients\\OCLA\\OCLATool.exe"        
		gt_controller_path = RSTD_PATH .. "\\Clients\\GlobalsTools\\PhyGlobalsTool.dll"
		gtm_controller_path = RSTD_PATH .. "\\Clients\\GlobalsTools\\MacGlobalsTool.dll"
	else	
		wlan_reg_xml = RSTD_PATH .. "\\Clients\\RegisterMapping\\CoEx\\WLAN_18xx_registers.xml"			
		ts18_controller_path = RSTD_PATH .. "\\Clients\\TrioScope\\18xx\\TrioScopeController.dll"
		ocla_controller_path = RSTD_PATH .. "\\Clients\\OCLA\\OCLATool.exe"
		gt_controller_path = RSTD_PATH .. "\\Clients\\GlobalsTools\\PhyGlobalsTool.dll"
		gtm_controller_path = RSTD_PATH .. "\\Clients\\GlobalsTools\\MacGlobalsTool.dll"
	end

	-- Unbuild a previous build
	RSTD.UnBuild()
	
	RSTD.UnRegisterDll(gtm_controller_path)
	RSTD.UnRegisterDll(gt_controller_path)	
	RSTD.UnRegisterDll(ocla_controller_path)
	RSTD.UnRegisterDll(ts18_controller_path)
	
	-- Run the TestScripter mapping functions
	dofile(RSTD_PATH .. "\\Scripts\\TestScripter_Mapping.lua")

	-- Load the Wlan DLLs
	RSTD.RegisterDllEx(ocla_controller_path, false)
	RSTD.RegisterDllEx(gt_controller_path, false)
	RSTD.RegisterDllEx(gtm_controller_path, false)
	RSTD.RegisterDllEx(ts18_controller_path, false)
	RSTD.SetExternalAL(ts18_controller_path)	
					
	-- Load the Trioscope Dll
	ts18.LoadTsDll(TrioscopeDLL)
	
	RSTD.SetVersion(RSTD_package .. " || ts18: " .. RSTD.GetDllVersion(ts18_controller_path) .. 
					" || ocla: " .. RSTD.GetDllVersion(ocla_controller_path))
	
	dofile(RSTD_PATH .. "\\Scripts\\18xx\\wlan\\ts18.lua")
	dofile(RSTD_PATH .. "\\Scripts\\18xx\\wlan\\ts18gui.lua")
	dofile(RSTD_PATH .. "\\Scripts\\18xx\\wlan\\TS_mapping_for_18xx.lua")
	
	gt.ShowGui()
	gt.LoadXml(GT_XML_PATH)
	gtm.ShowGui()
	gtm.LoadXml(GTM_XML_PATH)
	ts18.ShowGui()
	
	-------------------------------[[ BT ]]-------------------------------
	if (bt_reg_xml == nil) then
		bt_reg_xml = RSTD_PATH .. "\\Clients\\RegisterMapping\\CoEx\\BT_45nm_registers.xml"
	end
	if(NFC_MODE == nil) then
		NFC_MODE = false
	end
	
	-- Disable autoupdate
	RSTD.SetAndTransmit ("/Settings/AutoUpdate/Enabled" , "FALSE")
	
	if (debugging) then
		al_path     = RSTD_PATH .. "\\..\\..\\..\\m_Grid\\InfrastructureExport\\Debug\\HAL_6450.dll"
		client_path = RSTD_PATH .. "\\..\\..\\Lab\\LabClient\\Release\\LabClient.dll"
	else
		al_path     = RSTD_PATH .. "\\RunTime\\HAL_6450.dll"
		client_path = RSTD_PATH .. "\\Clients\\LabClient.dll"
	end
	
	RSTD.SetClientDll(al_path, client_path, "", 0)	

	-- Set if to update monitored variables display in the BrowseTree
	RSTD.SetVar ("/Settings/Monitors/UpdateDisplay" , "TRUE")

	-- Set to have a click on MonitorStart/MonitorStop in GUI automatically call GO/Stop
	RSTD.SetVar ("/Settings/Monitors/OneClickStart" , "TRUE")
	
	RSTD.SetVar ("/Settings/Automation/Automation Mode" , tostring(automation_mode))

	RSTD.Transmit("/Settings")
	
	RSTD.SaveClientSettings()

	RSTD.RunFunction("/Settings/Methods/AL Build()")

	RSTD.SetVar ("/HAL6450/HCI/Settings/COM Port Number" 				   , hci_connection_params.COM_PORT_NUMBER		   		)
	RSTD.SetVar ("/HAL6450/HCI/Settings/Port Type" 						   , hci_connection_params.PORT_TYPE				   	)
	RSTD.SetVar ("/HAL6450/HCI/Settings/Flow Control Type" 				   , hci_connection_params.FLOW_CONTROL_TYPE		   	)
	RSTD.SetVar ("/HAL6450/HCI/Settings/Boud Rate" 						   , hci_connection_params.BAUD_RATE				   	)
	RSTD.SetVar ("/HAL6450/HCI/Settings/Port Sleep Type" 				   , hci_connection_params.PORT_SLEEP_TYPE		   		)
	RSTD.SetVar ("/HAL6450/HCI/Settings/Three Wire Sliding Window"         , hci_connection_params.THREE_WIRE_SLIDING_WINDOW 	)
	RSTD.SetVar ("/HAL6450/HCI/Settings/RTS on EOP"                        , hci_connection_params.RTS_ON_EOP				   	)
	RSTD.SetVar ("/HAL6450/HCI/Settings/Data Integrity"                    , hci_connection_params.DATA_INTEGRITY			   	)
	RSTD.SetVar ("/HAL6450/HCI/Settings/Port Buffers"                      , hci_connection_params.PORT_BUFFERS			   		)
	RSTD.SetVar ("/HAL6450/HCI/Settings/Three Wire Flow Control"  		   , hci_connection_params.THREE_WIRE_FLOW_CONTROL   	)
	RSTD.SetVar ("/HAL6450/HCI/Settings/16Bit Alignment"                   , hci_connection_params._16BIT_ALIGNMENT		   		)
	RSTD.SetVar ("/HAL6450/HCI/Settings/Full HCI EXE Path" 			       , hci_connection_params.FULL_HCI_EXE_PATH		   	)
	RSTD.SetVar ("/HAL6450/HCI/Settings/Full HCI XML Script Path" 		   , hci_connection_params.FULL_HCI_XML_SCRIPT_PATH  	)
	RSTD.SetVar ("/HAL6450/HCI/Settings/HCI visible mode" 				   , hci_connection_params.HCI_VISIBLE_MODE		   		)
	RSTD.SetVar ("/HAL6450/HCI/Settings/Additional params"                 , hci_connection_params.ADDITIONAL_PARAMS            )

	RSTD.Transmit("/HAL6450/HCI/Settings")

	RSTD.RunFunction("/Settings/Methods/AL Init()")
	RSTD.RunFunction("/Settings/Methods/AL Reset()")
	RSTD.RunFunction("/Settings/Methods/Clients Build()")
	
	-- Load the WLAN register mapping
	RSTD.LoadExpose(wlan_reg_xml)

	-- Load the BT register mapping
	RSTD.LoadExpose(bt_reg_xml)
	
	RSTD.SetAndTransmit ("/HAL6450/Global Settings/Initial Wait For HCI Status Update" , "3000")
	if(NFC_MODE == true) then
		RSTD.SetAndTransmit ("/NFC/Configuration/NFC Test Chip" , "1")
	end

	dofile(RSTD_PATH .. "\\Scripts\\BT_Lab_Functions.lua")
end
