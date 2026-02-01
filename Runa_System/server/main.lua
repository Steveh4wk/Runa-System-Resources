-- ==============================================
-- RUNA SYSTEM - Main Server Script (Updated)
-- ==============================================

local PlayerData = {}
local activeRocks = {}

-- Upgrade chances per livello
local upgradeChances = {
    [0] = 80,  -- +0 → +1
    [1] = 65,  -- +1 → +2
    [2] = 50,  -- +2 → +3
    [3] = 35,  -- +3 → +4
    [4] = 20   -- +4 → +5
}

-- ==============================================
-- RESOURCE START/STOP
-- ==============================================

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        TriggerClientEvent('Runa_System:client:start', -1)
        print('[Runa System] Resource started')
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        TriggerClientEvent('Runa_System:client:stop', -1)
        cleanupRocks()
        print('[Runa System] Resource stopped')
    end
end)

-- ==============================================
-- PLAYER LOAD
-- ==============================================

RegisterNetEvent('QBCore:Server:PlayerLoaded', function(player)
    PlayerData = player
    print('[Runa System] Player loaded: ' .. tostring(player?.firstname))
    TriggerClientEvent('Runa_System:client:start', source)
end)

-- ==============================================
-- ROCK MANAGEMENT
-- ==============================================

function cleanupRocks()
    print('[Runa System] Cleaning up rocks...')
    TriggerClientEvent('Runa_System:client:cleanupRocks', -1)
    activeRocks = {}
end

RegisterNetEvent('Runa_System:server:registerRock', function(netId)
    activeRocks[netId] = true
end)

RegisterNetEvent('Runa_System:server:breakRock', function(netId)
    local src = source
    local Player = exports.qbx_core:GetPlayer(src)
    if not Player then return end
    activeRocks[netId] = nil
    print('[Rock] ' .. Player.PlayerData.firstname .. ' broke rock ' .. tostring(netId))
end)

-- ==============================================
-- RUNE UPGRADE SYSTEM
-- ==============================================

RegisterNetEvent('Runa_System:server:upgradeRune', function(runeType, currentLevel)
    local src = source
    print('[Runa Upgrade] upgradeRune called: type=' .. runeType .. ', level=' .. currentLevel)
    
    local Player = exports.ox_inventory:GetPlayer(src)
    if not Player then
        print('[Runa Upgrade] Player not found')
        TriggerClientEvent('Runa_System:client:upgradeResult', src, { success = false, newLevel = 0, error = 'Player not found' })
        return
    end

    local playerName = Player.PlayerData.firstname .. ' ' .. Player.PlayerData.lastname
    print('[Runa Upgrade] ' .. playerName .. ' upgrading: ' .. runeType .. ' +' .. tostring(currentLevel))

    -- Get galleons from player
    local galleons = Player.PlayerData.money?.cash or 0
    local cost = 200

    if galleons < cost then
        print('[Runa Upgrade] Insufficient funds: ' .. galleons .. ' < ' .. cost)
        TriggerClientEvent('Runa_System:client:notification', src, {
            title = 'Insufficient Funds',
            message = 'You need ' .. cost .. ' galleons for the ritual',
            duration = 4000
        })
        TriggerClientEvent('Runa_System:client:upgradeResult', src, { success = false, newLevel = currentLevel, error = 'Insufficient funds' })
        return
    end

    local currentRune = Player:Search(runeType)
    if not currentRune then
        print('[Runa Upgrade] Rune not found: ' .. runeType)
        TriggerClientEvent('Runa_System:client:notification', src, {
            title = 'Rune Not Found',
            message = 'The rune was not found in your inventory',
            duration = 4000
        })
        TriggerClientEvent('Runa_System:client:upgradeResult', src, { success = false, newLevel = currentLevel, error = 'Rune not found' })
        return
    end

    local runeLevel = currentRune.metadata?.level or currentLevel
    if runeLevel ~= currentLevel then
        runeLevel = currentLevel
    end

    local chance = upgradeChances[runeLevel] or 50
    local roll = math.random(100)
    local success = roll <= chance
    print('[Runa Upgrade] Roll: ' .. roll .. ' <= ' .. chance .. ' = ' .. tostring(success))

    -- Remove galleons
    Player.Functions.RemoveMoney('cash', cost, 'rune-upgrade')

    -- Remove old rune
    Player:RemoveItem(runeType, 1)

    -- Add new rune with updated level
    local newLevel = success and runeLevel + 1 or math.max(0, runeLevel - 1)
    local metadata = {
        level = newLevel,
        divina = currentRune.metadata?.divina or false,
        description = runeType .. ' level ' .. newLevel
    }
    Player:AddItem(runeType, 1, metadata)
    print('[Runa Upgrade] Given ' .. runeType .. ' +' .. newLevel)

    -- Send result to client
    TriggerClientEvent('Runa_System:client:upgradeResult', src, {
        success = success,
        newLevel = newLevel,
        runeType = runeType
    })
    print('[Runa Upgrade] Sent upgrade result to client')

    -- Send notification
    if success then
        TriggerClientEvent('Runa_System:client:notification', src, {
            title = 'Upgrade Success!',
            message = runeType .. ' has ascended to level ' .. tostring(newLevel),
            duration = 4000
        })
    else
        TriggerClientEvent('Runa_System:client:notification', src, {
            title = 'Upgrade Failed!',
            message = runeType .. ' has been reduced to level ' .. tostring(newLevel),
            duration = 4000
        })
    end
end)

