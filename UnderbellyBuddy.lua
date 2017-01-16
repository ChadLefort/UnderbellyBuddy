ubb = LibStub('AceAddon-3.0'):NewAddon('UnderbellyBuddy', 'AceConsole-3.0', 'AceEvent-3.0')

local buffName, _, buffIcon = GetSpellInfo(203894)
local fontName = GameFontHighlightSmallOutline:GetFont()
local inUnderbelly = false
local hasGuardBuff = false
local bar = {}
local barSize = {}
local secondsToDisplayWarning = {30, 90}

local barBase = {
    width = 140,
    height = 20,
    font = 8
}

local run = {
    warning = {},
    bar = false1
}

local defaults = {
  profile = {
    enable = true,
    lock = false,
    warning = true,
    size = 1.5
  }
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
                header1 = {
                   order = 0,
                    name = 'Options',
                    type = 'header'
                },
                enable = {
                    order = 0.1,
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
                header2 = {
                   order = 5,
                    name = 'Appearance',
                    type = 'header'
                },
                bar = {
                    order = 5.1,
                    name = 'Test Bar',
                    desc = 'Shows a test bar to move or adjust size',
                    width = 'full',
                    type = 'execute',
                    func = 'ShowTestBar'
                },
                size = {
                    order = 6,
                    name = 'Bar Size',
                    desc = 'Changes the size of the timer bar',
                    width = 'full',
                    type = 'range',
                    min = 1,
                    max = 5,
                    set =  'SetSize',
                    get = function() return ubb.db.profile.size end
                },
                header3 = {
                    order = 7,
                    name = 'About',
                    type = 'header'
                },
                about = {
                    order = 8,
                    name = 'Version: @project-version@ Created by Pigletoos of Skywall',
                    type = 'description'
                },
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

    self.db.RegisterCallback(self, 'OnProfileChanged', 'RefreshConfig')
    self.db.RegisterCallback(self, 'OnProfileCopied', 'RefreshConfig')
    self.db.RegisterCallback(self, 'OnProfileReset', 'RefreshConfig')

    barSize = {
        width = self.db.profile.size * barBase.width,
        height = self.db.profile.size * barBase.height,
        font = self.db.profile.size * barBase.font
    }

    for _, value in pairs(secondsToDisplayWarning) do
        run.warning[value] = false
    end

    bar.container = CreateFrame('Frame', 'UnderbellyBuddyTimerBar', UIParent)
    bar.container:SetSize(barSize.width, barSize.height)
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

    bar.timer = candyBar:New('Interface\\AddOns\\UnderbellyBuddy\\Media\\bar', barSize.width, barSize.height)
    bar.timer:SetPoint('CENTER', bar.container)
    bar.timer:SetLabel(buffName)
    bar.timer:SetIcon(buffIcon)
    bar.timer.candyBarLabel:SetFont(fontName, barSize.font)
    bar.timer.candyBarDuration:SetFont(fontName, barSize.font)
    bar.timer:Hide()

    bar.test = candyBar:New('Interface\\AddOns\\UnderbellyBuddy\\Media\\bar', barSize.width, barSize.height)
    bar.test:SetPoint('CENTER', bar.container)
    bar.test:SetLabel('Test Bar')
    bar.test:SetIcon(buffIcon)
    bar.test.candyBarLabel:SetFont(fontName, barSize.font)
    bar.test.candyBarDuration:SetFont(fontName, barSize.font)
    bar.test:Hide()

    self:RegisterEvent('PLAYER_ENTERING_WORLD', 'CheckBodyGuard')
    self:RegisterEvent('ZONE_CHANGED_NEW_AREA', 'CheckBodyGuard')
    self:RegisterEvent('UNIT_AURA')
end

function ubb:OnDisable()
    self:UnregisterEvent('PLAYER_ENTERING_WORLD')
    self:UnregisterEvent('ZONE_CHANGED_NEW_AREA')
    self:UnregisterEvent('UNIT_AURA')
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
        bar.test:SetDuration(20)
        bar.test:Start()
    else
        self:Print('Buff bar is in progress and the test bar cannot be displayed.')
    end
end

function ubb:SetSize(info, value) 
    self.db.profile.size = value
    
    bar.timer:SetSize(value *  barBase.width, value *  barBase.height)
    bar.timer.candyBarLabel:SetFont(fontName, value * barBase.font)
    bar.timer.candyBarDuration:SetFont(fontName, value * barBase.font)

    bar.test:SetSize(value *  barBase.width, value * barBase.height)
    bar.test.candyBarLabel:SetFont(fontName, value * barBase.font)
    bar.test.candyBarDuration:SetFont(fontName, value * barBase.font)
end

function ubb:RefreshConfig()
    self:SetSize(_, self.db.profile.size)
end

function ubb:CheckBodyGuard()
    inUnderbelly = self:CheckZone(GetSubZoneText())
    hasGuardBuff = self:CheckBuff()
end

function ubb:UNIT_AURA(eventName, unit)
    self:StartBar()
end

function ubb:StartBar()
    if inUnderbelly then
        hasGuardBuff = self:CheckBuff()

        if hasGuardBuff and not run.bar then
            bar.test:Hide()
            bar.timer:AddUpdateFunction(function(bar) self:CheckRemaingTime(bar) end)
            bar.timer:SetDuration(300)
            bar.timer:Start()
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
        local timeLeft = self:Round(bar.remaining, 1)
        local timeDisplay = string.format('%d seconds', timeLeft)

        if timeLeft > 60 then
            timeDisplay = string.format('%d minute %d seconds', timeLeft / 60 % 60, timeLeft % 60)         
        end

        for _, value in pairs(secondsToDisplayWarning) do
            if timeLeft == value and not run.warning[value] then 
                RaidNotice_AddMessage(RaidWarningFrame, string.format('Only %s remaining for %s!', timeDisplay, buffName), ChatTypeInfo['RAID_WARNING'])
                run.warning[value] = true
            end
        end
    end

    run.bar = true
end