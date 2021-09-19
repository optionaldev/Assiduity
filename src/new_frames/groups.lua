
------------------------
-- Locals and imports --
------------------------

local table_insert = table.insert
local table_remove = table.remove
local table_sort   = table.sort
local UnitLocalizedClass = AssiduityGetUnitLocalizedClass
local UnitAuraSource = AssiduityUnitAuraSource

--[[
    2 people in a party:
        num party & real num party = 1
        num raid & real num raid = 0
    2 people in a raid:
        num party & real num party = 1
        num raid & real num raid = 2
    2 people in a raid in different parties
        num party & real num party = 0
        num raid & real num raid = 2
    battleground with 2 people in same group, 14 others in other groups
        num party = 2
        real num party = 0
        num raid = 17
        real num raid = 0
]]
local GetNumRaidMembers = GetNumRaidMembers
local GetRealNumRaidMembers = GetRealNumRaidMembers
local GetRealNumPartyMembers = GetRealNumPartyMembers

local BUTTON_WIDTH = 70
local BUTTON_HEIGHT = 50
local SEPARATOR_SIZE = 7

local DISTANCE_TO_EDGE = 1
local HEALTH_BAR_HEIGHT = 14
local POWER_BAR_HEIGHT = 3
local AURA_SIZE = 15

local RAID_TANK_MIN_HP = 45000
local PARTY_TANK_MIN_HP = 35000

local AURA_HIDDEN_ALPHA  	    = 0
local BACKGROUND_ALPHA   	    = 0.15
local HIDDEN_FRAME_ALPHA 	    = 0.03
local NON_EXISTING_UNIT_ALPHA   = 0
local OUT_OF_RANGE_ALPHA 	    = 0.3
local POWER_BAR_ALPHA    	    = 1

--local AURA_HIDDEN_ALPHA  	  = 1
--local BACKGROUND_ALPHA   	  = 1
--local HIDDEN_FRAME_ALPHA 	  = 1
--local NON_EXISTING_UNIT_ALPHA = 1
--local OUT_OF_RANGE_ALPHA 	  = 1
--local POWER_BAR_ALPHA    	  = 1

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
    There is no perfect method for detecting the 1-2-3 tanks available in the group.
    
    Still experimenting with different things, but as long as there is ambiguity,
    we should take the top 2-3 hp pools in the group.
    
    This might mess up parties, but the priority is having it work in raids.
]]
nameToHealth = {}

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
	["Retribution"] = "mdps",
    ["Unholy"]      = "mdps"
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
	
	["Living Seed"] = "Restoration",
    
    ["Bone Shield"] = "Unholy"
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

local DEBUFFS_TO_IGNORE = {

	["Chill of the Throne"] = 1,
	["Exhaustion"] 			= 1,
	["Weakened Soul"]		= 1
}

local tankFrames = {}
local mdpsFrames = {}
local rdpsFrames = {}
local healFrames = {}
local unclassifiedFrames = {}

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

local handleTableInsertion = function(tbl, unit) 

	for index, existingUnit in ipairs(tbl) do
		if UnitName(unit) < UnitName(existingUnit) then
			table_insert(tbl, index, unit)
			return
		end
	end
	
	table_insert(tbl, unit)
