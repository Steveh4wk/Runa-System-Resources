-- =============================================================================
-- Animal Farm - Wild Animal Spawner
-- Sistema spawn animali selvatici per feeding fantasy system
-- =============================================================================

local QBCore = exports['qb-core']:GetCoreObject()
local lib = exports['ox_lib']

local SpawnedAnimals = {}
local nextId = 1

-- Funzione per spawnare animale selvatico
local function SpawnWildAnimal(animalData)
    if not animalData or not animalData.coords then return end
    
    local model = GetHashKey(animalData.model)
    if not IsModelInCdimage(model) then
        print("[Animal Farm] Modello non valido:", animalData.model)
        return false
    end
    
    RequestModel(model)
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(model) do
        if GetGameTimer() > timeout then
            print("[Animal Farm] Timeout caricamento modello:", animalData.model)
            return false
        end
        Wait(10)
    end
    
    -- Trova posizione sicura a terra
    local groundZ = animalData.coords.z
    local success, z = GetGroundZFor_3dCoord(animalData.coords.x, animalData.coords.y, animalData.coords.z + 10.0, false)
    if success then
        groundZ = z
    end
    
    local spawnPos = vector3(animalData.coords.x, animalData.coords.y, groundZ)
    
    local ped = CreatePed(28, model, spawnPos.x, spawnPos.y, spawnPos.z, animalData.heading or 0.0, false, false)
    if not ped then
        print("[Animal Farm] Errore spawn animale")
        return false
    end
    
    -- Imposta comportamento animale selvatico
    SetEntityInvincible(ped, false)
    SetBlockingOfNonTemporaryEvents(ped, true)
    TaskWanderStandard(ped, 10.0, 10)
    
    -- Aggiungi alle tabelle
    local animalId = "wild_" .. nextId
    SpawnedAnimals[animalId] = {
        ped = ped,
        type = animalData.type,
        label = animalData.label,
        coords = spawnPos,
        model = animalData.model,
        feedItem = animalData.feedItem,
        healthReward = animalData.healthReward,
        expReward = animalData.expReward,
        alive = true
    }
    
    -- Aggiungi ox_target per interazioni
    exports.ox_target:addLocalEntity(ped, {
        {
            name = 'feed_wild_animal',
            icon = 'fas fa-drumstick-bite',
            label = 'Nutri Animale Selvatico',
            distance = 3.0,
            canInteract = function(entity, distance, data, options)
                -- Controlla se player è in forma fantasy
                local form = LocalPlayer.state.fantasyForm
                return form == 'vampire' or form == 'lycan'
            end,
            onSelect = function(data)
                local playerForm = LocalPlayer.state.fantasyForm
                if playerForm == 'vampire' then
                    -- Vampire feeding animation
                    TriggerEvent('fantasy_peds:client:vampireFeedAnimal', animalData.model)
                elseif playerForm == 'lycan' then
                    -- Lycan feeding animation  
                    TriggerEvent('fantasy_peds:client:lycanFeedAnimal', animalData.model)
                end
            end
        },
        {
            name = 'kill_wild_animal',
            icon = 'fas fa-skull',
            label = 'Uccidi Animale',
            distance = 3.0,
            onSelect = function(data)
                KillWildAnimal(animalId)
            end
        }
    })
    
    nextId = nextId + 1
    SetModelAsNoLongerNeeded(model)
    
    print("[Animal Farm] Spawnato animale selvatico:", animalData.label, "ID:", animalId)
    return animalId
end

