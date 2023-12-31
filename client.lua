--------- ATTACH -------------
local QBCore = exports['qb-core']:GetCoreObject()

local attachedCarModel = "npolvette"

-- Variable to keep track of the attached car
local attachedCar = nil

-- Attach the car to the helicopter
function attachCarToHelicopter(playerPed, helicopter)
    -- Check if a car is already attached and still exists
    if attachedCar ~= nil and DoesEntityExist(attachedCar) then
        TriggerEvent("chat:addMessage", {
            color = {255, 0, 0},
            multiline = true,
            args = {"System", "A car is already attached!"}
        })
        return
    end

    local heliCoords = GetEntityCoords(helicopter)
    local heliForwardVector = GetEntityForwardVector(helicopter)
    local carSpawnCoords = heliCoords + heliForwardVector * 5.0 -- Adjust the distance between helicopter and car

    -- Spawn the car model at the specified coordinates
    attachedCar = CreateVehicle(GetHashKey(attachedCarModel), carSpawnCoords.x, carSpawnCoords.y, carSpawnCoords.z, GetEntityHeading(helicopter), true, false)

    if DoesEntityExist(attachedCar) then
        -- Attach the car to the helicopter
        AttachEntityToEntity(attachedCar, helicopter, GetEntityBoneIndexByName(helicopter, "chassis"), 0.0, 0.0, -1.8, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
        TriggerEvent("chat:addMessage", {
            color = {255, 0, 0},
            multiline = true,
            args = {"System", "Car attached to helicopter!"}
        })
    end
end


RegisterCommand("detachcar", function(source, args)
    if DoesEntityExist(attachedCar) then
        DetachEntity(attachedCar, true, true)
        attachedCar = nil
        TriggerEvent("chat:addMessage", {
            color = {255, 0, 0},
            multiline = true,
            args = {"System", "Car detached from helicopter!"}
        })
    else
        TriggerEvent("chat:addMessage", {
            color = {255, 0, 0},
            multiline = true,
            args = {"System", "No car is attached to the helicopter!"}
        })
    end
end)



-- Attach the nearest car to the helicopter
function attachNearestCarToHelicopter(playerPed, helicopter)
    -- Check if a car is already attached and still exists
    if attachedCar ~= nil and DoesEntityExist(attachedCar) then
        TriggerEvent("chat:addMessage", {
            color = {255, 0, 0},
            multiline = true,
            args = {"System", "A car is already attached!"}
        })
        return
    end

    local playerCoords = GetEntityCoords(playerPed)
    local closestVehicle = GetClosestVehicle(playerCoords.x, playerCoords.y, playerCoords.z, 5.0, 0, 127)

    
    if DoesEntityExist(closestVehicle) then
        -- Attach the car to the helicopter
        AttachEntityToEntity(closestVehicle, helicopter, GetEntityBoneIndexByName(helicopter, "chassis"), 0.0, 0.0, -1.8, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
        attachedCar = closestVehicle
        TriggerEvent("chat:addMessage", {
            color = {255, 0, 0},
            multiline = true,
            args = {"System", "Car attached to helicopter!"}
        })
    else
        TriggerEvent("chat:addMessage", {
            color = {255, 0, 0},
            multiline = true,
            args = {"System", "No nearby cars found!"}
        })
    end
end

-- Command to attach the nearest car to the helicopter
RegisterCommand("attachncar", function(source, args)
    local playerPed = GetPlayerPed(-1)
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    -- Check if the player is in a helicopter
    if IsVehicleModel(vehicle, GetHashKey("polmav")) then -- Change the vehicle model to the helicopter model you want to use
        QBCore.Functions.Progressbar("attach_car", "Attaching car", 3000, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = "missheistdockssetup1clipboard@idle_a",
            anim = "idle_a",
            flags = 49,
        }, {}, {}, function() -- Done
            attachNearestCarToHelicopter(playerPed, vehicle)
        end, function() -- Cancel
            TriggerEvent("chat:addMessage", {
                color = {255, 0, 0},
                multiline = true,
                args = {"System", "Failed to attach the car!"}
            })
        end)
    else
        TriggerEvent("chat:addMessage", {
            color = {255, 0, 0},
            multiline = true,
            args = {"System", "You must be in a helicopter to use this command!"}
        })
    end
end)









-------------------- RAPPEL --------------------
-- Register the chat command /droprope
RegisterCommand('rappelheli', function(source, args, rawCommand)
    -- Get the player's ped
    local playerPed = GetPlayerPed(-1)

    -- Check if the player is in a helicopter
    if IsPedInAnyHeli(playerPed) then
        -- Make the player rappel from the helicopter
        TaskRappelFromHeli(playerPed, 0x41200000)
    else
        TriggerEvent('chat:addMessage', {
            color = { 255, 0, 0},
            multiline = true,
            args = {"System", "You must be in a helicopter to rappel!"}
        })
    end
end)



--- 2222 ---

local isRappelling = false

RegisterCommand('down', function()
    local ped = GetPlayerPed(-1)
    local pos = GetEntityCoords(ped)

    -- Check if the player is near a building
    if IsNearBuilding(pos) then
        if not isRappelling then
            TaskStartScenarioAtPosition(ped, "PROP_HUMAN_SEAT_LEDGE", pos.x, pos.y, pos.z - 1.0, 0.0, 0, 0, 1)
            isRappelling = true
        else
            ClearPedTasks(ped)
            isRappelling = false
        end
    else
        -- Notify the player that they are not near a suitable building
        TriggerEvent('chatMessage', 'SYSTEM', {255, 0, 0}, 'You are not near a suitable building to rappel down.')
    end
end, false)

-- Function to check if the player is near the side of a building
function IsNearBuilding(position)
    local ped = GetPlayerPed(-1)

    -- Define the direction for the raycast (downward)
    local direction = vector3(0.0, 0.0, -1.0)

    -- Perform a raycast from the player's position
    local rayHandle = StartShapeTestRay(position.x, position.y, position.z + 50.0, position.x, position.y, position.z - 50.0, 10, ped, 0)

    -- Get the result of the raycast
    local _, hit, _, _, _ = GetShapeTestResult(rayHandle)

    -- Check if the ray hit something and if that something is a building
    if hit > 0 and IsEntityAPed(hit) == false then
        return true
    else
        return false
    end
end
