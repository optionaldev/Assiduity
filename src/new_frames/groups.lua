
------------------------
-- Locals and imports --
------------------------

local table_insert = table.insert
local UnitLocalizedClass = AssiduityGetUnitLocalizedClass
local UnitAuraSource = AssiduityUnitAuraSource

local BUTTON_WIDTH = 50
local BUTTON_HEIGHT = 40
local SEPARATOR_SIZE = 7

local DISTANCE_TO_EDGE = 1
local HEALTH_BAR_HEIGHT = 14
local POWER_BAR_HEIGHT = 3

local BAR_WIDTH = BUTTON_WIDTH - 2 * DISTANCE_TO_EDGE
--local PORTRAIT_SIZE = HEALTH_BAR_HEIGHT + POWER_BAR_HEIGHT + DISTANCE_TO_EDGE

--local BAR_HEIGHT = PORTRAIT_SIZE + 2 * DISTANCE_TO_EDGE

-- Main frame that will also handle the events
AssiduityGroupsFrame = CreateFrame("Frame", AssiduityGroupsFrame, UIParent)
--AssiduityGroupsFrame:Hide()

--[[
	If we already established a player's spec, aside from accounting
	for spec changes for when players leave or we're about to face
	Valithria, for the most part, specs don't change.
	
	Worth noting that in Druid's case, just because we know he's Feral
	doesn't mean we know his role. Could still be both tank and mdps.
	
	Also, doesn't make sense to add spec to this table if the role
	doesn't change, such as for mages, hunters, rogues & warlocks.
]]
local nameToSpec

local specToRole = {

	["Balance"]	    = "rdps",
	["Elemental"]   = "rdps",
	["Enhancement"] = "mdps",
	["Holy"]		= "heal",
	["Protection"]  = "tank",
	["Restoration"] = "heal",
	["Retribution"] = "mdps"
}

local tankFrames
local mdpsFrames
local rdpsFrames
local healFrames

local tankUnits
local mdpsUnits
local rdpsUnits
local healUnits

--[[ 
	Here we put units that we can't classify based on hp / mana / passive buffs
	We need to wait for them to cast some spell specific for their talents (spec)
]] 
local unclassifiedUnits

---------------
-- Functions --
---------------

--[[
	Clasify units based on simple and obvious metrics. These might not work
	for lesser geared people, especially in RDFs, but it's also less 
	important in RDFs and I might even hide the entire thing in dungeons
	and just use key combos for selecting.
]]
local applyBaseClasification = function(unit)
	
	local class = UnitLocalizedClass(unit)
	local name, _ = UnitName(unit)
	
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
		elseif UnitHealthMax(unit) > 45000 then
			table_insert(tankUnits, unit)
			nameToSpec[name] = "Feral"
		else
			table_insert(unclassifiedUnits, unit)
		end
	elseif class == "PALADIN" then
		if UnitPowerMax(unit) > 15000 then
			table_insert(healUnits, unit)
			nameToSpec[name] = "Holy"
		elseif UnitHealthMax(unit) > 45000 then
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
		elseif UnitPowerMax(unit) < 15000 then
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
		if UnitHealthMax(unit) > 45000 then
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
				Here could be disc or holy, will need to see how to distinguish
			]]		
			table_insert(unclassifiedUnits, unit)
			nameToSpec[name] = "Discipline"
		end
	end
end

local evaluateParty = function() 

end

local evaluateGroup = function()

	if GetRealNumRaidMembers() ~= 0 then
		evaluateRaid()
	elseif GetRealNumPartyMembers() ~= 0 then
		evaluateParty()
	elseif GetNumRaidMembers() ~= 0 then
		evaluateBattleground()
	end
end

evaluateBattleground = function()
	evaluateRaid()
end

local printUnitTable = function(tbl) 

	for _, unit in ipairs(tbl) do
		if UnitExists(unit) then
			print(UnitName(unit) .. " " .. unit .. " " .. UnitLocalizedClass(unit))
		end
	end
end


evaluateRaid = function()

	tankUnits = {}
	mdpsUnits = {}
	rdpsUnits = {}
	healUnits = {}
	unclassifiedUnits = {}
	
	for index = 1, 40 do
		local unit = "raid" .. index
		if UnitExists(unit) then
			applyBaseClasification(unit)
		end
	end
	
	if #unclassifiedUnits ~= 0 then
		AssiduityGroupsFrame:RegisterEvent("UNIT_AURA")
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
		AssiduityGroupsFrame:SetAlpha(0.1)
	elseif not IsInInstance() then
		AssiduityGroupsFrame:SetAlpha(0.4)
	else 
		AssiduityGroupsFrame:SetAlpha(1)
	end
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

	evaluateGroup()
