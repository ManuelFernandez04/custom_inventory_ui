local Keys = {
    ["ESC"]=322,["F1"]=288,["F2"]=289,["F3"]=170,["F5"]=166,["F6"]=167,["F7"]=168,["F8"]=169,["F9"]=56,["F10"]=57,
    ["~"]=243,["1"]=157,["2"]=158,["3"]=160,["4"]=164,["5"]=165,["6"]=159,["7"]=161,["8"]=162,["9"]=163,
    ["-"]=84,["="]=83,["BACKSPACE"]=177,["TAB"]=37,["Q"]=44,["W"]=32,["E"]=38,["R"]=45,["T"]=245,["Y"]=246,["U"]=303,
    ["P"]=199,["["]=39,["]"]=40,["ENTER"]=18,["CAPS"]=137,["A"]=34,["S"]=8,["D"]=9,["F"]=23,["G"]=47,["H"]=74,
    ["K"]=311,["L"]=182,["LEFTSHIFT"]=21,["Z"]=20,["X"]=73,["C"]=26,["V"]=0,["B"]=29,["N"]=249,["M"]=244,[","]=82,
    ["."]=81,["LEFTCTRL"]=36,["LEFTALT"]=19,["SPACE"]=22,["RIGHTCTRL"]=70,["HOME"]=213,["PAGEUP"]=10,["PAGEDOWN"]=11,
    ["DELETE"]=178,["LEFT"]=174,["RIGHT"]=175,["TOP"]=27,["DOWN"]=173,["NENTER"]=201,["N4"]=108,["N5"]=60,["N6"]=107,
    ["N+"]=96,["N-"]=97,["N7"]=117,["N8"]=61,["N9"]=118
}

local ESX = ESX or (exports['es_extended'] and exports['es_extended']:getSharedObject()) or nil
local isInInventory = false
local display = false
local RESOURCE = GetCurrentResourceName()
local currentShopType = nil

-- Fallback para obtener ESX si tu versión usa el viejo evento
CreateThread(function()
    while not ESX do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Wait(100)
    end
end)

-- Abrir con tecla configurada
CreateThread(function()
    while true do
        Wait(0)
        if IsControlJustReleased(0, Config.OpenControl) and IsInputDisabled(0) then
            ToggleInventory(true, 'normal')
        end
    end
end)

-- ===================
-- Apertura/Cierre UI
-- ===================
function ToggleInventory(state, invType)
    display = state
    isInInventory = state
    currentShopType = nil

    SetNuiFocus(state, state)
    SendNUIMessage({ action = state and 'display' or 'hide', type = invType or 'normal' })

    if state then
        ESX.TriggerServerCallback('custom_inventory_ui:getPlayerInventory', function(data)
            if data and data.items then
                SendNUIMessage({ action = 'setItems', itemList = data.items })
            end
        end)
    end
end

-- ==========
--  SHOPS
-- ==========
-- /shop <Regular|RobsLiquor|YouTool|WeaponShop>
RegisterCommand('shop', function(_, args)
    OpenShop(args[1] or 'Regular')
end)

function OpenShop(shopType)
    currentShopType = shopType
    isInInventory = true
    display = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'display', type = 'shop' })

    ESX.TriggerServerCallback('custom_inventory_ui:getPlayerInventory', function(data)
        if data and data.items then
            SendNUIMessage({ action = 'setItems', itemList = data.items })
        end
    end)

    ESX.TriggerServerCallback('custom_inventory_ui:getShopItems', function(list)
        SendNUIMessage({ action = 'setShopInventoryItems', itemList = list })
        SendNUIMessage({ action = 'setInfoText', text = ('<b>Shop:</b> %s'):format(shopType) })
    end, shopType)
end

-- ================
-- NUI Callbacks
-- ================
RegisterNUICallback('NUIFocusOff', function(_, cb)
    ToggleInventory(false)
    cb('ok')
end)

