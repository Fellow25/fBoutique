ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(90000)
        TriggerClientEvent("Boutique:Notification", -1, "N'hésitez pas à jeter un coup d'oeil à notre boutique (F11) !")
    end
end)

RegisterServerEvent("boutique:getpoints")
AddEventHandler("boutique:getpoints", function()
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer ~= nil then
	local _source = source
    if id_system_l_o_s == "steam" then
    license = xPlayer.getIdentifier()
    elseif id_system_l_o_s == "license" then
    license = ESX.GetIdentifierFromId(source)
    end
	MySQL.Async.fetchAll('SELECT * FROM users WHERE identifier=@identifier', {
        ['@identifier'] = license
	}, function(data)
		local poi = data[1].boutique_coin
		TriggerClientEvent('boutique:retupoints', _source, poi)
	end)
end
end)

ESX.RegisterServerCallback('boutique:GetCodeBoutique', function(source, cb)
    local xPlayer  = ESX.GetPlayerFromId(source)
    MySQL.Async.fetchAll("SELECT * FROM `users` WHERE `identifier` = '".. xPlayer.getIdentifier() .."'", {}, function (result)
        cb(result[1].boutique_id)
    end)
end)

RegisterServerEvent('shop:vehiculeboutique')
AddEventHandler('shop:vehiculeboutique', function(vehicleProps, plate)
    local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer ~= nil then
    MySQL.Async.execute('INSERT INTO owned_vehicles (owner, plate, vehicle) VALUES (@owner, @plate, @vehicle)', {
        ['@owner']   = xPlayer.identifier,
        ['@plate']   = vehicleProps.plate,
        ['@vehicle'] = json.encode(vehicleProps)
    }, function(rowsChange)
        PerformHttpRequest(discord_webhook.url, function(err, text, headers) end, 'POST', json.encode({username = "", content = xPlayer.getName() .. " à acheter un véhicule boutique."}), { ['Content-Type'] = 'application/json' })
    end)
end
end)

ESX.RegisterServerCallback('Boutique:DonnePoint', function(source, cb, point, boutique_id)
    local xPlayer  = ESX.GetPlayerFromId(source)
    if xPlayer ~= nil then
   MySQL.Async.fetchAll("SELECT * FROM `users` WHERE `identifier` = '".. xPlayer.identifier .."'", {}, function (result)
        if result[1].boutique_coin >= tonumber(point) then
            local newpoint = result[1].boutique_coin - tonumber(point)
            MySQL.Async.execute("UPDATE `users` SET `boutique_coin`= '".. newpoint .."' WHERE `identifier` = '".. xPlayer.getIdentifier() .."'", {}, function() end)
            MySQL.Async.fetchAll("SELECT * FROM `users` WHERE `boutique_id` = '".. boutique_id .."'", {}, function (result2)
                local addpoint = result2[1].boutique_coin + tonumber(point)
                local xPlayer2 = ESX.GetPlayerFromIdentifier(result2[1].license)
                PerformHttpRequest(discord_webhook.url, function(err, text, headers) end, 'POST', json.encode({username = "Boutique", content = "Transaction : " .. point .. " crédit(s) de la part de " .. xPlayer.getName() .. " a " .. xPlayer2.getName()}), { ['Content-Type'] = 'application/json' })
                xPlayer2.triggerEvent("Boutique:Notification", "Vous avez recu " .. point .. " crédit(s) de la part de " .. xPlayer.getName())
                MySQL.Async.execute("UPDATE `users` SET `boutique_coin`= '".. addpoint .."' WHERE `boutique_id` = '".. boutique_id .."'", {}, function() end)
            end)
            cb(true)
        else
            cb(false)
        end
    end)
end
end)

RegisterServerEvent('boutique:deltniop')
AddEventHandler('boutique:deltniop', function(point)
    local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer ~= nil then
	local _source = source
    if id_system_l_o_s == "steam" then
        license = xPlayer.getIdentifier()
    elseif id_system_l_o_s == "license" then
        license = ESX.GetIdentifierFromId(source)
    end
	MySQL.Async.fetchAll('SELECT * FROM users WHERE identifier=@identifier', {
        ['@identifier'] = license
	}, function(data)
        local poi = data[1].boutique_coin
        npoint = poi -point

        MySQL.Async.execute('UPDATE `users` SET `boutique_coin`=@point  WHERE identifier=@identifier', {
            ['@identifier'] = license,
            ['@point'] = npoint 
        }, function(rowsChange)
        end)
    end)
end
end)


