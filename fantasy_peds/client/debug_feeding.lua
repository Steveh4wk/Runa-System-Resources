-- debug_feeding.lua
-- Script di debug per testare le animazioni di feeding

local testMode = false

RegisterCommand('debugfeeding', function()
    testMode = not testMode
    if testMode then
        print('[DEBUG] Modalità test feeding attivata')
        lib.notify({
            title = 'Debug',
            description = 'Modalità test feeding attivata',
            type = 'info'
        })
    else
        print('[DEBUG] Modalità test feeding disattivata')
        lib.notify({
            title = 'Debug',
            description = 'Modalità test feeding disattivata',
            type = 'info'
        })
    end
end)

RegisterCommand('testvampireanim', function()
    local ped = PlayerPedId()
    print('[DEBUG] Test animazione vampire')
    
    -- Test animazione morso
    local dict = 'melee@unarmed@streamed_core'
    local anim = 'attack_heavy'
    
    RequestAnimDict(dict)
    local timeout = GetGameTimer() + 5000
    while not HasAnimDictLoaded(dict) do
        if GetGameTimer() > timeout then
            print('[DEBUG] Timeout caricamento animazione')
            return
        end
        Wait(10)
    end
    
    if HasAnimDictLoaded(dict) then
        print('[DEBUG] Eseguo animazione')
        TaskPlayAnim(ped, dict, anim, 8.0, -8.0, 2000, 48, 0, false, false, false)
        
        -- Effetti visivi
        SetEntityAlpha(ped, 180, false)
        UseParticleFxAssetNextCall("core")
        local particle = StartParticleFxLoopedOnEntity("blood_splash", ped, 0.0, 0.0, 0.5, 0.0, 0.0, 0.0, 1.0, false, false, false)
        
        Wait(1500)
        StopParticleFxLooped(particle, false)
        SetEntityAlpha(ped, 255, false)
        RemoveAnimDict(dict)
        ClearPedTasksImmediately(ped)
        
        print('[DEBUG] Animazione completata')
    end
end)

RegisterCommand('testlycananim', function()
    local ped = PlayerPedId()
    print('[DEBUG] Test animazione lycan')
    
    -- Test animazione primaria
    local dict = 'amb@world_human_wolf@mount@base'
    local anim = 'base'
    
    RequestAnimDict(dict)
    local timeout = GetGameTimer() + 5000
    while not HasAnimDictLoaded(dict) do
        if GetGameTimer() > timeout then
            print('[DEBUG] Timeout caricamento animazione primaria, provo fallback')
            dict = 'creatures@dog@amb@world_dog_biting@idle_a'
            anim = 'idle_b'
            RequestAnimDict(dict)
            while not HasAnimDictLoaded(dict) and GetGameTimer() < timeout do
                Wait(10)
            end
            break
        end
        Wait(10)
    end
    
    if HasAnimDictLoaded(dict) then
        print('[DEBUG] Eseguo animazione:', dict, anim)
        TaskPlayAnim(ped, dict, anim, 8.0, -8.0, 2000, 48, 0, false, false, false)
        
        -- Effetti visivi
        SetEntityAlpha(ped, 170, false)
        UseParticleFxAssetNextCall("core")
        local particle = StartParticleFxLoopedOnEntity("ent_amb_fbi_gas_station_burst", ped, 0.0, 0.0, 0.5, 0.0, 0.0, 0.0, 1.5, false, false, false)
        
        Wait(1500)
        StopParticleFxLooped(particle, false)
        SetEntityAlpha(ped, 255, false)
        RemoveAnimDict(dict)
        ClearPedTasksImmediately(ped)
        
        print('[DEBUG] Animazione completata')
    else
        print('[DEBUG] Errore caricamento animazione')
    end
end)

RegisterCommand('spawnanimal', function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local offset = GetEntityForwardVector(ped) * 2.0
    
    -- Spawna un cervo per test
    local animalModel = 'a_c_deer'
    local modelHash = GetHashKey(animalModel)
    
    RequestModel(modelHash)
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(modelHash) do
        if GetGameTimer() > timeout then
            print('[DEBUG] Timeout caricamento modello animale')
            return
        end
        Wait(10)
    end
    
    if HasModelLoaded(modelHash) then
        local animal = CreatePed(28, modelHash, coords.x + offset.x, coords.y + offset.y, coords.z, 0.0, true, false)
        if DoesEntityExist(animal) then
            SetEntityHealth(animal, 100)
            print('[DEBUG] Animale spawnato:', animal)
            lib.notify({
                title = 'Debug',
                description = 'Animale spawnato per test',
                type = 'success'
            })
        end
        SetModelAsNoLongerNeeded(modelHash)
    end
end)

print('[DEBUG] Debug feeding script caricato')
