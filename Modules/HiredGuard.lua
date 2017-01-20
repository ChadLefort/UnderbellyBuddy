ub = LibStub('AceAddon-3.0'):GetAddon('UnderbellyBuddy')
ubHiredGuard = ub:NewModule('HiredGuard', 'AceConsole-3.0', 'AceEvent-3.0')

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

function ubHiredGuard:OnInitialize()
    self.db = ub.db

    barSize = {
        width = self.db.profile.size * barBase.width,
        height = self.db.profile.size * barBase.height,
        font = self.db.profile.size * barBase.font
    }

    for _, value in pairs(secondsToDisplayWarning) do
        run.warning[value] = false
    end
end

function ubHiredGuard:OnEnable()
    local candyBar = LibStub('LibCandyBar-3.0')

    ub.bar = {}
    ub.bar.timer = candyBar:New('Interface\\AddOns\\UnderbellyBuddy\\Media\\bar', barSize.width, barSize.height)
    ub.bar.timer:SetPoint('CENTER', ub.container)
    ub.bar.timer:SetLabel(buffName)
    ub.bar.timer:SetIcon(buffIcon)
    ub.bar.timer.candyBarLabel:SetFont(fontName, barSize.font)
    ub.bar.timer.candyBarDuration:SetFont(fontName, barSize.font)
    ub.bar.timer:Hide()

    ub.bar.test = candyBar:New('Interface\\AddOns\\UnderbellyBuddy\\Media\\bar', barSize.width, barSize.height)
    ub.bar.test:SetPoint('CENTER', ub.container)
    ub.bar.test:SetLabel('Test Bar')
    ub.bar.test:SetIcon(buffIcon)
    ub.bar.test.candyBarLabel:SetFont(fontName, barSize.font)
    ub.bar.test.candyBarDuration:SetFont(fontName, barSize.font)
    ub.bar.test:Hide()

    self:RegisterEvent('PLAYER_ENTERING_WORLD', 'CheckBodyGuard')
    self:RegisterEvent('ZONE_CHANGED_NEW_AREA', 'CheckBodyGuard')
    self:RegisterEvent('UNIT_AURA')
end

function ubHiredGuard:OnDisable()
    self:UnregisterEvent('PLAYER_ENTERING_WORLD')
    self:UnregisterEvent('ZONE_CHANGED_NEW_AREA')
    self:UnregisterEvent('UNIT_AURA')
    self:StopBar()
end

function ubHiredGuard:CheckBodyGuard()
    inUnderbelly = self:CheckZone(GetSubZoneText())
    hasGuardBuff = self:CheckBuff()
end

function ubHiredGuard:UNIT_AURA(eventName, unit)
    self:StartBar()
end

function ubHiredGuard:CheckZone(subzone)
    local correctZones = {'The Underbelly', 'The Underbelly Descent', 'Circle of Wills', 'The Black Market'}
    local value

    for _, value in pairs(correctZones) do
        if subzone == value then
            return true
        end
    end

    return false
end

function ubHiredGuard:CheckBuff()
    local buff = UnitBuff('player', buffName)

    if buff == buffName then
        return true
    else
        return false
    end
end

function ubHiredGuard:StartBar()
    if inUnderbelly then
        hasGuardBuff = self:CheckBuff()

        if hasGuardBuff and not run.bar then
            ub.bar.test:Hide()
            ub.bar.timer:AddUpdateFunction(function(bar) self:CheckRemaingTime(bar) end)
            ub.bar.timer:SetDuration(300)
            ub.bar.timer:Start()
        end

        if not hasGuardBuff then
            self:StopBar()
        end
    else
        self:StopBar()
    end
end

function ubHiredGuard:StopBar()
    if run.bar then
        ub.bar.timer:Stop()
        run.bar = false

        for _, value in pairs(secondsToDisplayWarning) do
            run.warning[value] = false
        end
    end
end

function ubHiredGuard:Round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function ubHiredGuard:CheckRemaingTime(bar)
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

function ubHiredGuard:SetEnabled(_, value)
    self.db.profile.enable = value
    
    if self.db.profile.enable then
        self:OnEnable()
    else
        self:OnDisable()
    end
end

function ubHiredGuard:ShowBar() 
    if run.bar then
        ub.container:Show()  
        ub.bar.timer:Show() 
    else 
        ub:Print('No bar to display') 
    end 
end

function ubHiredGuard:HideBar()
    if run.bar then
        ub.container:Hide() 
        ub.bar.timer:Hide() 
    else 
        ub:Print('No bar to hide') 
    end 
 end

function ubHiredGuard:ShowTestBar()
    if not run.bar then
        ub.bar.test:SetDuration(20)
        ub.bar.test:Start()
    else
        ub:Print(string.format('%s is in progress and the test bar cannot be displayed.', buffName))
    end
end

function ubHiredGuard:SetSize(_, value) 
    self.db.profile.size = value
    
    ub.bar.timer:SetSize(value * barBase.width, value * barBase.height)
    ub.bar.timer.candyBarLabel:SetFont(fontName, value * barBase.font)
    ub.bar.timer.candyBarDuration:SetFont(fontName, value * barBase.font)

    ub.bar.test:SetSize(value * barBase.width, value * barBase.height)
    ub.bar.test.candyBarLabel:SetFont(fontName, value * barBase.font)
    ub.bar.test.candyBarDuration:SetFont(fontName, value * barBase.font)
end
