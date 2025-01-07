local inFFA = false

-- Key für Menü-Interaktion
CreateThread(function()
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local distance = #(playerCoords - Config.FFAEntryPoint)

        if distance < 5.0 then
            sleep = 0
            ESX.ShowHelpNotification("Drücke ~INPUT_CONTEXT~, um dem FFA beizutreten.")
            if IsControlJustReleased(0, 38) then -- E
                OpenFFAMenu()
            end
        end

        Wait(sleep)
    end
end)

-- Menü anzeigen
function OpenFFAMenu()
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'ffa_menu', {
        title = "FFA Menü",
        align = "top-left",
        elements = {
            {label = "FFA betreten", value = "join"},
            {label = "Schließen", value = "close"}
        }
    }, function(data, menu)
        if data.current.value == "join" then
            TriggerServerEvent("ffa:join")
            menu.close()
        elseif data.current.value == "close" then
            menu.close()
        end
    end, function(data, menu)
        menu.close()
    end)
end

-- Spieler verlassen das FFA
RegisterCommand("leave", function()
    if inFFA then
        TriggerServerEvent("ffa:leave")
    else
        ESX.ShowNotification("Du bist nicht in einem FFA!")
    end
end, false)

-- Spieler wird teleportiert und Waffen hinzugefügt
RegisterNetEvent("ffa:enter")
AddEventHandler("ffa:enter", function()
    local playerPed = PlayerPedId()

    -- Spieler in FFA teleportieren
    SetEntityCoords(playerPed, Config.FFASpawnPoint)
    SetEntityHeading(playerPed, 0.0)
    SetPlayerRoutingBucket(PlayerId(), Config.FFADimension)

    -- Waffen geben
    for _, weapon in ipairs(Config.FFAWeapons) do
        GiveWeaponToPed(playerPed, GetHashKey(weapon), 250, false, true)
    end

    inFFA = true
    ESX.ShowNotification("Du bist dem FFA beigetreten!")
end)

-- Spieler verlässt FFA
RegisterNetEvent("ffa:exit")
AddEventHandler("ffa:exit", function(originalCoords)
    local playerPed = PlayerPedId()

    -- Spieler zurück teleportieren
    SetEntityCoords(playerPed, originalCoords)
    SetPlayerRoutingBucket(PlayerId(), 0)

    -- Waffen entfernen
    RemoveAllPedWeapons(playerPed, true)

    inFFA = false
    ESX.ShowNotification("Du hast das FFA verlassen!")
end)
