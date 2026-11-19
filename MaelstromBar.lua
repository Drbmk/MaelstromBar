-- MaelstromBar by Petitcorps : Maelstrom Weapon stack bar (Retail style), standalone.
-- Commands: /mw options | move | lock | always | warn | count | color | glow | glowspell | glowframe | glowscan | reset | scale <n> | size <w> <h> [gap] | test <0-5> | aura <name> | setup | log | testerror | debug

local MAX_STACKS = 5
local SQ_W, SQ_H, SQ_GAP = 28, 22, 3
local BUILD = select(4, GetBuildInfo()) or 0
local REV = 15 -- revision du code, affichee par /mw (la version TOC ne bouge qu'a la publication)

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
        ["Bar background"] = "Fond de la barre",
        ["Show the stack count on the bar (/mw count)"] = "Afficher le nombre de stacks sur la barre (/mw count)",
        ["count "] = "compteur ",
        ["warning "] = "avertissement ",
        ["Show the Cooldown Manager warning (red text under the bar, /mw warn)"] = "Afficher l'avertissement du Gestionnaire de temps de recharge (texte rouge sous la barre, /mw warn)",
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
        ["/mw color [full] <r> <g> <b>  (values from 0 to 1)"] = "/mw color [full] <r> <g> <b>  (valeurs de 0 à 1)",
        ["always show "] = "affichage permanent ",
        ["position and size reset"] = "position et taille réinitialisées",
        ["test "] = "test ",
        ["aura name = "] = "nom d'aura = ",
        ["log cleared"] = "journal vidé",
        ["no Lua errors recorded"] = "aucune erreur Lua enregistrée",
        ["%d Lua error(s) recorded, most recent first (/mw log clear to wipe)"] = "%d erreur(s) Lua enregistrée(s), la plus récente d'abord (/mw log clear pour vider)",
        ["this client does not need the Cooldown Manager"] = "ce client n'a pas besoin du Cooldown Manager",
        ["not available in combat"] = "indisponible en combat",
        ["Maelstrom Weapon is not tracked in the Cooldown Manager.\nThe bar stays empty in combat.  /mw setup"] = "Arme du Maelström n'est pas suivie dans le Cooldown Manager.\nLa barre reste vide en combat.  /mw setup",
        ["Cooldown Manager enabled: "] = "Cooldown Manager activé : ",
        ["Maelstrom Weapon is tracked in the Cooldown Manager"] = "Arme du Maelström est suivie dans le Cooldown Manager",
        ["Maelstrom Weapon is not tracked in the Cooldown Manager: the bar will stay empty in combat. Add it to the tracked buffs in the Cooldown Manager settings."] = "Arme du Maelström n'est pas suivie dans le Cooldown Manager : la barre restera vide en combat. Ajoute-la aux buffs suivis dans les réglages du Cooldown Manager.",
        ["Square width"] = "Largeur des carrés",
        ["Square height"] = "Hauteur des carrés",
        ["Spacing between squares"] = "Espacement entre les carrés",
        ["Size (/mw size)"] = "Taille (/mw size)",
        ["Default size"] = "Taille par défaut",
        ["size: %d x %d, spacing %d"] = "taille : %d x %d, espacement %d",
        ["/mw size <width> <height> [spacing]  (10-80, 6-60, 0-30)"] = "/mw size <largeur> <hauteur> [espacement]  (10-80, 6-60, 0-30)",
        ["Reset position and size (/mw reset)"] = "Réinitialiser la position et la taille (/mw reset)",
        ["the Cooldown Manager is not ready yet, checking again..."] = "le Gestionnaire de temps de recharge n'est pas encore prêt, nouvelle vérification en cours…",
        ["in combat: Maelstrom Weapon is not in the Cooldown Manager, the stacks cannot be read. After combat, type /mw setup."] = "en combat : Arme du Maelström n'est pas dans le Gestionnaire de temps de recharge, les stacks sont illisibles. Hors combat, tape /mw setup.",
        ["in combat: the Maelstrom Weapon icon of the Cooldown Manager was found but its stacks could not be read; please report this with /mw log."] = "en combat : l'icône Arme du Maelström du Gestionnaire de temps de recharge est trouvée mais ses stacks sont illisibles ; signale-le avec /mw log.",
        ["cannot confirm without Maelstrom stacks active: on some UIs the icon only exists while the buff is up. Check again right after a fight, with stacks still active."] = "impossible de confirmer sans stacks Arme du Maelström actives : sur certaines UI l'icône n'existe qu'avec le buff actif. Revérifie juste après un combat, stacks encore actives.",
        ["Cooldown Manager (stacks in combat)"] = "Cooldown Manager (stacks en combat)",
        ["Maelstrom Weapon is tracked in the Cooldown Manager: the bar works in combat."] = "Arme du Maelström est suivie dans le Cooldown Manager : la barre fonctionne en combat.",
        ["Maelstrom Weapon is not tracked in the Cooldown Manager: the bar stays empty in combat."] = "Arme du Maelström n'est pas suivie dans le Cooldown Manager : la barre reste vide en combat.",
        ["Fix: press Open the Cooldown Manager settings below, then add Maelstrom Weapon to the tracked buffs by hand, in the Enhancements section of the window that opens (an addon cannot change that list). Press Check again afterwards."] = "Correction : appuie sur « Ouvrir les réglages du Cooldown Manager » ci-dessous, puis ajoute Arme du Maelström aux buffs suivis à la main, dans la section « Améliorations » de la fenêtre qui s'ouvre (un addon ne peut pas modifier cette liste). Appuie ensuite sur « Vérifier à nouveau ».",
        ["cannot click that in combat, retry out of combat"] = "clic impossible en combat, réessaie hors combat",
        ["Open the Cooldown Manager settings"] = "Ouvrir les réglages du Cooldown Manager",
        ["Cooldown Manager settings not found: open the game options and look for them"] = "réglages du Cooldown Manager introuvables : ouvre les options du jeu et cherche-les",
        ["The Cooldown Manager cannot be checked in combat; reopen this panel out of combat."] = "Le Cooldown Manager ne peut pas être vérifié en combat ; rouvre ce panneau hors combat.",
        ["Cannot confirm yet: no Maelstrom stacks active, or the Cooldown Manager is still loading. If the stacks cannot be read in combat, a message in chat will say so."] = "Impossible de confirmer pour l'instant : pas de stacks Arme du Maelström actives, ou Cooldown Manager en cours de chargement. Si les stacks sont illisibles en combat, un message le dira dans le chat.",
        ["Check again"] = "Vérifier à nouveau",
        ["The Cooldown Manager is disabled: the stacks cannot be read in combat. Press Check again to enable it."] = "Le Cooldown Manager est désactivé : les stacks sont illisibles en combat. Appuie sur « Vérifier à nouveau » pour l'activer.",
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
    warnCDM = true,                     -- texte rouge si le buff n'est pas suivi
    sqW = SQ_W, sqH = SQ_H, sqGap = SQ_GAP,
    colorNormal = { 0, 0.55, 1 },
    colorFull = { 0.55, 0.95, 1 },
    colorBg = { 0.08, 0.1, 0.15 },      -- fond des carres
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

local cdmItem      -- icone du Cooldown Manager trouvee (cachee : evite de rebalayer a chaque lecture)
local cdmCooldown  -- lectures restantes avant un nouveau balayage complet apres un echec

-- Diagnostique en combat : si la lecture des stacks via le Cooldown Manager
-- echoue, un message explique pourquoi (une fois par combat) plutot qu'une
-- barre muette a 0, qui donne des rapports "ne suit pas en combat" sans cause.
local cdmItemLastSeen   -- horodatage de la derniere icone vue (le suivi fonctionne)
local cdmValueEverRead  -- vrai : au moins une valeur de stacks lue depuis le login
local viaCDM            -- vrai : la lecture courante des stacks passe par le Cooldown Manager
local combatHintDone    -- message de combat deja affiche pour ce combat

-- Journal de combat : repli pour lire les stacks en combat quand ni la lecture
-- directe ni l'icone du Cooldown Manager ne fonctionnent (certains clients
-- rendent l'icone mais refusent sa lecture). Les evenements d'aura
-- (SPELL_AURA_APPLIED_DOSE...) portent le nombre de stacks et ne passent pas
-- par l'API des auras. Hors combat, la lecture directe resynchronise ce
-- decompte ; le compteur de stacks s'appuie aussi dessus, une valeur secrete
-- ne pouvant pas etre convertie en texte.
local cleuStacks, cleuTime
local cleuTraceUntil, cleuTraceCount, cleuTraceAura, cleuTraceLast, cleuTraceRaw -- diagnostic /mw cleu
local cleuEvents -- statut d'enregistrement des evenements du journal (diagnostic)
local playerGUID
local CLEU_AURA = {
    SPELL_AURA_APPLIED = true, SPELL_AURA_REFRESH = true,
    SPELL_AURA_APPLIED_DOSE = true, SPELL_AURA_REMOVED_DOSE = true,
    SPELL_AURA_REMOVED = true,
}

local function ReadAuraFromFrame(f)
    -- Lecture seule : on n'appelle pas GetAuraData. Cette methode peut rafraichir
    -- le cache de l'icone depuis notre contexte "tainted" ; Blizzard relit alors
    -- des donnees contaminees dans son propre code et plante en combat
    -- ("attempt to compare a secret number value"). Seules les lectures pures
    -- sont autorisees : le cache, puis l'ID d'instance via l'API C.
    if f.GetAuraDataCached then
        local ok, d = pcall(f.GetAuraDataCached, f)
        if ok and type(d) == "table" and Has(d.applications) then return d.applications end
    end
    if f.GetAuraSpellInstanceID then
        local ok, id = pcall(f.GetAuraSpellInstanceID, f)
        if ok and Has(id) then
            local ok2, d = pcall(C_UnitAuras.GetAuraDataByAuraInstanceID, "player", id)
            if ok2 and type(d) == "table" and Has(d.applications) then return d.applications end
        end
    end
    return nil
end

local function ReadFromCooldownManager()
    local now = time()
    -- icone cachee d'abord : lecture directe, rapide, des que le buff est suivi
    if cdmItem then
        local v = ReadAuraFromFrame(cdmItem)
        if v ~= nil then
            cdmItemLastSeen, cdmValueEverRead = now, true
            return v
        end
        cdmItem = nil -- buff tombe ou icone retiree : il faut rechercher l'icone
    elseif cdmCooldown and cdmCooldown > 0 then
        cdmCooldown = cdmCooldown - 1
        return nil
    end
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
                    cdmItemLastSeen = now -- icone presente : le suivi fonctionne
                    local val = ReadAuraFromFrame(f)
                    if val ~= nil then
                        cdmValueEverRead = true
                        cdmItem, cdmCooldown = f, nil
                        return val
                    end
                end
            end
        end
    end
    -- aucune icone Maelstrom visible : patienter un peu avant de tout rebalayer
    cdmCooldown = 2
    return nil
end

---------------------------------------------------------------- verification du Cooldown Manager
-- La lecture en combat depend de l'icone Maelstrom Weapon du Cooldown Manager :
-- on verifie qu'il est actif et que le buff y est suivi, puis on previent.
-- Interdit d'y ecrire depuis l'addon : les reglages du Cooldown Manager doivent
-- etre modifies a la main dans les options du jeu, sinon son code est "tainted".
local setupDone = false    -- la verification de connexion a eu lieu
local cdmMissing = false   -- vrai : buff non suivi, avertissement affiche sur la barre
local RefreshCDMWarning    -- defini plus bas (a besoin de la barre)

-- Les frames du Cooldown Manager peuvent naitre bien apres le login (UI manette
-- notamment) : tant qu'elles n'existent pas, ou que leurs icones ne sont pas
-- encore creees, la verification est reprise plus tard au lieu de conclure que
-- le buff n'est pas suivi. Sinon l'avertissement rouge apparait a tort au login
-- et ne disparait qu'a la fin du premier combat.
local CDM_GRACE_RETRIES = 30 -- ~60 s apres le login avant de declarer le buff non suivi
local cdmGraceLeft = 0       -- ressais restantes de cette periode de grace
local cdmCheckScheduled = false

local function CooldownViewerExists()
    for _, vn in ipairs(CDM_VIEWERS) do
        if _G[vn] then return true end
    end
    return false
end

local function ScheduleCDMCheck(delay)
    if cdmCheckScheduled or not (C_Timer and C_Timer.After) then return end
    cdmCheckScheduled = true
    C_Timer.After(delay, function()
        cdmCheckScheduled = false
        RefreshCDMWarning()
    end)
end

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

-- Le catalogue du Cooldown Manager permet parfois de savoir si le buff est
-- suivi sans attendre son icone (qui, sur certaines UI, n'existe qu'avec le
-- buff actif) : on compare l'ensemble de categorie rendu avec l'argument
-- "tout inclure" et sans lui. Renvoie true (suivi), false (non suivi) ou nil
-- (inconnu) ; on ne conclut que si les deux ensembles se differencient
-- clairement, pour ne jamais prevenir a tort.
local function CatalogTrackedState()
    local C = C_CooldownViewer
    if not (C and C.GetCooldownViewerCategorySet and C.GetCooldownViewerCooldownInfo) then return nil end
    local id = FindMaelstromCooldownID()
    if not id then return nil end
    -- champ explicite du descriptif du cooldown, s'il existe
    local okI, info = pcall(C.GetCooldownViewerCooldownInfo, id)
    if okI and type(info) == "table" then
        for _, k in ipairs({ "tracked", "isTracked" }) do
            local v = Plain(info[k])
            if v == true then return true end
            if v == false then return false end
        end
    end
    local foundTracked, totalTracked, totalAll = false, 0, 0
    for _, cat in pairs(Enum and Enum.CooldownViewerCategory or {}) do
        local okA, all = pcall(C.GetCooldownViewerCategorySet, cat, true)
        local okT, tracked = pcall(C.GetCooldownViewerCategorySet, cat, false)
        if okA and type(all) == "table" and okT and type(tracked) == "table" then
            for _ in ipairs(all) do totalAll = totalAll + 1 end
            for _, cid in ipairs(tracked) do
                totalTracked = totalTracked + 1
                if cid == id then foundTracked = true end
            end
        end
    end
    -- ensembles vides, egaux ou suspects : on ne peut pas conclure
    if totalAll == 0 or totalTracked == 0 or totalTracked >= totalAll then return nil end
    return foundTracked
end

-- L'absence de l'icone du Cooldown Manager prouve-t-elle le non-suivi ? Oui sur
-- l'UI clavier (l'icone y existe meme sans buff actif, des que le buff est
-- suivi) ; non sur l'UI manette (elle n'y apparait qu'avec le buff actif).
-- On ne conclut donc que si l'UI manette est exclue : aucune manette active.
local function IconAbsenceIsProof()
    if C_GamePad and C_GamePad.IsEnabled then
        local ok, enabled = pcall(C_GamePad.IsEnabled)
        if ok and enabled == false then return true end
        if ok and enabled == true then return false end
    end
    return false -- manette active ou etat inconnu : prudence
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
    say("code rev" .. REV) -- prouve que le code charge est bien le dernier

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

    -- 3) pas d'ajout automatique : ecrire dans les reglages du Cooldown Manager
    -- depuis un addon contamine ses donnees, et le code Blizzard plante ensuite
    -- en combat ("attempt to compare a secret number value (execution tainted
    -- by 'MaelstromBar')"). L'ajout du buff aux buffs suivis se fait a la main
    -- dans les options du jeu ; on se contente de verifier et d'indiquer quoi
    -- faire si le buff n'y est pas.
    local id = FindMaelstromCooldownID()
    say("cooldownID=" .. tostring(id))

    -- 3 bis) dump de l'API (verbose uniquement) : liste des fonctions de
    -- C_CooldownViewer, champs du descriptif du cooldown, comptage des
    -- ensembles de categories selon l'argument. Permet de voir ce que ce
    -- client expose exactement pour determiner le suivi.
    if verbose then
        local okDump, errDump = pcall(function()
            local C = C_CooldownViewer
            local names = {}
            for k in pairs(C) do names[#names + 1] = tostring(k) end
            table.sort(names)
            say("C_CooldownViewer: " .. table.concat(names, ", "))
            if id then
                local okI, info = pcall(C.GetCooldownViewerCooldownInfo, id)
                if okI and type(info) == "table" then
                    local fields = {}
                    for k, v in pairs(info) do
                        local tv = type(v)
                        if tv == "string" or tv == "number" or tv == "boolean" then
                            local pv = Plain(v)
                            fields[#fields + 1] = tostring(k) .. "=" .. (pv ~= nil and tostring(pv) or "?")
                        elseif v ~= nil then
                            fields[#fields + 1] = tostring(k) .. "=(" .. tv .. ")"
                        end
                    end
                    table.sort(fields)
                    say("cooldown info: " .. table.concat(fields, ", "))
                end
                local function cnt(ok, t) return (ok and type(t) == "table") and tostring(#t) or "?" end
                local function has(ok, t)
                    if not (ok and type(t) == "table") then return "?" end
                    for _, cid in ipairs(t) do if cid == id then return "yes" end end
                    return "no"
                end
                for name, cat in pairs(Enum and Enum.CooldownViewerCategory or {}) do
                    local okA, all = pcall(C.GetCooldownViewerCategorySet, cat, true)
                    local okT, tracked = pcall(C.GetCooldownViewerCategorySet, cat, false)
                    local okN, def = pcall(C.GetCooldownViewerCategorySet, cat)
                    say(string.format("category %s (%s): all=%s/%s tracked=%s/%s default=%s/%s",
                        tostring(name), tostring(cat),
                        cnt(okA, all), has(okA, all),
                        cnt(okT, tracked), has(okT, tracked),
                        cnt(okN, def), has(okN, def)))
                end
                say("info.category=" .. tostring(Plain(info and info.category)))
                -- etat manette : determine si l'absence d'icone est une preuve
                do
                    local bits = {}
                    if C_GamePad and C_GamePad.IsEnabled then
                        local okE, en = pcall(C_GamePad.IsEnabled)
                        bits[#bits + 1] = "IsEnabled=" .. ((okE and tostring(en)) or "?")
                        if C_GamePad.IsUsingGamepadUI then
                            local okU, ui = pcall(C_GamePad.IsUsingGamepadUI)
                            bits[#bits + 1] = "IsUsingGamepadUI=" .. ((okU and tostring(ui)) or "?")
                        end
                    else
                        bits[#bits + 1] = "C_GamePad absent"
                    end
                    say("gamepad: " .. table.concat(bits, ", "))
                end
            end
        end)
        if not okDump then say("catalog dump error: " .. tostring(errDump)) end
    end

    -- 4) verifier un peu plus tard ; la periode de grace laisse aux icones le temps
    -- d'apparaitre (UI manette) avant d'afficher l'avertissement
    C_Timer.After(1, function()
        if verbose then cdmGraceLeft = 0 end -- diagnostic demande : reponse immediate
        local status = RefreshCDMWarning(verbose)
        if status == "pending" and verbose then
            print(PREFIX .. T("the Cooldown Manager is not ready yet, checking again..."))
        elseif status == "unknown" and verbose then
            print(PREFIX .. T("cannot confirm without Maelstrom stacks active: on some UIs the icon only exists while the buff is up. Check again right after a fight, with stacks still active."))
        elseif status == "tracked" and verbose then
            print(PREFIX .. T("Maelstrom Weapon is tracked in the Cooldown Manager"))
        end
    end)
end

local function ReadStacks()
    viaCDM = false
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
        viaCDM = true -- en combat : Cooldown Manager d'abord, journal de combat en repli
        local v = ReadFromCooldownManager()
        if v ~= nil then return v end
        if cleuStacks ~= nil then return cleuStacks end
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
    if ok then
        if issecretvalue and issecretvalue(res) then return res end
        -- nombre simple : resynchronise le decompte du journal de combat
        if type(res) == "number" then cleuStacks, cleuTime = res, time() end
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
-- Blizzard, ex. taint du Cooldown Manager) dans les SavedVariables, puis on
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

-- Avertissement visible sous la barre quand le buff n'est pas suivi par le Cooldown Manager
local warn = bar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
warn:SetPoint("TOP", bar, "BOTTOM", 0, -4)
warn:SetWidth(260)
warn:SetTextColor(1, 0.25, 0.2)
warn:SetText(T("Maelstrom Weapon is not tracked in the Cooldown Manager.\nThe bar stays empty in combat.  /mw setup"))
warn:Hide()

-- Compteur de stacks (option /mw count) : au centre de la barre
local count = bar:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
count:SetPoint("CENTER", bar, "CENTER", 0, 0)
count:SetTextColor(1, 1, 1)
count:Hide()

overlay:SetScript("OnDragStart", function() bar:StartMoving() end)
overlay:SetScript("OnDragStop", function()
    bar:StopMovingOrSizing()
    local p, _, rp, x, y = bar:GetPoint()
    db.point, db.relPoint, db.x, db.y = p, rp, x, y
end)

-- Taille des carres (largeur, hauteur, espacement) : reglable dans le panneau
-- d'options et par /mw size. La longueur totale de la barre en decoule :
-- 5 largeurs + 4 espacements.
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
end

-- Couleur de fond des carres (option /mw color bg, panneau d'options)
local function ApplyBgColor()
    if not db then return end
    local c = db.colorBg or DEFAULTS.colorBg
    for i = 1, MAX_STACKS do SetColor(squares[i].bg, c[1], c[2], c[3], 0.8) end
end

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
-- Buff Maelstrom actif et lisible ? (hors combat). Retourne nil si la lecture
-- est impossible. Sert a ne prevenir que lorsque l'absence d'icone du Cooldown
-- Manager est reelle : sans buff actif, l'icone peut simplement ne pas exister
-- (elle n'apparait parfois qu'avec le buff actif, UI manette notamment).
local function MaelstromBuffActive()
    if AurasSecret() then return nil end
    local ok, res = pcall(ReadStacks)
    if not ok then return nil end
    if issecretvalue and issecretvalue(res) then return nil end
    return (res or 0) > 0
end

local function Update()
    if not db then return end
    local stacks = GetStacks()
    local inCombat = UnitAffectingCombat("player")
    local secret = issecretvalue and issecretvalue(stacks)

    -- Diagnostique en combat : si la lecture des stacks depend du Cooldown
    -- Manager et echoue, expliquer pourquoi (une fois par combat, 10 s de
    -- marge) plutot qu'une barre muette a 0. Respecte /mw warn.
    if inCombat and viaCDM and db.warnCDM and not combatHintDone then
        local now = time()
        -- le journal de combat recent suffit a lire les stacks : pas d'alerte
        local cleuOk = cleuStacks ~= nil and (now - (cleuTime or 0)) < 15
        if not cleuOk and now - (cdmItemLastSeen or 0) > 10 then
            combatHintDone = true
            print(PREFIX .. T("in combat: Maelstrom Weapon is not in the Cooldown Manager, the stacks cannot be read. After combat, type /mw setup."))
        elseif not cleuOk and not cdmValueEverRead and cdmItemLastSeen and now - cdmItemLastSeen <= 2 then
            combatHintDone = true
            print(PREFIX .. T("in combat: the Maelstrom Weapon icon of the Cooldown Manager was found but its stacks could not be read; please report this with /mw log."))
        end
    end

    -- Valeur secrete : aucune comparaison possible (barre toujours visible)
    RefreshGlow(stacks)

    local showWarn = cdmMissing and db.warnCDM and true or false
    if showWarn then warn:Show() else warn:Hide() end
    if unlocked or db.alwaysShow or inCombat or secret or showWarn or stacks > 0 then
        bar:Show()
    else
        bar:Hide()
        return
    end

    -- Compteur optionnel : une valeur secrete ne peut pas devenir du texte,
    -- le decompte du journal de combat fournit alors le nombre
    if db.showCount then
        local n = stacks
        if issecretvalue and issecretvalue(n) then n = cleuStacks end
        if type(n) == "number" and n > 0 then
            count:SetText(tostring(n))
            count:Show()
        else
            count:Hide()
        end
    else
        count:Hide()
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

-- Decompte des stacks tenu par le journal de combat (cleuStacks) : mise a
-- jour sur chaque evenement d'aura Maelstrom du joueur.
local function OnCombatLog(event, ...)
    local cleuArgs
    local _, cev, _, _, _, _, _, dstGUID, _, _, _, spellId, spellName, _, auraType, amount
    if CombatLogGetCurrentEventInfo then
        _, cev, _, _, _, _, _, dstGUID, _, _, _, spellId, spellName, _, auraType, amount = CombatLogGetCurrentEventInfo()
    else
        -- ce client n'a pas CombatLogGetCurrentEventInfo : la charge utile du
        -- journal peut venir en arguments de l'evenement (anciens clients)
        cleuArgs = { ... }
        local u = unpack or table.unpack
        _, cev, _, _, _, _, _, dstGUID, _, _, _, spellId, spellName, _, auraType, amount = u(cleuArgs)
    end
    if cleuTraceUntil and time() < cleuTraceUntil then
        if cleuArgs then
            cleuTraceRaw = cleuTraceRaw + 1
            if cleuTraceRaw <= 8 then
                local parts = { "argc=" .. tostring(#cleuArgs) }
                for i = 1, math.min(#cleuArgs, 16) do parts[#parts + 1] = tostring(cleuArgs[i]) end
                print(PREFIX .. "brut: " .. table.concat(parts, " | "))
            end
        end
        if dstGUID == playerGUID and CLEU_AURA[cev] then
            cleuTraceAura = cleuTraceAura + 1
            local amt = amount
            if issecretvalue and issecretvalue(amt) then amt = "<valeur secrete>" end
            print(PREFIX .. cev .. " | " .. tostring(spellId) .. " " .. tostring(spellName)
                .. " | type=" .. tostring(auraType) .. " | amount=" .. tostring(amt))
        end
    end
    if not CLEU_AURA[cev] then return end
    if dstGUID ~= playerGUID then return end
    if auraType ~= "BUFF" and auraType ~= "HELPFUL" then return end
    if not IsMaelstromAura(spellName, spellId) then return end
    amount = Plain(amount)
    if cev == "SPELL_AURA_REMOVED" then
        cleuStacks = 0
    elseif cev == "SPELL_AURA_APPLIED" then
        cleuStacks = (amount and amount > 0) and amount or 1
    elseif cev == "SPELL_AURA_APPLIED_DOSE" then
        cleuStacks = (amount and amount > 0) and amount or (cleuStacks or 0) + 1
    elseif cev == "SPELL_AURA_REMOVED_DOSE" then
        cleuStacks = (amount and amount >= 0) and amount or math.max((cleuStacks or 1) - 1, 0)
    else -- SPELL_AURA_REFRESH : certains clients y mettent le compte
        if amount and amount > 0 then cleuStacks = amount end
        if not cleuStacks then cleuStacks = 1 end
    end
    cleuTime = time()
    Update()
end

RefreshCDMWarning = function(force)
    -- force (commande /mw setup) : rapporter meme si l'avertissement est coupe
    -- inutile sur les clients sans auras secretes ; pas de verification en combat
    if not (C_Secrets and C_Secrets.ShouldAurasBeSecret) then return end
    if UnitAffectingCombat("player") then return end
    if not CooldownViewerExists() then
        -- frames pas encore creees (login lent, UI manette) : reverifier plus tard,
        -- sans afficher l'avertissement pour autant
        if cdmGraceLeft > 0 then
            cdmGraceLeft = cdmGraceLeft - 1
            ScheduleCDMCheck(2)
        end
        return "pending"
    end
    local missing = not HasMaelstromItem()
    if missing then
        local active = MaelstromBuffActive()
        if active == nil or not active then
            -- Buff absent ou illisible : l'icone du Cooldown Manager n'existe
            -- parfois qu'avec le buff actif (UI manette notamment). Le catalogue
            -- ou l'exclusion de l'UI manette peut quand meme trancher ; sans
            -- certitude, pas d'avertissement.
            if CatalogTrackedState() ~= false and not IconAbsenceIsProof() then
                if cdmMissing then cdmMissing = false; Update() end
                ScheduleCDMCheck(10)
                return "unknown"
            end
            -- preuve de non-suivi : avertissement legitime (suite ci-dessous)
        end
        if cdmGraceLeft > 0 then
            -- buff actif mais icones pas encore apparues : laisser le temps
            cdmGraceLeft = cdmGraceLeft - 1
            ScheduleCDMCheck(2)
            return "pending"
        end
    end
    if missing ~= cdmMissing then
        cdmMissing = missing
        if missing and (db.warnCDM or force) then
            print(PREFIX .. T("Maelstrom Weapon is not tracked in the Cooldown Manager: the bar will stay empty in combat. Add it to the tracked buffs in the Cooldown Manager settings."))
        end
        Update()
    end
    if cdmMissing then
        -- l'icone peut apparaitre plus tard (reglages modifies, UI manette) :
        -- reverifier regulierement, l'avertissement disparait alors tout seul,
        -- sans attendre la fin d'un combat
        ScheduleCDMCheck(10)
    end
    return missing and "missing" or "tracked"
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

-- Recherche d'un bouton visible par son libelle : les noms des frames de la
-- fenetre "Parametres avances" de ce client sont inconnus, mais ses libelles
-- sont localises et stables. Attention, string.lower ne touche pas les lettres
-- accentuees (multi-octets) : les motifs sont coupes avant la lettre accentuee.
local function FrameLabelTexts(f)
    local texts = {}
    local function Add(t)
        if type(t) == "string" and #t > 0 then texts[#texts + 1] = t end
    end
    if f.GetText then
        local ok, t = pcall(f.GetText, f)
        if ok then Add(t) end
    end
    if f.GetFontString then
        local ok, fs = pcall(f.GetFontString, f)
        if ok and fs and fs ~= f and fs.GetText then
            local ok2, t = pcall(fs.GetText, fs)
            if ok2 then Add(t) end
        end
    end
    local okR, regions = pcall(f.GetRegions, f)
    if okR and type(regions) == "table" then
        for _, r in ipairs(regions) do
            if r ~= f and type(r) == "table" and r.GetText then
                local ok2, t = pcall(r.GetText, r)
                if ok2 then Add(t) end
            end
        end
    end
    return texts
end

local function FindButtonsBy(predicate)
    -- parcourt les frames visibles et rend les boutons dont un libelle
    -- correspond, avec la liste de tous les libelles vus (diagnostic)
    local found, labels = {}, {}
    local visited = 0
    local function Walk(f, depth)
        if depth > 12 or visited > 5000 then return end
        visited = visited + 1
        if type(f) == "table" and f.IsVisible and f.GetChildren then
            local okV, vis = pcall(f.IsVisible, f)
            if okV and vis then
                local isBtn = false
                for _, objType in ipairs({ "Button", "CheckButton" }) do
                    local ok, is = pcall(f.IsObjectType, f, objType)
                    if ok and is then isBtn = true end
                end
                if isBtn and f.Click then
                    for _, t in ipairs(FrameLabelTexts(f)) do
                        labels[#labels + 1] = t
                        if predicate(t:lower()) then found[#found + 1] = { frame = f, label = t } end
                    end
                end
                for _, c in ipairs({ f:GetChildren() }) do Walk(c, depth + 1) end
            end
        end
    end
    Walk(UIParent, 0)
    return found, labels
end

-- Options > Avancees > "Parametre avance" ouvre une fenetre dediee dont la
-- section "Ameliorations" gere les buffs suivis du Cooldown Manager.
local function ClickAdvancedSettings()
    local found, labels = FindButtonsBy(function(n)
        return (n:find("param", 1, true) and n:find("avanc", 1, true))
            or (n:find("advanced", 1, true) and n:find("setting", 1, true))
    end)
    if #found == 0 then
        print(PREFIX .. "« Paramètre avancé » introuvable dans Options > Avancées ; libellés des boutons visibles :")
        local seen, line = {}, {}
        local function flush()
            if #line > 0 then print(PREFIX .. "  " .. table.concat(line, " | ")) end
            line = {}
        end
        for _, t in ipairs(labels) do
            if not seen[t] then
                seen[t] = true
                line[#line + 1] = t
                if #table.concat(line, " | ") > 180 then flush() end
            end
        end
        flush()
        return
    end
    if InCombatLockdown() then
        print(PREFIX .. T("cannot click that in combat, retry out of combat"))
        return
    end
    local b = found[1]
    pcall(b.frame.Click, b.frame)
    local function openTab()
        local tabs = FindButtonsBy(function(n)
            return n:find("lioration", 1, true) or n:find("enhancement", 1, true)
        end)
        if #tabs == 0 then return end
        if InCombatLockdown() then
            print(PREFIX .. "section « Améliorations » trouvée mais inaccessible en combat")
            return
        end
        pcall(tabs[1].frame.Click, tabs[1].frame)
    end
    if C_Timer and C_Timer.After then C_Timer.After(0.4, openTab) else openTab() end
end

-- Ouvre la page des reglages du Cooldown Manager dans les options du jeu.
-- En cas d'echec, liste les categories vues pour diagnostiquer (commande
-- /mw cdmsettings ou bouton du panneau d'options).
local function OpenCDMSettings()
    local function listNames(names)
        local line = {}
        local function flush()
            if #line > 0 then print(PREFIX .. "categories: " .. table.concat(line, ", ")) end
            line = {}
        end
        for _, nm in ipairs(names) do
            line[#line + 1] = nm
            if #table.concat(line, ", ") > 200 then flush() end
        end
        flush()
    end
    local function fail(names)
        print(PREFIX .. T("Cooldown Manager settings not found: open the game options and look for them"))
        if type(names) == "table" then
            if #names == 0 then
                print(PREFIX .. "Settings.GetCategories() n'a rendu aucune categorie")
            else
                listNames(names)
            end
        end
    end
    if not (Settings and Settings.OpenToCategory) then
        print(PREFIX .. "Settings API incomplete : OpenToCategory="
            .. tostring(Settings and Settings.OpenToCategory or nil))
        return
    end
    local target = CDM_NAME:lower()
    local function CatName(cat)
        if cat.GetName then
            local ok, n = pcall(cat.GetName, cat)
            if ok and type(n) == "string" then return n end
        end
        return type(cat.name) == "string" and cat.name or nil
    end
    local function Match(name)
        if type(name) ~= "string" or #name < 3 then return false end
        local n = name:lower()
        return n:find("cooldown", 1, true) or target:find(n, 1, true) or n:find(target, 1, true)
    end
    local function Open(cat)
        local ok = pcall(Settings.OpenToCategory, cat.GetID and cat:GetID() or cat)
        if not ok then pcall(Settings.OpenToCategory, cat) end
    end
    local names = {}
    local advCat -- categorie "Avancees" / "Advanced" : la page y est cachee sur ce client
    local function TryCat(cat)
        -- renvoie vrai si la categorie correspond (et a ete ouverte)
        if type(cat) ~= "table" then
            names[#names + 1] = "(" .. type(cat) .. ")"
            return false
        end
        local n = CatName(cat)
        local okS2, subs = pcall(cat.GetSubcategories, cat)
        local subCount = (okS2 and type(subs) == "table") and #subs or -1
        names[#names + 1] = (tostring(n) or "?") .. " [" .. tostring(subCount) .. "]"
        if Match(n) then Open(cat) return true end
        if not advCat and type(n) == "string"
            and n:lower():find("avanc", 1, true) then
            advCat = cat
        end
        if okS2 and type(subs) == "table" then
            for _, sub in ipairs(subs) do
                local sn = CatName(sub)
                names[#names + 1] = (tostring(n) or "?") .. " > " .. (tostring(sn) or "?")
                if Match(sn) then Open(sub) return true end
            end
        end
        return false
    end
    if Settings.GetCategories then
        local okS, cats = pcall(Settings.GetCategories)
        if not okS or type(cats) ~= "table" then
            print(PREFIX .. "Settings.GetCategories() erreur : " .. tostring(cats))
            return fail()
        end
        for _, cat in ipairs(cats) do
            if type(cat) == "number" and Settings.GetCategory then
                local okC, real = pcall(Settings.GetCategory, cat)
                if okC and type(real) == "table" then cat = real end
            end
            if TryCat(cat) then return end
        end
    elseif Settings.GetCategory then
        -- ce client n'a pas GetCategories : balayer les categories par ID
        local misses = 0
        for id = 1, 300 do
            local okC, cat = pcall(Settings.GetCategory, id)
            if okC and type(cat) == "table" then
                misses = 0
                if TryCat(cat) then return end
            else
                misses = misses + 1
                if misses >= 25 then break end -- IDs epuises
            end
        end
    else
        -- aucune enumeration connue : montrer ce que ce client expose
        local keys = {}
        for k in pairs(Settings) do keys[#keys + 1] = tostring(k) end
        table.sort(keys)
        print(PREFIX .. "Settings: " .. table.concat(keys, ", "))
        return fail()
    end
    if advCat then
        -- ce client n'a pas de page Cooldown Manager : elle vit dans la
        -- fenetre "Parametres avances", derriere Options > Avancees
        Open(advCat)
        if C_Timer and C_Timer.After then
            C_Timer.After(0.3, ClickAdvancedSettings)
        else
            ClickAdvancedSettings()
        end
        return
    end
    fail(names)
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
                paint(); Update()
            end
            local function cancel()
                db[key] = { old[1], old[2], old[3] }
                glowDirty = true
                if key == "colorBg" then ApplyBgColor() end
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

    -- Cooldown Manager : guider l'utilisateur. L'addon active le Cooldown
    -- Manager lui-meme (bouton « Check again », comme au login), mais le suivi
    -- du buff doit etre coche a la main dans les options du jeu : le panneau
    -- affiche l'etat et la marche a suivre.
    if C_Secrets and C_Secrets.ShouldAurasBeSecret then
        Label(T("Cooldown Manager (stacks in combat)"), "GameFontNormal", 16, y); y = y - 22
        local st = Label("", "GameFontHighlight", 16, y)
        local fix = Label("", "GameFontHighlight", 16, y - 20)
        fix:SetWidth(540)
        local function RefreshCDMPanel()
            local getCV = (C_CVar and C_CVar.GetCVar) or GetCVar
            local okG, enabled = pcall(getCV, "cooldownViewerEnabled")
            local s
            if InCombatLockdown and InCombatLockdown() then
                s = "combat"
            elseif okG and enabled == "0" then
                s = "disabled"
            elseif not CooldownViewerExists() then
                s = "pending"
            elseif HasMaelstromItem() then
                s = "tracked"
            else
                local active = MaelstromBuffActive()
                if active == nil or not active then
                    -- sans stacks actives, l'icone peut ne pas exister (UI
                    -- manette) : le catalogue ou l'exclusion de l'UI manette
                    -- tranche quand c'est possible
                    local cat = CatalogTrackedState()
                    if cat == false or IconAbsenceIsProof() then s = "missing"
                    elseif cat == true then s = "tracked"
                    else s = "unknown" end
                else
                    s = "missing"
                end
            end
            if s == "tracked" then
                st:SetText(T("Maelstrom Weapon is tracked in the Cooldown Manager: the bar works in combat."))
                st:SetTextColor(0.35, 1, 0.35)
                fix:SetText("")
            elseif s == "missing" then
                st:SetText(T("Maelstrom Weapon is not tracked in the Cooldown Manager: the bar stays empty in combat."))
                st:SetTextColor(1, 0.3, 0.25)
                fix:SetText(T("Fix: press Open the Cooldown Manager settings below, then add Maelstrom Weapon to the tracked buffs by hand, in the Enhancements section of the window that opens (an addon cannot change that list). Press Check again afterwards."))
            elseif s == "disabled" then
                st:SetText(T("The Cooldown Manager is disabled: the stacks cannot be read in combat. Press Check again to enable it."))
                st:SetTextColor(1, 0.55, 0.2)
                fix:SetText("")
            elseif s == "combat" then
                st:SetText(T("The Cooldown Manager cannot be checked in combat; reopen this panel out of combat."))
                st:SetTextColor(1, 0.8, 0.2)
                fix:SetText("")
            else
                st:SetText(T("Cannot confirm yet: no Maelstrom stacks active, or the Cooldown Manager is still loading. If the stacks cannot be read in combat, a message in chat will say so."))
                st:SetTextColor(1, 0.8, 0.2)
                fix:SetText("")
            end
        end
        refreshers[#refreshers + 1] = RefreshCDMPanel
        Button(T("Check again"), 130, 16, y - 70, function()
            -- active le Cooldown Manager si besoin, verifie le suivi et
            -- detaille la marche a suivre dans le chat (meme chemin que /mw setup)
            SetupCooldownManager(true)
            RefreshCDMPanel()
            if C_Timer and C_Timer.After then C_Timer.After(1.5, RefreshCDMPanel) end
        end)
        Button(T("Open the Cooldown Manager settings"), 300, 156, y - 70, OpenCDMSettings)
        y = y - 100
    end

    Check(T("Unlock the bar to move it (/mw move)"),
        function() return unlocked end, function(v) SetUnlocked(v) end)
    Check(T("Always show the bar (/mw always)"),
        function() return db.alwaysShow end, function(v) db.alwaysShow = v; Update() end)
    Check(T("Show the Cooldown Manager warning (red text under the bar, /mw warn)"),
        function() return db.warnCDM end, function(v) db.warnCDM = v; Update() end)
    Check(T("Show the stack count on the bar (/mw count)"),
        function() return db.showCount end, function(v) db.showCount = v; Update() end)

    y = y - 6
    Label(T("Colors (/mw color)"), "GameFontNormal"); y = y - 26
    ColorRow(T("Stacks 1 to 4"), "colorNormal")
    ColorRow(T("5 stacks (maximum)"), "colorFull")
    ColorRow(T("Bar background"), "colorBg")
    ColorRow(T("Spell glow"), "colorGlow")
    Button(T("Default colors"), 150, 16, y, function()
        for _, key in ipairs({ "colorNormal", "colorFull", "colorBg", "colorGlow" }) do
            local d = DEFAULTS[key]
            db[key] = { d[1], d[2], d[3] }
        end
        glowDirty = true
        ApplyBgColor()
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
        for _, e in ipairs({ "ACTIONBAR_SLOT_CHANGED", "ACTIONBAR_PAGE_CHANGED", "UPDATE_BONUS_ACTIONBAR" }) do
            pcall(self.RegisterEvent, self, e) -- certains evenements n'existent pas sur tous les clients
        end
        self:RegisterEvent("UNIT_AURA")
        self:RegisterEvent("PLAYER_REGEN_DISABLED")
        self:RegisterEvent("PLAYER_REGEN_ENABLED")
        self:RegisterEvent("PLAYER_ENTERING_WORLD")
        playerGUID = (UnitGUID and UnitGUID("player")) or playerGUID
        cleuEvents = cleuEvents or {}
        -- journal de combat : repli de lecture en combat (voir OnCombatLog).
        -- Plusieurs noms possibles selon les clients : tous ceux qui
        -- s'enregistrent sont ecoutes, le statut est visible via /mw cleu.
        -- (Certains clients n'ont pas CombatLogGetCurrentEventInfo et passent
        -- la charge utile en arguments de l'evenement.)
        for _, ev in ipairs({ "COMBAT_LOG_EVENT_UNFILTERED", "COMBAT_LOG_EVENT" }) do
            local ok, err = pcall(self.RegisterEvent, self, ev)
            cleuEvents[ev] = ok and "enregistre" or tostring(err)
        end

        -- Integration au menu d'edition de l'interface (clients qui l'ont)
        if EditModeManagerFrame and EditModeManagerFrame.HookScript then
            EditModeManagerFrame:HookScript("OnShow", function() SetUnlocked(true) end)
            EditModeManagerFrame:HookScript("OnHide", function() SetUnlocked(false) end)
        end
        Update()
        StartRealtimeUpdates()
        -- laisse le temps au Cooldown Manager de creer ses frames et ses icones
        -- avant de verifier ; avec l'UI manette elles apparaissent tard, d'ou la
        -- periode de grace (~60 s) pendant laquelle on reessaie sans prevenir
        if C_Timer and C_Timer.After then
            C_Timer.After(5, function()
                setupDone = true
                cdmGraceLeft = CDM_GRACE_RETRIES
                pcall(SetupCooldownManager, false)
            end)
        end
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" or event == "COMBAT_LOG_EVENT" then
        -- comptage brut ici : meme si OnCombatLog rend la main aussitot
        -- (CombatLogGetCurrentEventInfo absent...), la trace doit le montrer
        if cleuTraceUntil and time() < cleuTraceUntil then
            cleuTraceCount = cleuTraceCount + 1
            cleuTraceLast = event
        end
        OnCombatLog()
    elseif event == "UNIT_AURA" then
        if unit == "player" then Update() end
    else
        if event == "PLAYER_REGEN_DISABLED" then
            -- entree en combat : reinitialiser le diagnostique (10 s de marge
            -- avant le message, le temps que les premieres stacks arrivent)
            combatHintDone = false
            cdmItemLastSeen = time()
        end
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
    elseif cmd == "cleu" then
        -- /mw cleu : tracer 20 s le journal de combat (diagnostic du repli).
        -- Montre les evenements d'aura du joueur : si la trace reste vide, le
        -- journal n'est pas emis ; si amount est secret, le repli est mort.
        if type(cleuEvents) == "table" then
            for ev, st in pairs(cleuEvents) do print(PREFIX .. ev .. " : " .. tostring(st)) end
        else
            print(PREFIX .. "journal de combat : enregistrement non tente")
        end
        cleuTraceUntil, cleuTraceCount, cleuTraceAura, cleuTraceLast, cleuTraceRaw = time() + 20, 0, 0, nil, 0
        print(PREFIX .. "trace du journal de combat pendant 20 s : entre en combat et frappe des ennemis, colle le resultat")
        local glob = {}
        for k in pairs(_G) do
            if type(k) == "string" and k:lower():find("combatlog", 1, true) then glob[#glob + 1] = k end
        end
        table.sort(glob)
        print(PREFIX .. "API CombatLog* : " .. ((#glob > 0 and table.concat(glob, ", ")) or "aucune"))
        if C_Timer and C_Timer.After then
            C_Timer.After(21, function()
                local st = ""
                if type(cleuEvents) == "table" then
                    for ev, s in pairs(cleuEvents) do st = st .. " | " .. ev .. ": " .. tostring(s) end
                end
                print(PREFIX .. "journal : " .. tostring(cleuTraceCount) .. " evenements recus dont "
                    .. tostring(cleuTraceAura) .. " auras sur toi | dernier: " .. tostring(cleuTraceLast)
                    .. " | CombatLogGetCurrentEventInfo: " .. tostring(CombatLogGetCurrentEventInfo ~= nil)
                    .. st)
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
    elseif cmd == "cdmsettings" then
        -- /mw cdmsettings : ouvre les reglages du Cooldown Manager (diagnostic)
        OpenCDMSettings()
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
    elseif cmd == "color" or cmd == "couleur" then
        -- /mw color <r> <g> <b>  (0-1)  -> stacks 1-4 ;  /mw color full <r> <g> <b> -> 5 stacks
        local which, rest = "colorNormal", arg
        local first = arg:match("^(%a+)")
        if first == "full" then which, rest = "colorFull", arg:gsub("^full%s*", "")
        elseif first == "bg" or first == "fond" then which, rest = "colorBg", arg:gsub("^" .. first .. "%s*", "") end
        local r, g, b = rest:match("([%d%.]+)%s+([%d%.]+)%s+([%d%.]+)")
        r, g, b = tonumber(r), tonumber(g), tonumber(b)
        if r and g and b and r <= 1 and g <= 1 and b <= 1 then
            db[which] = { r, g, b }
            if which == "colorBg" then ApplyBgColor() end
            Update()
        else
            print(PREFIX .. T("/mw color [full] <r> <g> <b>  (values from 0 to 1)"))
        end
    elseif cmd == "always" then
        db.alwaysShow = not db.alwaysShow
        Update()
        print(PREFIX .. T("always show ") .. (db.alwaysShow and T("on") or T("off")))
    elseif cmd == "count" or cmd == "compteur" then
        -- /mw count : compteur de stacks au centre de la barre
        db.showCount = not db.showCount
        Update()
        print(PREFIX .. T("count ") .. (db.showCount and T("on") or T("off")))
    elseif cmd == "warn" then
        -- /mw warn : afficher ou non le texte rouge du Cooldown Manager
        db.warnCDM = not db.warnCDM
        Update()
        print(PREFIX .. T("warning ") .. (db.warnCDM and T("on") or T("off")))
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
            .. " : /mw options | move | lock | always | warn | count | color | glow | glowspell | glowframe | glowscan | reset | scale <n> | size <w> <h> [gap] | test <0-5> | aura <buff name> | setup | log | testerror | debug")
    end
end
