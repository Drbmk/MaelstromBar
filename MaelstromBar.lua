-- MaelstromBar by Petitcorps : Maelstrom Weapon stack bar (Retail style), standalone.
-- Commands: /mw options | move | lock | always | count | timer | color | glow | glowspell | glowframe | glowscan | reset | scale <n> | size <w> <h> [gap] | test <0-5> | aura <name> | setup | log | testerror | debug

local MAX_STACKS = 5
local SQ_W, SQ_H, SQ_GAP = 28, 22, 3
local BUILD = select(4, GetBuildInfo()) or 0
local REV = 35 -- revision du code, affichee par /mw (la version TOC ne bouge qu'a la publication)

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
        ["unlocked (drag the bar)"] = "déverrouillée (glisse la barre)",
        ["locked"] = "verrouillée",
        ["active buffs (index, name, stacks, id)"] = "buffs actifs (index, nom, stacks, id)",
        ["glow "] = "halo ",
        ["Bar background"] = "Fond de la barre",
        ["Show the stack count on the bar (/mw count)"] = "Afficher le nombre de stacks sur la barre (/mw count)",
        ["count "] = "compteur ",
        ["count position: "] = "position du compteur : ",
        ["count position: above, center or below (/mw count pos ...)"] = "position du compteur : au-dessus, au centre ou en dessous (/mw count pos …)",
        ["count offset: "] = "décalage du compteur : ",
        ["count offset: /mw count offset x y (pixels)"] = "décalage : /mw count offset x y (pixels)",
        ["Show the remaining time bar (/mw timer)"] = "Afficher la bande du temps restant (/mw timer)",
        ["Remaining time bar"] = "Bande du temps restant",
        ["time bar "] = "bande du temps ",
        ["/mw color [full|bg|timer] <r> <g> <b>  (values from 0 to 1)"] = "/mw color [full|bg|timer] <r> <g> <b>  (valeurs de 0 à 1)",
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
        ["no button found for the glow; hover the button and use /fstack, then /mw glowframe <FrameName>"] = "aucun bouton trouvé pour le halo ; survole le bouton avec /fstack, puis /mw glowframe <NomDeFrame>",
        ["%d button(s) found for the glow:"] = "%d bouton(s) trouvé(s) pour le halo :",
        ["options panel unavailable"] = "panneau d'options indisponible",
        ["always show "] = "affichage permanent ",
        ["position and size reset"] = "position et taille réinitialisées",
        ["test "] = "test ",
        ["aura name = "] = "nom d'aura = ",
        ["log cleared"] = "journal vidé",
        ["no Lua errors recorded"] = "aucune erreur Lua enregistrée",
        ["%d Lua error(s) recorded, most recent first (/mw log clear to wipe)"] = "%d erreur(s) Lua enregistrée(s), la plus récente d'abord (/mw log clear pour vider)",
        ["Square width"] = "Largeur des carrés",
        ["Square height"] = "Hauteur des carrés",
        ["Spacing between squares"] = "Espacement entre les carrés",
        ["Size (/mw size)"] = "Taille (/mw size)",
        ["Default size"] = "Taille par défaut",
        ["size: %d x %d, spacing %d"] = "taille : %d x %d, espacement %d",
        ["/mw size <width> <height> [spacing]  (10-80, 6-60, 0-30)"] = "/mw size <largeur> <hauteur> [espacement]  (10-80, 6-60, 0-30)",
        ["Reset position and size (/mw reset)"] = "Réinitialiser la position et la taille (/mw reset)",
        ["in combat the game engine itself displays the stacks: everything is fine."] = "en combat, le moteur du jeu affiche lui-même les stacks : tout va bien.",
        ["this client does not let the addon display the stacks in combat."] = "ce client ne permet pas à l'addon d'afficher les stacks en combat.",
        ["the combat display is built out of combat; try again after combat."] = "l'affichage de combat se construit hors combat ; réessaie après le combat.",
        ["the combat display is not built yet; type /mw native for details."] = "l'affichage de combat n'est pas encore construit ; tape /mw native pour les détails.",
        ["In combat"] = "En combat",
        ["The stacks are displayed in combat by the game engine itself: no configuration is needed."] = "En combat, les stacks sont affichées par le moteur du jeu lui-même : aucune configuration n'est nécessaire.",
        ["The combat display is built out of combat; it will be ready for the next fight."] = "L'affichage de combat se construit hors combat ; il sera prêt pour le prochain combat.",
    }
end
-- Traduction des textes : cle anglaise, valeur localisee (frFR).
local function T(s) return LOC[s] or s end

local DEFAULTS = {
    point = "CENTER", relPoint = "CENTER", x = 0, y = -150,
    scale = 1, auraName = nil, alwaysShow = false,
    sqW = SQ_W, sqH = SQ_H, sqGap = SQ_GAP,
    colorNormal = { 0, 0.55, 1 },
    colorFull = { 0.55, 0.95, 1 },
    colorBg = { 0.08, 0.1, 0.15 },      -- fond des carres
    showTimer = true,                    -- bande du temps restant sous les carres
    colorTimer = { 0.25, 0.85, 0.4 },    -- couleur de la bande du temps
    showCount = false,                   -- compteur de stacks sur la barre
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
local function AddonVersion()
    if C_AddOns and C_AddOns.GetAddOnMetadata then return C_AddOns.GetAddOnMetadata("MaelstromBar", "Version") end
    if GetAddOnMetadata then return GetAddOnMetadata("MaelstromBar", "Version") end
end

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

-- Etat du timer (bande du temps restant, option /mw timer) : auraTiming
-- memorise duree/expiration lues hors combat ; mwInstanceID est l'instance de
-- l'aura, cachee tant qu'elle est lisible — en combat, elle sert a demander au
-- moteur un objet duree (valeur secrete) qui pilote la bande sans la lire.
local auraTiming     -- { duration, expiration } ou nil (secret / sans duree)
local mwInstanceID   -- instance de l'aura, lue hors combat uniquement
local lastAuraUpdateInfo -- derniere charge utile UNIT_AURA (sonde /mw timerdebug)

local function ReadStacks()
    -- Lecture directe par ID (la plus fiable). "applications" peut etre une valeur
    -- secrete (liste blanche Blizzard) : on la renvoie telle quelle, la StatusBar l'accepte.
    -- En combat, ce client interdit toute lecture aux addons (valeurs secretes) :
    -- la lecture echoue alors proprement et l'affichage passe par la couche native.
    auraTiming = nil -- repart de zero : l'aura peut etre tombee depuis la derniere lecture
    if C_UnitAuras and C_UnitAuras.GetPlayerAuraBySpellID then
        for id in pairs(SPELL_IDS) do
            local okA, a = pcall(C_UnitAuras.GetPlayerAuraBySpellID, id)
            if okA and a then
                local c = a.applications
                -- cache du timer : duree/expiration (hors combat) + instance
                local dur, exp = a.duration, a.expirationTime
                local secretT = issecretvalue and ((dur ~= nil and issecretvalue(dur)) or (exp ~= nil and issecretvalue(exp)))
                if secretT then
                    auraTiming = nil
                elseif (dur or 0) > 0 and exp then
                    auraTiming = { duration = dur, expiration = exp }
                end -- sinon : aura sans duree, pas de bande de temps
                if not (issecretvalue and a.auraInstanceID ~= nil and issecretvalue(a.auraInstanceID)) then
                    mwInstanceID = a.auraInstanceID
                end
                if issecretvalue and issecretvalue(c) then return c end
                if not (c and c > 0) then c = 1 end
                return c
            end
        end
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
    if ok then
        if issecretvalue and issecretvalue(res) then return res end
        return res or 0
    end
    if res ~= lastErr then
        lastErr = res
        print(PREFIX .. T("buff read error: ") .. tostring(res))
    end
    return 0
end

---------------------------------------------------------------- journal des erreurs Lua
-- Une erreur qui surgit en combat est facile a rater sans BugSack. On installe
-- un gestionnaire d'erreurs qui enregistre tout (les notres comme celles du code
-- Blizzard) dans les SavedVariables, puis on
-- laisse la main au gestionnaire precedent (BugSack, fenetre Blizzard) pour ne
-- rien casser. Consultation : /mw log.
local MAX_LOGGED_ERRORS = 50

