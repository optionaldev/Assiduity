
print("Loaded utility functions.")

--- func: Returns the localized class of the player
AssiduityGetPlayerLocalizedClass = function()

    local _, localizedClass = UnitClass( "player" )
    return localizedClass
end

AssiduityGetInstanceType = function()
    local _, instanceType = IsInInstance()
    return instanceType
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