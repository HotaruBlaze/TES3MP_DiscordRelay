
# Discord Relay for TES3MP 0.7.0 (Webhook Branch)
 This is one of my first attempts at scripting for TES3MP and Lua

## **(Read note below)**

**Note: Due to issues talking to Discord Gateway easily to keep a bot online due to lua not supporting wss (weboscket) at this time**

**This branch has been tweaked to use webhooks as an "Lazy and quick" working alternative, while a more elegant solution is planned**

# Contributing

Feel free to submit Issues and Pull Requests. 

Ensure that your pull requests/issues follow the same requirements as [Script Loader](https://github.com/SaintWish/tes3mp_scriptloader#commits-and-bug-reports). For reference...

>Consistent tabulation  
>lowerCamelCase for local and global variables  
>UpperCamelCase for function names.

# Warnings / Known issues

 - Currently, this only sends chat to discord `(TES3MP -> Discord)`. It does not show discord messages in-game `(Discord -> TES3MP)`
 - Designed for [rpChat](https://github.com/SaintWish/tes3mp_scriptloader/blob/master/scripts/addons/rpChat.lua) primarily, however Local/Normal chat will still work even if you don't have rpChat.
- This does not work on Linux yet. Unfortunately, Discord requires us to use SSL, and that requires luasec 0.6 and/or 0.7, I currently dont have the library files required for linux
 
# Requirements

- [Script Loader](https://github.com/SaintWish/tes3mp_scriptloader)  

# Installation

- Copy the folders `data/`, `lib/` and `script/` into `mp-stuff` (or Corescripts folder).
- Edit **`data/discord_config.json`**
- Add `discordRelay` to **`data/scripts.json`**

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