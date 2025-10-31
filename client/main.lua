camera, currentWalkStyle = nil, nil
playerDead, disarm, bleedingNow, sirits = false, true, false, false
inspectedPlayer = {
    inspectedPlayerId = nil,
    playerPed = nil,
    health = 0,
    bodyParts = {}
}
local boneData = {
    Head = {
        boneIndex = 98, -- SKEL_Head
        bodyPart = {
            { id = 31086 },
        },
        currentHealth = 100,
        damagedBy = nil,
    },
    Body = {
        boneIndex = 0, -- SKEL_Pelvis
        bodyPart = {
            { id = 23553 },
            { id = 57597 },
            { id = 23554 },
            { id = 24816 },
            { id = 24817 },
            { id = 39317 },
            { id = 11816 }
        },
        currentHealth = 100,
        damagedBy = nil,
    },
    RightArm = {
        boneIndex = 41, -- SKEL_R_UpperArm
        bodyPart = {
            { id = 10706 },
            { id = 40269 },
            { id = 28252 },
            { id = 57005 },
            { id = 58866 },
            { id = 64016 },
            { id = 64017 },
            { id = 58867 },
            { id = 64096 },
            { id = 64097 },
            { id = 58868 },
            { id = 64112 },
            { id = 64113 },
            { id = 58869 },
            { id = 64064 },
            { id = 64065 },
            { id = 58870 },
            { id = 64080 },
            { id = 64081 }
        },
        currentHealth = 100,
        damagedBy = nil,
    },
    LeftArm = {
        boneIndex = 70, -- SKEL_L_UpperArm
        bodyPart = {
            { id = 64729 },
            { id = 45509 },
            { id = 61163 },
            { id = 18905 },
            { id = 26610 },
            { id = 4089 },
            { id = 4090 },
            { id = 26611 },
            { id = 4169 },
            { id = 4170 },
            { id = 26612 },
            { id = 4185 },
            { id = 4186 },
            { id = 26613 },
            { id = 4137 },
            { id = 4138 },
            { id = 26614 },
            { id = 4153 },
            { id = 4154 }
        },
        currentHealth = 100,
        damagedBy = nil,
    },
    RightLeg = {
        boneIndex = 3, -- SKEL_R_Thigh
        bodyPart = {
            { id = 51826 },
            { id = 36864 },
            { id = 52301 },
            { id = 20781 }
        },
        currentHealth = 100,
        damagedBy = nil,
    },
    LeftLeg = {
        boneIndex = 22, -- SKEL_L_Thigh
        bodyPart = {
            { id = 58271 },
            { id = 63931 },
            { id = 14201 },
            { id = 2108 }
        },
        currentHealth = 100,
        damagedBy = nil,
    }
}

RegisterCommand("hudayar", function()
    SetNuiFocus(true, true)
    QBCore.Functions.Notify("Hud ayarı kapatmak için ESC tuşuna basınız.", 'info')
end)

