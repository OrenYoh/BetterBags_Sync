if(GetLocale() ~= 'deDE') then
    return
end

local _, ns = ...
local L = ns.L

L["BAGS"] = "Taschen";
L["BANK"] = "Bank";
L["WARBAND_BANK"] = "Kriegsmeutenbank";
L["TOTAL"] = "Gesamt";
L["SLASH_HELP"] = "Befehle: /bbsync gold, /bbsync list, /bbsync remove <Name-Realm oder Gilde-Realm>";
L["SLASH_LIST"] = "Bekannte Charaktere:";
L["SLASH_REMOVED"] = "_name_ entfernt.";
L["SLASH_UNKNOWN"] = "Kein Charakter namens _name_.";
L["SLASH_CURRENT"] = "Ihr könnt den Charakter, den Ihr spielt, nicht entfernen.";
L["EQUIPPED"] = "Angelegt";
L["MAIL"] = "Post";
L["TITLE"] = "Sync";
L["OPTIONS_GROUP_CHARACTERS"] = "Charaktere";
L["OPTIONS_GROUP_TOOLTIP"] = "Tooltip";
L["OPTIONS_GROUP_TYPES"] = "Tooltiparten";
L["OPTIONS_TYPE_GEAR"] = "Ausrüstung";
L["OPTIONS_TYPE_REAGENTS"] = "Handwerksmaterialien";
L["OPTIONS_TYPE_MISC"] = "Andere Gegenstände";
L["OPTIONS_TYPE_CURRENCIES"] = "Währungen";
L["OPTIONS_TYPE_GOLD"] = "Gold";
L["OPTIONS_SHOW_CURRENT"] = "Den gespielten Charakter anzeigen";
L["OPTIONS_SHOW_GUILDS"] = "Gildenbanken anzeigen";
L["OPTIONS_FACTION"] = "Fraktionen";
L["OPTIONS_FACTION_ALL"] = "Alle Fraktionen";
L["OPTIONS_FACTION_SAME"] = "Nur Eure Fraktion";
L["OPTIONS_REALMS"] = "Realms";
L["OPTIONS_REALMS_ALL"] = "Alle Realms";
L["OPTIONS_REALMS_CONNECTED"] = "Verbundene Realms";
L["OPTIONS_REALMS_CURRENT"] = "Nur Euer Realm";
L["VOID"] = "Leerenlager";
L["GOLD_TITLE"] = "Gold:";
L["POPOUT_TITLE"] = "BetterBags - Sync";
L["OPTIONS_MODIFIER"] = "Nur beim Halten anzeigen";
L["OPTIONS_MODIFIER_NONE"] = "Immer anzeigen";
L["OPTIONS_MODIFIER_SHIFT"] = "Umschalt";
L["OPTIONS_MODIFIER_CTRL"] = "Strg";
L["OPTIONS_MODIFIER_ALT"] = "Alt";
L["OPTIONS_POPOUT"] = "In einem eigenen Tooltip anzeigen";
L["OPTIONS_POPOUT_DESC"] = "Zeigt die Anzahlen in einem eigenen Tooltip unter dem des Gegenstands, statt sie ihm hinzuzufügen.";
