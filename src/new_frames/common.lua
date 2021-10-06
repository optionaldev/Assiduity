
------------
-- Locals --
------------

local table_insert = table.insert
local UnitLocalizedClass = Assiduity.UnitLocalizedClass

local FRIENDLY = "FRIENDLY"
local HOSTILE  = "HOSTILE"
local UNIT     = "unit"

--local AURA_DISTANCE_TO_EDGE = 1
--local AURA_SIZE             = 20
--local BAR_WIDTH             = 180
--local DISTANCE_TO_EDGE      = 3
--local HEALTH_BAR_HEIGHT     = 28
--local PLAYER_AURA_SIZE      = 25
--local POWER_BAR_HEIGHT      = 12
--
--local TARGET_FRAME_HEIGHT = 26
--local TARGET_FRAME_WIDTH  = 70
--local TARGET_PORTRAIT_SIZE = TARGET_FRAME_HEIGHT - 2
--local TARGET_HEALTH_BAR_HEIGHT = 13
--local TARGET_BAR_WIDTH = TARGET_FRAME_WIDTH - TARGET_PORTRAIT_SIZE - 3
--local TARGET_POWER_BAR_HEIGHT = TARGET_FRAME_HEIGHT - TARGET_HEALTH_BAR_HEIGHT - 3
--
--local PLAYER_BAR_HEIGHT = PLAYER_AURA_SIZE + 2 * AURA_DISTANCE_TO_EDGE
--local PORTRAIT_SIZE     = HEALTH_BAR_HEIGHT + POWER_BAR_HEIGHT + DISTANCE_TO_EDGE
--
--local FRAME_WIDTH  = BAR_WIDTH + PORTRAIT_SIZE + 3 * DISTANCE_TO_EDGE
--local FRAME_HEIGHT = PORTRAIT_SIZE + 2 * DISTANCE_TO_EDGE

local MEASUREMENTS = {
    ["SMALL"] = {
        ["AURA_DISTANCE_TO_EDGE"] =   1,
        ["AURA_SIZE"]             =  16,
        ["BAR_WIDTH"]             =  89,
        ["CAST_BAR_OFFSET"]       =   7,
        ["DISTANCE_TO_EDGE"]      =   2,
        ["FRAME_HEIGHT"]          =  33,
        ["FRAME_WIDTH"]           = 123,
        ["HEALTH_BAR_HEIGHT"]     =  22,
        ["MINI_AURA"]             =   9,
        ["PLAYER_AURA_SIZE"]      =  17,
        ["PLAYER_BAR_HEIGHT"]     =  19,
        ["PORTRAIT_SIZE"]         =  28,
        ["POWER_BAR_HEIGHT"]      =   5,
        ["TARGET"] = {
            ["BAR_WIDTH"]          = 53,
            ["FRAME_HEIGHT"]       = 28,
            ["FRAME_WIDTH"]        = 82,
            ["HEALTH_BAR_HEIGHT"]  = 13,
            ["PORTRAIT_SIZE"]      = 24,
            ["POWER_BAR_HEIGHT"]   = 10,
        },
    },
    ["LARGE"] = {
        ["AURA_DISTANCE_TO_EDGE"] =   1,
        ["AURA_SIZE"]             =  20,
        ["BAR_WIDTH"]             = 180,
        ["CAST_BAR_OFFSET"]       =  15,
        ["DISTANCE_TO_EDGE"]      =   3,
        ["FRAME_HEIGHT"]          =  47,
        ["FRAME_WIDTH"]           = 230,
        ["HEALTH_BAR_HEIGHT"]     =  28,
        ["MINI_AURA"]             =   9,
        ["PLAYER_AURA_SIZE"]      =  25,
        ["PLAYER_BAR_HEIGHT"]     =  27,
        ["PORTRAIT_SIZE"]         =  41,
        ["POWER_BAR_HEIGHT"]      =  12,
        ["TARGET"] = {
            ["BAR_WIDTH"]          = 53,
            ["FRAME_HEIGHT"]       = 28,
            ["FRAME_WIDTH"]        = 82,
            ["HEALTH_BAR_HEIGHT"]  = 13,
            ["PORTRAIT_SIZE"]      = 24,
            ["POWER_BAR_HEIGHT"]   = 10,
        },
    }
}

local FILTERED_AURA_IDS = {
    [34123] = 1,    -- Druid Tree of Life passive buff
    [59620] = 1,    -- Berserk weapon enchant proc
    [67354] = 1,    -- Idol of Mutilation proc
}

