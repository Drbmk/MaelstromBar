-- MaelstromBar by Petitcorps : Maelstrom Weapon stack bar (Retail style), standalone.
-- Commands: /mw options | move | lock | always | color | glow | glowspell | glowframe | reset | scale <n> | test <0-5> | aura <name> | setup | debug

local MAX_STACKS = 5
local SQ_W, SQ_H, SQ_GAP = 28, 22, 3
local BUILD = select(4, GetBuildInfo()) or 0

-- Localisation : les textes sont ecrits en anglais (cle) ; frFR les traduit.
local PREFIX = "|cff00aaffMaelstromBar|r : "
local LOC = {}
if GetLocale() == "frFR" then
    LOC = {
        ["buff read error: "] = "erreur de lecture du buff : ",
        ["MaelstromBar - drag to move"] = "MaelstromBar - glisser pour déplacer",
        ["MaelstromBar  (command: /mw)"] = "MaelstromBar  (commande : /mw)",
        ["Unlock the bar to move it (/mw move)"] = "Déverrouiller la barre pour la déplacer (/mw move)",
        ["Always show the bar (/mw always)"] = "Toujours afficher la barre (/mw always)",
        ["Colors (/mw color)"] = "Couleurs (/mw color)",
        ["Stacks 1 to 4"] = "Stacks 1 à 4",
        ["5 stacks (maximum)"] = "5 stacks (maximum)",
        ["Spell glow"] = "Halo sur le sort",
        ["Default colors"] = "Couleurs par défaut",
        ["Action-bar glow (/mw glow)"] = "Halo sur la barre d'action (/mw glow)",
        ["Glow on the spell at 5 stacks"] = "Halo lumineux sur le sort à 5 stacks",
        ["Spell to highlight (name or ID), empty = Lightning Bolt (/mw glowspell)"] = "Sort à surligner (nom ou ID), vide = Eclair (/mw glowspell)",
        ["Scale (/mw scale)"] = "Taille (/mw scale)",
        ["Test (/mw test)"] = "Test (/mw test)",
        ["3 stacks"] = "3 stacks",
        ["Stop"] = "Arrêter",
        ["Buff name to track (/mw aura), leave empty by default"] = "Nom du buff à suivre (/mw aura), laisser vide par défaut",
        ["Reset position (/mw reset)"] = "Réinitialiser la position (/mw reset)",
        ["unlocked (drag the bar)"] = "déverrouillée (glisse la barre)",
        ["locked"] = "verrouillée",
        ["active buffs (index, name, stacks, id)"] = "buffs actifs (index, nom, stacks, id)",
        ["glow "] = "halo ",
        ["on"] = "activé",
        ["off"] = "désactivé",
        ["glow on "] = "halo sur ",
        ["Lightning Bolt (default)"] = "Eclair (par défaut)",
        ["highlighted frames: "] = "frames surlignées : ",
        ["none"] = "aucune",
        ["frames cleared"] = "frames supprimées",
        ["warning: frame '%s' does not exist (yet)"] = "attention, la frame '%s' n'existe pas (encore)",
        ["frame %s removed"] = "frame %s retirée",
        ["frame %s added"] = "frame %s ajoutée",
        ["options panel unavailable"] = "panneau d'options indisponible",
        ["/mw color [full] <r> <g> <b>  (values from 0 to 1)"] = "/mw color [full] <r> <g> <b>  (valeurs de 0 à 1)",
        ["always show "] = "affichage permanent ",
        ["position reset"] = "position réinitialisée",
        ["test "] = "test ",
        ["aura name = "] = "nom d'aura = ",
        ["this client does not need the Cooldown Manager"] = "ce client n'a pas besoin du Cooldown Manager",
        ["not available in combat"] = "indisponible en combat",
        ["Maelstrom Weapon is not tracked in the Cooldown Manager.\nThe bar stays empty in combat.  /mw setup"] = "Arme du Maelström n'est pas suivie dans le Cooldown Manager.\nLa barre reste vide en combat.  /mw setup",
        ["Cooldown Manager enabled: "] = "Cooldown Manager activé : ",
        ["Maelstrom Weapon is tracked in the Cooldown Manager"] = "Arme du Maelström est suivie dans le Cooldown Manager",
        ["Maelstrom Weapon added to the Cooldown Manager"] = "Arme du Maelström ajoutée au Cooldown Manager",
        ["Maelstrom Weapon is not tracked in the Cooldown Manager: the bar will stay empty in combat. Add it to the tracked buffs in the Cooldown Manager settings."] = "Arme du Maelström n'est pas suivie dans le Cooldown Manager : la barre restera vide en combat. Ajoute-la aux buffs suivis dans les réglages du Cooldown Manager.",
    }
end
-- Nom du "Cooldown Manager" tel que le client l'affiche dans ses menus
local CDM_NAME = (type(COOLDOWN_VIEWER_LABEL) == "string" and COOLDOWN_VIEWER_LABEL)
    or (GetLocale() == "frFR" and "Gestionnaire de temps de recharge") or "Cooldown Manager"
CDM_NAME = CDM_NAME:gsub("%%", "%%%%")
local function T(s) return ((LOC[s] or s):gsub("Cooldown Manager", CDM_NAME)) end

local DEFAULTS = {
    point = "CENTER", relPoint = "CENTER", x = 0, y = -150,
    scale = 1, auraName = nil, alwaysShow = false,
    colorNormal = { 0, 0.55, 1 },
    colorFull = { 0.55, 0.95, 1 },
    glow = true,                       -- halo sur le sort a 5 stacks
    colorGlow = { 1, 0.85, 0.2 },
    glowSpell = nil,                   -- nom ou ID ; nil = Eclair
    extraFrames = {},                  -- noms de frames a mettre en surbrillance (ex. OneButton)
}

