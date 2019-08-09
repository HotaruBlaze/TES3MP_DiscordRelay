-- IrcBridge.lua -*-lua-*-
-- "THE BEER-WARE LICENCE" (Revision 42):
-- <mail@michael-fitzmayer.de> wrote this file.  As long as you retain
-- this notice you can do whatever you want with this stuff. If we meet
-- some day, and you think this stuff is worth it, you can buy me a beer
-- in return.  Michael Fitzmayer

require("color")
require("irc")

local IrcBridge = {}

IrcBridge.scriptName = "IrcBridge"

IrcBridge.defaultConfig = {
	nick = "",
	server = "",
	port = "6667",
	nspasswd = "",
	channel = "#",
	alertChannel = "#",
	nickfilter = "",
	usrColor = "#7289da",
	enableNotify = true,
	enableSpamKick = false,
	kickThreshold = 5,
	enableSpamBan = false,
	kicksBeforeBan = 3,
}

local relayData = {}

---- "Borrowed" from kanaBank -- 
---- https://github.com/Atkana/tes3mp-scripts/blob/master/0.7/kanaBank/kanaBank.lua#L70-L84"
IrcBridge.Save = function()
	jsonInterface.save("custom/relayData.json", relayData)
end

IrcBridge.Load = function()
	local loadedData = jsonInterface.load("custom/relayData.json")
	
	if loadedData then
		relayData = loadedData
	else
		IrcBridge.Save()
	end
end
----

IrcBridge.config = DataManager.loadConfiguration(IrcBridge.scriptName, IrcBridge.defaultConfig)

if (IrcBridge.config == IrcBridge.defaultConfig) then
	tes3mp.LogMessage(enumerations.log.WARN, "IrcBridge configuration has been generated,")
	tes3mp.StopServer(0)
end

if (IrcBridge.config.nick == "" or IrcBridge.config.server == "" or IrcBridge.config.channel == "#") then
	tes3mp.LogMessage(enumerations.log.ERROR, "IrcBridge has not been configured correctly." .. "\n" .. "nick, server and channel are required.")
	tes3mp.StopServer(0)
end

local nick = IrcBridge.config.nick
local server = IrcBridge.config.server
local nspasswd = IrcBridge.config.nspasswd
local channel = IrcBridge.config.channel
local alertChannel = IrcBridge.config.alertChannel
local nickfilter = IrcBridge.config.nickfilter
local usrColor = IrcBridge.config.usrColor
local port = IrcBridge.config.port

IRCTimerId = nil

local s = irc.new {nick = nick}
s:connect(server, port)
nspasswd = "identify " .. nspasswd
s:sendChat("NickServ", nspasswd)
s:join(channel)
s:join(alertChannel)
local lastMessage = ""

IrcBridge.RecvMessage = function()
	local message

	s:hook("OnChat",function(user, channel, message)
		if lastMessage ~= message and tableHelper.getCount(Players) > 0 then
			for pid, player in pairs(Players) do
				if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
					user.nick = string.gsub(user.nick, nickfilter, "")
					tes3mp.SendMessage(pid, usrColor .. "[" .. user.nick .. "]" .. color.Default .. " " .. message .. "\n", true)
					tes3mp.LogMessage(enumerations.log.INFO, "[" .. user.nick .. "]" .. " " .. message .. "\n")
					lastMessage = message
					break
				end
			end
		end
	end)

	s:hook("OnChat",function(user, alertChannel, message)
		if lastMessage ~= message and tableHelper.getCount(Players) > 0 then
			for pid, player in pairs(Players) do
				if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
					user.nick = string.gsub(user.nick, nickfilter, "")
					tes3mp.SendMessage(pid, usrColor .. "[" .. user.nick .. "]" .. color.Default .. " " .. message .. "\n", true)
					tes3mp.LogMessage(enumerations.log.INFO, "[" .. user.nick .. "]" .. " " .. message .. "\n")
					lastMessage = message
					break
				end
			end
		end
	end)

	tes3mp.RestartTimer(IRCTimerId, time.seconds(1))
end

IrcBridge.SendMessage = function(message)
	s:sendChat(channel, message)
