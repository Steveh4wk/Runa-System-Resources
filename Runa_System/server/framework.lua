-- Supporto framework usando ox_inventory direttamente
-- Fallback a luman-bridge se disponibile

local useLumanBridge = exports['luman-bridge'] ~= nil

Framework = {}

function Framework.hasItem(playerId, item, amount)
    if useLumanBridge then
        return exports['luman-bridge']:getItemAmount(playerId, item) >= amount
    end
    
    -- Fallback a ox_inventory
    local player = exports.ox_inventory:GetPlayer(playerId)
    if player then
        local count = player.items[item] or 0
        return count >= amount
    end
    return false
end

function Framework.takeItem(playerId, item, amount)
    if useLumanBridge then
        return exports['luman-bridge']:removeItem(playerId, item, amount)
    end
    
    -- Fallback a ox_inventory
    local removed = exports.ox_inventory:RemoveItem(playerId, item, amount)
    return removed ~= nil
end

function Framework.giveItem(playerId, item, amount)
    if useLumanBridge then
        return exports['luman-bridge']:addItem(playerId, item, amount)
    end
    
    -- Fallback a ox_inventory
    local added = exports.ox_inventory:AddItem(playerId, item, amount)
    return added ~= nil
end

function Framework.hasMoney(playerId, amount)
    if useLumanBridge then
        return exports['luman-bridge']:getMoneyAmount(playerId) >= amount
    end
    
    -- ox_inventory non gestisce soldi, usa native
    local money = GetPlayerMoney(playerId)
    return money >= amount
end

function Framework.takeMoney(playerId, amount)
    if useLumanBridge then
        return exports['luman-bridge']:removeMoney(playerId, amount)
    end
    
    -- Usa soldi nativi
    return RemovePlayerMoney(playerId, amount)
end

function Framework.giveMoney(playerId, amount)
    if useLumanBridge then
        return exports['luman-bridge']:addMoney(playerId, amount)
    end
    
    -- Usa soldi nativi
    return AddPlayerMoney(playerId, amount)
end

function Framework.showNotification(playerId, message)
    if useLumanBridge then
        return exports['luman-bridge']:notify(playerId, message)
    end
    
    -- Fallback a notifica ox_lib
    TriggerClientEvent('ox_lib:notify', playerId, {
        type = 'success',
        description = message
    })
end

function Framework.getCharacterName(playerId)
    if useLumanBridge then
        local firstName, lastName = exports['luman-bridge']:getCharacterName(playerId)
        return firstName .. ' ' .. lastName
    end
    
    -- Fallback - ritorna ID player come nome
    return 'Player ' .. playerId
end
