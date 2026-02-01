-- Stefano Luciano Corp. per AstralRP - Orologio Stellare Server System Standalone
-- Gestione cooldown e logica orologio

local stellareCooldowns = {}

-- Callback per QBCore (compatibilità)
if QBCore and QBCore.Functions then
    QBCore.Functions.CreateCallback('metal_detector:useStellare', function(source, cb)
        -- Controlla cooldown
        if stellareCooldowns[source] and os.time() < stellareCooldowns[source] then
            TriggerClientEvent('QBCore:Notify', source, 'L\'Orologio Stellare è in cooldown!', 'error')
            cb(false)
            return
        end

        -- Controlla se il player ha almeno un orologio
        local count = exports.ox_inventory:Search(source, 'count', 'orologiostellare')

        if count and count > 0 then
            -- Rimuovi solo 1 orologio
            exports.ox_inventory:RemoveItem(source, 'orologiostellare', 1)

            -- Imposta cooldown di 30 minuti
            stellareCooldowns[source] = os.time() + (30 * 60)

            -- Notifica
            if count == 1 then
                TriggerClientEvent('QBCore:Notify', source, 'Orologio Stellare usato! Sei stato curato completamente.', 'success')
            end

            cb(true)
        else
            cb(false)
        end
    end)
end

-- Evento diretto senza QBCore
RegisterServerEvent('stellare:useWatch')
AddEventHandler('stellare:useWatch', function()
    local source = source
    
    -- Controlla cooldown
    if stellareCooldowns[source] and os.time() < stellareCooldowns[source] then
        local remainingTime = stellareCooldowns[source] - os.time()
        local minutes = math.floor(remainingTime / 60)
        local seconds = remainingTime % 60
        
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = string.format('L\'Orologio Stellare è in cooldown! Tempo rimanente: %d:%02d', minutes, seconds)
        })
        return
    end

    -- Controlla se il player ha almeno un orologio
    local count = exports.ox_inventory:Search(source, 'count', 'orologiostellare')

    if count and count > 0 then
        -- Rimuovi solo 1 orologio
        exports.ox_inventory:RemoveItem(source, 'orologiostellare', 1)

        -- Imposta cooldown di 30 minuti
        stellareCooldowns[source] = os.time() + (30 * 60)

        -- Notifica
        if count == 1 then
            TriggerClientEvent('ox_lib:notify', source, {
                type = 'success',
                description = 'Orologio Stellare usato! Sei stato curato completamente.'
            })
        end

        -- Rispondi al client che ha successo
        TriggerClientEvent('stellare:watchResult', source, true)
        
        print(string.format('[Stellare Watch] Player %s ha usato l\'orologio stellare', GetPlayerName(source)))
    else
        TriggerClientEvent('stellare:watchResult', source, false)
    end
end)

-- Comando per controllare cooldown (admin)
RegisterCommand('stellare_cooldown', function(source, args, rawCommand)
    if source == 0 then -- Console
        local targetId = tonumber(args[1])
        if targetId then
            if stellareCooldowns[targetId] and os.time() < stellareCooldowns[targetId] then
                local remainingTime = stellareCooldowns[targetId] - os.time()
                local minutes = math.floor(remainingTime / 60)
                local seconds = remainingTime % 60
                print(string.format('[Stellare Watch] Player %s ha cooldown di %d:%02d', GetPlayerName(targetId), minutes, seconds))
            else
                print(string.format('[Stellare Watch] Player %s non ha cooldown attivo', GetPlayerName(targetId)))
            end
        else
            print('Uso: /stellare_cooldown [playerId]')
        end
    end
end, false)

-- Comando per resettare cooldown (admin)
RegisterCommand('stellare_reset', function(source, args, rawCommand)
    if source == 0 then -- Console
        local targetId = tonumber(args[1])
        if targetId then
            stellareCooldowns[targetId] = nil
            print(string.format('[Stellare Watch] Cooldown resettato per player %s', GetPlayerName(targetId)))
        else
            print('Uso: /stellare_reset [playerId]')
        end
    end
end, false)

print('[Stellare Watch] Server orologio stellare caricato')
