 

local RNE = RegisterNetEvent
local AEH = AddEventHandler
 
ESX = exports["es_extended"]:getSharedObject()
 
RNE('esx:playerLoaded')
AEH('esx:playerLoaded', function(xPlayer)
    ESX.PlayerData = xPlayer
    ESX.PlayerLoaded = true
end)

RNE('esx:onPlayerLogout')
AEH('esx:onPlayerLogout', function()
    ESX.PlayerLoaded = false
    ESX.PlayerData = {}
end)

RNE('esx:setJob')
AEH('esx:setJob', function(job)
    ESX.PlayerData.job = job
end)


RNE('esx:setJob')
RNE('esx:setJob', function(job)
    ESX.PlayerData.job = job
end)

local SpawnedPlants = {}
local InteractedPlant = nil
local HarvestedPlants = {}
local canHarvest = true
local closestPlant = nil
local isDoingAction = false

Citizen.CreateThread(function()
    while true do
    Citizen.Wait(150)

    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local inRange = false

    for i = 1, #Config.Plants do
        local dist = GetDistanceBetweenCoords(pos.x, pos.y, pos.z, Config.Plants[i].x, Config.Plants[i].y, Config.Plants[i].z, true)

        if dist < 20.0 then
            inRange = true
            local hasSpawned = false
            local needsUpgrade = false
            local upgradeId = nil
            local tableRemove = nil

            for z = 1, #SpawnedPlants do
                local p = SpawnedPlants[z]

                if p.id == Config.Plants[i].id then
                    hasSpawned = true
                    if p.stage ~= Config.Plants[i].stage then
                        needsUpgrade = true
                        upgradeId = p.id
                        tableRemove = z
                    end
                end
            end

            if not hasSpawned then
                local hash = GetHashKey(Config.WeedStages[Config.Plants[i].stage])
                RequestModel(hash)
                local data = {}
                data.id = Config.Plants[i].id
                data.stage = Config.Plants[i].stage

                while not HasModelLoaded(hash) do
                    Citizen.Wait(10)
                    RequestModel(hash)
                end

                data.obj = CreateObject(hash, Config.Plants[i].x, Config.Plants[i].y, Config.Plants[i].z + GetPlantZ(Config.Plants[i].stage), false, false, false) 
                SetEntityAsMissionEntity(data.obj, true)
                FreezeEntityPosition(data.obj, true)
                table.insert(SpawnedPlants, data)
                hasSpawned = false
            end

            if needsUpgrade then
                for o = 1, #SpawnedPlants do
                    local u = SpawnedPlants[o]

                    if u.id == upgradeId then
                        SetEntityAsMissionEntity(u.obj, false)
                        FreezeEntityPosition(u.obj, false)
                        DeleteObject(u.obj)

                        local hash = GetHashKey(Config.WeedStages[Config.Plants[i].stage])
                        RequestModel(hash)
                        local data = {}
                        data.id = Config.Plants[i].id
                        data.stage = Config.Plants[i].stage

                        while not HasModelLoaded(hash) do
                            Citizen.Wait(10)
                            RequestModel(hash)
                        end

                        data.obj = CreateObject(hash, Config.Plants[i].x, Config.Plants[i].y, Config.Plants[i].z + GetPlantZ(Config.Plants[i].stage), false, false, false) 
                        SetEntityAsMissionEntity(data.obj, true)
                        FreezeEntityPosition(data.obj, true)
                        table.remove(SpawnedPlants, o)
                        table.insert(SpawnedPlants, data)
                        needsUpgrade = false
                    end
                end
            end
        end
    end
    if not InRange then
        Citizen.Wait(1000)
    end
    end
end)

 

RNE('izbrisitravu', function()
    local plant = GetClosestPlant()
    local hasDone = false

    for k, v in pairs(HarvestedPlants) do
        if v == plant.id then
            hasDone = true
        end
    end

    if not hasDone then
        table.insert(HarvestedPlants, plant.id)
        local ped = PlayerPedId()
        isDoingAction = true
        TriggerServerEvent('jevtovicc:weedplant:plantHasBeenHarvested', plant.id)
        TaskTurnPedToFaceEntity(PlayerPedId(), entity, -1)

        lib.progressCircle({
            duration = 8000,
            position = 'bottom',
            useWhileDead = false,
            canCancel = false,
            label = "移除中",
            disable = {
                car = true,
                move = true,
                combat = true
            },
            anim = {
                dict = 'amb@prop_human_bum_bin@base',
                clip = 'base'
            },
        })
        TriggerServerEvent('jevtovicc:weedplant:destroyPlant', plant.id)
        isDoingAction = false
        canHarvest = true
        FreezeEntityPosition(ped, false)
        ClearPedTasksImmediately(ped)
        ClearPedTasks(PlayerPedId())
    else

    end
end)

