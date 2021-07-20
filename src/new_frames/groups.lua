
local BUTTON_WIDTH = 50
local BUTTON_HEIGHT = 40
local SEPARATOR_SIZE = 7

local DISTANCE_TO_EDGE = 1
local HEALTH_BAR_HEIGHT = 14
local POWER_BAR_HEIGHT = 3

local BAR_WIDTH = BUTTON_WIDTH - 2 * DISTANCE_TO_EDGE
--local PORTRAIT_SIZE = HEALTH_BAR_HEIGHT + POWER_BAR_HEIGHT + DISTANCE_TO_EDGE

--local BAR_HEIGHT = PORTRAIT_SIZE + 2 * DISTANCE_TO_EDGE

-- Main frame that will also handle the events
AssiduityGroupsFrame = CreateFrame("Frame", AssiduityGroupsFrame, UIParent)

local handleCurrentState = function()

	if GetRealNumPartyMembers() == 0 and GetRealNumRaidMembers() == 0 then
		AssiduityGroupsFrame:SetAlpha(0.2)
	elseif not IsInInstance() then
		AssiduityGroupsFrame:SetAlpha(0.5)
	else 
		AssiduityGroupsFrame:SetAlpha(1)
	end
end

do 
	local self = AssiduityGroupsFrame
	
	self:SetSize(SEPARATOR_SIZE, 4 * BUTTON_HEIGHT + SEPARATOR_SIZE)
	self:SetPoint("CENTER", UIParent, "CENTER", 0, -240)
	
	local background = self:CreateTexture(nil, "BACKGROUND")
	background:SetTexture(0, 0, 0)
	background:SetAllPoints()
	
	handleCurrentState()
end

--[[
	Create horizontal bar that separated mdps group from rdps group
]]

local AssiduityGroupsFrameDpsSeparator = CreateFrame("Frame", nil, AssiduityGroupsFrame)

do 
	local self = AssiduityGroupsFrameDpsSeparator
	
	self:SetSize(BUTTON_WIDTH * 5, SEPARATOR_SIZE)
	self:SetPoint("RIGHT", 
				  AssiduityGroupsFrame, 
				  "LEFT")
	
	local background = self:CreateTexture(nil, "BACKGROUND")
	background:SetTexture(0, 0, 0)
	background:SetAllPoints()
end

local AssiduityGroupsFrameTankHealSeparator = CreateFrame("Frame", nil, AssiduityGroupsFrame)

do 
	local self = AssiduityGroupsFrameTankHealSeparator
	
	self:SetSize(3 * BUTTON_WIDTH, SEPARATOR_SIZE)
	self:SetPoint("LEFT", 
				  AssiduityGroupsFrame, 
				  "RIGHT",
				  0,
				  BUTTON_HEIGHT)
	
	local background = self:CreateTexture(nil, "BACKGROUND")
	background:SetTexture(0, 0, 0)
	background:SetAllPoints()
end

do 
	local self = CreateFrame("Frame", nil, AssiduityGroupsFrame)
end


local handleFrameCreation = function(frameType)

	local frameColors = {
		["tank"] = { 1, 0, 0},
		["rdps"] = {0, 0, 1},
		["mdps"] = {1, 1, 0},
		["heal"] = {0, 1, 0}
	}

	local result = CreateFrame("Button", nil, AssiduityGroupsFrame, "SecureUnitButtonTemplate")
	result:SetSize(BUTTON_WIDTH, BUTTON_HEIGHT)
	
	local background = result:CreateTexture(nil, "BACKGROUND")
	background:SetTexture(0, 0, 0, 0.4)
	background:SetAllPoints()
	
	local healthBar = result:CreateTexture(nil, "BACKGROUND")
	healthBar:SetTexture(unpack(frameColors[frameType]))
	healthBar:SetSize(BAR_WIDTH, HEALTH_BAR_HEIGHT)
	healthBar:SetPoint("TOPLEFT", 
					   result, 
					   "TOPLEFT",
					   DISTANCE_TO_EDGE, 
					   -DISTANCE_TO_EDGE)
				
	
	local powerBar = result:CreateTexture(nil, "BACKGROUND")
	powerBar:SetTexture(0, 1, 1)
	powerBar:SetSize(BAR_WIDTH, POWER_BAR_HEIGHT)
	powerBar:SetPoint("TOP", 
					  healthBar, 
					  "BOTTOM",
					  0, 
					  -1)
	powerBar:SetAlpha(0.5)
					  
	
	--local portrait = result:CreateTexture(nil, "BACKGROUND")
	--portrait:SetTexture(1, 1, 1)
	--portrait:SetSize(PORTRAIT_SIZE, PORTRAIT_SIZE)
	--portrait:SetPoint("RIGHT", 
	--				  result, 
	--				  "RIGHT",
	--				  -DISTANCE_TO_EDGE, 
	--				  0)
	--result.portrait = portrait
	
	return result
