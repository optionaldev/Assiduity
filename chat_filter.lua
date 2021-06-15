
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
local table_insert = table.insert

--[[
	The reason why this is declared here and not in a SavedVariable 
	is because it's required on multiple accounts and cross-account
	variable saving is not possible with addons.
]]
local filteringSubstrings = {

	--- Guilds ---
	"Advent",
	"Arise",
	"ATENCION",
	"Back in Blood",
	"Bad Luck",
	"BALANCED INSANITY",
	"Balkanski Guild",
	"BALKANSKI GUILD",
	"Bloody Butchers",
	"calavera",
	"Cant Afford Retail",
	"CODE",
	"Die Raidgilde",
	"Cognitive",
	"Courage",
	"Edora",
	"EL CAPITOLIO",
	"CON LA GUILD",
	"Empathy",
	"Essentials",
	"EVASION",
	"FrenchDrama",
	"For The Aliance",
	"FOR THE ALIANCE",
	"From Bulgaria with Love",
	"Guardian of the Bulgaria",
	"Guild Latina,",
	"Guilda Cz/Sk",
	"Impaled",
	"Infest",
	"INTEGRITY KNIGHTS",
	"INTENSE",
	"INTENSE is a fresh",
	"Invaders",
	"Iranian House",
	"Iron Alliance",
	"IRON LINE",
	"K e r v a N",
	"La Caja de Pandora",
	"LEGADO DE WRYNN",
	"MAGYAR guild",
	"MASTODON",
	"Moria guildi",
	"NOWA POLSKA",
	"NUEVA GUILD LOS",
	"Orgrimmar Gankers",
	"Our Guild Welcome",
	"Olympos",
	"Olympos t",
	"Pouch My Tenis",
	"PvP guild",
	"PvP Nao e Pra Gringos",
	"Rebel Knights",
	"Red Ribbon Army",
	"R E S U R R E C T I O N",
	"RENEGADOS BRASIL",
	"Retaliation",
	"RISING ANGELS",
	"Saints and Soldiers",
	"Serbian Knights",
	"Silent Spectrum",
	"The Dead Center",
	"TEMPERED INSANITY",
	"The Patiant",
	"The Pug Society",
	"The Rippers",
	"The Sons of Norris",
	"T O X I N",
	"Toxicology",
	"TooManyButtons",
	"Vanguardia de Escarcha",
	"Vendetta",
	"WAP SQUAD",
	"W I P E",
	"What Makes Us Strong",
	"Yeezus",
	
	--- Buying ---
	"WTB HUNTER",
	"WTB Rogue",
	"WTB Resto",
	"WTB Feral druid",
	"WTB CHARACTERS",
	"WTB Rogue",
	"BUY CAT",
	
	--- Char selling ---
	"WTS Warr",
	"WTS - Shadow",
	"WTS ON LORD",
	"WTS PREBIS",
	"WTS BiS Ret",
	"WTS WARLOCK WITH",
	"WTS HumanPaladin",
	"WTS FRESH NAKED",
	"WTS human priest",
	"WTS Priest",
	"WTS BIS BOOMY",
	"Fragment and orb Ress",
	"WTS R1 Shaman",
	"WTS (only via",
	"Pve bis pvp WF",
	"WTS druid",
	"WTS Pala",
	"WTE ENCHANTMENT SHAMAN",
	"WTS>Pally",
	"WTS FROSTMOURNE 4.2k",
	"with a lot of bis items",
	"WTS Human",
	"wts hpala 2500",
	"WTS R1",
	"wts bis",
	"WTS Hunter",
	"WTS DK",
	"WTS BIS",
	"WTS a lot of chars",
	"WTS SHAMAN",
	"Selling Feral",
	"Wts 177",
	"WTS Boomie",
	"WTS Icecrown",
	"WTS WARLOCK",
	"WTS Shaman",
	"WTS shaman",
	"WTS // Human",
	"WTS Warrior",
	"WTS MAGE",
	"Wts priest",
	"WTS Naked",
	"WTS GOLD",
	"WTS BiS",
	"Wts Und lock",
	"WTS 300",
	"Wts Bis",
	"WTS PALADIN",
	"WTS RET",
	"WTS alot of",
	"BOMY have Ulduar",
	"Female human",
	"WTS HOLY",
	"WTS nearly",
	"Selling shaman",
	"WTS DRAENEI",
	"WTS 45 COINS OR",
	"wts 333 coins",
	"WTS ROGUE",
	"<WTB> Paladin",
	"WTS Bis",
	"WTS - BIS PVP",
	"WTS WARRIOR",
	"WTS Mage",
	"WTS Night Elf",
	"WTS BIs",
	"BOOSTS Full",
	"WTS Troll",
	"SELL draenei",
	"WTS MY HUMAN",
	"WTS HUMAN",
	"WTS Retry",
	"WTS 200k",
	"WTS HPALA",
	"WTS THIS",
	"WTS Warlock",
	"WTS 6.5 Warlock",
	"WTS Rogue",
	"WTS human",
	"WTS BOMKIN",
	"WTS GNOME",
	"RET PALA PVP With Smourne",
	"selling cool",
	"WTS Fwarr",
	"WTS naked rogue",
	"Trading on market",
	"WTS ELF HUNTER",
	"WTS Via Warm",
	"selling cheap",
	"selling vool bis",
	"Knietief im Dispo",
	"warmane trade",
	"PvE Feral Druid",
	"WTS rogue",
	"Wts Naked warlock",
	"wts 360 coins",
	"WTS via warmane",
	"WTS HUNTER",
	"WTS Fresh",
	"WTS/WTT",
	"WTS f draenei",
	"Selling 200k",
	"WTS Pre",
	
	--- Reserving raids ---
	"E+O+P",
	"B+P+sfs",
	"Boe + Primo+DBW",
	"BOE P RES(HAVE",
	"P ress link your ach",
	"[Boe+p+o ress]",
	"BOE + Primo Ress",
	"BOE+Primo Ress",
	"B+P+ need",
	"(sts ress)",
	"B+P ress",
	"(Sts REs)",
	"(B+P RES)",
	"(B+O+P Res)",
	"(BoE+Primo) Ress",
	"SFS BOE PRIMO RES",
	"(b+p+o=ress)",
	"{BOE RES}",
	"B+P + can ress",
	"BOE+P Res",
	"B+O+P RES",
	"BOE AND",
	"BoE+Primo",
	"BOE and saronite",
	"B+SFS+DBW Res",
	"B+SFS+dbw ress",
	"BEO+P res",
	"+BOE+P Ress",
	"(Boe &Primo&SFS",
	"B+P + Marrow",
	"(Boe+Primo+",
	"B+P+Death",
	"[boe+P Res]",
	"(b+p+sfs",
	"B+P res",
	"{B+P+Sfs ress",
	"BoE-orb-plans ress",
	"Boe+P Res",
	"B+P Ress",
	"(BoE+Primo+blood",
	"(Boe + Primo + Dbw Res)",
	"B+P+DBW",
	"Integrity Knights",
	"B+P+O RESS",
	"(B+P RESS)",
	"(B/p+Dbw res)",
	"(B+P+O)ress",
	"(dbw +boe+primo)",
	"( B - O - P )",
	"(DBW+Boe+P Reserved)",
	"(BOP+Solance",
	"(BOP+Solace",
	"( Boe - P ) Ress",
	"(Boe res)",
	"b+p+sfs ress",
	"Boe+Recepie+Solace ress",
	"(Boe Res)",
	"B+P= Res",
	"(BOE,PRIMO RESERV)",
	"[B+P+SFS=Res]",
	"<B+P+ Res",
	"B+p res",
	"b+p res",
	"B+P+ WFS",
	"SFS+BOE ress",
	"BOE+P RESS",
	"WTS PVP",
	"(BOE+DBW+PMS)RESS",
	"(boe+primo+dbw ress)",
	"guildi olarak",
	"(BOE+DBW+PSM)",
	"WTS RESTO",
	"CAMPEONES DEL VALHALLA",
	"(Boe+Ps+SSC ress)",
	"Boe+ PS ress",
	"(B+P) RESS",
	"P+Boe+S+",
	"B+P RES",
	"BOE ReSS",
	"selling bis",
	"BoE res.",
	"sts ress..",
	"[BOE +PRIMO",
	"(B+P+token",
	"(BOE+ORB+PATTERN",
	"(B+P+SFS",
	"BOE+ORB",
	
	"Orcish",
	
	--- Twitch streamers ---
	"sovietnik 2.9 destro",
	"Twitch.tv/JorisxTV",
	"twitch.tv/",
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
local function spamFilter(self, event, msg, _, language, ...)

	if language == "Orcish" and GetZoneText() == "Dalaran" then
		return true
	end
	
	for _, substring in ipairs( filteringSubstrings ) do
		--[[ Filter messages that contain substring. The true parameter says to ignore regex ]]
		if string_find(msg, substring, 1, true) then
			filteredMessages[msg] = true
			return true
		end
	end
	
	return false
end

local ADDON_LOADED = function( self, addon )

    if addon == "Assiduity" then
        self:UnregisterEvent( "ADDON_LOADED" )
		
		ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", spamFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL",    spamFilter)
    end
end

-----------
-- Frame --
-----------
local NeemChatFilter = CreateFrame( "Frame" )

do
    local self = NeemChatFilter
  
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

SlashCmdList["ASSIDUITYCHATFILTER"] = function ( msg )
	
	if msg == "print" then
		debug( "So far, filtered the following messages:" )
		for message, _ in pairs( filteredMessages ) do
			print(message)
		end
	elseif msg == "reset" then
		filteredMessages = {}
	else
		print( "Available commands: print, reset" )
	end
end