RegisterNUICallback("KapatAmk", function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

CreateThread(function()
    while true do
        SendNUIMessage({
            action = "babapro",
            bool = exports.core_inventory:isInventoryOpen() or IsPauseMenuActive()
        })
        Wait(512)
    end
end)

-- inspect the nearest player with command
RegisterCommand(Config.CheckPlayerCommand, function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local peds = GetGamePool("CPed")

    for _, peda in pairs(peds) do
        local closestPed = peda

        if IsPedAPlayer(closestPed) then
            local ped = PlayerPedId()

            if closestPed ~= ped then
                local closestPlayer = NetworkGetPlayerIndexFromPed(closestPed)
                local closestPedCoords = GetEntityCoords(closestPed)
                local pedCoords = GetEntityCoords(ped)

                if #(closestPedCoords - pedCoords) < 3.0 then
                    SendNUIMessage({
                        action = "showRevive"
                    })
                    TriggerServerEvent('Sweepz_Body_Parts:inspectPlayer', GetPlayerServerId(closestPlayer))
                    return
                end
            end
        end
    end
end)

CreateThread(function()
    RegisterKeyMapping(Config.CheckPlayerCommand, "Player Check - Sweepz_Health_System", "keyboard",
        Config.CheckPlayerKey)
end)

RegisterCommand(Config.CheckPlayerCommand2, function()
    SendNUIMessage({
        action = "hideRevive"
    })
    TriggerServerEvent('Sweepz_Body_Parts:inspectPlayer', GetPlayerServerId(PlayerId()))
end)

CreateThread(function()
    RegisterKeyMapping(Config.CheckPlayerCommand2, "Player Check - Sweepz_Health_System", "keyboard", "f4")
end)


local performanceCd = 2
Citizen.CreateThread(function()
    while true do
        performanceCd = 2
        if inspectedPlayer.playerPed ~= nil then
            performanceCd = 2
            local playerPed = inspectedPlayer.playerPed
            -- check player bones, and get them screen coords
            for boneGroup, groupData in pairs(inspectedPlayer.bodyParts) do
                -- print("INCELENIYO")
                local boneCoords = GetWorldPositionOfEntityBone(playerPed, groupData.boneIndex)
                local onScreen, screenCoordX, screenCoordY = GetScreenCoordFromWorldCoord(boneCoords.x, boneCoords.y,
                    boneCoords.z + 0.5)

                -- Send the data to the NUI
                SendNUIMessage({
                    action = "updateBodyPart",
                    bodyPart = boneGroup,
                    groupTaken = groupData.damagedBy,
                    groupHealth = groupData.currentHealth,
                    health = groupData.currentHealth,
                    onScreen = onScreen,
                    screenCoordX = screenCoordX * 100,
                    screenCoordY = screenCoordY * 100,
                })
            end
        end
        Citizen.Wait(performanceCd)
    end
end)

CreateThread(function()
    while true do
        Wait(2000)
        performanceCd = 2
        local playerPed = inspectedPlayer.playerPed
        -- check player bones, and get them screen coords
        for boneGroup, groupData in pairs(boneData) do
            -- print("INCELENIYO")
            local boneCoords = GetWorldPositionOfEntityBone(playerPed, groupData.boneIndex)
            local onScreen, screenCoordX, screenCoordY = GetScreenCoordFromWorldCoord(boneCoords.x, boneCoords.y,
                boneCoords.z + 0.5)

            -- Send the data to the NUI
            SendNUIMessage({
                action = "updateBodyPart",
                bodyPart = boneGroup,
                groupTaken = groupData.damagedBy,
                groupHealth = groupData.currentHealth,
                health = groupData.currentHealth,
                onScreen = onScreen,
                screenCoordX = screenCoordX * 100,
                screenCoordY = screenCoordY * 100,
            })
        end
    end
end)



RegisterNetEvent('Sweepz_Body_Parts:show-data', function(data, target, itemList)
    -- get target player ped and set it to the inspected player
    local playerPed = GetPlayerPed(GetPlayerFromServerId(target))
    inspectedPlayer.inspectedPlayerId = target
    inspectedPlayer.playerPed = playerPed
    inspectedPlayer.health = 100
    inspectedPlayer.bodyParts = data


    local isTargetDead = checkPedIsDead(playerPed)
    if isTargetDead then
        local targetCoords = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 2.5, 7.5)
        camera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
        PointCamAtEntity(camera, playerPed, 0.0, 0.0, 0.0, true)
        SetCamCoord(camera, targetCoords.x, targetCoords.y, targetCoords.z)
        RenderScriptCams(true, true, 1000, true, true)
        SetCamActive(camera, true)
        SetCamFov(camera, 20.0)
    else
        local targetCoords = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 10.0, 0.5)
        camera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
        PointCamAtEntity(camera, playerPed, 0.0, 0.0, 0.0, true)
        SetCamCoord(camera, targetCoords.x, targetCoords.y, targetCoords.z)
        RenderScriptCams(true, true, 1000, true, true)
        SetCamActive(camera, true)
        SetCamFov(camera, 20.0)
    end


    -- show the NUI
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "show",
        itemList = itemList,
        targetIsDead = isTargetDead,
        translate = Config.Translate
    })
end)

RegisterNetEvent('Sweepz_Body_Parts:request-data', function(target)
    local boneDataCopy = boneData
    for boneGroup, groupData in pairs(boneDataCopy) do
        for _, bone in ipairs(groupData.bodyPart) do
            bone.bodyPart = nil
        end
    end
    TriggerServerEvent('Sweepz_Body_Parts:send-data', boneDataCopy, target)
end)

function GetBoneGroupFromID(boneID)
    for groupName, groupData in pairs(boneData) do
        for _, bone in ipairs(groupData.bodyPart) do
            if bone.id == boneID then
                return groupName
            end
        end
    end
    return "Body"
