-- main.lua (SERVER) - custom_inventory_ui
-- Inventario + Shops con shopType recibido desde el cliente

local ESX = ESX or exports['es_extended']:getSharedObject()

-- Si tu core ESX no expone exports, habilitá también este fallback:
if not ESX then
    AddEventHandler('esx:getSharedObject', function(obj) ESX = obj end)
end

-- =========================================================
--  Helpers de Items (lee info de la tabla items)
-- =========================================================
local function BuildItemsInfo()
    local map = {}

    -- mysql-async (por defecto):
    local rows = MySQL.Sync.fetchAll('SELECT name, label, `limit`, rare, can_remove FROM items')

    -- oxmysql (alternativa):
    -- local rows = exports.oxmysql:query_sync('SELECT name, label, `limit`, rare, can_remove FROM items', {})

    for i = 1, #rows do
        local r = rows[i]
        map[r.name] = {
            name = r.name,
            label = r.label,
            limit = r.limit or -1,
            rare = r.rare,
            can_remove = r.can_remove
        }
    end
    return map
end

-- Construye la lista de un shop según Config.Shops y la info de DB
local function BuildShopList(shopType)
    local list = {}
    local info = BuildItemsInfo()

    -- Normalizamos el tipo
    shopType = tostring(shopType or 'Regular')

    if shopType == 'WeaponShop' then
        -- armas
        for _, w in ipairs(Config.Shops.WeaponShop.Weapons or {}) do
            local label = (info[w.name] and info[w.name].label) or w.name
            list[#list+1] = {
                type  = 'item_weapon',
                name  = w.name,
                label = label,
                limit = 1,
                ammo  = w.ammo or 0,
                price = w.price or 0,
                count = 99999999
            }
        end
        -- munición
        for _, a in ipairs(Config.Shops.WeaponShop.Ammo or {}) do
            local i = info[a.name] or {}
            list[#list+1] = {
                type       = 'item_ammo',
                name       = a.name,
                label      = i.label or a.name,
                limit      = 1,
                weaponhash = a.weaponhash,
                ammo       = a.ammo or 0,
                price      = a.price or 0,
                count      = 99999999
            }
        end
        -- items varios del armero
        for _, it in ipairs(Config.Shops.WeaponShop.Items or {}) do
            local i = info[it.name] or {}
            list[#list+1] = {
                type  = 'item_standard',
                name  = it.name,
                label = i.label or it.name,
                limit = i.limit or -1,
                price = it.price or 0,
                count = 99999999
            }
        end

    else
        -- Shops simples: Regular / RobsLiquor / YouTool / etc.
        local bucket = Config.Shops[shopType]
        if bucket and bucket.Items then
            for _, it in ipairs(bucket.Items) do
                local i = info[it.name] or {}
                list[#list+1] = {
                    type  = 'item_standard',
                    name  = it.name,
                    label = i.label or it.name,
                    limit = i.limit or -1,
                    price = it.price or 0,
                    count = 99999999
                }
            end
        end
    end

    return list
end

-- =========================================================
--  INVENTARIO
-- =========================================================
ESX.RegisterServerCallback('custom_inventory_ui:getPlayerInventory', function(src, cb)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then cb({ items = {} }) return end

    local items = {}

    -- Items estándar
    for _, v in ipairs(xPlayer.getInventory() or {}) do
        if (v.count or 0) > 0 then
            items[#items+1] = {
                name      = v.name,
                label     = v.label,
                count     = v.count,
                limit     = v.limit or -1,
                type      = 'item_standard',
                usable    = true,
                canRemove = true
            }
        end
    end

    -- Cash como ítem visual
    if Config.ShowCashAsItem then
        local cash = xPlayer.getMoney()
        if cash > 0 then
            items[#items+1] = {
                name='money', label='Cash', count=cash, limit=-1,
                type='item_money', usable=false, canRemove=true
            }
        end
    end

    -- Black money como ítem visual
    if Config.ShowBlackMoneyAsItem then
        local acc = xPlayer.getAccount('black_money')
        if acc and acc.money and acc.money > 0 then
            items[#items+1] = {
                name='black_money', label='Illicit Funds', count=acc.money, limit=-1,
                type='item_account', usable=false, canRemove=true
            }
        end
    end

    -- Armas como ítems visuales
    if Config.ShowWeaponsAsItem then
        for _, w in ipairs(xPlayer.getLoadout() or {}) do
            items[#items+1] = {
                name=w.name, label=w.label or w.name, count=w.ammo or 0, limit=1,
                type='item_weapon', usable=false, canRemove=true
            }
        end
    end

    cb({ items = items })
end)

