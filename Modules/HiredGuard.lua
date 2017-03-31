local UnderbellyBuddy = LibStub('AceAddon-3.0'):GetAddon('UnderbellyBuddy')
local UnderbellyBuddyHiredGuard = UnderbellyBuddy:NewModule('UnderbellyBuddyHiredGuard', 'AceConsole-3.0', 'AceEvent-3.0')
local buffName, _, buffIcon = GetSpellInfo(203894)
local fontName = GameFontHighlightSmallOutline:GetFont()
local inUnderbelly = false
local hasGuardBuff = false
local barSize = {}
local secondsToDisplayWarning = {30, 90}
local barBase = {
    width = 140,
    height = 20,
    font = 8
}
local run = {
    warning = {},
    bar = false
}

function UnderbellyBuddyHiredGuard:OnInitialize()
    self.db = UnderbellyBuddy.db

    barSize = {
        width = self.db.profile.size * barBase.width,
        height = self.db.profile.size * barBase.height,
        font = self.db.profile.size * barBase.font
    }

    for _, value in pairs(secondsToDisplayWarning) do
        run.warning[value] = false
    end

    self:RegisterChatCommand('ubshow', 'ShowBar')
    self:RegisterChatCommand('ubhide', 'HideBar')
end

function UnderbellyBuddyHiredGuard:OnEnable()
    local candyBar = LibStub('LibCandyBar-3.0')

    UnderbellyBuddy.bar = {}

    if not UnderbellyBuddy.bar.timer then
        UnderbellyBuddy.bar.timer = candyBar:New('Interface\\AddOns\\UnderbellyBuddy\\Media\\bar', barSize.width, barSize.height)
        UnderbellyBuddy.bar.timer:SetPoint('CENTER', UnderbellyBuddy.container)
        UnderbellyBuddy.bar.timer:SetLabel(buffName)
        UnderbellyBuddy.bar.timer:SetIcon(buffIcon)
        UnderbellyBuddy.bar.timer.candyBarLabel:SetFont(fontName, barSize.font)
        UnderbellyBuddy.bar.timer.candyBarDuration:SetFont(fontName, barSize.font)
        UnderbellyBuddy.bar.timer:Hide()
    end

    if not UnderbellyBuddy.bar.test then
        UnderbellyBuddy.bar.test = candyBar:New('Interface\\AddOns\\UnderbellyBuddy\\Media\\bar', barSize.width, barSize.height)
        UnderbellyBuddy.bar.test:SetPoint('CENTER', UnderbellyBuddy.container)
        UnderbellyBuddy.bar.test:SetLabel('Test Bar')
        UnderbellyBuddy.bar.test:SetIcon(buffIcon)
        UnderbellyBuddy.bar.test.candyBarLabel:SetFont(fontName, barSize.font)
        UnderbellyBuddy.bar.test.candyBarDuration:SetFont(fontName, barSize.font)
        UnderbellyBuddy.bar.test:Hide()
    end

    self:RegisterEvent('PLAYER_ENTERING_WORLD', 'CheckBodyGuard')
    self:RegisterEvent('ZONE_CHANGED_NEW_AREA', 'CheckBodyGuard')
    self:RegisterEvent('UNIT_AURA')
end

function UnderbellyBuddyHiredGuard:OnDisable()
    self:UnregisterEvent('PLAYER_ENTERING_WORLD')
    self:UnregisterEvent('ZONE_CHANGED_NEW_AREA')
    self:UnregisterEvent('UNIT_AURA')
    self:StopBar()
end

function UnderbellyBuddyHiredGuard:CheckBodyGuard()
    inUnderbelly = self:CheckZone(GetSubZoneText())
    hasGuardBuff = self:CheckBuff()
end

function UnderbellyBuddyHiredGuard:UNIT_AURA(eventName, unit)
    self:StartBar()
end

