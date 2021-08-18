

---------------
-- Constants -- 
---------------

local table_insert = table.insert

local FRIENDLY = "FRIENDLY"
local HOSTILE  = "HOSTILE"
local TARGET   = "target"

local AURA_DISTANCE_TO_EDGE = 1
local AURA_SIZE			    = 20
local BAR_WIDTH 			= 180
local DISTANCE_TO_EDGE 		= 3
local HEALTH_BAR_HEIGHT 	= 28
local PLAYER_AURA_SIZE 		= 25
local POWER_BAR_HEIGHT 		= 12

local PLAYER_BAR_HEIGHT = PLAYER_AURA_SIZE + 2 * AURA_DISTANCE_TO_EDGE
local PORTRAIT_SIZE 	= HEALTH_BAR_HEIGHT + POWER_BAR_HEIGHT + DISTANCE_TO_EDGE

local FRAME_WIDTH  = BAR_WIDTH + PORTRAIT_SIZE + 3 * DISTANCE_TO_EDGE
local FRAME_HEIGHT = PORTRAIT_SIZE + 2 * DISTANCE_TO_EDGE

-- Tables

local FILTERED_AURA = {

	["Abomination's Might"] = 1,
	["Amplify Magic"] = 1,
	["Arcane Brilliance"] = 1,
	["Arcane Intellect"] = 1,
	["Aspect of the Beast"] = 1,
	["Aspect of the Dragonhawk"] = 1,
	["Aspect of the Hawk"] = 1,
	["Aspect of the Monkey"] = 1,
	["Aspect of the Wild"] = 1,
	["Battle Shout"] = 1,
	["Berserker Rage"] = 1,
	["Blessing of Kings"] = 1,
	["Blessing of Might"] = 1,
	["Blessing of Sanctuary"] = 1,
	["Blessing of Wisdom"] = 1,
	["Bone Shield"] = 1,
	["Chill of the Throne"] = 1,
	["Commanding Shout"] = 1,
	["Concentration Aura"] = 1,
	["Dampen Magic"] = 1,
	["Demoralizing Roar"] = 1,
	["Devotion Aura"] = 1,
	["Dalaran Brilliance"] = 1,
	["Demon Armor"] = 1,
	["Demonic Circle: Summon"] = 1,
	["Demoralizing Shout"] = 1,
	["Detect Invisibility"] = 1,
	["Divine Plea"] = 1,
	["Divine Sacrifice"] = 1,
	["Divine Spirit"] = 1,
	["Earth Shield"] = 1,
	["Earth Shock"] = 1,
	["Enrage"] = 1,
	["Enraged Regeneration"] = 1,
	["Fade"] = 1,
	["Fel Armor"] = 1,
	["Fire Resistance"] = 1,
	["Fire Resistance Aura"] = 1,
	["Fire Ward"] = 1,
	["Flametongue Totem"] = 1,
	["Focus Magic"] = 1,
	["Frenzied Regeneration"] = 1,
	["Frost Resistance"] = 1,
	["Frost Resistance Aura"] = 1,
	["Frost Ward"] = 1,
	["Hand of Reckoning"] = 1,
	["Hand of Salvation"] = 1,
	["Heroic Presence"] = 1,
	["Holy Shield"] = 1,
	["Horn of Winter"] = 1,
	["Hunter's Mark"] = 1,
	["Gift of the Wild"] = 1,
	["Greater Blessing of Kings"] = 1,
	["Greater Blessing of Might"] = 1,
	["Greater Blessing of Sanctuary"] = 1,
	["Greater Blessing of Wisdom"] = 1,
	["Ice Armor"] = 1,
	["Inner Fire"] = 1,
	["Inner Focus"] = 1,
	["Judgement of Light"] = 1,
	["Judgement of Wisdom"] = 1,
	["Leader of the Pack"] = 1,
	["Lightning Shield"] = 1,
	["Mage Armor"] = 1,
	["Mana Spring"] = 1,
	["Mangle (Bear)"] = 1,
	["Mangle (Cat)"] = 1,
	["Mark of the Wild"] = 1,
	["Master Shapeshifter"] = 1,
	["Molten Armor"] = 1,
	["Nature Resistance"] = 1,
	["Prayer of Fortitude"] = 1,
	["Prayer of Shadow Protection"] = 1,
	["Prayer of Spirit"] = 1,
	["Rampage"] = 1,
	["Retribution Aura"] = 1,
	["Righteous Fury"] = 1,
	["Scorpid Sting"] = 1,
	["Sentry Totem"] = 1,
	["Shadow Resistance Aura"] = 1,
	["Shadow Ward"] = 1,
	["Shield of Righteousness"] = 1,
	["Stoneskin"] = 1,
	["Strength of Earth"] = 1,
	["Sunder Armor"] = 1,
	["Tiger's Fury"] = 1,
	["Totem of Wrath"] = 1,
	["Trueshot Aura"] = 1,
	["Vigilance"] = 1,
	["Water Shield"] = 1,
	["Wild Growth"] = 1,
	["Windfury Totem"] = 1,
	["Wrath of Air Totem"] = 1,
	["Wyrmrest Champion"] = 1
}

