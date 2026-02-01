--- client/fantasy_skilltree_client.lua
-- Stefano Luciano Corp
-- Fantasy Skilltree Client
-- Gestione menu NUI, spell casting, cooldown e logica forme
-- ======================================================

local spellCooldowns = {}
local slotCount = 5 -- slot 6-0 per Lycan (5 slot totali)
local isNuiOpen = false
local activeSpells = {} -- Traccia spell attive con i loro effetti

-- Helper function for notifications with fallback
local function notifyPlayer(data)
    if lib and type(lib.notify) == "function" then
        pcall(lib.notify, data)
    else
        TriggerEvent('chat:addMessage', {
            args = {"System", data.description or data.message or "Notification"},
            color = data.type == 'error' and {255, 0, 0} or data.type == 'success' and {0, 255, 0} or {0, 150, 255}
        })
    end
end

-- Ottieni forma attiva
local function getCurrentForm()
    local form = LocalPlayer.state.fantasyForm
    print('[Skilltree] getCurrentForm() =', form)
    return form
end

-- Controlla cooldown
local function isOnCooldown(slot)
    local form = getCurrentForm()
    if not form then return false end
    spellCooldowns[form] = spellCooldowns[form] or {}
    local cd = spellCooldowns[form][slot] or 0
    return cd > GetGameTimer()
end

-- Imposta cooldown
local function setCooldown(slot, ms)
    local form = getCurrentForm()
    if not form then return end
    spellCooldowns[form] = spellCooldowns[form] or {}
    spellCooldowns[form][slot] = GetGameTimer() + ms
end

-- Ottieni slot disponibili per forma
local function getAvailableSlots(form)
    if form == 'lycan' then
        return {6, 7, 8, 9, 0} -- Solo 5 slot per Lycan
    else
        return {0, 1, 2, 3, 4, 5, 6} -- 7 slot per altre forme
    end
end

-- Ottieni nome spell
local function getSpellName(form, slot)
    local names = {
        vampire = {
            [6] = "Aura",
            [7] = "Morso", 
            [8] = "Nutriti",
            [9] = "Disattiva Aura"
        },
        lycan = {
            [6] = "Trasformazione",
            [7] = "Corsa",
            [8] = "Graffio", 
            [9] = "Morso",
            [0] = "Pozione Antilupo"
        }
    }
    
    if names[form] and names[form][slot] then
        return names[form][slot]
    else
        return "Slot " .. slot
    end
end

-- Sistema gestione spell attive
local function deactivateAllSpells()
    print('[Skilltree] Disattivo tutte le spell attive')
    local ped = PlayerPedId()
    
    -- Resetta tutti gli effetti possibili delle spell
    SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
    SetPlayerMeleeWeaponDamageModifier(PlayerId(), 1.0)
    SetEntityAlpha(ped, 255, false)
    ClearTimecycleModifier()
    SetPlayerInvincible(false, false)
    
    -- Resetta stati specifici
    Entity(ped).state.vampireAura = false
    Entity(ped).state.lycanSpeed = false
    Entity(ped).state.lycanTransform = false -- Resetta trasformazione
    
    -- Pulisci le spell attive
    activeSpells = {}
    print('[Skilltree] Tutte le spell disattivate')
end

local function deactivateSpell(form, slot)
    local spellKey = form .. '_' .. slot
    if activeSpells[spellKey] then
        print('[Skilltree] Disattivo spell:', spellKey)
        local ped = PlayerPedId()
        
        -- Disattiva effetti specifici in base alla spell
        if form == 'lycan' and slot == 7 then -- Corsa Lycan
            SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
            SetEntityAlpha(ped, 255, false)
        elseif form == 'vampire' and slot == 6 then -- Aura Vampire
            SetEntityAlpha(ped, 255, false)
            ClearTimecycleModifier()
        end
        
        activeSpells[spellKey] = nil
    end
end

local function activateSpell(form, slot)
    local spellKey = form .. '_' .. slot
    activeSpells[spellKey] = {
        form = form,
        slot = slot,
        activatedAt = GetGameTimer()
    }
    print('[Skilltree] Attivata spell:', spellKey)
end

-- Ottieni informazioni spell per NUI
local function getSpellInfo(form, slot)
    local spells = nil
    
    if form == 'vampire' then
        spells = exports['fantasy_skilltree']:GetVampireSpells()
    elseif form == 'lycan' then
        spells = exports['fantasy_skilltree']:GetLycanSpells()
    elseif form == 'animagus' then
        spells = exports['fantasy_skilltree']:GetAnimagusSpells()
    end

    if spells and spells[slot] then
        return {
            slot = slot,
            available = true,
            name = getSpellName(form, slot),
            cooldown = isOnCooldown(slot)
        }
    else
        return {
            slot = slot,
            available = false,
            name = "Slot Vuoto",
            cooldown = false
        }
    end