local FILTERED_AURA = {

	["Abomination's Might"] = 1,
    ["Acclimation"] = 1,                    -- Frost dk talent
    ["Aegis"] = 1,                          -- The Black Heart, tank trinket
    ["Amplify Magic"] = 1,
    ["Ancestral Fortitude"] = 1,
    ["Ancestral Fortitude"] = 1,            -- Rsham talent
	["Arcane Brilliance"] = 1,
	["Arcane Empowerment"] = 1,
	["Arcane Intellect"] = 1,
	["Argent Champion"] = 1,
    ["Argent Dawn Commission"] = 1,         -- Level 1 trinket
    ["Argent Valor"] = 1,                   -- Cannoneer trinket proc
	["Aspect of the Beast"] = 1,
	["Aspect of the Dragonhawk"] = 1,
	["Aspect of the Hawk"] = 1,
	["Aspect of the Monkey"] = 1,
	["Aspect of the Wild"] = 1,
	["Battle Shout"] = 1,
	["Berserker Rage"] = 1,
    ["Black Magic"] = 1,                     -- Weapon enchant caster haste
    ["Blade Barrier"] = 1,                   -- DK talent
    ["Blessing of Forgotten Kings"] = 1,
	["Blessing of Kings"] = 1,
	["Blessing of Might"] = 1,
    ["Blessing of the Moon Goddess"] = 1,   -- Idol of Lunar Fury proc
	["Blessing of Sanctuary"] = 1,
	["Blessing of Wisdom"] = 1,
    ["Blood Pact"] = 1,                     -- Warlock imp ability
    ["Bloodrage"] = 1,                      -- Warrior ability
    ["Bloodthirst"] = 1,                    -- Fury war talent
    ["Bloody Vengeance"] = 1,               -- Blood DK talent, 3% extra physical damage, stacks up to 9%, 30s
	["Bone Shield"] = 1,
	["Champion of the Kirin Tor"] = 1,
    ["Chaos Bane"] = 1,                     -- Shadowmourne proc
	["Chill of the Throne"] = 1,
    ["Chilling Knowledge"] = 1,             -- Ashen verdict healer ring
    ["Clearcasting"] = 1,
	["Commanding Shout"] = 1,
	["Concentration Aura"] = 1,
    ["Cozy Fire"] = 1,
    ["Crusader's Glory"] = 1,               -- Trinket proc
    ["Culling the Herd"] = 1,               -- Hunter pet ability?
	["Cultivated Power"] = 1,	-- 
	["Dampen Magic"] = 1,
    ["Demonic Pact"] = 1,                   -- Demo lock talent
	["Demoralizing Roar"] = 1,
	["Devotion Aura"] = 1,
	["Dalaran Brilliance"] = 1,
	["Dalaran Intellect"] = 1,
	["Demon Armor"] = 1,
	["Demonic Circle: Summon"] = 1,
    ["Demonic Knowledge"] = 1,              -- Demo warlock talent
	["Demoralizing Shout"] = 1,
    ["Desolation"] = 1,                     -- Unholy DK talent, 5% additional damage with all attacks, 20s
	["Detect Invisibility"] = 1,
	["Divine Plea"] = 1,
	["Divine Sacrifice"] = 1,
	["Divine Spirit"] = 1,
	["Earth and Moon"] = 1,
	["Earth Shield"] = 1,
	["Earth Shock"] = 1,
    ["Ebon Champion"] = 1,
    ["Ebon Plague"] = 1,                    -- Unholy DK debuff
    ["Edward's Insight"] = 1,               -- Signet of Edward the Odd
    ["Effervescence"] = 1,
	["Elemental Oath"] = 1,
    ["Elemental Devastation"] = 1,          -- Enha shaman talent?
    ["Elusive Power"] = 1,                  -- Abyssal Rune trinket, 590 sp 10s
    ["Energized"] = 1,                      -- Solace
	["Enrage"] = 1,     
    ["Enraged"] = 1,
    ["Enraged Defense"] = 1,                -- Druid feral talent?
	["Enraged Regeneration"] = 1,       
    ["Eradication"] = 1,                    -- Affliction talent, 20% haste 10s
    ["Evasive"] = 1,                        -- Libram of the Eternal Tower relic buff
    ["Executioner"] = 1,                    -- Executioner weapon enchant proc
    ["Expose Weakness"] = 1,                -- Survival hunt talent
	["Fade"] = 1,                           -- Priest ability, reduce threat
	["Fel Armor"] = 1,
	["Fel Intelligence"] = 1,               -- Warlock felhunter ability
    ["Ferocious Inspiration"] = 1,          -- BM hunt talent
	["Fire Resistance"] = 1,
	["Fire Resistance Aura"] = 1,
    ["Fire Shield"] = 1,                    -- Imp ability
	["Fire Ward"] = 1,
	["Flametongue Totem"] = 1,
	["Flask of Endless Rage"] = 1,
    ["Flask of Stoneblood"] = 1,
	["Flask of the Frost Wyrm"] = 1,
    ["Flask of the North"] = 1,
    ["Flurry"] = 1,                         -- Fury war talent, 25% attack speed on next 3 attacks
	["Focus Magic"] = 1,
    ["Focused Will"] = 1,                   -- Disc priest talent
    ["Formidable"] = 1,                     -- Libram of Three Truths proc
	["Fortitude"] = 1,
	["Frenzied Regeneration"] = 1,
	["Frost Resistance"] = 1,
	["Frost Resistance Aura"] = 1,
	["Frost Ward"] = 1,
    ["Frostforged Champion"] = 1,           -- Ashen verdict melee rings (ap & str)
    ["Frostforged Sage"] = 1,               -- Ashen verdict hostile caster ring
    ["Furious"] = 1,                        -- Shaman item idol slot
    ["Furious Gladiator's Libram of Fortitude"] = 1,    
    ["Furious Howl"] = 1,                   -- Hunter pet, wolf ability
	["Hand of Reckoning"] = 1,
	["Hand of Salvation"] = 1,
    ["Heart of the Crusader"] = 1,          -- Ret pala talent
	["Heroic Presence"] = 1,
	["Holy Shield"] = 1,
    ["Holy Strength"] = 1,                  -- Libram of Valiance
    ["Honorable Defender"] = 1,
	["Horn of Winter"] = 1,
	["Hunter's Mark"] = 1,
    ["Hyperspeed Acceleration"] = 1,        -- Engineering hand enchant
	["Gift of the Wild"] = 1,
    ["Glyph of Blocking"] = 1,              -- Warrior glyph
    ["Gylph of Revenge"] = 1,               -- Warrior glyph
    ["Grace"] = 1,                          -- Disc priest talent
	["Greater Blessing of Kings"] = 1,
	["Greater Blessing of Might"] = 1,
	["Greater Blessing of Sanctuary"] = 1,
	["Greater Blessing of Wisdom"] = 1,
    ["Hoarse"] = 1,                         -- Some random debuff
	["Ice Armor"] = 1,                      
    ["Icy Talons"] = 1,                     -- DK talent, 20% attack speed
	["Improved Icy Talons"] = 1,            -- DK talent, 20% attack speed to other party members, 5% extra for DK
    ["Improved Scorch"] = 1,                -- Fire mage talent
    ["Improved Spirit Tap"] = 1,            -- Priest talent
    ["Improved Steady Shot"] = 1,           -- MM hunt talent, 15% extra damage on next Aimed/Arcane/Chimera shot
	["Indomitable"] = 1,                    -- Sigil of the Hanged Man (dk relic)
    ["Infected Wounds"] = 1,
	["Inner Fire"] = 1,
	["Inner Focus"] = 1,
    ["Inspiration"] = 1,                    -- Priest talent
	["Judgement of Light"] = 1,
    ["Judgement of the Just"] = 1,          -- Prot pala talent
	["Judgement of Wisdom"] = 1,
    ["Judgements of the Pure"] = 1,         -- Holy pala talent
    ["Kill Command"] = 1,                   -- Hunter ability
    ["Killing Machine"] = 1,                -- DK talent
    ["Kindred Spirits"] = 1,                -- BM hunt talent, 10% movement speed, pet damage 20% increase
	["Leader of the Pack"] = 1,
    ["Lesser Flask of Toughness"] = 1, 
    ["Life Tap"] = 1,                       -- Warlock glyph, 
	["Lightning Shield"] = 1,
    ["Lightning Speed"] = 1,                -- Mongoose weapon enchant prot
    ["Lightweave"] = 1,                     -- Tailoring back enchant proc
	["Living Seed"] = 1,
    ["Luck of the Draw"] = 1,               -- RDF buff
	["Mage Armor"] = 1,
	["Mana Spring"] = 1,
	["Mark of the Wild"] = 1,
    ["Master Demonologist"] = 1,            -- Demo  lock talent
    ["Master of Subtlety"] = 1,             -- Sub rogue talent
	["Master Shapeshifter"] = 1,
    ["Misery"] = 1,                         -- Spriest talent
	["Molten Armor"] = 1,
    ["Molten Core"] = 1,                    -- Demo lock talent
	["Moonkin Aura"] = 1,
	["Nature Resistance"] = 1,
    ["Omen of Doom"] = 1,                   -- Druid T10 4 piece set bonus proc
    ["Power Word: Fortitude"] = 1,
	["Prayer of Fortitude"] = 1,
	["Prayer of Shadow Protection"] = 1,
	["Prayer of Spirit"] = 1,
	["Precious's Ribbon"] = 1,
    ["Precognition"] = 1,                   -- Sigil of the Bone Gryphon (dk relic)
    ["Pyroclasm"] = 1,                      -- Warlock
    ["Quad Core"] = 1,                      -- Mage tier 4 piece set bonus when casting Mirror Image
	["Rampage"] = 1,
    ["Rapid Killing"] = 1,                  -- Hunt talent 
    ["Rapid Recuperation"] = 1,             -- MM hunt talent
    ["Rage of the Fallen"] = 1,             -- Herkuml War Token trinket proc
    ["Reckoning"] = 1,                      -- Prot pala talent, next 4 swings generate extra attack
    ["Redoubt"] = 1,                        -- Prot pala talent
    ["Rejuvenating"] = 1,                   -- Idol of Flaring Growth
	["Renewed Hope"] = 1,
    ["Replenishment"] = 1,                  -- 1% max mana every 5s
	["Retribution Aura"] = 1,
    ["Revitalized"] = 1,                    -- Purified Lunar Dust proc
    ["Roar of Sacrifice"] = 1,              -- BM pet ability
    ["Runic Return"] = 1,                   -- DK talent???
    ["Savage Combat"] = 1,                  -- Combat rogue talent
    ["Savage Defense"] = 1,                 -- Feral druid talent (Savage Fury)
	["Scorpid Sting"] = 1,
    ["Seal of Light"] = 1,
    ["Seal of the Pantheon"] = 1,           -- Tank trinket, 3k armor, 20s
	["Sentry Totem"] = 1,
    ["Shadow Embrace"] = 1,                 -- Aff lock talent
    ["Shadow Mastery"] = 1,                 -- Aff lock talent
    ["Shadow Protection"] = 1,
	["Shadow Resistance Aura"] = 1,
	["Shadow Ward"] = 1,
    ["Shadow Weaving"] = 1,                 -- Spriest talent
    ["Shadowy Insight"] = 1,                -- Glyph of Shadow (priest)
    ["Shield Block"] = 1,
	["Shield of Righteousness"] = 1,
    ["Slam"] = 1,                           -- Fury war talent (Bloodsurge)
    ["Sniper Training"] = 1,                -- Survival hunt talent
    ["Snow of Faith"] = 1,              
    ["Soothing"] = 1,                       -- Idol of the Black Widow 
    ["Soul Link"] = 1,                      -- Warlock pet ability
    ["Spirit Tap"] = 1,                     -- Priest talent
    ["Spiritual Trance"] = 1,               -- Totem of Calming Tides relic buff
	["Stamina"] = 1,                        -- scroll buff
    ["Stoneskin"] = 1,
	["Strength of Earth"] = 1,
	["Strength of Wrynn"] = 1,
    ["Sword and Board"] = 1,                -- Prot warrior talent, refresh Shield Slam ability
	["Sunder Armor"] = 1,
    ["Surge of Power"] = 1,                 -- 1/2 of the DFO buffs
    ["Swordguard Embroidery"] = 1,          -- Tailoring back enchant?
    ["Thorns"] = 1,
    ["Thunder Clap"] = 1,
	["Tiger's Fury"] = 1,
	["Totem of Wrath"] = 1,
    ["Trauma"] = 1,                         -- Arms war talent
	["Trueshot Aura"] = 1,
    ["Unending Breath"] = 1,                -- Warlock ability
    ["Unholy Force"] = 1,                   -- Sigil of Virulence
    ["Unleashed Rage"] = 1,                 -- Enha shammy passive talent
    ["Vampiric Embrace"] = 1,               -- Spriest talent
    ["Vengeance"] = 1,
    ["Vicious"] = 1,                        -- Idol of the Lunar Eclipse
	["Vigilance"] = 1,
    ["Vindication"] = 1,                    -- Ret pala talent
    ["Volcanic Fury"] = 1,                  -- Totem of Quaking Earth
    ["Water Breathing"] = 1,                -- Shaman ability
	["Water Shield"] = 1,
	["Well Fed"] = 1,
	["Wild Growth"] = 1,
	["Windfury Totem"] = 1,
    ["Winter's Chill"] = 1,                 -- Frost mage talent
	["Wrath of Air Totem"] = 1,
	["Wyrmrest Champion"] = 1
}

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


