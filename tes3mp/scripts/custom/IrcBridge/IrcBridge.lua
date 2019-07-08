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
	nickfilter = "",
	usrColor = "#7289da"
}

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
local nickfilter = IrcBridge.config.nickfilter
local usrColor = IrcBridge.config.usrColor
local port = IrcBridge.config.port

IRCTimerId = nil

local s = irc.new {nick = nick}
s:connect(server, port)
nspasswd = "identify " .. nspasswd
s:sendChat("NickServ", nspasswd)
s:join(channel)
local lastMessage = ""


IrcBridge.RecvMessage = function()
	local message

	s:hook("OnChat",function(user, channel, message)
		if lastMessage ~= message and tableHelper.getCount(Players) > 0 then
			for pid, player in pairs(Players) do
				if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
					user.nick = string.gsub(user.nick, nickfilter, "")
					tes3mp.SendMessage(pid, usrColor .. "[" .. user.nick .. "]" .. color.Default .. " " .. message .. "\n", true)
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

function OnIRCUpdate()
	IrcBridge.RecvMessage()
	s:think()
end

customEventHooks.registerValidator("OnPlayerSendMessage", function(eventStatus, pid, message)
	CharName = tes3mp.GetName(pid)
	message = tostring(message)
	
	if message:sub(1, 1) == "/" then
		return
	else
		IrcBridge.SendMessage(CharName .. ": " .. message)
	end
end)

customEventHooks.registerValidator("OnServerInit", function()
	IRCTimerId = tes3mp.CreateTimer("OnIRCUpdate", time.seconds(1))
end)

customEventHooks.registerValidator("OnServerInit", function()
	tes3mp.StartTimer(IRCTimerId)
end)

customEventHooks.registerValidator("OnServerExit", function()
	tes3mp.StopTimer(IRCTimerId)
	s:shutdown()
end)
