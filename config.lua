Config = {}

Config.Framework = "qb"                            -- "qb"  /  "esx"
Config.CheckPlayerCommand =
"checkplayerhealth"                                -- If you want to change check player health command, you can change this value.
Config.CheckPlayerCommand2 =
"checkYourself"                                    -- If you want to change check player health command, you can change this value.
Config.CheckPlayerKey = "F6"                       -- If you want to change check player health key, you can change this value.
Config.DisarmPed = true                            -- If player get damage from arms, player will disarm.
Config.DisarmPedArmHealth = 50                     -- If player arm health is less than this value, player will disarm.
Config.PlayerRagdoll = true                        -- If player get damage from legs and if players run, player will ragdoll.
Config.Bleeding = true                             -- If player get damage, player will start bleeding.
Config.BleedingDecreaseAllPartHealth = 0.5         -- All part health will decrease this value every second.
Config.BleedingIfThisPartGetDamage = "Body"        -- Head, Body, LeftArm, RightArm, LeftLeg, RightLeg
Config.BleedingStopHealth = 50                     -- If player health is more than this value, bleeding will stop.
Config.BleedingTime = 10                           -- Bleeding time in seconds.
Config.BleedingScreenEffect = true                 -- If player bleeding, screen will be red.
Config.BleedingChance = 10
Config.AllPartDamageWhenFatalDamage = false         -- If player get fatal damage, all part will get damage.
Config.FatalDamageRandom = { min = 10, max = 70 }  -- If player get fatal damage, all part health will be random value between min and max.
Config.FullHealthOnRevive = false                   -- If player revived, player will get full health for all parts.
Config.ReviveItemNeeded = true                     -- If player want to revive player, player must have item.

Config.ReviveItems = {
    ["firstaid"] = {
        name = "firstaid", -- item name
        reviveChance = 100,
    }
}

-- FOR ESX: esx_ambulancejob:revive
Config.PartHealthNeededForRevive = false  -- If player want to revive player, player must have part health.
Config.MinimumAllPartHealthForRevive = 50 -- All part health must be more than this value to revive player.

Config.DoctorItems = {
    ["surgerykit"] = {
        image = "img/firstaid.png",
        label = "Surgery Kit",
        itemName = "surgerykit",
        healPart = 0,
        healAmount = 10,
        healGeneral = 10,
        description = "Surgery Kit saves lives, stabilizes emergencies.",
        stopBleeding = false,
    },
    ["bandage"] = {
        image = "img/bandage.png",
        label = "Bandage",
        itemName = "bandage",
        healPart = 25,
        healAmount = 10,
        healGeneral = 0,
        description = "Bandage protects wounds, supports healing.",
        stopBleeding = false,
    },
    ["firstaid"] = {
        image = "img/firstaid.png",
        label = "Medikit",
        itemName = "firstaid",
        healPart = 85,
        healAmount = 40,
        healGeneral = 0,
        description = "First aid saves lives, stabilizes emergencies.",
        stopBleeding = false,
    }
}

Config.AllowedJobs = {
    "ambulance",
    "police",
}

Config.RevivePlayer = function()
    if Config.Framework == "qb" then
        TriggerEvent("hospital:client:Revive")
    elseif Config.Framework == "esx" then
        TriggerEvent("esx_ambulancejob:revive") -- esx_ambulancejob:revive
    else
        print("You can fill the RevivePlayer function for your framework.")
    end
end

Config.Translate = {
    title1 = "LOS SANTOS EMERGENCY",
    title2 = "Body Health System",
    healingItemYouHave = "Healing item you have",
    healthOfBodyParts = "Health of body parts",
    head = "Head",
    body = "Body",
    leftArm = "Left Arm",
    rightArm = "Right Arm",
    leftLeg = "Left Leg",
    rightLeg = "Right Leg",
    warn1 = "Lorem ipsum dolor, sit amet consectetur adipisicing elit. Hic vitae solu",
    warn2 = "Lorem ipsum dolor, sit amet consectetur adipisicing elit. Hic vitae solu",
    damageStatus = "Damage Status",
    damageSource = "Damage Source",
    revive = "Revive",
    health = "Health",
    youAreDead = "You are dead.",
    notDoctor = "You are not a doctor.",
    unknownWeapon = "Unknown weapon",
    unknownMeleeWeapon = "Unknown melee weapon",
    vehicle = "Vehicle",
    unknown = "Unknown",
    youDontHaveItem = "You don't have item",
    youCantRevive = "You can't revive this player, all parts should be more healthier", -- all part health must be more than 50
    reviveFailed = "Revive failed",
    youDontHaveRequiredItem = "You don't have required item to revive player"
}

Config.Disable = {
    OnePunchKnockout = true,
    DriveBy = true,
    BikeKick = true
}

Config.SingelDamage = {
    [tonumber(2725352035)] = 10 -- https://forge.plebmasters.de/joaatresolver?input=WEAPON_UNARMED
}

Config.Weapon = {
    [tonumber(453432689)] = { -- https://forge.plebmasters.de/joaatresolver?input=WEAPON_PISTOL
        ["KAFA"] = 45,
        ["GOVDE"] = 40,
        ["SOLKOL"] = 40,
        ["SAGKOL"] = 35,
        ["SOLBACAK"] = 30,
        ["SAGBACAK"] = 25
    }
}

Config.DoktorNPC = {
    model = "s_m_m_doctor_01",
    coords = {
        vector4(-602.9436, -1247.2889, 11.4241, 311.9409)
    }
}