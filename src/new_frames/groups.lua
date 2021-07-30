
------------------------
-- Locals and imports --
------------------------

local table_insert = table.insert
local UnitLocalizedClass = AssiduityGetUnitLocalizedClass
local UnitAuraSource = AssiduityUnitAuraSource

local BUTTON_WIDTH = 70
local BUTTON_HEIGHT = 50
local SEPARATOR_SIZE = 7

local DISTANCE_TO_EDGE = 1
local HEALTH_BAR_HEIGHT = 14
local POWER_BAR_HEIGHT = 3
local AURA_SIZE = 15

local RAID_TANK_MIN_HP = 45000
local PARTY_TANK_MIN_HP = 35000

--local BACKGROUND_ALPHA   = 0.4
--local HIDDEN_FRAME_ALPHA = 0.1
--local PLAYER_BUFFS_ALPHA = 0.1
--local POWER_BAR_ALPHA    = 0.5

local BACKGROUND_ALPHA   = 0.15
local OUT_OF_RANGE_ALPHA = 0.3
local HIDDEN_FRAME_ALPHA = 0.03
local AURA_HIDDEN_ALPHA  = 0
local POWER_BAR_ALPHA    = 1

local BAR_WIDTH = BUTTON_WIDTH - 2 * DISTANCE_TO_EDGE

-- Main frame that will also handle the events
AssiduityGroupsFrame = CreateFrame("Frame", AssiduityGroupsFrame, UIParent)

--[[
	If we already established a player's spec, aside from accounting
	for spec changes for when players leave or we're about to face
	Valithria, for the most part, specs don't change.
	
	Worth noting that in Druid's case, just because we know he's Feral
	doesn't mean we know his role. Could still be both tank and mdps.
	
	Also, doesn't make sense to add spec to this table if the role
	doesn't change, such as for mages, hunters, rogues & warlocks.
	
	This value should NOT be reset unless leaving the party.
]]
nameToSpec = {}

--[[
	Once we've identified the spec, we want to know what role that spec uses.
	
	Only included specs for classes where it couldn't be identified from the get-go.
	
	Excluded Feral due to spec being used as both mdps and tank.
	
	This value should NOT be reset unless leaving the party.
]]

local PLAYER_BUFF_ORDER = {
	"Rejuvenation",
	"Regrowth",
	"Lifebloom",
	"Abolish Poison",
	"Innervate"
}

local specToRole = {

	["Balance"]	    = "rdps",
	["Discipline"]  = "heal",
	["Elemental"]   = "rdps",
	["Enhancement"] = "mdps",
	["Holy"]		= "heal",
	["Protection"]  = "tank",
	["Restoration"] = "heal",
	["Retribution"] = "mdps"
}

local BUFF_TO_SPEC = {

	-- Priest
	["Divine Aegis"] = "Discipline",
	["Grace"] 		 = "Discipline",
	["Renewed Hope"] = "Discipline",
	
	["Body and Soul"] 	   = "Holy",
	["Holy Concentration"] = "Holy",
	["Serendipity"] 	   = "Holy",
	
	-- Druid
	["Eclipse (Lunar)"] = "Balance",
	["Eclipse (Solar)"] = "Balance",
	
	["Living Seed"] = "Restoration"
}

local SPELLCAST_TO_SPEC = {
	
	-- Priest
	["Pain Suppression"] = "Discipline",
	["Penance"] 		 = "Discipline",
	["Power Infusion"] 	 = "Discipline",
	
	["Circle of Healing"] = "Holy",
	["Guardian Spirit"]   = "Holy",
	["Lightwell"] 		  = "Holy",
	
	-- Druid
	["Force of Nature"] = "Balance",
	["Insect Swarm"] 	= "Balance",
	["Moonkin Form"] 	= "Balance",
	["Starfall"] 		= "Balance",
	["Typhoon"] 		= "Balance",
	
	["Swiftmend"]		   = "Restoration",
	["Nature's Swiftness"] = "Restoration",
	["Tree of Life"]	   = "Restoration",
	["Wild Growth"]		   = "Restoration"
}


local OPPOSITE_POINT = {
	["LEFT"]   = "RIGHT",
	["RIGHT"]  = "LEFT",
	["TOP"]    = "BOTTOM",
	["BOTTOM"] = "TOP"
}


