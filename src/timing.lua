--[[
    How to use:
    --- Calling this will hide $frame after $duration.
    --- Use "OnHide" script of $frame to detect when $duration finished.
    --- You can overwrite the $duration for a certain $frame by recalling with 
    --- the same frame.
    TimingLibDelayedHide( frame, duration )
    
    --- Remove $frame for the list of frames being monitored
    TimingLibCancelHide( frame )
]]

---------------------------------
-- Standard timerFS formatting --
---------------------------------
local standardFormatting = function( self, timer )

    if timer > 60 then
        return math_ceil( timer / 60 ) .. "\""
        
    elseif timer > 20 then
        return math_ceil( timer / 10 ) .. "0'"
    else
        return math_ceil( timer )
    end
end


local debug = print
-- local debug = function() end
------------------------
-- Imports and locals --
------------------------
local math_ceil    = math.ceil
local table_insert = table.insert
local table_remove = table.remove

--- t: contains all frames that are being counted down

--- model: { { frame, expiration }, ... }
local frameTimers = {}
local fontstringTimers = {}

----------------------
-- Global functions --
---------------------
--- f: 
--- p1:
--- r1:
TimingLibDelayedHide = function( frame, offset )

    for i in ipairs( frameTimers ) do
        if frame == frameTimers[i][1] then
            frameTimers[i][2] = GetTime() + offset 
            return
        end
    end
    
    table_insert( frameTimers, { frame, GetTime() + offset })
end

TimingLibCancelHide = function( frame )

    for i in ipairs( frameTimers ) do
        if frame == frameTimers[i] then
            table_remove( frameTimers, i )
            return
        end
    end
end

---------------------
-- Local functions --
---------------------

-------------
-- Scripts --
-------------
--- f:
local OnUpdate = function( self )

    local currentTime = GetTime()
    
    for i, frameTable in ipairs( frameTimers ) do
        local timeLeft = frameTable[2] - currentTime
        
        if timeLeft < 0 then
            frameTable[1]:Hide()
            table_remove( frameTimers, i )
        end 
    end 
    
    for i in ipairs( fontstringTimers ) do
        if fontstringTimers[i].expiration then
            fontstringTimers[i]:refresh( currentTime )
        else    
            fontstringTimers[i]:Hide()
            table_remove( fontstringTimers, i )
        end
    end
end

--------------------
-- Frame function --
--------------------
local clear = function( self )

    for i in ipairs( fontstringTimers ) do
        if fontstringTimers[i] == self then
            self:Hide()
            self:GetParent():SetAlpha( 1 )
            table_remove( fontstringTimers, i )   
            return
        end
    end
end

local refresh = function( self, currentTime )

    local timer = self.expiration - currentTime
    
    if timer > 0 then
        local formattedText = self:formatting( timer )
        local oldText       = self.timerFS:GetText()
        
        if formattedText ~= oldText then
            self.timerFS:SetText( formattedText )
        end
    else
        self.expiration = nil
        self:Hide()
    end
end

local startExpiration = function( self, expiration )

    self.expiration = expiration
    
    table_insert( fontstringTimers, self )
    
    self:Show()
end

local startDuration = function( self, duration )

    self.expiration = GetTime() + duration
    
    table_insert( fontstringTimers, self )
    
    self:Show()
end

local init = function( self, font, formatting )

    self.init            = nil
    self.clear           = clear
    self.refresh         = refresh
    self.startDuration   = startDuration
    self.startExpiration = startExpiration

    if font then
        self.timerFS:SetFontObject( font )
    end
    
    if formatting then
        self.formatting = formatting
    else
        self.formatting = standardFormatting
    end
end

 
-----------
-- Frame --
-----------
local AssiduityTimingFrame = CreateFrame("Frame") do
    local self = AssiduityTimingFrame 
    self:SetScript("OnUpdate", OnUpdate)
end

AssiduityTimingTemplate_OnLoad = function(self)

    self.init = init
end
