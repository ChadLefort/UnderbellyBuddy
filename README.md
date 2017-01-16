# UnderbellyBuddy

A World of Warcraft addon that tracks the time of the hired guard buff obtainable in the Underbelly of Dalaran. 
The hired guard prevents you from PvP flagging when the Underbelly turns into a PvP free for all.

**NOTE:** The timer bar will not persist through UI reloads.

## Options

### GUI

Found under **Interface > AddOns Tab > UnderbellyBuddy**

### Slash Commands

- `ubb` *option* - Main command

#### Main

- `enable` - Enables / disables the addon
- `show` - Shows the bar if you dismissed it away
- `hide` - Hides the bar if you dismissed it away
- `lock` - Locks the timer bar in place
- `warnings` - Displays warning messages after a certain amount of time
- `bar` - Shows a test bar to move or adjust size
- `size` *decimal (1.00-5.00)* - Changes the size of the timer bar

#### Profile

- `reset` - Reset the current profile to the default
- `new` *profile name* - Create a new empty profile
- `choose` *profile name* - Select one of your currently available profiles
- `copyfrom` *profile name* - Copy the settings from one existing profile into the currently active profile
- `delete` *profile name* - Deletes a profile from the database