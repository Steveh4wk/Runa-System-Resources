-- feeding_interaction.lua
-- Gestione interazione vicinanza / tasto per feeding creature (solo animali)

local feedingDistance = 3.0
local lastFeedTime = 0
local feedCooldown = 2000 -- 2 secondi

-- Funzione per trovare animali vicini
local function FindNearbyAnimal()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local closestAnimal = nil
    local closestDistance = feedingDistance
    
    -- Controlla tutti i ped nel gioco
    for _, ped in pairs(GetGamePool('CPed')) do
        if DoesEntityExist(ped) and not IsPedAPlayer(ped) and IsPedHuman(ped) == false then
            local pedCoords = GetEntityCoords(ped)
            local distance = #(playerCoords - pedCoords)
            
            if distance < closestDistance then
                closestDistance = distance
                closestAnimal = ped
            end
        end
    end
    
    return closestAnimal, closestDistance
end

-- Funzione per controllare se il giocatore è una creatura
local function IsCreature()
    local form = LocalPlayer.state.fantasyForm
    return form == 'vampire' or form == 'lycan'
end

-- Funzione per eseguire il feeding su animali
local function ExecuteFeed(animal)
    if not animal or not DoesEntityExist(animal) then return end
    
    local form = LocalPlayer.state.fantasyForm
    if not form then return end
    
    -- Check cooldown
    if GetGameTimer() - lastFeedTime < feedCooldown then
        if lib then
            lib.notify({title='Attesa', description='Aspetta prima di nutrirti di nuovo!', type='warning'})
        end
        return
    end
    
    lastFeedTime = GetGameTimer()
    
    if form == 'vampire' then
        -- ✅ ANIMAZIONE MORSO VAMPIRO CORRETTA
        local ped = PlayerPedId()
        local dict = 'melee@unarmed@streamed_core'
        local anim = 'attack_heavy'

        RequestAnimDict(dict)
        local timeout = GetGameTimer() + 5000
        while not HasAnimDictLoaded(dict) do
            if GetGameTimer() > timeout then
                print('[FANTASY_PEDS] Timeout caricamento animazione vampire')
                break
            end
            Wait(10)
        end

        if HasAnimDictLoaded(dict) then
            print('[FANTASY_PEDS] Eseguo animazione morso vampire')
            -- Inizia animazione morso
            TaskPlayAnim(ped, dict, anim, 8.0, -8.0, 2000, 48, 0, false, false, false)

            -- Aspetta fine animazione player
            Wait(1000)

            -- Effetti visivi durante animazione
            SetEntityAlpha(ped, 180, false)
            UseParticleFxAssetNextCall("core")
            local particle = StartParticleFxLoopedOnEntity("blood_splash", ped, 0.0, 0.0, 0.5, 0.0, 0.0, 0.0, 1.0, false, false, false)

            Wait(500)
            StopParticleFxLooped(particle, false)
            SetEntityAlpha(ped, 255, false)

            -- Ora uccidi l'animale con animazione morte
            SetEntityHealth(animal, 0)
            SetPedToRagdoll(animal, 2000, 2000, 0, 0, 0, 0)

            -- Applica effetti
            SetEntityHealth(ped, GetEntityHealth(ped) + 10)
            AddHunger(50)
            AddThirst(50)

            RemoveAnimDict(dict)
            ClearPedTasksImmediately(ped)

            if lib then
                lib.notify({title='Vampiro', description='Hai morso e drenato l\'animale!', type='success'})
            end
        else
            -- Fallback senza animazione
            SetEntityHealth(animal, 0)
            SetEntityHealth(ped, GetEntityHealth(ped) + 10)
            AddHunger(50)
            AddThirst(50)
            if lib then
                lib.notify({title='Vampiro', description='Hai nutrito l\'animale!', type='success'})
            end
        end

    elseif form == 'lycan' then
        -- ✅ ANIMAZIONE TUFFO LYCAN CORRETTA
        local ped = PlayerPedId()
        local dict = 'amb@world_human_wolf@mount@base'
        local anim = 'base'

        RequestAnimDict(dict)
        local timeout = GetGameTimer() + 5000
        while not HasAnimDictLoaded(dict) do
            if GetGameTimer() > timeout then
                print('[FANTASY_PEDS] Timeout caricamento animazione lycan, uso fallback')
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
            print('[FANTASY_PEDS] Eseguo animazione attacco lycan')
            -- Inizia animazione tuffo/pounce
            TaskPlayAnim(ped, dict, anim, 8.0, -8.0, 2000, 48, 0, false, false, false)

            -- Aspetta inizio animazione
            Wait(800)

            -- Effetti visivi durante animazione
            SetEntityAlpha(ped, 170, false)
            UseParticleFxAssetNextCall("core")
            local particle = StartParticleFxLoopedOnEntity("ent_amb_fbi_gas_station_burst", ped, 0.0, 0.0, 0.5, 0.0, 0.0, 0.0, 1.5, false, false, false)

            Wait(700)
            StopParticleFxLooped(particle, false)
            SetEntityAlpha(ped, 255, false)

            -- Ora uccidi l'animale con animazione morte
            SetEntityHealth(animal, 0)
            SetPedToRagdoll(animal, 2000, 2000, 0, 0, 0, 0)

            -- Applica effetti
            SetEntityHealth(ped, GetEntityHealth(ped) + 15)
            SetPlayerMeleeWeaponDamageModifier(PlayerId(), 1.3)
            AddHunger(50)
            AddThirst(50)

            RemoveAnimDict(dict)
            ClearPedTasksImmediately(ped)

            if lib then
                lib.notify({title='Lycan', description='Hai sbranato l\'animale!', type='success'})
            end
        else
            -- Fallback senza animazione
            SetEntityHealth(animal, 0)
            SetEntityHealth(ped, GetEntityHealth(ped) + 15)
            AddHunger(50)
            AddThirst(50)
            if lib then
                lib.notify({title='Lycan', description='Hai nutrito l\'animale!', type='success'})
            end
        end
    end
    
    Wait(1500) -- Aspetta che l'animazione completi
    ClearPedTasksImmediately(PlayerPedId())
end

-- Thread principale per controllare vicinanza e input (solo animali)
CreateThread(function()
    while true do
        Wait(500)
        
        if IsCreature() then
            local nearbyAnimal, distance = FindNearbyAnimal()
            
            if nearbyAnimal and distance <= feedingDistance then
                -- Mostra testo UI per nutrirsi
                local form = LocalPlayer.state.fantasyForm
                local text = (form == 'vampire' and '[E] Bevi Sangue') or (form == 'lycan' and '[E] Mangia Animale') or '[E] Interagisci'
                if lib then
                    lib.showTextUI(text)
                end

                -- Controlla input tasto E
                if IsControlJustReleased(0, 38) then -- Tasto E
                    ExecuteFeed(nearbyAnimal)
                    if lib then
                        lib.hideTextUI()
                    end
                end
            else
                -- Nascondi testo se non ci sono animali vicini
                if lib then
                    lib.hideTextUI()
                end
            end
        else
            -- Nascondi testo se non sei una creatura
            if lib then
                lib.hideTextUI()
            end
        end
    end
end)

-- Reset al disconnect
AddEventHandler('playerSpawned', function()
    lastFeedTime = 0
    if lib then
        lib.hideTextUI()
    end
end)

print('[FANTASY_PEDS] Feeding interaction caricato! (solo animali)')
