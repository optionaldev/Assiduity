--[[
	Noteworthy: all of the structures are initially array due to simplicity of declaration,
				but later on get converted into dictionaries for simplicity of usage
				
	Example:
	Declaration: 
		CONSTANT_NAME = {
			"a",
			"b",
			"c"
		}
	gets converted into
		CONSTANT_NAME = {
			["a"] = 1,
			["b"] = 1,
			["c"] = 1
		}
		
	The conversion part is at the end of the file, after all the constants have been declared.
]]
------------------------
-- Locals and imports --
------------------------

local ipairs = ipairs

--[[ 
	Hidden buffs are hidden initally from the UI and only displayed on hover.
	Even though it's important to know, especially for PvE, if you have or
	don't have one of these buffs, in the grand scheme of things, they're not that important.
]]
local HIDDEN_BUFFS = {

	"Abomination's Might", 	-- DK passive, +10% AP
	"Aquatic Form",			
	"Arcane Brilliance",	-- Arcane m
	"Arcane Empowerment", 	-- Arcane Mage talent, 3% damage increase
	"Arcane Intellect",		-- Mage buff, 
	"Battle Shout",
	"Bear Form",
	"Blessing of Kings",
	"Blessing of Might",
	"Blessing of Sanctuary",
	"Blessing of Wisdom",
	"Blood Pact", --imp
	"Cat Form",
	"Clearcasting", -- displayed as proc
	"Concentration Aura",
	"Cozy Fire",
	"Dalaran Brilliance",
	"Dalaran Intellect",
	"Devotion Aura",
	"Demonic Pact",
	"Dire Bear Form",
	"Elemental Oath",
	"Ferocious Inspiration",
	"Focus Magic",
	"Fortitude",
	"Gift of the Wild",
	"Greater Blessing of Kings",
	"Greater Blessing of Might",
	"Greater Blessing of Sanctuary",
	"Greater Blessing of Wisdom",
	"Heroic Presence",
	"Honorable Defender",
	"Honorless Target",
	"Horn of Winter",
	"Improved Icy Talons",
	"Leader of the Pack",
	"Lightweave", 	-- cloak enchant
	"Luck of the Draw",
    "Mark of the Wild",
	"Master Shapeshifter",
	"Moonkin Aura",
	"Moonkin Form",
	"Prayer of Fortitude",
	"Prayer of Shadow Protection",
	"Prayer of Spirit",
	"Precious's Ribbon",
	"Preparation",
	"Rampage", 
	"Renewed Hope",			-- Priest ta
	"Retribution Aura",
	"Strength of Wrynn",
	"Swift Flight Form",
	"Swift Stormsaber",
	"Swift White Mechanostrider",
	"Thorns",
	"Totem of Wrath",
	"Tree of Life",
	"Trueshot Aura",
	"Well Fed",
	"Wrath of Air Totem"
}

--[[
	Similarly to HIDDEN_BUFFS, these are debuffs that, although it's nice
	to know when it's applied or not, most of them are passive, not removable,
	and should be known based on the class / spec / race you're facing.=
]]
local HIDDEN_DEBUFFS = {
	"Chill of the Throne",
	"Sated"
}

--[[
	These are the buffs that will be shown on the player buff row.
	Only applies if these buffs have been caster by "player" unit.
	It's possible to have e.g. 2 Rejuvenations, 1 from "player", from from another source.
]]
local SHOWN_BUFFS = {

	"Barkskin",
	"Dash",
	"Enrage",
	"Frenzied Regeneration",
	"Innervate",
	"Lifebloom",
	"Nature's Grasp",
	"Regrowth",
	"Rejuvenation",
	"Starfall",
	"Wild Growth",	-- debateable whether should be shown or not
}

--[[
	Procs are displayed in a different section because they require 
	virtually immediate attention, as opposed to just buffs 
]]
local PROCS = {
	"Clearcasting",
}

local convertArrayToDictionary = function(array) 

	local result = {}
	
	for _, value in ipairs(array) do
		result[value] = 1
	end
	
	return result
end

do 
	HIDDEN_BUFFS = convertArrayToDictionary(HIDDEN_BUFFS)
	SHOWN_BUFFS = convertArrayToDictionary(SHOWN_BUFFS)
	HIDDEN_DEBUFFS = convertArrayToDictionary(HIDDEN_DEBUFFS)
end

Assiduity.HIDDEN_BUFFS   = HIDDEN_BUFFS
Assiduity.HIDDEN_DEBUFFS = HIDDEN_DEBUFFS
Assiduity.PROCS  	     = PROCS
Assiduity.SHOWN_BUFFS    = SHOWN_BUFFS