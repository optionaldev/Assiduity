
--[[*
    NeemGCD
    
    Api:
    
    To do list:
    
    The global cooldown is generally 1.5 seconds for all classes except rogues, 
    Cat Form druids, and Death Knights, whose abilities are mostly one second 
    global cooldown(reduced to 0.5 in UP). Shaman totems also only trigger a one 
    second global cooldown as well as warlock curses with Amplify Curse . The 
    global cooldown affects the wait for the next ability, so using an item or 
    ability with the standard 1.5 second cooldown will require waiting that long 
    before a 1 second global cooldown ability can be used.
]]

local debug = print
-- local debug = function() end
------------
-- Locals --
------------
local GetInventoryItemID   = GetInventoryItemID
local GetTime              = GetTime
local TimingLibDelayedHide = TimingLibDelayedHide
local TimingLibCancelHide  = TimingLibCancelHide
local UnitAffectingCombat  = UnitAffectingCombat
local UnitBuff             = UnitBuff

local print = print

local math_floor = math.floor

local HASTE_BUFFS   = QueryNeemDB( "HASTE_BUFF_TO_PERCENTAGE" )
local HASTE_TALENTS = QueryNeemDB( "CLASS_TO_HASTE_TALENTS" )

local HASTE_FOR_100_PERCENT = 3279     --- 32.79 haste for 1 percent
local _, PLAYER_CLASS       = UnitClass( "player" )
local WEAPON_SWAP_GCD       = 1.5

if PLAYER_CLASS == "ROGUE" then
    WEAPON_SWAP_GCD = 1
end

local CAST_GCD = {

    ["DEATHKNIGHT"] = {},
    ["DRUID"] = {
        ["Cyclone"]          = 1,
        ["Entangling Roots"] = 1,
        ["Healing Touch"]    = 1,
        ["Hibernate"]        = 1,
        ["Hurricane"]        = 1,
        ["Nourish"]          = 1,
        ["Rebirth"]          = 1,
        ["Regrowth"]         = 1,
        ["Revive"]           = 1,
        ["Starfire"]         = 1,
        ["Tranquility"]      = 1,
        ["Wrath"]            = 1,
    },
    ["HUNTER"] = {},
    ["MAGE"] = {},
    ["PALADIN"] = {},
    ["PRIEST"] = {
        ["Binding Heal"]      = 1,
        ["Flash Heal"]        = 1,
        ["Greater Heal"]      = 1,
        ["Heal"]              = 1,
        ["Holy Fire"]         = 1,
        ["Lesser Heal"]       = 1,
        ["Lightwell"]         = 1,
        ["Mana Burn"]         = 1,
        ["Mass Dispel"]       = 1,
        ["Mind Blast"]        = 1,
        ["Mind Control"]      = 1,
        ["Prayer of Healing"] = 1,
        ["Resurrection"]      = 1,
        ["Shackle Undead"]    = 1,
    },
    ["ROGUE"] = {},
    ["SHAMAN"] = {},
    ["WARLOCK"] = {},
    ["WARRIOR"] = {}
}

local DYNAMIC_GCD = {

    ["DEATHKNIGHT"] = {},
    ["DRUID"] = {
        ["Abolish Poison"]        = 1,
        ["Cure Poison"]           = 1,
        ["Faerie Fire"]           = 1,
        ["Force of Nature"]       = 1,
        ["Gift of the Wild"]      = 1,
        ["Innervate"]             = 1,
        ["Insect Swarm"]          = 1,
        ["Lifebloom"]             = 1,
        ["Mark of the Wild"]      = 1,
        ["Moonfire"]              = 1,
        ["Nature's Grasp"]        = 1,
        ["Rejuvenation"]          = 1,
        ["Remove Curse"]          = 1,
        ["Soothe Animal"]         = 1,
        ["Starfall"]              = 1,
        ["Thorns"]                = 1,
        ["Typhoon"]               = 1,
    },
    ["HUNTER"] = {},
    ["MAGE"] = {},
    ["PALADIN"] = {},
    ["PRIEST"] = {
        ["Abolish Disease"]             = 1,
        ["Circle of Healing"]           = 1,
        ["Cure Disease"]                = 1,
        ["Desperate Prayer"]            = 1,
        ["Devouring Plague"]            = 1,
        ["Dispel Magic"]                = 1,
        ["Divine Hymn"]                 = 1,
        ["Divine Spirit"]               = 1,
        ["Fade"]                        = 1,
        ["Fear Ward"]                   = 1,
        ["Holy Nova"]                   = 1,
        ["Hymn of Hope"]                = 1,
        ["Inner Fire"]                  = 1,
        ["Levitate"]                    = 1,
        ["Mind Sear"]                   = 1,
        ["Mind Soothe"]                 = 1,
        ["Mind Vision"]                 = 1,
        ["Power Word: Fortitude"]       = 1,
        ["Power Word: Shield"]          = 1,
        ["Prayer of Fortitude"]         = 1,
        ["Prayer of Mending"]           = 1,
        ["Prayer of Shadow Protection"] = 1,
        ["Prayer of Spirit"]            = 1,
        ["Psychic Scream"]              = 1,
        ["Renew"]                       = 1,
        ["Shadow Protection"]           = 1,
        ["Shadow Word: Death"]          = 1,
        ["Shadow Word: Pain"]           = 1,
        ["Shadowfiend"]                 = 1,
    },
    ["ROGUE"] = {},
    ["SHAMAN"] = {},
    ["WARLOCK"] = {},
    ["WARRIOR"] = {}
}