-- Funzione per uccidere animale con animazione
local function KillWildAnimal(animalId)
    local animal = SpawnedAnimals[animalId]
    if not animal or not animal.ped or not DoesEntityExist(animal.ped) then
        return false
    end
    
    local ped = animal.ped
    
    -- Rimuovi ox_target prima di eliminare
    pcall(function()
        exports.ox_target:removeLocalEntity(ped)
    end)
    
    -- Animazione morte salto a terra
    RequestAnimDict("creatures@creature@move_a")
    while not HasAnimDictLoaded("creatures@creature@move_a") do Wait(10) end
    
    TaskPlayAnim(ped, "creatures@creature@move_a", "dead_fall_a", 8.0, -8.0, 2000, 1, 0, 0, 0, 0)
    SetEntityVelocity(ped, 0.0, 0.0, -5.0, true, true, true)
    
    Wait(1500)
    
    -- Rimuovi l'animale
    DeleteEntity(ped)
    
    ClearPedTasksImmediately(ped)
    RemoveAnimDict("creatures@creature@move_a")
    
    -- Rimuovi dalla tabella
    SpawnedAnimals[animalId] = nil
    
    lib.notify({
        type = 'info',
        description = animal.label .. ' ucciso!'
    })
    
    print("[Animal Farm] Ucciso animale selvatico:", animal.label, "ID:", animalId)
    return true
end

-- Funzione per ottenere animali vicini
local function GetNearbyWildAnimals(coords, radius)
    local nearby = {}
    
    for id, animal in pairs(SpawnedAnimals) do
        if animal.alive and animal.ped and DoesEntityExist(animal.ped) then
            local animalCoords = GetEntityCoords(animal.ped)
            local distance = #(coords - animalCoords)
            if distance <= radius then
                table.insert(nearby, {
                    id = id,
                    ped = animal.ped,
                    type = animal.type,
                    label = animal.label,
                    distance = distance,
                    feedItem = animal.feedItem,
                    healthReward = animal.healthReward,
                    expReward = animal.expReward
                })
            end
        end
    end
    
    return nearby
end

-- Thread per spawn casuali animali selvatici
CreateThread(function()
    while true do
        Wait(Config.RandomSpawn.checkIntervalSec * 1000)
        
        if Config.RandomSpawn.enabled then
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            
            -- Controlla se ci sono giocatori nelle zone di spawn
            local shouldSpawn = false
            for _, zone in ipairs(Config.RandomSpawn.spawnZones) do
                local distance = #(playerCoords - zone.center)
                if distance <= zone.radius then
                    shouldSpawn = true
                    break
                end
            end
            
            if shouldSpawn and #SpawnedAnimals < Config.RandomSpawn.maxAnimals then
                -- Scegli un tipo casuale
                local animalTypes = {}
                for _, animal in ipairs(Config.WildAnimals) do
                    table.insert(animalTypes, animal)
                end
                
                if #animalTypes > 0 then
                    local selectedAnimal = animalTypes[math.random(#animalTypes)]
                    
                    -- Trova posizione casuale nella zona
                    local zone = Config.RandomSpawn.spawnZones[math.random(#Config.RandomSpawn.spawnZones)]
                    local angle = math.random() * math.pi * 2
                    local distance = math.random() * zone.radius
                    local spawnCoords = vector3(
                        zone.center.x + math.cos(angle) * distance,
                        zone.center.y + math.sin(angle) * distance,
                        zone.center.z
                    )
                    
                    -- Controlla distanza da altri animali
                    local tooClose = false
                    for _, animal in pairs(SpawnedAnimals) do
                        if animal.alive and animal.ped and DoesEntityExist(animal.ped) then
                            local animalCoords = GetEntityCoords(animal.ped)
                            local distance = #(spawnCoords - animalCoords)
                            if distance < Config.RandomSpawn.minDistanceBetweenAnimals then
                                tooClose = true
                                break
                            end
                        end
                    end
                    
                    if not tooClose then
                        SpawnWildAnimal({
                            type = selectedAnimal.type,
                            label = selectedAnimal.label,
                            model = selectedAnimal.model,
                            coords = spawnCoords,
                            heading = math.random() * 360
                        })
                    end
                end
            end
        end
    end
end)

-- Esporta funzioni per fantasy_peds
exports('SpawnWildAnimal', SpawnWildAnimal)
exports('KillWildAnimal', KillWildAnimal)
exports('GetNearbyWildAnimals', GetNearbyWildAnimals)

print('[Animal Farm] Wild animal spawner loaded')
