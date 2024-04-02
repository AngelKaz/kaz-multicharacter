local Proxy = module("vrp", "lib/Proxy")
local maingroups = module("cfg/groups").groups
vRP = Proxy.getInterface('vRP')

RegisterNetEvent("deks-multichar:SetupStart", function()
    local source = source
    LoadChars(source)
end)

RegisterNetEvent("deks-multichar:SelectChar", function(user_id)
    local source = source
    local steam = getSteam(source)

    Webhook(Config.Webhooks["Joining"], "Deks-Multicharacter", "Player Joining", "New Player joining | ID: "..user_id)

    TriggerEvent("deks-multichar:LoadCharacter", { source = source, user_id = user_id, steam = steam })
    Wait(200)
    TriggerEvent('vRPcli:playerSpawned', source)
end)

RegisterNetEvent("deks-multichar:CreateNewChar", function(data)
    local source = source
    local steam = getSteam(source)
    local chars = getCharacters(steam)

    if chars >= Config.CharData.Chars then
        print("Kan ikke create flere karaktere, mulig snyder")
    else
        MySQL.Async.fetchAll("SELECT MAX(user_id) AS id FROM vrp_user_ids", {}, function(result)
            local next_id = nil

            if result[1].id == nil then 
                next_id = 1 
            else
                next_id = result[1].id+1
            end

            MySQL.Async.execute("INSERT INTO vrp_users (id, whitelisted, banned) VALUES (@id, 'false', 'false')", {id = next_id})
            MySQL.Async.execute("INSERT INTO vrp_user_ids (user_id, identifier) VALUES (@user, @id)", {user = next_id, id = steam})
            vRP.generateRegistrationNumber(function(registration)
                if registration ~= nil then
                  vRP.generatePhoneNumber(function(phone)
                    if phone ~= nil then
                        MySQL.Async.execute("INSERT INTO vrp_user_identities (user_id, firstname, name, sex, registration, phone, age, height) VALUES (@user_id, @firstname, @cpr, @phone, @name, @sex, @age, @height)", {
                            user_id = next_id,
                            firstname = data.firstname,
                            name = data.name,
                            sex = data.sex,
                            age = data.age, 
                            height = data.height,
                            cpr = registration,
                            phone = phone
                        })
                    end
                  end)
                end
            end)

            TriggerEvent("deks-multichar:LoadCharacter", { source = source, user_id = next_id, steam = steam })
            Wait(500)
            TriggerEvent('vRPcli:playerSpawned', source)

            Webhook(Config.Webhooks["Create-Char"], "Deks-Multicharacter", "New Char created", "New character created | ID: "..user_id)
        end)
    end
end)

RegisterNetEvent("deks-multichar:DeleteChar", function(user_id)
    local source = source
    local steam = getSteam(source)

    MySQL.Async.fetchAll("SELECT * FROM vrp_user_ids WHERE identifier = @id AND user_id = @user_id", {id = steam, user_id = user_id}, function(result)
        if #result > 0 then
            for k,v in pairs(Config.UserTables) do
                MySQL.Async.execute("DELETE FROM "..v.table.." WHERE "..v.id.." = @id", {id = user_id})
            end
            Webhook(Config.Webhooks["Delete-Char"], "Deks-Multicharacter", "Char deleted", "Character deleted | ID: "..user_id)
        end
    end)
end)

function LoadChars(source)
    local steam = getSteam(source)
    local result = MySQL.Sync.fetchAll("SELECT * FROM vrp_user_ids WHERE identifier = @steam", {steam = steam})
    local chars = {}

    if #result > 0 then
        for i = 1, Config.CharData.Chars do
            if result[i] ~= nil then
                local res = result[i]
                local identity = MySQL.Sync.fetchAll("SELECT * FROM vrp_user_identities WHERE user_id = @id", {id = res.user_id})
                local money = MySQL.Sync.fetchAll("SELECT * FROM vrp_user_moneys WHERE user_id = @id", {id = res.user_id})
                local groups = MySQL.Sync.fetchAll("SELECT * FROM vrp_user_data WHERE user_id = @id", {id = res.user_id})
                local job = "Unemployed"
                local data = {}

                if groups[1].dvalue ~= nil then
                    data = json.decode(groups[1].dvalue)
                end
                
                if data.groups ~= nil then
                    for k,v in pairs(data.groups) do
                        local kgroup = maingroups[k]

                        if kgroup then
                            if kgroup._config and kgroup._config.gtype and kgroup._config.gtype == "job" then
                                job = k
                            end
                        end
                    end
                end

                if #identity > 0 then
                    identity = identity[1]
                    money = money[1] or {bank = 0, wallet = 0}

                    chars[#chars+1] = {
                        user_id = res.user_id,
                        firstname = identity.firstname,
                        lastname = identity.name,
                        age = identity.age, 
                        gender = identity.sex,
                        height = identity.height,
                        job = firstToUpper(job),
                        phonenumber = identity.phone,
                        bank = FormatNumber(money.bank),
                        cash = FormatNumber(money.wallet),
                    }
                end
            end
        end

        TriggerClientEvent('deks-multichar:SetChars', source, chars)
    else
        TriggerClientEvent('deks-multichar:SetChars', source, chars)
    end
end

function getCharacters(steam)
    local result = MySQL.Sync.fetchAll("SELECT * FROM vrp_user_ids WHERE identifier = @id", {id = steam})

    return #result
end

function getSteam(src)
    return GetPlayerIdentifiers(src)[1]
end

function FormatNumber(number)
    local i, j, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')
    int = int:reverse():gsub("(%d%d%d)", "%1,")
    return minus .. int:reverse():gsub("^,", "") .. fraction
end

function firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end

function Webhook(link, username, title, desc, color)
    if username == nil then username = "Deks-Multicharacter" end
    if title == nil then title = "Deks-Multicharacter" end
    if desc == nil then desc = "Noget her :))))" end
    if color == nil then color = "BLUE" end

    PerformHttpRequest(link, function(o,p,q) end, 'POST', json.encode({
        username = username,
        embeds = {
            {              
                title = title;
                description = desc;
                color = color;
            }
        }
    }), { ['Content-Type'] = 'application/json' })
end


exports('GetCharsbySteam', function(steam)
    return MySQL.Sync.fetchAll("SELECT * FROM vrp_user_ids WHERE identifier = @id", {id = steam})
end)


RegisterCommand("switchchar", function(source)
    local user_id = vRP.getUserId({source})

    if user_id ~= nil then
        if vRP.hasGroup({user_id, Config.AdminRank}) then
            TriggerEvent("deks-multichar:SwitchChar", source)
            Wait(500)
            LoadChars(source)
        end
    end
end)
