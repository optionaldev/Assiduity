--[[
    
]]

local debug = print
-- local debug = function() end
------------------------
-- Imports and locals --
------------------------
local SaveBindings     = SaveBindings
local SetBinding       = SetBinding
local UnitFactionGroup = UnitFactionGroup

local GetPlayerLocalizedClass = AssiduityGetPlayerLocalizedClass

local BINDS = {
    ["UNBIND"] = {
        --- mouse
        "MOUSEWHEELUP",  "CTRL-MOUSEWHEELUP",  "SHIFT-MOUSEWHEELUP",
        "MOUSEWHEELDOWN","CTRL-MOUSEWHEELDOWN","SHIFT-MOUSEWHEELDOWN",

        "ALT-MOUSEWHEELUP","ALT-MOUSEWHEELDOWN",

        "BUTTON3","CTRL-BUTTON3","SHIFT-BUTTON3","ALT-BUTTON3",
        "BUTTON4","CTRL-BUTTON4","SHIFT-BUTTON4","ALT-BUTTON4",
        "BUTTON5","CTRL-BUTTON5","SHIFT-BUTTON5","ALT-BUTTON5",

        --- keyboard
		"1", "2", "3", "4", "5", "6", "7", "8", "9", "10",
		
        "F1","CTRL-F1",
        "F2","CTRL-F2",
        "F3","CTRL-F3",
        "F4","CTRL-F4",
        "F5","CTRL-F5",
        "F6","CTRL-F6",

        "1","CTRL-1","SHIFT-1","ALT-1",
        "2","CTRL-2","SHIFT-2","ALT-2",
        "3","CTRL-3","SHIFT-3","ALT-3",
        "4","CTRL-4","SHIFT-4","ALT-4",
        "5","CTRL-5","SHIFT-5","ALT-5",
        "6","CTRL-6","SHIFT-6","ALT-6",

        "TAB","CTRL-TAB","SHIFT-TAB","ALT-TAB",

        "Q","CTRL-Q","SHIFT-Q","ALT-Q",
        "E","CTRL-E","SHIFT-E","ALT-E",
        "R","CTRL-R","SHIFT-R","ALT-R",
        "T","CTRL-T","SHIFT-T","ALT-T",
        "Y","CTRL-Y","SHIFT-Y","ALT-Y",
        "U","CTRL-U","SHIFT-U","ALT-U",

        "S","CTRL-S","SHIFT-S","ALT-S",
        "F","CTRL-F","SHIFT-F","ALT-F",
        "G","CTRL-G","SHIFT-G","ALT-G",
        "H","CTRL-H","SHIFT-H","ALT-H",

        "Z","CTRL-Z","SHIFT-Z","ALT-Z",
        "X","CTRL-X","SHIFT-X","ALT-X",
        "C","CTRL-C","SHIFT-C","ALT-C",
        "V","CTRL-V","SHIFT-V","ALT-V",

        "B","CTRL-B","SHIFT-B","ALT-B",
        "N","CTRL-N","SHIFT-N","ALT-N",

        "I", "J", "M",

        "CTRL-SHIFT-SPACE",
        "ALT-CTRL-SPACE"
    },
    ["GLOBAL"] = {
        ["NUMPADPLUS"]  = "MACRO Hide record",

        ["ESCAPE"]      = "TOGGLEGAMEMENU",
        ["PRINTSCREEN"] = "SCREENSHOT",
        ["HOME"]        = "TOGGLEUI",
        ["END"]         = "MACRO reload",

        ["TAB"]       = "MACRO tab",
        ["SHIFT-TAB"] = "OPENALLBAGS",

        ["W"] = "MOVEFORWARD",
        ["`"] = "MOVEBACKWARD",
        ["A"] = "STRAFELEFT",
        ["D"] = "STRAFERIGHT",

        ["ENTER"] = "OPENCHAT",

        ["\\"] = "MACRO \\",
        [","] = "TOGGLEWORLDMAP",
        ["."] = "TOGGLEBATTLEFIELDMINIMAP",

        ["SPACE"]            = "JUMP",
        ["ALT-SPACE"]        = "SITORSTAND",
        ["CTRL-SPACE"]       = "TOGGLESHEATH",

        ["LEFT"]  = "TURNLEFT",
        ["RIGHT"] = "TURNRIGHT",
        ["UP"]    = "CAMERAZOOMIN",
        ["DOWN"]  = "CAMERAZOOMOUT",

        ["1"] = "ACTIONBUTTON1",
        ["2"] = "ACTIONBUTTON2",
        ["3"] = "ACTIONBUTTON3",
        ["4"] = "ACTIONBUTTON4",
        ["5"] = "ACTIONBUTTON5",
		
        ["S"] = "ACTIONBUTTON6",
		
        ["Z"] = "ACTIONBUTTON7",
        ["X"] = "ACTIONBUTTON8",
        ["C"] = "ACTIONBUTTON9",
        ["V"] = "ACTIONBUTTON10",
        ["B"] = "ACTIONBUTTON11",
        ["N"] = "ACTIONBUTTON12",


        ["Q"] = "MACRO q",
        ["E"] = "MACRO e",
        ["R"] = "MACRO r",
        ["T"] = "MACRO t",

        ["F"] = "MACRO f",
        ["G"] = "MACRO g",
        ["H"] = "MACRO h",

        
        ["MOUSEWHEELUP"]   = "MACRO mu",
        ["MOUSEWHEELDOWN"] = "MACRO md",
        
        ["BUTTON3"] = "MACRO m3",
        ["BUTTON4"] = "MACRO m4",
        ["BUTTON5"] = "MACRO m5",
    },
    ["DEATHKNIGHT"] = {},
    ["DRUID"] = {
        ["F1"] = "SPELL Track Humanoids",
        ["F2"] = "SPELL Track Minerals",
        ["F3"] = "SPELL Find Fish"
    },
    ["HUNTER"] = {},
    ["MAGE"] = {},
    ["PALADIN"] = {},
    ["PRIEST"] = {},
    ["ROGUE"] = {},
    ["SHAMAN"] = {},
    ["WARLOCK"] = {},
    ["WARRIOR"] = {}
}

local _, RACE = UnitRace( "player" )

--------------------
-- Slash Commands --
--------------------
SLASH_ASSIDUITYBINDS1 = "/assiduitybinds"
SLASH_ASSIDUITYBINDS2 = "/ab"

SlashCmdList["ASSIDUITYBINDS"] = function ()

	-- Reset bindings because otherwise you will end up with two bindings for one functionality
    for _, key in ipairs( BINDS.UNBIND ) do      
		print("Set binding to nil " .. key)
        SetBinding( key, nil )
    end
    
	-- Handle the bindings that are shared among all characters and accounts
    for key, action in pairs( BINDS.GLOBAL ) do    
		print("Set binding " .. key .. " to " .. action)
        SetBinding( key, action )
    end
    
    -- Character specific binds
    for key, action in pairs( BINDS[ GetPlayerLocalizedClass() ]) do   
		print("Set binding " .. key .. " to " .. action)          
        SetBinding( key, action )
    end
    
    SaveBindings( 2 )
    
    print( "Loaded binds." )
end
