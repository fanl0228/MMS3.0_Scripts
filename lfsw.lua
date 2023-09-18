--------------------------------------------------------------------------------------------------------------------------------
--[[			lfsw.lua 								                      	
		Goal - Wrapper for the lfs (Lua File System) module
--]]
--------------------------------------------------------------------------------------------------------------------------------

require "lfs"

-------------------------[[Module Declaratrion]]-------------------------
lfsw = lfsw or {}

-------------------------------[[Private]]-------------------------------


-------------------------------[[Public]]--------------------------------
--[[
Function Name 	: dir
Description		: Gets a list of all files & directories in a given path
Input 			: A full path
Output  		: A table containing paths of all files & directories in the given path
Example 		: t = lfsw("c:\\00\\")
]]--
function lfsw.dir (path)
	local t = {}
    for file in lfs.dir(path) do
        if file ~= "." and file ~= ".." then
            local f = path..'\\'..file
			
            --local attr = lfs.attributes (f)
			
            --if attr.mode ~= "directory" then
			table.insert(t,f)				
			--end
        end
    end
	
	return t;
end