end

local PLAYER_ENTERING_WORLD = function()

	handleCurrentState()
end

local UNIT_AURA = function() 
	-- Pala gaining Vengeance -> retri
end

local UNIT_SPELLCAST_START = function()
	
end

-----------
-- Frame --
-----------
do 
	local self = AssiduityGroupsFrame
	
	self:SetSize(SEPARATOR_SIZE, 4 * BUTTON_HEIGHT + SEPARATOR_SIZE)
	self:SetPoint("CENTER", UIParent, "CENTER", 0, -240)
	
	local background = self:CreateTexture(nil, "BACKGROUND")
	background:SetTexture(0, 0, 0)
	background:SetAllPoints()
	
	handleCurrentState()
	
    self:SetScript("OnEvent", function(self, event, ...)
        self[event](self, ...)
    end)    
	
	self.PARTY_MEMBERS_CHANGED = PARTY_MEMBERS_CHANGED
	self.PLAYER_ENTERING_WORLD = PLAYER_ENTERING_WORLD
	self.UNIT_AURA 			   = UNIT_AURA
	self.UNIT_SPELLCAST_START  = UNIT_SPELLCAST_START
	
	self:RegisterEvent("PARTY_MEMBERS_CHANGED")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
end

--[[
	Create horizontal bar that separated mdps group from rdps group
]]

local AssiduityGroupsFrameDpsSeparator = CreateFrame("Frame", nil, AssiduityGroupsFrame)

do 
	local self = AssiduityGroupsFrameDpsSeparator
	
	self:SetSize(BUTTON_WIDTH * 5, SEPARATOR_SIZE)
	self:SetPoint("RIGHT", 
				  AssiduityGroupsFrame, 
				  "LEFT")
	
	local background = self:CreateTexture(nil, "BACKGROUND")
	background:SetTexture(0, 0, 0)
	background:SetAllPoints()
end

local AssiduityGroupsFrameTankHealSeparator = CreateFrame("Frame", nil, AssiduityGroupsFrame)

do 
	local self = AssiduityGroupsFrameTankHealSeparator
	
	self:SetSize(3 * BUTTON_WIDTH, SEPARATOR_SIZE)
	self:SetPoint("LEFT", 
				  AssiduityGroupsFrame, 
				  "RIGHT",
				  0,
				  BUTTON_HEIGHT)
	
	local background = self:CreateTexture(nil, "BACKGROUND")
	background:SetTexture(0, 0, 0)
	background:SetAllPoints()
end

do 
	local self = CreateFrame("Frame", nil, AssiduityGroupsFrame)
end


local handleFrameCreation = function(frameType)

	local frameColors = {
		["tank"] = { 1, 0, 0},
		["rdps"] = {0, 0, 1},
		["mdps"] = {1, 1, 0},
		["heal"] = {0, 1, 0}
	}

	local result = CreateFrame("Button", nil, AssiduityGroupsFrame, "SecureUnitButtonTemplate")
	result:SetSize(BUTTON_WIDTH, BUTTON_HEIGHT)
	
    result:SetAttribute("unit", "player")
    result:SetAttribute("type", "spell")
	
    result:SetAttribute("*helpbutton1", "heal1")
    result:SetAttribute("*helpbutton2", "heal2")
	
    result:SetAttribute("spell-heal1", "Rejuvenation")
    result:SetAttribute("ctrl-spell-heal1", "Regrowth")
    result:SetAttribute("shift-spell-heal1", "Wild Growth")
    result:SetAttribute("alt-spell-heal1", "Rejuvenation")
	
    result:SetAttribute("spell-heal2", "Lifebloom")
    result:SetAttribute("ctrl-spell-heal2", "Nourish")
    result:SetAttribute("shift-spell-heal2", "Remove Curse")
    result:SetAttribute("alt-spell-heal2", "Abolish Poison")
	
	local background = result:CreateTexture(nil, "BACKGROUND")
	background:SetTexture(0, 0, 0, 0.4)
	background:SetAllPoints()
	
	local healthBar = result:CreateTexture(nil, "BACKGROUND")
	healthBar:SetTexture(unpack(frameColors[frameType]))
	healthBar:SetSize(BAR_WIDTH, HEALTH_BAR_HEIGHT)
	healthBar:SetPoint("TOPLEFT", 
					   result, 
					   "TOPLEFT",
					   DISTANCE_TO_EDGE, 
					   -DISTANCE_TO_EDGE)
				
	
	local powerBar = result:CreateTexture(nil, "BACKGROUND")
	powerBar:SetTexture(0, 1, 1)
	powerBar:SetSize(BAR_WIDTH, POWER_BAR_HEIGHT)
	powerBar:SetPoint("TOP", 
					  healthBar, 
					  "BOTTOM",
					  0, 
					  -1)
	powerBar:SetAlpha(0.5)
					  
	
	--local portrait = result:CreateTexture(nil, "BACKGROUND")
	--portrait:SetTexture(1, 1, 1)
	--portrait:SetSize(PORTRAIT_SIZE, PORTRAIT_SIZE)
	--portrait:SetPoint("RIGHT", 
	--				  result, 
	--				  "RIGHT",
	--				  -DISTANCE_TO_EDGE, 
	--				  0)
	--result.portrait = portrait
	
	return result