RegisterNUICallback('GetNearPlayers', function(data, cb)
    local elems = {}
    local myPed = PlayerPedId()
    local myCoords = GetEntityCoords(myPed)
    local radius = 3.0

    for _, pid in ipairs(GetActivePlayers()) do
        local sid = GetPlayerServerId(pid)
        if sid ~= GetPlayerServerId(PlayerId()) then
            local ped = GetPlayerPed(pid)
            if #(GetEntityCoords(ped) - myCoords) <= radius then
                elems[#elems+1] = { label = GetPlayerName(pid) or ('Player '..sid), player = sid }
            end
        end
    end

    SendNUIMessage({
        action = 'nearPlayers',
        foundAny = (#elems > 0),
        players = elems,
        item = data and data.item or nil
    })
    cb('ok')
end)

RegisterNUICallback('UseItem', function(data, cb)
    if not data or not data.item then cb('err'); return end
    TriggerServerEvent('custom_inventory_ui:useItem', data.item)
    -- Si querés cerrar al usar algún ítem, controlalo desde server o agregá lista acá
    Wait(250)
    RefreshInventory()
    cb('ok')
end)

RegisterNUICallback('DropItem', function(data, cb)
    if not data or not data.item or not data.number then cb('err'); return end
    if IsPedSittingInAnyVehicle(PlayerPedId()) then cb('ok'); return end
    TriggerServerEvent('custom_inventory_ui:dropItem', data.item, tonumber(data.number) or 1)
    Wait(250)
    RefreshInventory()
    cb('ok')
end)

RegisterNUICallback('GiveItem', function(data, cb)
    if not data or not data.item or not data.player then cb('err'); return end
    local count = tonumber(data.number) or 1

    if data.item.type == 'item_weapon' then
        count = GetAmmoInPedWeapon(PlayerPedId(), GetHashKey(data.item.name))
    end

    TriggerServerEvent('custom_inventory_ui:giveItem', data.player, data.item, count)
    Wait(250)
    RefreshInventory()
    cb('ok')
end)

-- Compra desde shop (drag second->player en modo 'shop')
RegisterNUICallback('TakeFromShop', function(data, cb)
    if not data or not data.item then cb('err'); return end
    local count = tonumber(data.number) or 1
    TriggerServerEvent('custom_inventory_ui:buyFromShop', data.item, count, currentShopType or 'Regular')
    Wait(250)
    RefreshInventory()
    cb('ok')
end)

-- ===================
--  Utilidades
-- ===================
function RefreshInventory()
    ESX.TriggerServerCallback('custom_inventory_ui:getPlayerInventory', function(data)
        if data and data.items then
            SendNUIMessage({ action = 'setItems', itemList = data.items })
        end
    end)
end

-- Eventos públicos por si otro script quiere abrir/cerrar
RegisterNetEvent('custom_inventory_ui:open', function(invType)
    ToggleInventory(true, invType or 'normal')
end)

RegisterNetEvent('custom_inventory_ui:close', function()
    ToggleInventory(false)
end)

-- Bloqueo de controles mientras la UI está abierta
CreateThread(function()
    while true do
        Wait(1)
        if isInInventory then
            DisableControlAction(0, 1, true)   -- Pan
            DisableControlAction(0, 2, true)   -- Tilt
            DisableControlAction(0, 24, true)  -- Attack
            DisableControlAction(0, 257, true) -- Attack 2
            DisableControlAction(0, 25, true)  -- Aim
            DisableControlAction(0, 263, true) -- Melee 1

            DisableControlAction(0, Keys["W"], true)
            DisableControlAction(0, Keys["A"], true)
            DisableControlAction(0, 31, true)  -- S
            DisableControlAction(0, 30, true)  -- D

            DisableControlAction(0, Keys["R"], true)
            DisableControlAction(0, Keys["SPACE"], true)
            DisableControlAction(0, Keys["Q"], true)
            DisableControlAction(0, Keys["TAB"], true)
            DisableControlAction(0, Keys["F"], true)

            DisableControlAction(0, Keys["F1"], true)
            DisableControlAction(0, Keys["F2"], true)
            DisableControlAction(0, Keys["F3"], true)
            DisableControlAction(0, Keys["F6"], true)

            DisableControlAction(0, Keys["V"], true)
            DisableControlAction(0, Keys["C"], true)
            DisableControlAction(0, Keys["X"], true)
            DisableControlAction(2, Keys["P"], true)

            DisableControlAction(0, 59, true)
            DisableControlAction(0, 71, true)
            DisableControlAction(0, 72, true)

            DisableControlAction(2, Keys["LEFTCTRL"], true)

            DisableControlAction(0, 47, true)
            DisableControlAction(0, 264, true)
            DisableControlAction(0, 257, true)
            DisableControlAction(0, 140, true)
            DisableControlAction(0, 141, true)
            DisableControlAction(0, 142, true)
            DisableControlAction(0, 143, true)
            DisableControlAction(0, 75, true)
            DisableControlAction(27, 75, true)
        end
    end
end)
