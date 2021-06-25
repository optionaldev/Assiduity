local debug = function() end

------------------------
-- Imports and locals --
------------------------

local math_random = math.random

--[[
	nextDeleteTime is required because trying to delete multiple items
	at the same time causes the account to be disconnected
]]
local nextDeleteTime = 0

local COMMON_ITEMS_TO_DELETE = {
	["Deep Fried Plantains"] = 1,
	["Greater Mana Potion"] = 1,
	["Major Healing Potion"] = 1,
	["Moon Harvest Pumpkin"] = 1,
	["Moonberry Juice"] = 1,
	["Morning Glory Dew"] = 1,
	["Scroll of Intellect IV"] = 1,
	["Scroll of Protection IV"] = 1,
	["Scroll of Spirit IV"] = 1,
	["Scroll of Strength IV"] = 1,
	["Solid Stone"] = 1,
	["Superior Healing Potion"] = 1,
}

---------------------
-- Local functions --
---------------------

local onUpdate = function(self)
	
	local currentTime = GetTime()
	
	if nextDeleteTime < currentTime then
		
		local randomNumber = math_random(5000, 10000)
		nextDeleteTime = currentTime + (randomNumber / 1000)
		
		for bag = 0, 4 do 
			for slot = 1, GetContainerNumSlots(bag) do 
				link = GetContainerItemLink(bag, slot) 
				if link then 
					local name, _, rarity = GetItemInfo(link) 
					if rarity == 0 or (rarity == 1 and COMMON_ITEMS_TO_DELETE[name]) then 
						print("Deleting item: " .. name)
						PickupContainerItem(bag,slot) 
						DeleteCursorItem() 
						return
					end 
				end
			end
		end
	end
end

-----------
-- Frame --
-----------
local AssiduityDeleteItems = CreateFrame("Frame")

--------------------
-- Slash commands --
--------------------
SLASH_ASSIDUITYDELETEITEMS1 = "/assiduitydeleteitems"
SLASH_ASSIDUITYDELETEITEMS2 = "/adi"

SlashCmdList["ASSIDUITYDELETEITEMS"] = function(message)
	
	local self = AssiduityDeleteItems
	
	if message == "start" then
		self:SetScript("OnUpdate", onUpdate)
		print("Auto deleting items started.")
	elseif message == "stop" then
		self:SetScript("OnUpdate", nil)
		print("Auto deleting items stopped.")
	else
		print("Available commands for /assiduitydeleteitems or /adi:")
		print("")
		print("/aae start")
		print("Start deleting items from bags.")
		print("")
		print("/aae stop")
		print("Stop deleting items from bags.")
		print("")
	end
end