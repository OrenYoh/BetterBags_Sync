local addonName, root = ...;
local L = root.L;
local _G = _G

--- BetterBags dependencies
-----------------------------
---@class BetterBags: AceAddon
local BetterBags = LibStub('AceAddon-3.0'):GetAddon("BetterBags")
assert(BetterBags, addonName .. " requires BetterBags")
---@class Events: AceModule
local events = BetterBags:GetModule('Events')
---@class Constants: AceModule
local const = BetterBags:GetModule('Constants')
---@class Config: AceModule
local config = BetterBags:GetModule('Config')
-----------------------------

--- Saved data
-----------------------------
-- BetterBags_SyncDB = {
--     version = 1,
--     options = { faction, realms, showCurrent, showGuilds },
--     characters = { ["Name-Realm"] = {
--         name, realm, class, faction, guild (a guilds key),
--         bags = { [bagID] = counts },     -- what is in each bag and bank container
--         bagSlots = { [bagID] = itemID }, -- the bag items equipped in the bag slots
--         equip = counts,                  -- equipped gear (profession gear included)
--         mail = counts,                   -- the mailbox, and what was sent to it by your other characters
--         void = counts,                   -- void storage (clients that still have it)
--         money = copper,
--         currencies = { [currencyID] = quantity }, -- currencies held by this character only (not Warband-wide ones)
--     } },
--     guilds = { ["Guild-Realm"] = { name, realm, faction, money, tabs = { [tab] = counts } } },
--     warband = { [bagID] = counts },
--     warbandMoney = copper,
-- }
-- counts = { [itemID] = count, ["pet:<speciesID>"] = count }: a caged battle pet is counted by its species.
-- Counts are kept per bag (and per guild tab) so a read of some of them (the bank and the guild bank
-- load tab by tab) only replaces those.
local DB_VERSION = 1
local DEFAULT_OPTIONS = {
    faction = "all",    -- "all" or "same"
    realms = "all",     -- "all", "connected" or "current"
    showCurrent = true,
    showGuilds = true,
    modifier = "none",  -- "none", "shift", "ctrl" or "alt": the lines show only while it is held
    popout = false,     -- the lines in a tooltip of their own under the item's
}
local db

local function normalizeRealm(realm)
    return (realm or ""):gsub("[%s%-]", "")
end

local function currentRealm()
    return _G.GetNormalizedRealmName() or normalizeRealm(_G.GetRealmName())
end

local function currentKey()
    return _G.UnitName("player") .. "-" .. currentRealm()
end

local function currentGuildKey()
    if not _G.IsInGuild() then return nil end
    local name, _, _, realm = _G.GetGuildInfo("player")
    if not name then return nil end
    return name .. "-" .. (realm and normalizeRealm(realm) or currentRealm()), name, realm and normalizeRealm(realm) or currentRealm()
end

local function currentCharacter()
    local key = currentKey()
    local character = db.characters[key]
    if not character then
        character = {}
        db.characters[key] = character
    end
    character.bags = character.bags or {}
    character.bagSlots = character.bagSlots or {}
    character.equip = character.equip or {}
    character.mail = character.mail or {}
    character.void = character.void or {}
    character.currencies = character.currencies or {}
    character.name = _G.UnitName("player")
    character.realm = currentRealm()
    character.class = select(2, _G.UnitClass("player"))
    character.faction = _G.UnitFactionGroup("player")
    character.guild = currentGuildKey()
    return character
end

local function currentGuild()
    local key, name, realm = currentGuildKey()
    if not key then return nil end
    local guild = db.guilds[key]
    if not guild then
        guild = { tabs = {} }
        db.guilds[key] = guild
    end
    guild.name = name
    guild.realm = realm
    guild.faction = _G.UnitFactionGroup("player")
    return guild
end
-----------------------------

--- Reading items
-----------------------------
local getItemInfoInstant = _G.C_Item and _G.C_Item.GetItemInfoInstant or _G.GetItemInfoInstant

-- The key an item is counted under: its species for a caged battle pet, else its item ID.
local function keyOf(itemID, link)
    local species = link and link:match("|Hbattlepet:(%d+)")
    if species then return "pet:" .. species end
    if itemID then return itemID end
    if link then return (getItemInfoInstant(link)) end
    return nil
end

local function add(counts, key, count)
    if key then
        counts[key] = (counts[key] or 0) + (count or 1)
    end
end

-- Groups a committed slotInfo's items by bag: every slot BetterBags read is in itemsBySlotKey,
-- empty slots included, so a bag that was read is listed even when it holds nothing.
local function countByBag(slotInfo)
    local byBag = {}
    for _, item in pairs(slotInfo.itemsBySlotKey or {}) do
        local bagID = item.bagid
        if bagID then
            byBag[bagID] = byBag[bagID] or {}
            local info = item.itemInfo
            if not item.isItemEmpty and info and info.itemID then
                add(byBag[bagID], keyOf(info.itemID, info.itemLink), info.currentItemCount)
            end
        end
    end
    return byBag
end

local function isWarbandBag(bagID)
    return const.ACCOUNT_BANK_BAGS ~= nil and const.ACCOUNT_BANK_BAGS[bagID] ~= nil
end
-----------------------------

