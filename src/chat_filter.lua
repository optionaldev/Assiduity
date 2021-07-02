
--[[
	On the current server I'm playing, there are a lot of messages happening in global.
	It's not just a chat, but people also do LFG, LFM, LF <prof>, guild recruitment, etc.
	This filter is used to minimize the amount of messages received in global and /yell,
	especially around Dalaran area.
]]

local debug = function() end

------------------------
-- Imports and locals --
------------------------

local print = print
local pairs = pairs
local ipairs = ipairs
local string_find = string.find
local string_sub = string.sub
local string_lower = string.lower
local table_insert = table.insert

--[[
	The reason why this is declared here and not in a SavedVariable 
	is because it's required on multiple accounts and cross-account
	variable saving is not possible with addons.
]]

local filteringSubstrings = {}

local temporaryFilters = {}

local guildsToFilter = {

	--- Guilds ---
	"advent",
	"another memory",
	"arise",
	"asperity",
	"atencion",
	"autentic",
	"back in blood",
	"bad luck",
	"balanced insanity",
	"balkanski guild",
	"bloody butchers",
	"calavera",
	"cant afford retail",
	"carbonite",
	"carried",
	"code",
	"dej na wino",
	"die raidgilde",
	"drakkhen",
	"cognitive",
	"consortium",
	"courage",
	"deleted user",
	"edora",
	"el capitoli",
	"el sol devastado",
	"con la guild",
	"empathy",
	"essentials",
	"evasion",
	"exalted spiritz",
	"frenchdrama",
	"for the aliance",
	"freezing field",
	"from bulgaria with love",
	"guardian of the bulgaria",
	"guild internacional",
	"guild latina,",
	"guilda cz/sk",
	"guilty gear",
	"i n s i g h t",
	"i n s u r r",
	"impaled",
	"infest",
	"injustice",
	"integrity knights",
	"intense",
	"invaders",
	"iranian house",
	"iron alliance",
	"iron line",
	"k e r v a n",
	"knight champions",
	"la brigada",
	"la caja de pandora",
	"legado de wrynn",
	"life power",
	"lonsdaleites",
	"magyar guild",
	"mai una gioia",
	"mastodon",
	"moria guildi",
	"nowa polska",
	"nueva guild los",
	"orgrimmar gankers",
	"our guild welcome",
	"out laws",
	"olympos",
	"penumbra d la desolacion",
	"pouch my tenis",
	"pride",
	"pvp guild",
	"pvp nao e pra gringos",
	"rebel knights",
	"red ribbon army",
	"r e s u r r e c t i o n",
	"remorselesses",
	"renegados brasil",
	"retaliation",
	"rising angels",
	"saints and soldiers",
	"serbian knights",
	"shadow house",
	"shield of light",
	"silent spectrum",
	"snow doves",
	"the dead center",
	"tempered insanity",
	"the outcast",
	"the patiant",
	"the pug society",
	"the rippers",
	"the sons of norris",
	"the walkiing dead",
	"t o x i n",
	"toxicology",
	"toomanybuttons",
	"trauma",
	"twinkonomic",
	"unison",
	"vanguardia de escarcha",
	"vendetta",
	"wap squad",
	"warmane br",
	"w i p e",
	"what makes us strong",
	"whispers in the dark",
	"wrynn legacy",
	"yeezus"
}

local marketIdentiers = {
	"wts",
	"wtb",
	"selling",
	"buying"
}

local marketToFilter = {
	
	"50",
	"100",
	"150",
	"200",
	"a lot of",
	"blackrock",
	"bis",
	"boom",
	"char",
	"dk",
	"druid",
	"fresh naked",
	"fury",
	"gnome",
	"hpala",
	"human",
	"hunt",
	"lock",
	"rogue",
	"mage",
	"paladin",
	"pala",
	"prebis",
	"priest",
	"resto",
	"ret",
	"shaman",
	"this",
	"twink",
	"via trade",
	"warlock",
	"war"
}

--[[ 
	Raids often reserve items and I don't plan on joining these types of 
	raids, so might as well ignore them completely.
]]
local reservingToFilter = {
	
	"b+o+p",
	"boe+p",
	"b+p+sfs",
	"b+p",
	"boe/primo"
}