tankFrames = {}
mdpsFrames = {}
rdpsFrames = {}
healFrames = {}

tankUnits = {}
mdpsUnits = {}
rdpsUnits = {}
healUnits = {}

--[[ 
	Here we put units that we can't classify based on hp / mana / passive buffs
	We need to wait for them to cast some spell specific for their talents (spec)
]] 
unclassifiedUnits = {}

---------------
-- Functions --
---------------

local isUnitRoleInTable = function(tbl, unit)
	
	for _, value in ipairs(tbl) do
		if unit == value then
			return true
		end
	end
	
	return false
end

local isUnitRoleDiscovered = function(unit)

	return isUnitRoleInTable(tankUnits, unit) or 
		   isUnitRoleInTable(mdpsUnits, unit) or
		   isUnitRoleInTable(rdpsUnits, unit) or
		   isUnitRoleInTable(healUnits, unit)
end

--[[
	Clasify units based on simple and obvious metrics. These might not work
	for lesser geared people, especially in RDFs, but it's also less 
	important in RDFs and I might even hide the entire thing in dungeons
	and just use key combos for selecting.
]]
local applyBaseClasification = function(unit, tankMinHp)
	
	local class = UnitLocalizedClass(unit)
	local name = UnitName(unit)
	
	if class == "MAGE" or class == "WARLOCK" or class == "HUNTER" then
		table_insert(rdpsUnits, unit)
	elseif class == "ROGUE" then
		table_insert(mdpsUnits, unit)
	elseif class == "DRUID" then
		if UnitAura(unit, "Moonkin Form") then
			table_insert(rdpsUnits, unit)
			nameToSpec[name] = "Balance"
		elseif UnitAuraSource(unit, "Tree of Life") then
			table_insert(healUnits, unit)
			nameToSpec[name] = "Restoration"
		elseif UnitHealthMax(unit) > tankMinHp then
			table_insert(tankUnits, unit)
			nameToSpec[name] = "Feral"
		else
			table_insert(unclassifiedUnits, unit)
		end
	elseif class == "PALADIN" then
		if UnitPowerMax(unit) > 15000 then
			table_insert(healUnits, unit)
			nameToSpec[name] = "Holy"
		elseif UnitHealthMax(unit) > tankMinHp then
			table_insert(tankUnits, unit)
			nameToSpec[name] = "Protection"
		else
			table_insert(mdpsUnits, unit)
			nameToSpec[name] = "Retribution"
		end
	elseif class == "SHAMAN" then
		if UnitAuraSource(unit, "Elemental Oath") then
			table_insert(rdpsUnits, unit)
			nameToSpec[name] = "Elemental"
		elseif UnitAuraSource(unit, "Unleashed Rage") then
			table_insert(mdpsUnits, unit)
			nameToSpec[name] = "Enhancement"
		else
			table_insert(healUnits, unit)
			nameToSpec[name] = "Restoration"
		end
	elseif class == "WARRIOR" and UnitAura(unit, "Rampage") then
		table_insert(mdpsUnits, unit)
	elseif class == "DEATHKNIGHT" or class == "WARRIOR" then
		--[[
			For DK, it's a bit more tricky because they can be Blood
			tank or dps and Frost tank or dps. Will need to see how 
			we deal with it.
		]]
		if UnitHealthMax(unit) > tankMinHp then
			table_insert(tankUnits, unit)
		else 
			table_insert(mdpsUnits, unit)
		end
	elseif class == "PRIEST" then
		if UnitAura(unit, "Shadowform") then
			table_insert(rdpsUnits, unit)
			nameToSpec[name] = "Shadow"
		else
			--[[
				Here could be disc or holy or an SP not in shadow form currently.
			]]		
			table_insert(unclassifiedUnits, unit)
		end
	else 
		print("unit \"" .. unit .. "\" not part of any clasification")
	end
end

local handleUnit = function(unit)

	if not UnitExists(unit) then
		return
	end
	applyBaseClasification(unit, RAID_TANK_MIN_HP)
	if not isUnitRoleDiscovered(unit) then
		local spec = nameToSpec[UnitName(unit)]
		if spec then
			local role = specToRole[spec]
			if role then
				if role == "tank" then
					table_insert(tankUnits, unit)
				elseif role == "rdps" then
					table_insert(rdpsUnits, unit)
				elseif role == "mdps" then
					table_insert(mdpsUnits, unit)
				elseif role == "heal" then
					table_insert(healUnits, unit)
				else 
					print("inexistent role found \"" .. role .. "\"")
				end
			end
		end
	end
