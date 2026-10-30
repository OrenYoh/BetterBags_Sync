if(GetLocale() ~= 'zhCN') then
    return
end

local _, ns = ...
local L = ns.L

L["BAGS"] = "背包";
L["BANK"] = "银行";
L["WARBAND_BANK"] = "战团银行";
L["TOTAL"] = "总计";
L["SLASH_HELP"] = "命令：/bbsync gold，/bbsync list，/bbsync remove <角色名-服务器 或 公会名-服务器>";
L["SLASH_LIST"] = "已知角色：";
L["SLASH_REMOVED"] = "已移除 _name_。";
L["SLASH_UNKNOWN"] = "没有名为 _name_ 的角色。";
L["SLASH_CURRENT"] = "无法移除你正在使用的角色。";
L["EQUIPPED"] = "已装备";
L["MAIL"] = "邮件";
L["TITLE"] = "Sync";
L["OPTIONS_GROUP_CHARACTERS"] = "角色";
L["OPTIONS_GROUP_TOOLTIP"] = "鼠标提示";
L["OPTIONS_GROUP_TYPES"] = "鼠标提示类型";
L["OPTIONS_TYPE_GEAR"] = "装备";
L["OPTIONS_TYPE_REAGENTS"] = "制造材料";
L["OPTIONS_TYPE_MISC"] = "其他物品";
L["OPTIONS_TYPE_CURRENCIES"] = "货币";
L["OPTIONS_TYPE_GOLD"] = "金币";
L["OPTIONS_SHOW_CURRENT"] = "显示当前角色";
L["OPTIONS_SHOW_GUILDS"] = "显示公会银行";
L["OPTIONS_FACTION"] = "阵营";
L["OPTIONS_FACTION_ALL"] = "所有阵营";
L["OPTIONS_FACTION_SAME"] = "仅限你的阵营";
L["OPTIONS_REALMS"] = "服务器";
L["OPTIONS_REALMS_ALL"] = "所有服务器";
L["OPTIONS_REALMS_CONNECTED"] = "互联服务器";
L["OPTIONS_REALMS_CURRENT"] = "仅限你的服务器";
L["VOID"] = "虚空仓库";
L["GOLD_TITLE"] = "金币：";
L["POPOUT_TITLE"] = "BetterBags - Sync";
L["OPTIONS_MODIFIER"] = "仅在按住时显示";
L["OPTIONS_MODIFIER_NONE"] = "总是显示";
L["OPTIONS_MODIFIER_SHIFT"] = "Shift";
L["OPTIONS_MODIFIER_CTRL"] = "Ctrl";
L["OPTIONS_MODIFIER_ALT"] = "Alt";
L["OPTIONS_POPOUT"] = "在单独的鼠标提示中显示";
L["OPTIONS_POPOUT_DESC"] = "在物品鼠标提示下方的单独提示中显示数量，而不是添加到物品提示中。";
