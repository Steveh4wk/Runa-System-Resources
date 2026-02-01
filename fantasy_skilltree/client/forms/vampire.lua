-- client/forms/vampire.lua
-- Stefano Luciano Corp
-- Spell specifiche Vampire secondo specifiche dettagliate
-- ========================================

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

local VampireSpells = {
    [6] = function()
        print('[Vampire] Slot 6: Aura')
        local ped = PlayerPedId()
        
        -- Controlla se aura è già attiva
        if Entity(ped).state.vampireAura then
            -- Disattiva aura
            SetEntityAlpha(ped, 255, false)
            ClearTimecycleModifier()
            Entity(ped).state.vampireAura = false
            
            notifyPlayer({
                title = 'Vampire',
                description = 'Aura rossa disattivata.',
                type = 'info'
            })
            return
        end
        
        -- Animazione attivazione aura
        TaskPlayAnim(ped, "amb@world_human_yoga@male@base", "base_a", 8.0, -8.0, 2000, 1, 0, 0, 0, 0)
        
        -- Aura rossa attorno al Vampire
        SetEntityAlpha(ped, 150, false)
        SetTimecycleModifier("rply_saturation")
        
        -- Particelle aura rossa intensa
        UseParticleFxAssetNextCall("core")
        local particle1 = StartParticleFxLoopedOnEntity("ent_amb_fbi_gas_station_burst", ped, 0.0, 0.0, 0.5, 0.0, 0.0, 0.0, 1.5, false, false, false)
    end,
    [7] = function()
        print('[Vampire] Slot 7: Morso')
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        
        -- Verifica se aura è attiva
        if not Entity(ped).state.vampireAura then
            notifyPlayer({
                title = 'Vampire',
                description = 'Aura non attiva! Attivala prima di mordere.',
                type = 'error'
            })
            return
        end
        
        -- Cerca target nelle vicinanze
        local closestPlayer, closestDistance = nil, 3.0
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
            -- Animazione morso vampire
            RequestAnimDict("melee@unarmed@streamed_core")
            while not HasAnimDictLoaded("melee@unarmed@streamed_core") do Wait(10) end
            
            TaskPlayAnim(ped, "melee@unarmed@streamed_core", "ground_attack_0", 8.0, -8.0, 1500, 1, 0, 0, 0, 0)
            
            -- Particelle sangue
            local particleDict = "scr_rcbarry1"
            RequestNamedPtfxAsset(particleDict)
            while not HasNamedPtfxAssetLoaded(particleDict) do Wait(10) end
            
            UseParticleFxAssetNextCall(particleDict)
            local particle1 = StartParticleFxLoopedOnEntity("scr_alien_teleport", ped, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, false, false, false)
            local particle2 = StartParticleFxLoopedOnEntity("scr_alien_teleport", closestPlayer, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, false, false, false)
            
            -- Applica effetti al target
            SetEntityHealth(closestPlayer, GetEntityHealth(closestPlayer) - 25)
            SetPedToRagdoll(closestPlayer, 60000, 60000, 0, true, true, false)
            
            -- Applica effetti al vampire
            SetEntityHealth(ped, math.min(200, GetEntityHealth(ped) + 25))
            
            Wait(1000)
            StopParticleFxLooped(particle1, false)
            StopParticleFxLooped(particle2, false)
            
            notifyPlayer({
                title = 'Vampire',
                description = 'MORSO RP eseguito! 1 minuto ragdoll + refill completo',
                type = 'success'
            })
        else
            notifyPlayer({
                title = 'Vampire',
                description = 'Nessun bersaglio nelle vicinanze!',
                type = 'error'
            })
        end
    end,
    [8] = function()
        print('[Vampire] Slot 8: Nutriti')
        local ped = PlayerPedId()
        
        -- Controlla se ha sangue nell'inventario
        local hasBlood = exports.ox_inventory:Search('count', 'sangue') > 0
        
        if not hasBlood then
            notifyPlayer({
                title = 'Vampire',
                description = 'Non hai sangue nell\'inventario!',
                type = 'error'
            })
            return
        end
        
        -- Animazione nutrizione
        RequestAnimDict("mp_player_intdrink")
        while not HasAnimDictLoaded("mp_player_intdrink") do Wait(10) end
        
        TaskPlayAnim(ped, 'mp_player_intdrink', 'loop_bottle', 8.0, -8.0, 2500, 49, 0, false, false, false)
        
        -- Particelle nutrizione
        local particleDict = "scr_rcbarry1"
        RequestNamedPtfxAsset(particleDict)
        while not HasNamedPtfxAssetLoaded(particleDict) do Wait(10) end
        
        UseParticleFxAssetNextCall(particleDict)
        local particle = StartParticleFxLoopedOnEntity("scr_alien_teleport", ped, 0.0, 0.0, 0.5, 0.0, 0.0, 0.0, 1.0, false, false, false)
        
        -- Rimuovi sangue dall'inventario
        exports.ox_inventory:RemoveItem('sangue', 1)
        
        Wait(1500)
        StopParticleFxLooped(particle, false)
        
        notifyPlayer({
            title = 'Vampire',
            description = 'Nutrizione completata! Refill cibo/acqua +50 HP',
            type = 'success'
        })
    end,
    [9] = function()
        print('[Vampire] Slot 9: Velocità')
        local ped = PlayerPedId()
        
        -- Animazione velocità
        RequestAnimDict("move_m@jumper@base")
        while not HasAnimDictLoaded("move_m@jumper@base") do Wait(10) end
        
        TaskPlayAnim(ped, "move_m@jumper@base", "dive_start_run", 8.0, -8.0, 1000, 1, 0, 0, 0, 0)
        
        Wait(500)
        
        -- Applica effetto velocità temporaneo
        SetRunSprintMultiplierForPlayer(PlayerId(), 1.3)
        
        notifyPlayer({
            title = 'Vampire',
            description = 'Velocità vampirica attivata! +30% velocità per 10 secondi',
            type = 'success'
        })
        
        -- Rimuovi effetto dopo 10 secondi
        SetTimeout(10000, function()
            SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
            notifyPlayer({
                title = 'Vampire',
                description = 'Effetto velocità terminato',
                type = 'info'
            })
        end)
    end,
    [0] = function()
        print('[Vampire] Slot 0: Resistenza')
        local ped = PlayerPedId()
        
        -- Animazione resistenza
        RequestAnimDict("missheistdockssetup1ig_10@handsup_base")
        while not HasAnimDictLoaded("missheistdockssetup1ig_10@handsup_base") do Wait(10) end
        
        TaskPlayAnim(ped, "missheistdockssetup1ig_10@handsup_base", "handsup_base", 8.0, -8.0, 1500, 1, 0, 0, 0, 0)
        
        Wait(800)
        
        -- Applica armatura temporanea
        SetEntityArmour(ped, 100)
        
        notifyPlayer({
            title = 'Vampire',
            description = 'Resistenza vampirica attivata! Armatura completa per 15 secondi',
            type = 'success'
        })
        
        -- Rimuovi armatura dopo 15 secondi
        SetTimeout(15000, function()
            SetEntityArmour(ped, 0)
            notifyPlayer({
                title = 'Vampire',
                description = 'Effetto resistenza terminato',
                type = 'info'
            })
        end)
    end,
}

RegisterNetEvent('fantasy_skilltree:client:castSpell', function(form, slot)
    if form ~= 'vampire' then return end
    local spell = VampireSpells[slot]
    if spell then spell() end
end)

exports('GetVampireSpells', function() return VampireSpells end)