local OPPOSITE_POINT = {

	["LEFT"]   = "RIGHT",
	["RIGHT"]  = "LEFT",
	["TOP"]    = "BOTTOM",
	["BOTTOM"] = "TOP"
}

local DEBUFF_TYPE_TO_TEXTURE = {

    ["Curse"]    = {1, 0, 1},
    ["Disease"]  = {1, 1, 0},
    ["Magic"]    = {0, 0, 1},
    ["Poison"]   = {0, 1, 0}
}

local CLASS_TO_ICON = {

    ["Army of the Dead Ghoul"] = "Interface\\Icons\\Spell_DeathKnight_ArmyOfTheDead",
    ["Ebon Gargoyle"]          = "Interface\\Icons\\Ability_Hunter_Pet_Bat",
    ["Risen Ghoul"]            = "Interface\\Icons\\Spell_Shadow_AnimateDead",
    ["Rune Weapon"]            = "Interface\\Icons\\INV_Sword_07",
    ["Shadowfiend"]            = "Interface\\Icons\\Spell_Shadow_Shadowfiend",
    ["Spirit Wolf"]            = "Interface\\Icons\\Spell_Shaman_FeralSpirit",
    ["Treant"]                 = "Interface\\Icons\\Ability_Druid_ForceofNature",
    ["Water Elemental"]        = "Interface\\Icons\\Spell_Frost_SummonWaterElemental_2"
}

