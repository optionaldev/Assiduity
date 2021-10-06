
local frame = CreateFrame("Button", "AssiduityPlayer", UIParent, "SecureUnitButtonTemplate")

frame:SetPoint("CENTER", UIParent, "CENTER", -300, -72)
frame:SetAttribute("unit", "player")
frame.castbarPosition = "RIGHT"
frame.sizing = "LARGE"

AssiduityRegisterFrame(frame)