local CLASS_TO_HEALTHCOLORS = {

    ["DEATHKNIGHT"]	= {0.77, 0.12, 0.23},
    ["DRUID"]		= {1,    0.49, 0.04},
    ["HUNTER"]		= {0.67, 0.83, 0.45},
    ["MAGE"]		= {0.41, 0.8,  0.94},
    ["PALADIN"]		= {0.96, 0.55, 0.73},
    ["PRIEST"]		= {1,    1,    1   },
    ["ROGUE"]		= {1,    0.96, 0.41},
    ["SHAMAN"]	 	= {0,    0.44, 0.87},
    ["WARLOCK"]		= {0.58, 0.51, 0.79},
    ["WARRIOR"]		= {0.78, 0.61, 0.43}
}

local POWERTYPE_TO_COLORS = {

    ["MANA"]		 = {0,    0,    0.85},
    ["RAGE"]		 = {0.85, 0,    0   },
    ["FOCUS"]		 = {1,    1,    1   },
    ["ENERGY"]		 = {0.9,  0.9,  0   },
    ["COMBO_POINTS"] = {1,    1,    1   },
    ["RUNES"]		 = {1,    1,    1   },
    ["RUNIC_POWER"]	 = {0,    0.6,  1   },
    ["SOUL_SHARDS"]	 = {1,    1,    1   },
    ["ECLIPSE"]		 = {1,    1,    1   },
    ["HOLY_POWER"]	 = {1,    1,    1   },
    ["AMMOSLOT"]	 = {1,    1,    1   },
    ["FUEL"]		 = {1,    1,    1   }
}

local REACTION = {

	[FRIENDLY] = {0, 1, 0, 0.3},
	[HOSTILE]  = {1, 0, 0, 0.3}
}


local OPPOSITE_POINT = {

	["LEFT"]   = "RIGHT",
	["RIGHT"]  = "LEFT",
	["TOP"]    = "BOTTOM",
	["BOTTOM"] = "TOP"
}

local DEBUFF_TYPE_TO_TEXTURE = {

    ["Curse"]    = {1, 0, 1},
    ["Disease"]  = {1, 1, 0},
    ["Magic"]    = {0, 0, 1},
    ["Poison"]   = {0, 1, 0}
}

-------------
-- Imports --
-------------

local UnitLocalizedClass = AssiduityGetUnitLocalizedClass

-----------
-- Frame --
-----------

AssiduityTarget = CreateFrame("Button", "AssiduityTarget", UIParent, "SecureUnitButtonTemplate")

local self = AssiduityTarget
self:Hide()
---------------
-- Functions --
---------------

local getReaction = function()

	if UnitIsPVPSanctuary(TARGET) == 1 or not UnitIsEnemy("player", TARGET) then
		return FRIENDLY
	end
	
	return HOSTILE
end

local position = function(anchored, point, origin)

	local anchoredPoint = OPPOSITE_POINT[point]
	anchored:SetPoint(anchoredPoint, 
					  origin, 
					  point, 
					  AURA_DISTANCE_TO_EDGE, 
					  0)
end

