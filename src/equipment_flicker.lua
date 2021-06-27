
-------------------
-- Flicker cloak --
-------------------
local AssiduityCloakFlicker = CreateFrame( "Frame" )
do
    local ShowCloak = ShowCloak

    local CLOAK_REFRESH_TIME = 5
    local CLOAK_VISIBLE_MAX  = 0.31
    local CLOAK_VISIBLE_MIN  = 0.3
    
    local cloakTimer = CLOAK_REFRESH_TIME   

    local onUpdate = function(self, elapsed)

        if clockTimer > CLOAK_VISIBLE_MIN and 
           clockTimer < CLOAK_VISIBLE_MAX
        then
            ShowCloak( true )
        end
        
        if clockTimer < 0 then
            ShowCloak( false )
            clockTimer = CLOAK_REFRESH_TIME
        end
        clockTimer = clockTimer - elapsed
    end
    
    local start = function()
    
        self:SetScript( "OnUpdate", onUpdate )
    end
    
    local stop = function()
    
        self:SetScript( "OnUpdate", nil )
        ShowCloak( false )
    end

    
    local self = AssiduityCloakFlicker
    
    self.start = start
    self.stop  = stop
    
    ShowCloak( false )
end

--------------------
-- Slash Commands --
--------------------
SLASH_ASSIDUITYEQUIPMENTFLICKER1 = "/assiduitycloakflicker"
SLASH_ASSIDUITYEQUIPMENTFLICKER2 = "/aef"

SlashCmdList["ASSIDUITYEQUIPMENTFLICKER"] = function ( msg )

    if msg == "start" then
        AssiduityCloakFlicker:start()
    
    elseif msg == "stop" then
        AssiduityCloakFlicker:stop()
    else
        print( "Possible commands: start, stop." )
    end
end