local FAMILY_TO_ICON = {

    ["Felguard"]   = "Interface\\Icons\\Spell_Shadow_SummonFelGuard",
    ["Felhunter"]  = "Interface\\Icons\\Spell_Shadow_SummonFelHunter",
    ["Ghoul"]      = "Interface\\Icons\\Spell_Shadow_AnimateDead",
    ["Imp"]        = "Interface\\Icons\\Spell_Shadow_SummonImp",
    ["Succubus"]   = "Interface\\Icons\\Spell_Shadow_SummonSuccubus",
    ["Voidwalker"] = "Interface\\Icons\\Spell_Shadow_SummonVoidWalker"
}

local COLORS = {

    ["BLACK"]  = {   0,   0,   0},
    ["BLUE"]   = {   0,   0, 200},
    ["GREEN"]  = {   0, 200,   0},
    ["PURPLE"] = { 200,   0, 255},
    ["RED"]    = { 200,   0,   0},
    ["WHITE"]  = { 255, 255, 255},
}

local UNIT_TO_SETUP = {
--- unit          = { txt, bgColor,       textColor    },
    ["arena1"]    = { "1", COLORS.RED,    COLORS.BLACK },
    ["arena2"]    = { "2", COLORS.RED,    COLORS.BLACK },
    ["arena3"]    = { "3", COLORS.RED,    COLORS.BLACK },
    ["arena4"]    = { "4", COLORS.RED,    COLORS.BLACK },
    ["arena5"]    = { "5", COLORS.RED,    COLORS.BLACK },
    
    ["arenapet1"] = { "1", COLORS.PURPLE, COLORS.WHITE },
    ["arenapet2"] = { "2", COLORS.PURPLE, COLORS.WHITE },
    ["arenapet3"] = { "3", COLORS.PURPLE, COLORS.WHITE },
    ["arenapet4"] = { "4", COLORS.PURPLE, COLORS.WHITE },
    ["arenapet5"] = { "5", COLORS.PURPLE, COLORS.WHITE },
    
    ["party1"]    = { "1", COLORS.GREEN,  COLORS.BLACK },
    ["party2"]    = { "2", COLORS.GREEN,  COLORS.BLACK },
    ["party3"]    = { "3", COLORS.GREEN,  COLORS.BLACK },
    ["party4"]    = { "4", COLORS.GREEN,  COLORS.BLACK },
    
    ["partypet1"] = { "1", COLORS.BLUE,   COLORS.WHITE },
    ["partypet2"] = { "2", COLORS.BLUE,   COLORS.WHITE },
    ["partypet3"] = { "3", COLORS.BLUE,   COLORS.WHITE },
    ["partypet4"] = { "4", COLORS.BLUE,   COLORS.WHITE },
    
    ["player"]    = { "P", COLORS.WHITE,  COLORS.BLACK },
    ["target"]    = { "G", COLORS.WHITE,  COLORS.BLACK },
    ["focus"]     = { "F", COLORS.WHITE,  COLORS.BLACK },
}

local VALID_UNITS = {

    "arena1",
    "arena2",
    "arena3",
    "arena4",
    "arena5",
    "arenapet1",
    "arenapet2",
    "arenapet3",
    "arenapet4",
    "arenapet5",

    "party1",
    "party2",
    "party3",
    "party4",
    "partypet1",
    "partypet2",
    "partypet3",
    "partypet4",

    "player",
    "focus",
    "target"
}

-------------
-- Imports --
-------------

local UnitLocalizedClass = AssiduityGetUnitLocalizedClass

---------------
-- Functions --
---------------

local getReaction = function(self, optionalUnit)

    local unit

    if optionalUnit then
        unit = optionalUnit
    else 
        unit = self:GetAttribute(UNIT)
    end

    if UnitIsPVPSanctuary(unit) == 1 or UnitIsFriend("player", unit) then
        return FRIENDLY
    end

    return HOSTILE
end

local position = function(anchored, point, origin)

    local anchoredPoint = OPPOSITE_POINT[point]
    anchored:SetPoint(anchoredPoint,
                      origin,
                      point,
                      1,
                      0)
end

local handleAuraFrameCreation = function(parent, size)

    local result = CreateFrame("Button", nil, parent)
    result:SetSize(size, size)

    local background = result:CreateTexture(nil, "BACKGROUND")
    background:SetSize(size, size)
    background:SetAllPoints()
    result.background = background

    local iconTexture = result:CreateTexture()
    iconTexture:SetSize(size - 2, size - 2)
    iconTexture:SetPoint("CENTER")
    iconTexture:SetAlpha(0.9)
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

local handleHealth = function(self)

    local unit = self:GetAttribute(UNIT)

    local class = UnitLocalizedClass(unit)
    local colors = CLASS_TO_HEALTHCOLORS[class]

    if colors then
        local health = UnitHealth(unit)
        local maxHealth = UnitHealthMax(unit)
        
        local percentage 
        local value
        
        if maxHealth > 3000 then
            value = tostring(math.floor(maxHealth / 1000) .. "k")
        else
            value = maxHealth
        end
        
        if maxHealth > 0 then
            percentage = tostring(math.floor((health / maxHealth) * 100) .. "%")
        else
            percentage = ""
        end
        
        self.healthBar:SetStatusBarColor(unpack(colors)) -- bug?
        self.healthBar:SetMinMaxValues(0, maxHealth)
        self.healthBar:SetValue(health)
        
        if self.healthValueFontString then
            self.healthValueFontString:SetText(tostring(value))
            self.healthPercentageFontString:SetText(percentage)
        end
    end
end

local handlePower = function(self)

    local unit = self:GetAttribute(UNIT)

    local _, powerType = UnitPowerType(unit)

    if powerType then
        local colors = POWERTYPE_TO_COLORS[powerType]
        
        if colors then
            self.powerBar:SetStatusBarColor(unpack(colors))
        end
    end
    
    local power = UnitMana(unit)
    
    if power > 3000 then
        value = tostring(math.floor(power / 1000) .. "k")
    else
        value = tostring(power)
    end
    
    if self.powerValueFontString then
        self.powerValueFontString:SetText(value)
    end
    
    self.powerBar:SetMinMaxValues(0, UnitManaMax(unit))
    self.powerBar:SetValue(power)
end

