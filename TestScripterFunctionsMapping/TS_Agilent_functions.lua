-------------------------------------------//////////////////////////////////////----------------------------
-- SCPI COMMANDS
-------------------------------------------//////////////////////////////////////----------------------------
--int
function Instr_Init (RESOURCE_STR, ACCESS_MODE, LOCK_TIME_OUT, OPT)
	return agilent.Init(RESOURCE_STR, ACCESS_MODE, LOCK_TIME_OUT, OPT);
end
function Instr_Close (POSITION)
	agilent.Close(POSITION);
end

function sendInstrCmd (POSITION, CMD)
	agilent.sendInstrCmd(POSITION, CMD);
end
--string
function readInstrStr (POSITION)
	return agilent.readInstrStr(POSITION);
end
--object 
function readInstrIEEEBlock (POSITION, BIN_TYPE)
	return agilent.readInstrIEEEBlock(POSITION, BIN_TYPE);
end