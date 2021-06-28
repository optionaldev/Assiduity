# Assiduity

Old World of Warcraft project from 2013 that I started working again on, slowly bringing back components, fixing bugs, adding new features. It's just for personal use. I like to customize my UI and I love working in Lua, so win-win.
 
Abbreviations:
WoW = World of Warcraft
UI = User Interface

References:

WoW has events firing in the global scope. An addon can use these events to react to certain situations.
https://wowwiki-archive.fandom.com/wiki/Events_A-Z_(full_list)

WoW has global functions that can be called from your code. No need to import anything, they're just there. Some APIs are protected, meaning you won't be able to use them as a reaction to an event. What you can do is link a button to those protected functions such that user has to interact with the UI in order to benefit from the protected functions. Even that won't work all the time, and you'll get a pop-up message saying Blizzard blocked it.
https://wowwiki-archive.fandom.com/wiki/World_of_Warcraft_API

WoW addons use **XML** for their UI. The file **BlizzardUI.xsd** can be used to validate your XML files. It's a file that contains all the rules that an XML file should comply to. You can use this link to validate XML against the XSD.
https://www.freeformatter.com/xml-validator-xsd.html

The scripting part is done in **lua**. Some of the most helpful resources can be found here:
https://wiki.srb2.org/wiki/Lua/Functions
https://www.tutorialspoint.com/lua/

When testing the addon, it's useful to have another addon called **devtools**. Download links may change / disappear so you need to find it on your own.

The source code can be changed with the game open. All you need to do is, after you make the required change, type **/reload** in chat. Warning: some servers will kick you if you reload too many times in a short time frame.
