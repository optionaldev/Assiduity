
------------------------
-- Imports and locals --
------------------------

local CLOAK_REFRESH_TIME = 5
local CLOAK_VISIBLE_MAX  = 0.31
local CLOAK_VISIBLE_MIN  = 0.3

local cloakTimer = CLOAK_REFRESH_TIME   
	
local ShowCloak = ShowCloak
local AssiduityEquipment = CreateFrame( "Frame" )

---------------------
-- Local functions --
---------------------
    
local onUpdate = function(self, elapsed)

    if clockTimer > CLOAK_VISIBLE_MIN and 
       clockTimer < CLOAK_VISIBLE_MAX
    then
        ShowCloak(true)
    end
    
    if clockTimer < 0 then
        ShowCloak(false)
        clockTimer = CLOAK_REFRESH_TIME
    end
    clockTimer = clockTimer - elapsed
end
	
local startCloakFlicker = function()

    AssiduityEquipment:SetScript("OnUpdate", onUpdate)
end

local stopCloakFlicker = function()

    AssiduityEquipment:SetScript("OnUpdate", nil)
    ShowCloak(false)
end

local decideIfShowingHelm = function() 

	if GetInventoryItemID("player",1) == 51149 then
		ShowHelm(true)
	else 
		ShowHelm(false)
	end
end

------------
-- Events --
------------

local PLAYER_ENTERING_WORLD = function()
	decideIfShowingHelm()
end

local UNIT_INVENTORY_CHANGED = function()
	decideIfShowingHelm()
end

do
	local self = AssiduityEquipment
	
	self.PLAYER_ENTERING_WORLD = PLAYER_ENTERING_WORLD
	self.UNIT_INVENTORY_CHANGED = UNIT_INVENTORY_CHANGED
	
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("UNIT_INVENTORY_CHANGED")
	
    self:SetScript( "OnEvent", function( self, event, ... )
        self[event]( self, ... )
    end )
end
	
ShowCloak(false)

--------------------
-- Slash Commands --
--------------------
SLASH_ASSIDUITYEQUIPMENTFLICKER1 = "/assiduitycloakflicker"
SLASH_ASSIDUITYEQUIPMENTFLICKER2 = "/aef"

SlashCmdList["ASSIDUITYEQUIPMENTFLICKER"] = function ( msg )

    if msg == "start" then
        startCloakFlicker()
    
    elseif msg == "stop" then
        stopCloakFlicker()
    else
        print( "Possible commands: start, stop." )
    end
end

