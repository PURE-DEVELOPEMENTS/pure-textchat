-- Text Chat Client Script
print("^2[TextChat]^7 Client script loaded successfully!")

local isUIOpen = false
local currentText = ""
local textEndTime = 0
local playersWithText = {}
local isUsingNotebook = false

-- Load animation dictionary
function LoadAnimDict(dict)
    if not HasAnimDictLoaded(dict) then
        print("^3[TextChat]^7 Requesting animation dict: " .. dict)
        RequestAnimDict(dict)
        local timeout = 0
        while not HasAnimDictLoaded(dict) and timeout < 5000 do
            Wait(10)
            timeout = timeout + 10
        end
        if HasAnimDictLoaded(dict) then
            print("^2[TextChat]^7 Animation dict loaded successfully: " .. dict)
        else
            print("^1[TextChat]^7 Failed to load animation dict: " .. dict)
        end
    else
        print("^2[TextChat]^7 Animation dict already loaded: " .. dict)
    end
end

-- Start notebook animation
function StartNotebookAnimation()
    if isUsingNotebook then return end
    
    local ped = PlayerPedId()
    isUsingNotebook = true
    
    print("^2[TextChat]^7 Starting notebook animation...")
    
    -- Cancel any existing animations
    ClearPedTasks(ped)
    
    -- Start the notebook animation using scenario
    TaskStartScenarioInPlace(ped, GetHashKey('WORLD_HUMAN_WRITE_NOTEBOOK'), -1, true, false, false, false)
    
    print("^2[TextChat]^7 Notebook animation started")
end

-- Stop notebook animation
function StopNotebookAnimation()
    if not isUsingNotebook then return end
    
    local ped = PlayerPedId()
    isUsingNotebook = false
    
    print("^2[TextChat]^7 Stopping notebook animation...")
    
    -- Clear the scenario
    ClearPedTasks(ped)
    
    print("^2[TextChat]^7 Notebook animation stopped")
end

-- Command to open text chat
RegisterCommand('tb', function()
    print("^2[TextChat]^7 Command triggered!")
    if not isUIOpen then
        openTextChat()
    else
        print("^3[TextChat]^7 UI already open!")
    end
end, false)

-- Say command to directly display text overhead
RegisterCommand('say', function(source, args, rawCommand)
    local message = string.sub(rawCommand, 5) -- Remove "/say " from the beginning
    message = message:gsub("^%s*(.-)%s*$", "%1") -- Trim whitespace
    
    if message and string.len(message) > 0 then
        if string.len(message) <= Config.UISettings.max_length then
            -- Set current player's text
            currentText = message
            textEndTime = GetGameTimer() + Config.TextSettings.duration
            
            -- Sync with other players
            TriggerServerEvent('textchat:updateText', message)
            print("^2[TextChat]^7 Say message set: " .. message)
        else
            print("^1[TextChat]^7 Message too long! Maximum " .. Config.UISettings.max_length .. " characters allowed.")
        end
    else
        print("^3[TextChat]^7 Usage: /say [message]")
    end
end, false)

-- Test command (for debugging)
RegisterCommand('testui', function()
    print("^3[TextChat]^7 Testing NUI directly...")
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open'
    })
end, false)

-- Open the text chat UI
function openTextChat()
    print("^2[TextChat]^7 Opening text chat UI...")
    
    if isUIOpen then
        print("^3[TextChat]^7 UI already open, ignoring...")
        return
    end
    
    isUIOpen = true
    
    -- Start notebook animation
    StartNotebookAnimation()
    
    -- Then open the UI
    print("^2[TextChat]^7 Setting NUI focus...")
    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(false)
    
    print("^2[TextChat]^7 Sending NUI message...")
    SendNUIMessage({
        action = 'open'
    })
    print("^2[TextChat]^7 NUI message sent!")
end

-- Close the text chat UI
function closeTextChat()
    if not isUIOpen then
        return -- Already closed, prevent multiple calls
    end
    
    print("^2[TextChat]^7 Closing text chat UI...")
    isUIOpen = false
    
    -- Stop notebook animation
    StopNotebookAnimation()
    
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

-- NUI Callbacks
RegisterNUICallback('close', function(data, cb)
    print("^2[TextChat]^7 NUI callback: close (user clicked close)")
    closeTextChat()
    cb('ok')
end)

