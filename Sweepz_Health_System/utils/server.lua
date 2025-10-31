Framework = nil

if Config.Framework == "qb" then
	Framework = exports['qb-core']:GetCoreObject()
elseif Config.Framework == "esx" then
	Framework = exports['es_extended']:getSharedObject()
elseif Config.Framework == "oldEsx" then
	TriggerEvent('esx:getSharedObject', function(obj) Framework = obj end)
end

function RegisterServerCallback(...)
	if Config.Framework == "qb" then
		Framework.Functions.CreateCallback(...)
	else
		Framework.RegisterServerCallback(...)
	end
end

function getXPlayer(source)
    if Config.Framework == "qb" then
        return Framework.Functions.GetPlayer(source)
    elseif Config.Framework == "esx" then
        return Framework.GetPlayerFromId(source)
    elseif Config.Framework == "oldEsx" then
        return Framework.GetPlayerFromId(source)
    end
end

function getPlayerInventoryItemListx(source)
    local itemList = {}
    if Config.Framework == "qb" then
        local xPlayer = getXPlayer(source)
        if xPlayer == nil then return end
        playerItems = xPlayer.PlayerData.items
        for k, v in pairs(playerItems) do
            for x, y in pairs(Config.DoctorItems) do 
                if v.name == y.itemName then
                    itemList[#itemList+1] = {}
                    itemList[#itemList].label = y.label
                    itemList[#itemList].description = y.description
                    itemList[#itemList].name = v.name
                    itemList[#itemList].amount = v.amount
                    itemList[#itemList].image = y.image
                end
            end
        end
    else
        local xPlayer = getXPlayer(source)
        if xPlayer == nil then return end
        for k,v in pairs(xPlayer.inventory) do
            for x, y in pairs(Config.DoctorItems) do 
                if v.name == y.itemName then
                    if v.count >= 1 then
                        itemList[#itemList+1] = {}
                        itemList[#itemList].label = x.label
                        itemList[#itemList].description = x.description
                        itemList[#itemList].name = v.name
                        itemList[#itemList].amount = v.count
                        itemList[#itemList].image = x.image
                    end
                end
            end
        end
    end
    return itemList
end

function xPlayerRemoveItem(itemName, amount, source)
    if Config.Framework == "qb" then
        local xPlayer = getXPlayer(source)
        if xPlayer == nil then return end
        xPlayer.Functions.RemoveItem(itemName, amount)
    else
        local xPlayer = getXPlayer(source)
        if xPlayer == nil then return end
        xPlayer.removeInventoryItem(itemName, amount)
    end
end

function checkPlayerItemCount(source, itemName)    
    local xPlayer = getXPlayer(source)
    if xPlayer == nil then return end

    if Config.Framework == "qb" then
        local checkItem = xPlayer.Functions.GetItemByName(itemName)
        local itemCount = checkItem ~= nil and checkItem.amount or 0
        return itemCount
    else
        local checkItem = xPlayer.getInventoryItem(itemName)
        local itemCount = checkItem ~= nil and checkItem.count or 0
        return itemCount
    end
end
    
local isBusy = false

function ExecuteSql(query, parameters, cb)
    while isBusy do
        Wait(0)
    end
    isBusy = true
    local promise = promise:new()
    exports.oxmysql:execute(query, parameters, function(data)
        promise:resolve(data)
        isBusy = false

        if cb then
            cb(data)
        end
    end)
    return Citizen.Await(promise)
end