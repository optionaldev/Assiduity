
-------------
-- Imports --
-------------

local tostring = tostring

------------
-- Frames --
------------

local createFrame = function(index)

    local stringIndex = tostring(index)

    frame = CreateFrame("Button", "AssiduityParty" .. stringIndex, UIParent, "SecureUnitButtonTemplate")
    frame:SetAttribute("unit", "party" .. stringIndex)
    frame:SetAttribute("type1", "target")
    frame.changeEvent = "PARTY_MEMBERS_CHANGED"
    --frame:SetAttribute("unit", "target")
    --frame.changeEvent = "PLAYER_TARGET_CHANGED"
    
    AssiduityRegisterFrame(frame, "SMALL")

    return frame
end

local party1 = createFrame(1)
local party2 = createFrame(2)
local party3 = createFrame(3)
local party4 = createFrame(4)

party1:SetPoint("BOTTOMRIGHT", UIParent, "CENTER", -250, 20)
party2:SetPoint("BOTTOM", party1, "TOP", 0, 60)
party3:SetPoint("BOTTOM", party2, "TOP", 0, 60)
party4:SetPoint("BOTTOM", party3, "TOP", 0, 60)