end

local evaluateParty = function() 
	
	for index = 1, 4 do
		local unit = "party" .. tostring(index)
		handleUnit(unit)
	end
	
	--[[ 
		Unlike in raids where "player" gets assigned a raid ID, here we 
		have to handle it like a different entity not part of the party
	]]
	handleUnit("player")
end

local evaluateRaid = function()
	
	for index = 1, 40 do
		local unit = "raid" .. index
		handleUnit(unit)
	end
end


local evaluateBattleground = function()

	evaluateRaid()
end


local CLASS_TO_HEALTHCOLORS = {

    ["DEATHKNIGHT"]	= { 0.77, 0.12, 0.23 },
    ["DRUID"]		= { 1,    0.49, 0.04 },
    ["HUNTER"]		= { 0.67, 0.83, 0.45 },
    ["MAGE"]		= { 0.41, 0.8,  0.94 },
    ["PALADIN"]		= { 0.96, 0.55, 0.73 },
    ["PRIEST"]		= { 1,    1,    1    },
    ["ROGUE"]		= { 1,    0.96, 0.41 },
    ["SHAMAN"]	 	= { 0,    0.44, 0.87 },
    ["WARLOCK"]		= { 0.58, 0.51, 0.79 },
    ["WARRIOR"]		= { 0.78, 0.61, 0.43 }
}

local updateFrames = function(frameList, units)
	
	for index, frame in ipairs(frameList) do
		local unit = units[index]
	
		if UnitExists(unit) then
			local class = UnitLocalizedClass(unit)
			local colors = CLASS_TO_HEALTHCOLORS[class]
		
			frame.nameFontString:SetText(UnitName(unit))
			frame:SetAttribute("unit", unit)
			
			frame.healthBar:SetStatusBarColor(unpack(colors))
			frame.healthBar:SetValue(UnitHealth(unit))
			frame.healthBar:SetMinMaxValues(0, UnitHealthMax(unit))
			frame.powerBar:SetValue(UnitMana(unit))
			frame.powerBar:SetMinMaxValues(0, UnitManaMax(unit))
			frame:RegisterEvent("UNIT_AURA")
			frame:RegisterEvent("UNIT_HEALTH")
			frame:RegisterEvent("UNIT_MAXHEALTH")
			frame:RegisterEvent("UNIT_MANA")
			frame:RegisterEvent("UNIT_MAXMANA")
			frame:SetAlpha(1)
		else
			frame:SetAttribute("unit", nil)
			frame:UnregisterEvent("UNIT_AURA")
			frame:UnregisterEvent("UNIT_HEALTH")
			frame:UnregisterEvent("UNIT_MAXHEALTH")
			frame:UnregisterEvent("UNIT_MANA")
			frame:UnregisterEvent("UNIT_MAXMANA")
			frame:SetAlpha(HIDDEN_FRAME_ALPHA)
		end
	end
end

local evaluateGroup = function()

	tankUnits = {}
	mdpsUnits = {}
	rdpsUnits = {}
	healUnits = {}
	unclassifiedUnits = {}
	
	if GetRealNumRaidMembers() ~= 0 then
		evaluateRaid()
	elseif GetRealNumPartyMembers() ~= 0 then
		evaluateParty()
	elseif GetNumRaidMembers() ~= 0 then
		evaluateBattleground()
	end
	
	AssiduityGroupsFrame:RegisterEvent("UNIT_AURA")
	AssiduityGroupsFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	
	--[[
		TODO: Either make an unclassifiedUnit frame section
		or apply a "best guess" until we know everyone's role.
	]]
	
	updateFrames(tankFrames, tankUnits)
	updateFrames(healFrames, healUnits)
	updateFrames(mdpsFrames, mdpsUnits)
	updateFrames(rdpsFrames, rdpsUnits)
end

