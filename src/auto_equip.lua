local debug = function() end

------------------------
-- Imports and locals --
------------------------

local math_random = math.random
local UnitIsDeadOrGhost = UnitIsDeadOrGhost

local chests = {
	"Dark Green Wedding Hanbok",
	"Green Wedding Hanbok",
	"Preened Ironfeather Breastplate",
	"Red Traditional Hanbok",
	"Royal Dangui",
	"White Traditional Hanbok"
}

local currentChestIndex = 1

local NEXT_CHEST_UPDATE_MIN = 150
local NEXT_CHEST_UPDATE_MAX = 230

local nextChestUpdateTime = 0

---------------------
-- Local functions --
---------------------

local onUpdate = function(self)
	
	local currentTime = GetTime()
	
	if nextChestUpdateTime < currentTime and UnitIsDeadOrGhost("player") ~= 1 then
		
		if currentChestIndex == #chests then
			currentChestIndex = 1
		end
		
		EquipItemByName(chests[currentChestIndex])
	
		local randomNumber = math_random(NEXT_CHEST_UPDATE_MIN, NEXT_CHEST_UPDATE_MAX)
		nextChestUpdateTime = currentTime + randomNumber
		
		currentChestIndex = currentChestIndex + 1
	end
end

local ADDON_LOADED = function( self, addon )

    if addon == "Assiduity" then
        self:UnregisterEvent( "ADDON_LOADED" )
		
		local name = UnitName("player")
		if name == "Asymmetry" then
			self:SetScript("OnUpdate", onUpdate)
		end
    end
end

-----------
-- Frame --
-----------
local AssiduityAutoEquip = CreateFrame("Frame")

do
    local self = AssiduityAutoEquip
  
    self.ADDON_LOADED = ADDON_LOADED
    
    self:RegisterEvent( "ADDON_LOADED" )
    
    self:SetScript( "OnEvent", function( self, event, ... )
        self[event]( self, ... )
    end )
end

--------------------
-- Slash commands --
--------------------
SLASH_ASSIDUITYAUTOEQUIP1 = "/assiduityautoequip"
SLASH_ASSIDUITYAUTOEQUIP2 = "/aae"

SlashCmdList["ASSIDUITYAUTOEQUIP"] = function (message)
	
	local self = AssiduityAutoEquip
	
	if message == "pause" then
		self:SetScript("OnUpdate", nil)
		print("Auto equip paused.")
	elseif message == "resume" then
		self:SetScript("OnUpdate", onUpdate)
		print("Auto equip resumed.")
	else 
		print("Available commands for /assiduityautoequip or /aae:")
		print("")
		print("/aae pause")
		print("Puts a pause on equip switching.")
		print("")
		print("/aae resume")
		print("Resumes equip switching if it was paused. Otherwise does nothing.")
		print("")
	end
end