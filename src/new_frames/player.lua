--[[
    
]]

local debug = print
-- local debug = function() end

------------------------
-- Locals and imports --
------------------------
local PlayerClass = AssiduityGetPlayerLocalizedClass

local HIDDEN_BUFFS = {
	["Aquatic Form"] = 1,
	["Bear Form"] = 1,
	["Blessing of Kings"] = 1,
	["Blessing of Might"] = 1,
	["Blessing of Sanctuary"] = 1,
	["Blessing of Wisdom"] = 1,
	["Cat Form"] = 1,
	["Clearcasting"] = 1,
	["Cozy Fire"] = 1,
	["Gift of the Wild"] = 1,
	["Greater Blessing of Kings"] = 1,
	["Greater Blessing of Might"] = 1,
	["Greater Blessing of Sanctuary"] = 1,
	["Greater Blessing of Wisdom"] = 1,
	["Honorable Defender"] = 1,
	["Horn of Winter"] = 1,
	["Luck of the Draw"] = 1,
    ["Mark of the Wild"] = 1,
	["Master Shapeshifter"] = 1,
	["Prayer of Fortitude"] = 1,
	["Prayer of Shadow Protection"] = 1,
	["Prayer of Spirit"] = 1,
	["Precious's Ribbon"] = 1,
	["Preparation"] = 1,
	["Retribution Aura"] = 1,
	["Swift Flight Form"] = 1,
	["Swift Stormsaber"] = 1,
	["Swift White Mechanostrider"] = 1,
	["Thorns"] = 1,
}

local SHOWN_BUFFS = {
	
}

local BUFF_TO_FILTERED = {

    -- ["Abomination's Might"]         = true,
    -- ["Aquatic Form"]                = true,
    -- ["Arcane Brilliance"]           = true,
    -- ["Arcane Intellect"]            = true,
    -- -- ["Arena Preparation"]           = true,
    -- ["Battle Shout"]                = true,
    -- ["Bear Form"]                   = true,
    -- ["Blessing of Kings"]           = true,
    -- ["Blessing of Wisdom"]          = true,
    -- ["Blood Pact"]                  = true,
    -- ["Cat Form"]                    = true,
    -- ["Clearcasting"]                = true,
    -- ["Commanding Shout"]            = true,
    -- ["Concentration Aura"]          = true,
    -- ["Crusader Aura"]               = true,
    -- ["Dalaran Intellect"]           = true,
    -- ["Dalaran Brilliance"]          = true,
    -- ["Devotion Aura"]               = true,
    -- ["Dire Bear Form"]              = true,
    -- ["Divine Spirit"]               = true,
    -- ["Elemental Oath"]              = true,
    -- ["Energized"]                   = true,
    -- ["Fade"]                        = true,
    -- ["Fel Intelligence"]            = true,
    -- ["Fire Resistance"]             = true,
    -- ["Fire Resistance Aura"]        = true,
    -- ["Fire Shield"]                 = true,
    -- ["Flash of Light"]              = true,
    -- ["Flametongue Totem"]           = true,
    -- ["Focus Magic"]                 = true,
    -- ["Frost Resistance"]            = true,
    -- ["Frost Resistance Aura"]       = true,
    -- ["Gift of the Wild"]            = true,
    -- ["Grace"]                       = true,
    -- ["Greater Blessing of Kings"]   = true,
    -- ["Greater Blessing of Wisdom"]  = true,
    -- ["Heroic Presence"]             = true,
    -- ["Honorless Target"]            = true,
    -- ["Horn of Winter"]              = true,
    -- ["Improved Icy Talons"]         = true,
    -- ["Inspiration"]                 = true,
    -- ["Leader of the Pack"]          = true,
    -- ["Mana Spring"]                 = true,
    -- ["Master Shapeshifter"]         = true,
    -- ["Moonkin Aura"]                = true,
    -- ["Moonkin Form"]                = true,
    -- ["Nature Resistance"]           = true,
    -- ["Power Word: Fortitude"]       = true,
    -- ["Prayer of Fortitude"]         = true,
    -- ["Prayer of Shadow Protection"] = true,
    -- ["Prayer of Spirit"]            = true,
	-- ["Prowl"]						= true,
    -- -- ["Preparation"]                 = true,
    -- ["Rampage"]                     = true,
    -- ["Relentless Survival"]         = true,
    -- ["Replenishment"]               = true,
    -- ["Renewed Hope"]                = true,
    -- ["Retribution Aura"]            = true,
    -- ["Shadow Protection"]           = true,
    -- ["Sheath of Light"]             = true,
    -- ["Stoneskin"]                   = true,
    -- ["Strength of Earth"]           = true,
    -- ["Thorns"]          			= true,
    -- ["Totem of Wrath"]              = true,
    -- ["Travel Form"]                 = true,
    -- ["Tree of Life"]                = true,
    -- ["Trueshot Aura"]               = true,
    -- ["Unending Breath"]             = true,
    -- ["Unleashed Rage"]              = true,
    -- ["Vampiric Embrace"]            = true,
    -- ["Vengeance"]                   = true,
    -- ["Vicious"]                     = true,
    -- ["Vigilance"]                   = true,
    -- ["Water Breathing"]             = true,
    -- ["Water Walking"]               = true,
    -- ["Windfury Totem"]              = true,
    -- ["Wrath of Air Totem"]          = true,
    -- ["Wrath of Elune"]              = true,
    -- [""] = true,
}

