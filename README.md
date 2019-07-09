
# Discord Relay for TES3MP 0.7.0-alpha (irc-relay Branch)
 This branch uses [matterbridge](https://www.github.com/42wim/matterbridge) and an updated IrcBridge for 0.7.0-alpha

#### Note: This is currently the only branch that offers tes3mp <-> discord cross-chat.

# READ THIS / WARNINGS

 - This specific branch is **not** designed to be user-friendly, you are expected to understand IRC and Discord Bot Creation/Usage <br>
 - I provide a docker-compose example of how you could deploy this in `external/`
 - You do not have to run your own IRC server, you **can** use a public one but not recommend. 
 - **matterbridge is required.**
 - This repo only provides Linux compatible libarys, you will need to source windows ones yourself.

## Instalation settings for tes3mp.

- Copy the folders and files located in `tes3mp/` and drop them into your `server (or coreScripts)` folder.
- add `IrcBridge = require("custom/IrcBridge/IrcBridge")` to `server/scripts/customScripts.lua`
- After first launch of the server, a configuration file will be generated in `data/custom/` called `__config_IrcBridge.json`
- if you see the following `[ERR]: [Script]: IrcBridge has not been configured correctly`.<br> a configuration file already exists, however is missing values.
*(nick, server and channel are required.)*

## Credits
- TeamFOSS for creating a IrcBridge used for tes3mp 0.6.1 located [***here***](https://github.com/TES3MP-TeamFOSS/Scripts/tree/master/0.6.1/scripts/IrcBridge)
- Hotaru / MrFlutters for updating the Script for 0.7.0
- matterbridge for making this setup possible

 # Contributing

Feel free to submit Issues and Pull Requests. 

>Consistent tabulation  
>lowerCamelCase for local and global variables  
>UpperCamelCase for function names.