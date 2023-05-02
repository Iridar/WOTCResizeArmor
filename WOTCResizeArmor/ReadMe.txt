X2ModBuildCommon v1.2.1 successfully installed. 
Edit .scripts\build.ps1 if you want to enable cooking. 
 
Enjoy making your mod, and may the odds be ever in your favor. 
 
 
Created with Enhanced Mod Project Template v1.0 
 
Get news and updates here: 
https://github.com/Iridar/EnhancedModProjectTemplate 

Changelog:
Added a "ResizeArmorWipe" console command to wipe all data stored by the mod in the save file.
Added a reset button.
Added Russian translation.
The panel to customize the soldier size will now show in the main customization menu as well. Useful for soldiers that do not have a customizable body, i.e. Playable Aliens. This feature can be disabled in config.
Tooltips should no longer go off screen if the panel is moved too far down.
Improved the limit on how far the panel will allow itself to be moved downwards.


TODO:
physics props are not resized
with UCR, have to select part from the list before resizing it

[WOTC] Iridar's Resizable Armor

This mod adds sliders that can be used to resize and reposition individual cosmetic body parts. Helmet too small? Make it bigger. Goggles clip through your anthro cosmetics? Move them.

Being able to do this opens a whole new dimension in soldier customization.

[h1]LIMITATIONS[/h1]
[list][*] The head cannot be resized.
[*] If you move or resize a body part too much, there will be animation issues. To minimize this effect, try to move and resize the parts as little as possible.
[*] The information about body part size and location is stored for each soldier individually. Resizing or moving a body part for one soldier will have no effect on other soldiers. The information is not saved to Character Pool and it cannot be moved between campaigns.[/list]

[h1]COMPATIBILITY[/h1]

The mod should be compatible with ALL cosmetic mods, don't even ask.

[b][url=https://steamcommunity.com/sharedfiles/filedetails/?id=2438621356][WOTC] Unrestricted Customization Redux[/url][/b] - should be compatible.

[b][url=https://steamcommunity.com/sharedfiles/filedetails/?id=1147128235]WotC Customize Soldier Size[/url][/b] - should be compatible, but unnecessary, my mod also allows resizing the entire soldier model.

[h1]DRAG AND DROP[/h1]

The new UI panel with size and location sliders is located in the top right corner of the soldier appearance customization screen by default. There is a button you can use to hide it.

In case the panel clips with UI elements from other mods, you can move it by holding the left mouse on that button to enable the drag and drop mode. Then move your mouse on top of the arrow icons to reposition it. Click at the center button when you're done.

See the video for a demonstration.

[h1]CONFIGURATION[/h1]

Maximum body part size and movement distance can be configured in:
[code]..\steamapps\workshop\content\268500\2969648947\Config\XComUI.ini[/code]

[h1]REQUIREMENTS[/h1]
[list][*] [url=https://steamcommunity.com/workshop/filedetails/?id=1134256495][b]X2 WOTC Community Highlander[/b][/url][/list]

Safe to add mid-campaign.

[h1]CREDITS[/h1]

Please [b][url=https://www.patreon.com/Iridar]support me on Patreon[/url][/b] if you require tech support, have a suggestion for a feature, or simply wish to help me create more awesome mods.

[b][url=https://discord.gg/mgZ5khh]Join my Discord[/url][/b] to keep track of my current activities.