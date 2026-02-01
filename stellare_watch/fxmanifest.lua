fx_version 'cerulean'
games { 'gta5' }
author 'Stefano Luciano Corp. per AstralRP'
version '1.0.0'
description 'Orologio Stellare - Sistema Revive Automatico Standalone'
lua54 'yes'

-- Dependencies
dependencies {
    'ox_lib',
    'ox_inventory',
    'qb-core'
}

-- Client scripts
client_scripts {
    'client/stellareWatch.lua'
}

-- Server scripts
server_scripts {
    'server/stellareWatch.lua'
}

-- UI Page
ui_page 'nui/index.html'

-- NUI Files
files {
    'nui/index.html',
    'nui/style.css',
    'nui/script.js',
    'nui/sound.mp3'
}

-- Exports
exports {
    'orologiostellare:use'
}

print('[Stellare Watch] Sistema Orologio Stellare caricato')
