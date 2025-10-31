local cubicore = exports['qb-core']:GetCoreObject()
local hasarpuan, srcs = {}, {}
local Components = {
    [20] = 'KAFA',
    [19] = 'KAFA',
    [18] = 'SOLKOL',
    [17] = 'SOLKOL',
    [16] = 'SOLKOL',
    [15] = 'GOVDE',
    [14] = 'SAGKOL',
    [13] = 'SAGKOL',
    [12] = 'SAGKOL',
    [11] = 'GOVDE',
    [10] = 'GOVDE',
    [9] = 'GOVDE',
    [8] = 'GOVDE',
    [7] = 'GOVDE',
    [6] = 'SOLBACAK',
    [5] = 'SOLBACAK',
    [4] = 'SOLBACAK',
    [3] = 'SAGBACAK',
    [2] = 'SAGBACAK',
    [1] = 'SAGBACAK',
    [0] = 'GOVDE'
}

local hasarBolgeleri = {
    KAFA = { "20", "19" },
    SAGKOL = { "12", "13", "14" },
    SOLKOL = { "16", "17", "18" },
    GOVDE = { "0", "7", "8", "9", "10", "11", "15" },
    SAGBACAK = { "1", "2", "3" },
    SOLBACAK = { "4", "5", "6" }
}

RegisterNetEvent('Sweepz_Body_Parts:inspectPlayer', function(data)
    local src = source
    TriggerClientEvent('Sweepz_Body_Parts:request-data', data, src)
end)

RegisterNetEvent('Sweepz_Body_Parts:send-data', function(data, target)
    local src = source
    -- get item list from target inventory as config framework
    local itemList = getPlayerInventoryItemListx(target)
    TriggerClientEvent('Sweepz_Body_Parts:show-data', target, data, src, itemList)
end)

RegisterServerCallback('Sweepz_Health_System:usedItem', function(source, cb, data, healedTarget)
    local source = source
    local usedItemData = data.usedItem

    local checkItemCount = checkPlayerItemCount(source, usedItemData.name) -- check if player has the item in inventory
    if checkItemCount > 0 then
        xPlayerRemoveItem(usedItemData.name, 1, source)
        TriggerClientEvent('Sweepz_Health_System:youHealed', healedTarget, data, source)
        cb({success = true, returnData = data})
    else
        cb({success = false})
    end
end)

RegisterNetEvent("Sweepz_Damages:AddItem123123", function(item31)
    local s = source
    local p = cubicore.Functions.GetPlayer(s)
    p.Functions.AddItem(item31, 1)
end)

RegisterNetEvent('Sweepz_Health_System:injuredRevived', function(data)
    local src = source
    TriggerClientEvent('Sweepz_Health_System:revivedInjured', tonumber(data), src)
end)

-- revive player
RegisterServerCallback('Sweepz_Health_System:revivePlayer', function(source, cb, target)
    local source = source
    local neededReviveItems = Config.ReviveItems -- table of items needed to revive player
    if Config.ReviveItemNeeded then 
        local bestItemForRevive = nil -- best reviveChance from neededReviveItems
        for k, v in pairs(neededReviveItems) do
            local checkItemCount = checkPlayerItemCount(source, v.name)
            if checkItemCount > 0 then
                if bestItemForRevive == nil then
                    bestItemForRevive = v
                else
                    if v.reviveChance > bestItemForRevive.reviveChance then
                        bestItemForRevive = v
                    end
                end
            end
        end

        if bestItemForRevive ~= nil then
            xPlayerRemoveItem(bestItemForRevive.name, 1, source)
            print( 'Revive chance: ' .. bestItemForRevive.reviveChance)
            local reviveChance = math.random(1, 100)
            if reviveChance <= bestItemForRevive.reviveChance then
	            local Player = cubicore.Functions.GetPlayer(target)
                if Player.PlayerData.metadata['isdead'] then
                    cb({success = false, errorText = Config.Translate.reviveFailed})
                else
                    TriggerClientEvent('Sweepz_Health_System:revivePlayer', target)
                    cb({success = true, itemName = bestItemForRevive.name})
                end
            else
                cb({success = false, errorText = Config.Translate.reviveFailed})
            end
        else
            cb({success = false, errorText = Config.Translate.youDontHaveRequiredItem})
        end
    else
        TriggerClientEvent('Sweepz_Health_System:revivePlayer', target)
        cb({success = true})
    end
end)

