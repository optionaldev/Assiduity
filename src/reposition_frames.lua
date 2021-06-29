
local DISTANCE_FROM_BOTTOM = 290

local PLAYER_TARGET_CHANGED = function(self)

	-- Unlike PlayerFrame, TargetFrame doesn't exist initially, so we can only change
	-- the anchors once the frame has appeared
	
	TargetFrame:ClearAllPoints()
	TargetFrame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOM", 150, DISTANCE_FROM_BOTTOM - 50)
end

local PLAYER_FOCUS_CHANGED = function(self)

	-- Unlike PlayerFrame, FocusFrame doesn't exist initially, so we can only change
	-- the anchors once the frame has appeared
	
	FocusFrame:ClearAllPoints()
	FocusFrame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOM", 150, DISTANCE_FROM_BOTTOM + 150)
	
	self:UnregisterEvent("PLAYER_FOCUS_CHANGED")
end 

local ADDON_LOADED = function(self, addon) 
	
	if addon == "Assiduity" then
		self:UnregisterEvent("ADDON_LOADED")
		
		-- Reposition the PlayerFrame
		
		
		print("reposition Player frame")
		PlayerFrame:ClearAllPoints()
		PlayerFrame:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOM", -150, DISTANCE_FROM_BOTTOM + 20)  
		
		--[[
		MultiBarBottomLeft:SetMovable() 
    MultiBarBottomLeft:ClearAllPoints() 
    MultiBarBottomLeft:SetPoint( "BOTTOMRIGHT", UIParent, 
                                 "BOTTOM", -58, 10 )
    MultiBarBottomLeft:SetUserPlaced( 1 )
		]]
		
		self:RegisterEvent("PLAYER_FOCUS_CHANGED")
		self:RegisterEvent("PLAYER_TARGET_CHANGED")
	end
end

local AssiduityRepositionFrames = CreateFrame("Frame")

do
    local self = AssiduityRepositionFrames
  
    self.ADDON_LOADED = ADDON_LOADED
	self.PLAYER_FOCUS_CHANGED = PLAYER_FOCUS_CHANGED
	self.PLAYER_TARGET_CHANGED = PLAYER_TARGET_CHANGED
    
    self:RegisterEvent("ADDON_LOADED")
    
    self:SetScript( "OnEvent", function( self, event, ... )
        self[event]( self, ... )
    end )
end