local DEBUFF_TO_FILTERED = {

    -- ["Blood Frenzy"]          = true,
    -- ["Death Grip"]            = true,
    -- ["Demoralizing Shout"]    = true,
    -- ["Demoralizing Roar"]     = true,
    -- -- ["Desecration"]           = true,
    -- ["Deserter"]              = true,
    -- ["Drain Life"]            = true,
    -- ["Drain Mana"]            = true,
    -- ["Drain Soul"]            = true,
    -- ["Earth and Moon"]        = true,
    -- ["Earth Shock"]           = true,
    -- ["Ebon Plague"]           = true,
    -- ["Exhaustion"]            = true,
    -- -- ["Expose Armor"]          = true,
    -- ["Forbearance"]           = true,
    -- ["Frost Vulnerability"]   = true,
    -- ["Growl"]                 = true,
    -- ["Heart of the Crusader"] = true,
    -- -- ["Hemorrhage"]            = true,
    -- ["Hellfire"]              = true,
    -- ["Honorless Target"]      = true,
    -- ["Improved Scorch"]       = true,
    -- ["Mangle (Bear)"]         = true,
    -- ["Mangle (Cat)"]          = true,
    -- ["Mind Flay"]             = true,
    -- ["Misery"]                = true,
    -- ["Recently Bandaged"]     = true,
    -- ["Sated"]                 = true,
    -- ["Savage Combat"]         = true,
    -- ["Shadowburn"]            = true,
    -- ["Stormstrike"]           = true,
    -- ["Summon Gargoyle"]       = true,
    -- -- ["Sunder Armor"]          = true,
    -- ["Thunder Clap"]          = true,
    -- ["Totem of Wrath"]        = true,
    -- ["Trauma"]                = true,
    -- ["Vindication"]           = true,
    -- ["Weakened Soul"]         = true,
}

local PLAYER_ALLOWED_BUFFS = {
	-- ["Rejuvenation"] = 1,
	-- ["Regrowth"] = 1,
	-- ["Frenzied Regeneration"] = 1,
	-- ["Prowl"] = 1,
	-- ["Lifebloom"] = 1,
	-- ["Abolish Poison"] = 1
}

local AURA_ROWS     = 3
local AURAS_PER_ROW = 7

local AURA_FRAME_SMALL  = "AURA_FRAME_SMALL"
local AURA_FRAME_LARGE  = "AURA_FRAME_LARGE"
local AURAS_FRAME_SMALL = "AURAS_FRAME_SMALL"
local AURAS_FRAME_LARGE = "AURAS_FRAME_LARGE"  
local BUFFS_FRAME       = "BUFFS_FRAME" 
local DEBUFFS_FRAME     = "DEBUFFS_FRAME" 
local HEALTH_SB_SMALL   = "HEALTH_SB_SMALL"
local HEALTH_SB_LARGE   = "HEALTH_SB_LARGE"
local ICON_FRAME_SMALL  = "ICON_FRAME_SMALL"
local ICON_FRAME_LARGE  = "ICON_FRAME_LARGE" 
local POWER_SB_SMALL    = "POWER_SB_SMALL"
local POWER_SB_LARGE    = "POWER_SB_LARGE"
local UNIT_FRAME_SMALL  = "UNIT_FRAME_SMALL"
local UNIT_FRAME_LARGE  = "UNIT_FRAME_LARGE"
local UNIT_TARGET_FRAME = "UNIT_TARGET_FRAME"

