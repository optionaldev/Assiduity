local MINIMUM_AMOUNT = 19

local GetInstanceType = AssiduityGetInstanceType

local AssiduityReagents = CreateFrame("Frame")
do
    local Warn = AssiduityWarn

    local CLASS_TO_REAGENTS = {

        ["GLOBAL"] = {
            --21215,  --- "Graccu's Mince Meat Fruitcake",
            34722,  --- "Heavy Frostweave Bandage"
        },
        ["DEATHKNIGHT"] = {},
        ["DRUID"] = {
            43236,  --- "Star's Sorrow",
            44614,  --- "Starleaf Seed",
            44605,  --- "Wild Spineleaf"
        },
        ["HUNTER"] = {},
        ["MAGE"] = {},
        ["PALADIN"] = {},
        ["PRIEST"] = {
            43236,  --- "Star's Sorrow",
            44615,  --- "Devout Candle"
            17056,  --- "Light Feather"
        },
        ["ROGUE"] = {},
        ["SHAMAN"] = {},
        ["WARLOCK"] = {},
        ["WARRIOR"] = {}
    }
    
    GetPlayerLClass = AssiduityGetPlayerLocalizedClass
    table_join      = AssiduityTableJoin
    
    REAGENTS = CLASS_TO_REAGENTS.GLOBAL      
    table_join(REAGENTS, CLASS_TO_REAGENTS[GetPlayerLClass()])
     
    local firstTime = 1     

    local isReagentEnough = function(itemID)
	local total = 0
        
        for i = 0, 4 do
            for j = 1, GetContainerNumSlots( i ) do
                if GetContainerItemID( i, j ) == itemID then
                    local _,count = GetContainerItemInfo( i, j )
                    total = total + count
                    if total > MINIMUM_AMOUNT then
                        return 1
                    end
                end
            end
        end
    end
    
    local onEvent = function( self ) 
        if not firstTime and GetInstanceType() ~= "arena" then
            for _,reagent in ipairs(REAGENTS) do
                if not isReagentEnough(reagent) then
                    local name = GetItemInfo(reagent)
					if name ~= nil then
						print("Low on " .. name)
						--Warn("Low on " .. name)
					end
                end
            end
        end
        firstTime = nil
    end

    local self = AssiduityReagents
    
    self:RegisterEvent("PLAYER_ENTERING_WORLD")

    self:SetScript("OnEvent", onEvent)
end