local createAuraFrames = function(self, parent, size)

    local aura1 = handleAuraFrameCreation(self, size)
    local aura2 = handleAuraFrameCreation(self, size)
    local aura3 = handleAuraFrameCreation(self, size)
    local aura4 = handleAuraFrameCreation(self, size)
    local aura5 = handleAuraFrameCreation(self, size)
    local aura6 = handleAuraFrameCreation(self, size)
    local aura7 = handleAuraFrameCreation(self, size)
    local aura8 = handleAuraFrameCreation(self, size)
    local aura9 = handleAuraFrameCreation(self, size)

    aura1:SetPoint("TOPLEFT",
                   parent,
                   "TOPLEFT",
                   self.MEASUREMENTS.AURA_DISTANCE_TO_EDGE,
                   -self.MEASUREMENTS.AURA_DISTANCE_TO_EDGE)

    position(aura2, "RIGHT", aura1)
    position(aura3, "RIGHT", aura2)
    position(aura4, "RIGHT", aura3)
    position(aura5, "RIGHT", aura4)
    position(aura6, "RIGHT", aura5)
    position(aura7, "RIGHT", aura6)
    position(aura8, "RIGHT", aura7)
    position(aura9, "RIGHT", aura8)

    parent.frames = {aura1, aura2, aura3, aura4, aura5, aura6, aura7, aura8, aura9}
end

--[[
    @auraFunction: can be either UnitBuff or UnitDebuff

    @playerInclusion:
        "INCLUDED"  -- all auras including those cast by "player"
        "EXCLUDED"  -- all auras except those cast by "player"
        "EXCLUSIVE" -- only auras that were cast by "player"
]]
local getAuras = function(self, auraFunction, playerInclusion)

    local result = {}
    
    local unit = self:GetAttribute(UNIT)
    
    local index = 1
    local auraName, _, icon, count, dispelType, duration, expiration, source, _, _, auraID = auraFunction(unit, index)
    local changeDetected = false

    while auraName do
        local isBuff

        if auraFunction == UnitBuff then
            isBuff = true
        else
            isBuff = false
        end
        local aura = {["name"]       = auraName,
                      ["index"]      = index,
                      ["isBuff"]     = isBuff,
                      ["icon"]       = icon,
                      ["count"]      = count,
                      ["dispelType"] = dispelType,
                      ["duration"]   = duration,
                      ["expiration"] = expiration}
        if not FILTERED_AURA[auraName] and not FILTERED_AURA_IDS[auraID] then
            if source == "player" then
                if playerInclusion ~= "EXCLUDED" then
                    table_insert(result, aura)
                end
            else
                if playerInclusion ~= "EXCLUSIVE" then
                    table_insert(result, aura)
                end
            end
        end

        index = index + 1
        auraName, _, icon, count, dispelType, duration, expiration, source, _, _, auraID = auraFunction(unit, index)
    end

    return result
end

local handleAura = function(frame, aura)

    frame:SetAlpha(1)
    frame.icon:SetTexture(aura.icon)

    local dispelTexture = DEBUFF_TYPE_TO_TEXTURE[aura.dispelType]

    if dispelTexture then
        frame.background:Show()
        frame.background:SetTexture(unpack(dispelTexture))
    else
        frame.background:Hide() -- SetTexture(1, 0, 0)
    end

    if aura.duration and aura.duration > 0 then
        frame.cooldown:Show()
        frame.cooldown:SetCooldown(aura.expiration - aura.duration, aura.duration)
    else
        frame.cooldown:Hide()
    end

    if aura.count and aura.count > 1 then
        frame.count:Show()
        frame.count:SetText(tostring(aura.count))
    else
        frame.count:Hide()
    end

    frame:SetScript("OnEnter", function(self)
        local unit = self:GetParent():GetAttribute(UNIT)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", 15, -25)
        if aura.isBuff then
            GameTooltip:SetUnitBuff(unit, aura.index)
        else
            GameTooltip:SetUnitDebuff(unit, aura.index)
        end
    end)

    frame:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    frame:SetScript("OnUpdate", function(self)
        local unit = self:GetParent():GetAttribute(UNIT)
        if GameTooltip:IsOwned(self) then
            if aura.isBuff then
                GameTooltip:SetUnitBuff(unit, aura.index)
            else
                GameTooltip:SetUnitDebuff(unit, aura.index)
            end
        end
    end)
end

--local handleTarget = function(self)
--
--    local unit = self:GetAttribute(UNIT)
--    local targetUnit = unit .. "target"
--    
--    for _, validUnit in ipairs(VALID_UNITS) do
--    
--    end
--end

local handleHostility = function(self)

    self.background:SetTexture(unpack(REACTION[getReaction(self)]))
end

local populateFramesWithAuras = function(row, auras)

    for index, frame in ipairs(row.frames) do
        local aura = auras[index]
        if aura then
            handleAura(frame, aura)
            frame:Show()
        else
            frame:Hide()
        end
    end
end

local updateAura = function(self)

    local firstAnchor  = self.background
    local secondAnchor = self.background

    local firstRowAuras = {}
    local secondRowAuras = {}
    local thirdRowAuras = {}

    if getReaction(self) == FRIENDLY then
        local unit = self:GetAttribute(UNIT)
        if UnitBuff(unit, "Mark of the Wild") or
           UnitBuff(unit, "Gift of the Wild") 
        then
            self.offTheWildTexture:Show()
        else
            self.offTheWildTexture:Hide()
        end
        
        if UnitBuff(unit, "Thorns") then
            self.thornsTexture:Show()
        else
            self.thornsTexture:Hide()
        end
        
        firstRowAuras  = getAuras(self, UnitBuff,   "EXCLUSIVE")
        secondRowAuras = getAuras(self, UnitBuff,   "EXCLUDED")
        thirdRowAuras  = getAuras(self, UnitDebuff, "INCLUDED")
    else
        self.offTheWildTexture:Hide()
        self.thornsTexture:Hide()
        
        firstRowAuras  = getAuras(self, UnitDebuff, "EXCLUSIVE")
        secondRowAuras = getAuras(self, UnitDebuff, "EXCLUDED")
        thirdRowAuras  = getAuras(self, UnitBuff,   "INCLUDED")
    end

    populateFramesWithAuras(self.playerAuras,    firstRowAuras)
    populateFramesWithAuras(self.nonPlayerAuras, secondRowAuras)
    populateFramesWithAuras(self.auras,          thirdRowAuras)

    if #firstRowAuras ~= 0 then
        firstAnchor = self.playerAuras
        if #secondRowAuras ~= 0 then
            secondAnchor = self.nonPlayerAuras
        else
            secondAnchor = self.playerAuras
        end
    else
        if #secondRowAuras ~= 0 then
            secondAnchor = self.nonPlayerAuras
        end
    end

    self.nonPlayerAuras:SetPoint("TOP",
                                 firstAnchor,
                                 "BOTTOM",
                                 0,
                                 -self.MEASUREMENTS.DISTANCE_TO_EDGE)

    self.auras:SetPoint("TOP",
                        secondAnchor,
                        "BOTTOM",
                        0,
                        -self.MEASUREMENTS.DISTANCE_TO_EDGE)
