
# Discord Relay for TES3MP 0.7.0

 This is one of my first attempts at scripting for TES3MP and Lua

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

# How to get a channel ID

1) Open your **Client** settings and go to **`Appearence`**.

2) Scroll down to Advanced and enable **`Developer Mode`**.
>![developermode_img](https://img.fluttershub.com/6ajUxrQBcTef.png)

3) Now simply right click a channel and select **`Copy ID`**
>![id_img](https://img.fluttershub.com/Udkgniqn8QP0.png)

4) Paste the ID into the corresponding channel in **`discord_config.json`**

___

# How to create a Discord Bot

1) Create a new application [here](https://discordapp.com/developers/applications/).

2) Go to Bot and click "Add Bot".

3) Click **` Click to Reveal Token`** and copy it for later.
>![token_img](https://img.fluttershub.com/f1q8DPpxC3a1.png)
 

4) Go to OAuth2 and select the **`bot`** scope and **`Send Messages`** from Bot Permissions
>![scope_img1](https://img.fluttershub.com/LqTv8FyN1n8U.png)

>![perm_img1](https://img.fluttershub.com/oJXH0tJ199KF.png)

  

5) Copy the url provided by scopes and paste it into your browser
>![scope_img2](https://img.fluttershub.com/uXQR1nJ57UfH.png)

  

6) Select your server from the dropdown and hit **`Authorize`**
>![invite_img](https://img.fluttershub.com/M7XvrIMezdiX.png)

7) Now edit your **`data/discord_config.json`** and put your token from earlier into token
![configtoken_img](https://img.fluttershub.com/iNKjVnctMeVs.png)