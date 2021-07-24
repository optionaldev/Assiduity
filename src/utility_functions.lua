
local select = select

local table_insert = table.insert

--- func: Returns the localized class of the player
AssiduityGetPlayerLocalizedClass = function()

    local _, localizedClass = UnitClass( "player" )
    return localizedClass
end

AssiduityGetUnitLocalizedClass = function(unit)

    local _, localizedClass = UnitClass(unit)
    return localizedClass
end

AssiduityGetInstanceType = function()
    local _, instanceType = IsInInstance()
    return instanceType
end

AssiduityUnitAuraSource = function(unit, auraName)
	local source = select(8, UnitAura(unit, auraName))
	return source == unit or (source == "player" and UnitIsUnit(unit, "player"))
end

AssiduityPrintTable = function(tbl)

	if tbl == nil then
		print("table is empty")
		return
	end

    for key, value in pairs( tbl ) do
		if type(v) == "boolean" then
			print( key .. " | " .. tostring(value))
		else 
			print( key .. " | " .. tostring(value) )
		end
    end
end

--- func: Returns the expiration time of a unit's buff
AssiduityBuffExpiration = function( unit, buff )

    local _, _, _, _, _, _,expiration = UnitBuff( unit, buff )
    return expiration
end

--- func: Returns the casting time of a spell belonging to player
AssiduityGetCastTime = function( spell )

    local _, _, _, _, _, _, castTime = GetSpellInfo( spell )
    return castTime / 1000
end

AssiduityMount = function( index )
	if not IsMounted() then 
		if (GetZoneText() == "Wintergrasp" and GetWintergraspWaitTime() == nil) or 
			not IsFlyableArea() 
		then 
			CallCompanion("MOUNT", index) 
		end 
	end
 end
 
local ChatTypeInfo_RAID_WARNING = ChatTypeInfo.RAID_WARNING

AssiduityWarn = function(message)
    RaidNotice_AddMessage(RaidWarningFrame,
                          message,
                          ChatTypeInfo_RAID_WARNING)
end

AssiduityTableJoin = function(table1, table2)

    for _, value in ipairs(table2) do
        table_insert(table1, value)
    end
end


local SOUND_FOLDER_LOCATION = "Interface\\AddOns\\Assiduity\\sounds\\"

AssiduityPlaySound = function(soundFileName)

	local fullPath = SOUND_FOLDER_LOCATION .. soundFileName .. ".wav"
	PlaySoundFile( fullPath, "Music" )
end