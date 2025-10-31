Framework = nil

if Config.Framework == "qb" then
	Framework = exports['qb-core']:GetCoreObject()
elseif Config.Framework == "esx" then
	Framework = exports['es_extended']:getSharedObject()
elseif Config.Framework == "oldEsx" then
	Framework = nil
	CreateThread(function()
		while Framework == nil do
			TriggerEvent('esx:getSharedObject', function(obj) Framework = obj end)
			Wait(10)
		end
	end)
end

function TriggerServerCallback(...)
	if Config.Framework == "esx" or Config.Framework == "oldEsx" then
		Framework.TriggerServerCallback(...)
	else
		Framework.Functions.TriggerCallback(...)
	end
end


function checkMyJob()
    local myJob = nil
    if Config.Framework == "qb" then
        myJob = Framework.Functions.GetPlayerData().job.name
    else
        myJob = Framework.GetPlayerData().job.name
    end

    for k, v in pairs(Config.AllowedJobs) do
        if myJob == v then
            return true
        end
    end

    return false
end

function checkPedIsDead(ped)
    local playerCoords = GetEntityCoords(ped)
    local boneCoords = GetPedBoneCoords(ped, 0x796E)
    if boneCoords.z < playerCoords.z + 0.5 then
        return true
    end
    return false
end

function sendNotify(notifyType, text)
    if Config.Framework == "qb" then
        Framework.Functions.Notify(text, notifyType)
    else
        Framework.ShowNotification(text)
    end
end

function disarmPed(ped)
    ClearPedSecondaryTask(ped)
    ClearPedTasks(ped)
    RemoveAllPedWeapons(ped, true)
end

function revivePlayer()
    if Config.Framework == "qb" then 
        TriggerEvent('hospital:client:Revive')
    else
        TriggerEvent('esx_ambulancejob:revive')
    end
end

--------------------------

meleeWeapons = {
    { name = "Unarmed", hash = GetHashKey("WEAPON_UNARMED") },
    { name = "Bat", hash = GetHashKey("WEAPON_BAT") },
    { name = "Crowbar", hash = GetHashKey("WEAPON_CROWBAR") },
    { name = "Golf Club", hash = GetHashKey("WEAPON_GOLFCLUB") },
    { name = "Hammer", hash = GetHashKey("WEAPON_HAMMER") },
    { name = "Hatchet", hash = GetHashKey("WEAPON_HATCHET") },
    { name = "Knuckle", hash = GetHashKey("WEAPON_KNUCKLE") },
    { name = "Knife", hash = GetHashKey("WEAPON_KNIFE") },
    { name = "Machete", hash = GetHashKey("WEAPON_MACHETE") },
    { name = "Switchblade", hash = GetHashKey("WEAPON_SWITCHBLADE") },
    { name = "Nightstick", hash = GetHashKey("WEAPON_NIGHTSTICK") },
    { name = "Wrench", hash = GetHashKey("WEAPON_WRENCH") },
    { name = "Battle Axe", hash = GetHashKey("WEAPON_BATTLEAXE") },
    { name = "Pool Cue", hash = GetHashKey("WEAPON_POOLCUE") },
    { name = "Stone Hatchet", hash = GetHashKey("WEAPON_STONE_HATCHET") }
}

