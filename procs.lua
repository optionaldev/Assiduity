--[[
    A frame that shows important procs.
]]

------------------------
-- Imports and locals --
------------------------
local debug  = print
local ipairs = ipairs
local pairs  = pairs
local unpack = unpack

local math_floor   = math.floor
local table_insert = table.insert

local GetTime  = GetTime
local UnitBuff = UnitBuff

local _, PLAYER_CLASS = UnitClass( "player" )

local PROCS = {

    ["DEATHKNIGHT"] = {},
    ["DRUID"] = {
        -- "Energized",
        "Soothing",
        "Vicious",
        "Intuition of the Gladiator",
        "Owlkin Frenzy",
        "Eclipse (Solar)",
        "Eclipse (Lunar)",
        "Black Magic",
        "Wrath of Elune",
        "Clearcasting"
    },
    ["HUNTER"] = {},
    ["MAGE"] = {},
    ["PALADIN"] = {},
    ["PRIEST"] = {
        "Energized"
    },
    ["ROGUE"] = {},
    ["SHAMAN"] = {},
    ["WARLOCK"] = {},
    ["WARRIOR"] = {}
}
local TEXTURES = {

    ["DEATHKNIGHT"] = {},
    ["DRUID"] = {
        -- "Interface\\Icons\\achievement_dungeon_ulduar77_25man",
        "Interface\\Icons\\trade_herbalism",
        "Interface\\Icons\\inv_offhand_1h_ulduarraid_d_01",
        "Interface\\Icons\\INV_Relics_IdolofHealth",
        "Interface\\Icons\\Ability_Druid_OwlkinFrenzy",
        "Interface\\Icons\\Ability_Druid_EclipseOrange",
        "Interface\\Icons\\Ability_Druid_Eclipse",
        "Interface\\Icons\\Spell_Shadow_UnstableAffliction_1",
        "Interface\\Icons\\Spell_Nature_Purge",
        "Interface\\Icons\\Spell_Shadow_ManaBurn"
    },
    ["HUNTER"] = {},
    ["MAGE"] = {},
    ["PALADIN"] = {},
    ["PRIEST"] = {
        "Interface\\Icons\\achievement_dungeon_ulduar77_25man"
    },
    ["ROGUE"] = {},
    ["SHAMAN"] = {},
    ["WARLOCK"] = {},
    ["WARRIOR"] = {}
}

PROCS    = PROCS[PLAYER_CLASS]
TEXTURES = TEXTURES[PLAYER_CLASS]

local solarExpirationTime = GetTime()
local lunarExpirationTime

---------------------
-- Local functions --
---------------------

--- Procs

local NPRs_anchorChild = function( self, childPos )

    local child          = self.children[childPos]
    local previous, next = self:getNeighbours( childPos )

    if previous ~= 0 then
        child:SetPoint( "LEFT", self.children[previous], "RIGHT" )
    else
        child:SetPoint( "LEFT", self, "LEFT" )
    end

    if next ~= 0 then
        local nextChild = self.children[next]
        
        nextChild:ClearAllPoints()
        nextChild:SetPoint( "LEFT", child, "RIGHT" )
    end
    
    child:Show()
end

local NPRs_getNeighbours = function( self, childPos ) 

    local previous, next = 0, 0

    for i = 1, childPos - 1 do
        if self.children[i]:GetNumPoints() ~= 0 then
            previous = i
        end
    end
    
    for i = childPos + 1, #self.children do
        if self.children[i]:GetNumPoints() ~= 0 then
            next = i
            break
        end
    end
    
    return previous, next
end

local NPRs_update = function( self )
                
    local children = self.children
    
    for i, spell in ipairs( PROCS ) do
        local child = children[i]
        local _,_,_,count,_,duration,expiration = UnitBuff( "player", spell )
        
        
        if expiration then
            -- if spell == "Eclipse (Lunar)" then
                -- local difference = expiration - solarExpirationTime
                -- expiration = expiration - difference
                -- duration   = duration   - difference
            -- end
            child:update( count, expiration, duration )
            
            if child:GetNumPoints() == 0 then
                self:anchorChild( i )
            end
        else
            child:clear()
            
            if child:GetNumPoints() ~= 0 then
                self:unanchorChild( i )
            end
        end
    end
end

local NPRs_unanchorChild = function( self, childPos )

    local child          = self.children[childPos]
    local previous, next = self:getNeighbours( childPos )

    if next ~= 0 then
        local nextChild = self.children[next]
        
        nextChild:ClearAllPoints()
        if previous ~= 0 then
            nextChild:SetPoint( "LEFT", self.children[previous], "RIGHT" )
        else
            nextChild:SetPoint( "LEFT", self, "LEFT" )
        end
    end
    child:ClearAllPoints()
    child:Hide()
end

--- ProcTemplate

local NPR_clear = function( self )

    self.expiration = nil
end
        
local NPR_update = function( self, count, expiration, duration )

    if count > 1 then
        self.count:SetText( count )
        self.count:Show()
    else
        self.count:Hide()
    end
    
    if expiration ~= self.expiration then
    
        local currentTime = GetTime()
        
        self.expiration = expiration
        self.CD:SetCooldown( expiration - duration, duration )
        TimingLibDelayedHide( self, expiration - GetTime() )
    end
end


-------------
-- Scripts --
-------------
local NPR_OnHide = function( self )
    
    NPRs_unanchorChild( AssiduityProcs, self:GetID() )
end

------------
-- Events --
------------
local NPRs_PLAYER_ENTERING_WORLD = function( self )
    
    self:update()
end

local NPRs_UNIT_AURA = function( self, unit )
    
    if unit == "player" then
        self:update()
    end
end

-----------
-- Frame --
-----------
AssiduityProcs_OnLoad = function( self )

    self.anchorChild   = NPRs_anchorChild
    self.children      = { self:GetChildren() }
    self.getNeighbours = NPRs_getNeighbours
    self.unanchorChild = NPRs_unanchorChild
    self.update        = NPRs_update
    
    
    for i, texture in ipairs( TEXTURES ) do
        self.children[i].iconT:SetTexture( texture )
    end
    
    self.PLAYER_ENTERING_WORLD = NPRs_PLAYER_ENTERING_WORLD
    self.UNIT_AURA             = NPRs_UNIT_AURA
    
    self:RegisterEvent( "PLAYER_ENTERING_WORLD" )
    self:RegisterEvent( "UNIT_AURA" )
    
    self:SetScript( "OnUpdate", AssiduityProcs_OnUpdate )
    
    self:SetScript( "OnEvent", function( self, event, ... )
        self[event]( self, ... )
    end )
end

AssiduityProcTemplate_OnLoad = function( self )
    
    self.clear  = NPR_clear
    self.update = NPR_update
    self.timerF:init()
    
    self:SetScript( "OnHide", NPR_OnHide )
end