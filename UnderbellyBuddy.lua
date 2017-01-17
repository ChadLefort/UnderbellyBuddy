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
end