-- IDs connus du buff "Maelstrom Weapon" (stacks). Complete par le nom si besoin.
local SPELL_IDS = { [408505] = true, [53817] = true, [344179] = true }
local NAMES = {
    ["maelstrom weapon"] = true,
    ["arme du maelstrom"] = true,
    ["arme du maelström"] = true,
}

local db
local unlocked = false
local testStacks = nil
local openOptions -- defini quand le panneau d'options est construit
local active = false -- vrai uniquement pour un chaman (l'addon ne fait rien pour les autres classes)

---------------------------------------------------------------- helpers
local function SetColor(tex, r, g, b, a)
    if tex.SetColorTexture then
        tex:SetColorTexture(r, g, b, a or 1)
    else
        tex:SetTexture(r, g, b, a or 1)
    end
end

local function IsMaelstromAura(name, spellId)
    if spellId and SPELL_IDS[spellId] then return true end
    if name then
        local lower = name:lower()
        if NAMES[lower] then return true end
        if db and db.auraName and lower == db.auraName:lower() then return true end
    end
    return false
end

-- En combat, ce client masque les auras du joueur ("secret") : la lecture par ID
-- renvoie nil et le balayage par index est refuse. La barre n'est donc fiable
-- que hors combat ; en combat elle retombe a 0 sans erreur.
local function AurasSecret()
    return C_Secrets and C_Secrets.ShouldAurasBeSecret and C_Secrets.ShouldAurasBeSecret()
end

-- En combat : le Cooldown Manager de Blizzard a le droit de lire l'aura. On retrouve
-- son icone Maelstrom Weapon et on lui emprunte les donnees d'aura ("applications"
-- est alors une valeur secrete, affichable par les StatusBar).
local CDM_SPELLS = { [408498] = true, [408505] = true, [53817] = true, [344179] = true }
local CDM_VIEWERS = { "BuffIconCooldownViewer", "BuffBarCooldownViewer" }

local function Plain(v) -- valeur utilisable dans un test (ni nil ni secrete)
    if v == nil or (issecretvalue and issecretvalue(v)) then return nil end
    return v
end

local function Has(v) -- non nil, sans comparer une valeur secrete
    return (issecretvalue and issecretvalue(v)) or v ~= nil
end

local function IsMaelstromItem(f)
    local function try(m)
        if not f[m] then return nil end
        local ok, r = pcall(f[m], f)
        return ok and Plain(r) or nil
    end
    local a, b = try("GetSpellID"), try("GetAuraSpellID")
    if (a and CDM_SPELLS[a]) or (b and CDM_SPELLS[b]) then return true end
    local ci = f.cooldownInfo
    if type(ci) == "table" then
        local s, o = Plain(ci.spellID), Plain(ci.overrideSpellID)
        if (s and CDM_SPELLS[s]) or (o and CDM_SPELLS[o]) then return true end
    end
    return false
end

local function ReadFromCooldownManager()
    for _, vn in ipairs(CDM_VIEWERS) do
        local v = _G[vn]
        if v then
            local items
            if v.GetItemFrames then
                local ok, r = pcall(v.GetItemFrames, v)
                if ok then items = r end
            end
            items = items or { v:GetChildren() }
            for _, f in ipairs(items) do
                if IsMaelstromItem(f) then
                    for _, m in ipairs({ "GetAuraData", "GetAuraDataCached" }) do
                        if f[m] then
                            local ok, d = pcall(f[m], f)
                            if ok and type(d) == "table" and Has(d.applications) then return d.applications end
                        end
                    end
                    if f.GetAuraSpellInstanceID then
                        local ok, id = pcall(f.GetAuraSpellInstanceID, f)
                        if ok and Has(id) then
                            local ok2, d = pcall(C_UnitAuras.GetAuraDataByAuraInstanceID, "player", id)
                            if ok2 and type(d) == "table" and Has(d.applications) then return d.applications end
                        end
                    end
                end
            end
        end
    end
    return nil
end

---------------------------------------------------------------- reglage auto du Cooldown Manager
-- La lecture en combat depend de l'icone Maelstrom Weapon du Cooldown Manager :
-- on verifie qu'il est actif et que le buff y est suivi, et on tente de le regler.
local setupDone = false    -- la verification de connexion a eu lieu
local cdmMissing = false   -- vrai : buff non suivi, avertissement affiche sur la barre
local RefreshCDMWarning    -- defini plus bas (a besoin de la barre)

local function HasMaelstromItem()
    for _, vn in ipairs(CDM_VIEWERS) do
        local v = _G[vn]
        if v then
            local items
            if v.GetItemFrames then
                local ok, r = pcall(v.GetItemFrames, v)
                if ok then items = r end
            end
            for _, f in ipairs(items or { v:GetChildren() }) do
                if IsMaelstromItem(f) then return true end
            end
        end
    end
    return false
end