local SETTINGS = {
    ["bgColor"]         = STANDARD_BACKGROUND_COLOR,
    ["bigFrameOffsetH"] = 200,
    ["bigFrameOffsetV"] = 150,
    [AURA_FRAME_SMALL] = {
        ["countFont"]   = "AssiduityAuraCountFontSmall",
        ["countOffset"] = 1,
        ["iconOffset"]  = 2,
        ["size"]        = 15,
    },
    [AURA_FRAME_LARGE] = {
        ["countFont"]   = "AssiduityAuraCountFontLarge",
        ["countOffset"] = 2,
        ["iconOffset"]  = 1.5,
        ["size"]        = 20,
    },
    [AURAS_FRAME_SMALL] = { 
        ["bgOffset"] = SMALL_BACKGROUND_OFFSET,
        ["spacing"]  = SMALL_SPACING,
    },
    [AURAS_FRAME_LARGE] = {
        ["bgOffset"] = LARGE_BACKGROUND_OFFSET,
        ["spacing"]  = LARGE_SPACING,
    },
    [BUFFS_FRAME] = {
        ["bgColor"] = { 0.5, 0.5, 0.5 },
        ["func"]    = UnitBuff,
    },
    [DEBUFFS_FRAME] = {
        ["bgColor"] = { 0, 0, 0 },
        ["func"]    = UnitDebuff,
    },
    [HEALTH_SB_SMALL] = {
        ["textFont"] = "AssiduityHealthStatusBarFontSmall",
    },
    [HEALTH_SB_LARGE] = {
        ["textFont"] = "AssiduityHealthStatusBarFontLarge",
    },
    [ICON_FRAME_SMALL] = {
        ["textFont"] = "AssiduityIconTextFontSmall",
    },
    [ICON_FRAME_LARGE] = {
        ["textFont"] = "AssiduityIconTextFontLarge",
    },
    [POWER_SB_SMALL] = {
        ["textFont"] = "AssiduityPowerStatusBarFontSmall",
    },
    [POWER_SB_LARGE] = {
        ["textFont"] = "AssiduityPowerStatusBarFontLarge",
    },
    [UNIT_FRAME_SMALL] = {
        ["bgOffset"]      = 2,
        ["castOffset"]    = 7,
        ["healthHeight"]  = 25,
        ["height"]        = 38,
        ["spacing"]       = SMALL_SPACING,
        ["width"]         = 180,
    },
    [UNIT_FRAME_LARGE] = {
        ["bgOffset"]      = 3,
        ["castOffset"]    = 10,
        ["healthHeight"]  = 30,
        ["height"]        = 48,
        ["spacing"]       = LARGE_SPACING,
        ["width"]         = 230,
    },
    [UNIT_TARGET_FRAME] = {
        ["bgColor"]  = STANDARD_BACKGROUND_COLOR,
        ["bgOffset"] = LARGE_BACKGROUND_OFFSET,
    },
}