allWeapons = {
    { name = "Pistol", hash = GetHashKey("WEAPON_PISTOL") },
    { name = "Combat Pistol", hash = GetHashKey("WEAPON_COMBATPISTOL") },
    { name = "AP Pistol", hash = GetHashKey("WEAPON_APPISTOL") },
    { name = "Pistol .50", hash = GetHashKey("WEAPON_PISTOL50") },
    { name = "SNS Pistol", hash = GetHashKey("WEAPON_SNSPISTOL") },
    { name = "Heavy Pistol", hash = GetHashKey("WEAPON_HEAVYPISTOL") },
    { name = "Vintage Pistol", hash = GetHashKey("WEAPON_VINTAGEPISTOL") },
    { name = "Marksman Pistol", hash = GetHashKey("WEAPON_MARKSMANPISTOL") },
    { name = "Revolver", hash = GetHashKey("WEAPON_REVOLVER") },
    { name = "Double Action", hash = GetHashKey("WEAPON_DOUBLEACTION") },
    { name = "Ray Pistol", hash = GetHashKey("WEAPON_RAYPISTOL") },
    { name = "Micro SMG", hash = GetHashKey("WEAPON_MICROSMG") },
    { name = "SMG", hash = GetHashKey("WEAPON_SMG") },
    { name = "Assault SMG", hash = GetHashKey("WEAPON_ASSAULTSMG") },
    { name = "MG", hash = GetHashKey("WEAPON_MG") },
    { name = "Combat MG", hash = GetHashKey("WEAPON_COMBATMG") },
    { name = "Combat MG Mk II", hash = GetHashKey("WEAPON_COMBATMG_MK2") },
    { name = "Combat PDW", hash = GetHashKey("WEAPON_COMBATPDW") },
    { name = "Gusenberg", hash = GetHashKey("WEAPON_GUSENBERG") },
    { name = "Assault Rifle", hash = GetHashKey("WEAPON_ASSAULTRIFLE") },
    { name = "Carbine Rifle", hash = GetHashKey("WEAPON_CARBINERIFLE") },
    { name = "Advanced Rifle", hash = GetHashKey("WEAPON_ADVANCEDRIFLE") },
    { name = "Special Carbine", hash = GetHashKey("WEAPON_SPECIALCARBINE") },
    { name = "Bullpup Rifle", hash = GetHashKey("WEAPON_BULLPUPRIFLE") },
    { name = "Compact Rifle", hash = GetHashKey("WEAPON_COMPACTRIFLE") },
    { name = "Musket", hash = GetHashKey("WEAPON_MUSKET") },
    { name = "Heavy Shotgun", hash = GetHashKey("WEAPON_HEAVYSHOTGUN") },
    { name = "Assault Shotgun", hash = GetHashKey("WEAPON_ASSAULTSHOTGUN") },
    { name = "Bullpup Shotgun", hash = GetHashKey("WEAPON_BULLPUPSHOTGUN") },
    { name = "DB Shotgun", hash = GetHashKey("WEAPON_DBSHOTGUN") },
    { name = "Pump Shotgun", hash = GetHashKey("WEAPON_PUMPSHOTGUN") },
    { name = "Sawed-Off Shotgun", hash = GetHashKey("WEAPON_SAWNOFFSHOTGUN") },
    { name = "Ray Carbine", hash = GetHashKey("WEAPON_RAYCARBINE") },
    { name = "Marksman Rifle", hash = GetHashKey("WEAPON_MARKSMANRIFLE") },
    { name = "Sniper Rifle", hash = GetHashKey("WEAPON_SNIPERRIFLE") },
    { name = "Heavy Sniper", hash = GetHashKey("WEAPON_HEAVYSNIPER") },
    { name = "Heavy Sniper Mk II", hash = GetHashKey("WEAPON_HEAVYSNIPER_MK2") },
    { name = "Minigun", hash = GetHashKey("WEAPON_MINIGUN") },
    { name = "RPG", hash = GetHashKey("WEAPON_RPG") },
    { name = "Homing Launcher", hash = GetHashKey("WEAPON_HOMINGLAUNCHER") },
    { name = "Grenade Launcher", hash = GetHashKey("WEAPON_GRENADELAUNCHER") },
    { name = "Firework", hash = GetHashKey("WEAPON_FIREWORK") },
    { name = "Railgun", hash = GetHashKey("WEAPON_RAILGUN") },
    { name = "Compact Launcher", hash = GetHashKey("WEAPON_COMPACTLAUNCHER") },
    { name = "Ray Minigun", hash = GetHashKey("WEAPON_RAYMINIGUN") }
}

function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(true)
    SetTextColour(255, 255, 255, 215)
    BeginTextCommandDisplayText('STRING')
    SetTextCentre(true)
    AddTextComponentSubstringPlayerName(text)
    SetDrawOrigin(x, y, z, 0)
    EndTextCommandDisplayText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0 + 0.0125, 0.017 + factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end