function HarvestWeedPlant()
    local plant = GetClosestPlant()
    local hasDone = false
    for k, v in pairs(HarvestedPlants) do
        if v == plant.id then
            hasDone = true
        end
    end

    if not hasDone then
        table.insert(HarvestedPlants, plant.id)
        isDoingAction = true
        TriggerServerEvent('jevtovicc:weedplant:plantHasBeenHarvested', plant.id)
        TaskTurnPedToFaceEntity(PlayerPedId(), entity, -1)

        lib.progressCircle({
            duration = 8000,
            position = 'bottom',
            useWhileDead = false,
            canCancel = false,
            label = "采摘中",
            disable = {
                car = true,
                move = true,
                combat = true
            },
            anim = {
                dict = 'amb@prop_human_bum_bin@base',
                clip = 'base'
            },
        })

        TriggerServerEvent('jevtovicc:weedplant:harvestWeed', plant.id)
        isDoingAction = false
        canHarvest = true
        ClearPedTasksImmediately(PlayerPedId())
        FreezeEntityPosition(PlayerPedId(), false)
        local hash = GetHashKey(`bkr_prop_weed_01_small_01c`)
        DeleteObject(hash)
    else

    end
end

function RemovePlantFromTable(plantId)
    for k, v in pairs(Config.Plants) do
        if v.id == plantId then
            table.remove(Config.Plants, k)
        end
    end
end


local weedmodels = {'bkr_prop_weed_01_small_01c','bkr_prop_weed_med_01a','bkr_prop_weed_lrg_01a'}
local weedoptions = {
    {
        name = 'weedopen',
        event = 'granula:otvori5',
        icon = 'fa-solid fa-cannabis',
        label = '查看大麻',
   
    } 
}

exports.ox_target:addModel(weedmodels, weedoptions)

 

RNE("granula:otvori5", function(args)
    local InRange = false
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local plant = GetClosestPlant()
    for k, v in pairs(Config.Plants) do
        if GetDistanceBetweenCoords(pos.x, pos.y, pos.z, v.x, v.y, v.z, true) < 3.3 and not isDoingAction and not v.beingHarvested and not IsPedInAnyVehicle(PlayerPedId(), false) then
            if ESX.PlayerData.job and ESX.PlayerData.job.name == 'police' then
                lib.registerContext({
                    id = 'policija',
                    title = '大麻',
                    options = {
                        {
                            title = '移除',
                            description = "移除非法大麻",
                            event = "izbrisitravu",
                        },
                    }
                })
                lib.showContext('policija')
       
            elseif v.growth >= 100 then 
                lib.registerContext({
                    id = 'kastm',
                    title = '大麻',
                    options = {
                        {
                            title = '已经成熟', 
                            description = "大麻已成熟,可以采摘了!",
                            event = "biljka:uberi",
                            args = {
                                plant.id
                            }
                        },
                        {
                            title = '成熟度',
                            progress = v.growth,
                        },
                        {
                            title = '水分',
                            progress = v.thirst,
                            description = "大麻水分",
                            event = "dodaj:vodu",
                        },
                        {
                            title = '养分',
                            progress = v.hunger,
                            description = "大麻养分",
                            event = "dodaj:djubrivo",
                        },
                    }
                })
                lib.showContext('kastm')
            else 
                lib.registerContext({
                    id = '4',
                    title = '大麻',
                    options = {
                        {
                            title = '成活率',
                            progress = v.quality,
                            colorScheme = 'green',
                            description = "大麻的成活率!",
                        },
                        {
                            title = '成熟度',
                            colorScheme = 'orange',
                            progress = v.growth,
                        },
                        {
                            title = '水分',
                            progress = v.thirst,
                            colorScheme = 'blue',
                            description = "大麻水分",
                            event = "dodaj:vodu",
                
                            
                        },
                        {
                            title = '养分',
                            progress = v.hunger,
                            colorScheme = 'brown',
                            description = "大麻养分",
                            event = "dodaj:djubrivo",
                        },
                    }
                })
                lib.showContext('4')
            end
        end
    end
end)

RNE("biljka:uberi", function()
    local InRange = false
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    for k, v in pairs(Config.Plants) do
        if GetDistanceBetweenCoords(pos.x, pos.y, pos.z, v.x, v.y, v.z, true) < 3.3 and not isDoingAction and not v.beingHarvested and not IsPedInAnyVehicle(PlayerPedId(), false) then
            local plant = GetClosestPlant()
            if v.id == plant.id then
                HarvestWeedPlant()
                local hash = GetHashKey(plant.id)
                DeleteObject(hash)
            end
        end
    end
end)


