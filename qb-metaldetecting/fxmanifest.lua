fx_version 'cerulean'
game 'gta5'

author 'plasma#2782 & EU ENVY#9641 & Stefano Luciano Corp'
description 'In-Depth & Multi-Feature QB Metal Detecting Script - Rilevamento Metallico'
repo 'https://github.com/plasmaFPS/qb-metaldetector'
version '1.0'

data_file 'DLC_ITYP_REQUEST' 'stream/gen_w_am_metaldetector.ytyp'

-- Streaming optimization
this_is_a_map 'yes'

dependencies {
    'ox_target',
    'ox_lib'
}

client_scripts {
    'client/**.lua'
}

server_script 'server/sv_main.lua'
shared_script 'config.lua'
