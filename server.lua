ESX = exports["es_extended"]:getSharedObject()



local PlantsLoaded = false

GlobalState.TravaItemi = {
    sjemenka = 'marijuana_seeds',  --大麻种子
    saksija = 'flowerpot',            -- 花盆 
    djubrivo = 'fertilizer',   -- 肥料 
    destilovana = 'pure-water', --水
    vutra = 'marijuana_leaf',        --大麻叶
}

Citizen.CreateThread(function()
    TriggerEvent('jevtovicc:weedplant:server:getWeedPlants')
    print("[ TonyKFC WEEDPLANT LOADED ]")
    TriggerClientEvent('jevtovicc:weedplant:client:updateWeedData', -1, Config.Plants)
    PlantsLoaded = true
end)


ESX.RegisterUsableItem(GlobalState.TravaItemi.sjemenka, function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.triggerEvent('jevtovicc:weedplant:client:plantNewSeed')
end)
 
 


RegisterServerEvent('jevtovicc:weedplant:server:saveWeedPlant')
AddEventHandler('jevtovicc:weedplant:server:saveWeedPlant', function(data)
    local data = json.encode(data)
    
    exports.oxmysql:execute('INSERT INTO Trava (informacije) VALUES (@informacije)', {
        ['@informacije'] = data,
    }, function ()
    end)
end)

RegisterServerEvent('rev:server:checkPlayerHasThisItem')
AddEventHandler('rev:server:checkPlayerHasThisItem', function(item, cb)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if xPlayer.getInventoryItem(item).count > 0 then
        TriggerClientEvent(cb, src)
    else  
        
        --TriggerClientEvent("esx:showNotification", source,"你缺少施肥材料", "error")
        TriggerClientEvent('ox_lib:notify', src, {title = '大麻', description = '你缺少施肥材料', type = 'error'})


    end
end)

RegisterServerEvent('jevtovicc:weedplant:server:giveShittySeed')
AddEventHandler('jevtovicc:weedplant:server:giveShittySeed', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    xPlayer.addInventoryItem(Config.BadSeedReward, math.random(1, 2))
end)

RegisterServerEvent('jevtovicc:weedplant:server:plantNewSeed')
AddEventHandler('jevtovicc:weedplant:server:plantNewSeed', function(type, location)
    local src = source
    local plantId = math.random(111111, 999999)
    local xPlayer = ESX.GetPlayerFromId(src)
    local SeedData = {id = plantId, type = type, x = location.x, y = location.y, z = location.z, hunger = Config.StartingHunger, thirst = Config.StartingThirst, growth = 0.0, quality = 70.0, stage = 1, grace = true, beingHarvested = false, planter = xPlayer.identifier}

    local PlantCount = 0

    if xPlayer.getInventoryItem(GlobalState.TravaItemi.saksija).count >= 1 and xPlayer.getInventoryItem(GlobalState.TravaItemi.sjemenka).count >= 1 then
        xPlayer.removeInventoryItem(GlobalState.TravaItemi.saksija, 1)
        xPlayer.removeInventoryItem(GlobalState.TravaItemi.sjemenka, 1)

        for k, v in pairs(Config.Plants) do
            if v.planter == xPlayer.identifier then
                PlantCount = PlantCount + 1
            end
        end
    
        if PlantCount >= Config.MaxPlantCount then
 
             
        --TriggerClientEvent("esx:showNotification", source,"大麻已经泛滥了无法种植", "error")
        TriggerClientEvent('ox_lib:notify', src, {title = '大麻', description = '大麻已经泛滥了无法种植', type = 'error'})


        else
            table.insert(Config.Plants, SeedData)
            TriggerClientEvent('jevtovicc:weedplant:client:plantSeedConfirm', src)
            TriggerEvent('jevtovicc:weedplant:server:saveWeedPlant', SeedData)
            TriggerEvent('jevtovicc:weedplant:server:updatePlants')
        end
        
    else 
        --TriggerClientEvent("esx:showNotification", source,"你需要至少一个花盆和大麻种子", "error")
        TriggerClientEvent('ox_lib:notify', src, {title = '大麻', description = '你需要至少一个花盆和大麻种子', type = 'error'})



    end
end)

RegisterServerEvent('jevtovicc:weedplant:plantHasBeenHarvested')
AddEventHandler('jevtovicc:weedplant:plantHasBeenHarvested', function(plantId)
    for k, v in pairs(Config.Plants) do
        if v.id == plantId then
            v.beingHarvested = true
        end
    end

    TriggerEvent('jevtovicc:weedplant:server:updatePlants')
end)