end

local setIcon = function(self, icon, coord)

    self.targetFontString:Hide()

    self.targetPortrait:SetTexture(icon)
    
    if coord then
        self.targetPortrait:SetTexCoord(unpack(coord))
    else
        self.targetPortrait:SetTexCoord(0, 1, 0, 1)
    end
end

local setUnit = function(self, text, bgColorTable, fontColorTable )

    self.targetPortrait:SetTexture(unpack(bgColorTable))
    self.targetPortrait:SetTexCoord(0, 1, 0, 1)
    self.targetFontString:SetTextColor(unpack(fontColorTable))
    self.targetFontString:SetText(text)
    self.targetFontString:Show()
end

local updateTarget = function(self)

    local unit = self:GetAttribute(UNIT)
    local unitTarget = unit .. "target"
    local class = UnitLocalizedClass(unit)
    
    if UnitIsUnit(unit, unitTarget) then
        
        setUnit(self, "S", COLORS.BLACK, COLORS.WHITE)
    end
    
    if (UnitIsUnit(unit, "player") and UnitIsUnit(unitTarget, "player")) or 
       not UnitExists(unitTarget) 
    then
        self.target:Hide()
        self.target.healthBar:Hide()
        self.target.powerBar:Hide()
        self.targetBackground:Hide()
        self.targetPortrait:Hide()
        self.targetFontString:Hide()
        return
    end
    
    self.target:Show()
    self.targetPortrait:Show()
    self.targetFontString:Show()
    
    local detectedUnit
    
    --- Handle displaying unit artwork for valid units
    
    
    for index, validUnit in ipairs(VALID_UNITS) do
        if UnitIsUnit(unitTarget, validUnit) then
            detectedUnit = validUnit
            break
        end
    end
    
    if detectedUnit then
        self.targetBackground:Hide()
        self.target.healthBar:Hide()
        self.target.powerBar:Hide()
    else 
        self.targetBackground:Show()
        self.target.healthBar:Show()
        self.target.powerBar:Show()
        detectedUnit = unitTarget
    end

    local reaction = REACTION[getReaction(self, unitTarget)]
    self.targetBackground:SetTexture(unpack(reaction))
    
    if UNIT_TO_SETUP[detectedUnit] then
        setUnit(self, unpack(UNIT_TO_SETUP[detectedUnit]))
    
    --if UnitIsPlayer(detectedUnit) then
    --self:setIcon( "Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES", CLASS_ICON_TCOORDS[class] )
        
    elseif FAMILY_TO_ICON[UnitCreatureFamily(detectedUnit)] then
        setIcon(self, FAMILY_TO_ICON[UnitCreatureFamily(detectedUnit)])
        
    elseif CLASS_TO_ICON[class] then
        setIcon(self, CLASS_TO_ICON[class])
        
    elseif UnitHealthMax(unitTarget) == 4400 then
        setIcon(self, "Interface\\Icons\\Spell_Magic_LesserInvisibilty")
        
    else
        SetPortraitTexture(self.targetPortrait, detectedUnit)
        self.targetPortrait:SetTexCoord(0, 1, 0, 1)
        self.targetFontString:Hide()
    end 
end

--[[
    @func: can either be RegisterEvent or UnregisterEvent
]]
local observeEvents = function(self, func)
    
    func(self, "UNIT_AURA")
    func(self, "UNIT_ENERGY")
    func(self, "UNIT_FACTION")
    func(self, "UNIT_HEALTH")
    func(self, "UNIT_MANA")
    func(self, "UNIT_RAGE")
    func(self, "UNIT_RUNIC_POWER")
    func(self, "UNIT_TARGET")
end

local handleUnitChange = function(self)

    local unit = self:GetAttribute(UNIT)

    if UnitExists(unit) then
        self:Show()
        self.nameFontString:SetText(UnitName(unit))
        handleHostility(self)
        handleHealth(self)
        handlePower(self)
        updateAura(self)
        updateTarget(self)
        observeEvents(self, self.RegisterEvent)
    else
        observeEvents(self, self.UnregisterEvent)
        self:Hide()
    end
end

local setupTarget = function(self)

    local MEASUREMENTS = self.MEASUREMENTS.TARGET

    local target = CreateFrame("Button", self:GetName() .. "Target", self, "SecureUnitButtonTemplate")
    target:SetSize(MEASUREMENTS.FRAME_WIDTH, MEASUREMENTS.FRAME_HEIGHT)
    target:SetPoint("LEFT",
                    self,
                    "RIGHT",
                    10,
                    0)
    
    target:SetAttribute(UNIT, self:GetAttribute(UNIT) .. "target")
    target:SetAttribute("*type1", "target")
    target:EnableKeyboard(true)
    target:RegisterForClicks("AnyUp")
    target:RegisterForClicks("AnyDown")
    self.target = target
    
    local targetBackground = target:CreateTexture(nil, "BACKGROUND")
    targetBackground:SetTexture(0, 0, 0, 0.4)
    targetBackground:SetAllPoints()
    self.targetBackground = targetBackground
    
    local targetPortrait = target:CreateTexture(nil, "BACKGROUND") 
    targetPortrait:SetSize(MEASUREMENTS.PORTRAIT_SIZE, MEASUREMENTS.PORTRAIT_SIZE)
    targetPortrait:SetPoint("LEFT", target, "LEFT", 1, 0)
    self.targetPortrait = targetPortrait
    
    local targetFontString = target:CreateFontString(nil, "BACKGROUND", "AssiduityIconTextSmall")
    targetFontString:SetPoint("CENTER", targetPortrait)
    self.targetFontString = targetFontString

    local healthBar = CreateFrame("StatusBar", nil, target)
    healthBar:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8.blp")
    healthBar:SetOrientation("HORIZONTAL")
    healthBar:SetSize(MEASUREMENTS.BAR_WIDTH, MEASUREMENTS.HEALTH_BAR_HEIGHT)
    healthBar:SetPoint("TOPRIGHT",
                       target,
                       "TOPRIGHT",
                       -self.MEASUREMENTS.DISTANCE_TO_EDGE,
                       -self.MEASUREMENTS.DISTANCE_TO_EDGE)
    target.healthBar = healthBar

    local healthBarBackground = healthBar:CreateTexture(nil, "BACKGROUND")
    healthBarBackground:SetTexture(0, 0, 0, 1)
    healthBarBackground:SetAllPoints()

    local nameFontString = healthBar:CreateFontString(nil, nil, "AssiduityAuraCountFontSmall")
    nameFontString:SetPoint("CENTER", healthBar)
    target.nameFontString = nameFontString

    local powerBar = CreateFrame("StatusBar", nil, target)
    powerBar:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8.blp")
    powerBar:SetStatusBarColor(0, 1, 1)
    powerBar:SetOrientation("HORIZONTAL")
    powerBar:SetSize(MEASUREMENTS.BAR_WIDTH, 
                     MEASUREMENTS.POWER_BAR_HEIGHT)
    powerBar:SetPoint("TOPRIGHT",
                      healthBar,
                      "BOTTOMRIGHT",
                      0,
                      -1)
    target.powerBar = powerBar

    local powerBarBackground = powerBar:CreateTexture(nil, "BACKGROUND")
    powerBarBackground:SetTexture(0, 0, 0, 1)
    powerBarBackground:SetAllPoints()

    target:SetScript("OnUpdate", function(self)
        handleHealth(self)
        handlePower(self)
    end)
