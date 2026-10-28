if(GetLocale() ~= 'frFR') then
    return
end

local _, ns = ...
local L = ns.L

L["BAGS"] = "Sacs";
L["BANK"] = "Banque";
L["WARBAND_BANK"] = "Banque de bataillon";
L["TOTAL"] = "Total";
L["SLASH_HELP"] = "Commandes : /bbsync gold, /bbsync list, /bbsync remove <Nom-Royaume ou Guilde-Royaume>";
L["SLASH_LIST"] = "Personnages connus :";
L["SLASH_REMOVED"] = "_name_ supprimé.";
L["SLASH_UNKNOWN"] = "Aucun personnage nommé _name_.";
L["SLASH_CURRENT"] = "Impossible de supprimer le personnage que vous jouez.";
L["EQUIPPED"] = "Équipé";
L["MAIL"] = "Courrier";
L["TITLE"] = "Sync";
L["OPTIONS_DESC"] = "Choisissez les personnages et les guildes listés dans les infobulles des objets.";
L["OPTIONS_SHOW_CURRENT"] = "Afficher le personnage joué";
L["OPTIONS_SHOW_GUILDS"] = "Afficher les banques de guilde";
L["OPTIONS_FACTION"] = "Factions";
L["OPTIONS_FACTION_ALL"] = "Toutes les factions";
L["OPTIONS_FACTION_SAME"] = "Votre faction uniquement";
L["OPTIONS_REALMS"] = "Royaumes";
L["OPTIONS_REALMS_ALL"] = "Tous les royaumes";
L["OPTIONS_REALMS_CONNECTED"] = "Royaumes connectés";
L["OPTIONS_REALMS_CURRENT"] = "Votre royaume uniquement";
L["VOID"] = "Chambre du Vide";
L["GOLD_TITLE"] = "Or :";
L["POPOUT_TITLE"] = "BetterBags - Sync";
L["OPTIONS_MODIFIER"] = "Afficher seulement en maintenant";
L["OPTIONS_MODIFIER_NONE"] = "Toujours afficher";
L["OPTIONS_MODIFIER_SHIFT"] = "Maj";
L["OPTIONS_MODIFIER_CTRL"] = "Ctrl";
L["OPTIONS_MODIFIER_ALT"] = "Alt";
L["OPTIONS_POPOUT"] = "Afficher dans une infobulle séparée";
L["OPTIONS_POPOUT_DESC"] = "Affiche les quantités dans leur propre infobulle, sous celle de l'objet, au lieu de les y ajouter.";
