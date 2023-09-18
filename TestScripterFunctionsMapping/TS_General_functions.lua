-------------------------------------------//////////////////////////////////////----------------------------
-- GENERAL COMMANDS
-------------------------------------------//////////////////////////////////////----------------------------
function WriteToLog(TEXT, COLOR) -- colors :  Red,black, blue, green, yellow, orange, purple   
	if(LOG_DISABLE_GLOBAL == nil) then
		if(LOG_NO_NEW_LINE_GLOBAL == nil) then
			if     COLOR == "red" then
			  RSTD.MessageColor(TEXT, COLORS.red)
			elseif COLOR == "black" then
			  RSTD.MessageColor(TEXT, COLORS.black)
			elseif COLOR == "blue" then
			  RSTD.MessageColor(TEXT, COLORS.blue)
			elseif COLOR == "green" then
			  RSTD.MessageColor(TEXT, COLORS.green)
			elseif COLOR == "yellow" then
			  RSTD.MessageColor(TEXT, COLORS.yellow)
			elseif COLOR == "orange" then
			  RSTD.MessageColor(TEXT, COLORS.orange)
			elseif COLOR == "purple" then
			  RSTD.MessageColor(TEXT, COLORS.purple)
			else--default--
			  RSTD.MessageColor(TEXT, COLORS.black)
			end
		else
			if     COLOR == "red" then
			  RSTD.MessageColorAdvanced(TEXT, COLORS.red)
			elseif COLOR == "black" then
			  RSTD.MessageColorAdvanced(TEXT, COLORS.black)
			elseif COLOR == "blue" then
			  RSTD.MessageColorAdvanced(TEXT, COLORS.blue)
			elseif COLOR == "green" then
			  RSTD.MessageColorAdvanced(TEXT, COLORS.green)
			elseif COLOR == "yellow" then
			  RSTD.MessageColorAdvanced(TEXT, COLORS.yellow)
			elseif COLOR == "orange" then
			  RSTD.MessageColorAdvanced(TEXT, COLORS.orange)
			elseif COLOR == "purple" then
			  RSTD.MessageColorAdvanced(TEXT, COLORS.purple)
			else--default--
			  RSTD.MessageColorAdvanced(TEXT, COLORS.black)
			end
		end
	end
end
-----------------------------------------------------------------------------------------------------
function cls()
	RSTD.ClearOutput()
end
-----------------------------------------------------------------------------------------------------
function p (TIME_MS)
	RSTD.Sleep(TIME_MS);
end
-----------------------------------------------------------------------------------------------------
function msgBox(MESSAGE)
	RSTD.MessageBox(MESSAGE,false)
end
-----------------------------------------------------------------------------------------------------
--bool
function yesNoMsgBox(QUESTION)
	return RSTD.YesNoMsgBox(QUESTION)
end
-----------------------------------------------------------------------------------------------------
--bool
function yesNoTimerMsgBox(TEXT, DEFAULT_ANS, TIME_TO_WAIT)
	return RSTD.YesNoTimerMsgBox(TEXT, DEFAULT_ANS, TIME_TO_WAIT)
end
-----------------------------------------------------------------------------------------------------
--string
function browseForFile()
	return RSTD.BrowseForFile("", "", "")
end
-------------------------------------------//////////////////////////////////////----------------------------
function plot(FIGNUM, X, Y, SERIES_NAME)
	RSTD.Plot("Chart" .. FIGNUM, SERIES_NAME, X, Y)
end

function plotAnotate(FIGNUM, X_AXIS_LABLE, Y_AXIS_LABLE, CHART_TITLE)
	RSTD.PlotAnotate("Chart" .. FIGNUM, X_AXIS_LABLE, Y_AXIS_LABLE, CHART_TITLE)
end
-----------------------------------------------------------------------------------------------------
function clearPlot(FIGNUM)
	RSTD.MessageColor("clearPlot Function Not Supported", COLORS.yellow)
end
-----------------------------------------------------------------------------------------------------
function closePlot(FIGNUM)
	RSTD.MessageColor("closePlot Function Not Supported", COLORS.yellow)
end
-----------------------------------------------------------------------------------------------------
function closeAllPlots()
	RSTD.MessageColor("closeAllPlots Function Not Supported", COLORS.yellow)
end
-----------------------------------------------------------------------------------------------------
function runTextFileScript(FILE_NAME)
	RSTD.MessageColor("runTextFileScript Function Not Supported", COLORS.yellow)
end
-----------------------------------------------------------------------------------------------------
--uint32
function And(ARG1, ARG2)
	return RSTD.bitWiseAnd(ARG1, ARG2)
end
-----------------------------------------------------------------------------------------------------
--uint32
function Or(ARG1, ARG2)
	return RSTD.bitWiseOr(ARG1, ARG2)
end
-----------------------------------------------------------------------------------------------------
--uint32
function Not(ARG1)
	return RSTD.bitWiseNot(ARG1)
end
-----------------------------------------------------------------------------------------------------
function lshift(value, num)
	return (value * 2^num)
end
-----------------------------------------------------------------------------------------------------
function rshift(value, num)
	return (value / 2^num)
end
-----------------------------------------------------------------------------------------------------
function d2h(value)
	if type(value) == "string" then
		value = tonumber(value);
	end
	local hex_val = string.format("0x%X", value);
	return hex_val;
end
-----------------------------------------------------------------------------------------------------
-- Input must be prefixed with 0x
function h2d(value)
	value = tonumber(value, 10);
	return value
end
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------