
-------------
-- Imports --
-------------

local ipairs = ipairs
local tostring = tostring

local IsInInstance = IsInInstance

local autoHideObserver = CreateFrame("Frame")
local partyFrames

local parentFrame = CreateFrame("Frame")

---------------
-- Functions --
---------------

local handleTogglingVisibility = function()
    
    local _, instanceType = IsInInstance()

    if instanceType == "raid" then
        parentFrame:Hide()
    else 
        parentFrame:Show()
    end
end

local createFrame = function(index)

    local stringIndex = tostring(index)

    frame = CreateFrame("Button", "AssiduityParty" .. stringIndex, parentFrame, "SecureUnitButtonTemplate")
    frame:SetAttribute("unit", "party" .. stringIndex)
    frame:SetAttribute("type1", "target")
    frame.changeEvent = "PARTY_MEMBERS_CHANGED"
    frame.orientation = "LEFT_TO_RIGHT"
    frame.sizing = "SMALL"
    
    AssiduityRegisterFrame(frame)

    return frame
end

------------
-- Events --
------------

local PLAYER_ENTERING_WORLD = function()

    handleTogglingVisibility()
end



------------
-- Frames --
------------

local party1 = createFrame(1)
local party2 = createFrame(2)
local party3 = createFrame(3)
local party4 = createFrame(4)

partyFrames = {party1, party2, party3, party4}

party1:SetPoint("BOTTOMRIGHT", UIParent, "CENTER", -250, 20)
party2:SetPoint("BOTTOM", party1, "TOP", 0, 60)
party3:SetPoint("BOTTOM", party2, "TOP", 0, 60)
party4:SetPoint("BOTTOM", party3, "TOP", 0, 60)

do 
    autoHideObserver.PLAYER_ENTERING_WORLD = PLAYER_ENTERING_WORLD
    
    autoHideObserver:RegisterEvent("PLAYER_ENTERING_WORLD")

    autoHideObserver:SetScript("OnEvent", function(self, event, ...)
        self[event](self, ...)
    end)
    
    handleTogglingVisibility()
end