-- fantasy_peds_client.lua
-- Gestione trasformazioni, ped, menu e spell casting (tasti 0-6)
-- Integrazione completa con fantasy_skilltree

local FantasyPeds = {
    vampire = { model = "Vampire" },
    lycan = { model = "icewolf" },
    animagus = { model = "random" } -- verrà scelto randomicamente
}

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

-- 6 animali nativi GTA per trasformazione Animagus
local AnimagusAnimals = {
    "a_c_deer",        -- Cervo
    "a_c_coyote",      -- Coyote
    "a_c_mtlion",      -- Leone di montagna
    "a_c_boar",        -- Cinghiale
    "a_c_rabbit_01",   -- Coniglio
    "a_c_chimp"        -- Scimpanzé
}

local SpellSlots = {0,1,2,3,4,5,6,7,8,9} -- tasti per spell casting (tutti gli slot)
local CurrentForm = nil -- forma corrente del giocatore

-- ==============================
-- UTILITY MODELLO SICURO
-- ==============================
local function LoadModelSafe(modelName)
    local hash = GetHashKey(modelName)
    if not IsModelInCdimage(hash) or not IsModelValid(hash) then
        print("[FANTASY_PEDS] Modello non valido:", modelName)
        return nil
    end
    RequestModel(hash)
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(hash) do
        if GetGameTimer() > timeout then
            print("[FANTASY_PEDS] Timeout caricamento modello:", modelName)
            return nil
        end
        Wait(10)
    end
    return hash
end

-- ==============================
-- APPLICA CREATURE
-- ==============================
local function ApplyCreature(form)
    local data = FantasyPeds[form]
    if not data then return end
    
    -- Salva skin attuale prima della trasformazione
    TriggerEvent('fantasy_peds:client:saveSkin')
    
    local modelHash = LoadModelSafe(data.model)
    if not modelHash then return end
    
    local ped = PlayerPedId()
    SetPlayerModel(PlayerId(), modelHash)
    SetPedDefaultComponentVariation(ped)
    
    LocalPlayer.state:set('fantasyForm', form, true)
    CurrentForm = form
    
    Entity(ped).state.isVampire = (form == "vampire")
    Entity(ped).state.isLycan = (form == "lycan")
    Entity(ped).state.isAnimagus = (form == "animagus")
    print("[FANTASY_PEDS] Trasformato in:", form)
    
    -- Forza un piccolo delay per assicurarsi che lo stato sia aggiornato
    Wait(200)
    
    -- Mostra skillbar per creature
    TriggerEvent('fantasy_skilltree:client:ShowSkillBar', form)
end

-- ==============================
-- RIPRISTINA PED UMANO CON SKIN QB-MULTICHARACTER E UI RESET
-- ==============================
local function RestoreOriginalPed()
    local ped = PlayerPedId()
    
    print("[FANTASY_PEDS] RestoreOriginalPed - nascondendo UI e ricaricando config...")
    
    -- Usa la funzione avanzata del skin manager che nasconde UI e ricarica config
    local success = false
    
    if exports['fantasy_peds'] and exports['fantasy_peds'].RestoreHumanWithUI then
        success = exports['fantasy_peds']:RestoreHumanWithUI()
    else
        -- Fallback se skin manager avanzato non disponibile
        LocalPlayer.state:set('fantasyForm', nil, true)
        CurrentForm = nil

        Entity(ped).state.isVampire = false
        Entity(ped).state.isLycan = false
        Entity(ped).state.isAnimagus = false
        Entity(ped).state.lycanTransform = false
        
        -- Chiudi skillbar e NUI PRIMA di applicare skin
        TriggerEvent('fantasy_skilltree:client:HideCreatureAbilities')
        
        -- Fallback skin base
        local isMale = true
        if QBCore and QBCore.Functions.GetPlayerData then
            local playerData = QBCore.Functions.GetPlayerData()
            if playerData and playerData.charinfo then
                isMale = playerData.charinfo.gender == 0
            end
        end
        
        local humanModel = isMale and "mp_m_freedom_01" or "mp_f_freedom_01"
        local hash = LoadModelSafe(humanModel)
        if hash then
            SetPlayerModel(PlayerId(), hash)
            SetPedDefaultComponentVariation(ped)
        end
        
        LocalPlayer.state:set('invHotkeys', true, true)
        success = true
    end
    
    print("[FANTASY_PEDS] Ripristino ped umano completato, UI nascosta, config ricaricata")
    return success
