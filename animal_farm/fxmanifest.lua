fx_version 'cerulean'
lua54 'yes'
game 'gta5'

name 'animal_farm'
author 'Stefano Luciano Corp'
version '1.0.0'
description 'Animal Farm: Sistema feeding per creature fantasy'

dependencies {
    'ox_inventory',
    'ox_target',
    'ox_lib',
    'fantasy_peds'
}

shared_script 'config.lua'

client_scripts {
    'client/main.lua',
    'client/wild_animal_spawner.lua'
}

server_script 'server/main.lua'

print('[Animal Farm] Manifest loaded')