fx_version 'cerulean'
game 'gta5'
author 'Bandi'
lua54 'yes'

server_script '@oxmysql/lib/MySQL.lua'
shared_script '@ox_lib/init.lua'
client_script 'client/*.lua'
server_script 'server/*.lua'
server_script 'discord.lua'
shared_script 'config.lua'

ui_page 'ui/index.html'
files {
    'ui/*.*'
}