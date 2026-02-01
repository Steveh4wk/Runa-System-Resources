-- Stefano Luciano Corp. Dev - Orologio Stellare Server System
-- Integrato in Runa_System

local stellareCooldowns = {}

-- Callback per QBCore (mantenuto per compatibilità)
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
            stellareCooldowns[source] = os.time() + (0 * 0) -- ORLOGIO SENZA COOLDOWN PER TEST

            -- Notifica solo se era il primo/unico orologio
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
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'L\'Orologio Stellare è in cooldown!'
        })
        return
    end

    -- Controlla se il player ha almeno un orologio
    local count = exports.ox_inventory:Search(source, 'count', 'orologiostellare')

    if count and count > 0 then
        -- Rimuovi solo 1 orologio
        exports.ox_inventory:RemoveItem(source, 'orologiostellare', 1)

        -- Imposta cooldown di 30 minuti
        stellareCooldowns[source] = os.time() + (30 * 60) -- ORLOGIO con cooldown 30min

        -- Notifica solo se era il primo/unico orologio
        if count == 1 then
            TriggerClientEvent('ox_lib:notify', source, {
                type = 'success',
                description = 'Orologio Stellare usato! Sei stato curato completamente.'
            })
        end

        -- Rispondi al client che ha successo
        TriggerClientEvent('stellare:watchResult', source, true)
    else
        TriggerClientEvent('stellare:watchResult', source, false)
    end
end)
