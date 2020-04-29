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

## How to Make Use of The Mod

If you want to debug scripts on your own copy and paste this template into the code you would like to monitor:
```
if ( ( level.errorDisplayLevel == 0 || level.errorDisplayLevel == 1 ) && level.debugLogging_zm_audio )
{
	logline1 = "ERROR_TYPE: GSC_FILE_NAME.gsc FUNCTION_THIS_IS_CALLED_IN yourtext" + "\n";
	logprint( logline1 );
}
```
By using this exact template to debug your code you can run multiple loglines that will print to your server log in data/logs.
Key:
ERROR_TYPE = INFO or ERROR or WARNING use these to indicate whether a log message is just information or is an unexpected error or something isn't right.
GSC_FILE_NAME = this is the actual .gsc you are currently debugging this can be useful if you are debugging mutliple scripts at once so it easier to sift thru the log.
FUNCTION_THIS_IS_CALLED_IN = use this to indicate what function this log message is inside of to again make it easier to tell what messages are coming from what.
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
In both of these replace GSC_FILE_NAME with the name of the .gsc you are debugging.

