-- Text Chat Server Script
print("^2[TextChat]^7 Server script loaded successfully!")

-- Handle text updates from players
RegisterNetEvent('textchat:updateText', function(text)
    local src = source
    
    -- Validate text length (fallback to 100 if config not available)
    local maxLength = 100
    if Config and Config.UISettings and Config.UISettings.max_length then
        maxLength = Config.UISettings.max_length
    end
    
    if text and string.len(text) <= maxLength and string.len(text) > 0 then
        -- Send to all players except sender
        TriggerClientEvent('textchat:updatePlayerText', -1, src, text)
        print("^2[TextChat]^7 Player " .. src .. " sent text: " .. text)
    else
        print("^1[TextChat]^7 Invalid text from player " .. src .. " (length: " .. (text and string.len(text) or "nil") .. ")")
    end
end)