do  --- AssiduityPlayer
    ---------------------
    -- Frame functions --
    ---------------------
    local updateAura = function( self )
    
        local firstAnchor  = self.bgT
        local secondAnchor = self.bgT
		
		local nonPlayerBuffs = self.buffF:getAuras()
        
		self.buffF:fill( nonPlayerBuffs )
		
        if #nonPlayerBuffs ~= 0 then
            firstAnchor = self.buffF
            
            self.buffF:SetPoint( "TOPLEFT", self.bgT, "BOTTOMLEFT",
                                 0, -SETTINGS[self.string].bgOffset )
        end
        
        local playerBuffs = self.playerBuffF:getAuras()
		self.playerBuffF:fill( playerBuffs )
            
		if #playerBuffs ~= 0 then
			secondAnchor = self.playerBuffs
		end
			
        if #playerBuffs == 0 then
            if #nonPlayerBuffs ~= 0 then
                secondAnchor = self.buffF
            end
        else
            secondAnchor = self.playerBuffF
            self.playerBuffF:SetPoint( "TOPLEFT", firstAnchor, "BOTTOMLEFT",
                                       0 , -SETTINGS[self.string].bgOffset )
        end
        
        local debuffs = self.debuffF:getAuras()
		self.debuffF:fill( debuffs )
        
        if #debuffs ~= 0 then
            self.debuffF:SetPoint( "TOPLEFT", secondAnchor, "BOTTOMLEFT",
                                   0, -SETTINGS[ self.string ].bgOffset )
        end
    end

    ------------
    -- Events --
    ------------
    local PLAYER_ENTERING_WORLD = function( self, addonName )

        self.powerSB:refresh()
        self.healthSB:refresh()
        self.manaF:update()
        
        self:updateAura()
    end

    local UNIT_AURA = function( self, unit )
        
        if unit == self.unit then
            self:updateAura()
        end
    end
	

    local UNIT_MANA = function( self, unit )
        
        if unit == self.unit then
            self.powerSB:refresh()
        end
    end

    local UNIT_ENERGY = function( self, unit )
        
        if unit == self.unit then
            self.powerSB:refresh()
        end
    end
	
	local register = function( self )
	
		self:RegisterEvent( "UNIT_AURA" )
		_, self.class = UnitClass( self.unit )
		
		--self.cpF:register()
		--self.nameF:update()
		self.healthSB:register()
		self.powerSB:register()
		
		--self.iconF:updateBuffless()
		--self.targetF:register()
		
		--self:updateAuraFrames()
		self:updateAura()
	end
	
	local unregister = function( self )
		--self.cpF:unregister()
		self.healthSB:unregister()
		self.powerSB:unregister()
		--self.targetF:unregister()
		self:UnregisterEvent( "UNIT_AURA" )
	end
	
	local PLAYER_X_CHANGED = function( self )
	
		if UnitExists( self.unit ) then
			self:register()
			self:Show()
		else
			self:unregister()
			self:Hide()
		end
	end
    
    AssiduityPlayer_OnLoad = function( self )

        local DEBUFFS  = {
			"Moonfire",
			"Insect Swarm",
			"Wrath(Rank 1)"     --- adjust
		}
        
        -- self.PARTY_LEADER_CHANGED   = NPL_PARTY_LEADER_CHANGED
        self.PLAYER_ENTERING_WORLD  = PLAYER_ENTERING_WORLD
        -- self.PLAYER_REGEN_DISABLED  = NPL_PLAYER_REGEN_DISABLED 
        -- self.PLAYER_REGEN_ENABLED   = NPL_PLAYER_REGEN_ENABLED 
        self.UNIT_AURA              = UNIT_AURA  
        self.UNIT_ENERGY            = UNIT_ENERGY
        self.UNIT_MANA            = UNIT_MANA
        
        _, self.class     = UnitClass( "player" )
        self.string       = "UNIT_FRAME_LARGE"
        self.unit         = "player"
        self.updateAura   = updateAura

        -- self.updateLeader = NPL_updateLeader
        
        self:SetAttribute( "unit", "player" )
        self:SetAttribute( "type", "macro" )
        self:SetAttribute( "type1", "target" )
        self:SetAttribute( "ctrl-macrotext3", "/forfeit" )
        self:SetAttribute( "shift-macrotext3", "/run LeaveParty()" )
        
        self:SetScript( "OnEvent", function( self, event, ... )
            self[event]( self, ... )
        end )
        
        self:RegisterForClicks( "AnyUp" )
        -- self:RegisterEvent( "PARTY_LEADER_CHANGED" )
        self:RegisterEvent( "PLAYER_ENTERING_WORLD" )
        -- self:RegisterEvent( "PLAYER_REGEN_DISABLED" )
        -- self:RegisterEvent( "PLAYER_REGEN_ENABLED" )
        self:RegisterEvent( "UNIT_AURA" )
        self:RegisterEvent( "UNIT_MANA" )
        self:RegisterEvent( "UNIT_ENERGY" )
        
        UnitFrameInit( self, "LEFT" )
        
        self:SetPoint( "BOTTOMRIGHT", UIParent, "BOTTOM",
                       -SETTINGS.bigFrameOffsetV, SETTINGS.bigFrameOffsetH )
        
        self.buffF:init(HIDDEN_BUFFS)
        self.playerBuffF:init(nil, PLAYER_ALLOWED_BUFFS)
        self.debuffF:init(DEBUFF_TO_FILTERED)
        
        self.powerSB:register()
        
        self:updateAura()
        --self:updateLeader()
    end
	
    AssiduityTarget_OnLoad = function( self )

        local DEBUFFS  = {
			"Moonfire",
			"Insect Swarm",
			"Wrath(Rank 1)"     --- adjust
		}
        
        -- self.PARTY_LEADER_CHANGED   = NPL_PARTY_LEADER_CHANGED
        self.PLAYER_ENTERING_WORLD  = PLAYER_ENTERING_WORLD
		self.PLAYER_TARGET_CHANGED = PLAYER_X_CHANGED
        self.UNIT_MANA              = UNIT_MANA
        self.UNIT_AURA              = UNIT_AURA
        
        _, self.class     = UnitClass( "target" )
		self.register	  = register
        self.string       = {
			["bgOffset"]      = 3,
			["castOffset"]    = 10,
			["healthHeight"]  = 30,
			["height"]        = 48,
			["spacing"]       = LARGE_SPACING,
			["width"]         = 230,
		}
        self.unit         = "target"
		self.unregister	  = unregister
        self.updateAura   = updateAura
        -- self.updateLeader = NPL_updateLeader
        
        self:SetAttribute( "unit", "target" )
        self:SetAttribute( "type", "macro" )
        -- self:SetAttribute( "type1", "target" )
        -- self:SetAttribute( "ctrl-macrotext3", "/forfeit" )
        -- self:SetAttribute( "shift-macrotext3", "/run LeaveParty()" )
        
        self:SetScript( "OnEvent", function( self, event, ... )
			if self[event] == nil then
				print("player211:")
				print(event)
			end
            self[event]( self, ... )
        end )
        
        self:RegisterForClicks( "AnyUp" )
        -- self:RegisterEvent( "PARTY_LEADER_CHANGED" )
        self:RegisterEvent( "PLAYER_ENTERING_WORLD" )
        self:RegisterEvent( "PLAYER_TARGET_CHANGED" )
        -- self:RegisterEvent( "PLAYER_REGEN_DISABLED" )
        -- self:RegisterEvent( "PLAYER_REGEN_ENABLED" )
        --self:RegisterEvent( "UNIT_AURA" )
        -- self:RegisterEvent( "UNIT_TARGET" )
        
        UnitFrameInit( self, "RIGHT" )
        
        self:SetPoint( "BOTTOMRIGHT", UIParent, "BOTTOM",
                       SETTINGS.bigFrameOffsetV * 3, SETTINGS.bigFrameOffsetH )
        
        -- debug( "player196 self, buffF", self, self.buffF, self.buffF.init )
        
        self.buffF:init( BUFF_TO_FILTERED)
        self.playerBuffF:init( nil, PLAYER_ALLOWED_BUFFS)
        self.debuffF:init(DEBUFF_TO_FILTERED)
        
        self.powerSB:register()
        
        self:updateAura()
        --self:updateLeader()
		
		if not UnitExists( "target" ) then
			self:Hide()
		end
    end
	
    AssiduityFocus_OnLoad = function( self )

        local DEBUFFS  = {
			"Moonfire",
			"Insect Swarm",
			"Wrath(Rank 1)"     --- adjust
		}
		
        -- self.PARTY_LEADER_CHANGED   = NPL_PARTY_LEADER_CHANGED
        self.PLAYER_ENTERING_WORLD  = PLAYER_ENTERING_WORLD
		self.PLAYER_FOCUS_CHANGED  = PLAYER_X_CHANGED
        self.UNIT_MANA              = UNIT_MANA
        self.UNIT_AURA              = UNIT_AURA
        
        _, self.class     = UnitClass( "focus" )
		self.register	  = register
        self.string       = {
			["bgOffset"]      = 3,
			["castOffset"]    = 10,
			["healthHeight"]  = 30,
			["height"]        = 48,
			["spacing"]       = LARGE_SPACING,
			["width"]         = 230,
		}
        self.unit         = "focus"
		self.unregister	  = unregister
        self.updateAura   = updateAura
        -- self.updateLeader = NPL_updateLeader
	
        self:SetAttribute( "unit", "focus" )
        self:SetAttribute( "type", "macro" )
        -- self:SetAttribute( "type1", "target" )
        -- self:SetAttribute( "ctrl-macrotext3", "/forfeit" )
        -- self:SetAttribute( "shift-macrotext3", "/run LeaveParty()" )
        
        self:SetScript( "OnEvent", function( self, event, ... )
			if self[event] == nil then
				print("player211:")
				print(event)
			end
            self[event]( self, ... )
        end )
        
        self:RegisterForClicks( "AnyUp" )
        -- self:RegisterEvent( "PARTY_LEADER_CHANGED" )
        self:RegisterEvent( "PLAYER_ENTERING_WORLD" )
        self:RegisterEvent( "PLAYER_FOCUS_CHANGED" )
        -- self:RegisterEvent( "PLAYER_REGEN_DISABLED" )
        -- self:RegisterEvent( "PLAYER_REGEN_ENABLED" )
        --self:RegisterEvent( "UNIT_AURA" )
        -- self:RegisterEvent( "UNIT_TARGET" )
        
        UnitFrameInit( self, "RIGHT" )
        
        self:SetPoint( "BOTTOMLEFT", UIParent, "BOTTOM",
                       SETTINGS.bigFrameOffsetV, SETTINGS.bigFrameOffsetH )
        
        -- debug( "player196 self, buffF", self, self.buffF, self.buffF.init )
        
        self.buffF:init(BUFF_TO_FILTERED)
     self.playerBuffF:init(nil, PLAYER_ALLOWED_BUFFS)
        self.debuffF:init(DEBUFF_TO_FILTERED)
        
        self.powerSB:register()
        
        self:updateAura()
		
		if not UnitExists( "focus" ) then
			self:Hide()
		end
        --self:updateLeader()
    end
