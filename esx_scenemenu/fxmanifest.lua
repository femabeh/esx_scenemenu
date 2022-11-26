fx_version 'cerulean'

game 'gta5'

author 'femabeh#8021'

title 'esx_scenemenu'

description 'Scenemenu script'

version '1.0.0'

shared_scripts {
	'@es_extended/locale.lua',
	'@es_extended/imports.lua',
	'locales/*.lua',
	'config.lua',
}

client_scripts {
    'client.lua',
}
server_script {
    'server.lua',
}

dependencies {
	'es_extended',
	'esx_menu_default',
}
