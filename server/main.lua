ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- Spieler betritt das FFA
RegisterServerEvent("ffa:join")
AddEventHandler("ffa:join", function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    -- Speichert die aktuellen Spielerkoordinaten
    local originalCoords = xPlayer.getCoords()

    -- Synchronisiere mit dem Client
    TriggerClientEvent("ffa:enter", src)

    -- Speichere die ursprünglichen Koordinaten für die Rückkehr
    xPlayer.set("originalCoords", originalCoords)
end)

-- Spieler verlässt das FFA
RegisterServerEvent("ffa:leave")
AddEventHandler("ffa:leave", function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    -- Originalkoordinaten laden
    local originalCoords = xPlayer.get("originalCoords")

    if originalCoords then
        -- Spieler zurück teleportieren
        TriggerClientEvent("ffa:exit", src, originalCoords)
        xPlayer.set("originalCoords", nil)
    else
        TriggerClientEvent("esx:showNotification", src, "Du bist nicht in einem FFA!")
    end
end)