end

function IsMeleeWeapon(ped)
    for _, weapon in ipairs(meleeWeapons) do
        if HasPedBeenDamagedByWeapon(ped, weapon.hash, 0) then
            return true, weapon.hash
        end
    end
    return false, nil
end

function IsFirearm(ped)
    for _, weapon in ipairs(allWeapons) do
        if HasPedBeenDamagedByWeapon(ped, weapon.hash, 0) and not IsMeleeWeapon(ped) then
            return true, weapon.hash
        end
    end
    return false, nil
end

function GetWeaponNameFromHash(weaponHash)
    for _, weapon in ipairs(allWeapons) do
        if weapon.hash == weaponHash then
            return weapon.name
        end
    end
    return Config.Translate.unknownWeapon
end

function GetMeleeWeaponNameFromHash(weaponHash)
    for _, weapon in ipairs(meleeWeapons) do
        if weapon.hash == weaponHash then
            return weapon.name
        end
    end
    return Config.Translate.unknownMeleeWeapon
end

function ApplyRandomDamage(boneGroup, damageAmount, damageType)
    if boneData[boneGroup] then
        boneData[boneGroup].currentHealth = boneData[boneGroup].currentHealth - damageAmount
        if boneData[boneGroup].currentHealth < 0 then
            boneData[boneGroup].currentHealth = 0
        end

        if not boneData[boneGroup].damagedBy then
            boneData[boneGroup].damagedBy = {}
        end

        local alreadyExists = false
        for _, existingDamageType in ipairs(boneData[boneGroup].damagedBy) do
            if existingDamageType == damageType then
                alreadyExists = true
                break
            end
        end

        if not alreadyExists then
            table.insert(boneData[boneGroup].damagedBy, damageType)
        end
    end
end

local babaproTimer = 0

CreateThread(function()
    while true do
        if IsPedFalling(cache.ped) then
            babaproTimer = babaproTimer + 1
        end
        Wait(0)
    end
end)

local isJ = false

function KontrolEtAmk()
    local babaprohash = 0
    for i, v in pairs(boneData) do
        if 50 >= v.currentHealth then
            babaprohash = babaprohash + 1
        end
    end

    if babaprohash >= 3 then
        if not isJ then
            isJ = true
            currentWalkStyle = GetPedMovementClipset(cache.ped)
            if currentWalkStyle ~= "move_m@injured" then
                RequestAnimSet("move_m@injured")
                while not HasAnimSetLoaded("move_m@injured") do
                    Wait(0)
                end
                SetPedMovementClipset(cache.ped, "move_m@injured", 1.0)
                exports["scully_emotemenu-main"]:setWalk("move_m@injured")
            end
        end
    else
        if isJ then
            isJ = false
            RequestAnimSet(currentWalkStyle)
            while not HasAnimSetLoaded(currentWalkStyle) do
                Wait(0)
            end
            SetPedMovementClipset(cache.ped, currentWalkStyle, 1.0)
            exports["scully_emotemenu-main"]:setWalk(currentWalkStyle)
        end
    end
end

local effect = false
local lastBleed = 0
CreateThread(function()
    while true do
        Wait(10000)
        if Config.PlayerRagdoll and not playerDead and not sirits then
            if boneData["RightLeg"].currentHealth < 50 or boneData["LeftLeg"].currentHealth < 50 then
                local playerPed = PlayerPedId()
                if IsPedSprinting(playerPed) then
                    SetPedToRagdoll(playerPed, 1000, 1000, 0, 0, 0, 0)
                end

                if IsPedRunning(playerPed) then
                    SetPedToRagdoll(playerPed, 500, 500, 0, 0, 0, 0)
                end
            end
        end

        if Config.Bleeding and not playerDead and not sirits then
            if boneData[Config.BleedingIfThisPartGetDamage].currentHealth < Config.BleedingStopHealth then
                bleedingNow = true
                lastBleed = GetGameTimer() + Config.BleedingTime * 1000
                if GetGameTimer() > lastBleed then
                    goto continue
                end

                SetEntityHealth(cache.ped, GetEntityHealth(cache.ped) - 1)

                if Config.BleedingScreenEffect then
                    SetFlash(0, 0, 100, 100, 100)
                    if not effect then
                        effect = true
                        StartScreenEffect('Rampage', 0, true)
                    end
                end

                for boneGroup, groupData in pairs(boneData) do
                    if boneGroup ~= "Head" then
                        ApplyRandomDamage(boneGroup, Config.BleedingDecreaseAllPartHealth, "Bleeding")
                    end
                end

                if Config.BleedingScreenEffect then
                    SetTimecycleModifier("health_bleed")
                    SetTimecycleModifierStrength(0.5)
                end
                ::continue::
            else
                bleedingNow = false
                if Config.BleedingScreenEffect then
                    SetFlash(0, 0, 0, 0, 0)
                    if effect then
                        effect = false
                        StopScreenEffect('Rampage')
                    end
                    SetTimecycleModifier("default")
                    SetTimecycleModifierStrength(0.0)
                end
            end
        else
            effect = false
        end

        if Config.DisarmPed and not playerDead and not sirits then
            if boneData["RightArm"].currentHealth < Config.DisarmPedArmHealth or boneData["LeftArm"].currentHealth < Config.DisarmPedArmHealth then
                disarm = true
            else
                disarm = false
            end
        else
            disarm = false
        end
    end
end)