RegisterServerEvent('give:money')
AddEventHandler('give:money', function(w)
    local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer ~= nil then
	local _source = source
    xPlayer.addMoney(w)
    PerformHttpRequest(discord_webhook.url, function(err, text, headers) end, 'POST', json.encode({username = "", content = xPlayer.getName() .. " à acheter de l'argent boutique."}), { ['Content-Type'] = 'application/json' })
    end
end)

RegisterServerEvent('give:weapon')
AddEventHandler('give:weapon', function(w)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    xPlayer.addInventoryItem(w, 1)
    PerformHttpRequest(discord_webhook.url, function(err, text, headers) end, 'POST', json.encode({username = "", content = xPlayer.getName() .. " à acheter une arme boutique."}), { ['Content-Type'] = 'application/json' })
end)

RegisterServerEvent('give:mun')
AddEventHandler('give:mun', function(w)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    xPlayer.addInventoryItem(w, 25)
    PerformHttpRequest(discord_webhook.url, function(err, text, headers) end, 'POST', json.encode({username = "", content = xPlayer.getName() .. " à acheter des munitions boutique."}), { ['Content-Type'] = 'application/json' })
end)

RegisterServerEvent('give:accessoires')
AddEventHandler('give:accessoires', function(w)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    xPlayer.addInventoryItem(w, 1)
    PerformHttpRequest(discord_webhook.url, function(err, text, headers) end, 'POST', json.encode({username = "", content = xPlayer.getName() .. " à acheter des accessoires boutique."}), { ['Content-Type'] = 'application/json' })
end)

RegisterServerEvent('fBoutique:buycaisse')
AddEventHandler('fBoutique:buycaisse', function(type, item)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if type == 'item' then
        xPlayer.addInventoryItem(item, 1)
    end

    if type == 'money' then
        xPlayer.addMoney(item)
    end
end)


RegisterCommand("givedonate", function(source, args, raw)
    local id    = args[1]
    local point = args[2]
    local xPlayer = ESX.GetPlayerFromId(id)
    if id_system_l_o_s == "steam" then
        license = xPlayer.getIdentifier()
    elseif id_system_l_o_s == "license" then
        license = ESX.GetIdentifierFromId(id)
    end
    if source == 0 then 
        TriggerClientEvent('esx:showAdvancedNotification', id, 'Boutique', '', 'Vous avez reçu vos :\n'..point..' '..moneypoints, "CHAR_DREYFUSS", 3)
        PerformHttpRequest(discord_webhook.url, function(err, text, headers) end, 'POST', json.encode({username = "", content = xPlayer.getName() .. " à bien reçu ses " ..point.. ' BitCoin(s)'}), { ['Content-Type'] = 'application/json' })
        MySQL.Async.fetchAll('SELECT * FROM users WHERE identifier=@identifier', {
            ['@identifier'] = license
        }, function(data)
            local poi = data[1].boutique_coin
            npoint = poi + point
    
            MySQL.Async.execute('UPDATE `users` SET `boutique_coin`=@point  WHERE identifier=@identifier', {
                ['@identifier'] = license,
                ['@point'] = npoint 
            }, function(rowsChange)
            end)
        end)
    else
        print("Tu ne peut pas faire cette commande ici")
    end
end, false)

ESX.RegisterUsableItem('silencieux', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)

    TriggerClientEvent('accesories:silencieux', source)

end)

ESX.RegisterUsableItem('flashlight', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)	
	
    TriggerClientEvent('accesories:flashlight', source)
end)

ESX.RegisterUsableItem('grip', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
		
    TriggerClientEvent('accesories:grip', source)
end)

ESX.RegisterUsableItem('yusuf', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)

    TriggerClientEvent('accesories:yusuf', source)
end)