end

IrcBridge.SendAlertMessage = function(message)
	s:sendChat(alertChannel, message)
end

IrcBridge.strSplit = function(delim, str)
    local t = {}
    for substr in string.gmatch(str, "[^".. delim.. "]*") do
        if substr ~= nil and string.len(substr) > 0 then
            table.insert(t,substr)
        end
    end
    return t
end

IrcBridge.formatMessage = function(pid, message, verifyString)
	local formattedMsg = ""
	local wordRemoved = "`[REMOVED]`"
	local msgArray = IrcBridge.strSplit(" ", message)

	-- This could probably be cleaned up severly but eh
	local count = 0
	for _ in pairs(msgArray) do 
		count = count + 1
	end

	-- Count Word Array 
	for i = 1, count do
		local badWord = false
		-- Get Current Word
		local word = msgArray[i]
		
		-- Read Characters in word 
		for i = 1, string.len(word) do
			char = string.sub(word,i,i)
			-- If Forbidden Character is found, set badWord to true
			if string.byte(char) < 32 or string.byte(char) > 126 then
				badWord = true
			end
		end
		if badWord == true then
			msgArray[i] = wordRemoved
			if verifyString == false then
				IrcBridge.spamKick(pid)
			end
		end
		if badWord == true and verifyString == true then
			return false
		end 
	end

	if verifyString == false then
		relayData[playerName].filteredCount = relayData[playerName].filteredCount + 1
	end
	return msgArray
end

IrcBridge.spamKick = function(pid)
	local playerName = tes3mp.GetName(pid)

	if relayData[playerName].filteredCount == IrcBridge.config.kickThreshold or 
	   relayData[playerName].filteredCount > IrcBridge.config.kickThreshold then

		local name = "[TES3MP]"
		local warnMsg = "has triggered the kick Threshold and been kicked."
		local playerMessage = usrColor .. name .. color.Error .. " " .. '"' .. playerName .. '"' .. " " .. warnMsg
		local discordMessage = name .. " " .. '"' .. playerName .. '" ' .. " " .. warnMsg

		-- Check if player should be banned.
		if IrcBridge.config.enableSpamBan == true then
			if relayData[playerName].kickedCount < IrcBridge.config.kicksBeforeBan then
				IrcBridge.spamBan(pid)
			end
		end
		if IrcBridge.config.enableSpamKick == true then
			tes3mp.LogMessage(enumerations.log.INFO, discordMessage .. "\n", true)
			relayData[playerName].filteredCount = 0
			relayData[playerName].kickedCount = relayData[playerName].kickedCount + 1
			tes3mp.SendMessage(pid, playerMessage .. color.Default, false)
			if IrcBridge.config.enableAlert == true then
				IrcBridge.discordNotify(discordMessage)
			end
			tes3mp.Kick(pid)
		end
	end
end

IrcBridge.spamBan = function(pid)
	-- local playerName = tes3mp.GetName(pid)
	-- if relayData[playerName] == nil then
	-- 	relayData[playerName] = {}
	-- end
	-- local message = "[TES3MP]"
	-- local warnMsg = "has triggered the ban Threshold and been kicked."
	-- local playerMessage = usrColor .. message .. color.Error .. message .. '"' .. playerName .. '"' .. " " .. warnMsg
	-- local message = message .. " " .. '"' .. playerName .. '"' .. " " .. warnMsg

	-- tes3mp.LogMessage(enumerations.log.INFO, message .. "\n", true)
	-- if IrcBridge.config.enableAlert == true then
	-- 	IrcBridge.discordAlert(discordMessage)
	-- end
	-- tes3mp.kick(pid)
	tes3mp.LogMessage(enumerations.log.INFO, "This is currently not functional." .. "\n", true)

end

IrcBridge.discordAlert = function(message)
	local message = "**" .. message .. "**"
	IrcBridge.SendAlertMessage(message)
end

IrcBridge.discordNotify = function(message)
	IrcBridge.SendMessage(message)
end


function OnIRCUpdate()
	IrcBridge.RecvMessage()
	s:think()
end