RegisterServerEvent('jevtovicc:weedplant:destroyPlant')
AddEventHandler('jevtovicc:weedplant:destroyPlant', function(plantId)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    for k, v in pairs(Config.Plants) do
        if v.id == plantId then
            table.remove(Config.Plants, k)
        end
    end

    TriggerClientEvent('jevtovicc:weedplant:client:removeWeedObject', -1, plantId)
    TriggerEvent('jevtovicc:weedplant:server:weedPlantRemoved', plantId)
    TriggerEvent('jevtovicc:weedplant:server:updatePlants') 
     
    --TriggerClientEvent("esx:showNotification", source,"已经移除大麻", "success")
    TriggerClientEvent('ox_lib:notify', src, {title = '大麻', description = '已经移除大麻', type = 'success'})

end)

local hasFound = false


RegisterServerEvent('jevtovicc:weedplant:harvestWeed')
AddEventHandler('jevtovicc:weedplant:harvestWeed', function(plantId)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local amount
    local label
    local item
    local goodQuality = false

    for k, v in pairs(Config.Plants) do
        if v.id == plantId then     
            local quality = math.ceil(v.quality)
            hasFound = true
            amount = math.random(20,30)
            table.remove(Config.Plants, k)
            if quality > 98 then
                goodQuality = true
            end
            amount = math.ceil(amount * (quality / 35))
            xPlayer.addInventoryItem(GlobalState.TravaItemi.vutra, math.random(50, 100))
            --TriggerClientEvent("esx:showNotification", source,"你获得了"..amount.." 个未加工的大麻叶", "info")
            TriggerClientEvent('ox_lib:notify', src, {title = '大麻', description = '你获得了 '..amount..' 个未加工的大麻叶', type = 'inform'})


        end
    end

    if hasFound == true  then
        TriggerClientEvent('jevtovicc:weedplant:client:removeWeedObject', -1, plantId)
        TriggerEvent('jevtovicc:weedplant:server:weedPlantRemoved', plantId)
        TriggerEvent('jevtovicc:weedplant:server:updatePlants')
        if label ~= nil then
            TriggerClientEvent('jevtovicc:weedplant:client:notify', src, 'Dobio si x ' .. amount .. ' ' .. label) 

        end
        if goodQuality then
            xPlayer.addInventoryItem(GlobalState.TravaItemi.vutra, math.random(50, 200)) 
        end 
    else
        
         --TriggerClientEvent("esx:showNotification", source,"无法找到大麻", "error")
         TriggerClientEvent('ox_lib:notify', src, {title = '大麻', description = '无法找到大麻', type = 'error'})

    end
end)

RegisterServerEvent('jevtovicc:weedplant:server:updatePlants')
AddEventHandler('jevtovicc:weedplant:server:updatePlants', function()
    TriggerClientEvent('jevtovicc:weedplant:client:updateWeedData', -1, Config.Plants)
end)

RegisterServerEvent('jevtovicc:weedplant:server:waterPlant')
AddEventHandler('jevtovicc:weedplant:server:waterPlant', function(plantId)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    for k, v in pairs(Config.Plants) do
        if v.id == plantId then
            Config.Plants[k].thirst = Config.Plants[k].thirst + Config.ThirstIncrease
            if Config.Plants[k].thirst > 100.0 then
                Config.Plants[k].thirst = 100.0
            end
        end
    end

    xPlayer.removeInventoryItem(GlobalState.TravaItemi.destilovana, 1)
    TriggerEvent('jevtovicc:weedplant:server:updatePlants')
end)

RegisterServerEvent('jevtovicc:weedplant:server:feedPlant')
AddEventHandler('jevtovicc:weedplant:server:feedPlant', function(plantId)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    for k, v in pairs(Config.Plants) do
        if v.id == plantId then
            Config.Plants[k].hunger = Config.Plants[k].hunger + Config.HungerIncrease
            if Config.Plants[k].hunger > 100.0 then
                Config.Plants[k].hunger = 100.0
            end
        end
    end
    xPlayer.removeInventoryItem(GlobalState.TravaItemi.djubrivo, 1)
    TriggerEvent('jevtovicc:weedplant:server:updatePlants')
end)

RegisterServerEvent('jevtovicc:weedplant:server:updateWeedPlant')
AddEventHandler('jevtovicc:weedplant:server:updateWeedPlant', function(id, data)
    local result = exports.oxmysql:executeSync('SELECT * FROM Trava')
    if result[1] then
        for i = 1, #result do
            local plantData = json.decode(result[i].informacije)
            if plantData.id == id then
                local newData = json.encode(data)
                exports.oxmysql:execute('UPDATE Trava SET informacije = ? WHERE id = ?', {
                     newData,
                     result[i].id,
                }, function ()
                end)
            end
        end
    end
end)


