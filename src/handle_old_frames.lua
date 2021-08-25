
---------------
-- Constants --
---------------

local DISTANCE_FROM_BOTTOM = 290

local ALPHA = 0

local partyFrames = {PartyMemberBackground, PartyMemberFrame1, PartyMemberFrame2, PartyMemberFrame3, PartyMemberFrame4}
local frames = {TargetFrame, FocusFrame, PlayerFrame, PartyMemberFrame1, PartyMemberFrame2, PartyMemberFrame3, PartyMemberFrame4}

---------------
-- Functions --
---------------

local handleFrames = function()
    
    for _, frame in ipairs(frames) do
        frame:SetAlpha(ALPHA)
        frame:Hide()
        frame:UnregisterAllEvents()
    end
end

------------
-- Events --
------------ 

local PLAYER_TARGET_CHANGED = function(self)

    TargetFrame:SetAlpha(ALPHA)

    self:UnregisterEvent("PLAYER_TARGET_CHANGED")
end

local PLAYER_FOCUS_CHANGED = function(self)

    FocusFrame:SetAlpha(ALPHA)
	
	self:UnregisterEvent("PLAYER_FOCUS_CHANGED")
end 

local PARTY_MEMBERS_CHANGED = function(self)

    handleFrames()
	
	self:UnregisterEvent("PARTY_MEMBERS_CHANGED")
end

local ADDON_LOADED = function(self, addon) 
	
	if addon == "Assiduity" then
		self:UnregisterEvent("ADDON_LOADED")
		
        handleFrames()
        
		--[[
		MultiBarBottomLeft:SetMovable() 
		MultiBarBottomLeft:ClearAllPoints() 
		MultiBarBottomLeft:SetPoint( "BOTTOMRIGHT", UIParent, "BOTTOM", -58, 10 )
		MultiBarBottomLeft:SetUserPlaced( 1 )
		]]
       
        -- Hide shapeshift forms bar
		ShapeshiftBarFrame:SetAlpha(0)
        ShapeshiftBarFrame:Hide()
        ShapeshiftBarFrame:UnregisterAllEvents()
        ShapeshiftBarFrame:SetScript("OnEnter", nil)
        ShapeshiftBarFrame:SetScript("OnUpdate", nil)
        ShapeshiftBarFrame:SetScript("OnLeave", nil)
        
        for index = 0, 7 do
            local frame = _G["ShapeshiftButton" .. tostring(index)] 
            
            if frame then
                frame:Hide()
                frame:UnregisterAllEvents()
            end
        end
		
		-- Hide default Casting Bar
		CastingBarFrame:UnregisterAllEvents()
		
		self:RegisterEvent("PLAYER_FOCUS_CHANGED")
		self:RegisterEvent("PLAYER_TARGET_CHANGED")
		self:RegisterEvent("PARTY_MEMBERS_CHANGED")
	end
end

local AssiduityRepositionFrames = CreateFrame("Frame")

do
    local self = AssiduityRepositionFrames
  
    self.ADDON_LOADED          = ADDON_LOADED
	self.PLAYER_FOCUS_CHANGED  = PLAYER_FOCUS_CHANGED
	self.PLAYER_TARGET_CHANGED = PLAYER_TARGET_CHANGED
	self.PARTY_MEMBERS_CHANGED = PARTY_MEMBERS_CHANGED
    
    self:RegisterEvent("ADDON_LOADED")
    
    self:SetScript( "OnEvent", function( self, event, ... )
        self[event]( self, ... )
    end )
end