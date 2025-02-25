fx_version "adamant"
lua54 'yes'
game "gta5"
author "Tony"

shared_scripts { 
    '@ox_lib/init.lua',
    '@es_extended/imports.lua'
} 

client_scripts {
    "client.lua",
    "Config.lua",
}

server_scripts {
    "server.lua",
    "Config.lua",
}