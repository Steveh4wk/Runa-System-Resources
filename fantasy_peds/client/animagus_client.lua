-- animagus_client.lua
-- Gestione trasformazioni Animagus per Fantasy Peds
-- Stefano Luciano Corp

local AnimagusAnimals = {
    'a_c_deer',
    'a_c_coyote', 
    'a_c_mtlion',
    'a_c_boar',
    'a_c_cow',
    'a_c_pig',
    'a_c_chicken',
    'a_c_rabbit',
    'a_c_chimp',
    'a_c_retriever'
}

local CurrentAnimal = nil
local OriginalPed = nil

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

-- Funzione per caricare modello sicuro
local function LoadModelSafe(model)
    if type(model) == 'string' then
        model = GetHashKey(model)
    end
    
    RequestModel(model)
    local timeout = GetGameTimer() + 10000 -- 10 secondi timeout
    
    while not HasModelLoaded(model) do
        if GetGameTimer() > timeout then
            print('[FANTASY_PEDS] Errore: Timeout caricamento modello', model)
            return nil
        end
        Wait(10)
    end
    
    return model
end

-- Funzione per trasformarsi in animale
local function TransformToAnimal()
    local playerPed = PlayerPedId()
    
    -- Salva ped originale
    OriginalPed = GetEntityModel(playerPed)
    
    -- Scegli animale casuale
    local randomIndex = math.random(1, #AnimagusAnimals)
    local animalModel = AnimagusAnimals[randomIndex]
    
    print('[FANTASY_PEDS] Trasformazione in:', animalModel)
    
    -- Carica modello animale
    local model = LoadModelSafe(animalModel)
    if not model then
        notifyPlayer({
            title = 'Animagus',
            description = 'Errore caricamento modello animale!',
            type = 'error'
        })
        return
    end
    
    -- Trasforma giocatore
    SetPlayerModel(PlayerId(), model)
    SetPedDefaultComponentVariation(PlayerPedId())
    Wait(100)
    
    -- Imposta stato
    LocalPlayer.state:set('fantasyForm', 'animagus', true)
    CurrentAnimal = animalModel
    
    -- Notifica
    notifyPlayer({
        title = 'Animagus',
        description = 'Ti sei trasformato in ' .. animalModel,
        type = 'success'
    })
    
    -- Pulisci modello
    SetModelAsNoLongerNeeded(model)
end

-- Funzione per ripristinare forma umana
local function RestoreHumanForm()
    if not OriginalPed then return end
    
    print('[FANTASY_PEDS] Ripristino forma umana')
    
    -- Carica modello originale
    local model = LoadModelSafe(OriginalPed)
    if not model then return end
    
    -- Ripristina giocatore
    SetPlayerModel(PlayerId(), model)
    SetPedDefaultComponentVariation(PlayerPedId())
    Wait(100)
    
    -- Resetta stato
    LocalPlayer.state:set('fantasyForm', nil, true)
    CurrentAnimal = nil
    OriginalPed = nil
    
    -- Notifica
    notifyPlayer({
        title = 'Animagus',
        description = 'Sei tornato alla forma umana',
        type = 'info'
    })
    
    -- Pulisci modello
    SetModelAsNoLongerNeeded(model)
end

-- Comandi per test
RegisterCommand('animagus', function()
    if CurrentAnimal then
        RestoreHumanForm()
    else
        TransformToAnimal()
    end
end)

RegisterCommand('animal_test', function()
    local randomIndex = math.random(1, #AnimagusAnimals)
    local animal = AnimagusAnimals[randomIndex]
    
    print('[TEST] Animale casuale:', animal)
    
    notifyPlayer({
        title = 'Test Animagus',
        description = 'Animale: ' .. animal,
        type = 'info'
    })
end)

-- Reset al respawn
AddEventHandler('playerSpawned', function()
    CurrentAnimal = nil
    OriginalPed = nil
    LocalPlayer.state:set('fantasyForm', nil, true)
end)

-- Export per altri script
exports('IsAnimagus', function()
    return CurrentAnimal ~= nil
end)

exports('GetCurrentAnimal', function()
    return CurrentAnimal
end)

exports('TransformToAnimal', TransformToAnimal)
exports('RestoreHumanForm', RestoreHumanForm)

print('[FANTASY_PEDS] Animagus client caricato!')
