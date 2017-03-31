local UnderbellyBuddy = LibStub('AceAddon-3.0'):NewAddon('UnderbellyBuddy', 'AceConsole-3.0')
local defaults = {
    profile = {
        enable = true,
        lock = false,
        warning = true,
        size = 1.5
    }
}

function UnderbellyBuddy:OnInitialize()
    self.db = LibStub('AceDB-3.0'):New('UnderbellyBuddyDB', defaults)  
    self.container = CreateFrame('Frame', 'UnderbellyBuddyTimerBar', UIParent)
    self.container:SetSize(self.db.profile.size * 140, self.db.profile.size * 20)
    self.container:SetMovable(true)
    self.container:SetUserPlaced(true)
    self.container:SetPoint('CENTER', 0, 150)
    self.container:EnableMouse(true)
    self.container:RegisterForDrag('LeftButton')
    self.container:SetScript('OnDragStart', function(self) if not UnderbellyBuddy.db.profile.lock then self:StartMoving() end end)
    self.container:SetScript('OnDragStop', function(self) self:StopMovingOrSizing() end)
    self.container:SetScript('OnMouseDown', function(self, button) if button == 'RightButton' then self:Hide() UnderbellyBuddy.bar.timer:Hide() end end)
end
