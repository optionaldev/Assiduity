--[[
    Adds a countdown timer to action bar cooldowns.
    
    To do list:
        - handle adding to action bars dynamically
            ( need an event that fires before PLAYER_ENTERING_WORLD )
        - handle cooldowns that start after usage
]]

local debug = print
--local debug = function() end
------------------------
-- Imports and locals --
------------------------
local AFTER_USE_COOLDOWNS = {

    ["Inner Focus"] = 1,
    ["Prowl"]       = 1,
    ["Stealth"]     = 1,
}

local BUTTONS = {

    MultiBarBottomLeftButton1,
    MultiBarBottomLeftButton2,
    MultiBarBottomLeftButton3,
    MultiBarBottomLeftButton4,
    MultiBarBottomLeftButton5,
    MultiBarBottomLeftButton6,
    MultiBarBottomLeftButton7,
    MultiBarBottomLeftButton8,
    MultiBarBottomLeftButton9,
    MultiBarBottomLeftButton10,
    MultiBarBottomLeftButton11,
    MultiBarBottomLeftButton12,
    
    MultiBarBottomRightButton1,
    MultiBarBottomRightButton2,
    MultiBarBottomRightButton3,
    MultiBarBottomRightButton4,
    MultiBarBottomRightButton5,
    MultiBarBottomRightButton6,
    MultiBarBottomRightButton7,
    MultiBarBottomRightButton8,
    MultiBarBottomRightButton9,
    MultiBarBottomRightButton10,
}

local ipairs = ipairs
local wipe   = wipe

local HasAction            = HasAction         
local GetActionCooldown    = GetActionCooldown 
local GetActionInfo        = GetActionInfo      
local GetItemInfo          = GetItemInfo       
local GetMacroSpell        = GetMacroSpell     
local GetSpellInfo         = GetSpellInfo      
local GetTime              = GetTime           
local TimingLibDelayedHide = TimingLibDelayedHide
local UnitFactionGroup     = UnitFactionGroup  

local math_ceil    = math.ceil 
local table_insert = table.insert
local table_remove = table.remove

local GetInstanceType = AssiduityGetInstanceType

local GUARDIAN_SPIRIT_ID       = 47788
local GUARDIAN_SPIRIT_HEAL_ID  = 48153
local GUARDIAN_SPIRIT_GLYPH_ID = 63231
local PLAYER_NAME              = GetUnitName( "player" )

local lastSentTime = GetTime()
local guardianSpiritRemoved 
local guardianSpiritBloomed
local updateButton

--- table: Keeps a list of buttons currenty being tracked
--- model: { button1, ... }
local actionToButton = {}

---------------
-- Functions --
---------------
local getActualName = function( name )

    if name == "PvP Trinket" then
        local faction = UnitFactionGroup( "player" )
        return "Medallion of the " .. faction
      
    elseif name == "Release of Light" then
        return "Bauble of True Blood"
        
    elseif name == "Master Healthstone" then
        return "Fel Healthstone"
        
    elseif name == "Replenish Mana" then
        return "Mana Sapphire"
		
	elseif name == "Deadly Precision" then
		return "Nevermelting Ice Crystal"
    end
   
    return name
end

---------------------
-- Local functions --
---------------------
local resetTimers = function()

    for _, button in ipairs( BUTTONS ) do
        if button.timerF then
            button.timerF:clear()
        end
    end
end

local formatting = function( self, timer )

    if timer > 60 then
        return math_ceil( timer / 60 ) .. "\""
        
    elseif timer > 20 then
        return math_ceil( timer / 10 ) .. "0'"
        
    elseif timer > 1 then
        return math_ceil( timer )
    else
        return math_ceil( timer * 10 ) / 10
    end
end

getButtonHoldings = function( self )

    for _, button in ipairs( BUTTONS ) do
        local action = button.action
        if HasAction(action) then
            local action, id, _, spellID = GetActionInfo( action )
            
            if action == "item"  then 
                button.holding = GetItemInfo( id ) 
                
            elseif action == "spell" then 
                button.holding = GetSpellInfo( spellID )
            
            elseif action == "macro" then 
                button.holding = GetMacroSpell( id )
            end
            
            if button.holding then
				actionToButton[button.holding] = button
            end
		end
    end
end

local start = function( self, duration )

    self.timerF.coolingT:Show()
    if duration then
        self.timerF:startDuration( duration )
    else
        _, duration = GetActionCooldown( self.action )
        self.timerF:startDuration( duration )
    end
end

-------------
-- Scripts --
-------------
local OnClick = function( self, button )

    if button == "MiddleButton" and lastSentTime + 2 < GetTime() and
        self.timerF.expiration
    then
        lastSentTime = GetTime()
    end
end

local OnHide = function( self )

    resetTimers()
end

local button_OnHide = function( self )

    self.timerF.coolingT:Hide()
end