local function UpdateClientDamage(playerId, bool)
    for bolge, indexler in pairs(hasarBolgeleri) do
        local toplam = 0
        for _, i in ipairs(indexler) do
            toplam = toplam + (hasarpuan[playerId .. ""][i] or 0)
        end
        if toplam > 50 then toplam = 50 end
        local percent = 100 - ((toplam / 50) * 100)
        TriggerClientEvent("Sweepz:SetHasarAmk", tonumber(playerId), percent, bolge, bool)
    end
end

AddEventHandler("weaponDamageEvent", function(sender, data)
    if not sender or tonumber(sender) == -1 then return end
    if not (data and data.weaponType and data.hitGlobalId and data.hitComponent) then return end
    local weaponData = Config.Weapon[data.weaponType]
    local meleeData = Config.SingelDamage[data.weaponType]
    local ped = NetworkGetEntityFromNetworkId(data.hitGlobalId)
    if not ped or not DoesEntityExist(ped) then return end
    local playerId = NetworkGetEntityOwner(ped)
    if not playerId or tonumber(playerId) == -1 or GetEntityType(ped) ~= 1 then return end
    if weaponData then
        local boneLabel = Components[tonumber(data.hitComponent)] or "KAFA"
        local damage = weaponData[boneLabel] or weaponData["KAFA"]

        hasarpuan[playerId .. ""] = hasarpuan[playerId .. ""] or {} hasarpuan[playerId .. ""][data.hitComponent .. ""] = (hasarpuan[playerId .. ""][data.hitComponent .. ""] or 0) + damage

        TriggerClientEvent("Sweepz_Damages:ApplyDamage", tonumber(playerId), damage, data.hitGlobalId, sender)
        UpdateClientDamage(playerId)
    elseif meleeData then
        hasarpuan[playerId .. ""] = hasarpuan[playerId .. ""] or {} hasarpuan[playerId .. ""][data.hitComponent .. ""] = (hasarpuan[playerId .. ""][data.hitComponent .. ""] or 0) + meleeData
        TriggerClientEvent("Sweepz_Damages:ApplyDamage", tonumber(playerId), meleeData, data.hitGlobalId, sender)
        UpdateClientDamage(playerId)
    end
end)

RegisterNetEvent("Sweepz:DamageKaydet", function(data)
    local src = source
    local ped = GetPlayerPed(src)
    local can = GetEntityHealth(ped)
    local zirh = GetPedArmour(ped)
    local cidid = srcs[src .. ""]
    if cidid then
        local result = ExecuteSql("SELECT * FROM damages WHERE identy = ?", { cidid })
        if next(result) then
            ExecuteSql("UPDATE damages SET data = ?, canzirh = ? WHERE identy = ?",
                { json.encode(data), json.encode({ can = can, zirh = zirh }), cidid })
        else
            ExecuteSql(
                "INSERT INTO damages (identy, data, canzirh) VALUES (?, ?, ?)",
                { cidid, json.encode(data), json.encode({ can = can, zirh = zirh }) })
        end
    end
end)

AddEventHandler('playerDropped', function()
    local src = source
    local ped = GetPlayerPed(src)
    local can = GetEntityHealth(ped)
    local zirh = GetPedArmour(ped)
    local cidid = srcs[src .. ""]
    if cidid then
        local result = ExecuteSql("SELECT * FROM damages WHERE identy = ?", { cidid })
        if next(result) then
            ExecuteSql("UPDATE damages SET canzirh = ? WHERE identy = ?",
                { json.encode({ can = can, zirh = zirh }), cidid })
        else
            ExecuteSql(
                "INSERT INTO damages (identy, data, canzirh) VALUES (?, ?, ?)",
                { cidid, json.encode({}), json.encode({ can = can, zirh = zirh }) })
        end
        srcs[src .. ""] = nil
    end
end)