RegisterNetEvent('core_inventory:client:handleWeapon', function(weaponName, weaponData, weaponInventoryamountAdded)
    if disarm then
        Wait(750)
        disarmPed(cache.ped)
    end
end)

RegisterNetEvent("Sweepz:316235325", function()
    if isJ then
        RequestAnimSet("move_m@injured")
        while not HasAnimSetLoaded("move_m@injured") do
            Wait(0)
        end
        SetPedMovementClipset(cache.ped, "move_m@injured", 1.0)
        exports["scully_emotemenu-main"]:setWalk("move_m@injured")
    end
end)

AddEventHandler('gameEventTriggered', function(eventName, eventData)
    if eventName == 'CEventNetworkEntityDamage' then
        local victim = eventData[1]
        if IsEntityAPed(victim) and IsPedAPlayer(victim) then
            local playerPed = PlayerPedId()
            if victim == playerPed then
                local hit, boneID = GetPedLastDamageBone(playerPed)
                local boneGroup = GetBoneGroupFromID(boneID)
                if boneGroup then
                    local damageAmount = nil
                    local damageType = nil
                    local isMelee, meleeWeaponHash = IsMeleeWeapon(playerPed)
                    local isFirearm, firearmWeaponHash = IsFirearm(playerPed)

                    if isMelee then
                        damageAmount = math.random(5, 15)     -- Melee attack damage
                        damageType = GetMeleeWeaponNameFromHash(meleeWeaponHash)
                    elseif isFirearm then
                        damageAmount = math.random(20, 40)                        -- Firearm attack damage
                        damageType = GetWeaponNameFromHash(firearmWeaponHash)     -- Silahın adı
                    else
                        damageAmount = math.random(1, 10)     -- Default unknown damage
                        damageType = Config.Translate.unknown
                    end

                    ApplyRandomDamage(boneGroup, damageAmount, damageType)
                end

                if Config.AllPartDamageWhenFatalDamage then
                    if GetEntityHealth(playerPed) <= 0 then
                        playerDead = true
                        ApplyRandomDamage(boneGroup,
                            math.random(Config.FatalDamageRandom.min, Config.FatalDamageRandom.max), "Fatal Damage")
                    end
                end

                ClearEntityLastDamageEntity(playerPed)
                KontrolEtAmk()
            end
        end
    end
end)