local otherFilters = {
	"hyjal",
	"molten core",
	"rs10",
	"rs25",
	"rs 10",
	"rs 25",
	"sunwell plateau",
	"tempest keep",
	"the black temple",
	"trade",
	"tmog",
	"twitch.tv",
	"warmane trade",
	"xmog"
}

--[[
	Keeps a list of messages that have been filtered so far. Sometimes
	need to double check to make sure that we didn't accidentally 
	filter a message we would have wanted to see
]]
local filteredMessages = {}

----------------------
-- Global functions --
---------------------


---------------------
-- Local functions --
---------------------
local function spamFilter(self, event, message, _, language, ...)

	if language == "Orcish" and GetZoneText() == "Dalaran" then
		return true
	end
	
	local lowercaseMessage = string_lower(message)
	
	for _, substring in ipairs(temporaryFilters) do
		if string_find(lowercaseMessage, substring, 1, true) then
			print("Found substrings \"" .. substring .. "\" in message:")
			print(lowercaseMessage)
			return true
		end
	end	
	
	for _, filter in ipairs(marketToFilter) do
		if string_find(lowercaseMessage, filter, 1, true) then
			for _, identifier in ipairs(marketIdentiers) do
				if string_find(lowercaseMessage, identifier, 1, true) then
					return true
				end
			end
		end
    end
        
	for _, substring in ipairs(filteringSubstrings) do
		-- Filter messages that contain substring. The 4th parameter (true) make string finding ignore regex syntax 
		if string_find(lowercaseMessage, substring, 1, true) then
			filteredMessages[lowercaseMessage] = true
			return true
		end
	end
	
	return false
end

local ADDON_LOADED = function( self, addon )

    if addon == "Assiduity" then
        self:UnregisterEvent( "ADDON_LOADED" )
		
		filteringSubstrings = guildsToFilter
		
		print("marketToFilter = ")
		print(marketToFilter)
		
		for _, value in ipairs(reservingToFilter) do
			table_insert(filteringSubstrings, value)
		end
		
		for _, value in ipairs(otherFilters) do
			table_insert(filteringSubstrings, value)
		end
		
		ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", spamFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL",    spamFilter)
    end
end

-----------
-- Frame --
-----------
local AssiduityChatFilter = CreateFrame("Frame")

do
    local self = AssiduityChatFilter
  
    self.ADDON_LOADED = ADDON_LOADED
    
    self:RegisterEvent( "ADDON_LOADED" )
    
    self:SetScript( "OnEvent", function( self, event, ... )
        self[event]( self, ... )
    end )
end

--------------------
-- Slash commands --
--------------------
SLASH_ASSIDUITYCHATFILTER1 = "/assiduitychatfilter"
SLASH_ASSIDUITYCHATFILTER2 = "/acf"

SlashCmdList["ASSIDUITYCHATFILTER"] = function (message)
	
	print(message)
	
	if string_sub(message, 1, 7) == "filter " then
		local filter = string_sub(message, 8)
		print("filtering: " .. filter)
		table_insert(temporaryFilters, filter)
	elseif message == "filtered" then
		print("Temporary filters are:")
		for message, _ in pairs(temporaryFilters) do
			print(message)
		end
	elseif message == "unfilter" then
		print("Unfiltering temporary.")
		temporaryFilters = {}
	elseif message == "messages" then
		for message, _ in pairs(filteredMessages) do
			print(message)
		end
	elseif message == "reset" then
		print("Removing list of filtered messages.")
		filteredMessages = {}
	else
		print("Available commands for /assiduitychatfilter or /acf:")
		print("")
		print("/acf filter <substring>")
		print("Filters messages containing <substring> until tomorrow.")
		print("")
		print("/acf filtered")
		print("Shows substrings that are filtered until tomorrow.")
		print("")
		print("/acf unfilter")
		print("Removes all filters applied by the /acf filter command.")
		print("")
		print("/acf messages")
		print("Displays messages that were not displayed due to being permanently filtered.")
		print("")
		print("/acf reset")
		print("Deletes messages that have been filtered so far.")
	end
end