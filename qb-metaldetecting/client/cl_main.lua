local QBCore = exports['qb-core']:GetCoreObject()
local lib = exports.ox_lib
local ent
local pos
local animdict
local anim
local breakchance
local overheated = false
local inZone = 0
local hasDetectorInHand = false

local boneoffsets = {
    ["w_am_metaldetector"] = {
        bone = 57005, -- Right hand bone
        offset = vector3(0.1, 0.05, 0.0),
        rotation = vector3(0.0, 0.0, 0.0), -- Dritto in avanti
    },
}

local function AttachEntity(ped, model)
    if boneoffsets[model] then
        print("Tentativo di caricare modello:", model)
        
        -- Carica il modello
        local modelHash = GetHashKey(model)
        RequestModel(modelHash)
        
        -- Attendi che il modello sia caricato
        local timeout = 0
        while not HasModelLoaded(modelHash) and timeout < 50 do
            Wait(100)
            timeout = timeout + 1
        end
        
        if HasModelLoaded(modelHash) then
            print("Modello caricato:", model)
            
            -- Rimuovi l'entità esistente se presente
            if DoesEntityExist(ent) then
                DeleteEntity(ent)
            end
            
            pos = GetEntityCoords(ped)
            ent = CreateObject(modelHash, pos.x, pos.y, pos.z, true, true, false)
            
            if DoesEntityExist(ent) then
                print("Entità creata:", ent)
                AttachEntityToEntity(ent, ped, GetPedBoneIndex(ped, boneoffsets[model].bone), 
                    boneoffsets[model].offset.x, boneoffsets[model].offset.y, boneoffsets[model].offset.z,
                    boneoffsets[model].rotation.x, boneoffsets[model].rotation.y, boneoffsets[model].rotation.z, 
                    false, false, false, false, 2, true)
                print("Modello attaccato con successo")
            else
                print("ERRORE: Impossibile creare l'entità")
            end
        else
            print("ERRORE: Modello non caricato dopo 5 secondi:", model)
        end
        
        SetModelAsNoLongerNeeded(modelHash)
    else
        print("ERRORE: Modello non trovato in boneoffsets:", model)
    end
end

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    if ent and DoesEntityExist(ent) then
        DetachEntity(ent, true, true)
        DeleteEntity(ent)
        ent = nil
    end
end)

-- Funzione per togliere il metal detector dalla mano
local function RemoveDetectorFromHand()
    if ent and DoesEntityExist(ent) then
        DetachEntity(ent, true, true)
        DeleteEntity(ent)
        ent = nil
        hasDetectorInHand = false
        QBCore.Functions.Notify('Metal detector riposto nell\'inventario', 'info')
    end
end

-- Funzione per dare il metal detector in mano
local function GiveDetectorInHand()
    if not hasDetectorInHand then
        AttachEntity(PlayerPedId(), "w_am_metaldetector")
        hasDetectorInHand = true
        QBCore.Functions.Notify('Metal detector in mano! Premi E per usare', 'success')
    end
end

-- E key detection per usare il metal detector (solo se l'ha in mano)
CreateThread(function()
    while true do
        Wait(0)
        if IsControlJustPressed(0, 38) then -- E key
            if hasDetectorInHand then
                TriggerEvent('qb-metaldetecting:startdetect')
            end
        end
    end
end)

RegisterNetEvent('qb-metaldetecting:startdetect', function(data)
    if inZone == 1 then 
        if not overheated then 
            if exports.ox_lib:progressBar({
                duration = Config.DetectTime,
                label = 'Detecting...',
                useWhileDead = false,
                canCancel = false,
                disable = {
                    move = false,
                    car = true,
                    mouse = false,
                    combat = true
                },
                anim = {
                    dict = 'mini@golfai',
                    clip = 'wood_idle_a'
                },
            }) then
                TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 10, 'metaldetector', 0.2)
                Wait(2000)
                TriggerServerEvent('qb-metaldetecting:DetectReward')
                breakchance = math.random(1,100)
                if breakchance <= Config.OverheatChance then
                    overheated = true
                    QBCore.Functions.Notify('Your metal detector has overheated! Let it cool down.', 'error', 4000)
                    Wait(Config.OverheatTime)
                    overheated = false
                    QBCore.Functions.Notify('Your metal detector has cooled down.', 'primary', 4000)
                end
            end
        else 
            QBCore.Functions.Notify('Your metal detector is still too hot!', 'error', 5000)
        end 
    else 
        QBCore.Functions.Notify('You cannot detect here. Find a suitable location.', 'error', 5000)
    end
end)

-- Evento principale per l'uso dall'inventario (toggle mano)
RegisterNetEvent('qb-metaldetecting:togglehand', function(data)
    TriggerServerEvent('qb-metaldetecting:checkdetector')
end)

-- Callback dal server per sapere se ha il metal detector
RegisterNetEvent('qb-metaldetecting:client:havedetector', function(hasDetector)
    if hasDetector then
        if hasDetectorInHand then
            RemoveDetectorFromHand()
        else
            GiveDetectorInHand()
        end
    else
        QBCore.Functions.Notify('Non hai un metal detector!', 'error')
    end
end)

CreateThread(function() 
    -- Disabilitato temporaneamente PolyZone - metal detector funzionante ovunque
    inZone = 1 -- Permette rilevamento ovunque
end)

-- Common Trade Menu --