-- cooldownID du buff dans le catalogue du Cooldown Manager (toutes categories)
local function FindMaelstromCooldownID()
    local C = C_CooldownViewer
    if not (C and C.GetCooldownViewerCategorySet and C.GetCooldownViewerCooldownInfo) then return nil end
    for _, cat in pairs(Enum and Enum.CooldownViewerCategory or {}) do
        local ok, ids = pcall(C.GetCooldownViewerCategorySet, cat, true)
        if ok and type(ids) == "table" then
            for _, id in ipairs(ids) do
                local ok2, info = pcall(C.GetCooldownViewerCooldownInfo, id)
                if ok2 and type(info) == "table" then
                    local hit = CDM_SPELLS[Plain(info.spellID) or 0] or CDM_SPELLS[Plain(info.overrideSpellID) or 0]
                    if not hit and type(info.linkedSpellIDs) == "table" then
                        for _, s in ipairs(info.linkedSpellIDs) do
                            if CDM_SPELLS[Plain(s) or 0] then hit = true end
                        end
                    end
                    if hit then return id, cat end
                end
            end
        end
    end
    return nil
end

-- verbose : detaille chaque etape (commande /mw setup) ; sinon un seul message si echec
local function SetupCooldownManager(verbose)
    if not (C_Secrets and C_Secrets.ShouldAurasBeSecret) then
        if verbose then print(PREFIX .. T("this client does not need the Cooldown Manager")) end
        return
    end
    if InCombatLockdown and InCombatLockdown() then
        if verbose then print(PREFIX .. T("not available in combat")) end
        return
    end
    local function say(s) if verbose then print(PREFIX .. s) end end

    -- 1) activer le Cooldown Manager
    local getCV = (C_CVar and C_CVar.GetCVar) or GetCVar
    local setCV = (C_CVar and C_CVar.SetCVar) or SetCVar
    local okG, cur = pcall(getCV, "cooldownViewerEnabled")
    if okG and cur == "0" then
        local okS = pcall(setCV, "cooldownViewerEnabled", "1")
        say(T("Cooldown Manager enabled: ") .. tostring(okS))
    else
        say("cooldownViewerEnabled=" .. tostring(okG and cur or "?"))
    end

    -- 2) deja suivi ?
    if HasMaelstromItem() then
        say(T("Maelstrom Weapon is tracked in the Cooldown Manager"))
        RefreshCDMWarning()
        return
    end

    -- 3) tenter de l'ajouter aux buffs suivis
    local id, cat = FindMaelstromCooldownID()
    local target = Enum and Enum.CooldownViewerCategory and Enum.CooldownViewerCategory.TrackedBuff
    say("cooldownID=" .. tostring(id) .. " cat=" .. tostring(cat) .. " TrackedBuff=" .. tostring(target))
    local done = false
    local S = CooldownViewerSettings
    if id and target ~= nil and S then
        local okP, dp = pcall(function() return S.GetDataProvider and S:GetDataProvider() end)
        say("settings=true dataProvider=" .. tostring(okP and dp ~= nil)
            .. " SetCooldownToCategory=" .. tostring(okP and dp and dp.SetCooldownToCategory ~= nil))
        if okP and dp and dp.SetCooldownToCategory then
            local okC, err = pcall(dp.SetCooldownToCategory, dp, id, target)
            say("SetCooldownToCategory ok=" .. tostring(okC) .. (okC and "" or (" " .. tostring(err))))
            if okC then
                for _, m in ipairs({ "MarkDirty", "SaveCurrentLayout", "SaveLayouts" }) do
                    local o = dp[m] and dp or (S.GetLayoutManager and S:GetLayoutManager())
                    if o and o[m] then say(m .. " ok=" .. tostring(pcall(o[m], o))) end
                end
                for _, m in ipairs({ "RefreshLayout", "Refresh" }) do
                    if S[m] then pcall(S[m], S) end
                end
                done = true
            end
        end
    else
        say("settings=" .. tostring(S ~= nil))
    end

    -- 4) verifier un peu plus tard, et prevenir si le buff n'est toujours pas suivi
    C_Timer.After(1, function()
        RefreshCDMWarning()
        if not cdmMissing then
            print(PREFIX .. T("Maelstrom Weapon added to the Cooldown Manager"))
        else
            print(PREFIX .. T("Maelstrom Weapon is not tracked in the Cooldown Manager: the bar will stay empty in combat. Add it to the tracked buffs in the Cooldown Manager settings.")
                .. (done and "" or " (/mw setup)"))
        end
    end)
end

local function ReadStacks()
    -- Lecture directe par ID (la plus fiable). "applications" peut etre une valeur
    -- secrete (liste blanche Blizzard) : on la renvoie telle quelle, la StatusBar l'accepte.
    if C_UnitAuras and C_UnitAuras.GetPlayerAuraBySpellID then
        for id in pairs(SPELL_IDS) do
            local okA, a = pcall(C_UnitAuras.GetPlayerAuraBySpellID, id)
            if okA and a then
                local c = a.applications
                if issecretvalue and issecretvalue(c) then return c end
                if not (c and c > 0) then c = 1 end
                return c
            end
        end
    end
    if AurasSecret() then
        local v = ReadFromCooldownManager()
        if v ~= nil then return v end
        return 0
    end
    if C_UnitAuras and C_UnitAuras.GetAuraDataByIndex then
        -- pcall : le balayage peut etre refuse (taint / valeurs secretes)
        local ok, res = pcall(function()
            for i = 1, 40 do
                local a = C_UnitAuras.GetAuraDataByIndex("player", i, "HELPFUL")
                if not a then break end
                if IsMaelstromAura(a.name, a.spellId) then
                    return a.applications or 1
                end
            end
            return 0
        end)
        return ok and res or 0
    end
    local wrath = BUILD >= 30000 and BUILD < 40000
    for i = 1, 40 do
        local name, count, spellId
        if wrath then
            -- 3.3.5 : name, rank, icon, count, debuffType, duration, expiration, caster, stealable, consolidate, spellId
            local _
            name, _, _, count, _, _, _, _, _, _, spellId = UnitBuff("player", i)
        else
            -- clients recents : name, icon, count, debuffType, duration, expiration, caster, ..., spellId
            local _
            name, _, count, _, _, _, _, _, _, spellId = UnitBuff("player", i)
        end
        if not name then break end
        if IsMaelstromAura(name, spellId) then
            return (count and count > 0) and count or 1
        end
    end
    return 0
