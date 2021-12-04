local lastTruck = nil

--
-- Threads
--

Citizen.CreateThread(function()
    while true do
        

        local playerId       = PlayerPedId()
        local currentVehicle = GetVehiclePedIsIn(playerId, true)
        local sleep          = 1000

        if currentVehicle and currentVehicle ~= lastTruck then
            if Config.ESUVehicles[GetEntityModel(currentVehicle)] then
                lastTruck = currentVehicle
            end
        end

        if lastTruck and DoesEntityExist(lastTruck) and not IsPedInAnyVehicle(playerId, true) then
            local distanceToTruck = #(GetEntityCoords(playerId) - GetEntityCoords(lastTruck))

            if distanceToTruck < 6 then
                sleep = 9

                local currentState = getCurrentTruckState(lastTruck)

                Redneck.GUI.ShowAlert(formatAlertString(currentState))

                if IsControlJustPressed(0, 327) then 
                    if currentState.pioneer then
                        SetVehicleDoorShut(lastTruck, 4, false)

                        Redneck.GUI.ShowNotification('Pioneers dropped.', nil, true, false)
                    else
                        SetVehicleDoorOpen(lastTruck, 4, false, false)

                        Redneck.GUI.ShowNotification('Pioneers lifted.', nil, true, false)
                    end
                end

                if IsControlJustPressed(0, 51) then 
                    if currentState.compartments then
                        SetVehicleDoorShut(lastTruck, 5, false)

                        Redneck.GUI.ShowNotification('Compartments closed.', nil, true, false)
                    else
                        SetVehicleDoorOpen(lastTruck, 5, false, false)

                        Redneck.GUI.ShowNotification('Compartments opened.', nil, true, false)
                    end
                end

                if IsControlJustPressed(0, 47) then 
                    if currentState.interiorLights then
                        updateVehicleExtra(lastTruck, 11, false)

                        Redneck.GUI.ShowNotification('Turned interior lights off.', nil, true, false)
                    else
                        updateVehicleExtra(lastTruck, 11, true)

                        Redneck.GUI.ShowNotification('Turned interior lights on.', nil, true, false)
                    end
                end

                if IsControlJustPressed(0, 73) then 
                    if currentState.leftSceneLights then
                        updateVehicleExtra(lastTruck, 3, false)

                        Redneck.GUI.ShowNotification('Turned left scene lights off.', nil, true, false)
                    else
                        updateVehicleExtra(lastTruck, 3, true)

                        Redneck.GUI.ShowNotification('Turned left scene lights on.', nil, true, false)
                    end
                end

                if IsControlJustPressed(0, 74) then 
                    if currentState.rightSceneLights then
                        updateVehicleExtra(lastTruck, 4, false)

                        Redneck.GUI.ShowNotification('Turned right scene lights off.', nil, true, false)
                    else
                        updateVehicleExtra(lastTruck, 4, true)

                        Redneck.GUI.ShowNotification('Turned right scene lights on.', nil, true, false)
                    end
                end

                if IsControlJustPressed(0, 311) then 
                    if currentState.rearSceneLights then
                        updateVehicleExtra(lastTruck, 10, false)

                        Redneck.GUI.ShowNotification('Turned rear scene lights off.', nil, true, false)
                    else
                        updateVehicleExtra(lastTruck, 10, true)

                        Redneck.GUI.ShowNotification('Turned rear scene lights on.', nil, true, false)
                    end
                end
            end
        end
        Citizen.Wait(sleep)
    end
end)

--
-- Functions
--

-- Returns the state of all relevant components and extras. True means
-- open or on, while false means closed or off.
function getCurrentTruckState(vehicleId)
    return {
        pioneer      = (GetVehicleDoorAngleRatio(vehicleId, 4) > 0),
        compartments      = (GetVehicleDoorAngleRatio(vehicleId, 5) > 0),
        interiorLights = IsVehicleExtraTurnedOn(vehicleId, 11),
        leftSceneLights   = IsVehicleExtraTurnedOn(vehicleId, 3),
        rightSceneLights  = IsVehicleExtraTurnedOn(vehicleId, 4),
        rearSceneLights   = IsVehicleExtraTurnedOn(vehicleId, 10),
    }
end

-- Updates a vehicle exta safely, meaning it will check if the compartments
-- are open and, if so, re-open them since changing extras causes
-- the vehicle's doors to shut.
function updateVehicleExtra(vehicleId, extraId, enable)
    local currentState = getCurrentTruckState(vehicleId)
    local disable      = not enable

    SetVehicleExtra(vehicleId, extraId, disable)

    if currentState.compartments then
        SetVehicleDoorOpen(vehicleId, 5, false, false)
    end    
end

-- Builds up an alert string that shows more relevant information, such as
-- if the extra is currently enabled or not.
function formatAlertString(currentState)
    return ('~INPUT_REPLAY_TIMELINE_SAVE~ %s pioneers.~n~~INPUT_CONTEXT~ %s compartment doors.~n~~INPUT_DETONATE~ %s interior lights ~r~BETA~w~.~n~~INPUT_VEH_DUCK~ %s left scene lights.~n~~INPUT_VEH_HEADLIGHT~ %s right scene lights.~n~~INPUT_REPLAY_SHOWHOTKEY~ %s pioneer scene lights.'):format(
        currentState.pioneer      and 'Drop'    or 'Lift',
        currentState.compartments      and 'Close'    or 'Open',
        currentState.interiorLights and 'Turn off' or 'Turn on',
        currentState.leftSceneLights   and 'Turn off' or 'Turn on',
        currentState.rightSceneLights  and 'Turn off' or 'Turn on',
        currentState.rearSceneLights   and 'Turn off' or 'Turn on'
    )
end