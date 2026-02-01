-- client/forms/lycan.lua
-- Stefano Luciano Corp
-- Spell specifiche Lycan secondo specifiche dettagliate
-- ========================================

-- Funzione per controllare se è notte
local function isNightTime()
    local hour = GetClockHours()
    return hour >= 20 or hour < 6  -- Notte: 20:00 - 05:59
end

-- Funzione per controllare se è giorno
local function isDayTime()
    return not isNightTime()
end

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

-- Variabili globali per gestione trasformazione notturna
local originalPedModel = nil
local isPotionActive = false
local lastPotionTime = 0

-- Thread per controllo ciclo giorno/notte e trasformazione automatica
CreateThread(function()
    while true do
        Wait(5000) -- Controlla ogni 5 secondi
        
        local ped = PlayerPedId()
        local playerData = {}
        
        -- Ottieni dati player per controllare inventario
        if QBCore and QBCore.Functions.GetPlayerData then
            playerData = QBCore.Functions.GetPlayerData()
        end
        
        -- Controlla se ha pozione anti-lupo nell'inventario
        local hasAntiPotion = false
        if playerData and playerData.items then
            for _, item in ipairs(playerData.items) do
                if item.name == 'pozione_antilupo' and item.amount > 0 then
                    hasAntiPotion = true
                    break
                end
            end
        end
        
        -- Se è notte e non è trasformato e non ha pozione anti-lupo -> trasformazione automatica
        if isNightTime() and not Entity(ped).state.lycanTransform and not hasAntiPotion then
            -- Controlla se è lycan (ha accesso alle spell lycan)
            local isLycanPlayer = false
            if LocalPlayer.state.fantasyForm == 'lycan' or Entity(ped).state.isLycan then
                isLycanPlayer = true
            end
            
            if isLycanPlayer then
                -- Trasformazione automatica
                notifyPlayer({
                    title = 'Lycan',
                    description = 'La notte ti chiama! Trasformazione automatica in lycan...',
                    type = 'warning'
                })
                
                -- RIMOSSO: Auto-trigger trasformazione per evitare doppio cast
-- if isNightTime() then
--     TriggerEvent('fantasy_skilltree:client:castSpell', 'lycan', 6)
-- end
            end
        end
        
        -- Se è giorno e il lycan è trasformato, ritorna umano con UI reset
        if isDayTime() and Entity(ped).state.lycanTransform then
            -- Usa la funzione avanzata che nasconde UI e ricarica config
            if exports['fantasy_peds'] and exports['fantasy_peds'].RestoreHumanWithUI then
                exports['fantasy_peds']:RestoreHumanWithUI()
            else
                TriggerEvent('fantasy_peds:client:RestoreHuman')
            end
            notifyPlayer({
                title = 'Lycan',
                description = 'Il sole sorge! Ritorni alla forma umana...',
                type = 'info'
            })
        end
        
        -- Resetta pozione anti-lupo ogni giorno
        if isDayTime() and isPotionActive then
            isPotionActive = false
            notifyPlayer({
                title = 'Lycan',
                description = 'L\'effetto della pozione anti-lupo è svanito con il nuovo giorno...',
                type = 'info'
            })
        end
    end
end)

