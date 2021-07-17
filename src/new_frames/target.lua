 
 do
	AssiduityTarget_OnLoad = function( self )

        local DEBUFFS  = {
			"Moonfire",
			"Insect Swarm",
			"Wrath(Rank 1)"     --- adjust
		}
        
        -- self.PARTY_LEADER_CHANGED   = NPL_PARTY_LEADER_CHANGED
        self.PLAYER_ENTERING_WORLD  = PLAYER_ENTERING_WORLD
		self.PLAYER_TARGET_CHANGED = PLAYER_X_CHANGED
        self.UNIT_MANA              = UNIT_MANA
        self.UNIT_AURA              = UNIT_AURA
        
        _, self.class     = UnitClass( "target" )
		self.register	  = register
        self.string       = {
			["bgOffset"]      = 3,
			["castOffset"]    = 10,
			["healthHeight"]  = 30,
			["height"]        = 48,
			["spacing"]       = LARGE_SPACING,
			["width"]         = 230,
		}
        self.unit         = "target"
		self.unregister	  = unregister
        self.updateAura   = updateAura
        -- self.updateLeader = NPL_updateLeader
        
        self:SetAttribute( "unit", "target" )
        self:SetAttribute( "type", "macro" )
        -- self:SetAttribute( "type1", "target" )
        -- self:SetAttribute( "ctrl-macrotext3", "/forfeit" )
        -- self:SetAttribute( "shift-macrotext3", "/run LeaveParty()" )
        
        self:SetScript( "OnEvent", function( self, event, ... )
			if self[event] == nil then
				print("player211:")
				print(event)
			end
            self[event]( self, ... )
        end )
        
        self:RegisterForClicks( "AnyUp" )
        -- self:RegisterEvent( "PARTY_LEADER_CHANGED" )
        self:RegisterEvent( "PLAYER_ENTERING_WORLD" )
        self:RegisterEvent( "PLAYER_TARGET_CHANGED" )
        -- self:RegisterEvent( "PLAYER_REGEN_DISABLED" )
        -- self:RegisterEvent( "PLAYER_REGEN_ENABLED" )
        --self:RegisterEvent( "UNIT_AURA" )
        -- self:RegisterEvent( "UNIT_TARGET" )
        
        UnitFrameInit( self, "RIGHT" )
        
        self:SetPoint( "BOTTOMRIGHT", UIParent, "BOTTOM",
                       SETTINGS.bigFrameOffsetV * 3, SETTINGS.bigFrameOffsetH )
        
        -- debug( "player196 self, buffF", self, self.buffF, self.buffF.init )
        
        self.buffF:init( BUFF_TO_FILTERED)
        self.playerBuffF:init( nil, PLAYER_ALLOWED_BUFFS)
        self.debuffF:init(DEBUFF_TO_FILTERED)
        
        self.powerSB:register()
        
        self:updateAura()
        --self:updateLeader()
		
		if not UnitExists( "target" ) then
			self:Hide()
		end
    end
end

