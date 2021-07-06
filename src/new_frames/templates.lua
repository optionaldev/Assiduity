--[[
    auraEntry = { texture, count, dispelType, duration, expiration, caster, 
                  auraID }
    aurasTable = { auraEntry1, ... }
    
    AuraFrame:update( unpack( auraEntry:table ))
    
    AurasFrame:fill( aurasTable:table )
              :update()
              :init( filter:table, sortTable:table )
              
    ExtraFrame:register()
              :unregister()
              :updateName()
              :init()
    
    HealthSB:register()
            :unregister()
            :init()
               
    IconFrame:setIcon( icon:string, texCoord:table/nil )
             :setSelf()
             :setUnit( text:string, bgColor:table, fontColor:table )
             :update()
             :init()
    
    OverlayHealthSB:register()
                   :unregister()
                   :init()
                 
    PowerSB:register()
           :unregister()
           :init()
    
    SpecFrame:update()
             :init()
             
    TargetOfUnitFrame:register()
                     :unregister()
                     :init()
             
    UnitPet:init()
]]

local debug = print
-- local debug = function() end
------------------------
-- Imports and locals --
------------------------
local ipairs = ipairs
local unpack = unpack

local math_ceil = math.ceil
local math_floor = math.floor


local LARGE_BACKGROUND_OFFSET   = 2
local LARGE_SPACING             = 2
local SMALL_BACKGROUND_OFFSET   = 1
local SMALL_SPACING             = 1

local STANDARD_BACKGROUND_COLOR = { 0, 0, 0, 50 }

local AURA_FRAME_SMALL  = "AURA_FRAME_SMALL"
local AURA_FRAME_LARGE  = "AURA_FRAME_LARGE"
local AURAS_FRAME_SMALL = "AURAS_FRAME_SMALL"
local AURAS_FRAME_LARGE = "AURAS_FRAME_LARGE"  
local BUFFS_FRAME       = "BUFFS_FRAME" 
local DEBUFFS_FRAME     = "DEBUFFS_FRAME" 
local HEALTH_SB_SMALL   = "HEALTH_SB_SMALL"
local HEALTH_SB_LARGE   = "HEALTH_SB_LARGE"
local ICON_FRAME_SMALL  = "ICON_FRAME_SMALL"
local ICON_FRAME_LARGE  = "ICON_FRAME_LARGE" 
local POWER_SB_SMALL    = "POWER_SB_SMALL"
local POWER_SB_LARGE    = "POWER_SB_LARGE"
local UNIT_FRAME_SMALL  = "UNIT_FRAME_SMALL"
local UNIT_FRAME_LARGE  = "UNIT_FRAME_LARGE"
local UNIT_TARGET_FRAME = "UNIT_TARGET_FRAME"

local SETTINGS = {
    ["bgColor"]         = STANDARD_BACKGROUND_COLOR,
    ["bigFrameOffsetH"] = 200,
    ["bigFrameOffsetV"] = 150,
    [AURA_FRAME_SMALL] = {
        ["countFont"]   = "AssiduityAuraCountFontSmall",
        ["countOffset"] = 1,
        ["iconOffset"]  = 2,
        ["size"]        = 15,
    },
    [AURA_FRAME_LARGE] = {
        ["countFont"]   = "AssiduityAuraCountFontLarge",
        ["countOffset"] = 2,
        ["iconOffset"]  = 1.5,
        ["size"]        = 20,
    },
    [AURAS_FRAME_SMALL] = { 
        ["bgOffset"] = SMALL_BACKGROUND_OFFSET,
        ["spacing"]  = SMALL_SPACING,
    },
    [AURAS_FRAME_LARGE] = {
        ["bgOffset"] = LARGE_BACKGROUND_OFFSET,
        ["spacing"]  = LARGE_SPACING,
    },
    [BUFFS_FRAME] = {
        ["bgColor"] = { 0.5, 0.5, 0.5 },
        ["func"]    = UnitBuff,
    },
    [DEBUFFS_FRAME] = {
        ["bgColor"] = { 0, 0, 0 },
        ["func"]    = UnitDebuff,
    },
    [HEALTH_SB_SMALL] = {
        ["textFont"] = "AssiduityHealthStatusBarFontSmall",
    },
    [HEALTH_SB_LARGE] = {
        ["textFont"] = "AssiduityHealthStatusBarFontLarge",
    },
    [ICON_FRAME_SMALL] = {
        ["textFont"] = "AssiduityIconTextFontSmall",
    },
    [ICON_FRAME_LARGE] = {
        ["textFont"] = "AssiduityIconTextFontLarge",
    },
    [POWER_SB_SMALL] = {
        ["textFont"] = "AssiduityPowerStatusBarFontSmall",
    },
    [POWER_SB_LARGE] = {
        ["textFont"] = "AssiduityPowerStatusBarFontLarge",
    },
    [UNIT_FRAME_SMALL] = {
        ["bgOffset"]      = 2,
        ["castOffset"]    = 7,
        ["healthHeight"]  = 25,
        ["height"]        = 38,
        ["spacing"]       = SMALL_SPACING,
        ["width"]         = 180,
    },
    [UNIT_FRAME_LARGE] = {
        ["bgOffset"]      = 3,
        ["castOffset"]    = 10,
        ["healthHeight"]  = 30,
        ["height"]        = 48,
        ["spacing"]       = LARGE_SPACING,
        ["width"]         = 230,
    },
    [UNIT_TARGET_FRAME] = {
        ["bgColor"]  = STANDARD_BACKGROUND_COLOR,
        ["bgOffset"] = LARGE_BACKGROUND_OFFSET,
    },
}

--- adjust
local AURAS_PER_ROW = 100

do  --- Aura Frame
    local AURA_COLORS = {
    
        ["Curse"]    = { 200,   0, 255 },
        ["Disease"]  = { 220, 220,   0 },
        ["Magic"]    = {   0,   0, 200 },
        ["Poison"]   = {   0, 200,   0 },
    }

    local update = function( self, texture, count, dispelType, duration,
                             expiration, caster, auraID, name )
        
        self.auraID = auraID
        
        if count > 1 then
            self.countFS:SetText( count )
        else
            self.countFS:SetText( nil )
        end
        
        if dispelType and AURA_COLORS[dispelType] then 
            self.dispelTypeT:Show()
            self.dispelTypeT:SetTexture( unpack( AURA_COLORS[dispelType] ))
        else
            self.dispelTypeT:Hide()
        end
        
        if expiration and expiration ~= 0 then
            self.CD:SetCooldown( expiration - duration, duration )
            self.CD:Show()
        else
            self.CD:Hide()
        end   
        
        self.iconT:SetTexture( texture )
        
        self:Show()
    end        
    
    local loadCommonElements = function( self )
    
        local countOffset  = SETTINGS[self.string].countOffset
        local iconOffset   = SETTINGS[self.string].iconOffset
        local size         = SETTINGS[self.string].size
        
        self.countFS:SetFontObject( SETTINGS[self.string].countFont )
        self.countFS:ClearAllPoints()
        self.countFS:SetPoint( "BOTTOMRIGHT", self, "BOTTOMRIGHT",
                               -countOffset, countOffset )
                               
        self.iconT:ClearAllPoints()
        self.iconT:SetPoint( "TOPLEFT", self, "TOPLEFT", 
                             iconOffset, -iconOffset )
        self.iconT:SetPoint( "BOTTOMRIGHT", self, "BOTTOMRIGHT",
                             -iconOffset, iconOffset )
        self.size   = size
        self.update = update
        
        self:SetSize( size, size )
    end
    
    AssiduitySmallAuraFrameTemplate_OnLoad = function( self )
    
        self.string = "AURA_FRAME_SMALL"
        loadCommonElements( self )
    end
    
    AssiduityLargeAuraFrameTemplate_OnLoad = function( self )
    
        self.string = "AURA_FRAME_LARGE"
        loadCommonElements( self )
    end
