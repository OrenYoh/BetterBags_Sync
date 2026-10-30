if(GetLocale() ~= 'ptBR') then
    return
end

local _, ns = ...
local L = ns.L

L["BAGS"] = "Bolsas";
L["BANK"] = "Banco";
L["WARBAND_BANK"] = "Banco do Bando de Guerra";
L["TOTAL"] = "Total";
L["SLASH_HELP"] = "Comandos: /bbsync gold, /bbsync list, /bbsync remove <Nome-Reino ou Guilda-Reino>";
L["SLASH_LIST"] = "Personagens conhecidos:";
L["SLASH_REMOVED"] = "_name_ removido.";
L["SLASH_UNKNOWN"] = "Nenhum personagem chamado _name_.";
L["SLASH_CURRENT"] = "Você não pode remover o personagem com que está jogando.";
L["EQUIPPED"] = "Equipado";
L["MAIL"] = "Correio";
L["TITLE"] = "Sync";
L["OPTIONS_GROUP_CHARACTERS"] = "Personagens";
L["OPTIONS_GROUP_TOOLTIP"] = "Dica";
L["OPTIONS_GROUP_TYPES"] = "Tipos de dica";
L["OPTIONS_TYPE_GEAR"] = "Equipamento";
L["OPTIONS_TYPE_REAGENTS"] = "Reagentes de criação";
L["OPTIONS_TYPE_MISC"] = "Outros itens";
L["OPTIONS_TYPE_CURRENCIES"] = "Moedas";
L["OPTIONS_TYPE_GOLD"] = "Ouro";
L["OPTIONS_SHOW_CURRENT"] = "Mostrar o personagem com que você está jogando";
L["OPTIONS_SHOW_GUILDS"] = "Mostrar bancos de guilda";
L["OPTIONS_FACTION"] = "Facções";
L["OPTIONS_FACTION_ALL"] = "Todas as facções";
L["OPTIONS_FACTION_SAME"] = "Somente sua facção";
L["OPTIONS_REALMS"] = "Reinos";
L["OPTIONS_REALMS_ALL"] = "Todos os reinos";
L["OPTIONS_REALMS_CONNECTED"] = "Reinos conectados";
L["OPTIONS_REALMS_CURRENT"] = "Somente seu reino";
L["VOID"] = "Cofre Etéreo";
L["GOLD_TITLE"] = "Ouro:";
L["POPOUT_TITLE"] = "BetterBags - Sync";
L["OPTIONS_MODIFIER"] = "Mostrar somente segurando";
L["OPTIONS_MODIFIER_NONE"] = "Sempre mostrar";
L["OPTIONS_MODIFIER_SHIFT"] = "Shift";
L["OPTIONS_MODIFIER_CTRL"] = "Ctrl";
L["OPTIONS_MODIFIER_ALT"] = "Alt";
L["OPTIONS_POPOUT"] = "Mostrar em uma dica separada";
L["OPTIONS_POPOUT_DESC"] = "Mostra as quantidades em uma dica própria, abaixo da do item, em vez de adicioná-las a ela.";
