--[[
    
]]

local debug = print
-- local debug = function() end
------------------------
-- Imports and locals --
------------------------
local GetTime        = GetTime

local bit_band   = bit.band
local math_ceil  = math.ceil
local math_floor = math.floor

local ENEMY_PETS = {

    "arenapet1",
    "arenapet2",
    "arenapet3",
    "arenapet4",
    "arenapet5"
}
local IGNORE_INCOMING_EVENTS = {

    ["SPELL_AURA_REMOVED"]    = true,
    ["SPELL_PERIODIC_DAMAGE"] = true
}
local IGNORE_OUTGOING_EVENTS = {

    ["SPELL_AURA_REMOVED"]    = true,
    ["SPELL_CAST_START"]      = true,
    ["SPELL_CAST_FAILED"]     = true,
    ["SPELL_PERIODIC_DAMAGE"] = true,
    ["SPELL_SUMMON"]          = true,
}
local PARTY_UNITS = {

    "party1",
    "party2",
    "party3",
    "party4",
    "partypet1",
    "partypet2",
    "partypet3",
    "partypet4"
}

local PLAYER_NAME = UnitName( "player" )

local nameToUnit = {}
local timer
local unitToName = {}

----------------------
-- Global functions --
----------------------


--- func: Strip the numbers decimals by $precision and depending on the
---       $func 1nil parameter, ceils it or floors it
local math_precision = function( number, precision, formatFunc )

    local multiplier = 1

    for i = 1, precision do
        multiplier = multiplier * 10
    end

    number = number * multiplier

    if formatFunc then
        number = formatFunc( number )
    else
        number = math_ceil( number )
    end

    return number / multiplier
end

---------------------
-- Local functions --
---------------------
--- function:
--- param1: 
--- return1:
local refreshName = function( unit )

    local name = unitToName[unit]
    
    if name then
        nameToUnit[name] = nil
    end
    
    name = UnitName( unit )
    
    if name then
        nameToUnit[name] = unit
        unitToName[unit] = name
    end
end

--------------------
-- Frame function --
--------------------
--- func:
--- param1:
local NC_startTimer = function( self )

    timer = GetTime() + 5.5
    self:Show()
end

-------------
-- Scripts --
-------------
local NC_OnUpdate = function( self )

    -- debug( "ok ?" )
    
    local currentTime = GetTime()
    local difference  = timer - currentTime

    if timer < currentTime then
        self:Hide()
        return
    end
    
    if difference > 1 then
        self.timerFS:SetText( math_floor( difference ))
    else
        self.timerFS:SetText( math_precision( difference, 1 ))
    end
end

------------
-- Events --
------------
local NC_COMBAT_LOG_EVENT_UNFILTERED = function( ... )

    local self,_,subEvent,_,source,sflags,_,target,tflags = ...
    -- debug( subEvent, source, target )
    
    if target and target ~= PLAYER_NAME and not IGNORE_OUTGOING_EVENTS[subEvent]
       and( source == PLAYER_NAME or
            bit_band( sflags, COMBATLOG_OBJECT_AFFILIATION_MINE ) > 0 )
    then
        if bit_band( tflags, COMBATLOG_OBJECT_REACTION_HOSTILE ) > 0 then
            -- debug( "Hostile mofo !" )
            self:startTimer()
            
        elseif nameToUnit[target] and 
               UnitAffectingCombat( nameToUnit[target] ) 
        then
            -- debug( "Friendly mofo !" )
            self:startTimer()
        end
    
    elseif target == PLAYER_NAME and not IGNORE_INCOMING_EVENTS[subEvent] and
           bit_band( sflags, COMBATLOG_OBJECT_REACTION_HOSTILE ) > 0 
    then
        -- debug( "Hostile action !" )
        self:startTimer()
    end
end

local NC_PARTY_MEMBERS_CHANGED = function( self )

    for i,party in ipairs( PARTY_UNITS ) do
        refreshName( party )
    end
end

local NC_PLAYER_FOCUS_CHANGED = function( self )

    refreshName( "focus" )
end

local NC_PLAYER_TARGET_CHANGED = function( self )

    refreshName( "target" )
end

local NC_UPDATE_MOUSEOVER_UNIT = function( self )

    refreshName( "mouseover" )
end
 
local NC_UNIT_TARGET = function( self, unit )

    if ENEMY_PETS[unit] and UnitName( unit.."target" ) == PLAYER_NAME and
       ( UnitName( unit ) == "Treat" or UnitName( unit ) == "Spirit Wolf" )
    then
        -- debug( "Pet targeted player." )
        self:startTimer()
    end
end
 
-----------
-- Frame --
-----------
AssiduityCombat_OnLoad = function( self )

    self:RegisterEvent( "COMBAT_LOG_EVENT_UNFILTERED" )
    self:RegisterEvent( "PARTY_MEMBERS_CHANGED" )
    self:RegisterEvent( "PLAYER_FOCUS_CHANGED" )
    self:RegisterEvent( "PLAYER_TARGET_CHANGED" )
    self:RegisterEvent( "UPDATE_MOUSEOVER_UNIT" )
    
    self.startTimer = NC_startTimer
    
    self:SetScript( "OnEvent",  function( self, event, ... )
        self[event]( self, ... )
    end )
    
    self:SetScript( "OnUpdate", NC_OnUpdate )
    
    self.COMBAT_LOG_EVENT_UNFILTERED = NC_COMBAT_LOG_EVENT_UNFILTERED
    self.PARTY_MEMBERS_CHANGED       = NC_PARTY_MEMBERS_CHANGED
    self.PLAYER_FOCUS_CHANGED        = NC_PLAYER_FOCUS_CHANGED
    self.PLAYER_TARGET_CHANGED       = NC_PLAYER_TARGET_CHANGED
    self.UPDATE_MOUSEOVER_UNIT       = NC_UPDATE_MOUSEOVER_UNIT
end