RegisterNetEvent("Sweepz_Health_System:youHealed", function(data, doctor)
    local healedPart = data.healedPart
    local usedItem = data.usedItem
    local healAmount = checkDoctorItemsHowMuchHealthRenew(usedItem.name)
    if healAmount then
        if healAmount.healGeneral > 0 then
            for boneGroup, groupData in pairs(boneData) do
                if 0 >= boneData[boneGroup].currentHealth and usedItem.name == 'surgerykit' then
                    if boneData[boneGroup].currentHealth + healAmount.healGeneral > 100 then
                        boneData[boneGroup].currentHealth = 100
                    else
                        boneData[boneGroup].currentHealth = boneData[boneGroup].currentHealth + healAmount.healGeneral
                    end
                else
                    if usedItem.name ~= 'surgerykit' then
                        if boneData[boneGroup].currentHealth + healAmount.healGeneral > 100 then
                            boneData[boneGroup].currentHealth = 100
                        else
                            boneData[boneGroup].currentHealth = boneData[boneGroup].currentHealth +
                            healAmount.healGeneral
                        end
                    end
                end
            end
        end
        if healAmount.healPart > 0 then
            if 0 >= boneData[healedPart].currentHealth then
                return
            else
                if boneData[healedPart].currentHealth + healAmount.healPart > 100 then
                    boneData[healedPart].currentHealth = 100
                else
                    boneData[healedPart].currentHealth = boneData[healedPart].currentHealth + healAmount.healPart
                end
            end
        end
    end

    if Config.FullHealthOnRevive then
        local fullHundreds = checkAllPartIsHundreds()
        if fullHundreds then
            TriggerServerEvent('Sweepz_Health_System:injuredRevived', doctor)
            playerDead = false
            bleedingNow = false
            Config.RevivePlayer()
        end
    end

    if healAmount.healAmount > 0 then
        SetEntityHealth(cache.ped, GetEntityHealth(cache.ped) + healAmount.healAmount)
    end

    KontrolEtAmk()
end)

RegisterNetEvent('Sweepz_Health_System:revivedInjured', function()
    RenderScriptCams(false, false, 0, true, true)
    DestroyCam(camera, true)
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = "hide"
    })
end)

function checkDoctorItemsHowMuchHealthRenew(itemName)
    for _, item in pairs(Config.DoctorItems) do
        if item.itemName == itemName then
            return {
                healPart = item.healPart,
                healGeneral = item.healGeneral,
                healAmount = item.healAmount
            }
        end
    end
    return nil
end

function checkAllPartIsHundreds()
    -- return true if all boneData health is 100
    for boneGroup, groupData in pairs(boneData) do
        if boneData[boneGroup].currentHealth < 100 then
            return false
        end
    end
    return true
end

-- check all part health and return true if all parts heath is more than Config.MinimumAllPartHealthForRevive
function checkAllPartHealthForRevive()
    -- inspectedPlayer
    for boneGroup, groupData in pairs(inspectedPlayer.bodyParts) do
        if inspectedPlayer.bodyParts[boneGroup].currentHealth < Config.MinimumAllPartHealthForRevive then
            return false
        end
    end
    return true
end

RegisterNetEvent('Sweepz_Health_System:revivePlayer', function()
    for boneGroup, groupData in pairs(boneData) do
        boneData[boneGroup].currentHealth = 100
        boneData[boneGroup].damagedBy = nil
        playerDead = false
        bleedingNow = false
    end
    Config.RevivePlayer()
end)

RegisterNetEvent("Sweepz_Damages:ApplyDamage", function(d, n, s)
    d = tonumber(d) - 1
    local p = NetworkGetEntityFromNetworkId(n)
    if IsEntityDead(p) then return end
    ApplyDamageToPed(p, d, true)
end)

CreateThread(function()
    while true do
        local p = cache.ped
        SetPedConfigFlag(p, 281, true)
        SetPedConfigFlag(p, 2, true)
        SetPedConfigFlag(p, 438, true)
        SetPedConfigFlag(p, 123, Config.Disable.BikeKick)
        Wait(1000)
    end
end)

CreateThread(function()
    while true do
        SetWeaponDamageModifier(tonumber(GetSelectedPedWeapon(cache.ped)), 0.01)
        Wait(1)
    end
end)

if Config.Disable.OnePunchKnockout then
    CreateThread(function()
        while Config.Disable.OnePunchKnockout do
            local p = cache.ped
            if GetPedStealthMovement(p) then
                SetPedStealthMovement(p, 0)
            end
            Wait(0)
        end
    end)
end

if Config.Disable.DriveBy then
    CreateThread(function()
        while true do
            SetPlayerCanDoDriveBy(cache.playerId, false)
            Wait(1000)
        end
    end)
end

