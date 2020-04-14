# Debug mod

Due to the lack of developer mode in bo2 I decided to go ahead and make my own debugging method.
Basically, I use this script called _zm_bot.gsc to act as a developer mode for the scripts.
What is does it override the typical _zm_bot.gsc logic, and replaces it with global variables that when active enable logprint() functions throughout supported scripts.

**Currently only the following scripts are supported**:
```
_zm_ai_dogs.gsc
```

## How it Works

Compile _zm_bot.gsc as _zm_bot.gsc and place it in maps/mp/zombies. It automatically has the debug variables set to 1 so it will be active.
It works by writing to the log useful events that may need monitoring in order to determine broken aspects of the script.
To disable it simply remove the mod or modify the vars in the mod.