function UnderbellyBuddyHiredGuard:CheckZone(subzone)
    local correctZones = {'The Underbelly', 'The Underbelly Descent', 'Circle of Wills', 'The Black Market'}
    local value

    for _, value in pairs(correctZones) do
        if subzone == value then
            return true
        end
    end

    return false
end

function UnderbellyBuddyHiredGuard:CheckBuff()
    local buff = UnitBuff('player', buffName)

    if buff == buffName then
        return true
    else
        return false
    end
end

function UnderbellyBuddyHiredGuard:StartBar()
    if inUnderbelly then
        hasGuardBuff = self:CheckBuff()

        if hasGuardBuff and not run.bar then
            UnderbellyBuddy.bar.test:Hide()
            UnderbellyBuddy.bar.timer:AddUpdateFunction(function(bar) self:CheckRemaingTime(bar) end)
            UnderbellyBuddy.bar.timer:SetDuration(300)
            UnderbellyBuddy.bar.timer:Start()
        end

        if not hasGuardBuff then
            self:StopBar()
        end
    else
        self:StopBar()
    end
end

function UnderbellyBuddyHiredGuard:StopBar()
    if run.bar then
        UnderbellyBuddy.bar.timer:Stop()
        run.bar = false

        for _, value in pairs(secondsToDisplayWarning) do
            run.warning[value] = false
        end
    end
end

function UnderbellyBuddyHiredGuard:Round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function UnderbellyBuddyHiredGuard:CheckRemaingTime(bar)
    if self.db.profile.warning then
        local timeLeft = self:Round(bar.remaining, 1)
        local timeDisplay = string.format('%d seconds', timeLeft)

        if timeLeft > 60 then
            timeDisplay = string.format('%d minute %d seconds', timeLeft / 60 % 60, timeLeft % 60)         
        end

        for _, value in pairs(secondsToDisplayWarning) do
            if timeLeft == value and not run.warning[value] then
                PlaySoundFile('Sound\\Interface\\RaidWarning.ogg') 
                RaidNotice_AddMessage(RaidWarningFrame, string.format('Only %s remaining for %s!', timeDisplay, buffName), ChatTypeInfo['RAID_WARNING'])
                run.warning[value] = true
            end
        end
    end

    run.bar = true
end

function UnderbellyBuddyHiredGuard:SetEnabled(_, value)
    self.db.profile.enable = value
    
    if self.db.profile.enable then
        self:OnEnable()
    else
        self:OnDisable()
    end
end

function UnderbellyBuddyHiredGuard:ShowBar() 
    if run.bar then
        UnderbellyBuddy.container:Show()  
        UnderbellyBuddy.bar.timer:Show() 
    else 
        UnderbellyBuddy:Print('No bar to display') 
    end 
end

function UnderbellyBuddyHiredGuard:HideBar()
    if run.bar then
        UnderbellyBuddy.container:Hide() 
        UnderbellyBuddy.bar.timer:Hide() 
    else 
        UnderbellyBuddy:Print('No bar to hide') 
    end 
 end

function UnderbellyBuddyHiredGuard:ShowTestBar()
    if not run.bar then
        UnderbellyBuddy.bar.test:SetDuration(20)
        UnderbellyBuddy.bar.test:Start()
    else
        UnderbellyBuddy:Print(string.format('%s is in progress and the test bar cannot be displayed.', buffName))
    end
end

function UnderbellyBuddyHiredGuard:SetSize(_, value) 
    self.db.profile.size = value
    
    UnderbellyBuddy.bar.timer:SetSize(value * barBase.width, value * barBase.height)
    UnderbellyBuddy.bar.timer.candyBarLabel:SetFont(fontName, value * barBase.font)
    UnderbellyBuddy.bar.timer.candyBarDuration:SetFont(fontName, value * barBase.font)

    UnderbellyBuddy.bar.test:SetSize(value * barBase.width, value * barBase.height)
    UnderbellyBuddy.bar.test.candyBarLabel:SetFont(fontName, value * barBase.font)
    UnderbellyBuddy.bar.test.candyBarDuration:SetFont(fontName, value * barBase.font)
end