------------
-- Events --
------------
local ADDON_LOADED = function( self, addon )

    if addon == "Assiduity" then
		debug("addon loaded for action button timers")
        self:UnregisterEvent("ADDON_LOADED")
        
        for i, button in ipairs(BUTTONS) do
            button.start = start
            if button.timerF then
                button.timerF:init(AssiduityLargeYellowFont, formatting)
            end
            button:HookScript("OnClick", OnClick)
            button:HookScript("OnClick", button_OnHide)
			
			--[[ 
				The default blizzard frame already has a cooldown
				We hide that one and replace it with our own, darker, with text 
			]]
            _G[button:GetName() .. "Cooldown"]:SetAlpha(0)
        end
		
		self:RegisterEvent("ADDON_LOADED")
		self:RegisterEvent("ACTIONBAR_HIDEGRID")
		self:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
		self:RegisterEvent("CHAT_MSG_SYSTEM")
		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		self:RegisterEvent("PET_BAR_UPDATE_COOLDOWN")
		self:RegisterEvent("PLAYER_ENTERING_WORLD")
		self:RegisterEvent("UNIT_AURA")
		self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    end
end

local ACTIONBAR_HIDEGRID = function( self )

    getButtonHoldings()
end

--- func: 
local ACTIONBAR_UPDATE_COOLDOWN = function( self )

    if updateButton then
        updateButton:start()
        updateButton = nil
    end
end

local CHAT_MSG_SYSTEM = function( self, message )

    if message == "Duel starting: 1" then
        TimingLibDelayedHide( self, 1 )
    end
end

local COMBAT_LOG_EVENT_UNFILTERED = function( ... )
    
    local self,_,subEvent,_,caster,_,_,_,_,spellID,spellName = ...
    if subEvent == "SPELL_AURA_REMOVED" and caster == PLAYER_NAME then
        if spellID == GUARDIAN_SPIRIT_ID then
            guardianSpiritRemoved = 1
            
        elseif AFTER_USE_COOLDOWNS[spellName] then
            local button = actionToButton[ getActualName( spellName )]
            if button then
                updateButton = button
            end
        end
    elseif subEvent == "SPELL_HEAL" and spellID == GUARDIAN_SPIRIT_HEAL_ID then
        guardianSpiritBloomed = 1
    end
end

local PET_BAR_UPDATE_COOLDOWN = function( self, addon )

    getButtonHoldings()
end

--- @function: Reset timers if entered arena
local PLAYER_ENTERING_WORLD = function( self )
    
	getButtonHoldings()
	
    if GetInstanceType() == "arena" then
        resetTimers()
    end
end

local UNIT_AURA = function( self, unit )
    
    if guardianSpiritRemoved == 1 then
        if not guardianSpiritBloomed and
           ( select( 3, GetGlyphSocketInfo( 1 )) == GUARDIAN_SPIRIT_GLYPH_ID or
             select( 3, GetGlyphSocketInfo( 4 )) == GUARDIAN_SPIRIT_GLYPH_ID or
             select( 3, GetGlyphSocketInfo( 6 )) == GUARDIAN_SPIRIT_GLYPH_ID )
        then
            local button = actionToButton["Guardian Spirit"]
            button:start( 60 )
        end
        guardianSpiritRemoved = nil
        guardianSpiritBloomed = nil
    end
end

--- @function: Ready the spell that will be tracked
local UNIT_SPELLCAST_SUCCEEDED = function( self, unit, action )
    
    if unit == "player" and not AFTER_USE_COOLDOWNS[action] then
        local button = actionToButton[getActualName(action)]
        if button then
            updateButton = button
        end
    end
end
    
-----------
-- Frame --
-----------
local AssiduityActionButtonTimers = CreateFrame( "Frame" )

do
    local self = AssiduityActionButtonTimers
  
    self.ADDON_LOADED                = ADDON_LOADED
    self.ACTIONBAR_HIDEGRID          = ACTIONBAR_HIDEGRID
    self.ACTIONBAR_UPDATE_COOLDOWN   = ACTIONBAR_UPDATE_COOLDOWN
    self.CHAT_MSG_SYSTEM   			 = CHAT_MSG_SYSTEM
    self.COMBAT_LOG_EVENT_UNFILTERED = COMBAT_LOG_EVENT_UNFILTERED
    self.PET_BAR_UPDATE_COOLDOWN     = PET_BAR_UPDATE_COOLDOWN
    self.PLAYER_ENTERING_WORLD       = PLAYER_ENTERING_WORLD
    self.UNIT_AURA                   = UNIT_AURA
    self.UNIT_SPELLCAST_SUCCEEDED    = UNIT_SPELLCAST_SUCCEEDED
    
    self:RegisterEvent("ADDON_LOADED")
    
    self:SetScript( "OnEvent", function( self, event, ... )
        self[event]( self, ... )
    end )
    self:SetScript( "OnHide", OnHide )
end
 
--------------------
-- Slash commands --
--------------------
SLASH_ASSIDUITYACTION1 = "/assiduityaction"
SLASH_ASSIDUITYACTION2 = "/aab"

SlashCmdList["ASSIDUITYACTION"] = function ( msg, editbox )

    if msg == "track" then
        print( "Tracking:", #tracking )
        for i in ipairs( tracking ) do
            print( i, tracking[i], tracking[i].holding )
        end
    
    elseif msg =="timers" then
        print( "Timers: " )
        for _, button in ipairs( BUTTONS ) do
            if button.timer then
                print( button.timer:GetText() )
            end
        end
    
    else
        print("Possible commands: hide, timers, track.")
    end
end
