ESX = nil
local choosen_radius
local choosen_speed
local speedzones = {}

CreateThread(function()
    ESX = exports["es_extended"]:getSharedObject()
    while ESX.GetPlayerData().job == nil do Wait(100) end
	ESX.PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    ESX.PlayerData = xPlayer
    PlayerLoaded = true
end)

RegisterNetEvent('esx:onPlayerLogout')
AddEventHandler('esx:onPlayerLogout', function()
	ESX.PlayerLoaded = false
	ESX.PlayerData = {}
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    ESX.PlayerData.job = job
end)

RegisterNetEvent('esx_scenemenu:OpenMainMenu')
AddEventHandler('esx_scenemenu:OpenMainMenu', function()
    OpenMainMenu()
end)

RegisterCommand('scenemenu', function(source, args)
    OpenMainMenu()
end)

function OpenMainMenu()
    local elements = {
        {label = _U('mainmenu_objects'), value = 'objects'},
        {label = _U('mainmenu_speedzone'), value = 'speedzone'},
    }
    ESX.UI.Menu.CloseAll()

    ESX.UI.Menu.Open(
        'default', GetCurrentResourceName(), 'esx_scenemenu-main',
    {
        title    = (_U('title')),
        align    = 'top-left',
        elements = elements,
    },
    function(data, menu)
        if data.current.value == 'objects' then
            OpenObjectMenu()
        elseif data.current.value == 'speedzone' then
            OpenSpeedzoneMenu()
        end
    end, function(data, menu)
        menu.close()
        choosen_radius = nil
        choosen_speed = nil
    end)
end

function OpenObjectMenu()
    local elements_objects = {
        {label = _U('objectmenu_delete'), value = 'delete'},
    }

    for key,value in pairs(Config.Objects) do
        table.insert(elements_objects, value)
    end

    ESX.UI.Menu.Open(
        'default', GetCurrentResourceName(), 'esx_scenemenu-objects',
    {
        title    = (_U('title')),
        align    = 'top-left',
        elements = elements_objects,
    },
    function(data_objects, menu_objects)
        local objectname = data_objects.current.object
        local Player = GetPlayerPed(-1)
        local heading = GetEntityHeading(Player)
        local x, y, z = table.unpack(GetEntityCoords(Player, true))
        if data_objects.current.value == 'delete' then
            for k,v in pairs(Config.Objects) do
                local hash = GetHashKey(v.object)
                if DoesObjectOfTypeExistAtCoords(x, y, z, 0.9, hash, true) then
                    local object = GetClosestObjectOfType(x, y, z, 0.9, hash, false, false, false)
                    DeleteObject(object)
                end
            end
        else
            RequestModel(objectname)
            while not HasModelLoaded(objectname) do
              Citizen.Wait(1)
            end
            local obj = CreateObject(GetHashKey(objectname), x, y, z, true, false);
            PlaceObjectOnGroundProperly(obj)
            SetEntityHeading(obj, heading)
            FreezeEntityPosition(obj, true)
        end
    end, function(data_objects, menu_objects)
        menu_objects.close()
    end)
end

