local QBCore = exports['qb-core']:GetCoreObject()

-- Create item
QBCore.Functions.CreateUseableItem("helihook", function(source, item)
    local src = source
	local Player = QBCore.Functions.GetPlayer(src)

    if Player.Functions.GetItemByName(item.name) ~= nil then
        TriggerClientEvent("attachncaritem", src)
    end
end)