--- Bags, bank and Warband bank: what BetterBags read
-----------------------------
local function recordBackpack(_, slotInfo)
    if not db or not slotInfo then return end
    local character = currentCharacter()
    -- A backpack read always commits every backpack bag, so bags no longer read (a bag removed) go too.
    for bagID in pairs(const.BACKPACK_BAGS) do
        character.bags[bagID] = nil
    end
    for bagID, counts in pairs(countByBag(slotInfo)) do
        character.bags[bagID] = counts
    end
end

local function recordBank(_, slotInfo)
    if not db or not slotInfo then return end
    local character = currentCharacter()
    for bagID, counts in pairs(countByBag(slotInfo)) do
        if isWarbandBag(bagID) then
            db.warband[bagID] = counts
        else
            character.bags[bagID] = counts
        end
    end
end
-----------------------------

--- Guild bank: what BetterBags Next read, else read here
-----------------------------
local GUILD_SLOTS = const.GUILD_BANK_SLOTS or _G.MAX_GUILDBANK_SLOTS_PER_TAB or 98

local function recordGuildBank(_, slotInfo)
    if not db or not slotInfo or not const.GUILD_BANK_BAGS then return end
    local guild = currentGuild()
    if not guild then return end
    for container, counts in pairs(countByBag(slotInfo)) do
        local tab = const.GUILD_BANK_BAGS[container]
        if tab then guild.tabs[tab] = counts end
    end
end

-- With the classic bags BetterBags reads no guild bank (Blizzard's frame shows it, and BetterBags
-- Next's guild bank, made whatever Enable Bank Bags says, is not there), so it is read here, as
-- BagSync reads it: every tab the player can view is queried as the guild bank opens, and once the
-- server's answers settle every tab is read (the client keeps every tab it received, whichever is
-- current). Later changes read the tab shown.
local atGuildBank = false
local guildQueried = false
local guildTimer

local function nativeGuildBank()
    return not (BetterBags.Bags and BetterBags.Bags.GuildBank)
end

local function readGuildTab(guild, tab)
    local _, _, isViewable = _G.GetGuildBankTabInfo(tab)
    if not isViewable then return end
    local counts = {}
    for slot = 1, GUILD_SLOTS do
        local link = _G.GetGuildBankItemLink(tab, slot)
        if link then
            local _, count = _G.GetGuildBankItemInfo(tab, slot)
            add(counts, keyOf(nil, link), count)
        end
    end
    guild.tabs[tab] = counts
end

local function scanGuildBank()
    guildTimer = nil
    if not db or not atGuildBank or not nativeGuildBank() then return end
    local guild = currentGuild()
    if not guild then return end
    if guildQueried then
        guildQueried = false
        for tab = 1, _G.GetNumGuildBankTabs() do
            readGuildTab(guild, tab)
        end
        -- Tabs bought no longer: forget them.
        for tab in pairs(guild.tabs) do
            if tab > _G.GetNumGuildBankTabs() then guild.tabs[tab] = nil end
        end
    else
        local tab = _G.GetCurrentGuildBankTab()
        if tab then readGuildTab(guild, tab) end
    end
end

local function onGuildBankOpened()
    if atGuildBank then return end -- a client that sends both opening events
    atGuildBank = true
    if not db or not nativeGuildBank() then return end
    for tab = 1, _G.GetNumGuildBankTabs() do
        if select(3, _G.GetGuildBankTabInfo(tab)) then
            _G.QueryGuildBankTab(tab)
        end
    end
    guildQueried = true
end

local function onGuildBankClosed()
    atGuildBank = false
    guildQueried = false
    if guildTimer then
        guildTimer:Cancel()
        guildTimer = nil
    end
end

local function onGuildBankChanged()
    -- It fires once per tab answered: read once they settle.
    if guildTimer then guildTimer:Cancel() end
    guildTimer = C_Timer.NewTimer(1, scanGuildBank)
end
-----------------------------

--- Equipped gear and bags
-----------------------------
local containerToInventoryID = _G.C_Container and _G.C_Container.ContainerIDToInventoryID or _G.ContainerIDToInventoryID

local function scanEquipment()
    if not db then return end
    local character = currentCharacter()
    local counts = {}
    for slot = _G.INVSLOT_FIRST_EQUIPPED or 1, _G.INVSLOT_LAST_EQUIPPED or 19 do
        local itemID = _G.GetInventoryItemID("player", slot)
        if itemID then
            add(counts, itemID, _G.GetInventoryItemCount("player", slot))
        end
    end
    -- Profession gear (retail): the slots are 0-based, as BagSync and Blizzard's tutorial read them.
    if _G.C_TradeSkillUI and _G.C_TradeSkillUI.GetProfessionInventorySlots then
        for _, slot in ipairs(_G.C_TradeSkillUI.GetProfessionInventorySlots() or {}) do
            local itemID = _G.GetInventoryItemID("player", slot + 1)
            if itemID then add(counts, itemID, 1) end
        end
    end
    character.equip = counts
end

local function scanBagSlots(list)
    local character = currentCharacter()
    for _, bagID in ipairs(list or {}) do
        local invID = containerToInventoryID and containerToInventoryID(bagID)
        character.bagSlots[bagID] = invID and _G.GetInventoryItemID("player", invID) or nil
    end