RegisterNetEvent("Sweepz:KullaniciLogIn", function(bool, data)
    local src = source
    local ped = GetPlayerPed(src)
    local can = GetEntityHealth(ped)
    local zirh = GetPedArmour(ped)
    if bool then
        local Player = cubicore.Functions.GetPlayer(src)
        if Player then
            local cidid = Player.PlayerData.citizenid
            if cidid then
                srcs[src .. ""] = cidid
                local result = ExecuteSql("SELECT * FROM damages WHERE identy = ?", { cidid })
                if not next(result) then
                    ExecuteSql(
                        "INSERT INTO damages (identy, data, canzirh) VALUES (?, ?, ?)",
                        { cidid, json.encode(data), json.encode({ can = can, zirh = zirh }) })
                end
                result = ExecuteSql("SELECT * FROM damages WHERE identy = ?", { cidid })
                if next(result) then
                    TriggerClientEvent("Sweepz:VeriIsle", src, result[1])
                    SetPedArmour(ped, json.decode(result[1].canzirh).zirh)
                end
            end
        end
    else
        local cidid = srcs[src .. ""]
        if cidid then
            local result = ExecuteSql("SELECT * FROM damages WHERE identy = ?", { cidid })
            if next(result) then
                ExecuteSql("UPDATE damages SET data = ?, canzirh = ? WHERE identy = ?",
                    { json.encode(data), json.encode({ can = can, zirh = zirh }), cidid })
            else
                ExecuteSql(
                    "INSERT INTO damages (identy, data, canzirh) VALUES (?, ?, ?)",
                    { cidid, json.encode(data), json.encode({ can = can, zirh = zirh }) })
            end
        end
    end
end)

RegisterNetEvent("Sweepz_Damages:Babapro", function()
    hasarpuan[source .. ""] = {}
end)

RegisterNetEvent("Sweepz_Damages:GazEfekt", function(damage)
    local src = source
    damage = damage * 2
    if not hasarpuan[src .. ""] then
        hasarpuan[src .. ""] = {}
    end

    hasarpuan[src .. ""]["20"] = (hasarpuan[src .. ""]["20"] or 0) + damage
    UpdateClientDamage(src)
end)

RegisterNetEvent("Sweepz_Damages:ZombiVurdu", function(damage)
    local src = source
    damage = damage * 3
    if not hasarpuan[src .. ""] then
        hasarpuan[src .. ""] = {}
    end

    local random = math.random(0, 20)

    hasarpuan[src .. ""][random..""] = (hasarpuan[src .. ""][random..""] or 0) + damage
    UpdateClientDamage(src)
end)

cubicore.Functions.CreateUseableItem("bandage", function(source, item)
    local s = source
    local p = cubicore.Functions.GetPlayer(s)
    if p.Functions.RemoveItem("bandage", 1) then
        TriggerClientEvent("Sweepz_Damages:Band", s)
    end
end)

cubicore.Functions.CreateUseableItem("painkillers", function(source, item)
    local s = source
    local p = cubicore.Functions.GetPlayer(s)
    if p.Functions.RemoveItem("painkillers", 1) then
        TriggerClientEvent("Sweepz_Damages:AgriKesici", s)
    end
end)

RegisterNetEvent("Sweepz:Damages:BandageGiveGeriAmk", function()
    local s = source
    local p = cubicore.Functions.GetPlayer(s)
    p.Functions.AddItem("bandage", 1)
end)

RegisterNetEvent("Sweepz:Damages:eGiveGeriAmk", function()
    local s = source
    local p = cubicore.Functions.GetPlayer(s)
    p.Functions.AddItem("painkillers", 1)
end)