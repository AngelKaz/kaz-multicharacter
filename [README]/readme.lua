--[[
Slet alle events i base.lua med navnene:
- playerConnecting
- vRPcli:playerSpawned

Og i client/base.lua skal TriggerServerEvent("vRPcli:playerSpawned") skiftes ud med TriggerServerEvent("deks-multichar:SetupStart")
Hvis du har en primary key på identifier i kolonnen "vrp_user_ids" så skal den fjernes.

Alt andet shit kan ændre i config ;)
Ved fejl, skriv på min discord i hjælp til fivem.

Requirements:
- Ossies devo filer
- MySQL-Async
]]

----------- base.lua -----------

AddEventHandler("playerConnecting",function(name,setMessage, deferrals)
    deferrals.defer()
    local source = source
    Debug.pbegin("playerConnecting")
    local steam = GetPlayerIdentifiers(source)[1]
  
    if steam ~= nil then
      deferrals.update("[Deks-Multi] | Tjekker om du er banned..")
      local banned = false
      local whitelisted = false
      local user_ids = exports['multicharacter']:GetCharsbySteam(steam)
      local user_string = "IDS: "
  
      if next(user_ids) then
        for i = 1, #user_ids do
          user_string = user_string.." "..user_ids[i].user_id
  
          vRP.isWhitelisted(user_ids[i].user_id, function(iswhitelisted)
            if iswhitelisted == true then
              whitelisted = true
            end
          end)
  
          vRP.isBanned(user_ids[i].user_id, function(isbanned)
            if isbanned == true then 
              banned = true
            end
          end)
        end
  
        Wait(250)
  
        if config.whitelist == true and whitelisted == false then
          deferrals.done("Du er ikke whitelisted på serveren. "..user_string)
          return
        end
  
        if banned == true then
          deferrals.done("Du er banned fra serveren. "..user_string)
          return
        end   
        deferrals.done()
      else
        deferrals.done()
      end
    
    else 
      deferrals.done("[Deks-Multi] | Du skal have steam åben")
    end
end)

RegisterNetEvent("deks-multichar:LoadCharacter", function(data)
  local source = tonumber(data.source)
  local user_id = tonumber(data.user_id)
  local name = GetPlayerName(source)

  if vRP.rusers[user_id] == nil then
    vRP.users[data.steam] = user_id
    vRP.rusers[user_id] = data.steam
    vRP.user_tables[user_id] = {}
    vRP.user_tmp_tables[user_id] = {}
    vRP.user_sources[user_id] = source

    vRP.getUData(user_id, "vRP:datatable", function(sdata)
      local data = json.decode(sdata)
      
      if type(data) == "table" then 
        vRP.user_tables[user_id] = data 
      end

      local tmpdata = vRP.getUserTmpTable(user_id)

      vRP.getLastLogin(user_id, function(last_login)
        tmpdata.last_login = last_login or ""
        tmpdata.spawns = 0

        local ep = vRP.getPlayerEndpoint(source)
        local last_login_stamp = ep
        local last_login_date = os.date("%H:%M:%S %d/%m/%Y")
        --MySQL.Async.execute("UPDATE vrp_users SET last_login = @last_login, last_date = @last_date WHERE id = @user_id", {user_id = user_id, last_login = last_login_stamp, last_date = last_login_date})

        TriggerEvent("vRP:playerJoin", user_id, source, name, tmpdata.last_login)
      end)
    end)
  else
    TriggerEvent("vRP:playerRejoin", user_id, source, name)

    local tmpdata = vRP.getUserTmpTable(user_id)
    tmpdata.spawns = 0
  end
end)

RegisterNetEvent("deks-multichar:SwitchChar",function(source)
  local source = source
  vRPclient.removePlayer(-1,{source})
  local user_id = vRP.getUserId(source)

  if user_id ~= nil then
    TriggerEvent("vRP:playerLeave", user_id, source)

    -- save user data table
    vRP.setUData(user_id, "vRP:datatable", json.encode(vRP.getUserDataTable(user_id)))

    vRP.users[vRP.rusers[user_id]] = nil
    vRP.rusers[user_id] = nil
    vRP.user_tables[user_id] = nil
    vRP.user_tmp_tables[user_id] = nil
    vRP.user_sources[user_id] = nil
  end
  Debug.pend()
end)

RegisterServerEvent("vRPcli:playerSpawned")
AddEventHandler("vRPcli:playerSpawned", function(source)
  Debug.pbegin("playerSpawned")
  local user_id = vRP.getUserId(source)

  if user_id ~= nil then
    vRP.user_sources[user_id] = source
    local tmp = vRP.getUserTmpTable(user_id)
    tmp.spawns = tmp.spawns+1
    local first_spawn = (tmp.spawns == 1)

    if first_spawn then
      for k,v in pairs(vRP.user_sources) do
        vRPclient.addPlayer(source,{v})
      end
      vRPclient.addPlayer(-1,{source})
    end
    
    TriggerEvent("vRP:playerSpawn",user_id, source, first_spawn)
  end

  Debug.pend()
end)