end

-- Evento per restore human da altri script
RegisterNetEvent('fantasy_peds:client:RestoreHuman', function()
    RestoreOriginalPed()
end)

-- ==============================
-- SPELL CASTING DA 0 A 6
-- ==============================
local function CastSpell(slot)
    if not CurrentForm then
        print("[FANTASY_PEDS] Non sei trasformato, impossibile lanciare spell")
        return
    end
    -- Trigger fantasy_skilltree con forma corrente e slot
    print("[FANTASY_PEDS] Casting spell slot:", slot, "form:", CurrentForm)
    TriggerEvent('fantasy_skilltree:client:cast', slot, CurrentForm)
end

-- Crea comandi per tasti 0-9 (tutti gli slot spell)
for _, slot in ipairs(SpellSlots) do
    RegisterCommand('spell'..slot, function()
        CastSpell(slot)
    end)
    RegisterKeyMapping('spell'..slot, 'Fantasy Spell Slot '..slot, 'keyboard', tostring(slot))
end

-- Comando diretto per tornare umano
RegisterCommand('tornaumano', function()
    print("[FANTASY_PEDS] Comando tornaumano eseguito")
    RestoreOriginalPed()
end)
RegisterKeyMapping('tornaumano', 'Torna Umano', 'keyboard', 'X')

-- Comando test per verificare funzioni
RegisterCommand('testrestore', function()
    print("[FANTASY_PEDS] Test RestoreOriginalPed...")
    if RestoreOriginalPed then
        print("[FANTASY_PEDS] RestoreOriginalPed disponibile, eseguo...")
        RestoreOriginalPed()
    else
        print("[FANTASY_PEDS] ERRORE: RestoreOriginalPed non disponibile!")
    end
end)

-- Menu ox_lib
RegisterCommand('creatures', function()
    print("[FANTASY_PEDS] Menu creatures richiesto")
    
    local menu = {
        { title="Vampiro", description="Trasformati in Vampiro", icon="skull", onSelect=function() 
            print("[FANTASY_PEDS] Scelto Vampiro")
            ApplyCreature('vampire') 
        end },
        { title="Lycan", description="Trasformati in Licantropo", icon="paw", onSelect=function() 
            print("[FANTASY_PEDS] Scelto Lycan")
            ApplyCreature('lycan') 
        end },
        { title="Animagus", description="Trasformati in Animagus", icon="feather", onSelect=function() 
            print("[FANTASY_PEDS] Scelto Animagus")
            ApplyCreature('animagus') 
        end },
        { title="Torna Umano", description="Ripristina forma umana", icon="user", onSelect=function() 
            print("[FANTASY_PEDS] Scelto Torna Umano")
            RestoreOriginalPed() 
        end }
    }
    
    if lib and lib.registerContext then
        print("[FANTASY_PEDS] Mostro menu ox_lib")
        lib.registerContext({id='creature_menu', title='🌙 Menu Creature', options=menu})
        lib.showContext('creature_menu')
    else
        print("[FANTASY_PEDS] ox_lib non trovato, uso fallback comandi diretti")
        notifyPlayer({
            title = 'Menu Creature',
            description = 'Usa /tornaumano per tornare umano',
            type = 'info'
        })
    end
end)
RegisterKeyMapping('creatures','Menu Creature','keyboard','F7')

-- ==============================
-- EXPORTS
-- ==============================
exports('ApplyCreature', ApplyCreature)
exports('RestoreOriginalPed', RestoreOriginalPed)

-- Pulisci tutto al relog
AddEventHandler('playerSpawned', function()
    print('[FANTASY_PEDS] Player spawned - reset stato trasformazione')
    CurrentForm = nil
    LocalPlayer.state:set('fantasyForm', nil, true)
    
    -- Resetta stato creature
    local ped = PlayerPedId()
    Entity(ped).state.isVampire = false
    Entity(ped).state.isLycan = false
    Entity(ped).state.isAnimagus = false
    
    -- Chiudi skillbar se aperta
    TriggerEvent('fantasy_skilltree:client:HideCreatureAbilities')
end)
