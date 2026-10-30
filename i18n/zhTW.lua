if(GetLocale() ~= 'zhTW') then
    return
end

local _, ns = ...
local L = ns.L

L["BAGS"] = "背包";
L["BANK"] = "銀行";
L["WARBAND_BANK"] = "戰隊銀行";
L["TOTAL"] = "總計";
L["SLASH_HELP"] = "指令：/bbsync gold，/bbsync list，/bbsync remove <角色名-伺服器 或 公會名-伺服器>";
L["SLASH_LIST"] = "已知角色：";
L["SLASH_REMOVED"] = "已移除 _name_。";
L["SLASH_UNKNOWN"] = "沒有名為 _name_ 的角色。";
L["SLASH_CURRENT"] = "無法移除你正在使用的角色。";
L["EQUIPPED"] = "已裝備";
L["MAIL"] = "郵件";
L["TITLE"] = "Sync";
L["OPTIONS_GROUP_CHARACTERS"] = "角色";
L["OPTIONS_GROUP_TOOLTIP"] = "浮動提示";
L["OPTIONS_GROUP_TYPES"] = "浮動提示類型";
L["OPTIONS_TYPE_GEAR"] = "裝備";
L["OPTIONS_TYPE_REAGENTS"] = "製作材料";
L["OPTIONS_TYPE_MISC"] = "其他物品";
L["OPTIONS_TYPE_CURRENCIES"] = "貨幣";
L["OPTIONS_TYPE_GOLD"] = "金幣";
L["OPTIONS_SHOW_CURRENT"] = "顯示目前角色";
L["OPTIONS_SHOW_GUILDS"] = "顯示公會銀行";
L["OPTIONS_FACTION"] = "陣營";
L["OPTIONS_FACTION_ALL"] = "所有陣營";
L["OPTIONS_FACTION_SAME"] = "僅限你的陣營";
L["OPTIONS_REALMS"] = "伺服器";
L["OPTIONS_REALMS_ALL"] = "所有伺服器";
L["OPTIONS_REALMS_CONNECTED"] = "連結伺服器";
L["OPTIONS_REALMS_CURRENT"] = "僅限你的伺服器";
L["VOID"] = "虛空倉庫";
L["GOLD_TITLE"] = "金幣：";
L["POPOUT_TITLE"] = "BetterBags - Sync";
L["OPTIONS_MODIFIER"] = "僅在按住時顯示";
L["OPTIONS_MODIFIER_NONE"] = "總是顯示";
L["OPTIONS_MODIFIER_SHIFT"] = "Shift";
L["OPTIONS_MODIFIER_CTRL"] = "Ctrl";
L["OPTIONS_MODIFIER_ALT"] = "Alt";
L["OPTIONS_POPOUT"] = "在獨立的浮動提示中顯示";
L["OPTIONS_POPOUT_DESC"] = "在物品浮動提示下方的獨立提示中顯示數量，而不是加入物品提示中。";