-- Usar ítem (demo / integra con tu sistema de items usables si lo tenés)
RegisterNetEvent('custom_inventory_ui:useItem', function(item)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer or not item or not item.name then return end
    print(('[custom_inventory_ui] %s (%d) used item %s'):format(GetPlayerName(src), src, item.name))
    -- Ej: TriggerEvent('my_items:use', src, item.name)
end)

-- Dropear ítem (simple: solo remover del inventario)
RegisterNetEvent('custom_inventory_ui:dropItem', function(item, count)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer or not item or not item.name then return end

    local qty = tonumber(count) or 1
    if qty < 1 then return end

    local invItem = xPlayer.getInventoryItem(item.name)
    if invItem and invItem.count >= qty then
        xPlayer.removeInventoryItem(item.name, qty)
        -- Si querés crear pickup en el mundo, hacelo acá.
    end
end)

-- Dar ítem a otro jugador
RegisterNetEvent('custom_inventory_ui:giveItem', function(targetId, item, count)
    local src = source
    local tgt = tonumber(targetId)
    if not tgt or not item or not item.name then return end

    local qty = tonumber(count) or 1
    if qty < 1 then return end

    local xPlayer = ESX.GetPlayerFromId(src)
    local xTarget = ESX.GetPlayerFromId(tgt)
    if not xPlayer or not xTarget then return end

    local invItem = xPlayer.getInventoryItem(item.name)
    if not invItem or invItem.count < qty then return end

    if xTarget.canCarryItem and not xTarget.canCarryItem(item.name, qty) then
        return
    end

    xPlayer.removeInventoryItem(item.name, qty)
    xTarget.addInventoryItem(item.name, qty)
end)

-- =========================================================
--  SHOPS
-- =========================================================
ESX.RegisterServerCallback('custom_inventory_ui:getShopItems', function(src, cb, shopType)
    cb(BuildShopList(shopType or 'Regular'))
end)

-- Compra desde la UI del shop (recibe shopType)
RegisterNetEvent('custom_inventory_ui:buyFromShop', function(item, count, shopType)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer or not item or not item.name then return end

    local qty = tonumber(count) or 1
    if qty < 1 then return end

    -- Construimos la lista exacta del shop que abrió el cliente
    local shopList = BuildShopList(shopType or 'Regular')

    -- Buscamos el ítem en esa lista
    local found
    for _, v in ipairs(shopList) do
        if v.name == item.name and (item.type == nil or item.type == v.type) then
            found = v
            break
        end
    end
    if not found then return end

    if found.type == 'item_standard' then
        local total = (found.price or 0) * qty
        if xPlayer.getMoney() >= total then
            if xPlayer.canCarryItem and not xPlayer.canCarryItem(found.name, qty) then
                return
            end
            xPlayer.removeMoney(total)
            xPlayer.addInventoryItem(found.name, qty)
        end

    elseif found.type == 'item_weapon' then
        local total = (found.price or 0) -- 1 arma por compra
        if not xPlayer.hasWeapon(found.name) and xPlayer.getMoney() >= total then
            xPlayer.removeMoney(total)
            xPlayer.addWeapon(found.name, found.ammo or 0)
        end

    elseif found.type == 'item_ammo' then
        local total = (found.price or 0) * qty
        if xPlayer.getMoney() >= total then
            xPlayer.removeMoney(total)
            -- Para sumar balas realmente al arma del jugador,
            -- implementá un evento cliente que añada balas:
            -- TriggerClientEvent('custom_inventory_ui:addAmmo', src, found.weaponhash, (found.ammo or 0) * qty)
        end
    end
end)

-- Stubs opcionales si algún día usás stash/propiedad/baúl
RegisterNetEvent('custom_inventory_ui:stash:put',  function(_) end)
RegisterNetEvent('custom_inventory_ui:stash:take', function(_) end)
