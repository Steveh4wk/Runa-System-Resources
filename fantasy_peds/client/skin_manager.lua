-- =============================================================================
-- Skin Manager - Integrazione con QB-Multicharacter
-- Gestione cache skin permanente e restore automatico con UI control
-- =============================================================================

local QBCore = exports['qb-core']:GetCoreObject()
local cachedSkinData = nil
local isSkinLoaded = false
local isSkinCachedOnLogin = false

-- =============================================================================
-- SALVATAGGIO SKIN TEMPORANEO (per slot qb-multicharacter)
-- =============================================================================

-- Funzione principale per salvare la skin corrente
local function saveCurrentSkinToTempSlot()
    local ped = PlayerPedId()
    local playerData = QBCore.Functions.GetPlayerData()
    
    if not playerData or not playerData.citizenid then
        print("[SKIN_MANAGER] Impossibile salvare skin - player data non disponibile")
        return false
    end
    
    local citizenid = playerData.citizenid
    
    -- Ottieni skin da qb-multicharacter callback
    QBCore.Functions.TriggerCallback('qb-multicharacter:server:getSkin', function(model, data)
        if model and data then
            -- Salva nel nostro storage temporaneo (simula slot temporaneo)
            cachedSkinData = {
                model = model,
                data = data,
                citizenid = citizenid,
                savedAt = GetGameTimer(), -- Timestamp salvataggio
                charinfo = playerData.charinfo
            }
            isSkinLoaded = true
            isSkinCachedOnLogin = true
            
            -- Salva anche in LocalPlayer state per persistenza
            LocalPlayer.state:set('fantasy_cachedSkin', cachedSkinData, true)
            
            print("[SKIN_MANAGER] Skin salvata in temp slot per:", citizenid)
            print("[SKIN_MANAGER] Model:", model, "Saved at:", cachedSkinData.savedAt)
        else
            print("[SKIN_MANAGER] Nessuna skin trovata nel database")
            -- Fallback: salva il modello corrente
            cachedSkinData = {
                model = tostring(GetEntityModel(ped)),
                data = nil,
                citizenid = citizenid,
                savedAt = GetGameTimer(),
                charinfo = playerData.charinfo
            }
            isSkinLoaded = true
            isSkinCachedOnLogin = true
            LocalPlayer.state:set('fantasy_cachedSkin', cachedSkinData, true)
        end
    end, citizenid)
    
    return true
end

-- =============================================================================
-- APPLICAZIONE SKIN DA QB-MULTICHARACTER
-- =============================================================================

local function applySavedSkinFromSlot()
    local ped = PlayerPedId()
    local playerData = QBCore.Functions.GetPlayerData()
    
    if not playerData or not playerData.cititianid and not cachedSkinData then
        print("[SKIN_MANAGER] Nessun dato skin disponibile")
        return false
    end
    
    local citizenid = cachedSkinData and cachedSkinData.citizenid or playerData.citizenid
    
    print("[SKIN_MANAGER] Applicazione skin da qb-multicharacter slot...")
    
    -- Usa callback di qb-multicharacter per ottenere skin aggiornata
    QBCore.Functions.TriggerCallback('qb-multicharacter:server:getSkin', function(model, data)
        if model and data then
            print("[SKIN_MANAGER] Skin caricata da database:", model)
            
            -- Applica modello
            local modelHash = tonumber(model) or GetHashKey(model)
            
            if not IsModelInCdimage(modelHash) then
                print("[SKIN_MANAGER] Modello non valido, uso fallback")
                modelHash = GetHashKey("mp_m_freemode_01")
            end
            
            RequestModel(modelHash)
            local timeout = GetGameTimer() + 5000
            while not HasModelLoaded(modelHash) do
                if GetGameTimer() > timeout then
                    print("[SKIN_MANAGER] Timeout caricamento modello")
                    return false
                end
                Wait(10)
            end
            
            -- Applica modello player
            SetPlayerModel(PlayerId(), modelHash)
            SetPedDefaultComponentVariation(ped)
            
            -- Resetta posizione per evitare problemi
            local coords = GetEntityCoords(ped)
            SetEntityCoords(ped, coords.x, coords.y, coords.z + 0.5)
            
            Wait(100)
            
            -- Applica clothing se disponibile
            if data and data ~= "" then
                local success, skinData = pcall(json.decode, data)
                if success and skinData then
                    -- Trigger evento clothing di qb-clothing
                    TriggerEvent('qb-clothing:client:loadPlayerClothing', skinData, ped)
                    print("[SKIN_MANAGER] Clothing applicata con successo")
                end
            end
            
            -- Forza visibilità completa
            Wait(100)
            SetEntityAlpha(ped, 255, false)
            SetEntityVisible(ped, true, 0)
            SetEntityInvincible(ped, false)
            
            print("[SKIN_MANAGER] Skin applicata con successo")
            return true
        else
            print("[SKIN_MANAGER] Errore caricamento skin, uso fallback")
            return false
        end
    end, citizenid)
    
    return true
