--[[
    Plays a sound when enemies use certain abilities.
]]

local debug = print
-- local debug = function() end
------------------------
-- Imports and locals --
------------------------

local PlaySound = AssiduityPlaySound

local nextPlay = 0

local BATTLEFIELD_MGR_ENTRY_INVITE = function()
	
	PlaySound("wintergrasp")
	
	nextPlay = 0
	self:SetScrip
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
end

local PLAYER_ENTERING_WORLD = function()
	
	self:SetScript("OnUpdate", OnUpdate)
end

-------------
-- Scripts --
-------------
local OnUpdate = function()

	local currentTime = GetTime()
	
	if nextUpdate < currentTime and UnitIsDeadOrGhost("player") ~= 1 then
		
		if currentChestIndex == #chests then
			currentChestIndex = 1
		end
		
		EquipItemByName(chests[currentChestIndex])
	
		local randomNumber = math_random(NEXT_CHEST_UPDATE_MIN, NEXT_CHEST_UPDATE_MAX)
		nextChestUpdateTime = currentTime + randomNumber
		
		currentChestIndex = currentChestIndex + 1
	end
end

-----------
-- Frame --
-----------
local AssiduitySoundsAlert = CreateFrame( "Frame" )
do
    local self = AssiduitySoundsAlert
    
    self.BATTLEFIELD_MGR_ENTRY_INVITE = BATTLEFIELD_MGR_ENTRY_INVITE
    self.PLAYER_ENTERING_WORLD 		  = PLAYER_ENTERING_WORLD
	
    self:RegisterEvent("BATTLEFIELD_MGR_ENTRY_INVITE")
    
    self:SetScript("OnEvent", function( self, event, ... )
        self[event]( self, ... )
    end )
end