end

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
local applyBaseClasification = function(unit)
	
	local class = UnitLocalizedClass(unit)
	local name = UnitName(unit)
	
	if class == "MAGE" or class == "WARLOCK" or class == "HUNTER" then
		handleTableInsertion(rdpsUnits, unit)
	elseif class == "ROGUE" then
		handleTableInsertion(mdpsUnits, unit)
	elseif class == "DRUID" then
        if UnitManaMax(unit) < 13000 then
			nameToSpec[name] = "Feral"
			handleTableInsertion(unclassifiedUnits, unit)
        elseif UnitAura(unit, "Moonkin Form") then
			handleTableInsertion(rdpsUnits, unit)
			nameToSpec[name] = "Balance"
		elseif UnitAuraSource(unit, "Tree of Life") then
			handleTableInsertion(healUnits, unit)
			nameToSpec[name] = "Restoration"
        else 
			handleTableInsertion(unclassifiedUnits, unit)
		end
	elseif class == "PALADIN" then
		if UnitManaMax(unit) > 15000 then
			handleTableInsertion(healUnits, unit)
			nameToSpec[name] = "Holy"
        else 
			handleTableInsertion(unclassifiedUnits, unit)
		end
	elseif class == "SHAMAN" then
		if UnitAuraSource(unit, "Elemental Oath") then
			handleTableInsertion(rdpsUnits, unit)
			nameToSpec[name] = "Elemental"
		elseif UnitAuraSource(unit, "Unleashed Rage") then
			handleTableInsertion(mdpsUnits, unit)
			nameToSpec[name] = "Enhancement"
		else
			handleTableInsertion(healUnits, unit)
			nameToSpec[name] = "Restoration"
		end
	elseif class == "WARRIOR" and UnitAuraSource(unit, "Rampage") then
		handleTableInsertion(mdpsUnits, unit)
	elseif class == "DEATHKNIGHT" or class == "WARRIOR" then
		--[[
			For DK, it's a bit more tricky because they can be Blood
			tank or dps and Frost tank or dps. Will need to see how 
			we deal with it.
		]]
        handleTableInsertion(unclassifiedUnits, unit)
	elseif class == "PRIEST" then
		if UnitAura(unit, "Shadowform") then
			handleTableInsertion(rdpsUnits, unit)
			nameToSpec[name] = "Shadow"
		else
			--[[
				Here could be disc or holy or an SP not in shadow form currently.
			]]		
			handleTableInsertion(unclassifiedUnits, unit)
		end
	end
end

local removeFromUnclassified = function(unit)
	
	for index, unclassifiedUnit in ipairs(unclassifiedUnits) do
		if unclassifiedUnit == unit then
			table_remove(unclassifiedUnits, index)
			return
		end
	end
end

local handleUnit = function(unit)

	if not UnitExists(unit) then
		return
	end
	applyBaseClasification(unit)
	if not isUnitRoleDiscovered(unit) then
		local spec = nameToSpec[UnitName(unit)]
		if spec then
			local role = specToRole[spec]
			if role then
				removeFromUnclassified(unit)
				if role == "tank" then
					handleTableInsertion(tankUnits, unit)
				elseif role == "rdps" then
					handleTableInsertion(rdpsUnits, unit)
				elseif role == "mdps" then
					handleTableInsertion(mdpsUnits, unit)
				elseif role == "heal" then
					handleTableInsertion(healUnits, unit)
				else 
					print("inexistent role found \"" .. role .. "\"")
				end
			end
		end
	end
end

local evaluateParty = function() 
	
	for index = 1, 4 do
		local unit = "party" .. index
		handleUnit(unit)
	end
	
	--[[ 
		Unlike in raids where "player" gets assigned a raid ID, here we 
		have to handle it like a different entity not part of the party
	]]
	handleUnit("player")
end

