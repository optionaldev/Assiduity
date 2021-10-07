
local frame = CreateFrame("Button", "AssiduityPlayer", UIParent, "SecureUnitButtonTemplate")

frame:SetPoint("CENTER", UIParent, "CENTER", -300, -72)
frame:SetAttribute("unit", "player")
frame.orientation = "LEFT_TO_RIGHT"
frame.sizing = "LARGE"
frame.hideTarget = 1

AssiduityRegisterFrame(frame)