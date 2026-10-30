if(GetLocale() ~= 'ruRU') then
    return
end

local _, ns = ...
local L = ns.L

L["BAGS"] = "Сумки";
L["BANK"] = "Банк";
L["WARBAND_BANK"] = "Банк отряда";
L["TOTAL"] = "Всего";
L["SLASH_HELP"] = "Команды: /bbsync gold, /bbsync list, /bbsync remove <Имя-Сервер или Гильдия-Сервер>";
L["SLASH_LIST"] = "Известные персонажи:";
L["SLASH_REMOVED"] = "_name_ удален(а).";
L["SLASH_UNKNOWN"] = "Нет персонажа с именем _name_.";
L["SLASH_CURRENT"] = "Нельзя удалить персонажа, за которого вы играете.";
L["EQUIPPED"] = "Надето";
L["MAIL"] = "Почта";
L["TITLE"] = "Sync";
L["OPTIONS_GROUP_CHARACTERS"] = "Персонажи";
L["OPTIONS_GROUP_TOOLTIP"] = "Подсказка";
L["OPTIONS_GROUP_TYPES"] = "Типы подсказок";
L["OPTIONS_TYPE_GEAR"] = "Экипировка";
L["OPTIONS_TYPE_REAGENTS"] = "Материалы для ремесла";
L["OPTIONS_TYPE_MISC"] = "Другие предметы";
L["OPTIONS_TYPE_CURRENCIES"] = "Валюта";
L["OPTIONS_TYPE_GOLD"] = "Золото";
L["OPTIONS_SHOW_CURRENT"] = "Показывать текущего персонажа";
L["OPTIONS_SHOW_GUILDS"] = "Показывать банки гильдий";
L["OPTIONS_FACTION"] = "Фракции";
L["OPTIONS_FACTION_ALL"] = "Все фракции";
L["OPTIONS_FACTION_SAME"] = "Только ваша фракция";
L["OPTIONS_REALMS"] = "Серверы";
L["OPTIONS_REALMS_ALL"] = "Все серверы";
L["OPTIONS_REALMS_CONNECTED"] = "Связанные серверы";
L["OPTIONS_REALMS_CURRENT"] = "Только ваш сервер";
L["VOID"] = "Хранилище Бездны";
L["GOLD_TITLE"] = "Золото:";
L["POPOUT_TITLE"] = "BetterBags - Sync";
L["OPTIONS_MODIFIER"] = "Показывать только при удержании";
L["OPTIONS_MODIFIER_NONE"] = "Показывать всегда";
L["OPTIONS_MODIFIER_SHIFT"] = "Shift";
L["OPTIONS_MODIFIER_CTRL"] = "Ctrl";
L["OPTIONS_MODIFIER_ALT"] = "Alt";
L["OPTIONS_POPOUT"] = "Показывать в отдельной подсказке";
L["OPTIONS_POPOUT_DESC"] = "Показывает количество в собственной подсказке под подсказкой предмета, а не добавляет его в нее.";