local LycanSpells = {
    [6] = function()
        print('[Lycan] Slot 6: Trasformazione')
        local ped = PlayerPedId()
        
        -- Controlla se è notte
        if not isNightTime() then
            notifyPlayer({
                title = 'Lycan',
                description = 'Puoi trasformarti solo di notte (20:00 - 05:59)!',
                type = 'error'
            })
            return
        end
        
        -- Controlla se pozione anti-lupo è attiva
        if isPotionActive then
            notifyPlayer({
                title = 'Lycan',
                description = 'La pozione anti-lupo ti protegge questa notte!',
                type = 'error'
            })
            return
        end
        
        -- Controlla se ha pozione anti-lupo nell'inventario (blocco trasformazione manuale)
        local playerData = {}
        if QBCore and QBCore.Functions.GetPlayerData then
            playerData = QBCore.Functions.GetPlayerData()
        end
        
        local hasAntiPotion = false
        if playerData and playerData.items then
            for _, item in ipairs(playerData.items) do
                if item.name == 'pozione_antilupo' and item.amount > 0 then
                    hasAntiPotion = true
                    break
                end
            end
        end
        
        if hasAntiPotion then
            notifyPlayer({
                title = 'Lycan',
                description = 'Hai una pozione anti-lupo! Bevila per bloccare la trasformazione.',
                type = 'error'
            })
            return
        end
        
        -- Controlla se trasformazione è già attiva
        if Entity(ped).state.lycanTransform then
            -- Disattiva trasformazione
            SetEntityHealth(ped, GetEntityHealth(ped) - 100) -- Perde 100 HP
            SetPlayerMeleeWeaponDamageModifier(PlayerId(), 1.0)
            SetEntityAlpha(ped, 255, false)
            ClearTimecycleModifier()
            Entity(ped).state.lycanTransform = false
            
            notifyPlayer({
                title = 'Lycan',
                description = 'Trasformazione terminata! Potere ridotto.',
                type = 'info'
            })
            return
        end
        
        -- Salva il modello originale del ped
        originalPedModel = GetEntityModel(ped)
        
        -- Animazione trasformazione lycan potente
        TaskPlayAnim(ped, "missheistdocks2preig_1@context_ext_ig_0", "handsup_base", 8.0, -8.0, 4000, 48, 0, 0, 0, 0)
        
        -- Effetti trasformazione intensi
        SetEntityHealth(ped, 400)
        SetPlayerMeleeWeaponDamageModifier(PlayerId(), 3.0)
        
        -- Particelle trasformazione esplosive
        UseParticleFxAssetNextCall("core")
        local particle1 = StartParticleFxLoopedOnEntity("ent_amb_fbi_gas_station_burst", ped, 0.0, 0.0, 0.5, 0.0, 0.0, 0.0, 3.0, false, false, false)
        local particle2 = StartParticleFxLoopedOnEntity("exp_grd_grenade_smoke", ped, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, false, false, false)
        
        -- Effetto aura lycan potente
        SetEntityAlpha(ped, 140, false)
        SetTimecycleModifier("tunnel_lights")
        
        -- Terremoto trasformazione
        ShakeGameplayCam("LARGE_EXPLOSION_SHAKE", 2000)
        
        -- Effetto sonoro
        PlayPedAmbientSpeechNative(ped, "GENERIC_CURSE_HIGH", "SPEECH_PARAMS_FORCE")
        
        -- Imposta stato trasformazione attiva
        Entity(ped).state.lycanTransform = true
        
        Wait(3500)
        SetEntityAlpha(ped, 180, false)
        ClearTimecycleModifier()
        StopParticleFxLooped(particle1, false)
        StopParticleFxLooped(particle2, false)
        
        notifyPlayer({
            title = 'Lycan',
            description = 'TRASFORMAZIONE COMPLETATA! Potere lupino attivato!',
            type = 'success'
        })
    end,
    [7] = function()
        print('[Lycan] Slot 7: Corsa')
        local ped = PlayerPedId()
        
        -- Controlla se corsa è già attiva
        if Entity(ped).state.lycanSpeed then
            -- Disattiva corsa
            SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
            SetEntityAlpha(ped, 255, false)
            Entity(ped).state.lycanSpeed = false
            
            notifyPlayer({
                title = 'Lycan',
                description = 'Corsa selvaggia disattivata.',
                type = 'info'
            })
        else
            -- Animazione attivazione corsa
            RequestAnimDict("move_m@jumper@base")
            while not HasAnimDictLoaded("move_m@jumper@base") do Wait(10) end
            
            TaskPlayAnim(ped, "move_m@jumper@base", "dive_start_run", 8.0, -8.0, 1000, 1, 0, 0, 0, 0)
            
            Wait(500)
            
            SetRunSprintMultiplierForPlayer(PlayerId(), 1.4)
            Entity(ped).state.lycanSpeed = true
            
            notifyPlayer({
                title = 'Lycan',
                description = 'CORSA SELVAGGIA! +40% velocità, stamina infinita!',
                type = 'success'
            })
        end
    end,
    [8] = function() 
        print('[Lycan] Slot 8: Graffio')
        local ped = PlayerPedId()
        
        -- Animazione graffio
        RequestAnimDict("melee@unarmed@streamed_core")
        while not HasAnimDictLoaded("melee@unarmed@streamed_core") do Wait(10) end
        
        TaskPlayAnim(ped, "melee@unarmed@streamed_core", "attack_0", 8.0, -8.0, 1000, 1, 0, 0, 0, 0)
        
        -- Particelle graffio
        local particleDict = "scr_indep_fireworks"
        RequestNamedPtfxAsset(particleDict)
        while not HasNamedPtfxAssetLoaded(particleDict) do Wait(10) end
        
        UseParticleFxAssetNextCall(particleDict)
        local shockwave = StartParticleFxLoopedOnEntity("scr_firework_xmas_ring_burst_r", ped, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, false, false, false)
        
        Wait(800)
        
        StopParticleFxLooped(shockwave, false)
        
        notifyPlayer({
            title = 'Lycan',
            description = 'GRAFFIO FEROCE! 6 metri, 30 HP danno!',
            type = 'success'
        })
    end,
    [9] = function() 
        print('[Lycan] Slot 9: Morso')
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        
        -- Cerca target nelle vicinanze
        local closestPlayer, closestDistance = nil, 6.0
        for _, id in ipairs(GetActivePlayers()) do
            local targetPed = GetPlayerPed(id)
            if targetPed ~= ped then
                local targetCoords = GetEntityCoords(targetPed)
                local distance = #(coords - targetCoords)
                if distance < closestDistance then
                    closestDistance = distance
                    closestPlayer = targetPed
                end
            end
        end
        
        if closestPlayer then
            -- Animazione morso
            RequestAnimDict("creatures@coyote@move")
            while not HasAnimDictLoaded("creatures@coyote@move") do Wait(10) end
            
            TaskPlayAnim(ped, "creatures@coyote@move", "attack", 8.0, -8.0, 1500, 1, 0, 0, 0, 0)
            
            -- Particelle morso
            local particleDict = "scr_rcbarry1"
            RequestNamedPtfxAsset(particleDict)
            while not HasNamedPtfxAssetLoaded(particleDict) do Wait(10) end
            
            UseParticleFxAssetNextCall(particleDict)
            local particle1 = StartParticleFxLoopedOnEntity("scr_alien_teleport", ped, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, false, false, false)
            local particle2 = StartParticleFxLoopedOnEntity("scr_alien_teleport", closestPlayer, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, false, false, false)
            
            -- Applica effetti al target
            SetEntityHealth(closestPlayer, GetEntityHealth(closestPlayer) - 30)
            SetPedToRagdoll(closestPlayer, 60000, 60000, 0, true, true, false)
            
            Wait(1000)
            StopParticleFxLooped(particle1, false)
            StopParticleFxLooped(particle2, false)
            
            notifyPlayer({
                title = 'Lycan',
                description = 'MORSO BRUTALE! 1 minuto ragdoll + black screen totale!',
                type = 'success'
            })
        else
            notifyPlayer({
                title = 'Lycan',
                description = 'Nessun bersaglio nelle vicinanze!',
                type = 'error'
            })
        end
    end,
    [0] = function() 
        print('[Lycan] Slot 0: Anti-Pozione')
        local ped = PlayerPedId()
        
        -- Controlla se è notte
        if not isNightTime() then
            notifyPlayer({
                title = 'Lycan',
                description = 'La pozione anti-lupo è efficace solo di notte!',
                type = 'error'
            })
            return
        end
        
        -- Animazione bevuta pozione
        RequestAnimDict("amb@world_human_drinking@coffee@male@idle_a")
        while not HasAnimDictLoaded("amb@world_human_drinking@coffee@male@idle_a") do Wait(10) end
        
        TaskPlayAnim(ped, "amb@world_human_drinking@coffee@male@idle_a", "idle_c", 8.0, -8.0, 2000, 49, 0, 0, 0, 0)
        
        -- Particelle protezione
        local particleDict = "scr_indep_fireworks"
        RequestNamedPtfxAsset(particleDict)
        while not HasNamedPtfxAssetLoaded(particleDict) do Wait(10) end
        
        UseParticleFxAssetNextCall(particleDict)
        local particle = StartParticleFxLoopedOnEntity("scr_firework_xmas_ring_burst_b", ped, 0.0, 0.0, 0.5, 0.0, 0.0, 0.0, 1.0, false, false, false)
        
        isPotionActive = true
        lastPotionTime = GetGameTimer()
        
        Wait(1500)
        StopParticleFxLooped(particle, false)
        
        notifyPlayer({
            title = 'Lycan',
            description = 'Protezione anti-lupo attivata fino all\'alba!',
            type = 'success'
        })
    end,
}

RegisterNetEvent('fantasy_skilltree:client:castSpell', function(form, slot)
    if form ~= 'lycan' then return end
    local spell = LycanSpells[slot]
    if spell then spell() end
end)

exports('GetLycanSpells', function() return LycanSpells end)
