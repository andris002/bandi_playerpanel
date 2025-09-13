Config = {}

Config.OpenKey = 'f11'
Config.Command = 'playerpanel'
Config.AdminGroups = {
    'admin'
}

Config.DiscordINV = "https://discord.gg/y99hwPaWXA"

Config.Notify = function(msg, time, type, src)
    if src then 
        TriggerClientEvent('ox_lib:notify', src, {
            description = msg,
            time = time,
            type = type
        })
        return
    end
    
    lib.notify({
        description = msg,
        time = time,
        type = type
    })
end