end

--[[
	Position a frame based the type of frames involved.
	
	Params:
		origin: The frame that the 'anchored' will be anchored to.
		point: The origin's side to which 'anchored' will be anchored to.
		anchored: The frame that is getting anchored to 'origin' frame.
]]

local OPPOSITE_POINT = {
	["LEFT"]   = "RIGHT",
	["RIGHT"]  = "LEFT",
	["TOP"]    = "BOTTOM",
	["BOTTOM"] = "TOP"
}

local position = function(anchored, point, origin)

	local anchoredPoint = OPPOSITE_POINT[point]
	anchored:SetPoint(anchoredPoint, origin, point)
end

rdps1  = handleFrameCreation("rdps")
do
	local self = AssiduityGroupsFrame

	-- Should have a maximum of 3 tanks
	local tank1 = handleFrameCreation("tank")
	local tank2 = handleFrameCreation("tank")
	local tank3 = handleFrameCreation("tank")
	
	tank1:SetPoint("BOTTOMLEFT", AssiduityGroupsFrameTankHealSeparator, "TOPLEFT")
	
	position(tank2, "RIGHT", tank1)
	position(tank3, "RIGHT", tank2)
	
	tankFrames = { tank1, tank2, tank3 }
	
	-- Should have a maximum of 10 rdps

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
	
	rdps1:SetPoint("TOPRIGHT", AssiduityGroupsFrameDpsSeparator, "BOTTOMRIGHT")
	
	position(rdps2,  "LEFT",  rdps1)
	position(rdps3,  "LEFT",  rdps2)
	position(rdps4,  "LEFT",  rdps3)
	position(rdps5,  "LEFT",  rdps4)
	position(rdps6,  "BOTTOM", rdps1)
	position(rdps7,  "BOTTOM", rdps2)
	position(rdps8,  "BOTTOM", rdps3)
	position(rdps9,  "BOTTOM", rdps4)
	position(rdps10, "BOTTOM", rdps5)
	
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
	
	mdps1:SetPoint("BOTTOMRIGHT", AssiduityGroupsFrameDpsSeparator, "TOPRIGHT")
	
	position(mdps2,	 "LEFT", mdps1)
	position(mdps3,  "LEFT", mdps2)
	position(mdps4,  "LEFT", mdps3)
	position(mdps5,  "LEFT", mdps4)
	position(mdps6,  "TOP",  mdps1)
	position(mdps7,  "TOP",  mdps2)
	position(mdps8,  "TOP",  mdps3)
	position(mdps9,  "TOP",  mdps4)
	position(mdps10, "TOP",  mdps5)

	
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
	heal1:SetPoint("TOPLEFT", AssiduityGroupsFrameTankHealSeparator, "BOTTOMLEFT")
	
	position(heal2,  "RIGHT",  heal1)
	position(heal3,  "BOTTOM", heal1)
	position(heal4,  "BOTTOM", heal2)
	position(heal5,  "BOTTOM", heal3)
	position(heal6,  "BOTTOM", heal4)
	position(heal7,  "RIGHT",  heal2)
	position(heal8,  "RIGHT",  heal4)
	position(heal9,  "RIGHT",  heal6)
end