end

-- Casting spell
local function castSpell(slot)
    local form = getCurrentForm()
    if not form then
        print('[Skilltree] Nessuna forma attiva')
        return
    end

    if isOnCooldown(slot) then
        print('[Skilltree] Spell slot '..slot..' in cooldown')
        return
    end

    -- Disattiva spell attive precedenti (eccetto spell istantanee)
    if form == 'lycan' then
        -- Per lycan, disattiva altre spell quando si casta trasformazione
        if slot == 6 then
            -- Disattiva corsa quando ti trasformi
            deactivateSpell(form, 7)
        elseif slot ~= 6 then
            -- Disattiva trasformazione quando usi altre spell
            deactivateSpell(form, 6)
        end
    elseif form == 'vampire' then
        -- Per vampire, disattiva aura (slot 6) quando si casta morso/nutriti
        if slot == 7 or slot == 8 then
            deactivateSpell(form, 6)
        end
    end

    -- Trigger verso file specifici SOLO se non è già attiva
    local spellKey = form .. '_' .. slot
    if not activeSpells[spellKey] then
        print('[Skilltree] Casting nuova spell:', spellKey)
        
        -- RIMOSSO: TriggerEvent duplicato - ora gestito direttamente dai file specifici
        -- TriggerEvent('fantasy_skilltree:client:castSpell', form, slot)
        
        setCooldown(slot, 5000) -- cooldown di default 5 secondi
        
        -- Registra la nuova spell come attiva se ha effetti persistenti
        if (form == 'lycan' and slot == 7) or (form == 'vampire' and slot == 6) or (form == 'lycan' and slot == 6) then
            activateSpell(form, slot)
        end
        
        -- Notifica solo per forme non-vampire (vampire hanno notifiche custom)
        if form ~= 'vampire' then
            notifyPlayer({
                title = 'Fantasy Skilltree',
                description = string.format('Hai usato slot %d di %s', slot, form),
                type = 'success'
            })
        end
    else
        print('[Skilltree] Spell già attiva, disattivo:', spellKey)
        deactivateSpell(form, slot)
    end
end

-- Evento per ricevere cast da fantasy_peds - ORA GESTISCE DIRETTAMENTE LE SPELL
RegisterNetEvent('fantasy_skilltree:client:cast', function(slot, form)
    if not form or not slot then return end
    
    print('[Skilltree] Ricevuto cast da fantasy_peds - slot:', slot, 'form:', form)
    
    -- Aggiorna temporaneamente la forma per il cast
    local originalForm = LocalPlayer.state.fantasyForm
    LocalPlayer.state:set('fantasyForm', form, false)
    
    -- Controlla cooldown
    if isOnCooldown(slot) then
        print('[Skilltree] Spell slot '..slot..' in cooldown')
        LocalPlayer.state:set('fantasyForm', originalForm, false)
        return
    end
    
    -- Disattiva spell attive precedenti
    if form == 'lycan' then
        if slot == 6 then
            deactivateSpell(form, 7)
        elseif slot ~= 6 then
            deactivateSpell(form, 6)
        end
    elseif form == 'vampire' then
        if slot == 7 or slot == 8 then
            deactivateSpell(form, 6)
        end
    end
    
    -- Controlla se spell è già attiva
    local spellKey = form .. '_' .. slot
    if not activeSpells[spellKey] then
        print('[Skilltree] Casting nuova spell:', spellKey)
        
        -- Imposta cooldown
        setCooldown(slot, 5000)
        
        -- Registra spell attiva se persistente
        if (form == 'lycan' and slot == 7) or (form == 'vampire' and slot == 6) or (form == 'lycan' and slot == 6) then
            activateSpell(form, slot)
        end
        
        -- ESECUZIONE DIRETTA DELLA SPELL
        if form == 'lycan' then
            TriggerEvent('fantasy_skilltree:client:castSpell', 'lycan', slot)
        elseif form == 'vampire' then
            TriggerEvent('fantasy_skilltree:client:castSpell', 'vampire', slot)
        elseif form == 'animagus' then
            TriggerEvent('fantasy_skilltree:client:castSpell', 'animagus', slot)
        end
        
        -- Notifica per forme non-vampire
        if form ~= 'vampire' then
            notifyPlayer({
                title = 'Fantasy Skilltree',
                description = string.format('Hai usato slot %d di %s', slot, form),
                type = 'success'
            })
        end
    else
        print('[Skilltree] Spell già attiva, disattivo:', spellKey)
        deactivateSpell(form, slot)
    end
    
    -- Ripristina forma originale se diversa
    if originalForm ~= form then
        Wait(100)
        LocalPlayer.state:set('fantasyForm', originalForm, false)
    end
end)

