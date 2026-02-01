-- client/main.lua
-- Stefano Luciano Corp
-- Logica client per Animal Farm: ricevere animali, interazioni

local Animals = {}
local Tamed = {}

-- Funzione per uccidere animale con animazione salto a terra
local function KillAnimalWithAnimation(ped)
    if not DoesEntityExist(ped) then return end
    
    -- Animazione di morte/salto a terra
    RequestAnimDict("creatures@deer@move_a")
    while not HasAnimDictLoaded("creatures@deer@move_a") do
        Wait(10)
    end
    
    -- Applica animazione di caduta
    TaskPlayAnim(ped, "creatures@deer@move_a", "dead_fall_a", 8.0, -8.0, 2000, 1, 0, 0, 0, 0)
    
    -- Aspetta che l'animazione inizi
    Wait(500)
    
    -- Applica forza per far cadere l'animale
    SetEntityVelocity(ped, 0.0, 0.0, -5.0, true, true, true)
    
    -- Aspetta la fine dell'animazione
    Wait(1500)
    
    -- Rimuovi l'animale
    DeleteEntity(ped)
    
    ClearPedTasksImmediately(ped)
    RemoveAnimDict("creatures@deer@move_a")
    
    lib.notify({
        type = 'info',
        description = 'Animale selvatico ucciso!'
    })
end

-- Esporta funzione per uccidere animali
exports('KillAnimalWithAnimation', KillAnimalWithAnimation)

-- Ricevi animali dal server
RegisterNetEvent('animal_farm:client:setAnimals', function(animals)
    Animals = animals
    -- Aggiorna blips o markers se necessario
    print('[Animal Farm] Ricevuti ' .. tostring(#Animals) .. ' animali')
end)

RegisterNetEvent('animal_farm:client:setTamed', function(tamed)
    Tamed = tamed
    print('[Animal Farm] Ricevuti animali addomesticati')
end)

RegisterNetEvent('animal_farm:client:addTamed', function(animal)
    Tamed[animal.id] = animal
    print('[Animal Farm] Aggiunto animale addomesticato: ' .. animal.name)
end)

RegisterNetEvent('animal_farm:client:updateTamed', function(animal)
    Tamed[animal.id] = animal
end)

RegisterNetEvent('animal_farm:client:removeTamed', function(id)
    Tamed[id] = nil
end)

-- Richiedi sync al join
CreateThread(function()
    Wait(1000)
    TriggerServerEvent('animal_farm:server:requestSync')
end)

-- Interazione creature gestita in fantasy_peds/feeding_interaction.lua con tasto E

print('[Animal Farm] Client main loaded')