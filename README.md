## This repo is deprecated and no longer being worked on, It's replacement can be here: https://github.com/HotaruBlaze/goTES3MP 

# Discord Relay for TES3MP 0.7.0 (Webhook Branch)
 This is one of my first attempts at scripting for TES3MP and Lua

## **(Read note below)**

**Note: Due to limiations with Lua, we are unable to use wss (websockets), This prevents the ability to have Discord -> tes3mp chat.**
**You can follow progress here https://github.com/MrFlutters/TES3MP_DiscordRelay/issues/1**

**This branch has been tweaked to use webhooks as an "Lazy and quick" working alternative, while a more elegant solution is planned**

# Contributing

Feel free to submit Issues and Pull Requests. 

>Consistent tabulation  
>lowerCamelCase for local and global variables  
>UpperCamelCase for function names.

# Warnings / Known issues

 - Currently, this only sends chat to discord `(TES3MP -> Discord)`. It does not show discord messages in-game `(Discord -> TES3MP)`
 - Designed for [rpChat](https://github.com/SaintWish/tes3mp_scriptloader/blob/master/scripts/addons/rpChat.lua) primarily, however Local/Normal chat will still work even if you don't have rpChat.
- This does not work on Windows yet. Unfortunately, Discord requires us to use SSL and we use luasec 0.8, I currently dont have the library files required for windows
 
# Installation

- Copy the folders `lib/` and `script/` into `server` (or Corescripts folder).
- Add `DiscordRelay = require("custom/DiscordRelay/main")` to `scripts/customScripts.lua`
- Start your TES3MP server, You should see <br> `[ERR]: [Script]: [DiscordRelay] webhook_url is blank or empty.` <br> if not you have not followed the steps correctly or have an compatability issue

- Edit config found at **`data/custom/__config_DiscordRelay.json`**


# How to create a webhook
1) Create or select the channel you would like to use

2) Right click and edit the channel
>![webhook-img1](https://img.fluttershub.com/qG1EpNjRnY7E.png)

3) Select webhook from the side menu
>![webhook-img2](https://img.fluttershub.com/9rIuKMCh53j9.png)

4) Create a webhook and customize it as you see fit
>![webhook-img3](https://img.fluttershub.com/xvsyAKXYCQAo.png)
### **Note: At this time the bot's name is set to the players name with no configuration option, So the name does not matter**

5) Add the webhook to **`data/discord_config.json`**

6) You should see something like below when a player types ingame.
>![webhook-img4](https://img.fluttershub.com/AUpi2uffuJZz.png)
