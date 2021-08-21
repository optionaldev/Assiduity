
local frame = CreateFrame("Button", "AssiduityTarget", UIParent, "SecureUnitButtonTemplate")

frame:SetPoint("CENTER", UIParent, "CENTER", 500, -150)
frame:SetAttribute("unit", "target")
frame.portraitText = "G"
frame.changeEvent = "PLAYER_TARGET_CHANGED"

AssiduityRegisterFrame(frame)