end

local lastErr
local function GetStacks()
    if testStacks then return testStacks end
    local ok, res = pcall(ReadStacks)
    if ok then return res or 0 end
    if res ~= lastErr then
        lastErr = res
        print(PREFIX .. T("buff read error: ") .. tostring(res))
    end
    return 0
end

---------------------------------------------------------------- frames
local bar = CreateFrame("Frame", "MaelstromBarFrame", UIParent)
bar:SetSize(MAX_STACKS * SQ_W + (MAX_STACKS - 1) * SQ_GAP, SQ_H)
bar:SetFrameStrata("MEDIUM")
bar:SetMovable(true)
bar:SetClampedToScreen(true)
bar:Hide()

local squares = {}
for i = 1, MAX_STACKS do
    local sq = CreateFrame("Frame", nil, bar)
    sq:SetSize(SQ_W, SQ_H)
    sq:SetPoint("LEFT", bar, "LEFT", (i - 1) * (SQ_W + SQ_GAP), 0)

    sq.border = sq:CreateTexture(nil, "BACKGROUND")
    sq.border:SetAllPoints()
    SetColor(sq.border, 0, 0, 0, 0.9)

    sq.bg = sq:CreateTexture(nil, "BORDER")
    sq.bg:SetPoint("TOPLEFT", 1, -1)
    sq.bg:SetPoint("BOTTOMRIGHT", -1, 1)
    SetColor(sq.bg, 0.08, 0.1, 0.15, 0.8)

    -- StatusBar : accepte une valeur "secret" (combat) sans comparaison cote addon.
    -- sb se remplit quand stacks >= i ; sbFull (4..5) ne se remplit qu'a 5 stacks.
    local function MakeBar(lo, hi, level)
        local s = CreateFrame("StatusBar", nil, sq)
        s:SetPoint("TOPLEFT", 2, -2)
        s:SetPoint("BOTTOMRIGHT", -2, 2)
        s:SetFrameLevel(sq:GetFrameLevel() + level)
        s:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")
        s:SetMinMaxValues(lo, hi)
        s:SetValue(lo)
        return s
    end
    sq.fill = MakeBar(i - 1, i, 1)
    sq.fullFill = MakeBar(MAX_STACKS - 1, MAX_STACKS, 2)

    squares[i] = sq
end

-- Calque de deplacement (visible uniquement en mode edition / deverrouille)
local overlay = CreateFrame("Frame", nil, bar)
overlay:SetAllPoints(bar)
overlay:SetFrameLevel(bar:GetFrameLevel() + 10)
overlay:EnableMouse(true)
overlay:RegisterForDrag("LeftButton")
overlay:Hide()
overlay.tex = overlay:CreateTexture(nil, "OVERLAY")
overlay.tex:SetAllPoints()
SetColor(overlay.tex, 0.2, 0.8, 0.3, 0.35)
overlay.label = overlay:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
overlay.label:SetPoint("BOTTOM", overlay, "TOP", 0, 2)
overlay.label:SetText(T("MaelstromBar - drag to move"))

-- Avertissement visible sous la barre quand le buff n'est pas suivi par le Cooldown Manager
local warn = bar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
warn:SetPoint("TOP", bar, "BOTTOM", 0, -4)
warn:SetWidth(260)
warn:SetTextColor(1, 0.25, 0.2)
warn:SetText(T("Maelstrom Weapon is not tracked in the Cooldown Manager.\nThe bar stays empty in combat.  /mw setup"))
warn:Hide()

overlay:SetScript("OnDragStart", function() bar:StartMoving() end)
overlay:SetScript("OnDragStop", function()
    bar:StopMovingOrSizing()
    local p, _, rp, x, y = bar:GetPoint()
    db.point, db.relPoint, db.x, db.y = p, rp, x, y
end)

---------------------------------------------------------------- halo sur la barre d'action
local glowDirty = true
local glowTargets = {}   -- noms (minuscules) et IDs a surligner
local glowFrames = {}    -- frame de halo par bouton
local glowActive = {}    -- boutons actuellement surlignes

local function SpellNameOf(id)
    if C_Spell and C_Spell.GetSpellName then return C_Spell.GetSpellName(id) end
    if GetSpellInfo then return (GetSpellInfo(id)) end
end

local function BuildGlowTargets()
    glowTargets = {}
    local custom = db and db.glowSpell
    if custom then
        local id = tonumber(custom)
        if id then
            glowTargets[id] = true
            local n = SpellNameOf(id)
            if n then glowTargets[n:lower()] = true end
        else
            glowTargets[tostring(custom):lower()] = true
        end
    else
        -- Eclair / Lightning Bolt : IDs connus + noms dans la langue du client
        for _, id in ipairs({ 403, 188196 }) do
            glowTargets[id] = true
            local n = SpellNameOf(id)
            if n then glowTargets[n:lower()] = true end
        end
        glowTargets["lightning bolt"] = true
        glowTargets["eclair"] = true -- nom frFR du sort : "Eclair", sans accent
        glowTargets[("Éclair"):lower()] = true -- lower() ne touche pas aux accents : meme traitement que le nom du jeu
    end
end