end

--- Mana Bar

local NPMF_refresh = function( self )

    self.SB:SetMinMaxValues( 0, UnitPowerMax( "player", 0 ))
    self.SB:SetValue( UnitPower( "player", 0 ))
end

local NPMF_update = function( self )

    local index = GetShapeshiftForm()
    
    if index == 1 or index == 3 then
        if not self:IsShown() then
            self:RegisterEvent( "UNIT_MANA" )
            self:RegisterEvent( "UNIT_MAXMANA" )
                    
            self:refresh()
    
            self:Show()
        end
    elseif self:IsShown() then
        self:UnregisterEvent( "UNIT_MANA" )
        self:UnregisterEvent( "UNIT_MAXMANA" )
    
        self:Hide()
    end
end


--- Mana Bar

local NPMF_PLAYER_ENTERING_WORLD = function( self )

    self:update()
end

local NPMF_UNIT_MANA = function( self, unit )

    if unit == "player" then
        self.SB:SetValue( UnitPower( "player", 0 ))
    end
end

local NPMF_UNIT_MAXMANA = function( self, unit )

    if unit == "player" then
        self:refresh()
    end
end

local NPMF_UPDATE_SHAPESHIFT_FORM = function( self )

    self:update()
end
 
-----------
-- Frame --
-----------

AssiduityPlayerManaFrame_OnLoad = function( self )

    self.SB:SetStatusBarColor( 0, 0, 0.85 )
    
    self.update  = NPMF_update
    self.refresh = NPMF_refresh
    
    self:RegisterEvent( "PLAYER_ENTERING_WORLD" )
    self:RegisterEvent( "UPDATE_SHAPESHIFT_FORM" )
    
    self:SetScript( "OnEvent", function( self, event, unit )
        self[event]( self, unit )
    end )
    
    self.PLAYER_ENTERING_WORLD  = NPMF_PLAYER_ENTERING_WORLD
    self.UNIT_MANA              = NPMF_UNIT_MANA
    self.UNIT_MAXMANA           = NPMF_UNIT_MAXMANA
    self.UPDATE_SHAPESHIFT_FORM = NPMF_UPDATE_SHAPESHIFT_FORM
end