local function InstallErrorLog()
    local prev = geterrorhandler and geterrorhandler()
    seterrorhandler(function(msg)
        pcall(function()
            local m = tostring(msg)
            local stack = debugstack and debugstack(2) or ""
            local last = db.errors and db.errors[#db.errors]
            if last and last.msg == m then
                last.count = (last.count or 1) + 1
                last.t = time()
            else
                db.errors = db.errors or {}
                db.errors[#db.errors + 1] = { t = time(), msg = m, stack = stack, count = 1 }
                if #db.errors > MAX_LOGGED_ERRORS then table.remove(db.errors, 1) end
            end
        end)
        if type(prev) == "function" then return prev(msg) end
    end)
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

-- Compteur de stacks (option /mw count) : au-dessus (defaut), au centre ou
-- en dessous de la barre ; position et decalage reglables (/mw count pos,
-- /mw count offset). La meme ancre sert au compteur natif (combat).
local count = bar:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
count:SetTextColor(1, 1, 1)
count:Hide()
local function CountAnchor()
    local pos = db and db.countPos or "top"
    local x = db and db.countX or 0
    local y = db and db.countY or 0
    if pos == "center" then return "CENTER", "CENTER", x, y end
    if pos == "bottom" then return "TOP", "BOTTOM", x, y - 9 end -- degage la bande du temps (-3..-5 px)
    return "BOTTOM", "TOP", x, y + 4
end
local function ApplyCountPos()
    local p, rp, x, y = CountAnchor()
    count:ClearAllPoints()
    count:SetPoint(p, bar, rp, x, y)
end
ApplyCountPos()

-- Bande du temps restant du buff (option /mw timer) : fine bande verte sous
-- les carres, elle se vide au fil du temps. Hors combat, on l'anime nous-memes
-- depuis expirationTime ; en combat, la lecture des durees etant refusee aux
-- addons (valeurs secretes), c'est la couche native qui prend le relais : un
-- slot dedie ou le moteur remplit la bande (barre d'application) et la
-- consomme avec le temps (SetDurationCooldown, comme les cadrans du jeu).
-- Notre bande se cache alors pour laisser la place a la sienne.
local timerBar = CreateFrame("StatusBar", nil, bar)
timerBar:SetPoint("TOPLEFT", bar, "BOTTOMLEFT", 0, -3)
timerBar:SetPoint("TOPRIGHT", bar, "BOTTOMRIGHT", 0, -3)
timerBar:SetHeight(3)
timerBar:SetFrameLevel(bar:GetFrameLevel() + 1)
timerBar:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")
timerBar:SetMinMaxValues(0, 1)
timerBar:SetValue(1)
timerBar:Hide()
local timerBg = bar:CreateTexture(nil, "BORDER") -- liseré sombre autour de la bande
timerBg:SetPoint("TOPLEFT", timerBar, "TOPLEFT", -1, 1)
timerBg:SetPoint("BOTTOMRIGHT", timerBar, "BOTTOMRIGHT", 1, -1)
SetColor(timerBg, 0, 0, 0, 0.9)
local timerStatic      -- vrai : valeur temoin (mode edition), pas d'animation
local timerStatic      -- vrai : valeur temoin (mode edition), pas d'animation

local function ApplyTimerColor()
    local c = (db and db.colorTimer) or DEFAULTS.colorTimer
    timerBar:SetStatusBarColor(c[1], c[2], c[3], 1)
end
ApplyTimerColor()

timerBar:SetScript("OnUpdate", function(self)
    if timerStatic then return end -- valeur temoin, pas d'animation
    local t = auraTiming
    if not t or not t.duration or t.duration <= 0 or not t.expiration then return end
    local rem = t.expiration - GetTime()
    if rem <= 0 then self:SetValue(0); self:Hide() return end
    self:SetValue(math.min(1, rem / t.duration))
end)

overlay:SetScript("OnDragStart", function() bar:StartMoving() end)
overlay:SetScript("OnDragStop", function()
    bar:StopMovingOrSizing()
    local p, _, rp, x, y = bar:GetPoint()
    db.point, db.relPoint, db.x, db.y = p, rp, x, y
end)

-- Taille des carres (largeur, hauteur, espacement) : reglable dans le panneau
-- d'options et par /mw size. La longueur totale de la barre en decoule :
-- 5 largeurs + 4 espacements.
local NativeChanged -- defini plus bas : reconstruction de la couche native
local function ApplySize()
    if not db then return end
    local w = db.sqW or SQ_W
    local h = db.sqH or SQ_H
    local gap = db.sqGap or SQ_GAP
    bar:SetSize(MAX_STACKS * w + (MAX_STACKS - 1) * gap, h)
    for i = 1, MAX_STACKS do
        local sq = squares[i]
        sq:SetSize(w, h)
        sq:ClearAllPoints()
        sq:SetPoint("LEFT", bar, "LEFT", (i - 1) * (w + gap), 0)
    end
    -- la geometrie de la couche native est figee a sa construction
    if nativeLayer or nativeHost then NativeChanged() end
end

-- Couleur de fond des carres (option /mw color bg, panneau d'options)
local function ApplyBgColor()
    if not db then return end
    local c = db.colorBg or DEFAULTS.colorBg
    for i = 1, MAX_STACKS do SetColor(squares[i].bg, c[1], c[2], c[3], 0.8) end
end

---------------------------------------------------------------- couche native (combat)
-- Le client Forever reserve la lecture des auras au code Blizzard en combat
-- ("valeurs secretes") : aucun addon ne peut y lire le nombre de stacks, ni
-- par l'API des auras, ni par le journal de combat (reserve lui aussi). En
-- revanche, le moteur natif peut piloter des elements d'affichage : on cree
-- un conteneur d'auras (meme mecanisme que l'UI du jeu) dont le slot
-- Maelstrom remplit lui-meme des barres et ecrit le compteur, secret ou pas.
-- Les widgets pilotes doivent naitre dans initializeFrame et deviennent
-- ensuite "interdits" : on les ancre sur nos carres pendant l'init, leur
-- geometrie suit donc /mw size automatiquement. Changer les couleurs ou le
-- compteur impose de reconstruire la couche (hors combat) ; sans cette API
-- (autres clients), il n'y a simplement pas d'affichage en combat.
local nativeHost        -- frame hote : son alpha pilote la visibilite de la couche
local nativeLayer       -- couche construite : { host, fills, count }
local nativeUnavailable -- ce client n'expose pas l'API : pas d'affichage en combat
local nativeDirty       -- reconstruction demandee (attend la fin du combat)
local glowDirty = true               -- declare ici : utilise aussi par NativeChanged (halos)
local ClearGlowNatives               -- defini dans la section halo (pilotes natifs des halos)

-- Formateur du compteur natif : nombre entier (mecanique du jeu).
local function MakeCountFormatter()
    if not (C_StringUtil and C_StringUtil.CreateNumericRuleFormatter
        and Enum and Enum.NumericRuleFormatRounding) then return nil end
    local ok, formatter = pcall(C_StringUtil.CreateNumericRuleFormatter)
    if not ok or not formatter then return nil end
    local down = Enum.NumericRuleFormatRounding.Down
    pcall(formatter.SetBreakpoints, formatter, {
        {
            threshold = 0, min = 0, step = 1, rounding = down, format = "%d",
            components = { { div = 1, step = 1, rounding = down } },
        },
    })
    return formatter
end

local nativeVariant = "squares" -- "squares" : nos carres | "ladder" : diagnostic
local NATIVE_IDS = { [408505] = true, [408498] = true, [53817] = true, [344179] = true }
local nativeSlotMethods -- sonde : methodes Duration/Application vues sur un slot (diagnostic)
local timerCdError     -- echec du branchement voile/compte a rebours (sonde /mw timerdebug)

local function BuildNativeLayer()
    if nativeLayer or nativeUnavailable or not db then return end
    if InCombatLockdown() then return end -- creation hors combat uniquement
    local ok, err = pcall(function()
        local host = CreateFrame("Frame", nil, bar)
        host:SetAllPoints(bar)
        host:SetFrameLevel(bar:GetFrameLevel() + 5)
        host:SetAlpha(0) -- visible seulement en combat (gere par Update)
        local container = CreateFrame("AuraContainer", nil, host, "CustomAuraContainerTemplate")
        container:SetUnit("player")
        local fills, nativeCount = {}, nil
        local w = db.sqW or SQ_W
        local h = db.sqH or SQ_H
        local gap = db.sqGap or SQ_GAP
        local total = MAX_STACKS * w + (MAX_STACKS - 1) * gap
        -- un slot dedie : son frame couvre la zone donnee, une seule barre
        -- (les setters du moteur semblent singuliers par slot), pilotee par
        -- le moteur avec la semantique minApplications/maxApplications
        local function MakeSlot(key, lo, hi, c, x1, y1, x2, y2, withCount, level)
            local slot = container:AddAuraSlot(key, "HELPFUL", {
                candidateFilters = { includeSpellIDs = NATIVE_IDS },
                initializeFrame = function(frame)
                    frame:ClearAllPoints()
                    frame:SetPoint("TOPLEFT", host, "TOPLEFT", x1, y1)
                    frame:SetPoint("BOTTOMRIGHT", host, "TOPLEFT", x2, y2)
                    frame:SetFrameLevel(host:GetFrameLevel() + (level or 1))
                    pcall(frame.SetMouseClickEnabled, frame, false)
                    pcall(frame.EnableMouseMotion, frame, false)
                    local s = CreateFrame("StatusBar", nil, frame)
                    s:SetAllPoints(frame)
                    s:SetFrameLevel(frame:GetFrameLevel() + 1)
                    s:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")
                    s:SetStatusBarColor(c[1], c[2], c[3], 1)
                    frame:SetApplicationBar(s, { minApplications = lo, maxApplications = hi })
                    fills[#fills + 1] = { bar = s, label = key .. " (min=" .. lo .. ", max=" .. hi .. ")" }
                    if withCount and db.showCount then
                        -- compteur natif : le moteur ecrit le nombre lui-meme,
                        -- a la meme position que notre compteur
                        nativeCount = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
                        local p, rp, cx, cy = CountAnchor()
                        nativeCount:SetPoint(p, host, rp, cx, cy)
                        nativeCount:SetTextColor(1, 1, 1)
                        frame:SetApplicationCount(nativeCount, { formatter = MakeCountFormatter() })
                    end
                end,
            })
            if not slot then error("slot " .. key .. " unavailable") end
            return slot
        end
        if nativeVariant == "ladder" then
            -- diagnostic : six slots, un par rangée, une semantique chacun.
            -- Rouge min=0..5, orange 1..5, jaune 2..5, vert 3..5, cyan 4..5,
            -- blanc 5..5 (la semantique exacte de ForeverTotems). La rangeree
            -- qui bouge en combat revele la semantique ; si une seule bouge,
            -- un seul slot peut matcher l'aura ; si aucune, le moteur ne
            -- pilote pas nos barres du tout.
            local rows = {
                { 0, { 1, 0.2, 0.2 } }, { 1, { 1, 0.5, 0.2 } }, { 2, { 1, 0.9, 0.2 } },
                { 3, { 0.3, 1, 0.3 } }, { 4, { 0.2, 0.8, 1 } }, { 5, { 1, 1, 1 } },
            }
            local rh = h / #rows
            for r, cfg in ipairs(rows) do
                MakeSlot("mwtest" .. r, cfg[1], 5, cfg[2], 0, -(r - 1) * rh, total, -(r * rh), r == 1)
            end
        else
            -- nos cinq carres : deux slots par carre (remplissage min..max =
            -- i-1..i, plein des que stacks >= i ; puis la barre "plein" 4..5
            -- par-dessus), comme nos propres StatusBars
            local cn = db.colorNormal or DEFAULTS.colorNormal
            local cf = db.colorFull or DEFAULTS.colorFull
            for i = 1, MAX_STACKS do
                local x = (i - 1) * (w + gap)
                -- inset de 2 px comme nos propres remplissages : le contour
                -- (liseré + fond) du carre reste visible autour du remplissage.
                -- La barre "plein" est a un niveau de frame superieur : elle
                -- recouvre le remplissage normal a 5 stacks (couleur maximum)
                MakeSlot("mwsq" .. i, i - 1, i, cn, x + 2, -2, x + w - 2, -(h - 2), i == 1, 1)
                MakeSlot("mwfull" .. i, MAX_STACKS - 1, MAX_STACKS, cf, x + 2, -2, x + w - 2, -(h - 2), false, 3)
            end
        end
        -- bande du temps restant en combat (option /mw timer) : slot dans le
        -- CONTENEUR PRINCIPAL (un seul conteneur par aura : deux conteneurs
        -- distincts semblaient faire traiter chaque dose deux fois par le
        -- moteur, d'ou un remplissage transitoire un carre trop haut).
        -- Le moteur y pilote trois choses :
        --  - le remplissage vert (barre d'application min=0 max=1, la
        --    semantique du premier carre) : plein des 1 stack, vide sinon ;
        --  - un cadran de duree (SetDurationCooldown) qui, sur les clients
        --    modernes, peut se rendre en barre lineaire (SetDisplayAsDurationBar) ;
        --  - un compte a rebours texte sous la bande (SetDurationText).
        if db.showTimer ~= false then
            local ct = db.colorTimer or DEFAULTS.colorTimer
            local tslot = container:AddAuraSlot("mwtimer", "HELPFUL", {
                candidateFilters = { includeSpellIDs = NATIVE_IDS },
                initializeFrame = function(frame)
                    frame:ClearAllPoints()
                    -- deux coins explicites, comme les carres (largeur = barre, hauteur 3 px)
                    frame:SetPoint("TOPLEFT", host, "BOTTOMLEFT", 0, -3)
                    frame:SetPoint("BOTTOMRIGHT", host, "BOTTOMLEFT", total, -6)
                    frame:SetFrameLevel(host:GetFrameLevel() + 1)
                    pcall(frame.SetMouseClickEnabled, frame, false)
                    pcall(frame.EnableMouseMotion, frame, false)
                    -- sonde : methodes exposees par le frame du slot
                    nativeSlotMethods = nativeSlotMethods or {}
                    for _, m in ipairs({ "SetApplicationBar", "SetApplicationCount",
                        "SetDurationCooldown", "SetDurationText", "SetDurationBar" }) do
                        nativeSlotMethods[m] = (frame[m] ~= nil) or nativeSlotMethods[m]
                    end
                    local back = frame:CreateTexture(nil, "BACKGROUND")
                    back:SetAllPoints(frame)
                    back:SetTexture("Interface\\Buttons\\WHITE8X8")
                    back:SetVertexColor(0, 0, 0, 0.9)
                    -- remplissage vert : plein des qu'il y a au moins 1 stack
                    local s = CreateFrame("StatusBar", nil, frame)
                    s:SetAllPoints(frame)
                    s:SetFrameLevel(frame:GetFrameLevel() + 1)
                    s:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")
                    s:SetStatusBarColor(ct[1], ct[2], ct[3], 1)
                    frame:SetApplicationBar(s, { minApplications = 0, maxApplications = 1 })
                    fills[#fills + 1] = { bar = s, label = "mwtimer (min=0, max=1)" }
                    local okCd, errCd = pcall(function()
                        local cd = CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
                        cd:SetAllPoints(frame)
                        cd:SetFrameLevel(frame:GetFrameLevel() + 2)
                        -- clients modernes : le cadran peut se rendre en barre de
                        -- duree lineaire (fin bandeau qui se vide) plutot qu'en
                        -- balayage circulaire — c'est exactement ce qu'on veut
                        -- pour une bande de 3 px
                        if cd.SetDisplayAsDurationBar then cd:SetDisplayAsDurationBar(true) end
                        if cd.SetSwipeColor then cd:SetSwipeColor(0, 0, 0, 0.75) end
                        if cd.SetDrawEdge then cd:SetDrawEdge(true) end
                        pcall(cd.SetHideCountdownNumbers, cd, true)
                        frame:SetDurationCooldown(cd)
                        -- compte a rebours texte : le moteur ecrit les secondes
                        local txt = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                        txt:SetPoint("TOP", host, "BOTTOM", 0, -8)
                        txt:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
                        txt:SetTextColor(1, 1, 1)
                        local formatter
                        if C_StringUtil and C_StringUtil.CreateNumericRuleFormatter
                            and Enum and Enum.NumericRuleFormatRounding then
                            local down = Enum.NumericRuleFormatRounding.Down
                            local f = C_StringUtil.CreateNumericRuleFormatter()
                            f:SetBreakpoints({ {
                                threshold = 0, min = 0, step = 1, rounding = down,
                                format = "%d",
                                components = { { div = 1, step = 1, rounding = down } },
                            } })
                            formatter = f
                        end
                        frame:SetDurationText(txt, { textFormatter = formatter })
                        -- essai : barre de duree lineaire, si le client l'expose.
                        -- Voile sombre par-dessus le vert : la bande semble se
                        -- vider au fil du temps (sens ajustable ensuite).
                        if frame.SetDurationBar then
                            local s2 = CreateFrame("StatusBar", nil, frame)
                            s2:SetAllPoints(frame)
                            s2:SetFrameLevel(frame:GetFrameLevel() + 3)
                            s2:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")
                            s2:SetStatusBarColor(0, 0, 0, 0.55)
                            frame:SetDurationBar(s2)
                        end
                    end)
                    if not okCd then
                        timerCdError = tostring(errCd):gsub("\n.*", "")
                    end
                end,
            })
            if not tslot then error("timer slot unavailable") end
        end
        nativeHost, nativeLayer = host, { host = host, fills = fills, count = nativeCount }
    end)
    if not ok then
        if nativeHost then nativeHost:Hide() end
        nativeHost, nativeLayer = nil, nil
        nativeUnavailable = true
        -- l'echec etait silencieux : le montrer une fois pour le diagnostic
        local msg = tostring(err):gsub("\n.*", "")
        if #msg > 200 then msg = msg:sub(1, 200) .. "..." end
        print(PREFIX .. "couche native indisponible : " .. msg)
    end
end

-- A appeler quand les couleurs, le compteur ou la taille changent :
-- reconstruit la couche native hors combat, sinon juste apres le combat.
NativeChanged = function()
    if nativeUnavailable then return end
    if InCombatLockdown() then nativeDirty = true; return end
    if nativeHost then nativeHost:Hide() end -- l'ancienne couche est abandonnee
    nativeHost, nativeLayer = nil, nil
    BuildNativeLayer()
    -- les pilotes natifs des halos portent la couleur du halo : les refaire
    if ClearGlowNatives then ClearGlowNatives() end
    glowDirty = true
end

-- Poignee de deplacement du compteur (mode edition) : glisser le chiffre
-- enregistre son decalage par rapport a sa position choisie ; le compteur
-- natif (combat) est reconstruit a l'arret du glissement.
local countDrag = CreateFrame("Frame", nil, bar)
countDrag:SetFrameLevel(overlay:GetFrameLevel() + 1)
countDrag:EnableMouse(true)
countDrag:RegisterForDrag("LeftButton")
countDrag:SetPoint("TOPLEFT", count, "TOPLEFT", -8, 8)
countDrag:SetPoint("BOTTOMRIGHT", count, "BOTTOMRIGHT", 8, -8)
countDrag.tex = countDrag:CreateTexture(nil, "OVERLAY")
countDrag.tex:SetAllPoints()
SetColor(countDrag.tex, 0.2, 0.8, 0.3, 0.35)
countDrag:Hide()
countDrag:SetScript("OnDragStart", function()
    local x, y = GetCursorPosition()
    local scale = (bar.GetEffectiveScale and bar:GetEffectiveScale()) or 1
    countDrag.startX, countDrag.startY = x / scale, y / scale
    countDrag.baseX, countDrag.baseY = db.countX or 0, db.countY or 0
    countDrag:SetScript("OnUpdate", function()
        local x, y = GetCursorPosition()
        local scale = (bar.GetEffectiveScale and bar:GetEffectiveScale()) or 1
        db.countX = math.max(-200, math.min(200, math.floor(countDrag.baseX + x / scale - countDrag.startX + 0.5)))
        db.countY = math.max(-100, math.min(100, math.floor(countDrag.baseY + y / scale - countDrag.startY + 0.5)))
        ApplyCountPos()
    end)
end)
countDrag:SetScript("OnDragStop", function()
    countDrag:SetScript("OnUpdate", nil)
    NativeChanged() -- compteur natif : reconstruction a la nouvelle position
end)

---------------------------------------------------------------- halo sur la barre d'action
-- glowDirty est declare plus haut (section couche native)
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

-- Macros : le texte est lu et le sort a surligner y est cherche. Les macros
-- avec #showtooltip, les conditions [nobuff:...] et les sequences
-- (/castsequence reset=5 Sort1, Sort2) sont gerees ; /cast Sort1; Sort2 aussi.
local function MacroBody(macroId)
    if GetMacroBody then
        local ok, body = pcall(GetMacroBody, macroId)
        if ok and type(body) == "string" then return body end
    end
    if GetMacroInfo then
        local ok, _, _, body = pcall(GetMacroInfo, macroId)
        if ok and type(body) == "string" then return body end
    end
    return nil
end

local MACRO_CAST = {
    ["cast"] = true, ["use"] = true, ["spell"] = true,
    ["lancer"] = true, ["utiliser"] = true, -- commandes frFR
}

local function MacroClauseMatches(clause)
    clause = clause:gsub("^%s+", ""):gsub("%s+$", "")
    if clause == "" then return false end
    local id = tonumber(clause)
    if id and glowTargets[id] then return true end
    return glowTargets[clause] == true
end

local function MacroMatches(macroId)
    local body = MacroBody(macroId)
    if not body then return false end
    for line in gmatch(body, "[^\r\n]+") do
        line = line:lower():gsub("^%s+", "")
        local cmd, rest = line:match("^/(%a+)%s*(.*)$")
        if cmd and rest ~= "" then
            rest = rest:gsub("%b[]%s*", "") -- conditions [combat], [nobuff:...] ignorees
            if MACRO_CAST[cmd] then
                for clause in gmatch(rest, "([^;]+)") do
                    if MacroClauseMatches(clause) then return true end
                end
            elseif cmd == "castsequence" then
                rest = rest:gsub("reset=%s*[%w%/]+%s*", "")
                for clause in gmatch(rest, "([^,]+)") do
                    if MacroClauseMatches(clause) then return true end
                end
            end
        end
    end
    return false
end

local function SlotMatches(slot)
    if not slot then return false end
    local t, id = GetActionInfo(slot)
    if t == "spell" then
        return SpellMatches(id)
    elseif t == "macro" then
        return MacroMatches(id)
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

-- Boutons d'UI non standard (UI manette notamment) : les prefixes de barres
-- connus ne couvrent pas leurs frames. On balaye les boutons globaux et on
-- retient ceux dont l'action (slot) ou le sort (attribut "spell") correspond.
-- Le balayage est mis en cache 5 s : il n'est refait qu'au besoin.
local globalButtons
local globalButtonsTime = 0

local function FrameMatchesGlow(f)
    local ok, a = pcall(ButtonAction, f)
    local slot = ok and tonumber(a) or nil
    if slot and SlotMatches(slot) then return true end
    if f.GetAttribute then
        local okS, sp = pcall(f.GetAttribute, f, "spell")
        if okS and type(sp) == "number" then return SpellMatches(sp) end
        if okS and type(sp) == "string" then
            return glowTargets[sp:lower()] == true or glowTargets[tonumber(sp)] == true
        end
    end
    return false
end

local function GlobalButtons()
    if globalButtons and (time() - globalButtonsTime) < 5 then return globalButtons end
    local found = {}
    for _, f in pairs(_G) do
        if type(f) == "table" and f.GetAttribute and f.IsShown then
            local ok, isBtn = pcall(f.IsObjectType, f, "Button")
            if ok and isBtn then found[#found + 1] = f end
        end
    end
    globalButtons, globalButtonsTime = found, time() or 0
    return found
end

local function CollectGlowButtons()
    local list, seen = {}, {}
    local function Try(btn)
        if btn and btn.IsShown and not seen[btn] and SlotMatches(ButtonAction(btn)) then
            seen[btn] = true
            list[#list + 1] = btn
        end
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
        if f and f.IsShown and not seen[f] then seen[f] = true; list[#list + 1] = f end
    end
    -- filet de securite pour les UI non standard (UI manette notamment) :
    -- boutons globaux dont l'action ou le sort correspond
    for _, f in ipairs(GlobalButtons()) do
        if not seen[f] and FrameMatchesGlow(f) then
            local ok, shown = pcall(f.IsShown, f)
            if ok and shown then seen[f] = true; list[#list + 1] = f end
        end
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

-- Pilote natif des halos : en combat, le moteur du client remplit aussi les
-- couches du halo (un slot par couche, barre visible a 5 stacks, min=max).
-- La creation n'est possible que hors combat ; un halo apparu en combat
-- recoit son pilote a la fin du combat (glowNativePending).
local glowNatives = {}  -- par bouton : frame hote du pilote (false : echec)
local glowNativePending -- true : des halos attendent leur pilote

ClearGlowNatives = function()
    for btn, host in pairs(glowNatives) do
        if host then host:Hide() end
        glowNatives[btn] = nil
    end
end

local function AttachGlowNative(btn, g)
    if glowNatives[btn] ~= nil then return end
    if nativeUnavailable then glowNatives[btn] = false; return end
    if InCombatLockdown() then glowNativePending = true; return end
    local ok = pcall(function()
        local w = btn:GetWidth(); if not w or w < 10 then w = 36 end
        local h = btn:GetHeight(); if not h or h < 10 then h = 36 end
        local host = CreateFrame("Frame", nil, g)
        host:SetAllPoints(g)
        host:SetFrameLevel(g:GetFrameLevel() + 1)
        host:SetAlpha(0) -- visible en combat seulement (bascule par RefreshGlow)
        local container = CreateFrame("AuraContainer", nil, host, "CustomAuraContainerTemplate")
        container:SetUnit("player")
        local c = db.colorGlow or DEFAULTS.colorGlow
        local layers = {
            { "Interface\\Buttons\\UI-ActionButton-Border", w * 2.1, h * 2.1, 1 },
            { "Interface\\Buttons\\UI-ActionButton-Border", w * 1.8, h * 1.8, 1 },
            { "Interface\\Buttons\\WHITE8X8", w, h, 0.4 },
        }
        for li, L in ipairs(layers) do
            local slot = container:AddAuraSlot("mwglow" .. li, "HELPFUL", {
                candidateFilters = { includeSpellIDs = NATIVE_IDS },
                initializeFrame = function(frame)
                    frame:ClearAllPoints()
                    frame:SetSize(L[2], L[3])
                    frame:SetPoint("CENTER", g, "CENTER", 0, 0)
                    frame:SetFrameLevel(host:GetFrameLevel() + 1)
                    pcall(frame.SetMouseClickEnabled, frame, false)
                    pcall(frame.EnableMouseMotion, frame, false)
                    local s = CreateFrame("StatusBar", nil, frame)
                    s:SetAllPoints(frame)
                    s:SetStatusBarTexture(L[1])
                    local t = s:GetStatusBarTexture()
                    if t and t.SetBlendMode then t:SetBlendMode("ADD") end
                    s:SetAlpha(L[4])
                    s:SetStatusBarColor(c[1], c[2], c[3], 1)
                    -- le moteur rend la couche visible a 5 stacks (min=max,
                    -- meme mecanisme que l'indicateur "pret" de l'UI du jeu)
                    frame:SetApplicationBar(s, { minApplications = MAX_STACKS, maxApplications = MAX_STACKS })
                end,
            })
            if not slot then error("glow slot unavailable") end
        end
        glowNatives[btn] = host
    end)
    if not ok then glowNatives[btn] = false end
end

local lastWant = false
local function RefreshGlow(stacks)
    -- Les halos restent poses sur les boutons tant que l'option est active ;
    -- c'est la valeur des StatusBar qui les rend visibles a 5 stacks. En
    -- combat, la valeur vient du pilote natif (moteur du client) : nos
    -- couches y restent vides et le pilote prend le relais visuellement.
    local want = db.glow and true or false
    if want ~= lastWant or glowDirty then
        lastWant, glowDirty = want, false
        HideGlows()
        ClearGlowNatives() -- boutons ou couleurs changes : pilotes obsoletes
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
                AttachGlowNative(btn, g)
            end
        end
    end
    local combat = UnitAffectingCombat("player")
    for btn in pairs(glowActive) do
        local g = glowFrames[btn]
        local host = glowNatives[btn]
        if host then host:SetAlpha(combat and 1 or 0) end
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

    -- Couche native (clients Forever) : en combat, le moteur du client pilote
    -- lui-meme les barres et le compteur du slot d'aura, secret ou pas ; nos
    -- propres remplissages se cachent pour lui laisser la place. Hors combat,
    -- en mode test ou en mode edition, le fonctionnement habituel reprend.
    local nativeActive = nativeLayer and inCombat and not testStacks and not unlocked

    -- Valeur secrete : aucune comparaison possible (barre toujours visible)
    RefreshGlow(stacks)

    if unlocked or db.alwaysShow or inCombat or secret or stacks > 0 then
        bar:Show()
    else
        bar:Hide()
        return
    end

    -- Compteur optionnel : une valeur secrete ne peut pas devenir du texte ;
    -- en combat la couche native fournit son propre compteur (moteur).
    -- En mode edition, un chiffre temoin reste visible et se deplace au doigt.
    if db.showCount then
        if unlocked then
            count:SetText((type(stacks) == "number" and stacks > 0) and tostring(stacks) or "5")
            count:Show()
        elseif nativeActive then
            count:Hide()
        else
            local n = stacks
            if type(n) == "number" and n > 0 then
                count:SetText(tostring(n))
                count:Show()
            else
                count:Hide()
            end
        end
    else
        count:Hide()
    end
    if unlocked and db.showCount then countDrag:Show() else countDrag:Hide() end

    -- Bande du temps restant : temoin en mode edition. Hors combat, notre
    -- animation depuis expirationTime ; en combat, c'est la bande de la couche
    -- native (slot dedie : remplissage + voile pilotes par le moteur) qui
    -- prend le relais — notre propre bande se cache pour lui laisser la place.
    if not db.showTimer then
        timerBar:Hide()
    elseif unlocked then
        timerStatic = true
        timerBar:SetValue(0.65)
        timerBar:Show()
    else
        timerStatic = false
        if nativeActive then
            timerBar:Hide()
        elseif type(stacks) == "number" and stacks > 0 and auraTiming then
            timerBar:Show()
        else
            timerBar:Hide()
        end
    end

    if nativeActive then
        -- le moteur natif remplit les barres du slot : cachons les notres
        nativeHost:SetAlpha(1)
        for i = 1, MAX_STACKS do
            squares[i].fill:Hide()
            squares[i].fullFill:Hide()
        end
    else
        if nativeHost then nativeHost:SetAlpha(0) end
        local n, f = db.colorNormal, db.colorFull
        for i = 1, MAX_STACKS do
            local sq = squares[i]
            sq.fill:Show()
            sq.fullFill:Show()
            sq.fill:SetStatusBarColor(n[1], n[2], n[3], 1)
            sq.fullFill:SetStatusBarColor(f[1], f[2], f[3], 1)
            sq.fill:SetValue(stacks)
            sq.fullFill:SetValue(stacks)
        end
    end
end


---------------------------------------------------------------- mise a jour en temps reel
-- Les seuls evenements d'auras ne suffisent pas : UNIT_AURA est retarde (maj
-- regroupees) sur les clients recents, et peut etre muet en combat sur ceux qui
-- cachent les auras du joueur. La barre restait alors figee jusqu'au prochain
-- evenement. On complete donc par une lecture rapide et permanente (~20 fois
-- par seconde) : quelques lectures d'aura par tick, les StatusBar acceptent les
-- valeurs secretes, le cout est negligeable.
local updateTicker
local function StartRealtimeUpdates()
    if updateTicker or not (C_Timer and C_Timer.NewTicker) then return end
    updateTicker = C_Timer.NewTicker(0.05, function()
        if db and active then Update() end
    end)
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
    local root = CreateFrame("Frame", "MaelstromBarOptionsPanel", UIParent)
    root.name = "MaelstromBar"
    -- Le contenu du panneau depasse la hauteur affichable : il est construit
    -- dans une frame deroulante (ascenseur a droite, molette).
    local scroll = CreateFrame("ScrollFrame", nil, root, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 4, -4)
    scroll:SetPoint("BOTTOMRIGHT", -4, 4)
    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(560, 800) -- largeur ajustee a l'affichage, hauteur en fin de construction
    scroll:SetScrollChild(content)
    local panel = content -- tout ce qui suit est construit dans la zone deroulante
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
                if key == "colorBg" then ApplyBgColor() end
                if key == "colorTimer" then ApplyTimerColor(); NativeChanged() end
                if key == "colorNormal" or key == "colorFull" then NativeChanged() end
                paint(); Update()
            end
            local function cancel()
                db[key] = { old[1], old[2], old[3] }
                glowDirty = true
                if key == "colorBg" then ApplyBgColor() end
                if key == "colorTimer" then ApplyTimerColor(); NativeChanged() end
                if key == "colorNormal" or key == "colorFull" then NativeChanged() end
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

    -- Affichage en combat : sur ce client, les auras du joueur sont secretes
    -- en combat et seul le moteur du jeu peut les afficher. Le panneau montre
    -- si la couche native est active (elle se construit hors combat).
    do
        Label(T("In combat"), "GameFontNormal", 16, y); y = y - 22
        local st = Label("", "GameFontHighlight", 16, y)
        local function RefreshCombatPanel()
            if nativeLayer then
                st:SetText(T("The stacks are displayed in combat by the game engine itself: no configuration is needed."))
                st:SetTextColor(0.35, 1, 0.35)
            elseif nativeUnavailable then
                st:SetText(T("this client does not let the addon display the stacks in combat."))
                st:SetTextColor(1, 0.55, 0.2)
            else
                st:SetText(T("The combat display is built out of combat; it will be ready for the next fight."))
                st:SetTextColor(1, 0.8, 0.2)
            end
        end
        refreshers[#refreshers + 1] = RefreshCombatPanel
        y = y - 30
    end

    Check(T("Unlock the bar to move it (/mw move)"),
        function() return unlocked end, function(v) SetUnlocked(v) end)
    Check(T("Always show the bar (/mw always)"),
        function() return db.alwaysShow end, function(v) db.alwaysShow = v; Update() end)
    Check(T("Show the stack count on the bar (/mw count)"),
        function() return db.showCount end, function(v) db.showCount = v; NativeChanged(); Update() end)
    Check(T("Show the remaining time bar (/mw timer)"),
        function() return db.showTimer end, function(v) db.showTimer = v; NativeChanged(); Update() end)

    y = y - 6
    Label(T("Colors (/mw color)"), "GameFontNormal"); y = y - 26
    ColorRow(T("Stacks 1 to 4"), "colorNormal")
    ColorRow(T("5 stacks (maximum)"), "colorFull")
    ColorRow(T("Bar background"), "colorBg")
    ColorRow(T("Remaining time bar"), "colorTimer")
    ColorRow(T("Spell glow"), "colorGlow")
    Button(T("Default colors"), 150, 16, y, function()
        for _, key in ipairs({ "colorNormal", "colorFull", "colorBg", "colorTimer", "colorGlow" }) do
            local d = DEFAULTS[key]
            db[key] = { d[1], d[2], d[3] }
        end
        glowDirty = true
        ApplyBgColor()
        ApplyTimerColor()
        NativeChanged()
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

    Label(T("Size (/mw size)"), "GameFontNormal"); y = y - 26
    local function Stepper(text, key, lo, hi)
        Label(T(text), "GameFontHighlight", 20, y)
        local val = Label("", "GameFontHighlight", 230, y - 6)
        local function Set(v)
            v = math.max(lo, math.min(hi, math.floor(v + 0.5)))
            db[key] = v
            ApplySize()
            val:SetText(tostring(v))
        end
        refreshers[#refreshers + 1] = function() val:SetText(tostring(db[key])) end
        Button("-", 30, 260, y, function() Set(db[key] - 1) end)
        Button("+", 30, 300, y, function() Set(db[key] + 1) end)
        y = y - 26
    end
    Stepper("Square width", "sqW", 10, 80)
    Stepper("Square height", "sqH", 6, 60)
    Stepper("Spacing between squares", "sqGap", 0, 30)
    Button(T("Default size"), 120, 20, y, function()
        db.sqW, db.sqH, db.sqGap = SQ_W, SQ_H, SQ_GAP
        ApplySize()
        for _, f in ipairs(refreshers) do f() end
    end)
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

    Button(T("Reset position and size (/mw reset)"), 260, 16, y, function()
        db.point, db.relPoint, db.x, db.y = DEFAULTS.point, DEFAULTS.relPoint, DEFAULTS.x, DEFAULTS.y
        db.sqW, db.sqH, db.sqGap = SQ_W, SQ_H, SQ_GAP
        ApplySize()
        SetScale(1)
    end)

    -- hauteur du contenu = hauteur reellement utilisee par les widgets
    content:SetHeight(-y + 16)

    root:SetScript("OnShow", function()
        -- largeur = zone visible moins l'ascenseur
        content:SetWidth(math.max((scroll:GetWidth() or 590) - 30, 500))
        for _, f in ipairs(refreshers) do f() end
    end)

    if Settings and Settings.RegisterCanvasLayoutCategory then
        local category = Settings.RegisterCanvasLayoutCategory(root, root.name)
        Settings.RegisterAddOnCategory(category)
        openOptions = function() Settings.OpenToCategory(category:GetID()) end
    elseif InterfaceOptions_AddCategory then
        root:SetSize(580, 500)
        InterfaceOptions_AddCategory(root)
        openOptions = function()
            InterfaceOptionsFrame_OpenToCategory(root)
            InterfaceOptionsFrame_OpenToCategory(root)
        end
    end
end

---------------------------------------------------------------- evenements
local ev = CreateFrame("Frame")
ev:RegisterEvent("PLAYER_LOGIN")
ev:SetScript("OnEvent", function(self, event, unit, ...)
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
        InstallErrorLog()

        -- Nom localise du sort, quelle que soit la langue du client
        local locName
        if C_Spell and C_Spell.GetSpellName then
            locName = C_Spell.GetSpellName(408505)
        elseif GetSpellInfo then
            locName = GetSpellInfo(408505)
        end
        if locName then NAMES[locName:lower()] = true end

        ApplyPosition()
        ApplySize()
        ApplyBgColor()
        BuildOptions()
        BuildGlowTargets()
        BuildNativeLayer()
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
        StartRealtimeUpdates()
    elseif event == "UNIT_AURA" then
        if unit == "player" then
            lastAuraUpdateInfo = ... -- charge utile (clients recents), sonde /mw timerdebug
            Update()
        end
    else
        if event == "PLAYER_REGEN_ENABLED" then
            -- couleurs, compteur ou halos changes en combat : reconstruire
            if nativeDirty then
                nativeDirty = false
                NativeChanged()
            end
            if glowNativePending then
                -- halos crees en combat : leurs slots natifs attendaient
                glowNativePending = false
                glowDirty = true
            end
        end
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
        -- /mw setup : etat de l'affichage en combat (couche native du client)
        if nativeLayer then
            print(PREFIX .. T("in combat the game engine itself displays the stacks: everything is fine."))
        elseif nativeUnavailable then
            print(PREFIX .. T("this client does not let the addon display the stacks in combat."))
        elseif InCombatLockdown() then
            print(PREFIX .. T("the combat display is built out of combat; try again after combat."))
        else
            print(PREFIX .. T("the combat display is not built yet; type /mw native for details."))
        end
    elseif cmd == "native" then
        -- /mw native : etat et sonde des barres natives — a lancer EN COMBAT,
        -- stacks actives, pour voir ce que le moteur a ecrit. Variantes :
        -- /mw native ladder (diagnostic de semantique), /mw native squares
        -- (nos carres), /mw native retry (reessai apres un echec).
        local rebuild = false
        if arg == "ladder" or arg == "etalon" or arg == "echelle" then
            nativeVariant, rebuild = "ladder", true
        elseif arg == "squares" or arg == "carres" then
            nativeVariant, rebuild = "squares", true
        elseif arg == "retry" or arg == "reessayer" then
            nativeUnavailable, rebuild = nil, true
        end
        if rebuild then
            if nativeHost then nativeHost:Hide() end
            nativeHost, nativeLayer = nil, nil
            BuildNativeLayer()
        end
        if nativeLayer then
            print(PREFIX .. "couche native : construite (variante " .. nativeVariant .. ")")
            for _, f in ipairs(nativeLayer.fills or {}) do
                local s = f.bar
                local okS, sh = pcall(s.IsShown, s)
                local okV, v = pcall(s.GetValue, s)
                if okV and issecretvalue and issecretvalue(v) then v = "<secret>" end
                local okM, mn, mx = pcall(s.GetMinMaxValues, s)
                print(PREFIX .. "  " .. f.label .. " : visible=" .. ((okS and tostring(sh)) or "erreur")
                    .. " | valeur=" .. ((okV and tostring(v)) or "erreur")
                    .. " | minmax=" .. ((okM and (tostring(mn) .. ".." .. tostring(mx))) or "erreur"))
            end
        elseif nativeUnavailable then
            print(PREFIX .. "couche native : indisponible sur ce client, /mw native retry pour reessayer")
        elseif InCombatLockdown() then
            print(PREFIX .. "couche native : non construite, en combat (elle se construit hors combat)")
        else
            print(PREFIX .. "couche native : non construite"
                .. (nativeDirty and " (reconstruction a la fin du combat)" or ""))
        end
        Update()
    elseif cmd == "timerdebug" then
        -- /mw timerdebug : sonde de la bande du temps. A lancer avec des stacks
        -- actives, hors combat d'abord, puis en combat, et comparer les sorties.
        local function desc(v, k)
            if v == nil then return k .. "=nil" end
            if issecretvalue and issecretvalue(v) then return k .. "=<secret>" end
            return k .. "=" .. tostring(v)
        end
        print(PREFIX .. "GetTime()=" .. tostring(GetTime())
            .. " | combat=" .. tostring(UnitAffectingCombat("player")))
        local a
        if C_UnitAuras and C_UnitAuras.GetPlayerAuraBySpellID then
            for id in pairs(SPELL_IDS) do
                local okA, r = pcall(C_UnitAuras.GetPlayerAuraBySpellID, id)
                if okA and r then a = r break end
            end
        end
        if not a then
            print(PREFIX .. "aura introuvable ou lecture refusee")
        else
            print(PREFIX .. desc(a.applications, "applications") .. "  "
                .. desc(a.duration, "duration") .. "  "
                .. desc(a.expirationTime, "expiration") .. "  "
                .. desc(a.auraInstanceID, "instance"))
        end
        print(PREFIX .. "auraTiming: " .. (auraTiming
            and ("duration=" .. tostring(auraTiming.duration)
                .. " expiration=" .. tostring(auraTiming.expiration)) or "nil"))
        print(PREFIX .. "mwInstanceID: " .. tostring(mwInstanceID))
        print(PREFIX .. "charge UNIT_AURA : " .. tostring(lastAuraUpdateInfo))
        if type(lastAuraUpdateInfo) == "table" then
            local parts = {}
            for k, v in pairs(lastAuraUpdateInfo) do
                local tv = type(v)
                if tv == "table" then parts[#parts + 1] = k .. "(#" .. #v .. ")"
                elseif tv == "boolean" then parts[#parts + 1] = k .. "=" .. tostring(v)
                else parts[#parts + 1] = k .. "(" .. tv .. ")" end
            end
            print(PREFIX .. "  cles : " .. table.concat(parts, ", "))
            -- listes d'instances : si elles sont lisibles en combat, l'addon peut
            -- suivre les reapplications du buff sans lire l'aura elle-meme
            for _, k in ipairs({ "updatedAuraInstanceIDs", "removedAuraInstanceIDs", "addedAuras" }) do
                local list = lastAuraUpdateInfo[k]
                if type(list) == "table" then
                    local shown = {}
                    for i, id in ipairs(list) do
                        if i > 10 then shown[#shown + 1] = "..."; break end
                        if type(id) == "table" then
                            local sid = id.spellId
                            shown[#shown + 1] = (issecretvalue and issecretvalue(sid)) and "aura<secret>" or ("aura" .. tostring(sid))
                        else
                            shown[#shown + 1] = (issecretvalue and issecretvalue(id)) and "<secret>" or tostring(id)
                        end
                    end
                    print(PREFIX .. "  " .. k .. " : " .. table.concat(shown, ", "))
                end
            end
        end
        print(PREFIX .. "GetAuraDuration: " .. tostring(C_UnitAuras and C_UnitAuras.GetAuraDuration)
            .. " | SetTimerDuration: " .. tostring(timerBar.SetTimerDuration)
            .. " | direction: " .. tostring(Enum and Enum.StatusBarTimerDirection))
        if mwInstanceID and C_UnitAuras and C_UnitAuras.GetAuraDuration then
            local ok, obj = pcall(C_UnitAuras.GetAuraDuration, "player", mwInstanceID)
            print(PREFIX .. "objet duree : ok=" .. tostring(ok) .. " obj=" .. tostring(obj)
                .. " type=" .. type(obj))
            -- NB : plus d'essai SetTimerDuration ici : l'essai confisquait la
            -- bande au profit du moteur (valeur figee a 0 jusqu'au /reload).
        end
        print(PREFIX .. "timerBar : visible=" .. tostring(timerBar:IsShown())
            .. " valeur=" .. tostring(timerBar:GetValue())
            .. " statique=" .. tostring(timerStatic))
        if type(nativeSlotMethods) == "table" then
            local parts = {}
            for k, v in pairs(nativeSlotMethods) do parts[#parts + 1] = k .. "=" .. tostring(v) end
            table.sort(parts)
            print(PREFIX .. "methodes du slot natif : " .. table.concat(parts, ", "))
        end
        if timerCdError then
            print(PREFIX .. "branchement voile/compte a rebours : " .. timerCdError)
        end
        if C_Timer and C_Timer.After then
            C_Timer.After(1, function()
                print(PREFIX .. "timerBar apres 1 s : valeur=" .. tostring(timerBar:GetValue())
                    .. " (si identique, la bande n'est pas animee)")
            end)
        end
    elseif cmd == "log" then
        -- /mw log : relire les erreurs Lua enregistrees ; /mw log clear : vider
        db.errors = db.errors or {}
        if arg == "clear" or arg == "vider" then
            db.errors = {}
            print(PREFIX .. T("log cleared"))
        elseif #db.errors == 0 then
            print(PREFIX .. T("no Lua errors recorded"))
        else
            print(PREFIX .. string.format(T("%d Lua error(s) recorded, most recent first (/mw log clear to wipe)"), #db.errors))
            for i = #db.errors, 1, -1 do
                local e = db.errors[i]
                local ts = (date and date("%Y-%m-%d %H:%M:%S", e.t or 0)) or tostring(e.t or 0)
                print(string.format("#%d x%d  %s  %s", i, e.count or 1, ts, e.msg or "?"))
                if e.stack and e.stack ~= "" then
                    for line in gmatch(e.stack, "[^\n]+") do print("  " .. line) end
                end
            end
        end
    elseif cmd == "testerror" then
        -- declenche volontairement une erreur : elle doit apparaitre dans /mw log
        -- (et dans BugSack / la fenetre d'erreurs). Permet de verifier la chaine.
        error("MaelstromBar: test error, it should show up in /mw log")
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
    elseif cmd == "glowscan" then
        -- /mw glowscan : lister les boutons que l'addon peut surligner
        local list = CollectGlowButtons()
        if #list == 0 then
            print(PREFIX .. T("no button found for the glow; hover the button and use /fstack, then /mw glowframe <FrameName>"))
        else
            print(PREFIX .. string.format(T("%d button(s) found for the glow:"), #list))
            for _, btn in ipairs(list) do
                local ok, name = pcall(btn.GetName, btn)
                print("  " .. ((ok and name) or tostring(btn)))
            end
        end
    elseif cmd == "options" or cmd == "config" then
        if openOptions then openOptions() else print(PREFIX .. T("options panel unavailable")) end
    elseif cmd == "timer" or cmd == "temps" then
        -- /mw timer : bande du temps restant du buff, sous les carres
        db.showTimer = not db.showTimer
        NativeChanged() -- le slot natif de la bande existe ou non selon l'option
        Update()
        print(PREFIX .. T("time bar ") .. (db.showTimer and T("on") or T("off")))
    elseif cmd == "color" or cmd == "couleur" then
        -- /mw color <r> <g> <b>  (0-1)  -> stacks 1-4 ;  /mw color full <r> <g> <b> -> 5 stacks
        local which, rest = "colorNormal", arg
        local first = arg:match("^(%a+)")
        if first == "full" then which, rest = "colorFull", arg:gsub("^full%s*", "")
        elseif first == "timer" or first == "temps" then which, rest = "colorTimer", arg:gsub("^" .. first .. "%s*", "")
        elseif first == "bg" or first == "fond" then which, rest = "colorBg", arg:gsub("^" .. first .. "%s*", "") end
        local r, g, b = rest:match("([%d%.]+)%s+([%d%.]+)%s+([%d%.]+)")
        r, g, b = tonumber(r), tonumber(g), tonumber(b)
        if r and g and b and r <= 1 and g <= 1 and b <= 1 then
            db[which] = { r, g, b }
            if which == "colorBg" then ApplyBgColor() end
            if which == "colorTimer" then ApplyTimerColor(); NativeChanged() end
            if which ~= "colorBg" and which ~= "colorTimer" then NativeChanged() end
            Update()
        else
            print(PREFIX .. T("/mw color [full|bg|timer] <r> <g> <b>  (values from 0 to 1)"))
        end
    elseif cmd == "always" then
        db.alwaysShow = not db.alwaysShow
        Update()
        print(PREFIX .. T("always show ") .. (db.alwaysShow and T("on") or T("off")))
    elseif cmd == "count" or cmd == "compteur" then
        -- /mw count : compteur de stacks. Variantes de position :
        -- /mw count pos above|center|below, /mw count offset <x> <y>
        local what, rest = arg:match("^(%S*)%s*(.-)$")
        if what == "pos" or what == "position" then
            local p = rest:match("^(%S+)")
            local pos
            if p == "center" or p == "centre" then pos = "center"
            elseif p == "below" or p == "dessous" then pos = "bottom"
            elseif p == "above" or p == "dessus" or p == "au-dessus" then pos = "top" end
            if pos then
                db.countPos = pos
                ApplyCountPos(); NativeChanged(); Update()
                print(PREFIX .. T("count position: ") .. pos)
            else
                print(PREFIX .. T("count position: above, center or below (/mw count pos ...)"))
            end
        elseif what == "offset" or what == "decalage" then
            local x, y = rest:match("^([-%d]+)%s+([-%d]+)")
            x, y = tonumber(x), tonumber(y)
            if x and y and math.abs(x) <= 200 and math.abs(y) <= 100 then
                db.countX, db.countY = x, y
                ApplyCountPos(); NativeChanged(); Update()
                print(PREFIX .. T("count offset: ") .. x .. ", " .. y)
            else
                print(PREFIX .. T("count offset: /mw count offset x y (pixels)"))
            end
        else
            db.showCount = not db.showCount
            NativeChanged()
            Update()
            print(PREFIX .. T("count ") .. (db.showCount and T("on") or T("off")))
        end
    elseif cmd == "lock" then
        SetUnlocked(false)
        print(PREFIX .. T("locked"))
    elseif cmd == "reset" then
        db.point, db.relPoint, db.x, db.y, db.scale = DEFAULTS.point, DEFAULTS.relPoint, DEFAULTS.x, DEFAULTS.y, 1
        db.sqW, db.sqH, db.sqGap = SQ_W, SQ_H, SQ_GAP
        ApplyPosition()
        ApplySize()
        print(PREFIX .. T("position and size reset"))
    elseif cmd == "size" or cmd == "taille" then
        -- /mw size <largeur> <hauteur> [espacement] : dimensions des carres
        local w, h, g = arg:match("(%d+)%s+(%d+)%s*(%d*)")
        w, h, g = tonumber(w), tonumber(h), tonumber(g)
        if w and h and w >= 10 and w <= 80 and h >= 6 and h <= 60 then
            db.sqW, db.sqH = w, h
            if g and g >= 0 and g <= 30 then db.sqGap = g end
            ApplySize()
            print(PREFIX .. string.format(T("size: %d x %d, spacing %d"), db.sqW, db.sqH, db.sqGap))
        else
            print(PREFIX .. T("/mw size <width> <height> [spacing]  (10-80, 6-60, 0-30)"))
        end
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
        print(PREFIX .. "v" .. (AddonVersion() or "?") .. " rev" .. REV
            .. " : /mw options | move | lock | always | count | timer | color | glow | glowspell | glowframe | glowscan | reset | scale <n> | size <w> <h> [gap] | test <0-5> | aura <buff name> | setup | log | testerror | debug")
    end
end
