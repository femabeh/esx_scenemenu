local ESX = nil
ESX = exports["es_extended"]:getSharedObject()

RegisterServerEvent('esx_scenemenu:ZoneActivated')
AddEventHandler('esx_scenemenu:ZoneActivated', function(message, speed, radius, x, y, z)
    if message and Config.UseMessage then
        TriggerClientEvent('chat:addMessage', -1, { color = { 255, 255, 255 }, multiline = false, args = {"LSPD", message} })
    end
    TriggerClientEvent('esx_scenemenu:CreateZone', -1, speed, radius, x, y, z)
end)

RegisterServerEvent('esx_scenemenu:RemoveZone')
AddEventHandler('esx_scenemenu:RemoveZone', function(message)
    if message and Config.UseMessage then
        TriggerClientEvent('chat:addMessage', -1, { color = { 255, 255, 255 }, multiline = false, args = {"LSPD", message} })
    end
    TriggerClientEvent('esx_scenemenu:RemoveZoneClient', -1)
end)
