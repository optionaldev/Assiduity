
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