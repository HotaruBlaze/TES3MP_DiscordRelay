local SCRIPT = scriptLoader.DefineScript()
SCRIPT.ID = "discordrelay"
SCRIPT.Version = "v1.0.0"
SCRIPT.Name = "DiscordRelay"
SCRIPT.Author = "MrFlutters(https://github.com/MrFlutters)"
SCRIPT.Desc = "Connect TES3MP to Discord!"

tableHelper = require("tableHelper")
json = require ("dkjson")
https = require('ssl.https')

local config = jsonInterface.load("discord_config.json")
local ScriptName = "[" .. SCRIPT.Name .."]" .. " "

local Methods = {}

Methods.CheckMessage = function(code)
    if not (code == 200) then
        tes3mp.LogMessage(enumerations.log.WARN, ScriptName .. "Failed to send message, Responce was " .. code)
        return false
    else
        if config['debug'] == true then
            tes3mp.LogMessage(enumerations.log.INFO, ScriptName .. "Message Sent")
        return true else return true end end end

Methods.SendRPMessage = function(pid, chatPrefix, message)
    if (chatPrefix == "OOC" or chatPrefix == "LOOC") then
        if chatPrefix == "OOC" then chatPrefix = config['oocPrefix'] discordChannel = config['ooc_Channel'] end
        if chatPrefix == "LOOC" then chatPrefix = config['loocPrefix'] discordChannel = config['looc_Channel'] end

        local staffRank
        if Players[pid]:IsModerator() then staffRank = config['ModeratorPrefix'] end
        if Players[pid]:IsAdmin() then staffRank = config['AdminPrefix'] end
        if Players[pid]:IsServerOwner() then staffRank = config['OwnerPrefix'] end
        
        local playerName = Players[pid].data.login.name
        if config['debug'] == true then 
            tes3mp.LogMessage(2, "staffRank = " .. staffRank)
        end
        if (staffRank == nil or staffRank == "" or config['showStaffRanks'] == false) then 
            playerName = chatPrefix .. "[" ..playerName .. "]" end
        if (staffRank ~= nil and config['showStaffRanks'] == true) then 
            playerName = staffRank .. chatPrefix .. "[" ..playerName.. "]" end

            local t = {['content'] = tostring(playerName) .. tostring(message)}
            
            local data = json.encode(t)
            local response_body = {}
            local res, code, responce_headers, status = https.request{
                url = "https://discordapp.com/api/channels/" .. discordChannel .. "/messages",
                method = "POST",
                protocol = "tlsv1_2",
                headers = {
                    ['Authorization'] = "Bot " .. config['token'],
                    ["Content-Type"] = "application/json",
                    ["Content-Length"] = string.len(data)},
                source = ltn12.source.string(data),
                sink = ltn12.sink.table(response_body),
            }
            if (Methods.CheckMessage(code) == true) then return true else return false 
        end
    end end
Methods.SendLocalMessage = function(pid, message)
    if config['enableLocal'] then
        local playerName = Players[pid].data.login.name
        local playerName = "[" ..playerName .. "]" .. " "
        local message = playerName .. message
        local t = {['content'] = tostring(message)}
        local data = json.encode(t)
        local response_body = {}
        local res, code, responce_headers, status = https.request{
            url = "https://discordapp.com/api/channels/" .. config['local_Channel'] .. "/messages",
            method = "POST",
            protocol = "tlsv1_2",
            headers = {
                ['Authorization'] = "Bot " .. config['token'],
                ["Content-Type"] = "application/json",
                ["Content-Length"] = string.len(data)},
            source = ltn12.source.string(data),
            sink = ltn12.sink.table(response_body),
        }
        if (Methods.CheckMessage(code) == true) then return true else return false end
    end end

SCRIPT:AddHook("ProcessCommand", "discord_rpchat", function(pid, cmd, message)
    if cmd[1] == "/" then
        if config["enableOOC"] == true then
            chatPrefix = "OOC"
            local message = string.sub(message, 3)
            Methods.SendRPMessage(pid, chatPrefix, message)
        end
        elseif cmd[1] == "//" then
        if config["enableLOOC"] == true then
            chatPrefix = "LOOC"
            local message = string.sub(message, 4)
            Methods.SendRPMessage(pid, chatPrefix, message)
            else
        end
    end end)


SCRIPT:AddHook("OnServerPostInit", "discord_DoSanityTest", function(pid, message)
    Methods.DoSanityTest() end)

SCRIPT:AddHook("OnPlayerSendMessage", "discord_localmsg", function(pid, message)
    Methods.SendLocalMessage(pid, message) end)

