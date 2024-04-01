fx_version 'cerulean'
games { 'gta5' }

shared_script 'config.lua'

client_script 'Client/client.lua'

server_scripts {
    '@vrp/lib/utils.lua',
    '@oxmysql/lib/MySQL.lua',
    'Server/server.lua'
}

ui_page 'Client/html/index.html'

files {
    'Client/html/index.html',
    'Client/html/script.js',
    'Client/html/style.css'
}