local evaluateRaid = function()
	
    nameToHealth = {}
    
    for index = 1, 40 do
        local unit = "raid" .. index
        if UnitExists(unit) then
            table_insert(nameToHealth, {["name"] = UnitName(unit), 
                                        ["maxHealth"] = UnitHealthMax(unit)})
        end
    end
    
	for index = 1, 40 do
		local unit = "raid" .. index
		handleUnit(unit)
	end
    
    table_sort(nameToHealth, function(a, b) return a.maxHealth > b.maxHealth end)
    
    local firstTank
    local secondTank
    local thirdTank
    
    if GetRealNumRaidMembers() ~= 0 then
        local count = GetRealNumRaidMembers()
        firstTank = nameToHealth[1].name
        secondTank = nameToHealth[2].name
        
        if count > 15 then
            thirdTank = nameToHealth[3].name
        end
    elseif GetNumPartyMembers() ~= 0 then
        firstTank = nameToHealth[1].name
    end
    
    --[[
        We expect there to be 1 tank in parties, 2 tanks in 10 man raids and 
        2-3 in 25 man raids (going with 3 just to be safe)
    ]]
   local removeIndex
   for index, unclassified in ipairs(unclassifiedUnits) do
       if UnitName(unclassified) == firstTank then
           table_insert(tankUnits, unclassified)
           removeIndex = index
           break
       end
   end
   table_remove(unclassifiedUnits, removeIndex)
   
   if secondTank then
       for index, unclassified in ipairs(unclassifiedUnits) do
           if UnitName(unclassified) == secondTank then
               table_insert(tankUnits, unclassified)
               removeIndex = index
               break
           end
       end
       table_remove(unclassifiedUnits, removeIndex)
       
       
       if thirdTank then
           for index, unclassified in ipairs(unclassifiedUnits) do
               if UnitName(unclassified) == thirdTank then
                   table_insert(tankUnits, unclassified)
                   removeIndex = index
                   break
               end
           end
           table_remove(unclassifiedUnits, removeIndex)
       end
   end
   
   local remainingUnclassifiedUnits = {}
   
   for index, unclassified in ipairs(unclassifiedUnits) do
       local class = UnitLocalizedClass(unclassified)
       if class == "DEATHKNIGHT" or 
          class == "WARRIOR" or 
          class == "PALADIN" or
          (class == "DRUID" and UnitPowerMax(unclassified, 0) < 15000)
       then
           table_insert(mdpsUnits, unclassified)
       else
           table_insert(remainingUnclassifiedUnits, unclassified)
       end
   end
   
   unclassifiedUnits = remainingUnclassifiedUnits
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


local orderedFrameString = ""
local orderedUnitString = ""
local orderedNameString = ""

printGroupsInfo = function()

    print("updateFrames ordered frames and ordered units:")
    print(orderedFrameString)
    print("---")
    print(orderedUnitString)
    print("---")
    print(orderedNameString)
end

local updateFrames = function(frameList, units, prefix)
	
    
	local orderedFrameList = {}
    local orderedUnits = {}
	
	for index = 1, #units do
		table_insert(orderedFrameList, frameList[index])
        table_insert(orderedUnits, units[index])
	end
	
	table_sort(orderedFrameList, function(a, b) 
        return a.position < b.position 
    end)
    
    table_sort(orderedUnits, function(a, b) 
        local firstName = UnitName(a)
        local secondName = UnitName(b)
        return firstName < secondName
    end)
    
    local frameToUnit = {}
    
	for index = 1, #units do
        local frame = orderedFrameList[index]
        
        if frame then
            frameToUnit[frame] = orderedUnits[index] 
        end
	end
    
	for index, frame in ipairs(frameList) do
		local unit = frameToUnit[frame]
	
		if unit and sUnitExists(unit) then
			local class = UnitLocalizedClass(unit)
			
			if class == nil then
				break
			end
			
			if not CLASS_TO_HEALTHCOLORS[class] then
				print("GROUPS: Found buggy class " .. class)
			end
			local colors = CLASS_TO_HEALTHCOLORS[class]
		
			frame.nameFontString:SetText(UnitName(unit))
			frame:SetAttribute("unit", unit)
			
			frame.healthBar:SetStatusBarColor(unpack(colors))
			frame.healthBar:SetValue(UnitHealth(unit))
			frame.healthBar:SetMinMaxValues(0, UnitHealthMax(unit))
			frame.powerBar:SetValue(UnitMana(unit))
			frame.powerBar:SetMinMaxValues(0, UnitManaMax(unit))
            if UnitIsDeadOrGhost(unit) then
                frame.deadFontString:SetAlpha(1)
            else 
                frame.deadFontString:SetAlpha(0)
            end
			frame:RegisterEvent("UNIT_AURA")
			frame:RegisterEvent("UNIT_HEALTH")
			frame:RegisterEvent("UNIT_MAXHEALTH")
			frame:RegisterEvent("UNIT_MANA")
			frame:RegisterEvent("UNIT_MAXMANA")
			frame:SetAlpha(1)
            frame:Show()
		else
            frame.deadFontString:SetAlpha(0)
			frame:SetAttribute("unit", nil)
			frame:UnregisterEvent("UNIT_AURA")
			frame:UnregisterEvent("UNIT_HEALTH")
			frame:UnregisterEvent("UNIT_MAXHEALTH")
			frame:UnregisterEvent("UNIT_MANA")
			frame:UnregisterEvent("UNIT_MAXMANA")
			frame:SetAlpha(HIDDEN_FRAME_ALPHA)
            frame:Hide()
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
    
    --local alphabeticSort = function(a, b) return UnitName(a)  end 
    --
    --table_sort(tankUnits, function(a, b) return a.maxHealth > b.maxHealth end)
	
	updateFrames(tankFrames, tankUnits, "t")
	updateFrames(healFrames, healUnits, "h")
	updateFrames(mdpsFrames, mdpsUnits, "m")
	updateFrames(rdpsFrames, rdpsUnits, "r")
	updateFrames(unclassifiedFrames, unclassifiedUnits, "u")
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


