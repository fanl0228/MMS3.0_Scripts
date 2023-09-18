--[[
Function Name 	: RunHciCommand
Description		: Sends the required HCI command to DUT via Hci Tester and waits for the set event.
Input 			: command - the HCI command ; event - the HCI matching event
Output  		: bool - success status
Example 		: RunHciCommand("Send_HCI_VS_Read_Memory 0xFF02, 0x00191000, 4", 
								"Wait_HCI_Command_Complete_VS_Read_Memory_Event 5000, any, HCI_VS_Read_Memory, 0x00, Any")
]]--
function RunHciCommand(command, event)
	local func_string
	
	command = string.gsub(command, "\"", "\\\"")
	
	if ((event == nil) or (event == "")) then
		func_string = string.format("/HAL6450/HCI/Functions/Send Command to HCI(\"%s\")", command)
	else
		event = string.gsub(event, "\"", "\\\"")
		func_string = string.format("/HAL6450/HCI/Functions/Send Command to HCI(\"%s\n%s\")", command, event)
	end
	
	local res = RSTD.RunFunction(func_string)
	
	return (res == "TRUE")
end

--[[
Function Name 	: RunHciScript
Description		: Runs the given script in the HCITester
Input 			: hci_script - the script to run
Output  		: bool - success status
Example 		: RunHciScript("D:\\00\\HciTester_scripts\\test2.txt")
]]--
function RunHciScript(hci_script)
	local func_path = "/HAL6450/HCI/Functions/Run HCI Script Remotely"
	local func_str = string.format("%s(\"%s\")", func_path, hci_script)
	local res = RSTD.RunFunction(func_str)

	return (res == "TRUE")
end

