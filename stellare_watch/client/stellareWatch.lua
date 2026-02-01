-- Stefano Luciano Corp. per AstralRP - Orologio Stellare System Standalone
-- Sistema revive automatico con cooldown di 30 minuti

local stellareActive = false

-- Funzione di reset completo
local function FullHealthReset()
    local ped = PlayerPedId()

    -- Reset vita al 100%
    SetEntityHealth(ped, GetEntityMaxHealth(ped))
    SetPedArmour(ped, 100)

    -- Stop bleeding / damage
    ClearPedBloodDamage(ped)
    ClearPedLastDamageBone(ped)
    ClearPedTasksImmediately(ped)

    -- Reset stati di movimento
    ResetPedMovementClipset(ped, 0.0)

    -- Invincibilità temporanea
    SetEntityInvincible(ped, true)

    -- Rimuove ragdoll forzato
    SetPedCanRagdoll(ped, true)

    -- Rimuovi invincibilità dopo 5 secondi
    SetTimeout(5000, function()
        SetEntityInvincible(ped, false)
    end)
end

-- Funzione per effetti di fumo visibili a tutti
local function CreateSmokeEffects()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    -- Crea fumo visibile a tutti i player
    for i = 1, 5 do
        local offsetX = (i - 3) * 2.0
        UseParticleFxAssetNextCall('core')
        local smoke = StartParticleFxLoopedAtCoord(
            'exp_grd_grenade_smoke',
            coords.x + offsetX,
            coords.y,
            coords.z,
            0.0, 0.0, 0.0,
            3.0,
            false, false, false, false
        )

        SetTimeout(8000, function()
            StopParticleFxLooped(smoke, false)
        end)
    end

    -- Particelle extra
    UseParticleFxAssetNextCall('core')
    local spark = StartParticleFxLoopedAtCoord(
        'ent_amb_falling_sparks',
        coords.x,
        coords.y,
        coords.z + 1.0,
        0.0, 0.0, 0.0,
        2.0,
        false, false, false, false
    )

    SetTimeout(8000, function()
        StopParticleFxLooped(spark, false)
    end)
end

-- Evento principale per la morte
RegisterNetEvent('QBCore:Client:OnPlayerDeath', function()
    if stellareActive then 
        return 
    end

    stellareActive = true
    TriggerServerEvent('stellare:useWatch')
end)

-- Ricevi risposta dal server
RegisterNetEvent('stellare:watchResult')
AddEventHandler('stellare:watchResult', function(success)
    if not success then 
        stellareActive = false
        return 
    end

    stellareActive = true

    Wait(200)

    -- Effetti di fumo
    CreateSmokeEffects()

    -- Effetto NUI SOLO per il player
    SetNuiFocus(true, false)
    SendNUIMessage({
        action = 'showStellare',
        sound = true
    })

    -- Tempo cinematico (7 secondi)
    Wait(7000)

    -- Revive
    TriggerEvent('hospital:client:Revive')

    Wait(500)
    FullHealthReset()

    -- Chiudi effetto
    SendNUIMessage({ action = 'hideStellare' })
    SetNuiFocus(false, false)

    -- Reset
    Wait(1000)
    stellareActive = false
end)

-- Monitoraggio continuo dello stato di morte
local function startDeathMonitoring()
    CreateThread(function()
        while true do
            Wait(1000)

            local ped = PlayerPedId()
            local health = GetEntityHealth(ped)
            local isDead1 = LocalPlayer.state.dead
            local isDead2 = health <= 0

            local isDead = isDead1 or isDead2
            if isDead and not stellareActive then
                -- Controlla se ha l'orologio
                local count = exports.ox_inventory:Search('count', 'orologiostellare')
                
                if count and count > 0 then
                    -- Attiva l'orologio automaticamente
                    TriggerEvent('QBCore:Client:OnPlayerDeath')
                end
            end
        end
    end)
end

-- Evento di morte diretto come backup
AddEventHandler('gameEventTriggered', function(eventName, args)
    if eventName == 'CEventNetworkEntityDamage' then
        local victim = args[1]
        local ped = PlayerPedId()
        
        if victim == ped then
            local health = GetEntityHealth(ped)
            if health <= 0 and not stellareActive then
                -- Controlla se ha l'orologio
                local count = exports.ox_inventory:Search('count', 'orologiostellare')
                if count and count > 0 then
                    TriggerEvent('QBCore:Client:OnPlayerDeath')
                end
            end
        end
    end
end)

-- Evento per uso manuale dall'inventario
exports('orologiostellare:use', function(data, slot)
    TriggerEvent('QBCore:Client:OnPlayerDeath')
end)

-- Inizializzazione
Citizen.CreateThread(function()
    Wait(3000)
    startDeathMonitoring()
    print('[Stellare Watch] Sistema orologio stellare inizializzato')
end)
