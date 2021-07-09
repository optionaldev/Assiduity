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
	["Aboriginal Shoulder Pads"] = 1,
	["Ancestral Gloves"] = 1,
	["Ceremonial Leather Ankleguards"] = 1,
	["Crude Scope"] = 1,
	["Dalaran Sharp"] = 1,
	["Deep Fried Plantains"] = 1,
	["Lesser Healing Potion"] = 1,
	["Greater Mana Potion"] = 1,
	["Green Hills of Stranglethorn - Page 1"] = 1,
	["Green Hills of Stranglethorn - Page 4"] = 1,
	["Green Hills of Stranglethorn - Page 6"] = 1,
	["Green Hills of Stranglethorn - Page 8"] = 1,
	["Green Hills of Stranglethorn - Page 10"] = 1,
	["Green Hills of Stranglethorn - Page 11"] = 1,
	["Green Hills of Stranglethorn - Page 14"] = 1,
	["Green Hills of Stranglethorn - Page 16"] = 1,
	["Green Hills of Stranglethorn - Page 18"] = 1,
	["Green Hills of Stranglethorn - Page 20"] = 1,
	["Green Hills of Stranglethorn - Page 21"] = 1,
	["Green Hills of Stranglethorn - Page 24"] = 1,
	["Green Hills of Stranglethorn - Page 25"] = 1,
	["Green Hills of Stranglethorn - Page 26"] = 1,
	["Green Hills of Stranglethorn - Page 27"] = 1,
	["Gorilla Fang"] = 1,
	["Grizzly Gloves"] = 1,
	["Gypsy Sash"] = 1,
	["Flask of Oil"] = 1,
	["Haunch of Meat"] = 1,
	["Heavy Blasting Powder"] = 1,
	["Heavy Stone"] = 1,
	["Hunting Boots"] = 1,
	["Hunting Bracers"] = 1,
	["Ice Cold Milk"] = 1,
	["Large Green Sack"] = 1,
	["Large Fang"] = 1,
	["Major Healing Potion"] = 1,
	["Mana Potion"] = 1,
	["Minor Mana Potion"] = 1,
	["Moon Harvest Pumpkin"] = 1,
	["Moonberry Juice"] = 1,
	["Morning Glory Dew"] = 1,
	["Raptor Hide"] = 1,
	["Scouting Spaulders"] = 1,
	["Scroll of Intellect"] = 1,
	["Scroll of Intellect I"] = 1,
	["Scroll of Intellect II"] = 1,
	["Scroll of Intellect III"] = 1,
	["Scroll of Intellect IV"] = 1,
	["Scroll of Intellect V"] = 1,
	["Scroll of Protection I"] = 1,
	["Scroll of Protection II"] = 1,
	["Scroll of Protection III"] = 1,
	["Scroll of Protection IV"] = 1,
	["Scroll of Protection V"] = 1,
	["Scroll of Spirit"] = 1,
	["Scroll of Spirit I"] = 1,
	["Scroll of Spirit II"] = 1,
	["Scroll of Spirit III"] = 1,
	["Scroll of Spirit IV"] = 1,
	["Scroll of Spirit V"] = 1,
	["Scroll of Strength"] = 1,
	["Scroll of Strength I"] = 1,
	["Scroll of Strength II"] = 1,
	["Scroll of Strength III"] = 1,
	["Scroll of Strength IV"] = 1,
	["Scroll of Strength V"] = 1,
	["Shimmering Amice"] = 1,
	["Simple Gloves"] = 1,
	["Simple Shoes"] = 1,
	["Solid Stone"] = 1,
	["Spellbinder Belt"] = 1,
	["Soldier's Cloak"] = 1,
	["Superior Healing Potion"] = 1,
	["Tel'Abim Banana"] = 1,
	["Tribal Boots"] = 1,
	["Veteran Boots"] = 1,
	["Veteran Bracers"] = 1,
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