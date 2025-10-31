
-- CLose Menu NUI
RegisterNUICallback('closeMenu', function(data, cb)
    SetCamActive(camera, false)
    RenderScriptCams(false, false, 0, true, true)
    DestroyCam(camera, false)
    camera = nil
    inspecting = false
    inspectedPlayer.playerPed = nil
    SetNuiFocus(false, false)
    cb('ok')
end)

-- Heal Player
RegisterNUICallback('healBodyPart', function(data, cb)
    TriggerServerCallback('Sweepz_Health_System:usedItem', function(result)
        if result.success then 
            local healedPart = data.healedPart
            local usedItem = data.usedItem
            local healAmount = checkDoctorItemsHowMuchHealthRenew(usedItem.name)
            if healAmount then 
                if healAmount.healGeneral > 0 then
                    for boneGroup, groupData in pairs(inspectedPlayer.bodyParts) do
                        if 0 >= inspectedPlayer.bodyParts[boneGroup].currentHealth and usedItem.name == 'surgerykit' then
                                if inspectedPlayer.bodyParts[boneGroup].currentHealth + healAmount.healGeneral > 100 then
                                    inspectedPlayer.bodyParts[boneGroup].currentHealth = 100
                                else
                                    inspectedPlayer.bodyParts[boneGroup].currentHealth = inspectedPlayer.bodyParts[boneGroup].currentHealth + healAmount.healGeneral
                                end
                        else
                            if usedItem.name ~= 'surgerykit' then
                                if inspectedPlayer.bodyParts[boneGroup].currentHealth + healAmount.healGeneral > 100 then
                                    inspectedPlayer.bodyParts[boneGroup].currentHealth = 100
                                else
                                    inspectedPlayer.bodyParts[boneGroup].currentHealth = inspectedPlayer.bodyParts[boneGroup].currentHealth + healAmount.healGeneral
                                end
                            end
                        end
                    end
                end

                

                if healAmount.healPart > 0 then 
                    if 0 >= inspectedPlayer.bodyParts[healedPart].currentHealth then
                        TriggerServerEvent("Sweepz_Damages:AddItem123123", usedItem.name)
                        return
                    else
                        if inspectedPlayer.bodyParts[healedPart].currentHealth + healAmount.healPart > 100 then
                            inspectedPlayer.bodyParts[healedPart].currentHealth = 100
                        else
                            inspectedPlayer.bodyParts[healedPart].currentHealth = inspectedPlayer.bodyParts[healedPart].currentHealth + healAmount.healPart
                        end
                    end
                end
            end
            cb('ok')
        else
            sendNotify('error', Config.Translate.youDontHaveItem)
            cb('error')
        end
    end, data, inspectedPlayer.inspectedPlayerId)
end)


-- revive player
RegisterNUICallback('revivePlayer', function(data, cb)
    if not inspectedPlayer then return end
    if Config.PartHealthNeededForRevive then 
        local canRevivable = checkAllPartHealthForRevive()
        if not canRevivable then 
            sendNotify('error', Config.Translate.youCantRevive)
            cb('error')
            return
        end
    end
    TriggerServerCallback('Sweepz_Health_System:revivePlayer', function(result)
        if result.success then 
            RenderScriptCams(false, false, 0, true, true)
            DestroyCam(camera, true)
            SetNuiFocus(false, false)
            SendNUIMessage({
                action = "hide"
            })
            -- full health and revive to inspectedPlayer
            for boneGroup, groupData in pairs(inspectedPlayer.bodyParts) do
                inspectedPlayer.bodyParts[boneGroup].currentHealth = 100
                inspectedPlayer.bodyParts[boneGroup].damagedBy = nil
                inspectedPlayer.health = 100
            end
            cb(result.itemName)
        else
            sendNotify('error', result.errorText)
            cb('error')
        end
    end, inspectedPlayer.inspectedPlayerId)
end)

-- change cam position

RegisterNUICallback('camClick', function(data, cb)
    local camPosition = data.state
    if inspectedPlayer ~= nil then 
        if camPosition == "dead" then 
            local targetCoords = GetOffsetFromEntityInWorldCoords(inspectedPlayer.playerPed, 0.0, 2.5, 7.5)
            SetCamParams(camera, targetCoords.x, targetCoords.y, targetCoords.z, 0.0, 0.0, 0.0, 20.0, 1500, 1, 1, 2)
        else
            local targetCoords = GetOffsetFromEntityInWorldCoords(inspectedPlayer.playerPed, 0.0, 10.0, 0.3)
            SetCamParams(camera, targetCoords.x, targetCoords.y, targetCoords.z, 0.0, 0.0, 0.3, 20.0, 1500,  1, 1, 2)
        end
    end
    cb('ok')
end)

--