RegisterServerEvent('jevtovicc:weedplant:server:weedPlantRemoved')
AddEventHandler('jevtovicc:weedplant:server:weedPlantRemoved', function(plantId)
    local result = exports.oxmysql:executeSync('SELECT * FROM Trava')

    if result then
        for i = 1, #result do
            local plantData = json.decode(result[i].informacije)
            if plantData.id == plantId then

                exports.oxmysql:execute('DELETE FROM Trava WHERE id = ?', {
                    result[i].id
                })

                for k, v in pairs(Config.Plants) do
                    if v.id == plantId then
                        table.remove(Config.Plants, k)
                    end
                end
            end
        end
    end
end)

RegisterServerEvent('jevtovicc:weedplant:server:getWeedPlants')
AddEventHandler('jevtovicc:weedplant:server:getWeedPlants', function()
    local data = {}
    local result = exports.oxmysql:executeSync('SELECT * FROM Trava')

    if result[1] then
        for i = 1, #result do
            local plantData = json.decode(result[i].informacije)

            table.insert(Config.Plants, plantData)
        end
    end
end)

travaDere = function()
    for i = 1, #Config.Plants do

        if Config.Plants[i].growth < 100 then
            if Config.Plants[i].grace then
                Config.Plants[i].grace = false
            else
                Config.Plants[i].thirst = Config.Plants[i].thirst - math.random(Config.Degrade.min, Config.Degrade.max) / 10
                Config.Plants[i].hunger = Config.Plants[i].hunger - math.random(Config.Degrade.min, Config.Degrade.max) / 10
                Config.Plants[i].growth = Config.Plants[i].growth + math.random(Config.GrowthIncrease.min, Config.GrowthIncrease.max) 

                if Config.Plants[i].growth > 100 then
                    Config.Plants[i].growth = 100
                end

                if Config.Plants[i].hunger < 0 then
                    Config.Plants[i].hunger = 0
                end

                if Config.Plants[i].thirst < 0 then
                    Config.Plants[i].thirst = 0
                end

                if Config.Plants[i].quality < 5 then
                    Config.Plants[i].quality = 5
                end

                if Config.Plants[i].thirst < 70 or Config.Plants[i].hunger < 70 then
                    if Config.Plants[i].quality > 60 then
                        Config.Plants[i].quality = Config.Plants[i].quality - 5
                    end
                else
                    if Config.Plants[i].quality < 100 then
                        Config.Plants[i].quality = Config.Plants[i].quality + 3.5
                    end
                end

        
                if Config.Plants[i].stage == 1 and Config.Plants[i].growth >= 55 then
                    Config.Plants[i].stage = 2
                elseif Config.Plants[i].stage == 2 and Config.Plants[i].growth >= 90 then
                    Config.Plants[i].stage = 3
                end
            end
        end
        TriggerEvent('jevtovicc:weedplant:server:updateWeedPlant', Config.Plants[i].id, Config.Plants[i])
    end
    TriggerEvent('jevtovicc:weedplant:server:updatePlants')
end

local Intervals = {}
SetajInterval = function(id, msec, callback, onclear)
    if not Intervals[id] and msec then
        Intervals[id] = msec
        CreateThread(function()
            repeat
                local interval = Intervals[id]
                Wait(interval)
                callback(interval)
            until interval == -1 and (onclear and onclear() or true)
            Intervals[id] = nil
        end)
    elseif msec then Intervals[id] = msec end
end

OcistiInterval = function(id)
    if Intervals[id] then Intervals[id] = -1 end
end

SetajInterval(1, 60000, travaDere)

RegisterServerEvent('weedserver:make')
 
--ESX.RegisterUsableItem('clear_bags', function(playerId)
RegisterServerEvent('weedserver:clear_bags')
AddEventHandler('weedserver:clear_bags', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local clear_bags = xPlayer.getInventoryItem('clear_bags').count
    local electronic_scale = xPlayer.getInventoryItem('electronic_scale').count
    local weed_powder = xPlayer.getInventoryItem('weed_powder').count
    local rolling_paper = xPlayer.getInventoryItem('rolling_paper').count

    if clear_bags >= 0 and electronic_scale >= 0 and weed_powder >= 0 and rolling_paper >= 0 then
        xPlayer.removeInventoryItem('clear_bags' ,1)
        xPlayer.removeInventoryItem('weed_powder' ,1)
        xPlayer.addInventoryItem('weed_joint', 1)
        xPlayer.addInventoryItem('rolling_paper', 1)
    else
         --TriggerClientEvent("esx:showNotification", source,"你没有足够的材料", "error")
         TriggerClientEvent('ox_lib:notify', src, {title = '大麻', description = '你没有足够的材料', type = 'error'})
    end  

  end)


  ESX.RegisterUsableItem('weed_joint', function(source)
    local xPlayer = ESX.GetPlayerFromId(source) 
    TriggerClientEvent('weed:joint', source) 
  end)

RegisterServerEvent('weedserver:joint')
AddEventHandler('weedserver:joint', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.removeInventoryItem('weed_joint' ,1) 

end)