
------------------------
-- Imports and locals --
------------------------

local CLOAK_REFRESH_TIME = 0.2
local CLOAK_VISIBLE_MAX  = 0.31
local CLOAK_VISIBLE_MIN  = 0.1

local clockTimer = CLOAK_REFRESH_TIME   
	
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

local UNIT_INVENTORY_CHANGED = function()
	decideIfShowingHelm()
end

local PLAYER_ENTERING_WORLD = function(self)

	self:UnregisterEvent("PLAYER_ENTERING_WORLD")

	if UnitName("player") == "Talons" then
		self.UNIT_INVENTORY_CHANGED = UNIT_INVENTORY_CHANGED
		self:RegisterEvent("UNIT_INVENTORY_CHANGED")
		decideIfShowingHelm()
	end
end

do
	local self = AssiduityEquipment
	
	self.PLAYER_ENTERING_WORLD = PLAYER_ENTERING_WORLD
	
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	
    self:SetScript( "OnEvent", function( self, event, ... )
        self[event]( self, ... )
    end )
end
	
ShowCloak(false)

--------------------
-- Slash Commands --
--------------------
SLASH_ASSIDUITYEQUIPMENT1 = "/assiduityequipment"
SLASH_ASSIDUITYEQUIPMENT2 = "/ae"

SlashCmdList["ASSIDUITYEQUIPMENT"] = function ( msg )

    if msg == "start" then
        startCloakFlicker()
    
    elseif msg == "stop" then
        stopCloakFlicker()
    else
        print( "Possible commands: start, stop." )
    end
end

