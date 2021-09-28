
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

local TableJoin = AssiduityTableJoin

--[[
	The reason why this is declared here and not in a SavedVariable 
	is because it's required on multiple accounts and cross-account
	variable saving is not possible with addons.
]]

local filteringSubstrings = {}

local temporaryFilters = {}

--[[
	This will hold all messages that have been detected to either
	not reserve items or not reserve all items. Because these 
	messages will be spammed, we want to print it once and that's it.
]]
local printedRecruitmentMessages = {}

--[[ 
	These will be read from the AssiduityWarmane module.
]]
local ACHIEVEMENTS_TO_FILTER
local DUNGEONS_TO_FILTER
local GUILDS_TO_FILTER
local HIGHLIGHT_MESSAGES
local ITEMS_TO_FILTER
local MARKET_IDENTIFIERS
local MARKET_TO_FILTER
local RESERVING_TO_FILTER
local OTHER_FILTERS
local TEMPORARY_FILTERS

--[[
	Keeps a list of messages that have been filtered so far. Sometimes
	need to double check to make sure that we didn't accidentally 
	filter a message we would have wanted to see
]]
local filteredMessages = {}

---------------------
-- Local functions --
---------------------
local function spamFilter(self, event, message, author, language, ...)

	if author == UnitName("player") then
		return false
	end

	if language == "Orcish" then
		return true
	end
	
	local lowercaseMessage = string_lower(message)
	
	for _, substring in ipairs(temporaryFilters) do
		if string_find(lowercaseMessage, substring, 1, true) then
			return true
		end
	end	
	
	for _, filter in ipairs(MARKET_TO_FILTER) do
		if string_find(lowercaseMessage, filter, 1, true) then
			for _, identifier in ipairs(MARKET_IDENTIFIERS) do
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
			if HIGHLIGHT_MESSAGES[lowercaseMessage] then
				printedRecruitmentMessages[lowercaseMessage] = 1
				print("\"" .. author .. "\" is looking for group:")
				print(lowercaseMessage)
			end
			return true
		end
	end
	
	return false
end
        
------------
-- Events --
------------

local ADDON_LOADED = function( self, addon )

    if addon == "AssiduityWarmane" then
		ACHIEVEMENTS_TO_FILTER = Assiduity.ACHIEVEMENTS_TO_FILTER
		DUNGEONS_TO_FILTER     = Assiduity.DUNGEONS_TO_FILTER
		GUILDS_TO_FILTER       = Assiduity.GUILDS_TO_FILTER
		HIGHLIGHT_MESSAGES     = Assiduity.HIGHLIGHT_MESSAGES
		ITEMS_TO_FILTER        = Assiduity.ITEMS_TO_FILTER
		MARKET_IDENTIFIERS     = Assiduity.MARKET_IDENTIFIERS
		MARKET_TO_FILTER       = Assiduity.MARKET_TO_FILTER
		OTHER_FILTERS          = Assiduity.OTHER_FILTERS
		TEMPORARY_FILTERS      = Assiduity.TEMPORARY_FILTERS
		
		self:UnregisterEvent("ADDON_LOADED")
		
		filteringSubstrings = ACHIEVEMENTS_TO_FILTER
		
        TableJoin(filteringSubstrings, DUNGEONS_TO_FILTER)
        TableJoin(filteringSubstrings, GUILDS_TO_FILTER)
        TableJoin(filteringSubstrings, ITEMS_TO_FILTER)
        TableJoin(filteringSubstrings, OTHER_FILTERS)
        TableJoin(filteringSubstrings, TEMPORARY_FILTERS)
        
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
    
    self:RegisterEvent("ADDON_LOADED")
    
    self:SetScript("OnEvent", function(self, event, ...)
        self[event](self, ...)
    end )
end

--------------------
-- Slash commands --
--------------------
SLASH_ASSIDUITYCHATFILTER1 = "/assiduitychatfilter"
SLASH_ASSIDUITYCHATFILTER2 = "/acf"

SlashCmdList["ASSIDUITYCHATFILTER"] = function (message)
	
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