end

local function scanBackpackSlots()
    if not db then return end
    scanBagSlots(const.BACKPACK_ONLY_BAGS_LIST)
end

-- Classic banks have bag slots; retail's bank tabs are not items.
local function scanBankSlots()
    if not db or BetterBags.isRetail or not BetterBags.atBank then return end
    scanBagSlots(const.BANK_ONLY_BAGS_LIST)
end
-----------------------------

--- Mailbox
-----------------------------
local atMailbox = false
local mailTimer
local pendingMail

local function scanMailbox()
    mailTimer = nil
    if not db or not atMailbox then return end
    local counts = {}
    for mail = 1, _G.GetInboxNumItems() do
        for attachment = 1, _G.ATTACHMENTS_MAX_RECEIVE or 16 do
            local name, itemID, _, count, _, _, isCurrency = _G.GetInboxItem(mail, attachment)
            if name and not isCurrency then
                add(counts, keyOf(itemID, _G.GetInboxItemLink(mail, attachment)), count)
            end
        end
    end
    currentCharacter().mail = counts
end

-- Remembers what a mail carries as it is sent; it is added to the recipient's mailbox (one of your
-- characters) once the server says it was sent.
local function onSendMail(recipient)
    pendingMail = nil
    if not db or not recipient or recipient == "" then return end
    local name, realm = strtrim(recipient):match("^([^%-]+)%-?(.*)$")
    if not name then return end
    local key = name .. "-" .. (realm ~= "" and normalizeRealm(realm) or currentRealm())
    local items = {}
    for i = 1, _G.ATTACHMENTS_MAX_SEND or 12 do
        local _, itemID, _, count = _G.GetSendMailItem(i)
        if itemID then
            table.insert(items, { key = keyOf(itemID, _G.GetSendMailItemLink(i)), count = count })
        end
    end
    if #items > 0 then pendingMail = { key = key, items = items } end
end

local function onMailSent()
    local sent = pendingMail
    pendingMail = nil
    if not db or not sent then return end
    local character = db.characters[sent.key]
    if not character or sent.key == currentKey() then return end
    character.mail = character.mail or {}
    for _, item in ipairs(sent.items) do
        add(character.mail, item.key, item.count)
    end
end
-----------------------------

--- Void storage (Cata and Mists Classic: removed from retail)
-----------------------------
local VOID_PAGES = _G.VOID_STORAGE_PAGES or 2
local VOID_SLOTS = _G.VOID_STORAGE_MAX or 80
local atVoidStorage = false

local function scanVoidStorage()
    if not db or not atVoidStorage or not _G.GetVoidItemInfo then return end
    if _G.CanUseVoidStorage and not _G.CanUseVoidStorage() then return end
    local counts = {}
    for page = 1, VOID_PAGES do
        for slot = 1, VOID_SLOTS do
            -- Its first return is the item ID (warcraft.wiki.gg GetVoidItemInfo); void storage holds no stacks.
            local itemID = _G.GetVoidItemInfo(page, slot)
            if itemID then add(counts, itemID, 1) end
        end
    end
    currentCharacter().void = counts
end
-----------------------------

--- Gold
-----------------------------
local function scanMoney()
    if not db then return end
    currentCharacter().money = _G.GetMoney()
    if _G.C_Bank and _G.C_Bank.FetchDepositedMoney and _G.Enum.BankType and BetterBags.hasWarbank then
        db.warbandMoney = _G.C_Bank.FetchDepositedMoney(_G.Enum.BankType.Account)
    end
end

local function scanGuildMoney()
    if not db or not atGuildBank or not _G.GetGuildBankMoney then return end
    local guild = currentGuild()
    if guild then guild.money = _G.GetGuildBankMoney() end
end
-----------------------------

--- Currencies
-----------------------------
local currencyModule = BetterBags:GetModule('Currencies')
local currencyTimer

local function isAccountWide(currencyID)
    local info = _G.C_CurrencyInfo and _G.C_CurrencyInfo.GetCurrencyInfo and _G.C_CurrencyInfo.GetCurrencyInfo(currencyID)
    return info ~= nil and info.isAccountWide == true
end

-- Reads every currency of Blizzard's currency list through BetterBags (which opens the headings the player
-- keeps collapsed and closes them again). Not in combat: the list's headings are Blizzard's UI state, which
-- BagSync also leaves alone in combat.
local function scanCurrencies()
    currencyTimer = nil
    if not db or not currencyModule:Available() then return end
    if _G.InCombatLockdown() then return end -- PLAYER_REGEN_ENABLED reads it again
    if currencyModule:ListSize() == 0 then return end -- the list has not loaded yet: keep what was saved
    local quantities = {}
    for _, entry in ipairs(currencyModule:List()) do
        if entry.id and entry.quantity > 0 and not isAccountWide(entry.id) then
            quantities[entry.id] = entry.quantity
        end
    end
    currentCharacter().currencies = quantities
end

local function queueCurrencyScan()
    -- It fires in bursts (every loot, every login step): read once it settles.
    if currencyTimer then currencyTimer:Cancel() end
    currencyTimer = C_Timer.NewTimer(1, scanCurrencies)
