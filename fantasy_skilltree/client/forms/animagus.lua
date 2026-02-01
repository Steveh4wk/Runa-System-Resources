-- client/forms/animagus.lua
-- Stefano Luciano Corp
-- Spell specifiche Animagus
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

local AnimagusSpells = {
    [0] = function() 
        print('[Animagus] Slot 0: Flight Boost')
        notifyPlayer({
            title = 'Animagus',
            description = 'Flight Boost attivato!',
            type = 'success'
        })
    end,
    [1] = function() 
        print('[Animagus] Slot 1: Enhanced Senses')
        notifyPlayer({
            title = 'Animagus',
            description = 'Sensi potenziati!',
            type = 'success'
        })
    end,
    [2] = function() 
        print('[Animagus] Slot 2: Beast Strike')
        notifyPlayer({
            title = 'Animagus',
            description = 'Beast Strike attivato!',
            type = 'success'
        })
    end,
    [3] = function() 
        print('[Animagus] Slot 3: Camouflage')
        notifyPlayer({
            title = 'Animagus',
            description = 'Camouflage attivato!',
            type = 'success'
        })
    end,
    [4] = function() 
        print('[Animagus] Slot 4: Healing Aura')
        notifyPlayer({
            title = 'Animagus',
            description = 'Aura curativa attivata!',
            type = 'success'
        })
    end,
    [5] = function() 
        print('[Animagus] Slot 5: Roar')
        notifyPlayer({
            title = 'Animagus',
            description = 'Ruggito potente!',
            type = 'success'
        })
    end,
    [6] = function() 
        print('[Animagus] Slot 6: Ultimate Form')
        notifyPlayer({
            title = 'Animagus',
            description = 'Forma Ultima attivata!',
            type = 'success'
        })
    end
}

RegisterNetEvent('fantasy_skilltree:client:castSpell', function(form, slot)
    if form ~= 'animagus' then return end
    local spell = AnimagusSpells[slot]
    if spell then 
        spell()
    else
        print('[Animagus] Spell non trovata per slot:', slot)
    end
end)

exports('GetAnimagusSpells', function() return AnimagusSpells end)

print('[Animagus] Spells loaded')
