local QBCore = exports['qb-core']:GetCoreObject()

CreateThread(function()
    -- Carica i modelli dei ped
    RequestModel(GetHashKey(Config.CommonPed))
    RequestModel(GetHashKey(Config.RarePed))
    
    -- Attendi che i modelli siano caricati
    while not HasModelLoaded(GetHashKey(Config.CommonPed)) do
        Wait(10)
    end
    
    while not HasModelLoaded(GetHashKey(Config.RarePed)) do
        Wait(10)
    end
    
    -- Spawn Common Ped
    local commonPed = CreatePed(4, GetHashKey(Config.CommonPed), Config.CommonPedLocation.x, Config.CommonPedLocation.y, Config.CommonPedLocation.z - 1.0, Config.CommonPedLocation.w, false, true)
    SetEntityInvincible(commonPed, true)
    SetBlockingOfNonTemporaryEvents(commonPed, true)
    FreezeEntityPosition(commonPed, true)
    TaskStartScenarioInPlace(commonPed, "WORLD_HUMAN_DRUG_DEALER", 0, true)
    
    -- Attendi un frame prima di aggiungere il target
    Wait(100)
    
    exports.ox_target:addLocalEntity(commonPed, {
        {
            name = 'common_trade',
            icon = 'fas fa-user-secret',
            label = 'Trade your Finds',
            onSelect = function()
                TriggerEvent('qb-metaldetector:CommonTradingMenu')
            end,
            distance = 2.5
        }
    })
    
    -- Spawn Rare Ped
    local rarePed = CreatePed(4, GetHashKey(Config.RarePed), Config.RarePedLocation.x, Config.RarePedLocation.y, Config.RarePedLocation.z - 1.0, Config.RarePedLocation.w, false, true)
    SetEntityInvincible(rarePed, true)
    SetBlockingOfNonTemporaryEvents(rarePed, true)
    FreezeEntityPosition(rarePed, true)
    TaskStartScenarioInPlace(rarePed, "WORLD_HUMAN_DRUG_DEALER", 0, true)
    
    -- Attendi un frame prima di aggiungere il target
    Wait(100)
    
    exports.ox_target:addLocalEntity(rarePed, {
        {
            name = 'rare_trade',
            icon = 'fas fa-user-secret',
            label = 'Trade your Rare Finds',
            onSelect = function()
                TriggerEvent('qb-metaldetector:RareTradingMenu')
            end,
            distance = 2.5
        }
    })
end)
