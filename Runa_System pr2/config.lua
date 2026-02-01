-- Configurazione Sistema Runa
-- Autore: Stefano Luciano Corp. per AstralRP
-- Developed Script Runa_System 1.0

Config = {}

-- Lingua predefinita
Config.Locale = 'en'

-- Posizioni fisse per gli oggetti
Config.FixedPositions = {
    CraftingTable = {
        x = 2081.370117,
        y = 3343.610107,
        z = 46.860001
    },
    Rock = {
        x = 2081.370117,
        y = 3340.610107,
        z = 45.881866
    }
}

-- Configurazione Tavolo da Crafting
Config.CraftingTable = {
    Enabled = true,
    ModelHash = `prop_rock_4_c`,
    Rotation = {
        x = 0.0,
        y = 0.0,
        z = 0.0
    }
}

-- Configurazione Gioco
Config.GameArea = {
    x = 2081.370117,
    y = 3343.610107,
    z = 46.860001
}

Config.GameDuration = 180000 -- 3 minuti in millisecondi

Config.MinimumParticipants = 1

Config.Cutscene = {
    Enabled = false,
    Sequence = {
        {
            transitionTime = 1000,
            waitTime = 2000,
            message = "Preparati per il gioco Rune System!"
        }
    }
}

-- Configurazione Drop Reward
Config.RewardItem = nil -- Disabilitato, usa sistema drop casuale

-- Configurazione Accumulativa Reward
Config.AccumulativeReward = false

-- Configurazione Target System
Config.TargetSystem = 'ox_target' -- 'ox_target' o 'qb-target'

-- Configurazione Debug
Config.Debug = false

-- Configurazione Rock/Rune Stone
Config.RockProp = {
    Enabled = true,
    ModelHash = `prop_rock_4_c`,
    InteractionDistance = 3.0,
    BlipEnabled = true,
    BlipSprite = 486,
    BlipColor = 3,
    BlipScale = 0.7,
    BlipName = "Rune Stone"
}

-- Configurazione Zona Gioco (per distanza)
Config.ZoneCoords = {
    GameCenter = vector3(2081.370117, 3343.610107, 46.860001),
    GameWidth = 10.0,
    GameLength = 10.0
}

-- Configurazione Minigame
Config.MinigameComplexityCheck = 0.05
Config.ParticipantAnimations = {
    {"mini@prosecutors_desk", "wait_01_prosecutor"},
    {"anim@amb@casino@empty","beach_idle_a"},
    {"anim@mp_cp_portraits","smoke_idle_1"},
    {"anim@mp_cp_portraits","smoke_idle_2"},
    {"anim@mp_cp_portraits","smoke_idle_3"},
    {"anim@mp_cp_portraits","smoke_idle_4"},
    {"anim@mp_cp_portraits","idle_a"},
    {"anim@mp_cp_portraits","idle_b"},
    {"anim@mp_cp_portraits","idle_c"},
}