local LOWER_GCD = {

    ["Cyclone"] = {
        [35022] = 0.1,
        [35111] = 0.1,
        [41287] = 0.1,
        [41293] = 0.1,
        [51420] = 0.1,
        [51434] = 0.1
    },
}

local STATIC_GCD = {

    ["DEATHKNIGHT"] = {},
    ["DRUID"] = {
        ["Aquatic Form"]          = 1.5,
        ["Bash"]                  = 1.5,
        ["Cat Form"]              = 1.5,
        ["Challenging Roar"]      = 1.5,
        ["Claw"]                  = 1,
        ["Cower"]                 = 1,
        ["Demoralizing Roar"]     = 1.5,
        ["Dire Bear Form"]        = 1.5,
        ["Faerie Fire (Feral)"]   = 1,
        ["Ferocious Bite"]        = 1,
        ["Flight Form"]           = 1.5,
        ["Lacerate"]              = 1.5,
        ["Maim"]                  = 1,
        ["Moonkin Form"]          = 1.5,
        ["Pounce"]                = 1,
        ["Rake"]                  = 1,
        ["Ravage"]                = 1,
        ["Rip"]                   = 1,
        ["Savage Roar"]           = 1,
        ["Shred"]                 = 1,
        ["Swift Flight Form"]     = 1.5,
        ["Swipe (Bear)"]          = 1.5,
        ["Swipe (Cat)"]           = 1,
        ["Travel Form"]           = 1.5,
    },
    ["HUNTER"] = {},
    ["MAGE"] = {},
    ["PALADIN"] = {},
    ["PRIEST"] = {},
    ["ROGUE"] = {
        ["Ambush"]              = 1,
        ["Adrenaline Rush"]     = 1,
        ["Backstab"]            = 1,
        ["Blade Flurry"]        = 1,
        ["Blind"]               = 1,
        ["Cheap Shot"]          = 1,
        ["Deadly Throw"]        = 1,
        ["Dismantle"]           = 1,
        ["Distract"]            = 1,
        ["Envenom"]             = 1,
        ["Eviscerate"]          = 1,
        ["Expose Armor"]        = 1,
        ["Fan of Knives"]       = 1,
        ["Feint"]               = 1,
        ["Garrote"]             = 1,
        ["Gouge"]               = 1,
        ["Kidney Shot"]         = 1,
        ["Killing Spree"]       = 1,
        ["Rupture"]             = 1,
        ["Sap"]                 = 1,
        ["Shiv"]                = 1,
        ["Slice and Dice"]      = 1,
        ["Sinister Strike"]     = 1,
        ["Tricks of the Trade"] = 1,
    },
    ["SHAMAN"] = {},
    ["WARLOCK"] = {},
    ["WARRIOR"] = {}
}

CAST_GCD      = CAST_GCD[PLAYER_CLASS]
DYNAMIC_GCD   = DYNAMIC_GCD[PLAYER_CLASS]
HASTE_TALENTS = HASTE_TALENTS[PLAYER_CLASS]
STATIC_GCD    = STATIC_GCD[PLAYER_CLASS]

-- local countdownEnd