RNE("dodaj:vodu", function()
    local InRange = false
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    for k, v in pairs(Config.Plants) do
        if GetDistanceBetweenCoords(pos.x, pos.y, pos.z, v.x, v.y, v.z, true) < 3.3 and not isDoingAction and not v.beingHarvested and not IsPedInAnyVehicle(PlayerPedId(), false) then
            local plant = GetClosestPlant()
            if v.thirst < 100 then 
                if v.id == plant.id then
                    TriggerServerEvent('rev:server:checkPlayerHasThisItem', GlobalState.TravaItemi.destilovana, 'jevtovicc:weedplant:client:waterPlant', true)
        
                end
            else
  
                lib.notify({
                    title = '大麻',
                    description = '大麻不需要浇水',
                    type = 'error'
                })

            end
        end
    end
end)        

RNE("dodaj:djubrivo", function()
    local InRange = false
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    for k, v in pairs(Config.Plants) do
        if GetDistanceBetweenCoords(pos.x, pos.y, pos.z, v.x, v.y, v.z, true) < 3.3 and not isDoingAction and not v.beingHarvested and not IsPedInAnyVehicle(PlayerPedId(), false) then
            local plant = GetClosestPlant()
            if v.hunger < 100 then 
                if v.id == plant.id then
                    TriggerServerEvent('rev:server:checkPlayerHasThisItem', GlobalState.TravaItemi.djubrivo, 'jevtovicc:weedplant:client:feedPlant', true)
                end
            else
                lib.notify({
                    title = '大麻',
                    description = '大麻不需要施肥',
                    type = 'error'
                })
            end   
        end
    end
end)

function GetClosestPlant()
    local dist = 600
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local plant = {}

    for i = 1, #Config.Plants do
        local xd = GetDistanceBetweenCoords(pos.x, pos.y, pos.z, Config.Plants[i].x, Config.Plants[i].y, Config.Plants[i].z, true)
        if xd < dist then
            dist = xd
            plant = Config.Plants[i]
        end
    end

    return plant
end

RNE('jevtovicc:weedplant:client:removeWeedObject')
AEH('jevtovicc:weedplant:client:removeWeedObject', function(plant)
    for i = 1, #SpawnedPlants do
        local o = SpawnedPlants[i]
        if o.id == plant then
            SetEntityAsMissionEntity(o.obj, false)
            FreezeEntityPosition(o.obj, false)
            DeleteObject(o.obj)
        end
    end
end)

RNE('jevtovicc:weedplant:client:notify')
AEH('jevtovicc:weedplant:client:notify', function(msg)			
    ESX.ShowNotification(msg)
end)

RNE('jevtovicc:weedplant:client:waterPlant')
AEH('jevtovicc:weedplant:client:waterPlant', function()
    local entity = nil
    local plant = GetClosestPlant()
    local ped = PlayerPedId()
    isDoingAction = true

    for k, v in pairs(SpawnedPlants) do
        if v.id == plant.id then
            entity = v.obj
        end
    end

    TaskTurnPedToFaceEntity(PlayerPedId(), entity, -1)
    lib.progressCircle({
        duration = 8000,
        position = 'bottom',
        useWhileDead = false,
        canCancel = false,
        label = "浇水中",
        disable = {
            car = true,
            move = true,
            combat = true
        },
        anim = {
            dict = 'amb@prop_human_bum_bin@base',
            clip = 'base'
        },
    })

    TriggerServerEvent('jevtovicc:weedplant:server:waterPlant', plant.id)
    FreezeEntityPosition(PlayerPedId(), false)
    ClearPedTasksImmediately(PlayerPedId())
    isDoingAction = false

end)


RNE('jevtovicc:weedplant:client:feedPlant')
AEH('jevtovicc:weedplant:client:feedPlant', function()
    local entity = nil
    local plant = GetClosestPlant()
    local ped = PlayerPedId()
    isDoingAction = true

    for k, v in pairs(SpawnedPlants) do
        if v.id == plant.id then
            entity = v.obj
        end
    end

    TaskTurnPedToFaceEntity(PlayerPedId(), entity, -1)

    lib.progressCircle({
        duration = 8000,
        position = 'bottom',
        useWhileDead = false,
        canCancel = false,
        label = "施肥中",
        disable = {
            car = true,
            move = true,
            combat = true
        },
        anim = {
            dict = 'amb@prop_human_bum_bin@base',
            clip = 'base'
        },
    })

    TriggerServerEvent('jevtovicc:weedplant:server:feedPlant', plant.id)
    FreezeEntityPosition(ped, false)
    ClearPedTasksImmediately(PlayerPedId())
    isDoingAction = false

end)