local handleAura = function(frame, icon, count, duration, expiration)

	frame:SetAlpha(1)
	frame.icon:SetTexture(icon)
	
	frame.cooldown:Show()
	frame.cooldown:SetCooldown(expiration - duration, duration)
	
	if count and count > 1 then
		frame.count:Show()
		frame.count:SetText(tostring(count))
	else 
		frame.count:Hide()
	end
end

local handleCurrentState = function()

	if GetRealNumPartyMembers() == 0 and GetRealNumRaidMembers() == 0 then
		--For some reason this fires even if there are people in the group
        --AssiduityGroupsFrame:Hide()
	elseif not IsInInstance() then
		AssiduityGroupsFrame:SetAlpha(0.5)
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
			frame:SetAlpha(NON_EXISTING_UNIT_ALPHA)
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

	handleCurrentState()
	evaluateGroup()
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
		
			if source and spec and nameToSpec[UnitName(source)] then
            
				nameToSpec[UnitName(source)] = spec
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
			handleAura(frame, icon, count, duration, expiration)
			
			frameIndex = frameIndex + 1
		end
	end
	
	for index = frameIndex, 5 do
		self.playerBuffs.frames[index]:SetAlpha(AURA_HIDDEN_ALPHA)
	end
	
	frameIndex = 1
	
	for debuffIndex = 1, 5 do 
		local name, _, icon, count, _, duration, expiration = UnitDebuff(unit, debuffIndex)
		
		if icon and DEBUFFS_TO_IGNORE[name] == nil then
			local frame = self.debuffs.frames[frameIndex]
			handleAura(frame, icon, count, duration, expiration)
			
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
		if UnitIsDeadOrGhost(unit) then
			self.deadFontString:SetAlpha(1)
		else 
			self.deadFontString:SetAlpha(0)
		end
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
	self:SetPoint("CENTER", UIParent, "CENTER", 12, -180)
	
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

local handleAuraFrameCreation = function(parent)

	local result = CreateFrame("Frame", nil, parent)
	result:SetSize(AURA_SIZE, AURA_SIZE)
	
	local iconTexture = result:CreateTexture()
	iconTexture:SetSize(AURA_SIZE, AURA_SIZE)
	iconTexture:SetAllPoints()
	result.icon = iconTexture
	
	local cooldown = CreateFrame("Cooldown", nil, result, "CooldownFrameTemplate")
	cooldown:SetPoint("CENTER")
	cooldown:SetReverse(true)
	result.cooldown = cooldown
	
	local count = result:CreateFontString(nil, nil, "AssiduityAuraCountFontSmall")
	count:SetPoint("BOTTOMRIGHT", result)
	result.count = count
	
	return result
end

