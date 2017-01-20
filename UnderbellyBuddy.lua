ub = LibStub('AceAddon-3.0'):NewAddon('UnderbellyBuddy', 'AceConsole-3.0')

local defaults = {
  profile = {
    enable = true,
    lock = false,
    warning = true,
    size = 1.5
  }
}

function ub:OnInitialize()
    self.db = LibStub('AceDB-3.0'):New('UnderbellyBuddyDB', defaults) 

    ub.container = CreateFrame('Frame', 'UnderbellyBuddyTimerBar', UIParent)
    ub.container:SetSize(self.db.profile.size * 140, self.db.profile.size * 20)
    ub.container:SetMovable(true)
    ub.container:SetUserPlaced(true)
    ub.container:SetPoint('CENTER', 0, 150)
    ub.container:EnableMouse(true)
    ub.container:RegisterForDrag('LeftButton')
    ub.container:SetScript('OnDragStart', function(self) if not ub.db.profile.lock then self:StartMoving() end end)
    ub.container:SetScript('OnDragStop', function(self) self:StopMovingOrSizing() end)
    ub.container:SetScript('OnMouseDown', function(self, button) if button == 'RightButton' then self:Hide() ub.bar.timer:Hide() end end)    
end