end

--[[
	Position a frame based the type of frames involved.
	
	Params:
		origin: The frame that the 'anchored' will be anchored to.
		point: The origin's side to which 'anchored' will be anchored to.
		anchored: The frame that is getting anchored to 'origin' frame.
]]

local OPPOSITE_POINT = {
	["LEFT"]   = "RIGHT",
	["RIGHT"]  = "LEFT",
	["TOP"]    = "BOTTOM",
	["BOTTOM"] = "TOP"
}

local position = function(anchored, point, origin)

	local anchoredPoint = OPPOSITE_POINT[point]
	anchored:SetPoint(anchoredPoint, origin, point)
end

do
	local self = AssiduityGroupsFrame

	-- Should have a maximum of 3 tanks
	local tank  = handleFrameCreation("tank")
	local tank2 = handleFrameCreation("tank")
	local tank3 = handleFrameCreation("tank")
	
	tank:SetPoint("BOTTOMLEFT", AssiduityGroupsFrameTankHealSeparator, "TOPLEFT")
	
	position(tank2, "RIGHT", tank)
	position(tank3, "RIGHT", tank2)
	
	
	-- Should have a maximum of 10 rdps
	local rdps   = handleFrameCreation("rdps")
	local rdps2  = handleFrameCreation("rdps")
	local rdps3  = handleFrameCreation("rdps")
	local rdps4  = handleFrameCreation("rdps")
	local rdps5  = handleFrameCreation("rdps")
	local rdps6  = handleFrameCreation("rdps")
	local rdps7  = handleFrameCreation("rdps")
	local rdps8  = handleFrameCreation("rdps")
	local rdps9  = handleFrameCreation("rdps")
	local rdps10 = handleFrameCreation("rdps")
	
	rdps:SetPoint("TOPRIGHT", AssiduityGroupsFrameDpsSeparator, "BOTTOMRIGHT")
	
	position(rdps2,  "LEFT",  rdps)
	position(rdps3,  "LEFT",  rdps2)
	position(rdps4,  "LEFT",  rdps3)
	position(rdps5,  "LEFT",  rdps4)
	position(rdps6,  "BOTTOM", rdps)
	position(rdps7,  "BOTTOM", rdps2)
	position(rdps8,  "BOTTOM", rdps3)
	position(rdps9,  "BOTTOM", rdps4)
	position(rdps10, "BOTTOM", rdps5)
	
	-- Should have a maximum of 10 mdps
	local mdps   = handleFrameCreation("mdps")
	local mdps2  = handleFrameCreation("mdps")
	local mdps3  = handleFrameCreation("mdps")
	local mdps4  = handleFrameCreation("mdps")
	local mdps5  = handleFrameCreation("mdps")
	local mdps6  = handleFrameCreation("mdps")
	local mdps7  = handleFrameCreation("mdps")
	local mdps8  = handleFrameCreation("mdps")
	local mdps9  = handleFrameCreation("mdps")
	local mdps10 = handleFrameCreation("mdps")
	
	mdps:SetPoint("BOTTOMRIGHT", AssiduityGroupsFrameDpsSeparator, "TOPRIGHT")
	
	position(mdps2,	 "LEFT",   mdps)
	position(mdps3,  "LEFT",   mdps2)
	position(mdps4,  "LEFT",   mdps3)
	position(mdps5,  "LEFT",   mdps4)
	position(mdps6,  "TOP", mdps)
	position(mdps7,  "TOP", mdps2)
	position(mdps8,  "TOP", mdps3)
	position(mdps9,  "TOP", mdps4)
	position(mdps10, "TOP", mdps5)

	
	-- Usually there's 5, but might have more in Valithria encounter
	local heal   = handleFrameCreation("heal")
	local heal2  = handleFrameCreation("heal")
	local heal3  = handleFrameCreation("heal")
	local heal4  = handleFrameCreation("heal")
	local heal5  = handleFrameCreation("heal")
	local heal6  = handleFrameCreation("heal")
	local heal7  = handleFrameCreation("heal")
	local heal8  = handleFrameCreation("heal")
	local heal9  = handleFrameCreation("heal")
	local heal10 = handleFrameCreation("heal")
	
	heal:SetPoint("TOPLEFT", AssiduityGroupsFrameTankHealSeparator, "BOTTOMLEFT")
	
	--[[ Positions
		1 - 2 - 7
		3 - 4 - 8
		5 - 6 - 9
	]]
	position(heal2,  "RIGHT",  heal)
	position(heal3,  "BOTTOM", heal)
	position(heal4,  "BOTTOM", heal2)
	position(heal5,  "BOTTOM", heal3)
	position(heal6,  "BOTTOM", heal4)
	position(heal7,  "RIGHT",  heal2)
	position(heal8,  "RIGHT",  heal4)
	position(heal9,  "RIGHT",  heal6)
end


