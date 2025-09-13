local ESX = exports['es_extended']:getSharedObject()

local function IsAdmin(src)
    local p = ESX.GetPlayerFromId(src)

    for i, v in ipairs(Config.AdminGroups) do
        if p.getGroup() == v then 
            return true
        end
    end

    return false
end

CreateThread(function()
    exports.oxmysql:execute([=[
        ALTER TABLE `users`
        ADD COLUMN IF NOT EXISTS `ban` VARCHAR(50) DEFAULT NULL,
        ADD COLUMN IF NOT EXISTS `discordid` VARCHAR(50) NULL AFTER `identifier`;
    ]=])
end)

CreateThread(function()
    if TOKEN == '' then
        error('Set a discord bot TOKEN')
    end
end)

AddEventHandler('esx:playerLoaded', function (playerId, xPlayer, isNew)
    local discordid
    for i, v in ipairs(GetPlayerIdentifiers(playerId)) do
        if v:match('discord:') then 
            discordid = v:gsub('discord:', '')
        end
    end
    MySQL.update.await('UPDATE users SET discordid = ? WHERE identifier = ?', {
        discordid, xPlayer.identifier
    })
end)

local function GetDcData(id)
    if not id then return {url = false, name = "Unknown"} end

    local p = promise.new()

    PerformHttpRequest("https://discord.com/api/v10/users/" .. id, function(status, response, headers)
        if status == 200 then
            local data = json.decode(response)
            local avatar = data.avatar
            local name = data.global_name or data.username or "Unknown"

            local avatarUrl
            if avatar then
                local ext = string.sub(avatar,1,2) == "a_" and "gif" or "png"
                avatarUrl = ("https://cdn.discordapp.com/avatars/%s/%s.%s?size=1024"):format(id, avatar, ext)
            else
                avatarUrl = "https://cdn.discordapp.com/embed/avatars/0.png"
            end

            p:resolve({url = avatarUrl, name = name})
        else
            print("Discord API hiba: " .. tostring(status))
            p:resolve({url = false, name = "Unknown"})
        end
    end, "GET", "", { ["Authorization"] = "Bot " .. TOKEN, ["Content-Type"] = "application/json" })

    return Citizen.Await(p)
end

lib.callback.register('playerpanel:getData', function(src)
    if not IsAdmin(src) then return end
    local r = {}
    local ofp = MySQL.query.await('SELECT * FROM `users`')
    for _, offline in ipairs(ofp) do
        offline.online = ESX.GetPlayerFromIdentifier(offline.identifier) and true or false
        offline.dc = GetDcData(offline.discordid)
        table.insert(r, offline)
    end

    return r
end)

lib.callback.register('playerpanel:revivep', function(src, id)
    if not IsAdmin(src) then return end

    local target = ESX.GetPlayerFromIdentifier(id).source
    TriggerClientEvent('esx_ambulancejob:revive', target)
end)

lib.callback.register('playerpanel:killp', function(src, id)
    if not IsAdmin(src) then return end

    local target = ESX.GetPlayerFromIdentifier(id).source

    TriggerClientEvent('playerpanel:killplayer', target)
end)

lib.callback.register('playerpanel:kickp', function(src, d)
    if not IsAdmin(src) then return end

    local target = ESX.GetPlayerFromIdentifier(d.id).source

    DropPlayer(target, d.reason)
end)

lib.callback.register('playerpanel:ban', function(src, d)
    if not IsAdmin(src) then return end

    MySQL.update.await('UPDATE users SET ban = ? WHERE identifier = ?', {
        d.reason, d.id
    })

    local target = ESX.GetPlayerFromIdentifier(d.id)
    if target then 
        DropPlayer(target.source, "Banned From the server")
    end
end)

lib.callback.register('playerpanel:unban', function(src, id)
    if not IsAdmin(src) then return end

    MySQL.update.await('UPDATE users SET ban = NULL WHERE identifier = ?', {
        id
    })
end)

local function OnPlayerConnecting(name, setKickReason, deferrals)
    local player = source
    local discord
    local identifiers = GetPlayerIdentifiers(player)
    deferrals.defer()

    Wait(0)

    for _, v in pairs(identifiers) do
        if v:match('discord:') then 
            discord = v:gsub('discord:', '')
        end
    end

    Wait(0)

    if not discord then 
        deferrals.done("Connect Your discord")
    end

    local reason = MySQL.scalar.await('SELECT ban FROM users WHERE discordid = ?', {discord})

    if reason then
        local reas = json.encode("Reason: " .. reason) 
        local url = json.encode(Config.DiscordINV)

        local cardJson = ([[
        {
            "type": "AdaptiveCard",
            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
            "version": "1.5",
            "body": [
                {
                    "type": "TextBlock",
                    "size": "ExtraLarge",
                    "weight": "Bolder",
                    "horizontalAlignment": "Center",
                    "text": "🚫 BANNED 🚫"
                },
                {
                    "type": "TextBlock",
                    "text": "You are banned from this server.",
                    "wrap": true,
                    "horizontalAlignment": "Center"
                },
                {
                    "type": "TextBlock",
                    "text": %s,
                    "wrap": true,
                    "horizontalAlignment": "Center"
                }
            ],
            "actions": [
                {
                    "type": "Action.OpenUrl",
                    "title": "📌 Discord",
                    "url": %s
                }
            ]
        }
        ]]):format(reas, url)

        deferrals.presentCard(cardJson)
    else 
        deferrals.done()
    end
end

AddEventHandler("playerConnecting", OnPlayerConnecting)
