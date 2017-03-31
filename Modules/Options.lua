local UnderbellyBuddy = LibStub('AceAddon-3.0'):GetAddon('UnderbellyBuddy')
local UnderbellyBuddyHiredGuard = UnderbellyBuddy:GetModule('UnderbellyBuddyHiredGuard')
local UnderbellyBuddyOptions = UnderbellyBuddy:NewModule('UnderbellyBuddyOptions', 'AceConsole-3.0')
local AceConfig = LibStub('AceConfig-3.0')
local AceConfigDialog = LibStub('AceConfigDialog-3.0')

function UnderbellyBuddyOptions:OnInitialize()
    self.db = UnderbellyBuddy.db
    
    local options = self:GetOptions()
    
    options.args.profile = LibStub('AceDBOptions-3.0'):GetOptionsTable(self.db)
    
    AceConfig:RegisterOptionsTable('UnderbellyBuddy', options)
    AceConfigDialog:AddToBlizOptions('UnderbellyBuddy', 'UnderbellyBuddy', nil, 'main')
    AceConfigDialog:AddToBlizOptions('UnderbellyBuddy', 'Profiles', 'UnderbellyBuddy', 'profile')
    
    self:RegisterChatCommand('ub', 'OpenOptions')
    
    self.db.RegisterCallback(self, 'OnProfileChanged', 'RefreshConfig')
    self.db.RegisterCallback(self, 'OnProfileCopied', 'RefreshConfig')
    self.db.RegisterCallback(self, 'OnProfileReset', 'RefreshConfig')
end

function UnderbellyBuddyOptions:OpenOptions()
    AceConfigDialog:SetDefaultSize('UnderbellyBuddy', 600, 425)
    AceConfigDialog:Open('UnderbellyBuddy')
end

function UnderbellyBuddyOptions:RefreshConfig()
    UnderbellyBuddyHiredGuard:SetSize(_, self.db.profile.size)
end

function UnderbellyBuddyOptions:GetOptions()
    return {
        name = 'UnderbellyBuddy',
        handler = UnderbellyBuddy,
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
                        set = function(_, value) UnderbellyBuddyHiredGuard:SetEnabled(_, value) end,
                        get = function() return self.db.profile.enable end
                    },
                    lock = {
                        order = 0.2,
                        name = 'Lock Timer',
                        desc = 'Locks the timer bar in place',
                        width = 'full',
                        type = 'toggle',
                        set = function(_, value) self.db.profile.lock = value end,
                        get = function() return self.db.profile.lock end
                    },
                    warnings = {
                        order = 0.3,
                        name = 'Display Warnings',
                        desc = 'Displays warning messages after a certain amount of time',
                        width = 'full',
                        type = 'toggle',
                        set = function(_, value) self.db.profile.warning = value end,
                        get = function() return  self.db.profile.warning end
                    },
                    header2 = {
                        order = 1,
                        name = 'Appearance',
                        type = 'header'
                    },
                    bar = {
                        order = 1.1,
                        name = 'Test Bar',
                        desc = 'Shows a test bar to move or adjust size',
                        width = 'full',
                        type = 'execute',
                        func = function() UnderbellyBuddyHiredGuard:ShowTestBar() end
                    },
                    size = {
                        order = 1.2,
                        name = 'Bar Size',
                        desc = 'Changes the size of the timer bar',
                        width = 'full',
                        type = 'range',
                        min = 1,
                        max = 5,
                        set = function(_, value) UnderbellyBuddyHiredGuard:SetSize(_, value) end,
                        get = function() return self.db.profile.size end
                    },
                    header3 = {
                        order = 2,
                        name = 'About',
                        type = 'header'
                    },
                    about = {
                        order = 2.1,
                        name = 'Version: @project-version@\nCreated by Pigletoos of Skywall',
                        type = 'description'
                    },
                }
            }
        }
    }
end