-- Menu NUI orizzontale (attivazione automatica)
local function showSkilltreeNui()
    print('[Skilltree] showSkilltreeNui() chiamata')
    local form = getCurrentForm()
    print('[Skilltree] getCurrentForm() =', form)
    if not form then
        print('[Skilltree] Nessuna forma, esco da showSkilltreeNui')
        return
    end

    print('[Skilltree] Preparo dati spell per forma:', form)
    -- Prepara dati spell per NUI
    local slots = getAvailableSlots(form)
    local spellData = {}
    
    for _, slot in ipairs(slots) do
        table.insert(spellData, getSpellInfo(form, slot))
    end

    print('[Skilltree] Invio messaggio NUI con', #spellData, 'spell')
    -- Mostra NUI senza focus (solo overlay estetico)
    SendNUIMessage({ 
        action = 'show',
        form = form,
        spells = spellData,
        noFocus = true
    })
    isNuiOpen = true
    
    print('[Skilltree] NUI mostrata per forma:', form)
end

-- Chiudi NUI (senza focus)
local function hideSkilltreeNui()
    if isNuiOpen then
        SendNUIMessage({ action = 'hide' })
        isNuiOpen = false
        print('[Skilltree] NUI nascosta')
    end
end

-- Tasti rapidi 6-0 attivi sempre quando trasformato
-- NOTA: I comandi sono gestiti da fantasy_peds per evitare duplicati

-- Listener cambio forma
AddStateBagChangeHandler('fantasyForm', 'player', function(_, _, form)
    print('[Skilltree] CAMBIO FORMA RILEVATO - form:', form)
    if not form then
        print('[Skilltree] Forma azzerata - chiudo NUI e disattivo spell')
        spellCooldowns = {}
        -- Disattiva tutte le spell attive
        deactivateAllSpells()
        -- Chiudi NUI se aperta
        hideSkilltreeNui()
        return
    end
    print('[Skilltree] Forma cambiata in:', form, '- apro NUI automaticamente')
    -- Disattiva spell della forma precedente
    deactivateAllSpells()
    -- Mostra automaticamente NUI quando trasformato
    showSkilltreeNui()
end)

-- Nascondi abilità creature
RegisterNetEvent('fantasy_skilltree:client:HideCreatureAbilities', function()
    print('[Skilltree] Nascondo abilità creature')
    spellCooldowns = {}
    -- Disattiva tutte le spell attive
    deactivateAllSpells()
    -- Chiudi NUI se aperta
    hideSkilltreeNui()
end)

-- Mostra skill bar (trigger diretto da trasformazione)
RegisterNetEvent('fantasy_skilltree:client:ShowSkillBar', function(form)
    print('[Skilltree] ShowSkillBar ricevuto per forma:', form)
    if form then
        -- Forza un piccolo delay per assicurarsi che lo stato sia aggiornato
        Wait(100)
        showSkilltreeNui()
    end
end)

-- Callback NUI
RegisterNUICallback('castSpell', function(data, cb)
    if data.slot then
        castSpell(tonumber(data.slot))
    end
    cb('ok')
end)

RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    isNuiOpen = false
    cb('ok')
end)

-- Pulisci tutto al relog
AddEventHandler('playerSpawned', function()
    print('[Skilltree] Player spawned - pulisco tutto')
    spellCooldowns = {}
    activeSpells = {}
    isNuiOpen = false
    
    -- Chiudi NUI se aperta
    SendNUIMessage({ action = 'hide' })
    
    -- Resetta tutti gli effetti del giocatore
    local ped = PlayerPedId()
    SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
    SetPlayerMeleeWeaponDamageModifier(PlayerId(), 1.0)
    SetEntityAlpha(ped, 255, false)
    ClearTimecycleModifier()
    SetPlayerInvincible(false, false)
end)

-- Pulisci tutto alla disconnessione
AddEventHandler('onClientResourceStop', function(resourceName)
    if resourceName == 'fantasy_skilltree' then
        print('[Skilltree] Resource stopping - pulisco tutto')
        if isNuiOpen then
            SetNuiFocus(false, false)
        end
    end
end)