local printUnitTable = function(tbl) 

	if tbl == nil then
		print("Table is nil")
		return
	end

	for _, unit in ipairs(tbl) do
		if UnitExists(unit) then
			local name = UnitName(unit)
			local result = name .. " " .. unit .. " " .. UnitLocalizedClass(unit) .. " "
			if nameToSpec[name] then
				result = result .. nameToSpec[name]
			else
				result = result .. "unknown spec"
			end
			print(result)
		end
	end
end

printRaid = function()
	
	print("evaluateRaid")
	print("")
	print("Tanks:")
	print("------")
	printUnitTable(tankUnits)
	print("")
	print("MDPS:")
	print("-----")
	printUnitTable(mdpsUnits)
	print("")
	print("RDPS:")
	print("-----")
	printUnitTable(rdpsUnits)
	print("")
	print("Healers:")
	print("--------")
	printUnitTable(healUnits)
	print("")
	print("Unclassified units:")
	print("-------------------")
	printUnitTable(unclassifiedUnits)
end

local handleCurrentState = function()

	if GetRealNumPartyMembers() == 0 and GetRealNumRaidMembers() == 0 then
		AssiduityGroupsFrame:SetAlpha(1)
	elseif not IsInInstance() then
		AssiduityGroupsFrame:SetAlpha(1)
	else 
		AssiduityGroupsFrame:SetAlpha(1)
	end
end 

local position = function(anchored, point, origin)

	local anchoredPoint = OPPOSITE_POINT[point]
	anchored:SetPoint(anchoredPoint, origin, point)
end

local handleRange = function(frames)

	for _, frame in ipairs(frames) do
		local unit = frame:GetAttribute("unit")
		if unit then
			if UnitInRange(unit) then
			--if unit and IsSpellInRange(503, unit) then
				frame:SetAlpha(1)
			else 
				frame:SetAlpha(OUT_OF_RANGE_ALPHA)
			end
		else 
			frame:SetAlpha(0)
		end
	end
end

local onUpdate = function()

	handleRange(tankFrames)
	handleRange(healFrames)
	handleRange(rdpsFrames)
	handleRange(mdpsFrames)
end

------------
-- Events --
------------

--[[
	This is also called when raid members changed. There is no separate event for raids.
	
	This fires whenever someone leaves or joins. It's important to know that
	just because someone in the party / raid is currently "raid11" doesn't 
	mean they will stay "raid11" until the end of the party, but rather
	change his index depending on (as far as I can tell) his position within
	the raid list.
	
	The raid indices can never skip a number, even if one player is in group 1
	and the other in group 9, their indices will be "raid1" and "raid2" 
	respectively.
	
	Why this is important is because it's not possible to use SetAttribute while 
	in combat, so the unit has to remain. From there, we have to simply adapt
	in the moment and suddenly change what is displayed at a particular slot.
	It could definitely be the case that one guy leaves and it messes up the 
	entire groups, mdps in rdps group, healer in tank group, etc. It is quite
	unlikely that someone will leave in the middle of the encounter, if anything
	probably before or after.
]]
local PARTY_MEMBERS_CHANGED = function()

	if GetNumPartyMembers() == 0 then
		--[[
			Use this opportunity to reset certain tables.
		]]
		nameToSpec = {}
	else 
		evaluateGroup()
	end
end

local PLAYER_ENTERING_WORLD = function()

	handleCurrentState()
	evaluateGroup()
end

local UNIT_AURA = function(self, unit) 

	local index = 1
	local buffName, _, _, _, _, _, _, source = UnitBuff(unit, index)
	local changeDetected = false
	
	while buffName do
		if not isUnitRoleDiscovered(source) then
			local spec = BUFF_TO_SPEC[buffName]
		
			if spec then
				nameToSpec[UnitName(unit)] = spec
				changeDetected = true
			end
		end
			
		index = index + 1
		buffName, _, _, _, _, _, _, source = UnitBuff(unit, index)
	end
	
	if changeDetected then
		evaluateGroup()
	end
end