end
-----------------------------

--- Which characters and guilds show
-----------------------------
local connectedRealms

local function realmSet()
    if connectedRealms then return connectedRealms end
    connectedRealms = { [normalizeRealm(currentRealm()):lower()] = true }
    local getRealms = _G.C_AutoComplete and _G.C_AutoComplete.GetAutoCompleteRealms or _G.GetAutoCompleteRealms
    for _, realm in ipairs(getRealms and getRealms() or {}) do
        connectedRealms[normalizeRealm(realm):lower()] = true
    end
    return connectedRealms
end

local function realmShown(realm)
    local mode = db.options.realms
    if mode == "current" then
        return realm == currentRealm()
    elseif mode == "connected" then
        return realmSet()[normalizeRealm(realm):lower()] == true
    end
    return true
end

local function factionShown(faction)
    return db.options.faction ~= "same" or faction == _G.UnitFactionGroup("player")
end
-----------------------------

--- Tooltips
-----------------------------
local function classColor(class)
    local color = class and _G.C_ClassColor and _G.C_ClassColor.GetClassColor(class)
        or class and _G.RAID_CLASS_COLORS and _G.RAID_CLASS_COLORS[class]
    if color then return color.r, color.g, color.b end
    return 1, 1, 1
end

local function sumBags(bags, key, inBank)
    local total = 0
    for bagID, counts in pairs(bags or {}) do
        if inBank == nil or inBank == (const.BACKPACK_BAGS[bagID] == nil) then
            total = total + (counts[key] or 0)
        end
    end
    return total
end

local function sumBagSlots(bagSlots, key, inBank)
    local total = 0
    for bagID, itemID in pairs(bagSlots or {}) do
        if itemID == key and inBank == (const.BACKPACK_BAGS[bagID] == nil) then
            total = total + 1
        end
    end
    return total
end

local function displayName(name, realm)
    if realm and realm ~= currentRealm() then
        return name .. "-" .. realm
    end
    return name
end

-- Every line for an item: { text, count, detail, r, g, b }, characters by count, then guilds, the
-- Warband bank and the total.
-- The options' filters: the current character as Show the Character You Are Playing says, the others by
-- their realm and faction.
local function characterShown(characterKey, character)
    if characterKey == currentKey() then
        return db.options.showCurrent
    end
    return realmShown(character.realm) and factionShown(character.faction)
end

local function sortRows(rows)
    table.sort(rows, function(a, c)
        if a.count ~= c.count then return a.count > c.count end
        return a.text < c.text
    end)
end

local function linesFor(key)
    local rows = {}
    local total = 0
    for characterKey, character in pairs(db.characters) do
        if characterShown(characterKey, character) then
            local places = {
                { L["BAGS"], sumBags(character.bags, key, false) + sumBagSlots(character.bagSlots, key, false) },
                { L["BANK"], sumBags(character.bags, key, true) + sumBagSlots(character.bagSlots, key, true) },
                { L["EQUIPPED"], character.equip and character.equip[key] or 0 },
                { L["MAIL"], character.mail and character.mail[key] or 0 },
                { L["VOID"], character.void and character.void[key] or 0 },
            }
            local count, parts = 0, {}
            for _, place in ipairs(places) do
                if place[2] > 0 then
                    count = count + place[2]
                    table.insert(parts, place[1] .. ": " .. place[2])
                end
            end
            if count > 0 then
                local r, g, b = classColor(character.class)
                table.insert(rows, { text = displayName(character.name or "?", character.realm), count = count, detail = table.concat(parts, ", "), r = r, g = g, b = b })
                total = total + count
            end
        end
    end
    sortRows(rows)

    if db.options.showGuilds then
        local guildRows = {}
        for _, guild in pairs(db.guilds) do
            if realmShown(guild.realm) and factionShown(guild.faction) then
                local count = sumBags(guild.tabs, key)
                if count > 0 then
                    table.insert(guildRows, { text = "<" .. displayName(guild.name or "?", guild.realm) .. ">", count = count, r = 0.25, g = 1, b = 0.25 })
                    total = total + count
                end
            end
        end
        table.sort(guildRows, function(a, c) return a.text < c.text end)
        for _, row in ipairs(guildRows) do table.insert(rows, row) end
    end

    local inWarband = sumBags(db.warband, key)
    if inWarband > 0 then
        table.insert(rows, { text = L["WARBAND_BANK"], count = inWarband, r = 0, g = 0.8, b = 1 })
        total = total + inWarband
    end
    if #rows > 1 then
        table.insert(rows, { text = L["TOTAL"], count = total, r = 1, g = 0.82, b = 0 })
    end
    return rows
end

local function isSecret(value)
    return _G.issecretvalue ~= nil and _G.issecretvalue(value)
end

local function formatCount(count)
    return _G.BreakUpLargeNumbers and _G.BreakUpLargeNumbers(count) or tostring(count)
end