local function SpellMatches(spellId)
    if not spellId then return false end
    if glowTargets[spellId] then return true end
    local n = SpellNameOf(spellId)
    return n and glowTargets[n:lower()] or false
end

local function SlotMatches(slot)
    if not slot then return false end
    local t, id = GetActionInfo(slot)
    if t == "spell" then
        return SpellMatches(id)
    elseif t == "macro" and GetMacroSpell then
        return SpellMatches(GetMacroSpell(id))
    end
    return false
end

local BAR_PREFIXES = {
    { "ActionButton", 12 }, { "MultiBarBottomLeftButton", 12 },
    { "MultiBarBottomRightButton", 12 }, { "MultiBarRightButton", 12 },
    { "MultiBarLeftButton", 12 }, { "MultiBar5Button", 12 },
    { "MultiBar6Button", 12 }, { "MultiBar7Button", 12 },
    { "BT4Button", 180 }, { "DominosActionButton", 180 },
}

local function ButtonAction(btn)
    local a = btn._state_action or btn.action
    if type(a) ~= "number" and btn.GetAttribute then a = btn:GetAttribute("action") end
    return tonumber(a)
end

local function CollectGlowButtons()
    local list = {}
    local function Try(btn)
        if btn and btn.IsShown and SlotMatches(ButtonAction(btn)) then list[#list + 1] = btn end
    end
    for _, p in ipairs(BAR_PREFIXES) do
        for i = 1, p[2] do Try(_G[p[1] .. i]) end
    end
    for barIndex = 1, 10 do
        for i = 1, 12 do Try(_G["ElvUI_Bar" .. barIndex .. "Button" .. i]) end
    end
    -- frames explicites (ex. bouton de OneButton) : surlignees telles quelles
    for _, name in ipairs(db.extraFrames or {}) do
        local f = _G[name]
        if f and f.IsShown then list[#list + 1] = f end
    end
    return list
end

local function GetGlowFrame(btn)
    local g = glowFrames[btn]
    if not g then
        g = CreateFrame("Frame", nil, btn)
        g:SetFrameLevel((btn:GetFrameLevel() or 1) + 8)
        local w = btn:GetWidth()
        if not w or w < 10 then w = 36 end
        local h = btn:GetHeight()
        if not h or h < 10 then h = 36 end
        g:SetSize(w * 2.1, h * 2.1)
        g:SetPoint("CENTER", btn, "CENTER", 0, 0)
        -- StatusBar (4..5) : pleines a 5 stacks, vides sinon, meme avec une valeur
        -- secrete en combat. "border" = anneau lumineux, "fill" = voile sur le bouton.
        local function Layer(texture, sw, sh, alpha)
            local s = CreateFrame("StatusBar", nil, g)
            s:SetSize(sw, sh)
            s:SetPoint("CENTER", g, "CENTER", 0, 0)
            s:SetStatusBarTexture(texture)
            local t = s:GetStatusBarTexture()
            if t and t.SetBlendMode then t:SetBlendMode("ADD") end
            s:SetAlpha(alpha)
            s:SetMinMaxValues(MAX_STACKS - 1, MAX_STACKS)
            s:SetValue(MAX_STACKS - 1)
            return s
        end
        g.border = Layer("Interface\\Buttons\\UI-ActionButton-Border", w * 2.1, h * 2.1, 1)
        g.border2 = Layer("Interface\\Buttons\\UI-ActionButton-Border", w * 1.8, h * 1.8, 1)
        g.fill = Layer("Interface\\Buttons\\WHITE8X8", w, h, 0.4)
        g.ag = g:CreateAnimationGroup()
        g.ag:SetLooping("BOUNCE")
        local a = g.ag:CreateAnimation("Alpha")
        if a.SetFromAlpha then
            a:SetFromAlpha(1); a:SetToAlpha(0.45)
        end
        a:SetDuration(0.4)
        glowFrames[btn] = g
    end
    return g
end

local function HideGlows()
    for btn in pairs(glowActive) do
        local g = glowFrames[btn]
        if g then g.ag:Stop(); g:Hide() end
        glowActive[btn] = nil
    end
end

local lastWant = false
local function RefreshGlow(stacks)
    -- Les halos restent poses sur les boutons tant que l'option est active ;
    -- c'est la valeur des StatusBar qui les rend visibles a 5 stacks.
    local want = db.glow and true or false
    if want ~= lastWant or glowDirty then
        lastWant, glowDirty = want, false
        HideGlows()
        if want then
            local c = db.colorGlow
            for _, btn in ipairs(CollectGlowButtons()) do
                local g = GetGlowFrame(btn)
                g.border:SetStatusBarColor(c[1], c[2], c[3])
                g.border2:SetStatusBarColor(c[1], c[2], c[3])
                g.fill:SetStatusBarColor(c[1], c[2], c[3])
                g:Show()
                g.ag:Play()
                glowActive[btn] = true
            end
        end
    end
    for btn in pairs(glowActive) do
        local g = glowFrames[btn]
        g.border:SetValue(stacks)
        g.border2:SetValue(stacks)
        g.fill:SetValue(stacks)
    end
end

---------------------------------------------------------------- logique
local function Update()
    if not db then return end
    local stacks = GetStacks()
    local inCombat = UnitAffectingCombat("player")
    local secret = issecretvalue and issecretvalue(stacks)

    -- Valeur secrete : aucune comparaison possible (barre toujours visible)
    RefreshGlow(stacks)

    if cdmMissing then warn:Show() else warn:Hide() end
    if unlocked or db.alwaysShow or inCombat or secret or cdmMissing or stacks > 0 then
        bar:Show()
    else
        bar:Hide()
        return
    end

    local n, f = db.colorNormal, db.colorFull
    for i = 1, MAX_STACKS do
        local sq = squares[i]
        sq.fill:SetStatusBarColor(n[1], n[2], n[3], 1)
        sq.fullFill:SetStatusBarColor(f[1], f[2], f[3], 1)
        sq.fill:SetValue(stacks)
        sq.fullFill:SetValue(stacks)
    end
end

RefreshCDMWarning = function()
    -- inutile sur les clients sans auras secretes ; pas de verification en combat
    if not (C_Secrets and C_Secrets.ShouldAurasBeSecret) then return end
    if UnitAffectingCombat("player") then return end
    local missing = not HasMaelstromItem()
    if missing ~= cdmMissing then
        cdmMissing = missing
        Update()
    end
end

local function ApplyPosition()
    bar:ClearAllPoints()
    bar:SetPoint(db.point, UIParent, db.relPoint, db.x, db.y)
    bar:SetScale(db.scale)
end

local function SetUnlocked(state)
    unlocked = state and true or false
    if unlocked then overlay:Show() else overlay:Hide() end
    Update()
end

---------------------------------------------------------------- panneau d'options
local function BuildOptions()
    local panel = CreateFrame("Frame", "MaelstromBarOptionsPanel", UIParent)
    panel.name = "MaelstromBar"
    local refreshers = {}
    local y = -16

    local function Label(text, font, x, yy)
        local fs = panel:CreateFontString(nil, "ARTWORK", font or "GameFontHighlight")
        fs:SetPoint("TOPLEFT", x or 16, yy or y)
        fs:SetText(text)
        return fs
    end

    local function Button(text, width, x, yy, onclick)
        local b = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
        b:SetSize(width, 22)
        b:SetPoint("TOPLEFT", x, yy)
        b:SetText(text)
        b:SetScript("OnClick", onclick)
        return b
    end

    local function Check(text, getter, setter)
        local cb = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
        cb:SetPoint("TOPLEFT", 12, y + 4)
        local fs = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        fs:SetPoint("LEFT", cb, "RIGHT", 4, 0)
        fs:SetText(text)
        cb:SetScript("OnClick", function(self) setter(self:GetChecked() and true or false) end)
        refreshers[#refreshers + 1] = function() cb:SetChecked(getter()) end
        y = y - 30
    end

    local function ColorRow(text, key)
        local btn = CreateFrame("Button", nil, panel)
        btn:SetSize(24, 24)
        btn:SetPoint("TOPLEFT", 20, y + 2)
        local border = btn:CreateTexture(nil, "BACKGROUND")
        border:SetAllPoints()
        SetColor(border, 1, 1, 1, 1)
        local sw = btn:CreateTexture(nil, "ARTWORK")
        sw:SetPoint("TOPLEFT", 2, -2)
        sw:SetPoint("BOTTOMRIGHT", -2, 2)
        local fs = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        fs:SetPoint("LEFT", btn, "RIGHT", 8, 0)
        fs:SetText(text)

        local function paint() local c = db[key]; SetColor(sw, c[1], c[2], c[3], 1) end
        refreshers[#refreshers + 1] = paint

        btn:SetScript("OnClick", function()
            local c = db[key]
            local old = { c[1], c[2], c[3] }
            local function apply()
                local r, g, b = ColorPickerFrame:GetColorRGB()
                db[key] = { r, g, b }
                glowDirty = true
                paint(); Update()
            end
            local function cancel()
                db[key] = { old[1], old[2], old[3] }
                glowDirty = true
                paint(); Update()
            end
            if ColorPickerFrame.SetupColorPickerAndShow then
                ColorPickerFrame:SetupColorPickerAndShow({
                    r = c[1], g = c[2], b = c[3], hasOpacity = false,
                    swatchFunc = apply, cancelFunc = cancel,
                })
            else
                ColorPickerFrame.hasOpacity = false
                ColorPickerFrame.func = apply
                ColorPickerFrame.swatchFunc = apply
                ColorPickerFrame.cancelFunc = cancel
                ColorPickerFrame:SetColorRGB(c[1], c[2], c[3])
                ColorPickerFrame:Hide()
                ColorPickerFrame:Show()
            end
        end)
        y = y - 28
    end

    Label(T("MaelstromBar  (command: /mw)"), "GameFontNormalLarge"); y = y - 32

    Check(T("Unlock the bar to move it (/mw move)"),
        function() return unlocked end, function(v) SetUnlocked(v) end)
    Check(T("Always show the bar (/mw always)"),
        function() return db.alwaysShow end, function(v) db.alwaysShow = v; Update() end)

    y = y - 6
    Label(T("Colors (/mw color)"), "GameFontNormal"); y = y - 26
    ColorRow(T("Stacks 1 to 4"), "colorNormal")
    ColorRow(T("5 stacks (maximum)"), "colorFull")
    ColorRow(T("Spell glow"), "colorGlow")
    Button(T("Default colors"), 150, 16, y, function()
        for _, key in ipairs({ "colorNormal", "colorFull", "colorGlow" }) do
            local d = DEFAULTS[key]
            db[key] = { d[1], d[2], d[3] }
        end
        glowDirty = true
        for _, f in ipairs(refreshers) do f() end
        Update()
    end)
    y = y - 38

    Label(T("Action-bar glow (/mw glow)"), "GameFontNormal"); y = y - 26
    Check(T("Glow on the spell at 5 stacks"),
        function() return db.glow end, function(v) db.glow = v; glowDirty = true; Update() end)
    Label(T("Spell to highlight (name or ID), empty = Lightning Bolt (/mw glowspell)"), "GameFontHighlight", 20, y); y = y - 24
    local gb = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
    gb:SetSize(220, 22)
    gb:SetPoint("TOPLEFT", 24, y)
    gb:SetAutoFocus(false)
    gb:SetScript("OnEnterPressed", function(self)
        local t = self:GetText()
        db.glowSpell = (t and t ~= "") and t or nil
        BuildGlowTargets(); glowDirty = true
        self:ClearFocus(); Update()
    end)
    gb:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    refreshers[#refreshers + 1] = function() gb:SetText(db.glowSpell and tostring(db.glowSpell) or "") end
    y = y - 34

    Label(T("Scale (/mw scale)"), "GameFontNormal", 16, y)
    Label(T("Test (/mw test)"), "GameFontNormal", 260, y); y = y - 26
    local scaleText = Label("", "GameFontHighlight", 56, y - 4)
    local function SetScale(s)
        s = math.max(0.5, math.min(3, math.floor(s * 10 + 0.5) / 10))
        db.scale = s
        ApplyPosition()
        scaleText:SetText(string.format("%.1f", s))
    end
    refreshers[#refreshers + 1] = function() scaleText:SetText(string.format("%.1f", db.scale)) end
    Button("-", 30, 16, y, function() SetScale(db.scale - 0.1) end)
    Button("+", 30, 96, y, function() SetScale(db.scale + 0.1) end)
    Button(T("3 stacks"), 76, 260, y, function() testStacks = 3; Update() end)
    Button(T("5 stacks"), 76, 340, y, function() testStacks = 5; Update() end)
    Button(T("Stop"), 76, 420, y, function() testStacks = nil; Update() end)
    y = y - 36

    Label(T("Buff name to track (/mw aura), leave empty by default"), "GameFontNormal"); y = y - 28
    local eb = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
    eb:SetSize(220, 22)
    eb:SetPoint("TOPLEFT", 24, y)
    eb:SetAutoFocus(false)
    eb:SetScript("OnEnterPressed", function(self)
        local t = self:GetText()
        db.auraName = (t and t ~= "") and t or nil
        self:ClearFocus(); Update()
    end)
    eb:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    refreshers[#refreshers + 1] = function() eb:SetText(db.auraName or "") end
    y = y - 40

    Button(T("Reset position (/mw reset)"), 230, 16, y, function()
        db.point, db.relPoint, db.x, db.y = DEFAULTS.point, DEFAULTS.relPoint, DEFAULTS.x, DEFAULTS.y
        SetScale(1)
    end)

    panel:SetScript("OnShow", function()
        for _, f in ipairs(refreshers) do f() end
    end)

    if Settings and Settings.RegisterCanvasLayoutCategory then
        local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
        Settings.RegisterAddOnCategory(category)
        openOptions = function() Settings.OpenToCategory(category:GetID()) end
    elseif InterfaceOptions_AddCategory then
        InterfaceOptions_AddCategory(panel)
        openOptions = function()
            InterfaceOptionsFrame_OpenToCategory(panel)
            InterfaceOptionsFrame_OpenToCategory(panel)
        end
    end
end

---------------------------------------------------------------- evenements
local ev = CreateFrame("Frame")
ev:RegisterEvent("PLAYER_LOGIN")
ev:SetScript("OnEvent", function(self, event, unit)
    if event == "PLAYER_LOGIN" then
        MaelstromBarDB = MaelstromBarDB or {}
        db = MaelstromBarDB
        for k, v in pairs(DEFAULTS) do
            if db[k] == nil then
                if type(v) == "table" then
                    db[k] = { v[1], v[2], v[3] }
                else
                    db[k] = v
                end
            end
        end

        local _, class = UnitClass("player")
        if class ~= "SHAMAN" then return end
        active = true

        -- Nom localise du sort, quelle que soit la langue du client
        local locName
        if C_Spell and C_Spell.GetSpellName then
            locName = C_Spell.GetSpellName(408505)
        elseif GetSpellInfo then
            locName = GetSpellInfo(408505)
        end
        if locName then NAMES[locName:lower()] = true end

        ApplyPosition()
        BuildOptions()
        BuildGlowTargets()
        for _, e in ipairs({ "ACTIONBAR_SLOT_CHANGED", "ACTIONBAR_PAGE_CHANGED", "UPDATE_BONUS_ACTIONBAR" }) do
            pcall(self.RegisterEvent, self, e) -- certains evenements n'existent pas sur tous les clients
        end
        self:RegisterEvent("UNIT_AURA")
        self:RegisterEvent("PLAYER_REGEN_DISABLED")
        self:RegisterEvent("PLAYER_REGEN_ENABLED")
        self:RegisterEvent("PLAYER_ENTERING_WORLD")

        -- Integration au menu d'edition de l'interface (clients qui l'ont)
        if EditModeManagerFrame and EditModeManagerFrame.HookScript then
            EditModeManagerFrame:HookScript("OnShow", function() SetUnlocked(true) end)
            EditModeManagerFrame:HookScript("OnHide", function() SetUnlocked(false) end)
        end
        Update()
        -- laisse le temps au Cooldown Manager de creer ses icones avant de verifier
        if C_Timer and C_Timer.After then
            C_Timer.After(5, function() setupDone = true; pcall(SetupCooldownManager, false) end)
        end
    elseif event == "UNIT_AURA" then
        if unit == "player" then Update() end
    else
        if event == "PLAYER_REGEN_ENABLED" and setupDone then RefreshCDMWarning() end
        glowDirty = true -- barres d'action modifiees : relire les boutons
        Update()
    end
end)

---------------------------------------------------------------- commandes
SLASH_MAELSTROMBAR1 = "/mw"
SLASH_MAELSTROMBAR2 = "/maelstrombar"
SlashCmdList["MAELSTROMBAR"] = function(msg)
    if not db or not active then return end
    local cmd, arg = (msg or ""):match("^(%S*)%s*(.-)$")
    cmd = cmd:lower()

    if cmd == "move" or cmd == "unlock" then
        SetUnlocked(not unlocked)
        print(PREFIX .. (unlocked and T("unlocked (drag the bar)") or T("locked")))
    elseif cmd == "setup" then
        SetupCooldownManager(true)
    elseif cmd == "debug" then
        print(PREFIX .. T("active buffs (index, name, stacks, id)"))
        local n = 0
        if C_UnitAuras and C_UnitAuras.GetAuraDataByIndex then
            for i = 1, 40 do
                local a = C_UnitAuras.GetAuraDataByIndex("player", i, "HELPFUL")
                if not a then break end
                n = n + 1
                print(i, tostring(a.name), tostring(a.applications), tostring(a.spellId))
            end
        else
            for i = 1, 40 do
                local name, _, count, _, _, _, _, _, _, spellId = UnitBuff("player", i)
                if not name then break end
                n = n + 1
                print(i, tostring(name), tostring(count), tostring(spellId))
            end
        end
        print("API: " .. ((C_UnitAuras and C_UnitAuras.GetAuraDataByIndex) and "C_UnitAuras" or "UnitBuff") .. ", build " .. tostring(BUILD) .. ", buffs: " .. n)
    elseif cmd == "glow" then
        db.glow = not db.glow
        glowDirty = true
        Update()
        print(PREFIX .. T("glow ") .. (db.glow and T("on") or T("off")))
    elseif cmd == "glowspell" then
        db.glowSpell = (arg ~= "") and arg or nil
        BuildGlowTargets(); glowDirty = true
        Update()
        print(PREFIX .. T("glow on ") .. (db.glowSpell or T("Lightning Bolt (default)")))
    elseif cmd == "glowframe" then
        -- /mw glowframe <NomDeFrame> ajoute/retire une frame (ex. bouton OneButton) ; sans argument : liste
        db.extraFrames = db.extraFrames or {}
        if arg == "" then
            print(PREFIX .. T("highlighted frames: ") .. (#db.extraFrames > 0 and table.concat(db.extraFrames, ", ") or T("none")))
        elseif arg == "clear" then
            db.extraFrames = {}
            glowDirty = true; Update()
            print(PREFIX .. T("frames cleared"))
        else
            local found
            for i, n in ipairs(db.extraFrames) do
                if n == arg then table.remove(db.extraFrames, i); found = true; break end
            end
            if not found then
                db.extraFrames[#db.extraFrames + 1] = arg
                if not _G[arg] then print(PREFIX .. string.format(T("warning: frame '%s' does not exist (yet)"), arg)) end
            end
            glowDirty = true; Update()
            print(PREFIX .. string.format(found and T("frame %s removed") or T("frame %s added"), arg))
        end
    elseif cmd == "options" or cmd == "config" then
        if openOptions then openOptions() else print(PREFIX .. T("options panel unavailable")) end
    elseif cmd == "color" or cmd == "couleur" then
        -- /mw color <r> <g> <b>  (0-1)  -> stacks 1-4 ;  /mw color full <r> <g> <b> -> 5 stacks
        local which, rest = "colorNormal", arg
        local first = arg:match("^(%a+)")
        if first == "full" then which, rest = "colorFull", arg:gsub("^full%s*", "") end
        local r, g, b = rest:match("([%d%.]+)%s+([%d%.]+)%s+([%d%.]+)")
        r, g, b = tonumber(r), tonumber(g), tonumber(b)
        if r and g and b and r <= 1 and g <= 1 and b <= 1 then
            db[which] = { r, g, b }
            Update()
        else
            print(PREFIX .. T("/mw color [full] <r> <g> <b>  (values from 0 to 1)"))
        end
    elseif cmd == "always" then
        db.alwaysShow = not db.alwaysShow
        Update()
        print(PREFIX .. T("always show ") .. (db.alwaysShow and T("on") or T("off")))
    elseif cmd == "lock" then
        SetUnlocked(false)
        print(PREFIX .. T("locked"))
    elseif cmd == "reset" then
        db.point, db.relPoint, db.x, db.y, db.scale = DEFAULTS.point, DEFAULTS.relPoint, DEFAULTS.x, DEFAULTS.y, 1
        ApplyPosition()
        print(PREFIX .. T("position reset"))
    elseif cmd == "scale" then
        local s = tonumber(arg)
        if s and s >= 0.5 and s <= 3 then
            db.scale = s
            ApplyPosition()
        else
            print(PREFIX .. "/mw scale <0.5-3>")
        end
    elseif cmd == "test" then
        local n = tonumber(arg)
        testStacks = (n and n >= 0 and n <= MAX_STACKS) and n or nil
        if testStacks == 0 then testStacks = nil end
        Update()
        print(PREFIX .. T("test ") .. (testStacks or T("off")))
    elseif cmd == "aura" and arg ~= "" then
        db.auraName = arg
        print(PREFIX .. T("aura name = ") .. arg)
        Update()
    else
        print(PREFIX .. "/mw options | move | lock | always | color | glow | glowspell | glowframe | reset | scale <n> | test <0-5> | aura <buff name>")
    end
end