local CHILD_UNIT_AURA = function(self, unit)
	
	if self:GetAttribute("unit") ~= unit then
		return
	end
	
	local frameIndex = 1
	
	for _, buffName in ipairs(PLAYER_BUFF_ORDER) do
		local _, _, icon, count, _, duration, expiration, source = UnitBuff(unit, buffName)
		
		if source and (source == "player" or UnitIsUnit(source, "player")) then
			local frame = self.playerBuffs.frames[frameIndex] 
			frame:SetAlpha(1)
			frame.icon:SetTexture(icon)
			
			frame.cooldown:Show()
			frame.cooldown:SetCooldown(expiration - duration, duration)
			
			if count == 0 then
				frame.count:Hide()
			else 
				frame.count:Show()
				frame.count:SetText(tostring(count))
			end
			
			frameIndex = frameIndex + 1
		end
	end
	
	for index = frameIndex, 5 do
		self.playerBuffs.frames[index]:SetAlpha(AURA_HIDDEN_ALPHA)
	end
	
	frameIndex = 1
	
	for debuffIndex = 1, 5 do 
		local _, _, icon, count, _, duration, expiration, source = UnitDebuff(unit, debuffIndex)
		
		if icon then
			local frame = self.debuffs.frames[frameIndex]
			frame:SetAlpha(1)
			frame.icon:SetTexture(icon)
			
			frame.cooldown:Show()
			frame.cooldown:SetCooldown(expiration - duration, duration)
			
			if count == 0 then
				frame.count:Hide()
			else 
				frame.count:Show()
				frame.count:SetText(tostring(count))
			end
			
			frameIndex = frameIndex + 1
		end
	end
	
	for index = frameIndex, 5 do
		self.debuffs.frames[index]:SetAlpha(AURA_HIDDEN_ALPHA)
	end
end

local UNIT_SPELLCAST_SUCCEEDED = function(self, unit, spell)

	local spec = SPELLCAST_TO_SPEC[spell]
	
	if spec then
		nameToSpec[UnitName(unit)] = spec
		
		evaluateGroup()
	end
end

local UNIT_HEALTH = function(self, unit)

	if self:GetAttribute("unit") == unit then
		self.healthBar:SetValue(UnitHealth(unit))
	end
end

local UNIT_MAXHEALTH = function(self, unit)

	if self:GetAttribute("unit") == unit then
		self.healthBar:SetMinMaxValues(0, UnitHealthMax(unit))
	end
end

local UNIT_MANA = function(self, unit)

	if self:GetAttribute("unit") == unit then
		self.powerBar:SetValue(UnitMana(unit))
	end
end

local UNIT_MAXMANA = function(self, unit)

	if self:GetAttribute("unit") == unit then
		self.powerBar:SetMinMaxValues(0, UnitManaMax(unit))
	end
end

-----------
-- Frame --
-----------
do 
	local self = AssiduityGroupsFrame
	
	self:SetSize(1, 1)
	self:SetPoint("CENTER", UIParent, "CENTER", 240, -180)
	
	local background = self:CreateTexture(nil, "BACKGROUND")
	background:SetTexture(0, 0, 0)
	background:SetAllPoints()
	
	handleCurrentState()
	
    self:SetScript("OnEvent", function(self, event, ...)
        self[event](self, ...)
    end)    
	self:SetScript("OnUpdate", onUpdate)
	
	self.PARTY_MEMBERS_CHANGED    = PARTY_MEMBERS_CHANGED
	self.PLAYER_ENTERING_WORLD    = PLAYER_ENTERING_WORLD
	self.UNIT_AURA 			      = UNIT_AURA
	self.UNIT_SPELLCAST_SUCCEEDED = UNIT_SPELLCAST_SUCCEEDED
	
	self:RegisterEvent("PARTY_MEMBERS_CHANGED")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
end

--[[
	Create horizontal bar that separated mdps group from rdps group
]]

-- local AssiduityGroupsFrameDpsSeparator = CreateFrame("Frame", nil, AssiduityGroupsFrame)
-- 
-- do 
-- 	local self = AssiduityGroupsFrameDpsSeparator
-- 	
-- 	self:SetSize(BUTTON_WIDTH * 5, SEPARATOR_SIZE)
-- 	self:SetPoint("RIGHT", 
-- 				  AssiduityGroupsFrame, 
-- 				  "LEFT")
-- 	
-- 	local background = self:CreateTexture(nil, "BACKGROUND")
-- 	background:SetTexture(0, 0, 0)
-- 	background:SetAllPoints()
-- end