-- ==============================================
-- DALGONA GIVE REWARD (handler for minigame.lua)
-- ==============================================

RegisterNetEvent('dalgona:giveReward', function(pattern)
    print('[Dalgona] giveReward called: pattern=' .. tostring(pattern))
    -- Re-route to dalgonaWin
    TriggerEvent('Runa_System:server:dalgonaWin', pattern)
end)

-- ==============================================
-- DALGONA MINIGAME REWARD
-- ==============================================

RegisterNetEvent('Runa_System:server:dalgonaWin', function(pattern)
    local src = source
    print('[Dalgona] server:dalgonaWin CALLED! pattern=' .. tostring(pattern) .. ' src=' .. tostring(src))
    
    -- ox_inventory v2.1 usa GetPlayer
    local Player = exports.ox_inventory:GetPlayer(src)
    if not Player then 
        print('[Dalgona] ERROR: Player not found for src=' .. tostring(src))
        return 
    end

    local runeTypes = { 'runa_speed', 'runa_hp', 'runa_mp', 'runa_danno', 'runa_cdr' }
    local randomRune = runeTypes[math.random(#runeTypes)]
    local metadata = { level = 0, divina = false, description = randomRune .. ' level 0' }
    Player:AddItem(randomRune, 1, metadata)
    print('[Dalgona] Given ' .. randomRune .. ' +0 to player')

    if pattern == 'dragon' then
        -- Dragon bonus: give extra runa_danno +0 (NOT +1)
        local dannoMetadata = { level = 0, divina = false, description = 'runa_danno level 0' }
        Player:AddItem('runa_danno', 1, dannoMetadata)
        print('[Dalgona] Bonus: Given runa_danno +0 (dragon pattern)')
        TriggerClientEvent('Runa_System:client:notification', src, {
            title = 'Dragon Pattern!',
            message = 'You got ' .. randomRune .. ' +0 and runa_danno +0!',
            duration = 5000
        })
    else
        TriggerClientEvent('Runa_System:client:notification', src, {
            title = 'Dalgona Won!',
            message = 'You got ' .. randomRune .. ' +0!',
            duration = 3000
        })
    end
end)

-- ==============================================
-- GIVE RANDOM RUNE (from rock gathering)
-- ==============================================

RegisterNetEvent('Runa_System:server:addItem', function(item, count, metadata)
    local src = source
    local Player = exports.ox_inventory:GetPlayer(src)
    if Player then
        Player:AddItem(item, count, metadata)
        print('[Rock] Given ' .. item .. ' x' .. tostring(count) .. ' to player')
    end
end)

-- ==============================================
-- GET INVENTORY RUNES (for crafting menu)
-- ==============================================

RegisterNetEvent('Runa_System:server:getInventoryRunes', function()
    local src = source
    print('[Rockstone] Server: getInventoryRunes called')
    
    -- ox_inventory v2.1 usa GetPlayer
    local Player = exports.ox_inventory:GetPlayer(src)
    if not Player then 
        print('[Rockstone] Server: Player not found')
        return 
    end
    
    -- Get all items directly
    local items = Player.items or {}
    
    print('[Rockstone] Server: Player has ' .. #items .. ' total items')
    
    -- Filtra solo le rune
    local runeTypes = { 'runa_speed', 'runa_hp', 'runa_mp', 'runa_danno', 'runa_cdr' }
    local runes = {}
    
    if items and type(items) == 'table' then
        for _, item in ipairs(items) do
            if item and item.name and table.includes(runeTypes, item.name) then
                table.insert(runes, {
                    name = item.name,
                    count = item.count or 1,
                    metadata = item.metadata or {}
                })
            end
        end
    end
    
    print('[Rockstone] Server: Found ' .. #runes .. ' runes, sending to client')
    
    -- Invia al client
    TriggerClientEvent('Runa_System:client:showCraftingMenu', src, runes)
end)
