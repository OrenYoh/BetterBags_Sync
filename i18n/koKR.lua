if(GetLocale() ~= 'koKR') then
    return
end

local _, ns = ...
local L = ns.L

L["BAGS"] = "가방";
L["BANK"] = "은행";
L["WARBAND_BANK"] = "전투부대 은행";
L["TOTAL"] = "합계";
L["SLASH_HELP"] = "명령어: /bbsync gold, /bbsync list, /bbsync remove <이름-서버 또는 길드-서버>";
L["SLASH_LIST"] = "알려진 캐릭터:";
L["SLASH_REMOVED"] = "_name_ 삭제됨.";
L["SLASH_UNKNOWN"] = "_name_(이)라는 캐릭터가 없습니다.";
L["SLASH_CURRENT"] = "플레이 중인 캐릭터는 삭제할 수 없습니다.";
L["EQUIPPED"] = "착용 중";
L["MAIL"] = "우편";
L["TITLE"] = "Sync";
L["OPTIONS_GROUP_CHARACTERS"] = "캐릭터";
L["OPTIONS_GROUP_TOOLTIP"] = "툴팁";
L["OPTIONS_GROUP_TYPES"] = "툴팁 종류";
L["OPTIONS_TYPE_GEAR"] = "장비";
L["OPTIONS_TYPE_REAGENTS"] = "제작 재료";
L["OPTIONS_TYPE_MISC"] = "기타 아이템";
L["OPTIONS_TYPE_CURRENCIES"] = "화폐";
L["OPTIONS_TYPE_GOLD"] = "골드";
L["OPTIONS_SHOW_CURRENT"] = "플레이 중인 캐릭터 표시";
L["OPTIONS_SHOW_GUILDS"] = "길드 은행 표시";
L["OPTIONS_FACTION"] = "진영";
L["OPTIONS_FACTION_ALL"] = "모든 진영";
L["OPTIONS_FACTION_SAME"] = "내 진영만";
L["OPTIONS_REALMS"] = "서버";
L["OPTIONS_REALMS_ALL"] = "모든 서버";
L["OPTIONS_REALMS_CONNECTED"] = "연결된 서버";
L["OPTIONS_REALMS_CURRENT"] = "내 서버만";
L["VOID"] = "공허 보관소";
L["GOLD_TITLE"] = "골드:";
L["POPOUT_TITLE"] = "BetterBags - Sync";
L["OPTIONS_MODIFIER"] = "누르고 있을 때만 표시";
L["OPTIONS_MODIFIER_NONE"] = "항상 표시";
L["OPTIONS_MODIFIER_SHIFT"] = "Shift";
L["OPTIONS_MODIFIER_CTRL"] = "Ctrl";
L["OPTIONS_MODIFIER_ALT"] = "Alt";
L["OPTIONS_POPOUT"] = "별도의 툴팁에 표시";
L["OPTIONS_POPOUT_DESC"] = "수량을 아이템 툴팁에 추가하는 대신, 그 아래에 있는 별도의 툴팁에 표시합니다.";
