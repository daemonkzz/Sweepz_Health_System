fx_version 'cerulean'
game 'gta5'

shared_script {
	'@ox_lib/init.lua',
	'config.lua'
}

ui_page 'html/index.html'
file 'html/**.*'

client_scripts {
	'utils/client.lua',
	'client/main.lua',
	'client/nui.lua',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'utils/server.lua',
	'server/main.lua',
}

lua54 'on'