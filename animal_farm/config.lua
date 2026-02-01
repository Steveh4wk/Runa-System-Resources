-- config.lua
-- Stefano Luciano Corp
-- Configurazione per Animal Farm - Sistema feeding fantasy

Config = {
    -- Usa QBCore
    UseQBCore = true,

    -- Debug
    Debug = false,

    -- Distanza interazione
    InteractDistance = 3.0,

    -- Animali selvatici per feeding fantasy system
    WildAnimals = {
        {
            type = 'deer',
            label = 'Cervo Selvatico',
            model = 'a_c_deer',
            feedItem = 'carne',
            healthReward = 25,
            expReward = 15
        },
        {
            type = 'boar',
            label = 'Cinghiale Selvatico',
            model = 'a_c_boar',
            feedItem = 'carne',
            healthReward = 30,
            expReward = 20
        },
        {
            type = 'cow',
            label = 'Mucca Selvatica',
            model = 'a_c_cow',
            feedItem = 'carne',
            healthReward = 20,
            expReward = 10
        }
    },

    -- Modelli animali permessi
    AllowedModels = {
        [GetHashKey('a_c_deer')] = 'deer',
        [GetHashKey('a_c_boar')] = 'boar',
        [GetHashKey('a_c_cow')] = 'cow'
    },

    -- Spawn casuali animali selvatici
    RandomSpawn = {
        enabled = true,
        checkIntervalSec = 600, -- 10 minuti
        playerActivationRadius = 500.0,
        minDistanceBetweenAnimals = 100.0,
        maxAnimals = 15,
        spawnZones = {
            {
                center = vector3(-1500.0, 2000.0, 50.0),
                radius = 2000.0
            },
            {
                center = vector3(2000.0, 3000.0, 50.0),
                radius = 1500.0
            }
        }
    }
}

print('[Animal Farm] Config loaded - Fantasy feeding system')