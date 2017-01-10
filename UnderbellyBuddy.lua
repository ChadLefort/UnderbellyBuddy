ubb = LibStub('AceAddon-3.0'):NewAddon('UnderbellyBuddy', 'AceConsole-3.0', 'AceEvent-3.0')

local fontName = GameFontHighlightSmallOutline:GetFont()
local inUnderbelly = false
local hasGuardBuff = false
local timeLeft = 0

local bar = {
    container = nil,
    timer = nil,
    test = nil
}

local defaults = {
  profile = {
    enable = true,
    lock = false,
    warning = true,
    size = 1.5
  },
  char = {
      timeLeft = 0
  }
}

local run = {
    warning = false,
    bar = false
}

local barSize = {
    width = 140,
    height = 20,
    font = 8
}

local options = {
    name = 'UnderbellyBuddy',
    handler = ubb,
    type = 'group',
    args = {
        main = {
            order = 1,
            name = 'Main Options',
            type = 'group',
            args = {
                enable = {
                    order = 0,
                    name = 'Enable',
                    desc = 'Enables / disables the addon',
                    type = 'toggle',
                    width = 'full',
                    set = 'SetEnabled',
                    get = function() return ubb.db.profile.enable end
                },
                show = {
                    order = 1,
                    guiHidden = true,
                    name = 'Show Bar',
                    desc = 'Shows the bar if you dismissed it away',
                    type = 'execute',
                    func = function() if run.bar then bar.timer:Show() else ubb:Print('No bar to display') end end
                },
                hide = {
                    order = 2,
                    guiHidden = true,
                    name = 'Hide Bar',
                    desc = 'Hides the bar if you dismissed it away',
                    type = 'execute',
                    func = function() if run.bar then bar.timer:Hide() else ubb:Print('No bar to hide') end end
                },
                lock = {
                    order = 3,
                    name = 'Lock Timer',
                    desc = 'Locks the timer bar in place',
                    width = 'full',
                    type = 'toggle',
                    set = function(info, value) ubb.db.profile.lock = value end,
                    get = function() return ubb.db.profile.lock end
                },
                warnings = {
                    order = 4,
                    name = 'Display Warnings',
                    desc = 'Displays warning messages after a certain amount of time',
                    width = 'full',
                    type = 'toggle',
                    set = function(info, value) ubb.db.profile.warning = value end,
                    get = function() return ubb.db.profile.warning end
                },
                bar = {
                    order = 5,
                    name = 'Test Bar',
                    desc = 'Shows a test bar to move or adjust size',
                    width = 'double',
                    type = 'execute',
                    func = 'ShowTestBar'
                },
                size = {
                    order = 6,
                    name = 'Size',
                    desc = 'Changes the size of the timer bar',
                    width = 'double',
                    type = 'range',
                    min = 1,
                    max = 5,
                    set =  'SetSize',
                    get = function() return ubb.db.profile.size end
                }
            }
        },
        about = {
            order = 2,
            name = 'About',
            type = 'group',
            cmdHidden = true,
            args = {
                about = {
                    order = 1,
                    type = 'description',
                    name = 'Made with love by Pigletoos of Sywall'
                }    
            }
        }
    }
}

function ubb:OnInitialize()
    self.db = LibStub('AceDB-3.0'):New('UnderbellyBuddyDB', defaults)
    
    options.args.profile = LibStub('AceDBOptions-3.0'):GetOptionsTable(self.db)

    LibStub('AceConfig-3.0'):RegisterOptionsTable('UnderbellyBuddy', options, {'ubb', 'UnderbellyBuddy'})
    LibStub('AceConfigDialog-3.0'):AddToBlizOptions('UnderbellyBuddy', 'UnderbellyBuddy', nil, 'main') 
    LibStub('AceConfigDialog-3.0'):AddToBlizOptions('UnderbellyBuddy', 'Profiles', 'UnderbellyBuddy', 'profile')
    LibStub('AceConfigDialog-3.0'):AddToBlizOptions('UnderbellyBuddy', 'About', 'UnderbellyBuddy', 'about')

    self.db.RegisterCallback(self, 'OnProfileChanged', 'RefreshConfig')
    self.db.RegisterCallback(self, 'OnProfileCopied', 'RefreshConfig')
    self.db.RegisterCallback(self, 'OnProfileReset', 'RefreshConfig')

    bar.container = CreateFrame('Frame', 'UnderbellyBuddyTimerBar', UIParent)
    bar.container:SetSize(ubb.db.profile.size * barSize.width, ubb.db.profile.size * barSize.height)
    bar.container:SetMovable(true)
    bar.container:SetUserPlaced(true)
    bar.container:SetPoint('CENTER', 0, 150)
    bar.container:EnableMouse(true)
    bar.container:RegisterForDrag('LeftButton')
    bar.container:SetScript('OnDragStart', function(self) if not ubb.db.profile.lock then self:StartMoving() end end)
    bar.container:SetScript('OnDragStop', function(self) self:StopMovingOrSizing() end)
    bar.container:SetScript('OnMouseDown', function(self, button) if button == 'RightButton' then self:Hide() bar.timer:Hide() end end)    
