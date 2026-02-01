-- Supporto framework per QB-Core e luman-bridge
-- Usa notifica QB-Core se disponibile, altrimenti fallback a notifica nativa

Framework = {}

-- Prova notifica QB-Core prima
function Framework.showNotification(message)
    -- Prova export QB-Core
    if exports['qb-core'] and exports['qb-core']:GetCoreObject() then
        local QBCore = exports['qb-core']:GetCoreObject()
        QBCore.Functions.Notify(message)
        return
    end
    
    -- Prova notifica ox_lib
    if exports['ox_lib'] and exports['ox_lib'].notify then
        exports['ox_lib']:notify({
            title = 'Dalgona Game',
            description = message,
            type = 'inform'
        })
        return
    end
    
    -- Fallback a notifica nativa FiveM
    SetNotificationTextEntry("STRING")
    AddTextComponentString(message)
    DrawNotification(false, false)
end
