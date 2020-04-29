# Debug mod

Due to the lack of developer mode in bo2 I decided to go ahead and make my own debugging method.
Basically, I use this script called _zm_bot.gsc to act as a developer mode for the scripts.
What is does it override the typical _zm_bot.gsc logic, and replaces it with global variables that when active enable logprint() functions throughout supported scripts.

**Currently only the following scripts are supported**:
```
zgrief.gsc
_zm_ai_dogs.gsc
_zm_audio.gsc
_zm_magicbox.gsc
_perks.gsc
_zm_perk_electric_cherry.gsc
_zm_powerups.gsc
_zm_spawner.gsc
_zm_weapons.gsc


```

## How it Works

Compile _zm_bot.gsc as _zm_bot.gsc and place it in maps/mp/zombies. It automatically has the debug variables set to 1 so it will be active.
It works by writing to the log useful events that may need monitoring in order to determine broken aspects of the script.
To disable it simply remove the mod or modify the vars in the mod.

If using mp compile _clientids.gsc as _clientids.gsc and place it in maps/mp/gametypes.

## How to Make Use of The Mod

If you want to debug scripts on your own copy and paste this template into the code you would like to monitor:
```
if ( ( level.errorDisplayLevel == 0 || level.errorDisplayLevel == 1 ) && debugModDebugLogging_GSC_FILE_NAME )
{
	logline1 = "ERROR_TYPE: GSC_FILE_NAME.gsc FUNCTION_THIS_IS_CALLED_IN yourtext" + "\n";
	logprint( logline1 );
}
```
If you would like ingame print messages use this code:
```
if ( ( level.errorDisplayLevel == 0 || level.errorDisplayLevel == 1 ) && debugModDebugLogging_GSC_FILE_NAME )
{
	players = get_players();
	players[ 0 ] iprintln( "ERROR_TYPE: GSC_FILE_NAME.gsc FUNCTION_THIS_IS_CALLED_IN yourtext" );
}

```
By using this template to debug your code you can run multiple loglines that will print to your server log in data/logs.
Key:
```
ERROR_TYPE = INFO or ERROR or WARNING
GSC_FILE_NAME = This is very useful when debugging multiple scripts at once
FUNCTION_THIS_IS_CALLED_IN = This will allow you to easily keep track of multiple functions in your script
```
If you would like to debug a script that isn't already supported use this template and place it in the very top of the init() in whatever script you would like to debug:
```
//begin debug code
level.custom_GSC_FILE_NAME_loaded = 1;
//if mp 
maps/mp/gametypes/_clientids::init();
//if zm
maps/mp/zombies/_zm_bot::init();
if ( !isDefined( level.debugLogging_GSC_FILE_NAME ) )
{
	level.debugLogging_GSC_FILE_NAME = 0;
}
//end debug code
```
and then put this in the _zm_bot.gsc debug_tracker() included with this guide:
```
if ( isDefined( level.custom_GSC_FILE_NAME_loaded ) && level.custom_GSC_FILE_NAME_loaded )
{
	level.debugLogging_GSC_FILE_NAME = getDvarIntDefault( "debugModDebugLogging_GSC_FILE_NAME", 1 );
	numberOfScriptsBeingLogged++;
}
```
If using mp use the _clientids.gsc instead.
In both of these replace GSC_FILE_NAME with the name of the .gsc you are debugging.


