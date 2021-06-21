
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