end

------------
-- Events --
------------

local PLAYER_ENTERING_WORLD = function(self)

    handleUnitChange(self)
end

local UNIT_AURA = function(self, unit)

    if unit == self:GetAttribute(UNIT) then
        updateAura(self)
    end
end

local UNIT_FACTION = function(self, unit)

    if unit == self:GetAttribute(unit) then
        handleHostility(self)
    end
end

local UNIT_HEALTH = function(self, unit)

    if unit == self:GetAttribute(UNIT) then
        handleHealth(self)
    end
end

local UNIT_POWER = function(self, unit)

    if unit == self:GetAttribute(UNIT) then
        handlePower(self)
    end
end

local UNIT_TARGET = function(self, unit)

    if unit == self:GetAttribute(UNIT) then
        updateTarget(self)
    end
end

AssiduityRegisterFrame = function(self)

    local MEASUREMENTS = MEASUREMENTS[self.sizing]
    self.MEASUREMENTS = MEASUREMENTS

    local unit = self:GetAttribute(UNIT)
    
    -- Layout
    self:SetSize(MEASUREMENTS.FRAME_WIDTH, MEASUREMENTS.FRAME_HEIGHT)

    -- Interaction
    self:EnableKeyboard(true)
    self:RegisterForClicks("AnyUp")
    self:RegisterForClicks("AnyDown")
    self:SetAttribute("type1", "target")
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

    local portrait = CreateFrame("Frame", nil, self)
    portrait:SetSize(MEASUREMENTS.PORTRAIT_SIZE, MEASUREMENTS.PORTRAIT_SIZE)
    
    if self.orientation == "LEFT_TO_RIGHT" then 
        portrait:SetPoint("LEFT",
                          self,
                          "LEFT",
                          MEASUREMENTS.DISTANCE_TO_EDGE,
                          0)
    else
        portrait:SetPoint("RIGHT",
                          self,
                          "RIGHT",
                          -MEASUREMENTS.DISTANCE_TO_EDGE,
                          0)
    end

    local portraitBackground = portrait:CreateTexture(nil, "BACKGROUND")
    portraitBackground:SetTexture(unpack(UNIT_TO_SETUP[unit][2]))
    portraitBackground:SetAllPoints()

    local portraitFontString = portrait:CreateFontString(nil, nil, "AssiduityIconText")
    portraitFontString:SetPoint("CENTER", portrait)
    portraitFontString:SetTextColor(unpack(UNIT_TO_SETUP[unit][3]))
    portraitFontString:SetText(UNIT_TO_SETUP[unit][1])
    
    -- Target of unit
    
    setupTarget(self)
    
    local nameFontString = self:CreateFontString(nil, nil, "AssiduityAuraCountFontSmall")
    nameFontString:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -2)
    self.nameFontString = nameFontString

    -- Bars
    
    local healthBar = CreateFrame("StatusBar", nil, self)
    healthBar:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8.blp")
    healthBar:SetOrientation("HORIZONTAL")
    healthBar:SetSize(MEASUREMENTS.BAR_WIDTH, MEASUREMENTS.HEALTH_BAR_HEIGHT)
    
    if orientation == "LEFT_TO_RIGHT" then 
        healthBar:SetPoint("TOPRIGHT",
                           self,
                           "TOPRIGHT",
                           -MEASUREMENTS.DISTANCE_TO_EDGE,
                           -MEASUREMENTS.DISTANCE_TO_EDGE)
    else
        healthBar:SetPoint("TOPLEFT",
                           self,
                           "TOPLEFT",
                           MEASUREMENTS.DISTANCE_TO_EDGE,
                           -MEASUREMENTS.DISTANCE_TO_EDGE)
    end
    self.healthBar = healthBar

    local healthBarBackground = healthBar:CreateTexture(nil, "BACKGROUND")
    healthBarBackground:SetTexture(0, 0, 0, 1)
    healthBarBackground:SetAllPoints()

    local healthValueFontString = healthBar:CreateFontString(nil, nil, "AssiduityAuraCountFontSmall")
    healthValueFontString:SetPoint("TOPRIGHT", healthBar, -2, -3)
    self.healthValueFontString = healthValueFontString
    
    local healthPercentageFontString = healthBar:CreateFontString(nil, nil, "AssiduityAuraCountFontSmall")
    healthPercentageFontString:SetPoint("LEFT", healthBar, 2, 0)
    self.healthPercentageFontString = healthPercentageFontString

    -- Druid buffs
    
    local offTheWildTexture = healthBar:CreateTexture(nil, "OVERLAY")
    offTheWildTexture:SetSize(MEASUREMENTS.MINI_AURA, MEASUREMENTS.MINI_AURA)
    offTheWildTexture:SetPoint("TOPLEFT", healthBar, "TOPLEFT")
    offTheWildTexture:SetTexture("Interface\\Icons\\Spell_Nature_Regeneration")
    offTheWildTexture:SetAlpha(0.5)
    self.offTheWildTexture = offTheWildTexture
    
    local thornsTexture = healthBar:CreateTexture(nil, "OVERLAY")
    thornsTexture:SetSize(MEASUREMENTS.MINI_AURA, MEASUREMENTS.MINI_AURA)
    thornsTexture:SetPoint("LEFT", offTheWildTexture, "RIGHT")
    thornsTexture:SetTexture("Interface\\Icons\\Spell_Nature_Thorns")
    thornsTexture:SetAlpha(0.5)
    self.thornsTexture = thornsTexture
    
    -- Power bar

    local powerBar = CreateFrame("StatusBar", nil, self)
    powerBar:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8.blp")
    powerBar:SetStatusBarColor(0, 1, 1)
    powerBar:SetOrientation("HORIZONTAL")
    powerBar:SetSize(MEASUREMENTS.BAR_WIDTH, MEASUREMENTS.POWER_BAR_HEIGHT)
    powerBar:SetPoint("TOP",
                      healthBar,
                      "BOTTOM",
                      0,
                      -MEASUREMENTS.DISTANCE_TO_EDGE)
    self.powerBar = powerBar

    local powerBarBackground = powerBar:CreateTexture(nil, "BACKGROUND")
    powerBarBackground:SetTexture(0, 0, 0, 1)
    powerBarBackground:SetAllPoints()

    local powerValueFontString = powerBar:CreateFontString(nil, nil, "AssiduityAuraCountFontTiny")
    powerValueFontString:SetPoint("RIGHT", powerBar, -2, 0)
    self.powerValueFontString = powerValueFontString
    
    -- Casting Bar

    local unitCapitalized = unit:sub(1,1):upper() .. unit:sub(2)

    local castBar = CreateFrame("StatusBar", "Assiduity" .. unitCapitalized .. "CastBar", self, "AssiduityCastingBarTemplate")
    castBar:SetPoint("RIGHT", 
                     self, 
                     "LEFT", 
                     -10, 
                     -MEASUREMENTS.CAST_BAR_OFFSET)
    self.castBar = castBar
    
    CastingBarFrame_OnLoad(castBar, unit, false)
    _G[castBar:GetName() .. "Icon"]:Show()
    
    castBar:SetScript("OnEvent", function(self, event, ...)
        CastingBarFrame_OnEvent(self, event, ...)
    end)
    
    castBar:SetScript("OnUpdate", function(self, elapsed)
        CastingBarFrame_OnUpdate(self, elapsed)
    end)
    
    castBar:SetScript("OnShow", function(self)
        CastingBarFrame_OnShow(self)
    end)

    --[[ 1st row:
        Friendly target: player applied buffs
        Hostile  target: player applied debuffs
    ]]

    local playerAuras = CreateFrame("Frame", nil, self)
    playerAuras:SetSize(MEASUREMENTS.FRAME_WIDTH, MEASUREMENTS.PLAYER_BAR_HEIGHT)
    playerAuras:SetPoint("TOPLEFT",
                         self,
                         "BOTTOMLEFT",
                         0,
                         -MEASUREMENTS.AURA_DISTANCE_TO_EDGE)
    self.playerAuras = playerAuras
    createAuraFrames(self, playerAuras, MEASUREMENTS.PLAYER_AURA_SIZE)
    --local playerAurasTexture = playerAuras:CreateTexture(nil, "BACKGROUND")
    --playerAurasTexture:SetTexture(0, 0, 1, 0.4)
    --playerAurasTexture:SetAllPoints()


    -- Shows when someone is dead for better visibility

    --[[ 2nd row:
        Friendly target: non-player buffs
        Hostile  target: non-player debuffs
    ]]
    local nonPlayerAuras = CreateFrame("Frame", nil, self)
    nonPlayerAuras:SetSize(MEASUREMENTS.FRAME_WIDTH, MEASUREMENTS.AURA_SIZE)
    self.nonPlayerAuras = nonPlayerAuras
    createAuraFrames(self, nonPlayerAuras, MEASUREMENTS.AURA_SIZE)

    --local nonPlayerAurasTexture = nonPlayerAuras:CreateTexture(nil, "BACKGROUND")
    --nonPlayerAurasTexture:SetTexture(0, 1, 0, 0.4)
    --nonPlayerAurasTexture:SetAllPoints()

    --[[ 3rd row:
        Friendly target: debuffs
        Hostile  target: buffs
    ]]
    local auras = CreateFrame("Frame", nil, self)
    auras:SetSize(MEASUREMENTS.FRAME_WIDTH, MEASUREMENTS.AURA_SIZE)
    self.auras = auras
    createAuraFrames(self, auras, MEASUREMENTS.AURA_SIZE)
    --local aurasTexture = auras:CreateTexture(nil, "BACKGROUND")
    --aurasTexture:SetTexture(1, 0, 0, 0.4)
    --aurasTexture:SetAllPoints()

    local deadFontString = playerAuras:CreateFontString(nil, nil, "AssiduityAuraCountFontLarge")
    deadFontString:SetPoint("CENTER", playerAuras)
    deadFontString:SetText("DEAD")
    deadFontString:SetAlpha(0)
    self.deadFontString = deadFontString

    -- Events
    self.PLAYER_ENTERING_WORLD = PLAYER_ENTERING_WORLD
    self.UNIT_AURA             = UNIT_AURA
    self.UNIT_FACTION          = UNIT_FACTION
    self.UNIT_HEALTH           = UNIT_HEALTH
    self.UNIT_MANA             = UNIT_POWER
    self.UNIT_RUNIC_POWER      = UNIT_POWER
    self.UNIT_ENERGY           = UNIT_POWER
    self.UNIT_RAGE             = UNIT_POWER
    self.UNIT_TARGET           = UNIT_TARGET

    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    
    if self.changeEvent then
        self:RegisterEvent(self.changeEvent)
    end

    -- Scripts

    self:SetScript("OnEvent", function(self, event, ...)
        if event == self.changeEvent then
            handleUnitChange(self)
        else 
            self[event](self, ...)
        end
    end)
    
    self:SetScript("OnEnter", function(self)
        --GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", 20, 10)
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
        GameTooltip:SetUnit(self:GetAttribute(UNIT))
        GameTooltip:Show()
    end)

    self:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    handleUnitChange(self)

    RegisterUnitWatch(self)
    RegisterUnitWatch(self.target)
end