local handleFrameCreation = function(frameType, framePosition)

	local frameColors = {          
		["tank"]         = {1,   0,   0,   BACKGROUND_ALPHA},
		["rdps"]         = {0,   0,   1,   BACKGROUND_ALPHA},
		["mdps"]         = {1,   1,   0,   BACKGROUND_ALPHA},
		["heal"]         = {0,   1,   0,   BACKGROUND_ALPHA},
		["unclassified"] = {0.3, 0.3, 0.3, BACKGROUND_ALPHA},
	}

	local result = CreateFrame("Button", nil, AssiduityGroupsFrame, "SecureUnitButtonTemplate")
	result:SetSize(BUTTON_WIDTH, BUTTON_HEIGHT)
	result:RegisterForClicks("LeftButtonDown",
							 "RightButtonDown")
	--						 "MiddleButtonDown",
	--						 "Button4Down",
	--						 "Button5Down")
	
	result:SetAttribute("type", "macro")
    result:SetAttribute("type1", "target")
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
				
	local nameFontString = healthBar:CreateFontString(nil, nil, "AssiduityAuraCountFontTiny")
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
	
	local playerBuff1 = handleAuraFrameCreation(result)
	local playerBuff2 = handleAuraFrameCreation(result)
	local playerBuff3 = handleAuraFrameCreation(result)
	local playerBuff4 = handleAuraFrameCreation(result)
	local playerBuff5 = handleAuraFrameCreation(result)
	
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
	
	-- Shows when someone is dead for better visibility
	
	local deadFontString = playerBuffs:CreateFontString(nil, nil, "AssiduityAuraCountFontLarge")
	deadFontString:SetPoint("CENTER", playerBuffs)
	deadFontString:SetText("DEAD")
	deadFontString:SetAlpha(0)
	result.deadFontString = deadFontString
	
	-- Debuffs
	
	local debuffs = CreateFrame("Frame", nil, result)
	debuffs:SetSize(BAR_WIDTH, AURA_SIZE)
	debuffs:SetPoint("TOP",
					 playerBuffs,
					 "BOTTOM",
					 0,
					 -DISTANCE_TO_EDGE)
	
	local debuff1 = handleAuraFrameCreation(result)
	local debuff2 = handleAuraFrameCreation(result)
	local debuff3 = handleAuraFrameCreation(result)
	local debuff4 = handleAuraFrameCreation(result)
	local debuff5 = handleAuraFrameCreation(result)
	
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
	
	result.position = framePosition
	
    RegisterUnitWatch(result)
    
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
	local tank1 = handleFrameCreation("tank", 1)
	local tank2 = handleFrameCreation("tank", 2)
	local tank3 = handleFrameCreation("tank", 3)
	
	tank3:SetPoint("TOPLEFT", AssiduityGroupsFrame, "BOTTOMRIGHT")
	
	position(tank2, "LEFT", tank3)
	position(tank1, "LEFT", tank2)
	
	tankFrames = { tank1, tank2, tank3 }
	
	-- Usually there's 5, but might have more in Valithria encounter
	local heal1  = handleFrameCreation("heal", 9)
	local heal2  = handleFrameCreation("heal", 8)
	local heal3  = handleFrameCreation("heal", 7)
	local heal4  = handleFrameCreation("heal", 6)
	local heal5  = handleFrameCreation("heal", 5)
	local heal6  = handleFrameCreation("heal", 4)
	local heal7  = handleFrameCreation("heal", 3)
	local heal8  = handleFrameCreation("heal", 2)
	local heal9  = handleFrameCreation("heal", 1)
	
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

	local rdps1  = handleFrameCreation("rdps", 9)
	local rdps2  = handleFrameCreation("rdps", 8)
	local rdps3  = handleFrameCreation("rdps", 10)
	local rdps4  = handleFrameCreation("rdps", 7)
	local rdps5  = handleFrameCreation("rdps", 11)
	local rdps6  = handleFrameCreation("rdps", 6)
	local rdps7  = handleFrameCreation("rdps", 12)
	local rdps8  = handleFrameCreation("rdps", 5)
	local rdps9  = handleFrameCreation("rdps", 4)
	local rdps10 = handleFrameCreation("rdps", 3)
	local rdps11 = handleFrameCreation("rdps", 2)
	local rdps12 = handleFrameCreation("rdps", 1)
	
	rdpsFrames = { rdps1, rdps2, rdps3, rdps4, rdps5, rdps6, rdps7, rdps8, rdps9, rdps10, rdps11, rdps12 }
	
	position(rdps1,  "BOTTOM", heal1)
	position(rdps2,  "LEFT",   rdps1)
	position(rdps3,  "RIGHT",  rdps1)
	position(rdps4,  "LEFT",   rdps2)
	position(rdps5,  "RIGHT",  rdps3)
	position(rdps6,  "LEFT",   rdps4)
	position(rdps7,  "RIGHT",  rdps5)
	position(rdps8,  "LEFT",   rdps6)
	position(rdps9,  "LEFT",   rdps8)
	position(rdps10, "LEFT",   rdps9)
	position(rdps11, "LEFT",   rdps10)
	position(rdps12, "LEFT",   rdps11)
	
	-- Should have a maximum of 10 mdps
	local mdps1  = handleFrameCreation("mdps", 9)
	local mdps2  = handleFrameCreation("mdps", 8)
	local mdps3  = handleFrameCreation("mdps", 10)
	local mdps4  = handleFrameCreation("mdps", 7)
	local mdps5  = handleFrameCreation("mdps", 11)
	local mdps6  = handleFrameCreation("mdps", 6)
	local mdps7  = handleFrameCreation("mdps", 12)
	local mdps8  = handleFrameCreation("mdps", 5)
	local mdps9  = handleFrameCreation("mdps", 4)
	local mdps10 = handleFrameCreation("mdps", 3)
	local mdps11 = handleFrameCreation("mdps", 2)
	local mdps12 = handleFrameCreation("mdps", 1)
	
	mdpsFrames = { mdps1, mdps2, mdps3, mdps4, mdps5, mdps6, mdps7, mdps8, mdps9, mdps10, mdps11, mdps12 }
	
	position(mdps1,  "BOTTOM", rdps1)
	position(mdps2,	 "BOTTOM", rdps2)
	position(mdps3,  "BOTTOM", rdps3)
	position(mdps4,  "BOTTOM", rdps4)
	position(mdps5,  "BOTTOM", rdps5)
	position(mdps6,  "BOTTOM", rdps6)
	position(mdps7,  "BOTTOM", rdps7)
	position(mdps8,  "BOTTOM", rdps8)
	position(mdps9,  "BOTTOM", rdps9)
	position(mdps10, "BOTTOM", rdps10)
	position(mdps11, "BOTTOM", rdps11)
	position(mdps12, "BOTTOM", rdps12)
	
	
	-- We have these frames to put unclassified players in and try to find patterns to categorize
	
	local unclassified1 = handleFrameCreation("unclassified", 9)
	local unclassified2 = handleFrameCreation("unclassified", 8)
	local unclassified3 = handleFrameCreation("unclassified", 7)
	local unclassified4 = handleFrameCreation("unclassified", 6)
	local unclassified5 = handleFrameCreation("unclassified", 5)
	local unclassified6 = handleFrameCreation("unclassified", 4)
	local unclassified7 = handleFrameCreation("unclassified", 3)
	local unclassified8 = handleFrameCreation("unclassified", 2)
	local unclassified9 = handleFrameCreation("unclassified", 1)
	
	unclassifiedFrames = { unclassified1, unclassified2, unclassified3, unclassified4, unclassified5, unclassified6, unclassified7, unclassified8, unclassified9 }
	
	position(unclassified1, "TOP",  tank1)
	position(unclassified2, "LEFT", unclassified1)
	position(unclassified3, "LEFT", unclassified2)
	position(unclassified4, "LEFT", unclassified3)
	position(unclassified5, "LEFT", unclassified4)
	position(unclassified6, "LEFT", unclassified5)
	position(unclassified7, "LEFT", unclassified6)
	position(unclassified8, "LEFT", unclassified7)
	position(unclassified9, "LEFT", unclassified8)
end