--local AssiduityGroupsFrameTankHealSeparator = CreateFrame("Frame", nil, AssiduityGroupsFrame)
--
--do 
--	local self = AssiduityGroupsFrameTankHealSeparator
--	
--	self:SetSize(3 * BUTTON_WIDTH, SEPARATOR_SIZE)
--	self:SetPoint("LEFT", 
--				  AssiduityGroupsFrame, 
--				  "RIGHT",
--				  0,
--				  BUTTON_HEIGHT)
--	
--	local background = self:CreateTexture(nil, "BACKGROUND")
--	background:SetTexture(0, 0, 0)
--	background:SetAllPoints()
--end

--do 
--	local self = CreateFrame("Frame", nil, AssiduityGroupsFrame)
--end

local handleAuraFrameCreation = function()

	local result = CreateFrame("Frame", nil, AssiduityGroupsFrame)
	result:SetSize(AURA_SIZE, AURA_SIZE)
	
	local iconTexture = result:CreateTexture()
	iconTexture:SetSize(AURA_SIZE, AURA_SIZE)
	iconTexture:SetAllPoints()
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

local handleFrameCreation = function(frameType)

	local frameColors = {
		["tank"] = {1, 0, 0, BACKGROUND_ALPHA},
		["rdps"] = {0, 0, 1, BACKGROUND_ALPHA},
		["mdps"] = {1, 1, 0, BACKGROUND_ALPHA},
		["heal"] = {0, 1, 0, BACKGROUND_ALPHA}
	}

	local result = CreateFrame("Button", nil, AssiduityGroupsFrame, "SecureUnitButtonTemplate")
	result:SetSize(BUTTON_WIDTH, BUTTON_HEIGHT)
	result:RegisterForClicks("RightButtonDown")
	--						 "MiddleButtonDown",
	--						 "Button4Down",
	--						 "Button5Down")
	
	result:SetAttribute("type", "macro")
	result:SetAttribute("macrotext2", "/use Nature's Swiftness\n/use [@mouseover,exists] Healing Touch")
	
    --result:SetAttribute("helpbutton2", "heal2")
    --result:SetAttribute("*helpbutton5", "heal5")
	
    --result:SetAttribute("spell-heal1", "Abolish Poison")
    --result:SetAttribute("ctrl-spell-heal1", "Regrowth")
    --result:SetAttribute("shift-spell-heal1", "Wild Growth")
    --result:SetAttribute("alt-spell-heal1", "Rejuvenation")
	--
    --result:SetAttribute("spell-heal2", "Rejuvenation")
    --result:SetAttribute("ctrl-spell-heal2", "Nourish")
    --result:SetAttribute("shift-spell-heal2", "Remove Curse")
    --result:SetAttribute("alt-spell-heal2", "Abolish Poison")
	
    --result:SetAttribute("spell-heal2", "Swiftmend")
    --result:SetAttribute("*spell-heal2", "Nourish")
	--
    --result:SetAttribute("spell-heal5", "Wild Growth")
	
	result.UNIT_AURA 	  = CHILD_UNIT_AURA
	result.UNIT_HEALTH 	  = UNIT_HEALTH
	result.UNIT_MAXHEALTH = UNIT_MAXHEALTH
	result.UNIT_MANA 	  = UNIT_MANA
	result.UNIT_MAXMANA   = UNIT_MAXMANA
	
	local background = result:CreateTexture(nil, "BACKGROUND")
	background:SetTexture(unpack(frameColors[frameType]))
	background:SetAllPoints()
	
	local healthBarBackground = result:CreateTexture(nil, "BACKGROUND")
	healthBarBackground:SetTexture(0.2, 0.2, 0.2)
	healthBarBackground:SetSize(BAR_WIDTH, HEALTH_BAR_HEIGHT)
	healthBarBackground:SetPoint("TOPLEFT", 
								 result, 
								 "TOPLEFT",
								 DISTANCE_TO_EDGE, 
								 -DISTANCE_TO_EDGE)
	
	local healthBar = CreateFrame("StatusBar", nil, result) 
	healthBar:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8.blp")
	healthBar:SetOrientation("HORIZONTAL")
	healthBar:SetSize(BAR_WIDTH, HEALTH_BAR_HEIGHT)
	healthBar:SetPoint("TOPLEFT", 
					   result, 
					   "TOPLEFT",
					   DISTANCE_TO_EDGE, 
					   -DISTANCE_TO_EDGE)
	result.healthBar = healthBar
				
	local nameFontString = healthBar:CreateFontString(nil, nil, "AssiduityAuraCountFontLarge")
	nameFontString:SetPoint("CENTER", healthBar)
	result.nameFontString = nameFontString
	
	local powerBar = CreateFrame("StatusBar", nil, result) 
	powerBar:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8.blp")
	powerBar:SetStatusBarColor(0, 1, 1)
	powerBar:SetOrientation("HORIZONTAL")
	powerBar:SetSize(BAR_WIDTH, POWER_BAR_HEIGHT)
	powerBar:SetPoint("TOP", 
					  healthBar, 
					  "BOTTOM",
					  0, 
					  -DISTANCE_TO_EDGE)
	powerBar:SetAlpha(POWER_BAR_ALPHA)
	result.powerBar = powerBar
					  
	local playerBuffs = CreateFrame("Frame", nil, result)
	playerBuffs:SetSize(BAR_WIDTH, AURA_SIZE)
	playerBuffs:SetPoint("TOP",
						 powerBar,
						 "BOTTOM",
						 0,
						 -DISTANCE_TO_EDGE)
	
	local playerBuff1 = handleAuraFrameCreation()
	local playerBuff2 = handleAuraFrameCreation()
	local playerBuff3 = handleAuraFrameCreation()
	local playerBuff4 = handleAuraFrameCreation()
	local playerBuff5 = handleAuraFrameCreation()
	
	playerBuff1:SetPoint("TOPLEFT", 
						 playerBuffs,
						 "TOPLEFT",
						 DISTANCE_TO_EDGE,
						 DISTANCE_TO_EDGE)
	
	position(playerBuff2, "RIGHT", playerBuff1)
	position(playerBuff3, "RIGHT", playerBuff2)
	position(playerBuff4, "RIGHT", playerBuff3)
	position(playerBuff5, "RIGHT", playerBuff4)
	
	playerBuffs.frames = {playerBuff1, playerBuff2, playerBuff3, playerBuff4, playerBuff5}
	
	result.playerBuffs = playerBuffs
	
	
	
	-- Debuffs
	
	local debuffs = CreateFrame("Frame", nil, result)
	debuffs:SetSize(BAR_WIDTH, AURA_SIZE)
	debuffs:SetPoint("TOP",
					 playerBuffs,
					 "BOTTOM",
					 0,
					 -DISTANCE_TO_EDGE)
	
	local debuff1 = handleAuraFrameCreation()
	local debuff2 = handleAuraFrameCreation()
	local debuff3 = handleAuraFrameCreation()
	local debuff4 = handleAuraFrameCreation()
	local debuff5 = handleAuraFrameCreation()
	
	debuff1:SetPoint("TOPLEFT", 
					 debuffs,
					 "TOPLEFT",
					 DISTANCE_TO_EDGE,
					 DISTANCE_TO_EDGE)
	
	position(debuff2, "RIGHT", debuff1)
	position(debuff3, "RIGHT", debuff2)
	position(debuff4, "RIGHT", debuff3)
	position(debuff5, "RIGHT", debuff4)
	
	debuffs.frames = {debuff1, debuff2, debuff3, debuff4, debuff5}
	
	result.debuffs = debuffs
	
	--local portrait = result:CreateTexture(nil, "BACKGROUND")
	--portrait:SetTexture(1, 1, 1)
	--portrait:SetSize(PORTRAIT_SIZE, PORTRAIT_SIZE)
	--portrait:SetPoint("RIGHT", 
	--				  result, 
	--				  "RIGHT",
	--				  -DISTANCE_TO_EDGE, 
	--				  0)
	--result.portrait = portrait
	
    result:SetScript("OnEvent", function(self, event, ...)
        self[event](self, ...)
    end)    
	
	return result