RNE('jevtovicc:weedplant:client:updateWeedData')
AEH('jevtovicc:weedplant:client:updateWeedData', function(data)
    Config.Plants = data
end)

RNE('jevtovicc:weedplant:client:plantNewSeed')
AEH('jevtovicc:weedplant:client:plantNewSeed', function(type)
    local pos = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 1.0, 0.0)

    if CanPlantSeedHere(pos) and not IsPedInAnyVehicle(PlayerPedId(), false) then
        TriggerServerEvent('jevtovicc:weedplant:server:plantNewSeed', type, pos)
    else
        lib.notify({
            title = '大麻',
            description = '种植距离太近了',
            type = 'error'
        })
    end
end)


RNE('jevtovicc:weedplant:client:plantSeedConfirm')
AEH('jevtovicc:weedplant:client:plantSeedConfirm', function()
    RequestAnimDict("pickup_object")
    while not HasAnimDictLoaded("pickup_object") do
        Citizen.Wait(7)
    end
    TaskPlayAnim(PlayerPedId(), "pickup_object" ,"pickup_low" ,8.0, -8.0, -1, 1, 0, false, false, false)
    Citizen.Wait(1800)
    ClearPedTasks(PlayerPedId())
end)


local BlacklistedZones = {
    vector3(-1099.21, -829.89, 19.31), --pd
    vector3(-444.42, -348.08, 24.23), --bolnica
    vector3(216.61, -905.62, 30.69),

}

function CanPlantSeedHere(pos)
    local canPlant = true
    local coords = GetEntityCoords(PlayerPedId())
    for k,v in pairs(BlacklistedZones) do
        if GetDistanceBetweenCoords(coords - vector3(v.x, v.y, v.z)) < 50.0 then
            canPlant = false
        end
    end

    for i = 1, #Config.Plants do
        if GetDistanceBetweenCoords(pos.x, pos.y, pos.z, Config.Plants[i].x, Config.Plants[i].y, Config.Plants[i].z, true) < 3.3 then
            canPlant = false
        end
    end

    return canPlant
end

function GetPlantZ(stage)
    if stage == 1 then return -1.0
    else return -3.5
    end
end

function animacija(dict, ime) 
    local ped = PlayerPedId()

    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(7)
    end

    TaskPlayAnim(PlayerPedId(), dict, ime, 8.0, -8.0, -1, 1, 0, false, false, false)
    FreezeEntityPosition(ped, true)
end


 


RNE('weed:clear_bags')
AEH('weed:clear_bags', function()

    if lib.progressCircle({
        duration = 5000,
        position = 'bottom',
        useWhileDead = false,
        canCancel = false,
        label = '包装中',
        disable = {
          car = true,
          move = true,
          combat = true,
        },
        anim = {
          dict = 'impexp_int-0',
          clip = 'mp_m_waremech_01_dual-0'
        },
        prop = {
            model = `sf_prop_sf_bag_weed_open_01b`,
            bone = 4153,
            pos = vec3(0.01, -0.08, 0.05),
            rot = vec3(0.0, -360, 90)
        },
     
    }) then 
        TriggerServerEvent('weedserver:clear_bags')
    else 
        lib.notify({
            title = '大麻',
            description = '发生位置错误',
            type = 'error'
        })
    end


 
 
 
end)


RNE('weed:joint')
AEH('weed:joint', function()
    local player = PlayerPedId()
    local MaxArmour =  GetPlayerMaxArmour(player)

    local Armour   = GetPedArmour(player)
    local newArmour =   math.floor(Armour +  20)
    print(Armour)
 
    if Armour >= 0 and Armour < 100 then


    
        if lib.progressCircle({
            duration = 5000,
            position = 'bottom',
            useWhileDead = false,
            canCancel = false,
            label = '抽大麻',
            disable = {
              car = false,
              move = false,
              combat = false,
            },
            anim = {
              dict = 'amb@world_human_aa_smoke@male@idle_a',
              clip = 'idle_b'
            },
            prop = {
                model = `p_amb_joint_01`,
                bone = 28422,
                pos = vec3(0.00, 0.00, 0.00),
                rot = vec3(0.00, 0.00, 0.00)
            },
         
        }) then 
   
            TriggerServerEvent('weedserver:joint')
            SetPedArmour(player, newArmour)
            SetTimecycleModifier("spectator5")
            Citizen.Wait(5000)
            ClearTimecycleModifier()
        else 
            lib.notify({
                title = '大麻',
                description = '发生位置错误',
                type = 'error'
            })
        end


 
    elseif Armour == 100 then    

        lib.notify({
            title = '大麻烟',
            description = '你无法使用',
            type = 'error'
        })

     end 

end)    
 
 