local handleAuraFrameCreation = function(parent, size)

	local result = CreateFrame("Button", nil, parent)
	result:SetSize(size, size)
	
	local background = result:CreateTexture(nil, "BACKGROUND")
	background:SetSize(size, size)
	background:SetAllPoints()
	result.background = background
	
	local iconTexture = result:CreateTexture()
	iconTexture:SetSize(size - 2, size - 2)
	iconTexture:SetPoint("CENTER")
	iconTexture:SetAlpha(0.9)
	result.icon = iconTexture
	
	local cooldown = CreateFrame("Cooldown", nil, result, "CooldownFrameTemplate")
	cooldown:SetPoint("CENTER")
	cooldown:SetReverse(true)
	result.cooldown = cooldown
	
	local count = result:CreateFontString(nil, nil, "AssiduityAuraCountFontLarge")
	count:SetPoint("BOTTOMRIGHT", result)
	result.count = count
	
	return result
end

local handleHealth = function()

	local class = UnitLocalizedClass(TARGET)
	local colors = CLASS_TO_HEALTHCOLORS[class]
		
	self.healthBar:SetStatusBarColor(unpack(colors))
	self.healthBar:SetMinMaxValues(0, UnitHealthMax(TARGET))
	self.healthBar:SetValue(UnitHealth(TARGET))
end

local handlePower = function()
	
	local _, powerType = UnitPowerType(TARGET)
	
	if powerType then
		local colors = POWERTYPE_TO_COLORS[powerType]
		self.powerBar:SetStatusBarColor(unpack(colors))
	end
	self.powerBar:SetMinMaxValues(0, UnitManaMax(TARGET))
	self.powerBar:SetValue(UnitMana(TARGET))
end

local createAuraFrames = function(parent, size)
		
	local aura1 = handleAuraFrameCreation(self, size)
	local aura2 = handleAuraFrameCreation(self, size)
	local aura3 = handleAuraFrameCreation(self, size)
	local aura4 = handleAuraFrameCreation(self, size)
	local aura5 = handleAuraFrameCreation(self, size)
	local aura6 = handleAuraFrameCreation(self, size)
	local aura7 = handleAuraFrameCreation(self, size)
	local aura8 = handleAuraFrameCreation(self, size)
	local aura9 = handleAuraFrameCreation(self, size)
	
	aura1:SetPoint("TOPLEFT", 
				   parent,
				   "TOPLEFT",
				   AURA_DISTANCE_TO_EDGE,
				   -AURA_DISTANCE_TO_EDGE)
	
	position(aura2, "RIGHT", aura1)
	position(aura3, "RIGHT", aura2)
	position(aura4, "RIGHT", aura3)
	position(aura5, "RIGHT", aura4)
	position(aura6, "RIGHT", aura5)
	position(aura7, "RIGHT", aura6)
	position(aura8, "RIGHT", aura7)
	position(aura9, "RIGHT", aura8)
	
	parent.frames = {aura1, aura2, aura3, aura4, aura5, aura6, aura7, aura8, aura9}
end

--[[
	friendly target
	player sources buffs 
	non-player buffs
	target debuffs
	
	hostile target
	player sourced debuffs
	non-player debuffs
	target buffs
	
	playerInclusion: can be "INCLUDED", "EXCLUDED", "EXCLUSIVE"
]]
local getAuras = function(auraFunction, playerInclusion)

	local result = {}

	local index = 1
	local auraName, _, icon, count, dispelType, duration, expiration, source = auraFunction(TARGET, index)
	local changeDetected = false
	
	while auraName do
		local isBuff
		
		if auraFunction == UnitBuff then
			isBuff = true
		else 
			isBuff = false
		end
		local aura = {["name"]       = auraName, 
					  ["index"]  	 = index,
					  ["isBuff"]     = isBuff,
					  ["icon"]       = icon, 
					  ["count"]      = count, 
					  ["dispelType"] = dispelType,
					  ["duration"]   = duration, 
					  ["expiration"] = expiration}
		if not FILTERED_AURA[auraName] then
			if source == "player" then 
				if playerInclusion ~= "EXCLUDED" then
					table_insert(result, aura)
				end
			else
				if playerInclusion ~= "EXCLUSIVE" then
					table_insert(result, aura)
				end
			end
		end
		
		index = index + 1
		auraName, _, icon, count, dispelType, duration, expiration, source = auraFunction(TARGET, index)
	end
	
	return result
