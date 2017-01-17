ub = LibStub('AceAddon-3.0'):GetAddon('UnderbellyBuddy')
ubHiredGuard = ub:GetModule('HiredGuard')
ubConfig = ub:NewModule('UnderbellyBuddyConfig')

function ubConfig:OnInitialize()
    self.db = ub.db

    local options = self:GetOptions()
    
    options.args.profile = LibStub('AceDBOptions-3.0'):GetOptionsTable(self.db)

    LibStub('AceConfig-3.0'):RegisterOptionsTable('UnderbellyBuddy', options, {'ub', 'UnderbellyBuddy'})
    LibStub('AceConfigDialog-3.0'):AddToBlizOptions('UnderbellyBuddy', 'UnderbellyBuddy', nil, 'main') 
    LibStub('AceConfigDialog-3.0'):AddToBlizOptions('UnderbellyBuddy', 'Profiles', 'UnderbellyBuddy', 'profile')

    self.db.RegisterCallback(self, 'OnProfileChanged', 'RefreshConfig')
    self.db.RegisterCallback(self, 'OnProfileCopied', 'RefreshConfig')
    self.db.RegisterCallback(self, 'OnProfileReset', 'RefreshConfig')
end

function ubConfig:RefreshConfig()
    ubHiredGuard:SetSize(_, self.db.profile.size)
end

function ubConfig:GetOptions()
    return {
        name = 'UnderbellyBuddy',
        handler = ub,
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
                        set = function(_, value) ubHiredGuard:SetEnabled(_, value) end,
                        get = function() return ub.db.profile.enable end
                    },
                    show = {
                        order = 1,
                        guiHidden = true,
                        name = 'Show Bar',
                        desc = 'Shows the bar if you dismissed it away',
                        type = 'execute',
                        func = function() ubHiredGuard:ShowBar() end
                    },
                    hide = {
                        order = 2,
                        guiHidden = true,
                        name = 'Hide Bar',
                        desc = 'Hides the bar if you dismissed it away',
                        type = 'execute',
                        func = function() ubHiredGuard:HideBar() end
                    },
                    lock = {
                        order = 3,
                        name = 'Lock Timer',
                        desc = 'Locks the timer bar in place',
                        width = 'full',
                        type = 'toggle',
                        set = function(_, value) ub.db.profile.lock = value end,
                        get = function() return ub.db.profile.lock end
                    },
                    warnings = {
                        order = 4,
                        name = 'Display Warnings',
                        desc = 'Displays warning messages after a certain amount of time',
                        width = 'full',
                        type = 'toggle',
                        set = function(_, value) ub.db.profile.warning = value end,
                        get = function() return ub.db.profile.warning end
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
                        func = function() ubHiredGuard:ShowTestBar() end
                    },
                    size = {
                        order = 6,
                        name = 'Bar Size',
                        desc = 'Changes the size of the timer bar',
                        width = 'full',
                        type = 'range',
                        min = 1,
                        max = 5,
                        set =  function(_, value) ubHiredGuard:SetSize(_, value) end,
                        get = function() return ub.db.profile.size end
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
end