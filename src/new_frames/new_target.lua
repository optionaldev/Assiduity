

---------------
-- Constants -- 
---------------

local DISTANCE_TO_EDGE = 3
local BAR_WIDTH = 180
local FRIENDLY = "FRIENDLY"
local HEALTH_BAR_HEIGHT = 28
local HOSTILE = "HOSTILE"
local POWER_BAR_HEIGHT = 12
local PORTRAIT_SIZE = HEALTH_BAR_HEIGHT + POWER_BAR_HEIGHT + DISTANCE_TO_EDGE
local TARGET = "target"

-- Tables

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

-------------
-- Imports --
-------------

local UnitLocalizedClass = AssiduityGetUnitLocalizedClass

-----------
-- Frame --
-----------

AssiduityTarget = CreateFrame("Button", "AssiduityNewTarget", UIParent, "SecureUnitButtonTemplate")

---------------
-- Functions --
---------------

local getReaction = function()

	if UnitIsPVPSanctuary(TARGET) == 1 or UnitIsFriend("player", TARGET) then
		return FRIENDLY
	end
	
	return HOSTILE
end

local handleHealth = function(self)

	local class = UnitLocalizedClass(TARGET)
	local colors = CLASS_TO_HEALTHCOLORS[class]
		
	self.healthBar:SetStatusBarColor(unpack(colors))
	self.healthBar:SetMinMaxValues(0, UnitHealthMax(TARGET))
	self.healthBar:SetValue(UnitHealth(TARGET))
end

local handlePower = function(self)
	
	local _, powerType = UnitPowerType(TARGET)
	local colors = POWERTYPE_TO_COLORS[powerType]
	
	self.powerBar:SetStatusBarColor(unpack(colors))
	self.powerBar:SetMinMaxValues(0, UnitManaMax(TARGET))
	self.powerBar:SetValue(UnitMana(TARGET))
end

local updateAura = function(self)
	
	-- TODO
end

local handleTargetChange = function(self)

	if UnitExists(TARGET) then
		self:Show()
		self.nameFontString:SetText(UnitName(TARGET))
		self.background:SetTexture(unpack(REACTION[getReaction()]))
		handleHealth(self)
		handlePower(self)
		self:RegisterEvent("UNIT_AURA")
		self:RegisterEvent("UNIT_HEALTH")
		self:RegisterEvent("UNIT_MANA")
	else 
		self:UnregisterEvent("UNIT_AURA")
		self:UnregisterEvent("UNIT_HEALTH")
		self:UnregisterEvent("UNIT_MANA")
		self:Hide()
	end
end

------------
-- Events --
------------

local PLAYER_TARGET_CHANGED = function(self)
	
	handleTargetChange(self)
end

local UNIT_AURA = function(self, unit)
    
    if unit == self:GetAttribute("unit") then
        updateAura(self)
    end
end

local UNIT_HEALTH = function(self, unit)

	if unit == self:GetAttribute("unit") then
		handleHealth(self)
	end
end

local UNIT_MANA = function(self, unit)
    
    if unit == self:GetAttribute("unit") then
		handlePower(self)
    end
end

do 
	local self = AssiduityTarget
	
	-- Layout
	self:SetSize(BAR_WIDTH + PORTRAIT_SIZE + 3 * DISTANCE_TO_EDGE, 
						   PORTRAIT_SIZE + 2 * DISTANCE_TO_EDGE)

	self:ClearAllPoints()
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
	
	local portrait = self:CreateTexture(nil, "BACKGROUND")
	portrait:SetTexture(1, 1, 1)
	portrait:SetSize(PORTRAIT_SIZE, PORTRAIT_SIZE)
	portrait:SetPoint("RIGHT", 
					  self, 
					  "RIGHT",
					  -DISTANCE_TO_EDGE, 
					  0)
	self.portrait = portrait
	
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
	
	local nameFontString = healthBar:CreateFontString(nil, nil, "AssiduityAuraCountFontLarge")
	nameFontString:SetPoint("CENTER", healthBar)
	self.nameFontString = nameFontString
				
	local powerBar = self:CreateTexture("$parentHealthBar", "BACKGROUND")
	powerBar:SetTexture(0, 1, 1)
	powerBar:SetSize(BAR_WIDTH, POWER_BAR_HEIGHT)
	powerBar:SetPoint("BOTTOMLEFT", 
					  self, 
					  "BOTTOMLEFT",
					  DISTANCE_TO_EDGE, 
					  DISTANCE_TO_EDGE)
	self.powerBar = powerBar
	
	
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
	
	-- Events
	self.PLAYER_TARGET_CHANGED = PLAYER_TARGET_CHANGED
	self.UNIT_AURA             = UNIT_AURA 
	self.UNIT_HEALTH           = UNIT_HEALTH
	self.UNIT_MANA             = UNIT_MANA
	
	self:RegisterEvent("PLAYER_TARGET_CHANGED")
	
	-- Scripts
	
    self:SetScript("OnEvent", function(self, event, ...)
        self[event](self, ...)
    end)
	
	handleTargetChange(self)
end

