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

--[[ 
	Hidden buffs are hidden initally from the UI and only displayed on hover.
	Even though it's important to know, especially for PvE, if you have or
	don't have one of these buffs, in the grand scheme of things, they're not that important.
]]
local HIDDEN_BUFFS = {

	"Aquatic Form",
	"Bear Form",
	"Blessing of Kings",
	"Blessing of Might",
	"Blessing of Sanctuary",
	"Blessing of Wisdom",
	"Cat Form",
	"Clearcasting",
	"Cozy Fire",
	"Dire Bear Form",
	"Gift of the Wild",
	"Greater Blessing of Kings",
	"Greater Blessing of Might",
	"Greater Blessing of Sanctuary",
	"Greater Blessing of Wisdom",
	"Honorable Defender",
	"Honorless Target",
	"Horn of Winter",
	"Luck of the Draw",
    "Mark of the Wild",
	"Master Shapeshifter",
	"Prayer of Fortitude",
	"Prayer of Shadow Protection",
	"Prayer of Spirit",
	"Precious's Ribbon",
	"Preparation",
	"Retribution Aura",
	"Swift Flight Form",
	"Swift Stormsaber",
	"Swift White Mechanostrider",
	"Thorns"
}

--[[
	Similarly to HIDDEN_BUFFS, these are debuffs that, although it's nice
	to know when it's applied or not, most of them are passive, not removable,
	and should be known based on the class / spec / race you're facing.=
]]
local HIDDEN_DEBUFFS = {

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

Assiduity.HIDDEN_BUFFS   = HIDDEN_BUFFS
Assiduity.HIDDEN_DEBUFFS = HIDDEN_DEBUFFS
Assiduity.PROCS  	     = PROCS
Assiduity.SHOWN_BUFFS    = SHOWN_BUFFS