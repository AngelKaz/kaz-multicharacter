local SelectingChar = false 

RegisterNetEvent("deks-multichar:SetChars", function(chars)
    SetupCams()
    SendNUIMessage({
        type = "setChars",
        chars = chars,
        charCount = Config.CharData.Chars
    })

    Wait(250)

    SendNUIMessage({
        type = "open"
    })

    SetNuiFocus(true, true)
    SelectingChar = true
end)

RegisterNUICallback("CreateChar", function(data)
    TriggerServerEvent('deks-multichar:CreateNewChar', data)
    Wait(200)
    EndCams()
end)

RegisterNUICallback("SelectChar", function(data)
    TriggerServerEvent('deks-multichar:SelectChar', tonumber(data.user_id))
    Wait(200)
    EndCams()
end)

RegisterNUICallback("DeleteChar", function(data)
    TriggerServerEvent("deks-multichar:DeleteChar", tonumber(data.user_id))
end)

CreateThread(function()
    local sleep = 100

    while true do
        if SelectingChar == true then
            sleep = 1
            DisplayRadar(false)
            DisplayHud(false)
        else
            sleep = 100
        end
        Wait(sleep)
    end
end)

function SetupCams()
    SetTimecycleModifier('hud_def_blur')
    FreezeEntityPosition(GetPlayerPed(-1), true)
    SetCam(true, Config.CamCoords.x, Config.CamCoords.y, Config.CamCoords.z, Config.CamCoords.h)
end

function EndCams()
    SelectingChar = false
    SetNuiFocus(false, false)
    SetTimecycleModifier('default')
    FreezeEntityPosition(GetPlayerPed(-1), false)
    SetCam(false)
end

function SetCam(onoff, CamX, CamY, CamZ, CamH)
    if onoff == true then
        if cam ~= 0 then 
            DestroyCam(cam)
        end
        cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
        SetCamCoord(cam, CamX, CamY, CamZ, CamH)
        SetCamActive(cam, true)
        RenderScriptCams(1, 1, 750, 1, 1)
    else
        SetCamActive(cam, false)
        DestroyCam(cam)
        DetachCam(cam)
        RenderScriptCams(false, true, 2000, true, true)
    end
end