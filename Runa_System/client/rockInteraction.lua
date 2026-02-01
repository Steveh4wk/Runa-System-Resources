-- RUNA SYSTEM - Rock Interaction Client
-- ==============================================

local rocks = {}
local rockModel = `prop_rock_4_a` -- modello roccia

-- ==============================================
-- UTILITIES
-- ==============================================

local function loadModel(model)
    if not IsModelValid(model) then return false end
    RequestModel(model)
    local timeout = 1000
    while not HasModelLoaded(model) and timeout > 0 do
        Wait(10)
        timeout = timeout - 1
    end
    return HasModelLoaded(model)
end

local function clearExistingRocks()
    for _, rock in pairs(rocks) do
        if DoesEntityExist(rock.entity) then
            DeleteEntity(rock.entity)
        end
    end
    rocks = {}
end

-- ==============================================
-- ROCK SPAWN
-- ==============================================

local function spawnRock(coords)
    clearExistingRocks()

    if not loadModel(rockModel) then
        print("[Rockstone] ^1Failed to load rock model^7")
        return
    end

    local rock = CreateObject(rockModel, coords.x, coords.y, coords.z, true, true, true)
    SetEntityAsMissionEntity(rock, true, true)
    FreezeEntityPosition(rock, true)
    PlaceObjectOnGroundProperly(rock)

    local netId = NetworkGetNetworkIdFromEntity(rock)

    -- Salva rock
    table.insert(rocks, {entity = rock, netId = netId})

    print(("[Rockstone] ^2Rock spawned at: x=%.3f, y=%.3f, z=%.3f, netId=%d^7"):format(
        coords.x, coords.y, coords.z, netId
    ))

    -- Aggiungi target - DUA OPZIONI SULLA ROCCIA
    exports.ox_target:addLocalEntity(rock, {
        {
            name = 'rockstone_dalgona',
            label = 'Dalgona Minigame',
            icon = 'fas fa-gamepad',
            onSelect = function()
                print("[Rockstone] ^3Player started Dalgona Minigame: netId=" .. netId .. "^7")
                TriggerEvent('dalgona:startMinigame')
            end
        },
        {
            name = 'rockstone_crafting',
            label = 'Crafting Table',
            icon = 'fas fa-hammer',
            onSelect = function()
                print("[Rockstone] ^3Player opened Crafting Table: netId=" .. netId .. "^7")
                -- Apri direttamente il menu - la UI mostrerà tutte le rune
                SendNUIMessage({ type = 'openCrafting', inventory = {} })
                SetNuiFocus(true, true)
            end
        }
    })
end

-- ==============================================
-- INITIALIZATION
-- ==============================================

Citizen.CreateThread(function()
    print("[Rockstone] ^2Script loaded successfully^7")

    -- Wait login
    while not LocalPlayer.state.isLoggedIn do Wait(500) end

    print("[Rockstone] ^2Player ready, spawning rock...^7")

    local rockCoords = vector3(2081.37, 3340.61, 46.88)
    spawnRock(rockCoords)

    print("[Rockstone] ^2System fully initialized^7")
end)

-- ==============================================
-- CLEANUP ON RESOURCE STOP
-- ==============================================

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        clearExistingRocks()
        print("[Rockstone] ^2Resource stopped, cleaned up entities^7")
    end
end)

-- ==============================================
-- DEBUG COMMANDS
-- ==============================================

RegisterCommand('runa:testdalgona', function()
    print("[Rockstone] ^3Manual test: triggering dalgona win directly...^7")
    TriggerServerEvent('Runa_System:server:dalgonaWin', 'star')
end, false)

RegisterCommand('runa:testupgrade', function()
    print("[Rockstone] ^3Manual test: opening crafting table...^7")
    SendNUIMessage({ type = 'openCrafting', inventory = {} })
    SetNuiFocus(true, true)
end, false)

RegisterCommand('runa:coords', function()
    local ped = PlayerPedId()
    local c = GetEntityCoords(ped)
    print('[Rockstone] Player coords: vec3('..c.x..','..c.y..','..c.z..')')
end, false)

print("[Rockstone] ^2Rock interaction script loaded^7")