end

local handleAura = function(frame, aura)

	frame:SetAlpha(1)
	frame.icon:SetTexture(aura.icon)
	
	local dispelTexture = DEBUFF_TYPE_TO_TEXTURE[aura.dispelType]
	
	if dispelTexture then
		frame.background:SetTexture(unpack(dispelTexture))
	else
		frame.background:SetTexture(1, 0, 0)
	end
	
	if aura.duration and aura.duration > 0 then
		frame.cooldown:Show()
		frame.cooldown:SetCooldown(aura.expiration - aura.duration, aura.duration)
	else 
		frame.cooldown:Hide()
	end
	
	if aura.count and aura.count > 1 then
		frame.count:Show()
		frame.count:SetText(tostring(aura.count))
	else 
		frame.count:Hide()
	end
	
	frame:SetScript("OnEnter", function() 
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", 15, -25)
		if aura.isBuff then
			GameTooltip:SetUnitBuff(TARGET, aura.index)
		else 
			GameTooltip:SetUnitDebuff(TARGET, aura.index)
		end
	end)
	
	frame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	
	frame:SetScript("OnUpdate", function() 
		if GameTooltip:IsOwned(self) then
			if aura.isBuff then
				GameTooltip:SetUnitBuff(TARGET, aura.index)
			else 
				GameTooltip:SetUnitDebuff(TARGET, aura.index)
			end
		end
	end)
end

local handleHostility = function()

	self.background:SetTexture(unpack(REACTION[getReaction()]))
end

local populateFramesWithAuras = function(row, auras)

	for index, frame in ipairs(row.frames) do
		local aura = auras[index]
		if aura then
			handleAura(frame, aura)
			frame:Show()
		else
			frame:Hide()
		end
	end
end

local updateAura = function()

    local firstAnchor  = self.background
    local secondAnchor = self.background
	
	local firstRowAuras = {}
	local secondRowAuras = {}
	local thirdRowAuras = {}
	
	if getReaction() == FRIENDLY then
		firstRowAuras  = getAuras(UnitBuff,   "EXCLUSIVE")
		secondRowAuras = getAuras(UnitBuff,   "EXCLUDED")
		thirdRowAuras  = getAuras(UnitDebuff, "INCLUDED")
	else
		firstRowAuras  = getAuras(UnitDebuff, "EXCLUSIVE")
		secondRowAuras = getAuras(UnitDebuff, "EXCLUDED")
		thirdRowAuras  = getAuras(UnitBuff,   "INCLUDED")
	end
	
	populateFramesWithAuras(self.playerAuras, 	 firstRowAuras)
	populateFramesWithAuras(self.nonPlayerAuras, secondRowAuras)
	populateFramesWithAuras(self.auras, 		 thirdRowAuras)
	
	if #firstRowAuras ~= 0 then
		firstAnchor = self.playerAuras
		if #secondRowAuras ~= 0 then
			secondAnchor = self.nonPlayerAuras
		else 
			secondAnchor = self.playerAuras
		end
	else 
		if #secondRowAuras ~= 0 then
			secondAnchor = self.nonPlayerAuras
		end
	end

	self.nonPlayerAuras:SetPoint("TOP", 
								 firstAnchor, 
								 "BOTTOM",
								 0,
								 -DISTANCE_TO_EDGE)

	self.auras:SetPoint("TOP", 
						secondAnchor,
						"BOTTOM",
						0,
						-DISTANCE_TO_EDGE)
end

local handleTargetChange = function(self)

	if UnitExists(TARGET) then
		self:Show()
		self.nameFontString:SetText(UnitName(TARGET))
		handleHostility()
		handleHealth()
		handlePower()
		updateAura()
		self:RegisterEvent("UNIT_AURA")
		self:RegisterEvent("UNIT_ENERGY")
		self:RegisterEvent("UNIT_FACTION")
		self:RegisterEvent("UNIT_HEALTH")
		self:RegisterEvent("UNIT_MANA")
		self:RegisterEvent("UNIT_RAGE")
		self:RegisterEvent("UNIT_RUNIC_POWER")
	else 
		self:UnregisterEvent("UNIT_AURA")
		self:UnregisterEvent("UNIT_ENERGY")
		self:UnregisterEvent("UNIT_FACTION")
		self:UnregisterEvent("UNIT_HEALTH")
		self:UnregisterEvent("UNIT_MANA")
		self:UnregisterEvent("UNIT_RAGE")
		self:UnregisterEvent("UNIT_RUNIC_POWER")
		self:Hide()
	end