Methods.DoSanityTest = function()
    local failed_count = 0
    tes3mp.LogMessage(enumerations.log.INFO, ScriptName .. "Initializing Discord Relay " .. SCRIPT.Version .. "...")
    
    if config == nil then
        tes3mp.LogMessage(enumerations.log.ERROR, ScriptName .. "Configuration file is missing")
        failed_count = failed_count + 1 
    end
    if (tableHelper.isEmpty(config) == true) then
        tes3mp.LogMessage(enumerations.log.ERROR, ScriptName .. "table is Empty or not loaded, This should not happen")
        failed_count = failed_count + 1 
    end
    if not (config['debug'] == true or config['debug'] == false) then
        tes3mp.LogMessage(enumerations.log.ERROR, ScriptName .. "debug must be set to true or false")
        failed_count = failed_count + 1 
    end
    if (config['token'] == nil or config['token'] == "") then
        tes3mp.LogMessage(enumerations.log.ERROR, ScriptName .. "token is missing")
        failed_count = failed_count + 1 
    end
    if not (config['enableLocal'] == true or config['enableLocal'] == false) then
        tes3mp.LogMessage(enumerations.log.ERROR, ScriptName .. "enableLocal must be set to true or false")
        failed_count = failed_count + 1
    end
    if (config['local_Channel'] == nil or config['local_Channel'] == "" and config['enableLocal'] == true) then
        tes3mp.LogMessage(enumerations.log.ERROR, ScriptName .. "local_Channel cannot be blank")
        failed_count = failed_count + 1 
    end
    if not (config['enableOOC'] == true or config['enableOOC'] == false) then
        tes3mp.LogMessage(enumerations.log.ERROR, ScriptName .. "EnableOOC must be set to true or false")
        failed_count = failed_count + 1 
    end
    if (config['ooc_Channel'] == nil or config['ooc_Channel'] == "" and config['enableOOC'] == true) then
        tes3mp.LogMessage(enumerations.log.ERROR, ScriptName .. "ooc_Channel cannot be blank")
        failed_count = failed_count + 1 
    end
    if (config['oocPrefix'] == nil or config['oocPrefix'] == "" and config['enableOOC'] == true) then
        tes3mp.LogMessage(enumerations.log.ERROR, ScriptName .. "oocPrefix cannot be blank")
        failed_count = failed_count + 1 
    end
    if not (config['enableLOOC'] == true or config['enableLOOC'] == false) then
        tes3mp.LogMessage(enumerations.log.ERROR, ScriptName .. "enableLOOC must be set to true or false")
        failed_count = failed_count + 1 
    end
    if (config['looc_Channel'] == nil or config['loocPrefix'] == "" and config['enableLOOC'] == true) then
        tes3mp.LogMessage(enumerations.log.ERROR, ScriptName .. "looc_Channel cannot be blank")
        failed_count = failed_count + 1 
    end
    if (config['loocPrefix'] == nil or config['loocPrefix'] == "" and config['enableLOOC'] == true) then
        tes3mp.LogMessage(enumerations.log.ERROR, ScriptName .. "loocPrefix cannot be blank")
        failed_count = failed_count + 1 
    end
    if not (config['showStaffRanks'] == true or config['showStaffRanks'] == false) then
        tes3mp.LogMessage(enumerations.log.ERROR, ScriptName .. "showStaffRanks must be set to true or false")
        failed_count = failed_count + 1 
    end
    if (config['ModeratorPrefix'] == nil or config['ModeratorPrefix'] == "" and config['showStaffRanks'] == true) then
        tes3mp.LogMessage(enumerations.log.ERROR, ScriptName .. "ModeratorPrefix cannot be blank")
        failed_count = failed_count + 1 
    end
    if (config['AdminPrefix'] == nil or config['AdminPrefix'] == "" and config['showStaffRanks'] == true) then
        tes3mp.LogMessage(enumerations.log.ERROR, ScriptName .. "AdminPrefix cannot be blank")
        failed_count = failed_count + 1 
    end
    if (config['OwnerPrefix'] == nil or config['OwnerPrefix'] == "" and config['showStaffRanks'] == true) then
        tes3mp.LogMessage(enumerations.log.ERROR, ScriptName .. "OwnerPrefix cannot be blank")
        failed_count = failed_count + 1 
    end    
    if (failed_count > 0) then
        tes3mp.LogMessage(enumerations.log.ERROR, ScriptName .. tostring(failed_count) .. " " .. "errors occured while initializing DiscordRelay")
    end
    local warnings = 0
    if (config['enableLocal'] == false) then 
        tes3mp.LogMessage(enumerations.log.WARN, ScriptName .. "[ " .."Local Chat is Disabled via config file" .." ]")
        warnings = warnings + 1
    end
    if (config['enableOOC'] == false) then 
        tes3mp.LogMessage(enumerations.log.WARN, ScriptName .. "[ " .."OOC Chat is Disabled via config file" .." ]")
        warnings = warnings + 1
    end
    if (config['enableLOOC'] == false) then 
        tes3mp.LogMessage(enumerations.log.WARN, ScriptName .. "[ " .."Local OOC Chat is Disabled via config file" .." ]")
        warnings = warnings + 1
    end
    if (failed_count == 0) then
    tes3mp.LogMessage(enumerations.log.INFO, ScriptName .. "DiscordRelay Started with " ..failed_count.. " Errors and "..warnings.. " warnings.")
    end
    if (failed_count < 0 or failed_count == nil) then
        tes3mp.LogMessage(enumerations.log.ERROR, ScriptName .. "----------------------------------")
        tes3mp.LogMessage(enumerations.log.ERROR, ScriptName .. tostring(failed_count) .. " Errors " .. "| 404 MATH NOT FOUND")
        tes3mp.LogMessage(enumerations.log.ERROR, ScriptName .. "----------------------------------")
        tes3mp.LogMessage(enumerations.log.ERROR, ScriptName .. "You Should never see this, if you continue getting this error, you should contact me")
        tes3mp.LogMessage(enumerations.log.ERROR, ScriptName .. tostring(SCRIPT.Author))
        tes3mp.LogMessage(enumerations.log.ERROR, ScriptName .. "----------------------------------")
    end end


SCRIPT:Register()