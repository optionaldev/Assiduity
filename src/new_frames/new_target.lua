local DISTANCE_TO_EDGE = 3
local BAR_WIDTH = 180
local HEALTH_BAR_HEIGHT = 25
local POWER_BAR_HEIGHT = 15
local PORTRAIT_SIZE = HEALTH_BAR_HEIGHT + POWER_BAR_HEIGHT + DISTANCE_TO_EDGE

AssiduityNewTarget = CreateFrame("Frame")

AssiduityNewTarget:SetSize(BAR_WIDTH + PORTRAIT_SIZE + 3 * DISTANCE_TO_EDGE, 
						   PORTRAIT_SIZE + 2 * DISTANCE_TO_EDGE)

AssiduityNewTarget:ClearAllPoints()
AssiduityNewTarget:SetPoint("CENTER", UIParent, "CENTER")

do 
	local self = AssiduityNewTarget

	local background = self:CreateTexture(nil, "BACKGROUND")
	background:SetTexture(0, 0, 0, 0.4)
	background:SetAllPoints()
	
	--[[
		using CreateTexture("$parentName") doesn't work
		maybe only works for frames?
	]]
	local healthBar = self:CreateTexture("$parentHealthBar", "BACKGROUND")
	healthBar:SetTexture(1, 1, 0)
	healthBar:SetSize(BAR_WIDTH, HEALTH_BAR_HEIGHT)
	healthBar:SetPoint("TOPLEFT", 
					   self, 
					   "TOPLEFT",
					   DISTANCE_TO_EDGE, 
					   -DISTANCE_TO_EDGE)
				
	
	local powerBar = self:CreateTexture("$parentHealthBar", "BACKGROUND")
	powerBar:SetTexture(0, 1, 1)
	powerBar:SetSize(BAR_WIDTH, POWER_BAR_HEIGHT)
	powerBar:SetPoint("BOTTOMLEFT", 
					  self, 
					  "BOTTOMLEFT",
					  DISTANCE_TO_EDGE, 
					  DISTANCE_TO_EDGE)
					  
	
	local portrait = self:CreateTexture(nil, "BACKGROUND")
	AssiduityNewTarget.portrait:SetTexture(1, 1, 1)
	portrait:SetSize(PORTRAIT_SIZE, PORTRAIT_SIZE)
	portrait:SetPoint("RIGHT", 
					  self, 
					  "RIGHT",
					  -DISTANCE_TO_EDGE, 
					  0)
	self.portrait = portrait
end

