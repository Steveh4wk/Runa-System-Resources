-- Sistema Runa - Sistema Completo per Rune Magic
-- Autore: Stefano Luciano Corp. per AstralRP
-- Developed Script Runa_System 1.0
-- Versione: 1.1.4
-- Licenza: Tutti i diritti riservati

fx_version 'cerulean'
games { 'gta5' }
author 'Stefano Luciano Corp. per AstralRP'
version '1.1.4'
lua54 'yes'

-- IMPORTANTE: Aggiungi questa risorsa al tuo server.cfg:
-- ensure Runa_System

dependencies {
    '/onesync',
    'ox_lib',
    'ox_inventory',
    'qb-core',
}

shared_scripts {
    'shared/variables.lua',
    'shared/events.lua',
    'shared/utils.lua',
    'config.lua',
    'locale.lua',
    'locales/*.lua',
}

client_scripts {
    'client/utils.lua',
    'client/framework.lua',
    'client/main.lua',
    'client/timer.lua',
    'client/countdown.lua',
    'client/skin.lua',
    'client/skinData.lua',
    'client/cutscene.lua',
    'client/freezePlayer.lua',
    'client/nui.lua',
    'client/minigame.lua',
    'client/npc.lua',
    'client/decals.lua',
    'client/rockInteraction.lua'
}

server_scripts {
    'server/utils.lua',
    'server/framework.lua',
    'server/main.lua',
    'server/stellareWatch.lua'
}

ui_page 'ui/index.html'
files {
    'ui/*.js',
    'ui/*.css',
    'ui/*.html',
    'ui/*.mp3',
    'ui/*.wav',
    'ui/*.png',
    'stream/**/*.ytd',
    'stream/**/*.dds',
    'stream/**/*.ydr',
    'audio/**/*.awc',
    'audio/**/*.dat54.rel'
}



-- Prop
file 'stream/props/dalgona_candies.ytyp'
file 'stream/props/dalgona_candy_circle.ydr'
file 'stream/props/dalgona_candy_square.ydr'
file 'stream/props/dalgona_candy_star.ydr'
file 'stream/props/dalgona_candy_triangle.ydr'
file 'stream/props/dalgona_candy_umbrella.ydr'

-- Audio
file 'audio/data/dalgona_sounds.dat54.rel'
data_file 'AUDIO_SOUNDDATA' 'audio/data/dalgona_sounds.dat'
file 'audio/audiodirectory/dalgonagame_audiobank.awc'

-- Config
file 'config.lua'

-- Items
file 'items.lua'
