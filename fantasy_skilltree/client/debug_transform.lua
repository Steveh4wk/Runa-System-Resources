-- debug_transform.lua
-- Script di debug per verificare lo stato delle trasformazioni

RegisterCommand('debugtransform', function()
    local ped = PlayerPedId()
    local form = LocalPlayer.state.fantasyForm
    
    print('[DEBUG TRANSFORM] Stato attuale:')
    print('[DEBUG TRANSFORM] Forma:', form)
    print('[DEBUG TRANSFORM] Vampire Aura:', Entity(ped).state.vampireAura)
    print('[DEBUG TRANSFORM] Lycan Speed:', Entity(ped).state.lycanSpeed)
    print('[DEBUG TRANSFORM] Lycan Transform:', Entity(ped).state.lycanTransform)
    
    -- Controlla spell attive
    local activeSpellsCount = 0
    for key, _ in pairs(activeSpells or {}) do
        print('[DEBUG TRANSFORM] Spell attiva:', key)
        activeSpellsCount = activeSpellsCount + 1
    end
    print('[DEBUG TRANSFORM] Spell attive totali:', activeSpellsCount)
    
    -- Controlla cooldowns
    if form then
        for slot = 0, 9 do
            if isOnCooldown(slot) then
                print('[DEBUG TRANSFORM] Cooldown attivo - Slot', slot)
            end
        end
    end
end)

RegisterCommand('forcereset', function()
    print('[DEBUG TRANSFORM] Forzo reset completo')
    
    local ped = PlayerPedId()
    
    -- Resetta tutti gli stati
    Entity(ped).state.vampireAura = false
    Entity(ped).state.lycanSpeed = false
    Entity(ped).state.lycanTransform = false
    
    -- Resetta effetti
    SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
    SetPlayerMeleeWeaponDamageModifier(PlayerId(), 1.0)
    SetEntityAlpha(ped, 255, false)
    ClearTimecycleModifier()
    
    -- Resetta spell attive
    if activeSpells then
        activeSpells = {}
    end
    
    print('[DEBUG TRANSFORM] Reset completato')
    
    if lib then
        lib.notify({
            title = 'Debug Transform',
            description = 'Reset completo eseguito',
            type = 'info'
        })
    end
end)

RegisterCommand('testtransform', function()
    local form = LocalPlayer.state.fantasyForm
    if form ~= 'lycan' then
        print('[DEBUG TRANSFORM] Devi essere in forma lycan')
        return
    end
    
    local ped = PlayerPedId()
    local currentState = Entity(ped).state.lycanTransform
    
    -- Simula pressione tasto 6
    castSpell(6)
    
    print('[DEBUG TRANSFORM] Test trasformazione eseguito')
    print('[DEBUG TRANSFORM] Stato prima:', currentState)
    print('[DEBUG TRANSFORM] Stato dopo:', Entity(ped).state.lycanTransform)
end)

print('[DEBUG TRANSFORM] Script debug trasformazioni caricato')