customEventHooks.registerValidator("OnPlayerSendMessage", function(eventStatus, pid, message)
	if lastMessage == nil then
		lastMessage = ""
	end

	playerName = tes3mp.GetName(pid) 

	if relayData[playerName] == nil then
		relayData[playerName] = {}
	end
	if relayData[playerName].filteredCount == nil then
		relayData[playerName].filteredCount = 0
	end
	if relayData[playerName].kickedCount == nil then
		relayData[playerName].kickedCount = 0 
	end 
	if relayData[playerName].warned == nil then
		relayData[playerName].warned = false
	end 
	
	-- Lets block any / commands
	if message:sub(1, 1) == "/" then
		return
	else
		if lastMessage == message then
			if IrcBridge.formatMessage(pid, message, true) == false then
				relayData[playerName].filteredCount = relayData[playerName].filteredCount + 1
			end
			IrcBridge.spamKick(pid) 
		else
			local message = IrcBridge.formatMessage(pid, message)
			local message = tableHelper.concatenateFromIndex(message, 1) 
			-- tes3mp.SendMessage(pid, message .. color.Default, false)
			IrcBridge.SendMessage(playerName .. ": " .. message)
		end
		-- if relayData[playerName].filteredCount == 1 and IrcBridge.config.enableSpamKick == true and relayData[playerName].warned == false then 
		-- 	-- Warn the user that we auto-kick
		-- 	local message = usrColor .. "[Discord] " .. color.Error
		-- 	local message = message .. "Your message contained invalid characters and was edited." .. "\n"
		-- 	local message = message .. "We do not allow spam or non-english characters." .. "\n"
		-- 	tes3mp.SendMessage(pid, message .. color.Default, false)
		-- 	relayData[playerName].warned = true
		-- end
	end
	lastMessage = message
	IrcBridge.Save()
end)

customEventHooks.registerValidator("OnServerInit", function()
	-- Create IRC "Heartbeat"
	IRCTimerId = tes3mp.CreateTimer("OnIRCUpdate", time.seconds(1))

	-- Load the Relay Data
	IrcBridge.Load()

	-- Start the IRC "Heartbeat"
	tes3mp.StartTimer(IRCTimerId)

	if IrcBridge.config.enableAlert == true then
		local message = "[TES3MP]"
		local message = message .. " Server is online. :yellow_heart:"
		-- local message = "https://cdn.discordapp.com/attachments/546181963468242974/609529190278103041/Server_-_Online.png"
		IrcBridge.discordAlert(message)
	end

end)

customEventHooks.registerHandler("OnPlayerAuthentified", function(eventStatus, pid)
	if IrcBridge.config.enableNotify == true then
		if pid ~= nil and Players[pid]:IsLoggedIn() then
			-- -- Lets Make sure this gets reset
			-- if relayData[playerName].warned == nil or  then
			-- 	relayData[playerName].warned = false
			-- end
			-- if relayData[playerName].filteredCount > 0 then
			-- 	relayData[playerName].filteredCount = 0
			-- end
			local message = "[TES3MP]"
			playerName = tes3mp.GetName(pid)

			local message = message .. " " .. playerName .." ".. "has joined the server."
			IrcBridge.discordNotify(message)
		end
	end
end)

customEventHooks.registerHandler("OnPlayerDisconnect", function(eventStatus, pid)
	if IrcBridge.config.enableNotify == true then
		if pid ~= nil then
			local message = "[TES3MP]"
			playerName = tes3mp.GetName(pid)

			local message = message .. " " .. playerName .." ".. "has left the server."
			IrcBridge.discordNotify(message)
		end
	end
end)

customEventHooks.registerHandler("OnServerExit", function()
	if IrcBridge.config.enableNotify == true then
		local message = "[TES3MP]"
		local message = message .. " Server is offline. :warning:"
		-- local message = "https://cdn.discordapp.com/attachments/546181963468242974/609529176483037225/Server_-_Offline.png"
		IrcBridge.discordAlert(message)
	end
	IrcBridge.Save()
	tes3mp.StopTimer(IRCTimerId)
	s:shutdown()
end)