-------------
-- Scripts --
-------------
-- local OnUpdate = function( self, elapsed )

    -- if GetTime() > countdownEnd then
        -- self:SetScript( "OnUpdate", nil )
        -- self.CD:Hide()
    -- end
-- end

local OnEvent = function( self, event, unit, spell )

    if event == "ITEM_UNLOCKED" and UnitAffectingCombat( "player" ) then
        self:start( WEAPON_SWAP_GCD )
    end
    
    if unit ~= "player" then
        return
    end
    
    local castGCD    = CAST_GCD[spell]
    local instantGCD = STATIC_GCD[spell] or DYNAMIC_GCD[spell]
    
    if not castGCD and not instantGCD then
        return
    end
    
    if castGCD and ( event == "UNIT_SPELLCAST_CHANNEL_START" or
                     event == "UNIT_SPELLCAST_START" ) or
       instantGCD and event == "UNIT_SPELLCAST_SUCCEEDED"
    then
        self:start( spell )
        
    elseif castGCD and event == "UNIT_SPELLCAST_INTERRUPTED" then
        self:reset()
    end
end        

---------------------
-- Local functions --
---------------------
--- func: Returns the global cooldown for spells
local getSpellGCD = function( spell )

    if STATIC_GCD[spell] then
        return STATIC_GCD[spell]
    end

    if not CAST_GCD[spell] and not DYNAMIC_GCD[spell] then
        return
    end
    
    local gcd = 1.5
    
    if LOWER_GCD[spell] then
        local value = LOWER_GCD[spell][ GetInventoryItemID( "player", INVSLOT_HAND ) ]
        if value then
            gcd = gcd - value
        end
    end
    
    local buffHastePercent = 0
    local talentPercent    = 0   
    
    for buff, percentage in pairs( HASTE_BUFFS ) do
        if UnitBuff( "player", buff ) then
            buffHastePercent = buffHastePercent + percentage
        end
    end
    
    for i, talent in ipairs( HASTE_TALENTS ) do
        talentPercent = talentPercent + select( 5, GetTalentInfo( talent[1], talent[2] )) * talent[3]
    end
    
    gcd = gcd /(( 1 + talentPercent / 100 ) * ( 1 + buffHastePercent / 100 ) *
                ( 1 + GetCombatRating( CR_HASTE_SPELL ) / HASTE_FOR_100_PERCENT ))
                   
    if gcd < 1 then 
        return 1
    else
        return gcd
    end
end 

---------------------
-- Frame functions --
---------------------
local reset = function( self )

    TimingLibCancelHide( self, gcd )
    self:Hide()
end

local start = function( self, spell )

    local gcd 
    if type( spell ) == "string" then
        gcd = getSpellGCD( spell )
    else
        gcd = spell
    end

    self.CD:SetCooldown( GetTime(), gcd )
    TimingLibDelayedHide( self, gcd )
    
    self:Show()
    -- countdownEnd = GetTime() + gcd
    -- self:SetScript( "OnUpdate", OnUpdate )
end

AssiduityGCD_OnLoad = function( self )

    self.reset = reset
    self.start = start

    self:RegisterEvent( "ITEM_UNLOCKED" )
    self:RegisterEvent( "UNIT_SPELLCAST_CHANNEL_START" )
    self:RegisterEvent( "UNIT_SPELLCAST_INTERRUPTED" )
    self:RegisterEvent( "UNIT_SPELLCAST_START" )
    self:RegisterEvent( "UNIT_SPELLCAST_SUCCEEDED" )
    
	print("GCD LOADED")
	
    self:SetScript( "OnEvent", OnEvent )
end

-----------
-- Hooks --
-----------

-- local gcdx

-- hooksecurefunc( "CooldownFrame_SetTimer", function( _, _, duration ) 

    -- if duration ~= 0 then
        -- if duration >= 1 and duration <= 1.5 then
            -- if gcdx ~= duration then
                -- debug( "gcd110", duration )
            -- end
            -- gcdx = duration
        -- else
            -- gcdx = nil
        -- end
    -- end
-- end
-- )


--------------------
-- Slash commands --
--------------------
SLASH_NEEMGCD1 = "/neemgcd"
SLASH_NEEMGCD2 = "/ng"

SlashCmdList["NEEMGCD"] = function( msg )
    if msg == "hide" then
        --local a = 5
    else 
        print( "Possible neemgcd commands: hide." )
    end
end