RegisterNUICallback('sendMessage', function(data, cb)
    print("^2[TextChat]^7 NUI callback: sendMessage")
    local message = data.message
    if message and string.len(message) > 0 then
        -- Set current player's text
        currentText = message
        textEndTime = GetGameTimer() + Config.TextSettings.duration
        
        -- Sync with other players
        TriggerServerEvent('textchat:updateText', message)
        print("^2[TextChat]^7 Message set: " .. message)
    end
    
    -- DON'T close the UI - keep it open for more messages
    -- Just clear the input field via NUI message
    SendNUIMessage({
        action = 'clearInput'
    })
    
    cb('ok')
end)

-- Handle text updates from other players
RegisterNetEvent('textchat:updatePlayerText', function(playerId, text)
    if text and string.len(text) > 0 then
        playersWithText[playerId] = {
            text = text,
            endTime = GetGameTimer() + Config.TextSettings.duration
        }
    else
        playersWithText[playerId] = nil
    end
end)

-- Main display loop
CreateThread(function()
    while true do
        local sleep = 100
        local currentTime = GetGameTimer()
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        
        -- Display current player's text
        if currentText ~= "" and currentTime < textEndTime then
            sleep = 0
            local headCoords = GetPedBoneCoords(playerPed, 0x796e, 0.0, 0.0, Config.TextSettings.height_offset)
            DrawText3D(headCoords.x, headCoords.y, headCoords.z, currentText)
        elseif currentTime >= textEndTime then
            currentText = ""
        end
        
        -- Display other players' text
        for playerId, data in pairs(playersWithText) do
            if currentTime < data.endTime then
                local player = GetPlayerFromServerId(playerId)
                if player ~= -1 then
                    local playerPed = GetPlayerPed(player)
                    if playerPed ~= 0 then
                        local playerPos = GetEntityCoords(playerPed)
                        local distance = #(playerCoords - playerPos)
                        
                        if distance < Config.TextSettings.distance then
                            sleep = 0
                            local headCoords = GetPedBoneCoords(playerPed, 0x796e, 0.0, 0.0, Config.TextSettings.height_offset)
                            DrawText3D(headCoords.x, headCoords.y, headCoords.z, data.text)
                        end
                    end
                end
            else
                playersWithText[playerId] = nil
            end
        end
        
        Wait(sleep)
    end
end)

-- Draw 3D text function with black outline
function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = GetScreenCoordFromWorldCoord(x, y, z)
    
    if onScreen then
        -- Draw black outline by drawing the text multiple times offset in different directions
        local outlineColor = {0, 0, 0, 255} -- Black outline
        local mainColor = Config.TextSettings.color
        local scale = Config.TextSettings.scale
        
        -- Create the text string once
        local str = CreateVarString(10, "LITERAL_STRING", text)
        
        -- Draw outline (8 directions around the main text)
        local outlineOffset = 0.001
        local outlinePositions = {
            {_x - outlineOffset, _y - outlineOffset}, -- Top-left
            {_x, _y - outlineOffset},                  -- Top
            {_x + outlineOffset, _y - outlineOffset}, -- Top-right
            {_x - outlineOffset, _y},                  -- Left
            {_x + outlineOffset, _y},                  -- Right
            {_x - outlineOffset, _y + outlineOffset}, -- Bottom-left
            {_x, _y + outlineOffset},                  -- Bottom
            {_x + outlineOffset, _y + outlineOffset}  -- Bottom-right
        }
        
        -- Draw outline
        for _, pos in ipairs(outlinePositions) do
            Citizen.InvokeNative(0xADA9255D, 1)
            SetTextScale(scale, scale)
            SetTextColor(outlineColor[1], outlineColor[2], outlineColor[3], outlineColor[4])
            SetTextCentre(1)
            DisplayText(str, pos[1], pos[2])
        end
        
        -- Draw main text on top
        Citizen.InvokeNative(0xADA9255D, 1)
        SetTextScale(scale, scale)
        SetTextColor(mainColor[1], mainColor[2], mainColor[3], mainColor[4])
        SetTextCentre(1)
        DisplayText(str, _x, _y)
    end
end

-- ESC key handler (simplified - no animation maintenance needed for scenarios)
CreateThread(function()
    while true do
        if isUIOpen then
            -- ESC key to close
            if IsControlJustPressed(0, 0x156F7119) then -- ESC key
                print("^2[TextChat]^7 ESC pressed, closing UI")
                closeTextChat()
            end
            
            Wait(100) -- Check ESC key more frequently
        else
            Wait(1000) -- Less frequent checks when UI is closed
        end
    end
end)