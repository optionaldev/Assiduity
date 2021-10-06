
local frame = CreateFrame("Button", "AssiduityTarget", UIParent, "SecureUnitButtonTemplate")

frame:SetPoint("CENTER", UIParent, "CENTER", 350, -205)
frame:SetAttribute("unit", "target")
frame.changeEvent = "PLAYER_TARGET_CHANGED"
frame.sizing = "LARGE"

AssiduityRegisterFrame(frame)

local comboPointsFrame = CreateFrame("Frame")

---------------
-- Functions --
---------------
local createComboPoint = function(self)

    local comboPoint = self:CreateTexture(nil, "BACKGROUND")
    comboPoint:SetTexture("Interface\\AddOns\\Assiduity\\img\\combo_point")
    comboPoint:SetSize(14, 14)
    return comboPoint
end

local handleComboPoints = function()
    
    local comboPointsCount = GetComboPoints("player", "target")
    
    for index = 1, comboPointsCount do
        comboPoints[index]:Show()
    end
    
    for index = comboPointsCount + 1, 5 do
        comboPoints[index]:Hide()
    end
end

------------
-- Events --
------------
local UNIT_COMBO_POINTS = function(self, unit)

    if unit == "player" then
        handleComboPoints()
    end
end

local PLAYER_TARGET_CHANGED = function(self)

    handleComboPoints()
end

-----------
-- Frame --
-----------
do
    

    local comboPoint1 = createComboPoint(frame)
    local comboPoint2 = createComboPoint(frame)
    local comboPoint3 = createComboPoint(frame)
    local comboPoint4 = createComboPoint(frame)
    local comboPoint5 = createComboPoint(frame)
    
    comboPoint1:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 0, 3)
    comboPoint2:SetPoint("LEFT", comboPoint1, "RIGHT", 0, 0)
    comboPoint3:SetPoint("LEFT", comboPoint2, "RIGHT", 0, 0)
    comboPoint4:SetPoint("LEFT", comboPoint3, "RIGHT", 0, 0)
    comboPoint5:SetPoint("LEFT", comboPoint4, "RIGHT", 0, 0)
    
    comboPoints = {comboPoint1, comboPoint2, comboPoint3, comboPoint4, comboPoint5}
    
    comboPointsFrame.PLAYER_TARGET_CHANGED = PLAYER_TARGET_CHANGED
    comboPointsFrame.UNIT_COMBO_POINTS     = UNIT_COMBO_POINTS
    
    comboPointsFrame:RegisterEvent("UNIT_COMBO_POINTS")
    comboPointsFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    
    comboPointsFrame:SetScript("OnEvent", function(self, event, ...)
        self[event](self, ...)
    end)
end