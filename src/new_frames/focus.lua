
local frame = CreateFrame("Button", "AssiduityFocus", UIParent, "SecureUnitButtonTemplate")

frame:SetPoint("CENTER", UIParent, "CENTER", 300, -72)
frame:SetAttribute("unit", "focus")
frame.changeEvent = "PLAYER_FOCUS_CHANGED"

AssiduityRegisterFrame(frame, "LARGE")