RegisterNetEvent('qb-metaldetector:CommonTradingMenu', function(data)
    exports['qb-menu']:openMenu({
        {
            id = 1,
            header = "Common Material Trade",
            txt = ""
        },
        {
            id = 2,
            header = "Metal Trash",
            txt = "Trade 50 Metal Trash for 30 Metal Scrap!",
            params = {
                isServer = true,
                event = "qb-metaldetector:server:CommonTrade",
                args = {
                    id = 2,
                    item = 'metaltrash'
                }
            }
        },
        {
            id = 3,
            header = "Iron Trash",
            txt = "Trade 50 Iron Trash for 30 Iron",
            params = {
                isServer = true,
                event = "qb-metaldetector:server:CommonTrade",
                args = {
                    id = 3,
                    item = 'irontrash'
                }
            }
        },
        {
            id = 4,
            header = "Bullet Casings",
            txt = "Trade 50 Bullet Casings for 30 Copper!",
            params = {
                isServer = true,
                event = "qb-metaldetector:server:CommonTrade",
                args = {
                    id = 4,
                    item = 'bulletcasings'
                }
            }
        },
        {
            id = 5,
            header = "Aluminum Cans",
            txt = "Trade 50 Aluminum Cans for 30 Aluminium",
            params = {
                isServer = true,
                event = "qb-metaldetector:server:CommonTrade",
                args = {
                    id = 5,
                    item = 'aluminumcan'
                }
            }
        },
        {
            id = 6,
            header = "Steel Trash",
            txt = "Trade 50 Steel Trash for 25 Steel!",
            params = {
                isServer = true,
                event = "qb-metaldetector:server:CommonTrade",
                args = {
                    id = 6,
                    item = 'steeltrash'
                }
            }
        },
        {
            id = 7,
            header = "Broken Knives",
            txt = "Trade 5 Broken Knives for a Dagger!",
            params = {
                isServer = true,
                event = "qb-metaldetector:server:CommonTrade",
                args = {
                    id = 7,
                    item = 'brokenknife'
                }
            }
        },
        {
            id = 8,
            header = "Broken Metal Detectors",
            txt = "Trade 1 Broken Metal Detectors for $30!",
            params = {
                isServer = true,
                event = "qb-metaldetector:server:CommonTrade",
                args = {
                    id = 8,
                    item = 'brokendetector'
                }
            }
        },
        {
            id = 9,
            header = "House Keys",
            txt = "Trade 50 House Keys for 30 Copper!",
            params = {
                isServer = true,
                event = "qb-metaldetector:server:CommonTrade",
                args = {
                    id = 9,
                    item = 'housekeys'
                }
            }
        },
        {
        id = 10,
        header = "Broken Phones",
        txt = "Trade 1 Broken Phones for $25!",
        params = {
            isServer = true,
            event = "qb-metaldetector:server:CommonTrade",
            args = {
                id = 10,
                item = 'brokenphone'
                }
            }
        },
    })
end)

-- Rare Trade Menu -- 

RegisterNetEvent('qb-metaldetector:RareTradingMenu', function(data)
    exports['qb-menu']:openMenu({
        {
            id = 1,
            header = "Rare Material Trade",
            txt = ""
        },
        {
            id = 2,
            header = "Burried Treasure",
            txt = "Trade 1 Burried Treasure for $10,000!",
            params = {
                isServer = true,
                event = "qb-metaldetector:server:RareTrade",
                args = {
                    id = 2,
                    item = 'burriedtreasure'
                }
            }
        },
        {
            id = 3,
            header = "Treasure Key",
            txt = "Trade 1 Treasure Key for $1,500!",
            params = {
                isServer = true,
                event = "qb-metaldetector:server:RareTrade",
                args = {
                    id = 3,
                    item = 'treasurekey'
                }
            }
        },
        {
            id = 4,
            header = "Antique Coin",
            txt = "Trade 1 Antique Coin for $500!",
            params = {
                isServer = true,
                event = "qb-metaldetector:server:RareTrade",
                args = {
                    id = 4,
                    item = 'antiquecoin'
                }
            }
        },
        {
            id = 5,
            header = "Golden Nuggets",
            txt = "Trade 1 Golden Nuggets $200!",
            params = {
                isServer = true,
                event = "qb-metaldetector:server:RareTrade",
                args = {
                    id = 5,
                    item = 'goldennugget'
                }
            }
        },
        {
            id = 6,
            header = "Gold Coin",
            txt = "Trade 1 Gold Coin for $300!",
            params = {
                isServer = true,
                event = "qb-metaldetector:server:RareTrade",
                args = {
                    id = 6,
                    item = 'goldcoin'
                }
            }
        },
        {
            id = 7,
            header = "Ancient Coin",
            txt = "Trade 1 Ancient Coin for $1000!",
            params = {
                isServer = true,
                event = "qb-metaldetector:server:RareTrade",
                args = {
                    id = 7,
                    item = 'ancientcoin'
                }
            }
        },
        {
            id = 8,
            header = "WW2 Relic",
            txt = "Trade 1 WW2 Relic for $800!",
            params = {
                isServer = true,
                event = "qb-metaldetector:server:RareTrade",
                args = {
                    id = 8,
                    item = 'ww2relic'
                }
            }
        },
        {
            id = 9,
            header = "Broken Gameboys",
            txt = "Trade 10 Broken Gameboys for 1 working Gameboy!",
            params = {
                isServer = true,
                event = "qb-metaldetector:server:RareTrade",
                args = {
                    id = 9,
                    item = 'brokengameboy'
                }
            }
        },
        {
            id = 10,
            header = "Pocket Watch",
            txt = "Trade 1 Pocket watch for $150!",
            params = {
                isServer = true,
                event = "qb-metaldetector:server:RareTrade",
                args = {
                    id = 10,
                    item = 'pocketwatch'
                }
            }
        },
    })
end)
