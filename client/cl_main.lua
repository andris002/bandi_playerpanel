RegisterCommand(Config.Command, function()
    local players = lib.callback.await('playerpanel:getData', false)
    if not players then
        return Config.Notify("Nincs jogod megnyitni", 2000, 'error')
    end
    SendNUIMessage({type = 'open', pl = players})
    SetNuiFocus(true, true)
end, false)

RegisterNUICallback('close', function(_, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('healp', function(id, cb)
    lib.callback.await('playerpanel:revivep', false, id)
    cb('ok')
end)

RegisterNUICallback('killp', function(id, cb)
    lib.callback.await('playerpanel:killp', false, id)
    cb('ok')
end)

RegisterNUICallback('kick', function(d, cb)
    lib.callback.await('playerpanel:kickp', false, d)
    cb('ok')
end)

RegisterNUICallback('ban', function(d, cb)
    if d.reason == '' then return Config.Notify("Nincs indok megadva", 2000, 'error') end
    lib.callback.await('playerpanel:ban', false, d)
    cb('ok')
end)

RegisterNUICallback('unban', function(id, cb)
    lib.callback.await('playerpanel:unban', false, id)
    cb('ok')
end)

RegisterNetEvent('playerpanel:killplayer', function()
    SetEntityHealth(PlayerPedId(), 0)
end)

RegisterKeyMapping(Config.Command, "Open Player Panel", 'keyboard', Config.OpenKey)