function OpenSpeedzoneMenu()
    local elements_speedzone = {
        {label = _U('speedzonemenu_radius'), value = 'speedzone_radius'},
        {label = _U('speedzonemenu_speed'), value = 'speedzone_speed'},
        {label = _U('speedzonemenu_create'), value = 'speedzone_create'},
        {label = _U('speedzonemenu_delete'), value = 'speedzone_delete'},
    }

    ESX.UI.Menu.Open(
        'default', GetCurrentResourceName(), 'esx_scenemenu-speedzone',
    {
        title    = (_U('title')),
        align    = 'top-left',
        elements = elements_speedzone,
    },
    function(data_speedzone, menu_speedzone)
        if data_speedzone.current.value == 'speedzone_radius' then
            local elements_speedzone_radius = {}

            for key_radius, value_radius in pairs(Config.SpeedZone.Radius) do
                table.insert(elements_speedzone_radius, {label = value_radius, value = value_radius})
            end
            
            ESX.UI.Menu.Open(
                'default', GetCurrentResourceName(), 'esx_scenemenu-speedzone_radius',
            {
                title    = (_U('title')),
                align    = 'top-left',
                elements = elements_speedzone_radius,
            },
            function(data_speedzone_radius, menu_speedzone_radius)
                choosen_radius = data_speedzone_radius.current.value
                menu_speedzone_radius.close()
            end, function(data_speedzone_radius, menu_speedzone_radius)
                menu_speedzone_radius.close()
            end)
        elseif data_speedzone.current.value == 'speedzone_speed' then
            local elements_speedzone_speed = {}

            for key_speed, value_speed in pairs(Config.SpeedZone.Speed) do
                table.insert(elements_speedzone_speed, {label = value_speed, value = value_speed})
            end
            
            ESX.UI.Menu.Open(
                'default', GetCurrentResourceName(), 'esx_scenemenu-speedzone_speed',
            {
                title    = (_U('title')),
                align    = 'top-left',
                elements = elements_speedzone_speed,
            },
            function(data_speedzone_speed, menu_speedzone_speed)
                choosen_speed = data_speedzone_speed.current.value
                menu_speedzone_speed.close()
            end, function(data_speedzone_speed, menu_speedzone_speed)
                menu_speedzone_speed.close()
            end)
        elseif data_speedzone.current.value == 'speedzone_create' then
            if not choosen_radius then
                ESX.ShowNotification(_U('speedzonemenu_create_no_radius'))
            elseif not choosen_speed then
                ESX.ShowNotification(_U('speedzonemenu_create_no_speed'))
            elseif choosen_radius and choosen_speed then
                local x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(-1)))
                radius = choosen_radius + 0.0
                speed = choosen_speed + 0.0
                local streetName, crossing = GetStreetNameAtCoord(x, y, z)
                streetName = GetStreetNameFromHashKey(streetName)
                local message = _U('speedzonemessage_first')..streetName.._U('speedzonemessage_last')..speed

                TriggerServerEvent('esx_scenemenu:ZoneActivated', message, speed, radius, x, y, z)
            end
        elseif data_speedzone.current.value == 'speedzone_delete' then
            local x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(-1)))
            local streetName, crossing = GetStreetNameAtCoord(x, y, z)
            streetName = GetStreetNameFromHashKey(streetName)
            local message = _U('speedzonemessagedelete_first')..streetName.._U('speedzonemessagedelete_last')

            TriggerServerEvent('esx_scenemenu:RemoveZone', message)
        end
    end, function(data_speedzone, menu_speedzone)
        menu_speedzone.close()
    end)
end

RegisterNetEvent('esx_scenemenu:CreateZone')
AddEventHandler('esx_scenemenu:CreateZone', function(speed, radius, x, y, z)
    blip = AddBlipForRadius(x, y, z, radius)
        SetBlipColour(blip,idcolor)
        SetBlipAlpha(blip,80)
        SetBlipSprite(blip,9)
    speedZone = AddSpeedZoneForCoord(x, y, z, radius, speed, false)

    table.insert(speedzones, {x, y, z, speedZone, blip})
end)

RegisterNetEvent('esx_scenemenu:RemoveZoneClient')
AddEventHandler('esx_scenemenu:RemoveZoneClient', function()

    if speedzones == nil then
      return
    end
    local playerPed = GetPlayerPed(-1)
    local x, y, z = table.unpack(GetEntityCoords(playerPed, true))
    local closestSpeedZone = 0
    local closestDistance = 1000
    for i = 1, #speedzones, 1 do
        local distance = Vdist(speedzones[i][1], speedzones[i][2], speedzones[i][3], x, y, z)
        if distance < closestDistance then
            closestDistance = distance
            closestSpeedZone = i
        end
    end
    RemoveSpeedZone(speedzones[closestSpeedZone][4])
    RemoveBlip(speedzones[closestSpeedZone][5])
    table.remove(speedzones, closestSpeedZone)
end)