end

function ubb:OnEnable()
    local candyBar = LibStub('LibCandyBar-3.0')

    bar.timer = candyBar:New('Interface\\AddOns\\UnderbellyBuddy\\Media\\bar', ubb.db.profile.size * barSize.width, ubb.db.profile.size * barSize.height)
    bar.timer:SetPoint('CENTER', bar.container)
    bar.timer:SetLabel('Hired Guard')
    bar.timer.candyBarLabel:SetFont(fontName, ubb.db.profile.size * barSize.font)
    bar.timer.candyBarDuration:SetFont(fontName, ubb.db.profile.size * barSize.font)

    bar.test = candyBar:New('Interface\\AddOns\\UnderbellyBuddy\\Media\\bar', ubb.db.profile.size * barSize.width, ubb.db.profile.size * barSize.height)
    bar.test:SetPoint('CENTER', bar.container)
    bar.test:SetLabel('Test Bar')
    bar.test.candyBarLabel:SetFont(fontName, ubb.db.profile.size * barSize.font)
    bar.test.candyBarDuration:SetFont(fontName, ubb.db.profile.size * barSize.font)

    self:RegisterEvent('PLAYER_ENTERING_WORLD', 'CheckForBodyGuard')
    self:RegisterEvent('ZONE_CHANGED_NEW_AREA', 'CheckForBodyGuard')
    self:RegisterEvent('UNIT_AURA')
    self:RegisterEvent('PLAYER_LOGOUT')
end

function ubb:OnDisable()
    self:UnregisterEvent('PLAYER_ENTERING_WORLD')
    self:UnregisterEvent('ZONE_CHANGED_NEW_AREA')
    self:UnregisterEvent('UNIT_AURA')
    self:RegisterEvent('PLAYER_LOGOUT')
    self:StopBar()
end

function ubb:SetEnabled(info, value)
    self.db.profile.enable = value
    
    if self.db.profile.enable then
        self:OnEnable()
    else
        self:OnDisable()
    end
end

function ubb:ShowTestBar()
    if not run.bar then
        bar.test:SetDuration(barSize.height)
        bar.test:Start()
    else
        self:Print('Buff bar is in progress and the test bar cannot be displayed.')
    end
end

function ubb:SetSize(info, value) 
    self.db.profile.size = value
    
    bar.timer:SetSize(value * barSize.width, value * barSize.height)
    bar.timer.candyBarLabel:SetFont(fontName, ubb.db.profile.size * barSize.font)
    bar.timer.candyBarDuration:SetFont(fontName, ubb.db.profile.size * barSize.font)

    bar.test:SetSize(value * barSize.width, value * barSize.height)
    bar.test.candyBarLabel:SetFont(fontName, ubb.db.profile.size * barSize.font)
    bar.test.candyBarDuration:SetFont(fontName, ubb.db.profile.size * barSize.font)
end

function ubb:RefreshConfig()
    self:SetSize(_, self.db.profile.size)
end

function ubb:UNIT_AURA(eventName, unit)
    if self.db.char.timeLeft > 0 then
        self:StartBar(self.db.char.timeLeft)
    else
        self:StartBar(300)
    end
end

function ubb:PLAYER_LOGOUT()
    if run.bar then
        self.db.char.timeLeft = timeLeft
    else
        self.db.char.timeLeft = 0
    end 
end

function ubb:CheckForBodyGuard()
    inUnderbelly = self:CheckZone(GetSubZoneText())
    hasGuardBuff = self:CheckBuff()
end

function ubb:StartBar(duration)
    if inUnderbelly then
        hasGuardBuff = self:CheckBuff()

        if hasGuardBuff and not run.bar then
            bar.test:Hide()
            bar.timer:AddUpdateFunction(function(bar) self:CheckRemaingTime(bar) end)
            bar.timer:SetDuration(duration)
            bar.timer:Start(300)
        end

        if not hasGuardBuff and run.bar then
            bar.timer:Stop()
            run.bar = false
        end
    else
        self:StopBar()
    end
end

function ubb:StopBar()
    if run.bar then
        bar.timer:Stop()
        run.bar = false
    end
end

function ubb:CheckZone(subzone)
    local correctZones = {'The Underbelly', 'The Underbelly Descent', 'Circle of Wills', 'The Black Market'}
    local value

    for _, value in pairs(correctZones) do
        if subzone == value then
            return true
        end
    end

    return false
end

function ubb:CheckBuff()
    --Precious\'s Ribbon, Mana Divining Stone, Hired Guard
    local buffName = 'Hired Guard'
    local buff = UnitBuff('player', buffName)

    if buff == buffName then
        return true
    else
        return false
    end
end

function ubb:Round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function ubb:CheckRemaingTime(bar)
    if self.db.profile.warning then
        timeLeft = self:Round(bar.remaining, 1)

        if timeLeft == 30 and not run.warning then 
            RaidNotice_AddMessage(RaidWarningFrame, 'Only ' .. timeLeft .. ' seconds left!', ChatTypeInfo['RAID_WARNING'])
            run.warning = true
        end
    end

    run.bar = true 
end