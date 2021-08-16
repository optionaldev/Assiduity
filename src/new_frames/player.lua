--[[
    
]]

local debug = print
-- local debug = function() end

------------------------
-- Locals and imports --
------------------------
local PlayerClass = AssiduityGetPlayerLocalizedClass

local HIDDEN_BUFFS = Assiduity.HIDDEN_BUFFS
local SHOWN_BUFFS = Assiduity.SHOWN_BUFFS

local HIDDEN_DEBUFFS = Assiduity.HIDDEN_DEBUFFS

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
    ["bigFrameOffsetH"] = 330,
    ["bigFrameOffsetV"] = 180,
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
        ["textFont"] = "AssiduityIconText",
    },
    [ICON_FRAME_LARGE] = {
        ["textFont"] = "AssiduityIconText",
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
		self.healthSB:register()
		self.powerSB:register()
		
		self:updateAura()
	end
	
	local unregister = function( self )
		self.healthSB:unregister()
		self.powerSB:unregister()
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
        
        self.PLAYER_ENTERING_WORLD = PLAYER_ENTERING_WORLD
        self.UNIT_AURA             = UNIT_AURA  
        self.UNIT_ENERGY           = UNIT_ENERGY
        self.UNIT_MANA             = UNIT_MANA
        
        _, self.class     = UnitClass( "player" )
        self.string       = "UNIT_FRAME_LARGE"
        self.unit         = "player"
        self.updateAura   = updateAura
        
        self:SetAttribute( "unit", "player" )
        self:SetAttribute( "type", "macro" )
        self:SetAttribute( "type1", "target" )
        self:SetAttribute( "ctrl-macrotext3", "/forfeit" )
        self:SetAttribute( "shift-macrotext3", "/run LeaveParty()" )
        
        self:SetScript( "OnEvent", function( self, event, ... )
            self[event]( self, ... )
        end )
        
        self:RegisterForClicks( "AnyUp" )
        self:RegisterEvent( "PLAYER_ENTERING_WORLD" )
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