-- Currency rows: every character holding it, the most first, and the total. Warband-wide currencies are
-- the same for every character, so they are never saved (scanCurrencies).
local function currencyRows(currencyID)
    local rows, total = {}, 0
    for characterKey, character in pairs(db.characters) do
        local count = character.currencies and character.currencies[currencyID] or 0
        if count > 0 and characterShown(characterKey, character) then
            local r, g, b = classColor(character.class)
            table.insert(rows, { text = displayName(character.name or "?", character.realm), count = count, r = r, g = g, b = b })
            total = total + count
        end
    end
    sortRows(rows)
    if #rows > 1 then
        table.insert(rows, { text = L["TOTAL"], count = total, r = 1, g = 0.82, b = 0 })
    end
    return rows
end

-- An entry is what a tooltip shows: { kind = "item" | "pet" | "currency", id, single, added }. single:
-- the tooltip takes one text per line (Blizzard's battle pet tooltips, BattlePetTooltipTemplate_AddTextLine).
local function rowsFor(entry)
    if entry.kind == "currency" then return currencyRows(entry.id) end
    return linesFor(entry.id)
end

local function writeRows(target, rows, single)
    for _, row in ipairs(rows) do
        local right = row.detail and (formatCount(row.count) .. " (" .. row.detail .. ")") or formatCount(row.count)
        if single then
            target:AddLine(row.text .. ": " .. right, row.r, row.g, row.b)
        else
            target:AddDoubleLine(row.text, right, row.r, row.g, row.b, 1, 1, 1)
        end
    end
end

--- The modifier and the pop-out
-----------------------------
local function modifierHeld()
    local modifier = db.options.modifier
    if modifier == "shift" then return _G.IsShiftKeyDown() end
    if modifier == "ctrl" then return _G.IsControlKeyDown() end
    if modifier == "alt" then return _G.IsAltKeyDown() end
    return true
end

-- The pop-out: a tooltip of its own under the one it belongs to, kept on the screen.
local popout

local function hidePopout(owner)
    if popout and (owner == nil or popout.syncOwner == owner) then
        popout.syncOwner = nil
        popout:Hide()
    end
end

local function showPopout(owner, rows)
    if not popout then
        popout = CreateFrame("GameTooltip", "BetterBagsSyncTooltip", UIParent, "GameTooltipTemplate")
        popout:SetClampedToScreen(true)
        popout:SetFrameStrata("TOOLTIP")
    end
    popout:SetOwner(owner, "ANCHOR_NONE")
    popout:ClearAllPoints()
    popout:SetPoint("TOPLEFT", owner, "BOTTOMLEFT", 0, -2)
    popout:AddLine(L["POPOUT_TITLE"], 1, 0.82, 0)
    writeRows(popout, rows, false)
    popout.syncOwner = owner
    popout:Show()
end

-- What each shown tooltip shows, so a modifier pressed or released while it shows can update it.
local entries = setmetatable({}, { __mode = "k" })
local watched = setmetatable({}, { __mode = "k" })

local function forget(tooltip)
    entries[tooltip] = nil
    hidePopout(tooltip)
end

-- A tooltip cleared for something else (OnTooltipCleared, GameTooltips only) or hidden forgets its entry.
local function watch(tooltip)
    if watched[tooltip] then return end
    watched[tooltip] = true
    tooltip:HookScript("OnHide", forget)
    if tooltip:HasScript("OnTooltipCleared") then
        tooltip:HookScript("OnTooltipCleared", forget)
    end
end

local function render(tooltip, entry)
    entries[tooltip] = entry
    watch(tooltip)
    local rows = modifierHeld() and rowsFor(entry) or {}
    if #rows == 0 then
        hidePopout(tooltip)
        return
    end
    if db.options.popout then
        showPopout(tooltip, rows)
    elseif not entry.added then
        entry.added = true
        if not entry.single then tooltip:AddLine(" ") end
        writeRows(tooltip, rows, entry.single)
        -- A GameTooltip already shown is resized by showing it again; a pet tooltip resizes itself.
        if entry.resize and not entry.single then tooltip:Show() end
    end
end

-- An addon reading an item's text (Pawn, TipTac...) sets it on a hidden tooltip of its own, owned with
-- ANCHOR_NONE and never placed; were it shown to, the pop-out would follow it off the screen.
local function isScanner(tooltip)
    return tooltip.GetAnchorType ~= nil and tooltip:GetAnchorType() == "ANCHOR_NONE" and tooltip:GetNumPoints() == 0
end

local function show(tooltip, kind, id, resize)
    if not db or not tooltip or not id or isSecret(id) or isScanner(tooltip) then return end
    render(tooltip, { kind = kind, id = id, single = tooltip.AddDoubleLine == nil, resize = resize })
end

-- A modifier pressed or released: the pop-out follows it; inline lines are added, or taken off by rebuilding
-- the tooltip where the client can (GameTooltipDataMixin:RefreshData, retail and WoW: Forever, which runs our
-- hooks again). Elsewhere the lines stay until the tooltip is drawn again.
local function onModifierChanged()
    if not db or db.options.modifier == "none" then return end
    local shown = {}
    for tooltip, entry in pairs(entries) do
        if tooltip:IsShown() then table.insert(shown, { tooltip = tooltip, entry = entry }) end
    end
    for _, item in ipairs(shown) do
        local tooltip, entry = item.tooltip, item.entry
        if db.options.popout then
            render(tooltip, entry)
        elseif modifierHeld() then
            entry.resize = true
            render(tooltip, entry)
        elseif entry.added and tooltip.RefreshData then
            tooltip:RefreshData()
        end
    end
end
-----------------------------

--- Hooking the tooltips
-----------------------------
local function isComparison(tooltip)
    return tooltip == _G.ShoppingTooltip1 or tooltip == _G.ShoppingTooltip2
        or tooltip == _G.ItemRefShoppingTooltip1 or tooltip == _G.ItemRefShoppingTooltip2
end

local function currencyIDFromLink(link)
    return link and tonumber(link:match("currency:(%d+)"))
end

-- Clients without TooltipDataProcessor (older Classic builds): the GameTooltip setters a currency goes
-- through, from the Currency tab (by list index), the backpack's tokens and links (by ID).
local function hookClassicCurrencyTooltip(tooltip)
    if not tooltip then return end
    if tooltip.SetCurrencyToken then
        hooksecurefunc(tooltip, "SetCurrencyToken", function(self, index)
            local getLink = _G.C_CurrencyInfo and _G.C_CurrencyInfo.GetCurrencyListLink or _G.GetCurrencyListLink
            show(self, "currency", currencyIDFromLink(getLink and getLink(index)), true)
        end)
    end
    if tooltip.SetCurrencyByID then
        hooksecurefunc(tooltip, "SetCurrencyByID", function(self, id) show(self, "currency", id, true) end)
    end
    if tooltip.SetBackpackToken then
        hooksecurefunc(tooltip, "SetBackpackToken", function(self, index)
            local id
            if _G.C_CurrencyInfo and _G.C_CurrencyInfo.GetBackpackCurrencyInfo then
                local info = _G.C_CurrencyInfo.GetBackpackCurrencyInfo(index)
                id = info and info.currencyTypesID
            elseif _G.GetBackpackCurrencyInfo then
                id = select(4, _G.GetBackpackCurrencyInfo(index))
            end
            show(self, "currency", id, true)
        end)
    end
end

local function hookTooltips()
    local types = _G.TooltipDataProcessor and _G.Enum.TooltipDataType
    if types and types.Currency then
        -- Retail and WoW: Forever: every currency tooltip (the Currency tab, links, rewards...).
        _G.TooltipDataProcessor.AddTooltipPostCall(types.Currency, function(tooltip, data)
            if data and tooltip.AddDoubleLine then show(tooltip, "currency", data.id) end
        end)
    else
        hookClassicCurrencyTooltip(_G.GameTooltip)
        hookClassicCurrencyTooltip(_G.ItemRefTooltip)
    end
    if types then
        -- Retail and WoW: Forever: every item tooltip, wherever it is shown, but the comparisons with what is worn.
        _G.TooltipDataProcessor.AddTooltipPostCall(types.Item, function(tooltip, data)
            if data and tooltip.AddDoubleLine and not isComparison(tooltip) then
                show(tooltip, "item", data.id)
            end
        end)
    else
        -- Classic: GameTooltip and the chat link tooltip.
        local function onSetItem(tooltip)
            local _, link = tooltip:GetItem()
            if link then show(tooltip, "item", (getItemInfoInstant(link))) end
        end
        for _, tooltip in ipairs({ _G.GameTooltip, _G.ItemRefTooltip }) do
            if tooltip then tooltip:HookScript("OnTooltipSetItem", onSetItem) end
        end
    end
    -- Caged battle pets (in the bags, and from a chat link).
    if _G.BattlePetToolTip_Show then
        hooksecurefunc("BattlePetToolTip_Show", function(speciesID)
            if speciesID then show(_G.BattlePetTooltip, "pet", "pet:" .. speciesID) end
        end)
    end
    if _G.FloatingBattlePet_Show then
        hooksecurefunc("FloatingBattlePet_Show", function(speciesID)
            if speciesID then show(_G.FloatingBattlePetTooltip, "pet", "pet:" .. speciesID) end
        end)
    end
end
-----------------------------

--- Options (BetterBags' settings window, Integrations)
-----------------------------
local options = {
    description = {
        type = "description",
        order = 1,
        name = L["OPTIONS_DESC"],
    },
    showCurrent = {
        type = "toggle",
        order = 2,
        width = "full",
        name = L["OPTIONS_SHOW_CURRENT"],
        get = function() return db.options.showCurrent end,
        set = function(_, value) db.options.showCurrent = value end,
    },
    showGuilds = {
        type = "toggle",
        order = 3,
        width = "full",
        name = L["OPTIONS_SHOW_GUILDS"],
        get = function() return db.options.showGuilds end,
        set = function(_, value) db.options.showGuilds = value end,
    },
    faction = {
        type = "select",
        order = 4,
        name = L["OPTIONS_FACTION"],
        values = { all = L["OPTIONS_FACTION_ALL"], same = L["OPTIONS_FACTION_SAME"] },
        sorting = { "all", "same" },
        get = function() return db.options.faction end,
        set = function(_, value) db.options.faction = value end,
    },
    realms = {
        type = "select",
        order = 5,
        name = L["OPTIONS_REALMS"],
        values = { all = L["OPTIONS_REALMS_ALL"], connected = L["OPTIONS_REALMS_CONNECTED"], current = L["OPTIONS_REALMS_CURRENT"] },
        sorting = { "all", "connected", "current" },
        get = function() return db.options.realms end,
        set = function(_, value) db.options.realms = value end,
    },
    modifier = {
        type = "select",
        order = 6,
        name = L["OPTIONS_MODIFIER"],
        values = { none = L["OPTIONS_MODIFIER_NONE"], shift = L["OPTIONS_MODIFIER_SHIFT"], ctrl = L["OPTIONS_MODIFIER_CTRL"], alt = L["OPTIONS_MODIFIER_ALT"] },
        sorting = { "none", "shift", "ctrl", "alt" },
        get = function() return db.options.modifier end,
        set = function(_, value) db.options.modifier = value end,
    },
    popout = {
        type = "toggle",
        order = 7,
        width = "full",
        name = L["OPTIONS_POPOUT"],
        desc = L["OPTIONS_POPOUT_DESC"],
        get = function() return db.options.popout end,
        set = function(_, value)
            db.options.popout = value
            hidePopout()
        end,
    },
}
-----------------------------

--- Slash command
-----------------------------
local function coins(copper)
    local format = _G.C_CurrencyInfo and _G.C_CurrencyInfo.GetCoinTextureString or _G.GetCoinTextureString
    return format and format(copper) or tostring(copper)
end

-- Every character's gold (as the options filter them), the most first, then the guilds' and the
-- Warband bank's, and the total: { text, count }.
local function goldRows()
    local rows, total = {}, 0
    for characterKey, character in pairs(db.characters) do
        if (character.money or 0) > 0 and characterShown(characterKey, character) then
            local r, g, b = classColor(character.class)
            local color = string.format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
            table.insert(rows, { text = color .. displayName(character.name or "?", character.realm) .. "|r", sort = character.name or "", count = character.money })
            total = total + character.money
        end
    end
    table.sort(rows, function(a, c)
        if a.count ~= c.count then return a.count > c.count end
        return a.sort < c.sort
    end)
    if db.options.showGuilds then
        for _, guild in pairs(db.guilds) do
            if (guild.money or 0) > 0 and realmShown(guild.realm) and factionShown(guild.faction) then
                table.insert(rows, { text = "|cff40ff40<" .. displayName(guild.name or "?", guild.realm) .. ">|r", count = guild.money })
                total = total + guild.money
            end
        end
    end
    if (db.warbandMoney or 0) > 0 then
        table.insert(rows, { text = "|cff00ccff" .. L["WARBAND_BANK"] .. "|r", count = db.warbandMoney })
        total = total + db.warbandMoney
    end
    table.insert(rows, { text = "|cffffd100" .. L["TOTAL"] .. "|r", count = total })
    return rows
end

local function printGold()
    print(L["GOLD_TITLE"])
    for _, row in ipairs(goldRows()) do print("  " .. row.text .. ": " .. coins(row.count)) end
end

-- BetterBags' money frames (the backpack's and the bank's, in both bag designs) show everyone's gold under
-- their own tooltip. Every frame is updated as it is made and as the world loads (frames/money.lua), so
-- each one is found there, those made before this addon loaded included.
local moneyFrames = setmetatable({}, { __mode = "k" })

local function showGold(overlay)
    if not db or not GameTooltip:IsOwned(overlay) then return end
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(L["GOLD_TITLE"], 1, 0.82, 0)
    for _, row in ipairs(goldRows()) do
        GameTooltip:AddDoubleLine(row.text, coins(row.count), 1, 1, 1, 1, 1, 1)
    end
    GameTooltip:Show()
end

local function hookMoneyFrames()
    local money = BetterBags:GetModule('MoneyFrame', true)
    if not money or not money.moneyProto or not money.moneyProto.Update then return end
    hooksecurefunc(money.moneyProto, "Update", function(m)
        if not m.overlay or moneyFrames[m.overlay] then return end
        moneyFrames[m.overlay] = true
        m.overlay:HookScript("OnEnter", showGold)
    end)
end

local function slash(input)
    local command, rest = strtrim(input or ""):match("^(%S*)%s*(.-)$")
    command = command:lower()
    if command == "gold" then
        printGold()
    elseif command == "list" then
        print(L["SLASH_LIST"])
        for key in pairs(db.characters) do print("  " .. key) end
        for key in pairs(db.guilds) do print("  <" .. key .. ">") end
    elseif command == "remove" and rest ~= "" then
        if rest == currentKey() then
            print(L["SLASH_CURRENT"])
        elseif db.characters[rest] then
            db.characters[rest] = nil
            print((L["SLASH_REMOVED"]:gsub("_name_", rest)))
        elseif db.guilds[rest] then
            db.guilds[rest] = nil
            print((L["SLASH_REMOVED"]:gsub("_name_", rest)))
        else
            print((L["SLASH_UNKNOWN"]:gsub("_name_", rest)))
        end
    else
        print(L["SLASH_HELP"])
    end
end
-----------------------------

--- Addon core
-----------------------------
local eventFrame = CreateFrame("Frame")
local handlers = {}

local function on(event, handler)
    if _G.C_EventUtils and _G.C_EventUtils.IsEventValid and not _G.C_EventUtils.IsEventValid(event) then return end
    -- A client without C_EventUtils raises for an event it does not have: that event is skipped.
    if pcall(eventFrame.RegisterEvent, eventFrame, event) then
        handlers[event] = handler
    end
end

local function onReady()
    if type(BetterBags_SyncDB) ~= "table" or BetterBags_SyncDB.version ~= DB_VERSION then
        BetterBags_SyncDB = { version = DB_VERSION }
    end
    db = BetterBags_SyncDB
    db.characters = db.characters or {}
    db.guilds = db.guilds or {}
    db.warband = db.warband or {}
    db.options = db.options or {}
    for key, value in pairs(DEFAULT_OPTIONS) do
        if db.options[key] == nil then db.options[key] = value end
    end

    events:RegisterMessage('items/RefreshBackpack/Done', recordBackpack)
    events:RegisterMessage('items/RefreshBank/Done', recordBank)
    events:RegisterMessage('items/RefreshGuildBank/Done', recordGuildBank)

    on("PLAYER_ENTERING_WORLD", function() scanEquipment(); scanBackpackSlots(); scanMoney(); queueCurrencyScan() end)
    on("PLAYER_EQUIPMENT_CHANGED", function() scanEquipment(); scanBackpackSlots() end)
    on("BAG_CONTAINER_UPDATE", function() scanBackpackSlots(); scanBankSlots() end)
    on("BANKFRAME_OPENED", scanBankSlots)
    on("PLAYERBANKSLOTS_CHANGED", scanBankSlots)
    -- The guild bank opens through the player interaction manager on retail and WoW: Forever, through
    -- GUILDBANKFRAME_OPENED on Classic clients (as BetterBags' own guild bank module listens).
    local guildBanker = _G.Enum.PlayerInteractionType and _G.Enum.PlayerInteractionType.GuildBanker
    if guildBanker then
        on("PLAYER_INTERACTION_MANAGER_FRAME_SHOW", function(interaction)
            if interaction == guildBanker then onGuildBankOpened() end
        end)
        on("PLAYER_INTERACTION_MANAGER_FRAME_HIDE", function(interaction)
            if interaction == guildBanker then onGuildBankClosed() end
        end)
    end
    on("GUILDBANKFRAME_OPENED", onGuildBankOpened)
    on("GUILDBANKFRAME_CLOSED", onGuildBankClosed)
    on("GUILDBANKBAGSLOTS_CHANGED", onGuildBankChanged)
    on("MAIL_SHOW", function() atMailbox = true end)
    on("MAIL_CLOSED", function() atMailbox = false end)
    on("MAIL_INBOX_UPDATE", function()
        -- It fires in bursts as the inbox loads: read once it settles.
        if mailTimer then mailTimer:Cancel() end
        mailTimer = C_Timer.NewTimer(0.3, scanMailbox)
    end)
    on("MAIL_SEND_SUCCESS", onMailSent)

    on("MODIFIER_STATE_CHANGED", onModifierChanged)

    on("PLAYER_MONEY", scanMoney)
    on("ACCOUNT_MONEY", scanMoney)
    on("GUILDBANK_UPDATE_MONEY", scanGuildMoney)

    on("CURRENCY_DISPLAY_UPDATE", queueCurrencyScan)
    on("PLAYER_REGEN_ENABLED", function()
        -- A scan that came due in combat waited for it to end.
        if not currencyTimer then queueCurrencyScan() end
    end)

    -- Void storage opens through the player interaction manager, or its own events on older clients.
    local voidBanker = _G.Enum.PlayerInteractionType and _G.Enum.PlayerInteractionType.VoidStorageBanker
    if _G.GetVoidItemInfo then
        local function openVoid() atVoidStorage = true; scanVoidStorage() end
        local function closeVoid() atVoidStorage = false end
        if voidBanker then
            on("PLAYER_INTERACTION_MANAGER_FRAME_SHOW", function(interaction)
                if interaction == guildBanker then onGuildBankOpened()
                elseif interaction == voidBanker then openVoid() end
            end)
            on("PLAYER_INTERACTION_MANAGER_FRAME_HIDE", function(interaction)
                if interaction == guildBanker then onGuildBankClosed()
                elseif interaction == voidBanker then closeVoid() end
            end)
        end
        on("VOID_STORAGE_OPEN", openVoid)
        on("VOID_STORAGE_CLOSE", closeVoid)
        on("VOID_STORAGE_UPDATE", scanVoidStorage)
        on("VOID_STORAGE_CONTENTS_UPDATE", scanVoidStorage)
        on("VOID_TRANSFER_DONE", scanVoidStorage)
    end
    if _G.SendMail then hooksecurefunc("SendMail", onSendMail) end

    hookTooltips()
    hookMoneyFrames()
    config:AddPluginConfig(L["TITLE"], options)

    _G.SLASH_BETTERBAGSSYNC1 = "/bbsync"
    _G.SlashCmdList.BETTERBAGSSYNC = slash
end

eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", function(_, event, ...)
    if event == "ADDON_LOADED" then
        if ... == addonName then
            eventFrame:UnregisterEvent("ADDON_LOADED")
            onReady()
        end
        return
    end
    local handler = handlers[event]
    if handler then handler(...) end
end)