end

------------
-- Events --
------------

local PLAYER_ENTERING_WORLD = function(self)
	
	handleTargetChange(self)
end

local PLAYER_TARGET_CHANGED = function(self)
	
	handleTargetChange(self)
end

local UNIT_AURA = function(self, unit)
    
    if unit == self:GetAttribute("unit") then
        updateAura()
    end
end

local UNIT_FACTION = function(self, unit)

	if unit == self:GetAttribute("unit") then
		handleHostility()
	end
end

local UNIT_HEALTH = function(self, unit)

	if unit == self:GetAttribute("unit") then
		handleHealth()
	end
end

local UNIT_POWER = function(self, unit)
    
    if unit == self:GetAttribute("unit") then
		handlePower()
    end
end

do 
	-- Layout
	self:SetSize(FRAME_WIDTH, FRAME_HEIGHT)
	self:SetPoint("CENTER", UIParent, "CENTER", 200, 150)
	
	-- Interaction
	self:EnableKeyboard(true)
	self:RegisterForClicks("AnyUp")
	self:RegisterForClicks("AnyDown")
    self:SetAttribute("unit", TARGET)
    --self:SetAttribute("type", "spell")
	--
    --self:SetAttribute("*helpbutton1", "heal1")
    --self:SetAttribute("*helpbutton2", "heal2")
	--
    --self:SetAttribute("spell-heal1", "Rejuvenation")
    --self:SetAttribute("ctrl-spell-heal1", "Regrowth")
    --self:SetAttribute("shift-spell-heal1", "Wild Growth")
    --self:SetAttribute("alt-spell-heal1", "Rejuvenation")
	--
    --self:SetAttribute("spell-heal2", "Lifebloom")
    --self:SetAttribute("ctrl-spell-heal2", "Nourish")
    --self:SetAttribute("shift-spell-heal2", "Remove Curse")
    --self:SetAttribute("alt-spell-heal2", "Abolish Poison")
	
	-- Textures
	local background = self:CreateTexture(nil, "BACKGROUND")
	background:SetTexture(0, 0, 0, 0.4)
	background:SetAllPoints()
	self.background = background
	
	local portrait = CreateFrame("Frame", nil, self)
	portrait:SetSize(PORTRAIT_SIZE, PORTRAIT_SIZE)
	portrait:SetPoint("RIGHT", 
					  self, 
					  "RIGHT",
					  -DISTANCE_TO_EDGE, 
					  0)			  
					  
	local portraitBackground = portrait:CreateTexture(nil, "BACKGROUND")
	portraitBackground:SetTexture(1, 1, 1)
	portraitBackground:SetAllPoints()
	
	local portraitFontString = portrait:CreateFontString(nil, nil, "AssiduityIconText")
	portraitFontString:SetPoint("CENTER", portrait)
	portraitFontString:SetText("G")
	
	-- Frames
	local healthBar = CreateFrame("StatusBar", nil, self) 
	healthBar:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8.blp")
	healthBar:SetOrientation("HORIZONTAL")
	healthBar:SetSize(BAR_WIDTH, HEALTH_BAR_HEIGHT)
	healthBar:SetPoint("TOPLEFT", 
					   self, 
					   "TOPLEFT",
					   DISTANCE_TO_EDGE, 
					   -DISTANCE_TO_EDGE)
	self.healthBar = healthBar
	
	local healthBarBackground = healthBar:CreateTexture(nil, "BACKGROUND")
	healthBarBackground:SetTexture(0, 0, 0, 1)
	healthBarBackground:SetAllPoints()
	
	local nameFontString = healthBar:CreateFontString(nil, nil, "AssiduityAuraCountFontLarge")
	nameFontString:SetPoint("CENTER", healthBar)
	self.nameFontString = nameFontString
				
	local powerBar = CreateFrame("StatusBar", nil, self) 
	powerBar:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8.blp")
	powerBar:SetStatusBarColor(0, 1, 1)
	powerBar:SetOrientation("HORIZONTAL")
	powerBar:SetSize(BAR_WIDTH, POWER_BAR_HEIGHT)
	powerBar:SetPoint("BOTTOMLEFT", 
					  self, 
					  "BOTTOMLEFT",
					  DISTANCE_TO_EDGE, 
					  DISTANCE_TO_EDGE)
	self.powerBar = powerBar
	
	local powerBarBackground = powerBar:CreateTexture(nil, "BACKGROUND")
	powerBarBackground:SetTexture(0, 0, 0, 1)
	powerBarBackground:SetAllPoints()
	
	
	--[[ 1st row: 
		Friendly target: player applied buffs
		Hostile  target: player applied debuffs
	]]
	
	local playerAuras = CreateFrame("Frame", nil, self)
	playerAuras:SetSize(FRAME_WIDTH, PLAYER_BAR_HEIGHT)
	playerAuras:SetPoint("TOPLEFT",
						 self,
						 "BOTTOMLEFT",
						 0,
						 -AURA_DISTANCE_TO_EDGE)
	self.playerAuras = playerAuras
	createAuraFrames(playerAuras, PLAYER_AURA_SIZE)
	--local playerAurasTexture = playerAuras:CreateTexture(nil, "BACKGROUND")
	--playerAurasTexture:SetTexture(0, 0, 1, 0.4)
	--playerAurasTexture:SetAllPoints()
						 

	-- Shows when someone is dead for better visibility
	
	--[[ 2nd row:
		Friendly target: non-player buffs 
		Hostile  target: non-player debuffs
	]]
	local nonPlayerAuras = CreateFrame("Frame", nil, self)
	nonPlayerAuras:SetSize(FRAME_WIDTH, AURA_SIZE)
	self.nonPlayerAuras = nonPlayerAuras		
	createAuraFrames(nonPlayerAuras, AURA_SIZE)	 
			
	--local nonPlayerAurasTexture = nonPlayerAuras:CreateTexture(nil, "BACKGROUND")
	--nonPlayerAurasTexture:SetTexture(0, 1, 0, 0.4)
	--nonPlayerAurasTexture:SetAllPoints()	 
	
	--[[ 3rd row: 
		Friendly target: debuffs
		Hostile  target: buffs
	]]
	local auras = CreateFrame("Frame", nil, self)
	auras:SetSize(FRAME_WIDTH, AURA_SIZE)
	self.auras = auras		 
	createAuraFrames(auras, AURA_SIZE)	
	--local aurasTexture = auras:CreateTexture(nil, "BACKGROUND")
	--aurasTexture:SetTexture(1, 0, 0, 0.4)
	--aurasTexture:SetAllPoints()
	
	local deadFontString = playerAuras:CreateFontString(nil, nil, "AssiduityAuraCountFontLarge")
	deadFontString:SetPoint("CENTER", playerAuras)
	deadFontString:SetText("DEAD")
	deadFontString:SetAlpha(0)
	self.deadFontString = deadFontString
	
	-- Events
	self.PLAYER_ENTERING_WORLD = PLAYER_ENTERING_WORLD
	self.PLAYER_TARGET_CHANGED = PLAYER_TARGET_CHANGED
	self.UNIT_AURA             = UNIT_AURA 
	self.UNIT_FACTION		   = UNIT_FACTION
	self.UNIT_HEALTH           = UNIT_HEALTH
	self.UNIT_MANA             = UNIT_POWER
	self.UNIT_RUNIC_POWER      = UNIT_POWER
	self.UNIT_ENERGY           = UNIT_POWER
	self.UNIT_RAGE 			   = UNIT_POWER
	
	self:RegisterEvent("PLAYER_TARGET_CHANGED")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	
	-- Scripts
	
    self:SetScript("OnEvent", function(self, event, ...)
        self[event](self, ...)
    end)
	
	handleTargetChange(self)
	
	RegisterUnitWatch(self)
end

