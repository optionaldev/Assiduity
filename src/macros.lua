--[[
    
]]

local debug = print
-- local debug = function() end
------------------------
-- Imports and locals --
------------------------
local EditMacro = EditMacro

--------------------
-- Slash Commands --
--------------------
SLASH_ASSIDUITYMACROS1 = "/assiduitymacros"
SLASH_ASSIDUITYMACROS2 = "/am"

SlashCmdList["ASSIDUITYMACROS"] = function(message)
	
	if message == "pve" then
		EditMacro("z", nil, nil, "/use [@mouseover,exists,nomod][nomod] Rejuvenation; [@mouseover,exists,mod][mod] Regrowth")
		EditMacro("x", nil, nil, "/use [@mouseover,exists,nomod][nomod] Lifebloom; [@mouseover,exists,mod][mod] Nourish")
		EditMacro("q", nil, nil, "/use [nomod,spec:1] Typhoon; [@mouseover,exists,nomod,spec:2][nomod,spec:2] Wild Growth")
		EditMacro("r", nil, nil, "/use [@mouseover,exists,nomod][nomod][@mouseover,exists,mod:alt][mod:alt] Remove Curse; [mod:ctrl] Mark of the Wild; [mod:shift] Gift of the Wild")
		EditMacro("t", nil, nil, "/use [@mouseover,exists,nomod][nomod][mod:alt] Abolish Poison; [@mouseover,exists,mod:ctrl][@mouseover,exists,mod:shift][mod:ctrl][mod:shift] Thorns")
		print("PVE macros have been set.")
	elseif message == "pvp" then
		EditMacro("z", nil, nil, "/use [nomod] Rejuvenation; [mod] Regrowth")
		EditMacro("x", nil, nil, "/use [nomod] Lifebloom; [mod] Nourish")
		EditMacro("q", nil, nil, "/use [nomod,spec:1] Typhoon; [nomod,spec:2] Wild Growth")
		EditMacro("r", nil, nil, "/use [nomod][mod:alt] Remove Curse; [mod:ctrl] Mark of the Wild; [mod:shift] Gift of the Wild")
		EditMacro("t", nil, nil, "/use [nomod][mod:alt] Abolish Poison; [mod:ctrl][mod:shift] Thorns")
		print("PVP macros have been set.")
	else 
		print("Available commands for /assiduitymacros or /am:")
		print("")
		print("/am pve")
		print("Sets bindings specific for pve (lots of mouseovers).")
		print("")
		print("/am pvp")
		print("Sets bindings specific for pvp (removes unnecessary mouseovers).")
		print("")
	end
end