end

-- =============================================================================
-- FUNZIONE DI RESTORE HUMAN CON UI HIDE E RELOAD CONFIG
-- =============================================================================

local function restoreHumanWithUIReset()
    local ped = PlayerPedId()
    
    print("[SKIN_MANAGER] Restore human con reset UI e reload config...")
    
    -- 1. Nascondi UI skill bar PRIMA di qualsiasi altra cosa
    TriggerEvent('fantasy_skilltree:client:HideCreatureAbilities')
    
    -- 2. Resetta tutti gli stati creature
    Entity(ped).state.isVampire = false
    Entity(ped).state.isLycan = false
    Entity(ped).state.isAnimagus = false
    Entity(ped).state.lycanTransform = false
    Entity(ped).state.vampireAura = false
    
    LocalPlayer.state:set('fantasyForm', nil, true)
    
    -- 3. Applica skin da qb-multicharacter
    local restoreSuccess = false
    
    -- Prova prima con cached data, poi con callback
    if cachedSkinData then
        restoreSuccess = applySavedSkinFromSlot()
    else
        -- Fallback: ricarica da qb-multicharacter direttamente
        QBCore.Functions.TriggerCallback('qb-multicharacter:server:getSkin', function(model, data)
            if model and data then
                local modelHash = tonumber(model) or GetHashKey(model)
                if not IsModelInCdimage(modelHash) then
                    modelHash = GetHashKey("mp_m_freemode_01")
                end
                
                RequestModel(modelHash)
                while not HasModelLoaded(modelHash) do Wait(10) end
                
                SetPlayerModel(PlayerId(), modelHash)
                SetPedDefaultComponentVariation(ped)
                
                -- Applica clothing
                if data and data ~= "" then
                    local success, skinData = pcall(json.decode, data)
                    if success and skinData then
                        TriggerEvent('qb-clothing:client:loadPlayerClothing', skinData, ped)
                    end
                end
                
                -- Forza visibilità
                Wait(100)
                SetEntityAlpha(ped, 255, false)
                SetEntityVisible(ped, true, 0)
                
                print("[SKIN_MANAGER] Skin ricaricata da qb-multicharacter")
            end
        end, QBCore.Functions.GetPlayerData().citizenid)
        restoreSuccess = true
    end
    
    -- 4. Reset effetti gameplay
    SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
    SetPlayerMeleeWeaponDamageModifier(PlayerId(), 1.0)
    SetEntityAlpha(ped, 255, false)
    ClearTimecycleModifier()
    
    -- 5. Resetta camera
    Wait(100)
    SetGameplayCamRelativeRotation(0.0, 0.0, 0.0)
    
    print("[SKIN_MANAGER] Restore human completato, UI nascosta, config ricaricata")
    return restoreSuccess
end

-- =============================================================================
-- EVENT HANDLERS
-- =============================================================================

-- Salva skin al login (playerLoaded event di qb-core)
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    print("[SKIN_MANAGER] Player loaded - salvando skin in temp slot...")
    Wait(2000) -- Aspetta che qb-multicharacter sia pronto
    saveCurrentSkinToTempSlot()
end)

-- Salva skin quando richiesto (prima trasformazione)
RegisterNetEvent('fantasy_peds:client:saveSkin', function()
    saveCurrentSkinToTempSlot()
end)

-- Applica skin quando si torna umani (con UI hide)
RegisterNetEvent('fantasy_peds:client:restoreHumanWithConfig', function()
    restoreHumanWithUIReset()
end)

-- Export functions
exports('SaveCurrentSkin', saveCurrentSkinToTempSlot)
exports('ApplySavedSkin', applySavedSkinFromSlot)
exports('RestoreHumanWithUI', restoreHumanWithUIReset)
exports('GetCachedSkin', function() return cachedSkinData end)
exports('IsSkinCachedOnLogin', function() return isSkinCachedOnLogin end)

-- =============================================================================
-- INTEGRAZIONE CON FANTASY_PEDS_CLIENT
-- =============================================================================

-- Override della funzione RestoreOriginalPed per usare il nuovo sistema
CreateThread(function()
    Wait(5000) -- Aspetta che tutto sia caricato
    
    -- Aggiorna il comando /tornaumano per usare la nuova funzione
    RegisterCommand('tornaumano', function()
        print("[SKIN_MANAGER] Comando tornaumano - eseguendo restore con UI reset...")
        restoreHumanWithUIReset()
    end)
    
    print("[SKIN_MANAGER] Sistema skin cache e restore con UI integrato")
end)

print("[SKIN_MANAGER] Skin manager avanzato caricato - supporta temp slot e UI reset")