RegisterNetEvent("Sweepz:SetHasarAmk", function(y, t, bool)
    if t == 'KAFA' then
        boneData.Head.currentHealth = tonumber(y)
    elseif t == 'GOVDE' then
        boneData.Body.currentHealth = tonumber(y)
    elseif t == 'SAGKOL' then
        boneData.RightArm.currentHealth = tonumber(y)
    elseif t == 'SOLKOL' then
        boneData.LeftArm.currentHealth = tonumber(y)
    elseif t == 'SAGBACAK' then
        boneData.RightLeg.currentHealth = tonumber(y)
    elseif t == 'SOLBACAK' then
        boneData.LeftLeg.currentHealth = tonumber(y)
    end

    for boneGroup, groupData in pairs(boneData) do
        local boneCoords = GetWorldPositionOfEntityBone(cache.ped, groupData.boneIndex)
        local onScreen, screenCoordX, screenCoordY = GetScreenCoordFromWorldCoord(boneCoords.x, boneCoords.y,
            boneCoords.z + 0.5)
        SendNUIMessage({
            action = "updateBodyPart",
            bodyPart = boneGroup,
            groupTaken = groupData.damagedBy,
            groupHealth = groupData.currentHealth,
            health = groupData.currentHealth,
            onScreen = onScreen,
            screenCoordX = screenCoordX * 100,
            screenCoordY = screenCoordY * 100,
        })
    end

    if not bool then
        local bleedRoll = math.random(1, 100)
        if bleedRoll <= Config.BleedingChance then
            if not bleedingNow then
                bleedingNow = true
            end
        end
    end

    TriggerServerEvent("Sweepz:DamageKaydet", boneData)
    KontrolEtAmk()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload')
AddEventHandler('QBCore:Client:OnPlayerUnload', function()
    TriggerServerEvent("Sweepz:KullaniciLogIn", false, boneData)
end)

CreateThread(function()
    while true do
        local sleep = 0
        if LocalPlayer.state.isLoggedIn then
            exports.spawnmanager:setAutoSpawn(false)
            TriggerServerEvent("Sweepz:KullaniciLogIn", true, boneData)
            break
        end
        Wait(sleep)
    end
end)

RegisterNetEvent("Sweepz:VeriIsle", function(data)
    local canzirh = json.decode(data.canzirh)
    boneData = json.decode(data.data)
    SetEntityHealth(cache.ped, canzirh.can)
end)

CreateThread(function()
    while true do
        Wait(1)
        SetPlayerHealthRechargeMultiplier(PlayerId(), 0.0)
    end
end)

function TedaviOl(bool)
    for boneGroup, groupData in pairs(boneData) do
        boneData[boneGroup].currentHealth = 100
        boneData[boneGroup].damagedBy = nil
        playerDead = false
        bleedingNow = false
    end
    SetFlash(0, 0, 0, 0, 0)
    StopScreenEffect('Rampage')
    SetTimecycleModifier("default")
    SetTimecycleModifierStrength(0.0)
    TriggerEvent('hospital:client:Revive')
    TriggerEvent('hospital:client:HealInjuries', 'full')
    if IsPedDeadOrDying(cache.ped) and not bool then
        local pos = GetEntityCoords(cache.ped, true)
        NetworkResurrectLocalPlayer(pos.x, pos.y, pos.z, GetEntityHeading(cache.ped), true, false)
    end
    TriggerServerEvent("Sweepz:DamageKaydet", boneData)
    for boneGroup, groupData in pairs(boneData) do
        local boneCoords = GetWorldPositionOfEntityBone(cache.ped, groupData.boneIndex)
        local onScreen, screenCoordX, screenCoordY = GetScreenCoordFromWorldCoord(boneCoords.x, boneCoords.y,
            boneCoords.z + 0.5)
        SendNUIMessage({
            action = "updateBodyPart",
            bodyPart = boneGroup,
            groupTaken = groupData.damagedBy,
            groupHealth = groupData.currentHealth,
            health = groupData.currentHealth,
            onScreen = onScreen,
            screenCoordX = screenCoordX * 100,
            screenCoordY = screenCoordY * 100,
        })
    end
    TriggerServerEvent("Sweepz_Damages:Babapro")
end

RegisterNetEvent("Sweepz:RevivePlayer", function()
    for boneGroup, groupData in pairs(boneData) do
        boneData[boneGroup].currentHealth = 100
        boneData[boneGroup].damagedBy = nil
        playerDead = false
        bleedingNow = false
    end
    SetFlash(0, 0, 0, 0, 0)
    StopScreenEffect('Rampage')
    SetTimecycleModifier("default")
    SetTimecycleModifierStrength(0.0)
    if IsPedDeadOrDying(cache.ped) and not bool then
        local pos = GetEntityCoords(cache.ped, true)
        NetworkResurrectLocalPlayer(pos.x, pos.y, pos.z, GetEntityHeading(cache.ped), true, false)
    end
    TriggerServerEvent("Sweepz:DamageKaydet", boneData)
    for boneGroup, groupData in pairs(boneData) do
        local boneCoords = GetWorldPositionOfEntityBone(cache.ped, groupData.boneIndex)
        local onScreen, screenCoordX, screenCoordY = GetScreenCoordFromWorldCoord(boneCoords.x, boneCoords.y,
            boneCoords.z + 0.5)
        SendNUIMessage({
            action = "updateBodyPart",
            bodyPart = boneGroup,
            groupTaken = groupData.damagedBy,
            groupHealth = groupData.currentHealth,
            health = groupData.currentHealth,
            onScreen = onScreen,
            screenCoordX = screenCoordX * 100,
            screenCoordY = screenCoordY * 100,
        })
    end
    TriggerServerEvent("Sweepz_Damages:Babapro")
end)

CreateThread(function()
    local model = Config.DoktorNPC.model
    for i, v in pairs(Config.DoktorNPC.coords) do
        RequestAnimDict("rcmnigel1cnmt_1c")
        while not HasAnimDictLoaded("rcmnigel1cnmt_1c") do
            Wait(0)
        end
        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(100)
        end
        local currentNpc = CreatePed(1, model, v, false, false)
        SetPedCombatAttributes(currentNpc, 46, true)
        SetPedFleeAttributes(currentNpc, 0, 0)
        SetBlockingOfNonTemporaryEvents(currentNpc, true)
        SetEntityAsMissionEntity(currentNpc, true, true)
        SetEntityInvincible(currentNpc, true)
        FreezeEntityPosition(currentNpc, true)
        TaskPlayAnim(currentNpc, "rcmnigel1cnmt_1c", "base", 8.0, -8.0, -1, 50, 0, false, false, false)
    end

    while true do
        local sleep = 1000
        local coords = GetEntityCoords(cache.ped)
        for i, v in pairs(Config.DoktorNPC.coords) do
            local distance = #(coords - vector3(v.x, v.y, v.z + 1))
            if distance < 2.5 then
                sleep = 1
                DrawText3D(v.x, v.y, v.z + 2, "[E] Tedavi Ol")
                if IsControlJustPressed(0, 38) then
                    TedaviOl()
                end
            end
        end
        Wait(sleep)
    end
end)

RegisterNetEvent("Sweepz_Damages:Band", function()
    local babapro234623 = 0
    for i, v in pairs(boneData) do
        if v.currentHealth >= 100 then
            babapro234623 = babapro234623 + 1
        end
    end

    if babapro234623 == 6 then
        if lib.progressCircle({
                duration = 5000,
                position = 'bottom',
                label = "Bandaj Kullanılıyor!",
                useWhileDead = false,
                canCancel = true,
                disable = {
                    move = false,
                    car = false,
                    combat = true,
                    mouse = false,
                },
                anim = {
                    dict = 'mp_suicide',
                    clip = 'pill',
                    flag = 49
                }
            }) then
            bleedingNow = false
            SetEntityHealth(cache.ped, GetEntityHealth(cache.ped) + 10)
            return true
        else
            sendNotify("İptal edildi.")
            TriggerServerEvent("Sweepz:Damages:BandageGiveGeriAmk")
            return false
        end
    else
        TriggerServerEvent("Sweepz:Damages:BandageGiveGeriAmk")
        sendNotify("Vücut parçalarınız tamamen iyileşmediği için bandaj kullanamazsınız.")
    end
end)

RegisterNetEvent("Sweepz_Damages:AgriKesici", function()
    if lib.progressCircle({
            duration = 5000,
            position = 'bottom',
            label = "Ağrı Kesici Kullanılıyor!",
            useWhileDead = false,
            canCancel = true,
            disable = {
                move = false,
                car = false,
                combat = true,
                mouse = false,
            },
            anim = {
                dict = 'mp_suicide',
                clip = 'pill',
                flag = 49
            }
        }) then
        sirits = true
        SetFlash(0, 0, 0, 0, 0)
        StopScreenEffect('Rampage')
        SetTimecycleModifier("default")
        SetTimecycleModifierStrength(0.0)
        CreateThread(function()
            Wait(10000)
            sirits = false
        end)
        return true
    else
        sendNotify("İptal edildi.")
        TriggerServerEvent("Sweepz:Damages:eGiveGeriAmk")
        return false
    end
end)