end

do  --- Auras Frame 
	
    local min          = min
    local table_insert = table.insert
    local table_remove = table.remove
    local table_sort   = table.sort
    
    local fill = function( self, auras )
        
        if #auras == 0 then
            self:Hide()
        else 
            self:Show()
            local frames = self.frames
            local firstFromLastRow, lastFromFirstRow
        
            for i in ipairs( auras ) do
                frames[i]:update( unpack( auras[i] ))
            end
            
            for i = #auras + 1, #frames do
                frames[i]:Hide()
            end
            
			local width = #auras * self.height + ( #auras - 1 ) * self.spacing
			local height = self.height
            self:SetSize( width, height )
       end
    end
    
	--[[ 
		Fetches the auras that correspond to the current frame.
		The current frame can be either buff frame or a debuff frame.
		A filtering function is applied. Filtered auras are added as
		they are discovered, to prevent filtering something accidentally.
	]]
    local getAuras = function( self )

        local 	   allowList,      filterList,      frames,      func,      unit =
              self.allowList, self.filterList, self.frames, self.func, self.unit
        local auras = {}
        local i, k = 0, 1
        local minAuras
        
        while true do
            local name, _, texture, count, debuffType, duration, expiration, 
                  caster = func( unit, k )
            
            if not name then
                break
            end
            
            if (allowList and allowList[name]) or
			   (filterList and not filterList[name])
			then
                i = i + 1
                auras[i] = { texture, count, debuffType, duration, expiration, 
                             caster, k, name }
            end
            
            k = k + 1
        end
        
        table_sort( auras, self.sortFunc )

        minAuras = min( #auras, #frames )
        
        auras[ minAuras + 1 ] = nil
        
		return auras
    end
    
    local init = function( self, filterList, allowList )

        self.init       = nil	-- prevent init from being called twice

		self.allowList  = allowList
        self.filterList = filterList

        self.fill       = fill
        self.getAuras   = getAuras

        self.height     = self.aura1:GetHeight()
        self.spacing    = SETTINGS[ self:GetParent().string ].spacing
        self.unit       = self:GetParent().unit
        
        if self.func == UnitBuff and self.unit == "player" then
            local OnClick_CancelUnitBuff = function( self, button )
                if button == "RightButton" then
                    CancelUnitBuff( "player", self.auraID )
                end
            end
        
            for _, frame in ipairs( self.frames ) do
                frame:SetScript( "OnClick", OnClick_CancelUnitBuff )
            end
        end
    end
    
    local loadCommonElements = function( self )
    
        self.init = init
	
        local bgOffset = SETTINGS[self.string1].bgOffset
        local spacing  = SETTINGS[self.string1].spacing
        local objectType
        
        if self.inheriting == "AssiduityLargeBuffButtonTemplate" then
            objectType = "Button"
        else
            objectType = "Frame"
        end
        
        self.aura1 = CreateFrame( objectType, nil, self, self.inheriting )
        self.aura1:SetPoint( "TOPLEFT", self, "TOPLEFT" )
        
        for i = 2, 15 do
            local auraIndex = "aura"..i
            
            self[auraIndex] = CreateFrame( objectType, nil, self, 
                                           self.inheriting )
            self[auraIndex]:SetPoint( "TOPLEFT", self[ "aura" .. i-1 ],
                                      "TOPRIGHT", spacing, 0 )
        end
    
        self.bgT:SetTexture( unpack( SETTINGS[ self.string2 ].bgColor ))
        self.bgT:ClearAllPoints()
        self.bgT:SetPoint( "TOPLEFT", self, "TOPLEFT", -bgOffset, bgOffset )
        self.bgT:SetPoint( "BOTTOMRIGHT", self, "BOTTOMRIGHT", 
                           bgOffset, -bgOffset )
              
        self.frames = { self:GetChildren() }
        self.func   = SETTINGS[self.string2].func
        
        self.sortFunc = function( a, b )
        
            if not a then     
                return false
            elseif not b then 
                return true
            end

            if a[5] == 0 then
                if b[5] == 0 then
                    return a[7] > b[7]
                else
                    return true
                end
            else
                if b[5] == 0 then
                    return false
                else
                    return a[5] > b[5]
                end
            end
        end
    end
    
    AssiduitySmallBuffsFrameTemplate_OnLoad = function( self )
    
        self.inheriting = "AssiduitySmallBuffFrameTemplate"
        self.string1    = AURAS_FRAME_SMALL
        self.string2    = BUFFS_FRAME
		
        loadCommonElements( self )
    end
    
    AssiduityLargeBuffsFrameTemplate_OnLoad = function( self )
    
        self.inheriting = "AssiduityLargeBuffButtonTemplate"
        self.string1    = AURAS_FRAME_LARGE
        self.string2    = BUFFS_FRAME
		
        loadCommonElements( self )
    end
    
    AssiduitySmallDebuffsFrameTemplate_OnLoad = function( self )
    
        self.inheriting = "AssiduitymSmallDebuffFrameTemplate"
        self.string1    = AURAS_FRAME_SMALL
        self.string2    = DEBUFFS_FRAME
        
        loadCommonElements( self )
    end
    
    AssiduityLargeDebuffsFrameTemplate_OnLoad = function( self )
    
        self.inheriting = "AssiduityLargeDebuffFrameTemplate"
        self.string1    = AURAS_FRAME_LARGE
        self.string2    = DEBUFFS_FRAME
        
        loadCommonElements( self )
    end
end

do  --- Cast StatusBar
    local init = function( self )
    
        self.init = nil
        
        CastingBarFrame_OnLoad( self, self:GetParent().unit, false )
        _G[ self:GetName() .. "Icon" ]:Show();
        
        self:SetScript( "OnEvent", function( self, event, ... )
            CastingBarFrame_OnEvent(self, event, ...)
        end )
        
        self:SetScript( "OnUpdate", function( self, elapsed )
            CastingBarFrame_OnUpdate(self, elapsed)
        end )
        
        self:SetScript( "OnShow", function( self )
            CastingBarFrame_OnShow( self )
        end )
    end

    AssiduityCastStatusBarTemplate_OnLoad = function( self )
    
        self.init = init
    end
end

do  --- Extra Frame
    local GetComboPoints = GetComboPoints
    
    local OnEvent = function( self, _, unit )
    
        --- adjust
        if unit == "player" then
            self:refresh()
        end
    end
    
    local refresh = function( self )
    
        local numComboPoints = GetComboPoints( "player", self.unit )
        
        for i = 1, numComboPoints do
            self.regions[i]:Show()
        end
        
        for i = numComboPoints + 1, 5 do
            self.regions[i]:Hide()
        end
    end
    
    local register = function( self )
    
        self.nameFS:SetText( nil )
    
        self:refresh()
        self:RegisterEvent( "UNIT_COMBO_POINTS" )
    end
    
    local unregister = function( self )
    
        self:UnregisterEvent( "UNIT_COMBO_POINTS" )
    end
    
    local updateName = function( self )
    
        self.nameFS:SetText( self:GetParent().name )
    end
    
    local init = function( self )
    
        self.init       = nil
        self.refresh    = refresh
        self.regions    = { self:GetRegions() }
        self.register   = register
        self.unit       = self:GetParent().unit
        self.unregister = unregister
        self.updateName = updateName
        
        self:SetScript( "OnEvent", OnEvent )
    end

    AssiduityExtraFrameTemplate_OnLoad = function( self )
    
        self.init = init
    end
end

do  --- Health StatusBar
    local CLASS_TO_HEALTHCOLORS = {

        ["DEATHKNIGHT"]	= { 0.77, 0.12, 0.23 },
        ["DRUID"]		= { 1,    0.49, 0.04 },
        ["HUNTER"]		= { 0.67, 0.83, 0.45 },
        ["MAGE"]		= { 0.41, 0.8,  0.94 },
        ["PALADIN"]		= { 0.96, 0.55, 0.73 },
        ["PRIEST"]		= { 1,    1,    1    },
        ["ROGUE"]		= { 1,    0.96, 0.41 },
        ["SHAMAN"]	 	= { 0,    0.44, 0.87 },
        ["WARLOCK"]		= { 0.58, 0.51, 0.79 },
        ["WARRIOR"]		= { 0.78, 0.61, 0.43 }
    }

    local OnEvent = function( self, event, unit )
    
        if unit == self.unit then
            if event == "UNIT_MAXHEALTH" then
                self:refresh()
            else 
                self.SB:SetValue( UnitHealth( unit ))
            end
        end
    end
    
    local refresh = function( self )
    
        self.SB:SetMinMaxValues( 0, UnitHealthMax( self.unit ))
        self.SB:SetValue( UnitHealth( self.unit ))
    end
    
    local register = function( self )
    
        local class = self:GetParent().class
        if class and CLASS_TO_HEALTHCOLORS[class] then
            self.SB:SetStatusBarColor( unpack( CLASS_TO_HEALTHCOLORS[class] ))
        else
            self.SB:SetStatusBarColor( UnitSelectionColor( self.unit ))
        end
        
        self:refresh() 
        
        self:RegisterEvent( "UNIT_HEALTH" )
        self:RegisterEvent( "UNIT_MAXHEALTH" )
    end
    
    local unregister = function( self )
    
        self:UnregisterAllEvents()
    end
    
    local OnMinMaxChanged = function( self, _, maxValue )
    
        self.textFS:SetText( math_ceil( maxValue / 1000 ) .. "k" )
    end
    
    local OnValueChanged = function( self, health )
    
        self.textFS:SetText( math_ceil( health                     / 
                                        UnitHealthMax( self.unit ) *
                                        100 )
                             .. "%" )
    end
    
    local init = function( self )
    
        self.init       = nil
        self.refresh    = refresh
        self.register   = register
        self.unregister = unregister
        self.unit       = self:GetParent().unit
        
        self.SB.unit = self.unit
        
        if self.unit == "player" then
            self.SB:SetScript( "OnValueChanged", OnValueChanged )
        else
            self.SB:SetScript( "OnMinMaxChanged", OnMinMaxChanged )
        end
        
        self:register()
        self:SetScript( "OnEvent", OnEvent )
    end

    local loadCommonElements = function( self )
    
        self.SB.textFS:SetFontObject( SETTINGS[self.string].textFont )
    
        self.init = init
    end
    
    AssiduitySmallHealthStatusBarTemplate_OnLoad = function( self )
    
        self.string = "HEALTH_SB_SMALL"
        loadCommonElements( self )
    end
    
    AssiduityLargeHealthStatusBarTemplate_OnLoad = function( self )
    
        self.string = "HEALTH_SB_LARGE"
        loadCommonElements( self )
    end
end

do  --- Icon Frame
    local CLASS_TO_ICON = {

        ["Army of the Dead Ghoul"] = "Interface\\Icons\\Spell_DeathKnight_ArmyOfTheDead",
        ["Ebon Gargoyle"]          = "Interface\\Icons\\Ability_Hunter_Pet_Bat",
        ["Risen Ghoul"]            = "Interface\\Icons\\Spell_Shadow_AnimateDead",
        ["Rune Weapon"]            = "Interface\\Icons\\INV_Sword_07",
        ["Shadowfiend"]            = "Interface\\Icons\\Spell_Shadow_Shadowfiend",
        ["Spirit Wolf"]            = "Interface\\Icons\\Spell_Shaman_FeralSpirit",
        ["Treant"]                 = "Interface\\Icons\\Ability_Druid_ForceofNature",
        ["Water Elemental"]        = "Interface\\Icons\\Spell_Frost_SummonWaterElemental_2"
    }

    local FAMILY_TO_ICON = {

        ["Felguard"]   = "Interface\\Icons\\Spell_Shadow_SummonFelGuard",
        ["Felhunter"]  = "Interface\\Icons\\Spell_Shadow_SummonFelHunter",
        ["Ghoul"]      = "Interface\\Icons\\Spell_Shadow_AnimateDead",
        ["Imp"]        = "Interface\\Icons\\Spell_Shadow_SummonImp",
        ["Succubus"]   = "Interface\\Icons\\Spell_Shadow_SummonSuccubus",
        ["Voidwalker"] = "Interface\\Icons\\Spell_Shadow_SummonVoidWalker"
    }

    local COLORS = {
    
        ["BLACK"]  = {   0,   0,   0, 255 },
        ["BLUE"]   = {   0,   0, 200, 255 },
        ["GREEN"]  = {   0, 200,   0, 255 },
        ["PURPLE"] = { 200,   0, 255, 255 },
        ["RED"]    = { 200,   0,   0, 255 },
        ["WHITE"]  = { 255, 255, 255, 255 },
    }
    
    local UNIT_TO_SETUP = {
    --- unit          = { txt, bgColor,       textColor },
        ["arena1"]    = { "1", COLORS.RED,    COLORS.BLACK },
        ["arena2"]    = { "2", COLORS.RED,    COLORS.BLACK },
        ["arena3"]    = { "3", COLORS.RED,    COLORS.BLACK },
        ["arena4"]    = { "4", COLORS.RED,    COLORS.BLACK },
        ["arena5"]    = { "5", COLORS.RED,    COLORS.BLACK },
        
        ["arenapet1"] = { "1", COLORS.PURPLE, COLORS.WHITE },
        ["arenapet2"] = { "2", COLORS.PURPLE, COLORS.WHITE },
        ["arenapet3"] = { "3", COLORS.PURPLE, COLORS.WHITE },
        ["arenapet4"] = { "4", COLORS.PURPLE, COLORS.WHITE },
        ["arenapet5"] = { "5", COLORS.PURPLE, COLORS.WHITE },
        
        ["party1"]    = { "1", COLORS.GREEN,  COLORS.BLACK },
        ["party2"]    = { "2", COLORS.GREEN,  COLORS.BLACK },
        ["party3"]    = { "3", COLORS.GREEN,  COLORS.BLACK },
        ["party4"]    = { "4", COLORS.GREEN,  COLORS.BLACK },
        
        ["partypet1"] = { "1", COLORS.BLUE,   COLORS.WHITE },
        ["partypet2"] = { "2", COLORS.BLUE,   COLORS.WHITE },
        ["partypet3"] = { "3", COLORS.BLUE,   COLORS.WHITE },
        ["partypet4"] = { "4", COLORS.BLUE,   COLORS.WHITE },
        
        ["player"]    = { "P", COLORS.WHITE,  COLORS.BLACK },
        ["target"]    = { "T", COLORS.WHITE,  COLORS.BLACK },
        ["focus"]     = { "F", COLORS.WHITE,  COLORS.BLACK },
    }

    local VALID_UNITS = {

        "arena1",
        "arena2",
        "arena3",
        "arena4",
        "arena5",
        "arenapet1",
        "arenapet2",
        "arenapet3",
        "arenapet4",
        "arenapet5",

        "party1",
        "party2",
        "party3",
        "party4",
        "partypet1",
        "partypet2",
        "partypet3",
        "partypet4",

        "player"
    }

    local CLASS_ICON_TCOORDS = CLASS_ICON_TCOORDS
   
    local setIcon = function( self, icon, coord )
    
        self.textFS:Hide()
    
        self.iconT:SetTexture( icon )
        
        if coord then
            self.iconT:SetTexCoord( unpack( coord ))
        else
            self.iconT:SetTexCoord( 0, 1, 0, 1 )
        end
    end
    
    local setSelf = function( self )
    
        self:setUnit( "S", COLORS.BLACK, COLORS.WHITE )
    end
    
    local setUnit = function( self, text, bgColorTable, fontColorTable )
    
        self.iconT:SetTexture( unpack( bgColorTable ))
        self.iconT:SetTexCoord( 0, 1, 0, 1 )
        self.textFS:SetText( text )
        self.textFS:Show()
    end
    
    local update = function( self )

        local class, unit = self:GetParent().class, self.unit
        
        --- Handle displaying unit artwork for valid units
        if self.searchForUnit then
            for i in ipairs( VALID_UNITS ) do
                if UnitIsUnit( unit, VALID_UNITS[i] ) then
                    unit = VALID_UNITS[i]
                    break
                end
            end
        end
        if UNIT_TO_SETUP[unit] then
            self:setUnit( unpack( UNIT_TO_SETUP[unit] ))
            return
        end
        
        if UnitIsPlayer( unit ) then
            self:setIcon( "Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES", CLASS_ICON_TCOORDS[class] )
            
        elseif FAMILY_TO_ICON[ UnitCreatureFamily( unit )] then
            self:setIcon( FAMILY_TO_ICON[ UnitCreatureFamily( unit )])
            
        elseif CLASS_TO_ICON[class] then
            self:setIcon( CLASS_TO_ICON[class] )
            
        elseif UnitHealthMax( unit ) == 4400 then
            self:setIcon( "Interface\\Icons\\Spell_Magic_LesserInvisibilty")
        else
            SetPortraitTexture( self.iconT, unit )
            self.iconT:SetTexCoord( 0, 1, 0, 1 )
        end 
    end
    
    local init = function( self )
    
        local height = self:GetParent():GetHeight()
        local unit   = self:GetParent().unit
        
        self.init    = nil 
        self.unit    = unit
        self.update  = update
        self.setIcon = setIcon
        self.setSelf = setSelf
        self.setUnit = setUnit
        
        self:SetSize( height, height )
        
        for i in ipairs( VALID_UNITS ) do
            if unit == VALID_UNITS[i] then
                return
            end
        end
        
        self.searchForUnit = 1
    end
    
    local loadCommonElements = function( self )
    
        self.textFS:SetFontObject( SETTINGS[self.string].textFont )
    
        self.init = init
    end
    
    AssiduitySmallIconFrameTemplate_OnLoad = function( self )
    
        self.string = "ICON_FRAME_SMALL"
        loadCommonElements( self )
    end
    
    AssiduityLargeIconFrameTemplate_OnLoad = function( self )
    
        self.string = "ICON_FRAME_LARGE"
        loadCommonElements( self )
    end
end

do  --- Overlay StatusBar
    local OnUpdate = function( self )
        
        local currentHealth = UnitHealth( self.unit ) 
        
        if currentHealth ~= self.lastHealth then
            self.lastHealth = currentHealth
            self.maxHealth  = UnitHealthMax( self.unit )
            
            self:refresh()
        end
    end
    
    local OnValueChanged = function( self, value )
    
        self.percentageFS:SetText( math_ceil( value / self.maxHealth * 100 )
                                   .. "%" )
    end
    
    local refresh = function( self )
    
        if self.lastHealth == 0 then
            self:SetStatusBarColor( 1, 1, 1 )
        else
            self:SetStatusBarColor( 0, 0, 0 )
        end
            
        self:SetMinMaxValues( 0, self.maxHealth )
        self:SetValue( self.lastHealth )
    end
   
    local register = function( self )
    
        self.maxHealth  = UnitHealthMax( self.unit )
        self.lastHealth = UnitHealth( self.unit )
        
        self:refresh()
        
        self:SetScript( "OnUpdate", OnUpdate )
    end
   
    local unregister = function( self )
    
        self:SetScript( "OnUpdate", nil )
    end
   
    local init = function( self )
     
        self.init       = nil  
        self.refresh    = refresh
        self.register   = register
        self.unit       = self:GetParent().unit
        self.unregister = unregister
        
        self:SetScript( "OnValueChanged", OnValueChanged )
    end
   
    AssiduityOverlayStatusBarTemplate_OnLoad = function( self )
    
        self.init = init
    end
end

do  --- Power StatusBar
    local CLASS_TO_POWER = {

        ["DEATHKNIGHT"] = "RUNIC_POWER",
        ["HUNTER"]      = "MANA",
        ["MAGE"]        = "MANA",
        ["PALADIN"]     = "MANA",
        ["PRIEST"]      = "MANA",
        ["ROGUE"]       = "ENERGY",
        ["SHAMAN"]      = "MANA",
        ["WARLOCK"]     = "MANA",
        ["WARRIOR"]     = "RAGE"
    }

    local CLASS_TO_POWERCOLORS = {

        ["DEATHKNIGHT"] = { 0,    0.6, 1    },
        ["DRUID"]       = { 0,    0,   0.85 },
        ["HUNTER"]      = { 0,    0,   0.85 },
        ["MAGE"]        = { 0,    0,   0.85 },
        ["PALADIN"]     = { 0,    0,   0.85 },
        ["PRIEST"]      = { 0,    0,   0.85 },
        ["ROGUE"]       = { 0.9,  0.9, 0    },
        ["SHAMAN"]      = { 0,    0,   0.85 },
        ["WARLOCK"]     = { 0,    0,   0.85 },
        ["WARRIOR"]     = { 0.85, 0,   0    }
    }

    local POWERTYPE_TO_COLORS = {

        ["ENERGY"]      = { 0.9,  0.9, 0    },
        ["MANA"]        = { 0,    0,   0.85 },
        ["RAGE"]        = { 0.85, 0,   0    },
        ["RUNIC_POWER"] = { 0,    0.6, 1    }
    }
    
    
    local OnMinMaxChanged = function( self, _, maxValue )
    
        self.textFS:SetText( math_ceil( maxValue / 1000 ) .. "k" )
    end
    
    local OnValueChanged = function( self, power )
    
        self.textFS:SetText( power )
    end
    
    local DRUIDPower_OnEvent = function( self, event, unit )
        
        if unit == self.unit then
            if event == "UNIT_DISPLAYPOWER" then
                self:updateDruid()
            
            elseif event == self.event then
                self.SB:SetValue( UnitPower( unit ))
            else
                self:refresh()
            end
        end
    end
    
    local Power_OnEvent = function( self, event, unit )
    
        if unit == self.unit then
            if event == self.event then
                self.SB:SetValue( UnitPower( unit ))
            else
                self:refresh()
            end
        end
    end
    
    local OnUpdate = function( self )
    
        self.SB:SetValue( UnitPower( self.unit ))
    end
   
    local refresh = function( self )
    
        self.SB:SetMinMaxValues( 0, UnitPowerMax( self.unit ))
        self.SB:SetValue( UnitPower( self.unit ))
    end
    
    local register = function( self )
    
        local class = self:GetParent().class
        
        if not CLASS_TO_POWERCOLORS[class] then
            return
        end
		
        local power = CLASS_TO_POWER[class]	
        self.SB:SetStatusBarColor( unpack( CLASS_TO_POWERCOLORS[class] ))
        
        if class == "DRUID" then
            self:updateDruid()
            self:SetScript( "OnEvent", DRUIDPower_OnEvent )
        else
            self.event = "UNIT_"..power
            
            self:RegisterEvent( "UNIT_MAX"..power )
            self:RegisterEvent( self.event )
            self:SetScript( "OnEvent", Power_OnEvent )
        end
			
        if power == "MANA" then
            self:SetScript( "OnUpdate", nil )
            
            self.SB:SetScript( "OnValueChanged", nil )
            self.SB:SetScript( "OnMinMaxChanged", OnMinMaxChanged )
            
        else
            self.SB:SetScript( "OnValueChanged", OnValueChanged )
            self.SB:SetScript( "OnMinMaxChanged", nil )
            
            self:SetScript( "OnUpdate", OnUpdate )
        end
            
        self:refresh()
    end
    
    local unregister = function( self )
    
        self:UnregisterAllEvents()
    end
    
    local updateDruid = function( self )
   
        local _, powerType = UnitPowerType( self.unit )
        
        if not powerType or powerType == "" then
            powerType = "MANA"
        end
        
        self.event = "UNIT_"..powerType
        self.SB:SetStatusBarColor( unpack( POWERTYPE_TO_COLORS[powerType]  ))
        
        self:refresh()
        
        self:UnregisterAllEvents()
        self:RegisterEvent( self.event )
        self:RegisterEvent( "UNIT_MAX"..powerType )
        self:RegisterEvent( "UNIT_DISPLAYPOWER" )
    end
    
        
    local init = function( self )
        
        self.init        = nil
        self.refresh     = refresh
        self.register    = register
        self.unregister  = unregister
        self.updateDruid = updateDruid
        self.unit        = self:GetParent().unit
        
        self.SB.unit = self.unit
    end
    
    local loadCommonElements = function( self )
    
        self.SB.textFS:SetFontObject( SETTINGS[self.string].textFont )
    
        self.init = init
    end

    AssiduitySmallPowerStatusBarTemplate_OnLoad = function( self )
    
        self.string = "POWER_SB_SMALL"
        loadCommonElements( self )
    end
    
    AssiduityLargePowerStatusBarTemplate_OnLoad = function( self )
    
        self.string = "POWER_SB_LARGE"
        loadCommonElements( self )
    end
end

do  --- Spec Frame
    local SPEC_TO_ICON = {

        -- DEATHKNIGHT
        ["Blood"]  = "Interface\\Icons\\Spell_Deathknight_BloodPresence",
        ["Frost"]  = "Interface\\Icons\\Spell_Deathknight_FrostPresence",
        ["Unholy"] = "Interface\\Icons\\Spell_Deathknight_UnholyPresence",

        -- DRUID
        ["Balance"]     = "Interface\\Icons\\Spell_Nature_StarFall",
        ["Feral"]       = "Interface\\Icons\\Ability_Racial_BearForm",
        ["Restoration"] = "Interface\\Icons\\Spell_Nature_HealingTouch",

        -- HUNTER
        ["Beast Mastery"] = "Interface\\Icons\\Ability_Hunter_BeastTaming",
        ["Marksmanship"]  = "Interface\\Icons\\Ability_Marksmanship",
        ["Survival"]      = "Interface\\Icons\\Ability_Hunter_SwiftStrike",

        -- MAGE
        ["Arcane"] = "Interface\\Icons\\Spell_Holy_MagicalSentry",
        ["Fire"]   = "Interface\\Icons\\Spell_Fire_FireBolt02",
        ["Frost"]  = "Interface\\Icons\\Spell_Frost_FrostBolt02",

        -- PALADIN
        ["Holy"]        = "Interface\\Icons\\Spell_Holy_HolyBolt",
        ["Protection"]  = "Interface\\Icons\\Spell_Holy_DevotionAura",
        ["Retribution"] = "Interface\\Icons\\Spell_Holy_AuraOfLight",

        -- PRIEST
        ["Discipline"] = "Interface\\Icons\\Spell_Holy_WordFortitude",
        -- ["Holy"]             -- using hpala icon
        ["Shadow"]     = "Interface\\Icons\\Spell_Shadow_ShadowWordPain",

        -- ROGUE
        ["Assassination"] = "Interface\\Icons\\Ability_Rogue_Eviscerate",
        ["Combat"]        = "Interface\\Icons\\Ability_BackStab",
        ["Subtlety"]      = "Interface\\Icons\\Ability_Stealth",

        -- SHAMAN
        ["Elemental"]   = "Interface\\Icons\\Spell_Nature_Lightning",
        ["Enhancement"] = "Interface\\Icons\\Spell_Nature_LightningShield",
        -- ["Restoration"] = "",    -- using rdruid icon

        -- WARLOCK
        ["Affliction"]  = "Interface\\Icons\\Spell_Shadow_DeathCoil",
        ["Demonology"]  = "Interface\\Icons\\Spell_Shadow_Metamorphosis",
        ["Destruction"] = "Interface\\Icons\\Spell_Shadow_RainOfFire",

        -- WARRIOR
        ["Arms"]       = "Interface\\Icons\\Ability_Rogue_Eviscerate",
        ["Fury"]       = "Interface\\Icons\\Ability_Warrior_InnerRage",
        ["Protection"] = "Interface\\Icons\\Ability_Warrior_DefensiveStance"
    }

    local update = function( self )
    
        self.iconT:SetTexture( SPEC_TO_ICON[ self:GetParent().spec ])
        self:Show()
    end
    
    local init = function( self )
    
        local height = self:GetParent():GetHeight()
        
        self:SetSize( height, height )
        
        self.init = nil
        self.update = update
    end
    
    AssiduitySpecFrameTemplate_OnLoad = function( self )
        
        self.init = init
    end
end

do  --- Target of Unit Frame
    local UNIT_TARGET = function( self, _, unit )
    
        if unit == self.parentUnit then
            self:update()
        end
    end
    
    local register = function( self )
    
        self:update()
        self:RegisterEvent( "UNIT_TARGET" )
    end
    
    local update = function( self )
        
        _, self.class = UnitClass( self.unit )
        if UnitIsUnit( "player", self.parentUnit ) then
            self:SetAlpha( 0 )
        else
            self:SetAlpha( 1 )  
            
            if UnitIsUnit( self.parentUnit, self.unit ) then
                self.iconF:setSelf()
            else
                self.iconF:update()
            end
        end
    end
    
    local unregister = function( self )
    
        self:UnregisterEvent( "UNIT_TARGET" )
    end
        
    local init = function( self )

        local height = self:GetParent():GetHeight()
    
        self.init       = nil
        self.parentUnit = self:GetParent().unit
        self.register   = register
        self.unit       = self.parentUnit.."target"
        self.update     = update
        self.unregister = unregister
        
        self:SetAttribute( "unit", self.unit )
        self:SetSize( height, height )
        
        self.iconF:init()
        
        SecureUnitButton_OnLoad( self, self.unit )
        RegisterUnitWatch( self )
    end
    
    AssiduityTargetOfUnitButtonTemplate_OnLoad = function( self )

        self.init = init

        self:SetScript( "OnEvent", UNIT_TARGET )
    end
end 

do  --- Unit Pet Frame

    --[[ 
        first two are monitored auras,
        the third one is a spell linked to middle mouse click on frame
    ]]
    
    local OWNER_TO_PET_UNIT = {

        ["arena1"] = "arenapet1",
        ["arena2"] = "arenapet2",
        ["arena3"] = "arenapet3",
        ["arena4"] = "arenapet4",
        ["arena5"] = "arenapet5",
    
        ["party1"] = "partypet1",
        ["party2"] = "partypet2",
        ["party3"] = "partypet3",
        ["party4"] = "partypet4"
    }
    
    local UNIT_TO_DIRECTION = {
    
        ["arena1"] = "LEFT",
        ["arena2"] = "LEFT",
        ["arena3"] = "LEFT",
        ["arena4"] = "LEFT",
        ["arena5"] = "LEFT",
        
        ["party1"] = "RIGHT",
        ["party2"] = "RIGHT",
        ["party3"] = "RIGHT",
        ["party4"] = "RIGHT"
    }
    
    local UNIT_TO_REACTION = {
    
        ["arena1"] = "HOSTILE",
        ["arena2"] = "HOSTILE",
        ["arena3"] = "HOSTILE",
        ["arena4"] = "HOSTILE",
        ["arena5"] = "HOSTILE",
        
        ["party1"] = "FRIENDLY",
        ["party2"] = "FRIENDLY",
        ["party3"] = "FRIENDLY",
        ["party4"] = "FRIENDLY"
    }
    
    local FilteredNamePlates = {
	
		--- Non totems
		["Viper"]           = true,
		["Venomous Snake"]  = true,
		["Spirit Wolf"]     = true,
		["Treant"]          = true,
		["Water Elemental"] = true,
	
		["Cleansing Totem"]              = true,
		["Earth Elemental Totem"]        = true,
		["Earthbind Totem"]              = false,
		["Fire Elemental Totem"]         = true,
		["Fire Resistance Totem"]        = true,
		["Fire Resistance Totem II"]     = true,
		["Fire Resistance Totem III"]    = true,
		["Fire Resistance Totem IV"]     = true,
		["Fire Resistance Totem V"]      = true,
		["Fire Resistance Totem VI"]     = true,
		["Flametongue Totem"]            = true,
		["Flametongue Totem II"]         = true,
		["Flametongue Totem III"]        = true,
		["Flametongue Totem IV"]         = true,
		["Flametongue Totem V"]          = true,
		["Flametongue Totem VI"]         = true,
		["Flametongue Totem VII"]        = true,
		["Flametongue Totem VIII"]       = true,
		["Frost Resistance Totem"]       = true,
		["Frost Resistance Totem II"]    = true,
		["Frost Resistance Totem III"]   = true,
		["Frost Resistance Totem IV"]    = true,
		["Frost Resistance Totem V"]     = true,
		["Frost Resistance Totem VI"]    = true,
		["Grounding Totem"]              = false,
		["Healing Stream Totem"]         = true,
		["Healing Stream Totem II"]      = true,
		["Healing Stream Totem III"]     = true,
		["Healing Stream Totem IV"]      = true,
		["Healing Stream Totem V"]       = true,
		["Healing Stream Totem VI"]      = true,
		["Healing Stream Totem VII"]     = true,
		["Healing Stream Totem VIII"]    = true,
		["Healing Stream Totem IX"]      = true,
		["Magma Totem"]                  = true,
		["Magma Totem II"]               = true,
		["Magma Totem III"]              = true,
		["Magma Totem IV"]               = true,
		["Magma Totem V"]                = true,
		["Magma Totem VI"]               = true,
		["Magma Totem VII"]              = true,
		["Mana Spring Totem"]            = true,
		["Mana Spring Totem II"]         = true,
		["Mana Spring Totem III"]        = true,
		["Mana Spring Totem IV"]         = true,
		["Mana Spring Totem V"]          = true,
		["Mana Spring Totem VI"]         = true,
		["Mana Spring Totem VII"]        = true,
		["Mana Spring Totem VIII"]       = true,
		["Mana Tide Totem"]              = false,
		["Nature Resistance Totem"]      = true,
		["Nature Resistance Totem II"]   = true,
		["Nature Resistance Totem III"]  = true,
		["Nature Resistance Totem IV"]   = true,
		["Nature Resistance Totem V"]    = true,
		["Nature Resistance Totem VI"]   = true,
		["Searing Totem"]                = true,
		["Searing Totem II"]             = true,
		["Searing Totem III"]            = true,
		["Searing Totem IV"]             = true,
		["Searing Totem V"]              = true,
		["Searing Totem VI"]             = true,
		["Searing Totem VII"]            = true,
		["Searing Totem VIII"]           = true,
		["Searing Totem IX"]             = true,
		["Searing Totem X"]              = true,
		["Sentry Totem"]                 = true,
		["Stoneclaw Totem"]              = true,
		["Stoneclaw Totem II"]           = true,
		["Stoneclaw Totem III"]          = true,
		["Stoneclaw Totem IV"]           = true,
		["Stoneclaw Totem V"]            = true,
		["Stoneclaw Totem VI"]           = true,
		["Stoneclaw Totem VII"]          = true,
		["Stoneclaw Totem VIII"]         = true,
		["Stoneclaw Totem IX"]           = true,
		["Stoneclaw Totem X"]            = true,
		["Stoneskin Totem"]              = true,
		["Stoneskin Totem II"]           = true,
		["Stoneskin Totem III"]          = true,
		["Stoneskin Totem IV"]           = true,
		["Stoneskin Totem V"]            = true,
		["Stoneskin Totem VI"]           = true,
		["Stoneskin Totem VII"]          = true,
		["Stoneskin Totem VIII"]         = true,
		["Stoneskin Totem IX"]           = true,
		["Stoneskin Totem X"]            = true,
		["Strength of Earth Totem"]      = true,
		["Strength of Earth Totem II"]   = true,
		["Strength of Earth Totem III"]  = true,
		["Strength of Earth Totem IV"]   = true,
		["Strength of Earth Totem V"]    = true,
		["Strength of Earth Totem VI"]   = true,
		["Strength of Earth Totem VII"]  = true,
		["Strength of Earth Totem VIII"] = true,
		["Totem of Wrath I"]             = true,
		["Totem of Wrath II"]            = true,
		["Totem of Wrath III"]           = true,
		["Totem of Wrath IV"]            = true,
		["Tremor Totem"]                 = true,
		["Windfury Totem"]               = true,
		["Wrath of Air Totem"]           = true
	}

    local _, PLAYER_CLASS = UnitClass( "player" )
    
    CLASS_TO_BUFFS = {
		"Rejuvenation",
		"Abolish Poison",
		"Remove Curse"
	}
    CLASS_TO_DEBUFFS = {
        "Moonfire",
        "Insect Swarm",
        "Wrath(Rank 1)"     --- adjust
    }
    CLASS_TO_BUFF_ICONS   = {}
    CLASS_TO_DEBUFF_ICONS = {
        "Interface\\Icons\\Spell_Nature_StarFall",
        "Interface\\Icons\\Spell_Nature_InsectSwarm",
    }
    
    local OnUpdate = function( self )

        local name = UnitName( self.unit ) 
        if name and name ~= "Unknown" then
            FilteredNamePlates[name] = true
            self:SetScript( "OnUpdate", nil )
        end
    end

    local OnHide = function( self )
    
        self.overlaySB:unregister()
        
        self:UnregisterEvent( "UNIT_AURA" )
    end
    
    local OnShow = function( self )
    
        if UnitLClass( parentUnit ) == "DEATHKNIGHT" then
            local name = UnitName( self.unit ) 
            if name and name ~= "Unknown" then
                FilteredNamePlates[name] = true
            else
                self:SetScript( "OnUpdate", OnUpdate )
            end
        end
    
        self.overlaySB:register()
        
        self:RegisterEvent( "UNIT_AURA" )
    end
    
    local OnEvent = function( self, _, unit )
    
        if unit == self.unit then
            for i = 1, 2 do
                  --- 1 2 3 4 5
                local _,_,_,_,_,duration,expiration = UnitAura( unit, 
                                                                self.spells[i] )
                local aura = self[ "aura" .. i ]
                if duration then
                    aura:SetCooldown( expiration - duration, duration )
                    aura:Show()
                else
                    aura:Hide()
                end
            end
        end
    end
    
    local init = function( self )
    
        local parentUnit = self:GetParent().unit
        
        local direction         = UNIT_TO_DIRECTION[parentUnit]
        local height            = self:GetParent():GetHeight()
        local offset            = SETTINGS.UNIT_FRAME_SMALL.offset
        local oppositeDirection 
        local unit              = OWNER_TO_PET_UNIT[parentUnit]
        
        local halfHeight = height / 2
        
        self.init       = nil
        self.parentUnit = parentUnit
        self.unit       = unit
        
        if UNIT_TO_REACTION[parentUnit] == "FRIENDLY" then
            self.spells = CLASS_TO_BUFFS
            self.textures = CLASS_TO_BUFF_ICONS
        else
            self.spells = CLASS_TO_DEBUFFS
            self.textures = CLASS_TO_DEBUFF_ICONS
        end
        
        for i = 1, 2 do
            local aura = self[ "aura" .. i ]
            
            aura.iconT:SetTexture( self.textures[i] )
            aura:SetSize( halfHeight, halfHeight )
        end
        
        self.bgT:SetPoint( "TOPLEFT",     self, "TOPLEFT",    -offset,  offset )
        self.bgT:SetPoint( "BOTTOMRIGHT", self, "BOTTOMRIGHT", offset, -offset )
        
        if direction == "LEFT" then 
            offset = -offset
            oppositeDirection = "RIGHT"
        else 
            oppositeDirection = "LEFT"
        end
        
        self.aura1:SetPoint( "TOP"..oppositeDirection, self, "TOP"..direction, 
                             offset, 0 )
        
        self:RegisterEvent( "UNIT_AURA" )
        self:RegisterForClicks( "AnyUp" )
        
        self:SetAttribute( "unit", unit )
        self:SetAttribute( "type", "macro" )
        self:SetAttribute( "type1", "target" )
        self:SetAttribute( "type3", "spell" )
        self:SetAttribute( "spell3", self.spells[3] )
        self:SetAttribute( "type2", "focus" )
        
        self:SetAttribute( "type5", "spell" )
        self:SetAttribute( "spell5", self.spells[1] )
        self:SetAttribute( "type4", "spell" )
        self:SetAttribute( "spell4", self.spells[2] )
            
        self:SetScript( "OnEvent", OnEvent )
        self:SetScript( "OnHide", OnHide )
        self:SetScript( "OnShow", OnShow )
        
        self.iconF:init()
        self.iconF:update()
        self.overlaySB:init()
        
        RegisterUnitWatch( self )
    end

    AssiduityUnitPetFrameTemplate_OnLoad = function( self )
    
        self.init = init
    end
end

do  --- Unit Frame
    UnitFrameInit = function( self, orientation )
        
        self.bgT:SetTexture( unpack( SETTINGS.bgColor ))
        
        local SETTING = SETTINGS[ self.string ]
        
        local bgOffset     = SETTING.bgOffset
        local height       = SETTING.height
        local healthHeight = SETTING.healthHeight
        local spacing      = SETTING.spacing
        local width        = SETTING.width
        
        self:SetSize( width, height )
        
        self.bgT:ClearAllPoints() 
        self.bgT:SetPoint( "TOPLEFT", self, "TOPLEFT", -bgOffset, bgOffset )
        self.bgT:SetPoint( "BOTTOMRIGHT", self, "BOTTOMRIGHT", 
                           bgOffset, -bgOffset )
        self.bgT:SetAlpha( 0.5 )
        
        if orientation == "LEFT" then
            self.castSB:SetPoint( "RIGHT", self, "LEFT",    
                                  SETTING.castOffset, 0 )
        
            self.healthSB:SetPoint( "TOPRIGHT", self, "TOPRIGHT" )
            self.healthSB:SetSize( SETTING.width - spacing - height, healthHeight )
            
            self.iconF:SetPoint( "TOPLEFT", self, "TOPLEFT" )
            
            self.powerSB:SetPoint( "BOTTOMRIGHT", self, "BOTTOMRIGHT" )
            self.powerSB:SetPoint( "TOPLEFT", self.healthSB, "BOTTOMLEFT",
                                   0, -spacing )
            -- self.powerSB:SetSize( SETTING.width - spacing - height, 
                                  -- height - spacing - healthHeight )
            
              
        else
            self.castSB:SetPoint( "LEFT", self, "RIGHT",    
								  SETTING.castOffset, 0)
                                  --SETTING[self.string].castOffset + 20, 0 )
                      
            self.healthSB:SetPoint( "TOPLEFT", self, "TOPLEFT" )
            self.healthSB:SetPoint( "BOTTOMRIGHT", self, "TOPRIGHT",
                                   -( height + spacing ), -healthHeight )
           
            self.iconF:SetPoint( "TOPRIGHT", self, "TOPRIGHT" )
            
            self.powerSB:SetPoint( "BOTTOMLEFT", self, "BOTTOMLEFT" )
            self.powerSB:SetPoint( "TOPRIGHT", self.healthSB, "BOTTOMRIGHT",
                                   0, -spacing )
        end
        
        self.castSB:init()
        self.healthSB:init()
        self.iconF:init()
        self.iconF:update()
        self.powerSB:init()
    end
    
    do  --- Combat
        local UNIT_FLAGS = function( self, _, unit )
            
            if unit == self.unit then
                if UnitAffectingCombat( unit ) then self.combatT:Show()
                else                                self.combatT:Hide()
                end
            end
        end
    
        local register = function( self )
            
            self:RegisterEvent( "UNIT_FLAGS" )
        end
        
        local unregister = function( self )
        
            self:UnregisterEvent( "UNIT_FLAGS" )
        end
        
        local init = function( self )
        
            self.init       = init
            self.register   = register
            self.unit       = self:GetParent().unit
            self.unregister = unregister
            
            self:SetScript( "OnEvent", UNIT_FLAGS )
        end
        
        AssiduityUnitFrameTemplateCombat_OnLoad = function( self )
        
            self.init = init
        end
    end
    
    do  --- Focus
        local PLAYER_FOCUS_CHANGED = function( self )
        
            if UnitIsUnit( "focus", self.unit ) then
                self.focusT:Show()
            else
                self.focusT:Hide()
            end
        end
    
        local register = function( self )
        
            self:RegisterEvent( "PLAYER_FOCUS_CHANGED" )
        end
        
        local unregister = function( self )
        
            self:UnegisterEvent( "PLAYER_FOCUS_CHANGED" )
        end
        
        local init = function( self )
        
            self.init       = nil
            self.register   = register
            self.unregister = unregister
            
            self:SetScript( "OnEvent", PLAYER_FOCUS_CHANGED )
        end
        
        AssiduityUnitFrameTemplateFocus_OnLoad = function( self )
        
            self.init = init
        end
    end

    do  --- Leader
        local PARTY_LEADER_CHANGED = function( self )
        
            if GetPartyLeaderIndex() == self.ID then
                self.leaderT:Show()
            else
                self.leaderT:Hide()
            end
        end
    
        local register = function( self )
        
            self:RegisterEvent( "PARTY_LEADER CHANGED" )
        end
        
        local unregister = function( self )
            
            self:UnregisterEvent( "PARTY_LEADER_CHANGED" )
        end
        
        local init = function( self )
        
            self.ID         = self:GetParent():GetID()
            self.init       = init
            self.register   = register
            self.unregister = unregister
            
            self:SetScript( "OnEvent", PARTY_LEADER_CHANGED )
        end
        
        AssiduityUnitFrameTemplateLeader_OnLoad = function( self )
        
            self.init = init
        end
    end
    
    do  --- Target
        local PLAYER_TARGET_CHANGED = function( self )
        
            if UnitIsUnit( "target", self.unit ) then
                
                if self.targetT then
                    self.targetT:Show()
                else
                    self.leftT:Show()
                    self.rightT:Show()
                end
            else
                if self.targetT then
                    self.targetT:Hide()
                else
                    self.leftT:Show()
                    self.rightT:Show()
                end
            end
        end
    
        local register = function( self )
        
            self:RegisterEvent( "PLAYER_TARGET_CHANGED" )
        end
        
        local unregister = function( self )
        
            self:UnregisterEvent( "PLAYER_TARGET_CHANGED" )
        end
        
        local init = function( self )
        
            self.init       = nil
            self.register   = register
            self.unregister = unregister
            
            self:SetScript( "OnEvent", PLAYER_TARGET_CHANGED )
        end
        
        AssiduityUnitFrameTemplateTarget_OnLoad = function( self )
        
            self.init = init
        end
    end
end




























