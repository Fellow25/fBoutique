fx_version 'adamant'
game 'gta5'

---- discord : https://discord.gg/pRXCnA8

server_script '@mysql-async/lib/MySQL.lua'

client_scripts {
    "src/RMenu.lua",
    "src/menu/RageUI.lua",
    "src/menu/Menu.lua",
    "src/menu/MenuController.lua",
    "src/components/*.lua",
    "src/menu/elements/*.lua",
    "src/menu/items/*.lua",
    "src/menu/panels/*.lua",
    "src/menu/windows/*.lua",
}

---- discord : https://discord.gg/pRXCnA8

client_scripts {
    'client.lua',
    'config.lua'
}

server_scripts {
    'server.lua',
    'config.lua'
}


---- discord : https://discord.gg/pRXCnA8