end

--[[
	Position a frame based the type of frames involved.
	
	Params:
		origin: The frame that the 'anchored' will be anchored to.
		point: The origin's side to which 'anchored' will be anchored to.
		anchored: The frame that is getting anchored to 'origin' frame.
]]
do
	local self = AssiduityGroupsFrame

	-- Should have a maximum of 3 tanks
	local tank1 = handleFrameCreation("tank")
	local tank2 = handleFrameCreation("tank")
	local tank3 = handleFrameCreation("tank")
	
	tank3:SetPoint("TOPLEFT", AssiduityGroupsFrame, "BOTTOMRIGHT")
	
	position(tank2, "LEFT", tank3)
	position(tank1, "LEFT", tank2)
	
	tankFrames = { tank1, tank2, tank3 }
	
	-- Usually there's 5, but might have more in Valithria encounter
	local heal1  = handleFrameCreation("heal")
	local heal2  = handleFrameCreation("heal")
	local heal3  = handleFrameCreation("heal")
	local heal4  = handleFrameCreation("heal")
	local heal5  = handleFrameCreation("heal")
	local heal6  = handleFrameCreation("heal")
	local heal7  = handleFrameCreation("heal")
	local heal8  = handleFrameCreation("heal")
	local heal9  = handleFrameCreation("heal")
	
	healFrames = { heal1, heal2, heal3, heal4, heal5, heal6, heal7, heal8, heal9 }
	
	--[[ Positions
		1 - 2 - 7
		3 - 4 - 8
		5 - 6 - 9
	]]
	position(heal1, "LEFT", tank1) 
	position(heal2, "LEFT", heal1)
	position(heal3, "LEFT", heal2)
	position(heal4, "LEFT", heal3)
	position(heal5, "LEFT", heal4)
	position(heal6, "LEFT", heal5)
	position(heal7, "LEFT", heal6)
	position(heal8, "LEFT", heal7)
	position(heal9, "LEFT", heal8)
	
	-- Should have a maximum of 10 rdps

	local rdps1  = handleFrameCreation("rdps")
	local rdps2  = handleFrameCreation("rdps")
	local rdps3  = handleFrameCreation("rdps")
	local rdps4  = handleFrameCreation("rdps")
	local rdps5  = handleFrameCreation("rdps")
	local rdps6  = handleFrameCreation("rdps")
	local rdps7  = handleFrameCreation("rdps")
	local rdps8  = handleFrameCreation("rdps")
	local rdps9  = handleFrameCreation("rdps")
	local rdps10 = handleFrameCreation("rdps")
	
	rdpsFrames = { rdps1, rdps2, rdps3, rdps4, rdps5, rdps6, rdps7, rdps8, rdps9, rdps10 }
	
	position(rdps1,  "BOTTOM", tank3)
	position(rdps2,  "LEFT",   rdps1)
	position(rdps3,  "LEFT",   rdps2)
	position(rdps4,  "LEFT",   rdps3)
	position(rdps5,  "LEFT",   rdps4)
	position(rdps6,  "LEFT",   rdps5)
	position(rdps7,  "LEFT",   rdps6)
	position(rdps8,  "LEFT",   rdps7)
	position(rdps9,  "LEFT",   rdps8)
	position(rdps10, "LEFT",   rdps9)
	
	-- Should have a maximum of 10 mdps
	local mdps1  = handleFrameCreation("mdps")
	local mdps2  = handleFrameCreation("mdps")
	local mdps3  = handleFrameCreation("mdps")
	local mdps4  = handleFrameCreation("mdps")
	local mdps5  = handleFrameCreation("mdps")
	local mdps6  = handleFrameCreation("mdps")
	local mdps7  = handleFrameCreation("mdps")
	local mdps8  = handleFrameCreation("mdps")
	local mdps9  = handleFrameCreation("mdps")
	local mdps10 = handleFrameCreation("mdps")
	
	mdpsFrames = { mdps1, mdps2, mdps3, mdps4, mdps5, mdps6, mdps7, mdps8, mdps9, mdps10 }
	
	position(mdps1, "BOTTOM", rdps1)
	position(mdps2,	 "LEFT",  mdps1)
	position(mdps3,  "LEFT",  mdps2)
	position(mdps4,  "LEFT",  mdps3)
	position(mdps5,  "LEFT",  mdps4)
	position(mdps6,  "LEFT",  mdps5)
	position(mdps7,  "LEFT",  mdps6)
	position(mdps8,  "LEFT",  mdps7)
	position(mdps9,  "LEFT",  mdps8)
	position(mdps10, "LEFT",  mdps9)

end


