
-------------
-- Imports --
-------------

local tostring = tostring

local createFrame = function(index)

    local stringIndex = tostring(index)

    frame = CreateFrame("Button", "AssiduityArena" .. stringIndex, UIParent, "SecureUnitButtonTemplate")
    frame:SetAttribute("unit", "arena" .. stringIndex)
    frame:SetAttribute("type1", "target")
    frame.changeEvent = "ARENA_OPPONENT_UPDATE"
    --frame:SetAttribute("unit", "target")
    --frame.changeEvent = "PLAYER_TARGET_CHANGED"
    
    AssiduityRegisterFrame(frame, "SMALL")

    return frame
end

local arena1 = createFrame(1)
local arena2 = createFrame(2)
local arena3 = createFrame(3)
local arena4 = createFrame(4)
local arena5 = createFrame(5)

arena1:SetPoint("BOTTOMLEFT", UIParent, "CENTER", 250, 0)
arena2:SetPoint("BOTTOM", arena1, "TOP", 0, 60)
arena3:SetPoint("BOTTOM", arena2, "TOP", 0, 60)
arena4:SetPoint("BOTTOM", arena3, "TOP", 0, 60)
arena5:SetPoint("BOTTOM", arena4, "TOP", 0, 60)