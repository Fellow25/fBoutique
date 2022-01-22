ESX = nil
local IsDead = false

Citizen.CreateThread(function()
	TriggerServerEvent('boutique:getpoints')
	if pointjoueur == nil then pointjoueur = 0 end
	while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(100)
	end
end)

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        ESX.TriggerServerCallback('boutique:GetCodeBoutique', function(thecode)
            code = thecode
        end)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(2000)
        ESX.TriggerServerCallback('boutique:GetCodeBoutique', function(thecode)
            code = thecode
        end)
    end    
end)

RegisterNetEvent("Boutique:Notification")
AddEventHandler("Boutique:Notification", function(message)
    ESX.ShowNotification("~o~Boutique : " .. message)
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  PlayerData = xPlayer 
end)

local used = 0

fullcustom = false
curentvehicle_name = ""
curentvehicle_model = ""
curentvehicle_finalpoint = 0
local codepromo = false

function OpenBoutique()
    local menu = RageUI.CreateMenu(MenuName, "~g~Salut "..GetPlayerName(PlayerId()))
    local vehiclemenu = RageUI.CreateSubMenu(menu, "Véhicules", "Menu Véhicule")
    local vehiclemenuparam = RageUI.CreateSubMenu(menu, "Paramètres", "Menu Véhicule")
    local armesmenu = RageUI.CreateSubMenu(menu, "Armes", "Menu d'armes")
    local armesmunitions = RageUI.CreateSubMenu(menu, "Armes", "Menu munitions")
    local armesaccessoires = RageUI.CreateSubMenu(menu, "Armes", "Menu accessoires")
    local moneymenu = RageUI.CreateSubMenu(menu, "Argent", "Menu d'argent")
    local caissemenu = RageUI.CreateSubMenu(menu, "Caisse", "Menu caisses")
    menu:SetRectangleBanner(0, 153, 153, 0.8)
	vehiclemenu:SetRectangleBanner(0, 153, 153, 0.8)
	vehiclemenuparam:SetRectangleBanner(0, 153, 153, 0.8)
	armesmenu:SetRectangleBanner(0, 153, 153, 0.8)
	armesmunitions:SetRectangleBanner(0, 153, 153, 0.8)
    armesaccessoires:SetRectangleBanner(0, 153, 153, 0.8)
	moneymenu:SetRectangleBanner(0, 153, 153, 0.8)
	caissemenu:SetRectangleBanner(0, 153, 153, 0.8)
    RageUI.Visible(menu, not RageUI.Visible(menu))
    while menu do
        Citizen.Wait(0)
                RageUI.IsVisible(menu,function()

                    RageUI.Separator("Code boutique : ~r~" .. code)

                    RageUI.Separator("~b~Vous avez ~r~"..pointjoueur.." "..moneypoints, nil, {}, true, function(_, _, _) end)
          
                  if codepromo then
                      RageUI.Separator("Code promo: ~g~Activer")
                  else
                      RageUI.Separator("Code promo: ~r~Desactiver")
                  end

                  RageUI.Button("Entrer le code promo", nil, {RightLabel = "→"}, true , { 
                    onSelected = function()
                        local code_promo = KeyboardInput('PROMO_BOUTIQUE', "Merci d'entrer le code promo", '', 50)
                        if code_promo == lecodepromo then
                            codepromo = true				
                            ESX.ShowNotification("~g~Code promo validé!")
                        else
                            ESX.ShowNotification("~r~Code promo invalide!")
                        end
                    end
                })

                RageUI.Button("Véhicules", nil, {RightLabel = "→"}, true , {
                    onSelected = function()
                    end
                }, vehiclemenu)
        
                RageUI.Button("Armes", nil, {RightLabel = "→"}, true , {
                    onSelected = function()
                    end
                }, armesmenu)
        
                RageUI.Button("Caisses", nil, {RightLabel = "→"}, true , {
                    onSelected = function()
                    end
                }, caissemenu)
        
                RageUI.Button("Argent", nil, {RightLabel = "→"}, true , {
                    onSelected = function()
                    end
                }, moneymenu)

                if donner_point then
                    RageUI.Button("Donner des "..moneypoints, "Donner à sois même = perte de crédit(s)", {}, true, {
                        onSelected = function()
                                local boutique_id = KeyboardInput('ID_BOUTIQUE', "Merci d'entrer l'id boutique de vôtre ami", '', 50)
                                local point = KeyboardInput('ID_BOUTIQUE', "Merci de spécifier le nombre de crédit(s) que vous souhaitez donner", '', 50)
                                ESX.TriggerServerCallback('Boutique:DonnePoint', function(callback)
                                    if callback then
                                       ESX.ShowNotification("~g~Transfert reussi !")
                                    else
                                        ESX.ShowNotification("~r~Vous n'avez pas assez de crédit(s) !")
                                    end
                                end, point, boutique_id)
                            end
                        })
                    end
                
            end)

            RageUI.IsVisible(vehiclemenu,function()

                if codepromo then
                    RageUI.Separator("Code promo ~g~activer~s~, réduction de ~g~"..100 - taxe.."%")
                else
                    RageUI.Separator("~r~Aucun code promo est activer")
                end
                
                for k, itemv in pairs(item_vehicule) do
                    RageUI.Button(itemv.name, nil, { RightLabel = "~r~"..tostring(itemv.point).." ~b~"..moneypoints },true, {
                        onSelected = function()
                            curentvehicle_name = itemv.name
                            curentvehicle_model = itemv.model
                            curentvehicle_point = itemv.point
                            curentvehicle_place = itemv.place
                            curentvehicle_vitesse = itemv.vitesse
                            if codepromo then
                            curentvehicle_finalpoint = itemv.point * reduction
                            else
                            curentvehicle_finalpoint = itemv.point
                            end
                        end
                    }, vehiclemenuparam)
                end

            end)

            RageUI.IsVisible(vehiclemenuparam,function()

            if curentvehicle_vitesse ~= nil and curentvehicle_place ~= nil and curentvehicle_name then
                
                RageUI.Separator("Véhicule : ~b~"..curentvehicle_name )

                RageUI.Separator("~o~Vitesse max : ~s~"..curentvehicle_vitesse )
            
                RageUI.Separator("~o~Nombre de siège : ~s~".. curentvehicle_place )
            end

            RageUI.Button("Essayer le véhicule", "Permet d'essayer le véhicule 20 secondes", {}, true , {
				onSelected = function()
				 	posessaie = GetEntityCoords(PlayerPedId())
					Wait(500)
					spawnuniCar(curentvehicle_model)
				end
			})

            RageUI.Checkbox("Full custom",nil, service,{},function(Hovered,Ative,Selected,Checked)
                if Selected then
                    service = Checked
					if codepromo then
						if Checked then
                            fullcustom = true
							curentvehicle_finalpoint_calcul = curentvehicle_point + customprice
							curentvehicle_finalpoint = curentvehicle_finalpoint_calcul * reduction
						else                         
							fullcustom = false
							curentvehicle_finalpoint = curentvehicle_point * reduction
						end
					else
						if Checked then
							fullcustom = true
							curentvehicle_finalpoint = curentvehicle_point + customprice
						else                         
							fullcustom = false
							curentvehicle_finalpoint = curentvehicle_point
                    end
                end
                end
            end)

			RageUI.Button("~b~Acheter", nil, {RightLabel = ""}, true, {
				onSelected = function()
					if pointjoueur >= curentvehicle_finalpoint then
						give_vehi(curentvehicle_model)
						buying(curentvehicle_finalpoint)
					else
						ESX.ShowNotification("~r~Vous n'avez pas assez de fond pour acheter ceci !")
					end
				end
			})

			RageUI.Separator("Cout de l'achat: ~r~"..curentvehicle_finalpoint.." ~g~"..moneypoints, nil, {}, true, function(_, _, _) end)

        end)

        RageUI.IsVisible(armesmenu,function()

            if codepromo then
				RageUI.Separator("Code promo ~g~activer~s~, réduction de ~g~"..100 - taxe.."%")
			else
				RageUI.Separator("~r~Aucun code promo est activer")
			end

			RageUI.Button("Accessoires", nil, {RightLabel = "→"}, true , {
				onSelected = function()
				end
			}, armesaccessoires)

			RageUI.Button("Munitions", nil, {RightLabel = "→"}, true , {
				onSelected = function()
				end
			}, armesmunitions)

			for k, itemar in pairs(item_arme) do
				RageUI.Button(itemar.name, nil, {RightLabel = "~r~"..tostring(itemar.point).." ~b~"..moneypoints}, true, {
					onSelected = function()

						curentvehicle_name = itemar.name
						curentvehicle_model = itemar.model
						curentvehicle_point = itemar.point
						if codepromo then
						curentvehicle_finalpoint = itemar.point * reduction
						else
						curentvehicle_finalpoint = itemar.point
						end
						if pointjoueur >= curentvehicle_finalpoint then
							buying(curentvehicle_finalpoint)
							garme(curentvehicle_model, curentvehicle_name)
						else
							ESX.ShowNotification("~r~Vous n'avez pas assez de fond pour acheter ceci !")
						end
					end
					})
				end

            end)

            RageUI.IsVisible(armesaccessoires,function()

                if codepromo then
                    RageUI.Separator("Code promo ~g~activer~s~, réduction de ~g~"..100 - taxe.."%")
                else
                    RageUI.Separator("~r~Aucun code promo est activer")
                end
    
            for k, itemaccessoires in pairs(item_accessoires) do
                RageUI.Button(itemaccessoires.name, nil, {RightLabel = "~r~"..tostring(itemaccessoires.point).." ~b~"..moneypoints}, true, {
                    onSelected = function()
    
                        curentvehicle_name = itemaccessoires.name
                        curentvehicle_model = itemaccessoires.model
                        curentvehicle_point = itemaccessoires.point
                        if codepromo then
                        curentvehicle_finalpoint = itemaccessoires.point * reduction
                        else
                        curentvehicle_finalpoint = itemaccessoires.point
                        end
    
                        if pointjoueur >= curentvehicle_finalpoint then
                            buying(curentvehicle_finalpoint)
                            garme_accessoires(curentvehicle_model, curentvehicle_name)
                        else
                            ESX.ShowNotification("~r~Vous n'avez pas assez de fond pour acheter ceci !")
                        end
                    end
                })

            end
            end)

            RageUI.IsVisible(armesmunitions,function()

                if codepromo then
                    RageUI.Separator("Code promo ~g~activer~s~, réduction de ~g~"..100 - taxe.."%")
                else
                    RageUI.Separator("~r~Aucun code promo est activer")
                end
    
    
                for k, itemmun in pairs(item_mun) do
                    RageUI.Button(itemmun.name, nil, {RightLabel = "~r~"..tostring(itemmun.point).." ~b~"..moneypoints}, true , {
                        onSelected = function()
    
                            curentvehicle_name = itemmun.name
                            curentvehicle_model = itemmun.model
                            curentvehicle_point = itemmun.point
                            if codepromo then
                            curentvehicle_finalpoint = itemmun.point * reduction
                            else
                            curentvehicle_finalpoint = itemmun.point
                            end
    
                            if pointjoueur >= curentvehicle_finalpoint then
                                buying(curentvehicle_finalpoint)
                                garme_mun(curentvehicle_model, curentvehicle_name)
                            else
                                ESX.ShowNotification("~r~Vous n'avez pas assez de fond pour acheter ceci !")
                            end
                    end
                })

            end
        end)

		RageUI.IsVisible(caissemenu,function()

            if codepromo then
				RageUI.Separator("Code promo ~g~activer~s~, réduction de ~g~"..100 - taxe.."%")
			else
				RageUI.Separator("~r~Aucun code promo est activer")
			end

			for k, caisse in pairs(LesCaisse) do
				RageUI.Button(caisse.name, nil, {RightLabel = "~r~"..tostring(caisse.point).." ~b~"..moneypoints}, true , {
					onSelected = function()
                        local casewin = ""
						curentvehicle_name = caisse.name
						curentvehicle_model = caisse.contenue
						if codepromo then
						curentvehicle_finalpoint = caisse.point * reduction
						else
						curentvehicle_finalpoint = caisse.point
						end
						for _,v in pairs(caisse.contenue) do
                            casewin = v
					    end
                        if pointjoueur >= curentvehicle_finalpoint then
							buying(curentvehicle_finalpoint)
							BuyCaisse(casewin.itemtype, casewin.itemname, caisse.name)
						else
							ESX.ShowNotification("~r~Vous n'avez pas assez de fond pour acheter ceci !")
						end
				    end
				})

            end 
            
				RageUI.Button("Caisse aléatoire", nil, {RightLabel = "?"}, true , {
					onSelected = function()
					    local caissealeatoire = math.random(1,#LesCaisse)
                        local casewin = ""
						curentvehicle_name = LesCaisse[caissealeatoire].name
						curentvehicle_model = LesCaisse[caissealeatoire].contenue
						if codepromo then
						    curentvehicle_finalpoint = LesCaisse[caissealeatoire].point * reduction
						else
						    curentvehicle_finalpoint = LesCaisse[caissealeatoire].point
						end
						for _,v in pairs(curentvehicle_model) do
                            casewin = v                        
					    end
                        if pointjoueur >= curentvehicle_finalpoint then
                            buying(curentvehicle_finalpoint)
                            BuyCaisse(casewin.itemtype, casewin.itemname, curentvehicle_name)
                        else
                            ESX.ShowNotification("~r~Vous n'avez pas assez de fond pour acheter ceci !")
                        end
				    end
                    })

            end)

            RageUI.IsVisible(moneymenu,function()

                if codepromo then
                    RageUI.Separator("Code promo ~g~activer~s~, réduction de ~g~"..100 - taxe.."%")
                else
                    RageUI.Separator("~r~Aucun code promo est activer")
                end
    
                for k, itemmoy in pairs(item_money) do
                    RageUI.Button(itemmoy.name, nil, {RightLabel = "~r~"..tostring(itemmoy.point).." ~b~"..moneypoints}, true , {
                        onSelected = function()
    
                            curentvehicle_name = itemmoy.name
                            curentvehicle_model = itemmoy.model
                            curentvehicle_point = itemmoy.point
                            if codepromo then
                            curentvehicle_finalpoint = itemmoy.point * reduction
                            else
                            curentvehicle_finalpoint = itemmoy.point
                            end
                            if pointjoueur >= curentvehicle_finalpoint then
                                buying(curentvehicle_finalpoint)
                                gmoney(curentvehicle_model, curentvehicle_name)
                            else
                                ESX.ShowNotification("~r~Vous n'avez pas assez de fond pour acheter ceci !")
                            end
                        end
                    })

                end
            

            end, function()
            end)
        if not RageUI.Visible(menu) and not RageUI.Visible(vehiclemenu) and not RageUI.Visible(vehiclemenuparam) and not RageUI.Visible(armesmenu) and not RageUI.Visible(armesmunitions) and not RageUI.Visible(armesaccessoires) and not RageUI.Visible(moneymenu) and not RageUI.Visible(caissemenu) then
            menu = RMenu:DeleteType("menu", true)
        end
        end
        end

        Keys.Register('F11', 'Boutique', 'Ouvrir le menu boutique', function()
            TriggerServerEvent('boutique:getpoints')
            OpenBoutique()
    end)
    
    function spawnuniCar(car)
        local car = GetHashKey(car)
        RequestModel(car)
        while not HasModelLoaded(car) do
            RequestModel(car)
            Citizen.Wait(0)
        end
        local x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(-1), false))
        local vehicle = CreateVehicle(car, -899.62, -3298.74, 13.94, 58.0, true, false)
        if fullcustom == true then
            FullVehicleBoost(vehicle)
        end
        SetEntityAsMissionEntity(vehicle, true, true) 
        SetPedIntoVehicle(GetPlayerPed(-1),vehicle,-1)
        SetVehicleDoorsLocked(vehicle, 4)
        ESX.ShowNotification("Vous avez 20 secondes pour tester le véhicule.")
        local timer = 20
        local breakable = false
        breakable = false
        while not breakable do
            Wait(1000)
            timer = timer - 1
            if timer == 10 then
                ESX.ShowNotification("Il vous reste plus que 10 secondes.")
            end
            if timer == 5 then
                ESX.ShowNotification("Il vous reste plus que 5 secondes.")
            end
            if timer <= 0 then
                local veh,dist4 = ESX.Game.GetClosestVehicle(playerCoords)
                DeleteEntity(vehicle)
                ESX.ShowNotification("~r~Vous avez terminé la période d'essai.")
                SetEntityCoords(PlayerPedId(), posessaie)
                breakable = true
                break
            end
        end
    end
    
    function buying(point)
        if pointjoueur >= point then
            TriggerServerEvent('boutique:deltniop', point)
            Citizen.Wait(300)
            TriggerServerEvent('boutique:getpoints')
        else
            TriggerEvent('esx:showNotification', '~r~Tu ne peut pas acheter cet article.')
        end
    end
    
    RegisterNetEvent('boutique:retupoints')
    AddEventHandler('boutique:retupoints', function(point)
        pointjoueur = point
    end)
    
    
    local voituregive = {}
    
    function give_vehi(veh)
        TriggerEvent('esx:showAdvancedNotification', 'Boutique', '', 'Vous avez reçu votre :\n '..veh, img_notif, 3)
        local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
        
        Citizen.Wait(10)
        ESX.Game.SpawnVehicle(veh, {x = plyCoords.x+2 ,y = plyCoords.y, z = plyCoords.z+2}, 313.4216, function (vehicle)
            if fullcustom == true then
                FullVehicleBoost(vehicle)
            end
                local plate = exports.fCore:GeneratePlate()
                table.insert(voituregive, vehicle)		
                print(plate)
                local vehicleProps = ESX.Game.GetVehicleProperties(voituregive[#voituregive])
                vehicleProps.plate = plate
                SetVehicleNumberPlateText(voituregive[#voituregive] , plate)
                TriggerServerEvent('shop:vehiculeboutique', vehicleProps, plate)
        end)
    end
    
    
    function garme(w,n)
        TriggerEvent('esx:showAdvancedNotification', '~o~Boutique', '', 'Vous avez reçu votre :\n'..n, img_notif, 3)
        TriggerServerEvent('give:weapon', w)
    end
    
    function garme_mun(w,n)
        TriggerEvent('esx:showAdvancedNotification', '~o~Boutique', '', 'Vous avez reçu votre :\n'..n, img_notif, 3)
        TriggerServerEvent('give:mun', w)
    end
    
    function garme_accessoires(w,n)
        TriggerEvent('esx:showAdvancedNotification', '~o~Boutique', '', 'Vous avez reçu votre :\n'..n, img_notif, 3)
        TriggerServerEvent('give:accessoires', w)
    end
    
    function gmoney(w,n)
        TriggerEvent('esx:showAdvancedNotification', '~o~Boutique', '', 'Vous avez reçu vos :\n'..n, img_notif, 3)
        TriggerServerEvent('give:money', w)
    end
    
    function BuyCaisse(type, name, label)
        TriggerEvent('esx:showAdvancedNotification', 'Boutique', '', 'Vous avez reçu votre :\n '..label, img_notif, 3)
        if type == 'car' then
            local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
            Citizen.Wait(10)
            ESX.Game.SpawnVehicle(name, {x = plyCoords.x+2 ,y = plyCoords.y, z = plyCoords.z+2}, 313.4216, function (vehicle)
                    local plate = exports.fCore:GeneratePlate()
                    table.insert(voituregive, vehicle)		
                    print(plate)
                    local vehicleProps = ESX.Game.GetVehicleProperties(voituregive[#voituregive])
                    vehicleProps.plate = plate
                    SetVehicleNumberPlateText(voituregive[#voituregive] , plate)
                    TriggerServerEvent('shop:vehiculeboutique', vehicleProps, plate)
            end)
        end
    
        if type == 'item' then
            TriggerServerEvent('fBoutique:buycaisse', type, name)
        end
    
        if type == 'money' then
            TriggerServerEvent('fBoutique:buycaisse', type, name)
        end
    end
    
    function FullVehicleBoost(vehicle)
        SetVehicleModKit(vehicle, 0)
        SetVehicleMod(vehicle, 14, 0, true)
        SetVehicleNumberPlateTextIndex(vehicle, 5)
        ToggleVehicleMod(vehicle, 18, true)
        SetVehicleColours(vehicle, 0, 0)
        SetVehicleModColor_2(vehicle, 5, 0)
        SetVehicleExtraColours(vehicle, 111, 111)
        SetVehicleWindowTint(vehicle, 2)
        ToggleVehicleMod(vehicle, 22, true)
        SetVehicleMod(vehicle, 23, 11, false)
        SetVehicleMod(vehicle, 24, 11, false)
        SetVehicleWheelType(vehicle, 120)
        SetVehicleWindowTint(vehicle, 3)
        ToggleVehicleMod(vehicle, 20, true)
        SetVehicleTyreSmokeColor(vehicle, 0, 0, 0)
        LowerConvertibleRoof(vehicle, true)
        SetVehicleIsStolen(vehicle, false)
        SetVehicleIsWanted(vehicle, false)
        SetVehicleHasBeenOwnedByPlayer(vehicle, true)
        SetVehicleNeedsToBeHotwired(vehicle, false)
        SetCanResprayVehicle(vehicle, true)
        SetPlayersLastVehicle(vehicle)
        SetVehicleFixed(vehicle)
        SetVehicleDeformationFixed(vehicle)
        SetVehicleTyresCanBurst(vehicle, false)
        SetVehicleWheelsCanBreak(vehicle, false)
        SetVehicleCanBeTargetted(vehicle, false)
        SetVehicleExplodesOnHighExplosionDamage(vehicle, false)
        SetVehicleHasStrongAxles(vehicle, true)
        SetVehicleDirtLevel(vehicle, 0)
        SetVehicleCanBeVisiblyDamaged(vehicle, false)
        IsVehicleDriveable(vehicle, true)
        SetVehicleEngineOn(vehicle, true, true)
        SetVehicleStrong(vehicle, true)
        RollDownWindow(vehicle, 0)
        RollDownWindow(vehicle, 1)
        
        SetPedCanBeDraggedOut(PlayerPedId(), false)
        SetPedStayInVehicleWhenJacked(PlayerPedId(), true)
        SetPedRagdollOnCollision(PlayerPedId(), false)
        ResetPedVisibleDamage(PlayerPedId())
        ClearPedDecorations(PlayerPedId())
        SetIgnoreLowPriorityShockingEvents(PlayerPedId(), true)
    end
    
    function Notify(text)
        SetNotificationTextEntry('STRING')
        AddTextComponentString(text)
        DrawNotification(false, true)
    end
    
    function drawNotification(text)
        SetNotificationTextEntry("STRING")
        AddTextComponentString(text)
        DrawNotification(false, false)
    end
    
    RegisterNetEvent('accesories:silencieux')
    AddEventHandler('accesories:silencieux', function(duration)
        local inventory = ESX.GetPlayerData().inventory
        local silencieux = 0
    
            for i=1, #inventory, 1 do
              if inventory[i].name == 'silencieux' then
                silencieux = inventory[i].count
              end
            end
    
    local ped = PlayerPedId()
    local currentWeaponHash = GetSelectedPedWeapon(ped)
    
            if used < silencieux then
                if currentWeaponHash == GetHashKey("WEAPON_PISTOL") then
                       GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_PISTOL"), GetHashKey("component_at_pi_supp_02"))  
                       ESX.ShowNotification(("Vous venez de vous équiper d'un silencieux. Il faudra le rééquiper a chaques retours en ville.")) 
                           used = used + 1
    
                  elseif currentWeaponHash == GetHashKey("WEAPON_PISTOL50") then
                       GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_PISTOL50"), GetHashKey("COMPONENT_AT_AR_SUPP_02"))  
                       ESX.ShowNotification(("Vous venez de vous équiper d'un silencieux. Il faudra le rééquiper a chaques retours en ville.")) 
                          used = used + 1
    
    
                  elseif currentWeaponHash == GetHashKey("WEAPON_COMBATPISTOL") then
                       GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_COMBATPISTOL"), GetHashKey("COMPONENT_AT_PI_SUPP"))  
                       ESX.ShowNotification(("Vous venez de vous équiper d'un silencieux. Il faudra le rééquiper a chaques retours en ville.")) 
                        used = used + 1
    
                  elseif currentWeaponHash == GetHashKey("WEAPON_APPISTOL") then
                       GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_APPISTOL"), GetHashKey("COMPONENT_AT_PI_SUPP"))  
                       ESX.ShowNotification(("Vous venez de vous équiper d'un silencieux. Il faudra le rééquiper a chaques retours en ville.")) 
                           used = used + 1
    
                  elseif currentWeaponHash == GetHashKey("WEAPON_HEAVYPISTOL") then
                       GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_HEAVYPISTOL"), GetHashKey("COMPONENT_AT_PI_SUPP"))  
                       ESX.ShowNotification(("Vous venez de vous équiper d'un silencieux. Il faudra le rééquiper a chaques retours en ville.")) 
                          used = used + 1
    
                  elseif currentWeaponHash == GetHashKey("WEAPON_VINTAGEPISTOL") then
                       GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_VINTAGEPISTOL"), GetHashKey("COMPONENT_AT_PI_SUPP"))  
                       ESX.ShowNotification(("Vous venez de vous équiper d'un silencieux. Il faudra le rééquiper a chaques retours en ville."))
                            used = used + 1
    
                  elseif currentWeaponHash == GetHashKey("WEAPON_SMG") then
                       GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_SMG"), GetHashKey("COMPONENT_AT_PI_SUPP"))  
                       ESX.ShowNotification(("Vous venez de vous équiper d'un silencieux. Il faudra le rééquiper a chaques retours en ville.")) 
                           used = used + 1
    
    
                  elseif currentWeaponHash == GetHashKey("WEAPON_MICROSMG") then
                       GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_MICROSMG"), GetHashKey("COMPONENT_AT_AR_SUPP_02"))  
                       ESX.ShowNotification(("Vous venez de vous équiper d'un silencieux. Il faudra le rééquiper a chaques retours en ville.")) 
        used = used + 1
                    
    
                  elseif currentWeaponHash == GetHashKey("WEAPON_ASSAULTSMG") then
                       GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_ASSAULTSMG"), GetHashKey("COMPONENT_AT_AR_SUPP_02"))  
                       ESX.ShowNotification(("Vous venez de vous équiper d'un silencieux. Il faudra le rééquiper a chaques retours en ville.")) 
        used = used + 1
                      
    
                  elseif currentWeaponHash == GetHashKey("WEAPON_ASSAULTRIFLE") then
                       GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_ASSAULTRIFLE"), GetHashKey("COMPONENT_AT_AR_SUPP_02"))  
                       ESX.ShowNotification(("Vous venez de vous équiper d'un silencieux. Il faudra le rééquiper a chaques retours en ville.")) 
        used = used + 1
                      
                  elseif currentWeaponHash == GetHashKey("WEAPON_CARBINERIFLE") then
                       GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_CARBINERIFLE"), GetHashKey("COMPONENT_AT_AR_SUPP"))  
                       ESX.ShowNotification(("Vous venez de vous équiper d'un silencieux. Il faudra le rééquiper a chaques retours en ville.")) 
        used = used + 1
                      
                  elseif currentWeaponHash == GetHashKey("WEAPON_ADVANCEDRIFLE") then
                       GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_ADVANCEDRIFLE"), GetHashKey("COMPONENT_AT_AR_SUPP"))  
                       ESX.ShowNotification(("Vous venez de vous équiper d'un silencieux. Il faudra le rééquiper a chaques retours en ville.")) 
        used = used + 1
                      
                  elseif currentWeaponHash == GetHashKey("WEAPON_SPECIALCARBINE") then
                       GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_SPECIALCARBINE"), GetHashKey("COMPONENT_AT_AR_SUPP_02"))  
                       ESX.ShowNotification(("Vous venez de vous équiper d'un silencieux. Il faudra le rééquiper a chaques retours en ville.")) 
        used = used + 1
                      
                  elseif currentWeaponHash == GetHashKey("WEAPON_BULLPUPRIFLE") then
                       GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_BULLPUPRIFLE"), GetHashKey("COMPONENT_AT_AR_SUPP"))  
                       ESX.ShowNotification(("Vous venez de vous équiper d'un silencieux. Il faudra le rééquiper a chaques retours en ville.")) 
        used = used + 1
                      
                  elseif currentWeaponHash == GetHashKey("WEAPON_ASSAULTSHOTGUN") then
                       GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_ASSAULTSHOTGUN"), GetHashKey("COMPONENT_AT_AR_SUPP"))  
                       ESX.ShowNotification(("Vous venez de vous équiper d'un silencieux. Il faudra le rééquiper a chaques retours en ville.")) 
        used = used + 1
                      
                  elseif currentWeaponHash == GetHashKey("WEAPON_HEAVYSHOTGUN") then
                       GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_HEAVYSHOTGUN"), GetHashKey("COMPONENT_AT_AR_SUPP_02"))  
                       ESX.ShowNotification(("Vous venez de vous équiper d'un silencieux. Il faudra le rééquiper a chaques retours en ville.")) 
        used = used + 1
                      
                  elseif currentWeaponHash == GetHashKey("WEAPON_BULLPUPSHOTGUN") then
                       GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_BULLPUPSHOTGUN"), GetHashKey("COMPONENT_AT_AR_SUPP_02"))  
                       ESX.ShowNotification(("Vous venez de vous équiper d'un silencieux. Il faudra le rééquiper a chaques retours en ville.")) 
        used = used + 1
                       
                  elseif currentWeaponHash == GetHashKey("WEAPON_PUMPSHOTGUN") then
                       GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_PUMPSHOTGUN"), GetHashKey("COMPONENT_AT_SR_SUPP"))  
                       ESX.ShowNotification(("Vous venez de vous équiper d'un silencieux. Il faudra le rééquiper a chaques retours en ville.")) 
        used = used + 1
    
                  elseif currentWeaponHash == GetHashKey("WEAPON_MARKSMANRIFLE") then
                       GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_MARKSMANRIFLE"), GetHashKey("COMPONENT_AT_AR_SUPP"))  
                       ESX.ShowNotification(("Vous venez de vous équiper d'un silencieux. Il faudra le rééquiper a chaques retours en ville.")) 
        used = used + 1
    
                  elseif currentWeaponHash == GetHashKey("WEAPON_SNIPERRIFLE") then
                       GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_SNIPERRIFLE"), GetHashKey("COMPONENT_AT_AR_SUPP_02"))  
                       ESX.ShowNotification(("Vous venez de vous équiper d'un silencieux. Il faudra le rééquiper a chaques retours en ville.")) 
        used = used + 1
    
                  else 
                        ESX.ShowNotification(("Vous n'avez pas d'arme en main ou votre arme ne peux pas supporter de silencieux."))	
                end
                else
                                   ESX.ShowNotification(("Vous avez utiliser tout vos silencieux.")) 
            end
    end)
                    local used2 = 0
    
    RegisterNetEvent('accesories:flashlight')
    AddEventHandler('accesories:flashlight', function(duration)
                        local inventory = ESX.GetPlayerData().inventory
                    local flashlight = 0
                        for i=1, #inventory, 1 do
                          if inventory[i].name == 'flashlight' then
                            flashlight = inventory[i].count
                          end
                        end
    
    local ped = PlayerPedId()
    local currentWeaponHash = GetSelectedPedWeapon(ped)
    
            if used2 < flashlight then
                if currentWeaponHash == GetHashKey("WEAPON_PISTOL") then
                       GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_PISTOL"), GetHashKey("COMPONENT_AT_PI_FLSH"))  
                       ESX.ShowNotification(("Vous venez de vous équiper d'un lampe. Il faudra le rééquiper a chaques retours en ville.")) 
                           used2 = used2 + 1
    
                  elseif currentWeaponHash == GetHashKey("WEAPON_PISTOL50") then
                       GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_PISTOL50"), GetHashKey("COMPONENT_AT_PI_FLSH"))  
                       ESX.ShowNotification(("Vous venez de vous équiper d'un lampe. Il faudra le rééquiper a chaques retours en ville.")) 
        used2 = used2 + 1
    
                  elseif currentWeaponHash == GetHashKey("WEAPON_COMBATPISTOL") then
                       GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_COMBATPISTOL"), GetHashKey("COMPONENT_AT_PI_FLSH"))  
                       ESX.ShowNotification(("Vous venez de vous équiper d'un lampe. Il faudra le rééquiper a chaques retours en ville.")) 
        used2 = used2 + 1
    
                  elseif currentWeaponHash == GetHashKey("WEAPON_APPISTOL") then
                       GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_APPISTOL"), GetHashKey("COMPONENT_AT_PI_FLSH"))  
                       ESX.ShowNotification(("Vous venez de vous équiper d'un lampe. Il faudra le rééquiper a chaques retours en ville.")) 
        used2 = used2 + 1
    
                  elseif currentWeaponHash == GetHashKey("WEAPON_HEAVYPISTOL") then
                       GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_HEAVYPISTOL"), GetHashKey("COMPONENT_AT_PI_FLSH"))  
                       ESX.ShowNotification(("Vous venez de vous équiper d'un lampe. Il faudra le rééquiper a chaques retours en ville.")) 
        used2 = used2 + 1
    
                  elseif currentWeaponHash == GetHashKey("WEAPON_SMG") then
                       GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_SMG"), GetHashKey("COMPONENT_AT_AR_FLSH"))  
                       ESX.ShowNotification(("Vous venez de vous équiper d'un lampe. Il faudra le rééquiper a chaques retours en ville.")) 
                           used2 = used2 + 1
    
                  elseif currentWeaponHash == GetHashKey("WEAPON_MICROSMG") then
                       GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_MICROSMG"), GetHashKey("COMPONENT_AT_PI_FLSH"))  
                       ESX.ShowNotification(("Vous venez de vous équiper d'un lampe. Il faudra le rééquiper a chaques retours en ville.")) 
        used2 = used2 + 1
    
                  elseif currentWeaponHash == GetHashKey("WEAPON_ASSAULTSMG") then
                       GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_ASSAULTSMG"), GetHashKey("COMPONENT_AT_AR_FLSH"))  
                       ESX.ShowNotification(("Vous venez de vous équiper d'un lampe. Il faudra le rééquiper a chaques retours en ville.")) 
        used2 = used2 + 1
     
                  elseif currentWeaponHash == GetHashKey("WEAPON_COMBATPDW") then
                       GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_COMBATPDW"), GetHashKey("COMPONENT_AT_AR_FLSH"))  
                       ESX.ShowNotification(("Vous venez de vous équiper d'un lampe. Il faudra le rééquiper a chaques retours en ville.")) 
        used2 = used2 + 1	
    
                  elseif currentWeaponHash == GetHashKey("WEAPON_ASSAULTRIFLE") then
                       GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_ASSAULTRIFLE"), GetHashKey("COMPONENT_AT_AR_FLSH"))  
                       ESX.ShowNotification(("Vous venez de vous équiper d'un lampe. Il faudra le rééquiper a chaques retours en ville.")) 
        used2 = used2 + 1
                      
                  elseif currentWeaponHash == GetHashKey("WEAPON_CARBINERIFLE") then
                       GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_CARBINERIFLE"), GetHashKey("COMPONENT_AT_AR_FLSH"))  
                       ESX.ShowNotification(("Vous venez de vous équiper d'un lampe. Il faudra le rééquiper a chaques retours en ville.")) 
        used2 = used2 + 1
                      
                  elseif currentWeaponHash == GetHashKey("WEAPON_ADVANCEDRIFLE") then
                       GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_ADVANCEDRIFLE"), GetHashKey("COMPONENT_AT_AR_FLSH"))  
                       ESX.ShowNotification(("Vous venez de vous équiper d'un lampe. Il faudra le rééquiper a chaques retours en ville.")) 
        used2 = used2 + 1
                      
                  elseif currentWeaponHash == GetHashKey("WEAPON_SPECIALCARBINE") then
                       GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_SPECIALCARBINE"), GetHashKey("COMPONENT_AT_AR_FLSH"))  
                       ESX.ShowNotification(("Vous venez de vous équiper d'un lampe. Il faudra le rééquiper a chaques retours en ville.")) 
        used2 = used2 + 1
    
                  elseif currentWeaponHash == GetHashKey("WEAPON_BULLPUPRIFLE") then
                       GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_BULLPUPRIFLE"), GetHashKey("COMPONENT_AT_AR_FLSH"))  
                       ESX.ShowNotification(("Vous venez de vous équiper d'un lampe. Il faudra le rééquiper a chaques retours en ville.")) 
        used2 = used2 + 1
    
                  elseif currentWeaponHash == GetHashKey("WEAPON_ASSAULTSHOTGUN") then
                       GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_ASSAULTSHOTGUN"), GetHashKey("COMPONENT_AT_AR_FLSH"))  
                       ESX.ShowNotification(("Vous venez de vous équiper d'un lampe. Il faudra le rééquiper a chaques retours en ville.")) 
        used2 = used2 + 1
                      
                  elseif currentWeaponHash == GetHashKey("WEAPON_HEAVYSHOTGUN") then
                       GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_HEAVYSHOTGUN"), GetHashKey("COMPONENT_AT_AR_FLSH"))  
                       ESX.ShowNotification(("Vous venez de vous équiper d'un lampe. Il faudra le rééquiper a chaques retours en ville.")) 
        used2 = used2 + 1
                      
                  elseif currentWeaponHash == GetHashKey("WEAPON_BULLPUPSHOTGUN") then
                       GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_BULLPUPSHOTGUN"), GetHashKey("COMPONENT_AT_AR_FLSH"))  
                       ESX.ShowNotification(("Vous venez de vous équiper d'un lampe. Il faudra le rééquiper a chaques retours en ville.")) 
        used2 = used2 + 1
                       
                  elseif currentWeaponHash == GetHashKey("WEAPON_PUMPSHOTGUN") then
                       GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_PUMPSHOTGUN"), GetHashKey("COMPONENT_AT_AR_FLSH"))  
                       ESX.ShowNotification(("Vous venez de vous équiper d'un lampe. Il faudra le rééquiper a chaques retours en ville.")) 
        used2 = used2 + 1
                      
                  elseif currentWeaponHash == GetHashKey("WEAPON_MARKSMANRIFLE") then
                       GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_MARKSMANRIFLE"), GetHashKey("COMPONENT_AT_AR_FLSH"))  
                       ESX.ShowNotification(("Vous venez de vous équiper d'un lampe. Il faudra le rééquiper a chaques retours en ville.")) 
        used2 = used2 + 1
    
                  else 
                        ESX.ShowNotification(("Vous n'avez pas d'arme en main ou votre arme ne peux pas supporter de lampe."))
                end
            else
                      ESX.ShowNotification(("Vous avez utiliser toutes vos lampes."))
            end
    end)
    
    local used3 = 0
    
    RegisterNetEvent('accesories:grip')
    AddEventHandler('accesories:grip', function(duration)
        local inventory = ESX.GetPlayerData().inventory
        local grip = 0
            for i=1, #inventory, 1 do
              if inventory[i].name == 'grip' then
                grip = inventory[i].count
              end
            end
    
    local ped = PlayerPedId()
    local currentWeaponHash = GetSelectedPedWeapon(ped)
    
            if used3 < grip then
                if currentWeaponHash == GetHashKey("WEAPON_COMBATPDW") then
                       GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_COMBATPDW"), GetHashKey("COMPONENT_AT_AR_AFGRIP"))  
                       ESX.ShowNotification(("Vous venez de vous équiper d'une poignée. Il faudra le rééquiper a chaques retours en ville.")) 
                              used3 = used3 + 1
    
                  elseif currentWeaponHash == GetHashKey("WEAPON_ASSAULTRIFLE") then
                       GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_ASSAULTRIFLE"), GetHashKey("COMPONENT_AT_AR_AFGRIP"))  
                       ESX.ShowNotification(("Vous venez de vous équiper d'une poignée. Il faudra le rééquiper a chaques retours en ville.")) 
        used3 = used3 + 1
                  elseif currentWeaponHash == GetHashKey("WEAPON_CARBINERIFLE") then
                       GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_CARBINERIFLE"), GetHashKey("COMPONENT_AT_AR_AFGRIP"))  
                       ESX.ShowNotification(("Vous venez de vous équiper d'une poignée. Il faudra le rééquiper a chaques retours en ville.")) 
        used3 = used3 + 1	
    
                  elseif currentWeaponHash == GetHashKey("WEAPON_SPECIALCARBINE") then
                       GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_SPECIALCARBINE"), GetHashKey("COMPONENT_AT_AR_AFGRIP"))  
                       ESX.ShowNotification(("Vous venez de vous équiper d'une poignée. Il faudra le rééquiper a chaques retours en ville.")) 
        used3 = used3 + 1
    
                  elseif currentWeaponHash == GetHashKey("WEAPON_BULLPUPRIFLE") then
                       GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_BULLPUPRIFLE"), GetHashKey("COMPONENT_AT_AR_AFGRIP"))  
                       ESX.ShowNotification(("Vous venez de vous équiper d'une poignée. Il faudra le rééquiper a chaques retours en ville.")) 
        used3 = used3 + 1
    
                  elseif currentWeaponHash == GetHashKey("WEAPON_ASSAULTSHOTGUN") then
                       GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_ASSAULTSHOTGUN"), GetHashKey("COMPONENT_AT_AR_AFGRIP"))  
                       ESX.ShowNotification(("Vous venez de vous équiper d'une poignée. Il faudra le rééquiper a chaques retours en ville.")) 
        used3 = used3 + 1
    
                  elseif currentWeaponHash == GetHashKey("WEAPON_HEAVYSHOTGUN") then
                       GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_HEAVYSHOTGUN"), GetHashKey("COMPONENT_AT_AR_AFGRIP"))  
                       ESX.ShowNotification(("Vous venez de vous équiper d'une poignée. Il faudra le rééquiper a chaques retours en ville.")) 
        used3 = used3 + 1
    
                  elseif currentWeaponHash == GetHashKey("WEAPON_BULLPUPSHOTGUN") then
                       GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_BULLPUPSHOTGUN"), GetHashKey("COMPONENT_AT_AR_AFGRIP"))  
                       ESX.ShowNotification(("Vous venez de vous équiper d'une poignée. Il faudra le rééquiper a chaques retours en ville.")) 
        used3 = used3 + 1
    
                  elseif currentWeaponHash == GetHashKey("WEAPON_MARKSMANRIFLE") then
                       GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_MARKSMANRIFLE"), GetHashKey("COMPONENT_AT_AR_AFGRIP"))  
                       ESX.ShowNotification(("Vous venez de vous équiper d'une poignée. Il faudra le rééquiper a chaques retours en ville.")) 
        used3 = used3 + 1
    
                  else 
                        ESX.ShowNotification(("Vous n'avez pas d'arme en main ou votre arme ne peux pas supporter de poignée."))
    
                end
            else
                      ESX.ShowNotification(("Vous avez utiliser toutes vos poignées."))
            end
    end)
    
    local used4 = 0
    
    RegisterNetEvent('accesories:yusuf')
    AddEventHandler('accesories:yusuf', function(duration)
        local inventory = ESX.GetPlayerData().inventory
        local yusuf = 0
            for i=1, #inventory, 1 do
              if inventory[i].name == 'yusuf' then
                yusuf = inventory[i].count
              end
            end
            
    local ped = PlayerPedId()
    local currentWeaponHash = GetSelectedPedWeapon(ped)
    
            if used4 < yusuf then
                if currentWeaponHash == GetHashKey("WEAPON_PISTOL") then
                       GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_PISTOL"), GetHashKey("COMPONENT_PISTOL_VARMOD_LUXE"))  
                       ESX.ShowNotification(("Vous venez d'équiper votre arme skin. Il faudra le rééquiper a chaques retours en ville.")) 
                           used4 = used4 + 1
    
                  elseif currentWeaponHash == GetHashKey("WEAPON_PISTOL50") then
                       GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_PISTOL50"), GetHashKey("COMPONENT_PISTOL50_VARMOD_LUXE"))  
                       ESX.ShowNotification(("Vous venez d'équiper votre arme skin. Il faudra le rééquiper a chaques retours en ville.")) 
        used4 = used4 + 1
    
                  elseif currentWeaponHash == GetHashKey("WEAPON_APPISTOL") then
                       GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_APPISTOL"), GetHashKey("COMPONENT_APPISTOL_VARMOD_LUXE"))  
                       ESX.ShowNotification(("Vous venez d'équiper votre arme skin. Il faudra le rééquiper a chaques retours en ville.")) 
        used4 = used4 + 1
    
                  elseif currentWeaponHash == GetHashKey("WEAPON_HEAVYPISTOL") then
                       GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_HEAVYPISTOL"), GetHashKey("COMPONENT_HEAVYPISTOL_VARMOD_LUXE"))  
                       ESX.ShowNotification(("Vous venez d'équiper votre arme skin. Il faudra le rééquiper a chaques retours en ville.")) 
        used4 = used4 + 1
    
                  elseif currentWeaponHash == GetHashKey("WEAPON_SMG") then
                       GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_SMG"), GetHashKey("COMPONENT_SMG_VARMOD_LUXE"))  
                       ESX.ShowNotification(("Vous venez d'équiper votre arme skin. Il faudra le rééquiper a chaques retours en ville.")) 
        used4 = used4 + 1
    
                  elseif currentWeaponHash == GetHashKey("WEAPON_MICROSMG") then
                       GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_MICROSMG"), GetHashKey("COMPONENT_MICROSMG_VARMOD_LUXE"))  
                       ESX.ShowNotification(("Vous venez d'équiper votre arme skin. Il faudra le rééquiper a chaques retours en ville.")) 
        used4 = used4 + 1
    
                  elseif currentWeaponHash == GetHashKey("WEAPON_ASSAULTRIFLE") then
                       GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_ASSAULTRIFLE"), GetHashKey("COMPONENT_ASSAULTRIFLE_VARMOD_LUXE"))  
                       ESX.ShowNotification(("Vous venez d'équiper votre arme skin. Il faudra le rééquiper a chaques retours en ville.")) 
        used4 = used4 + 1
                      
                  elseif currentWeaponHash == GetHashKey("WEAPON_CARBINERIFLE") then
                       GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_CARBINERIFLE"), GetHashKey("COMPONENT_CARBINERIFLE_VARMOD_LUXE"))  
                       ESX.ShowNotification(("Vous venez d'équiper votre arme skin. Il faudra le rééquiper a chaques retours en ville.")) 
        used4 = used4 + 1
                      
                  elseif currentWeaponHash == GetHashKey("WEAPON_ADVANCEDRIFLE") then
                       GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_ADVANCEDRIFLE"), GetHashKey("COMPONENT_ADVANCEDRIFLE_VARMOD_LUXE"))  
                       ESX.ShowNotification(("Vous venez d'équiper votre arme skin. Il faudra le rééquiper a chaques retours en ville.")) 
        used4 = used4 + 1
    
                  else 
                        ESX.ShowNotification(("Vous n'avez pas d'arme en main ou votre arme ne peux pas supporter de look de luxe."))
                end
            else
                      ESX.ShowNotification(("Vous avez utiliser tout vos skins de luxe."))
            end
    end)
    
    AddEventHandler('playerSpawned', function()
      used = 0
      used2 = 0
      used3 = 0
      used4 = 0
    end)

    function KeyboardInput(entryTitle, textEntry, inputText, maxLength)
        AddTextEntry(entryTitle, textEntry)
        DisplayOnscreenKeyboard(1, entryTitle, '', inputText, '', '', '', maxLength)
        blockinput = true
    
        while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
            Citizen.Wait(0)
        end
    
        if UpdateOnscreenKeyboard() ~= 2 then
            local result = GetOnscreenKeyboardResult()
            Citizen.Wait(500)
            blockinput = false
            return result
        else
            Citizen.Wait(500)
            blockinput = false
            return nil
        end
    end
