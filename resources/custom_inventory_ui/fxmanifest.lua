fx_version "cerulean"
game "gta5"

author "Manuel Fernández"
description "Custom Inventory UI - Modified and optimized version for learning purposes"
version "1.0.0"

ui_page "html/ui.html"

client_scripts {
    "client/main.lua",
    "client/shop.lua",
    "client/trunk.lua",
    "client/player.lua",
    "locales/en.lua",
    "config.lua"
}

server_scripts {
    "@mysql-async/lib/MySQL.lua",
    "server/main.lua",
    "locales/en.lua",
    "config.lua"
}

files {
    "html/ui.html",
    "html/css/ui.css",
    "html/js/inventory.js",
    "html/js/config.js",
    "html/img/items/*.png"
}