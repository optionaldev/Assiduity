
local frame = CreateFrame("Button", "AssiduityTarget", UIParent, "SecureUnitButtonTemplate")

frame:SetPoint("CENTER", UIParent, "CENTER", 350, -205)
frame:SetAttribute("unit", "target")
frame.changeEvent = "PLAYER_TARGET_CHANGED"

AssiduityRegisterFrame(frame, "LARGE")