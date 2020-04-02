# About this project

The way scripts are categorized is based on their current functionality. 
***The objective of this project is to get as many scripts in the No Known Erorrs category.*** 
Eventually, once scripts have been tested even more thoroughly there will be a new category for scripts that have parity with the original scripts.

### The current categories are:

**No Known Errors**: This means that during a short gameplay test no errors are observed.
It can also mean that the script is unused such as the _hackables series meaning that while they are being parsed nothing is calling them.

**Minor Errors**: Indicates that the scripts are functional but perhaps there is a typo in text shown on screen or other ui error.
It means that while the script doesn't have 100% parity with the base script it nears 100% and all the expected core functionality of the script works.

**Major Errors**: The scripts' core functionality is missing or broken so that anything from crashes occur during gameplay or perks not working.
Any script categorized as having major errors is not yet in a playable state unlike scripts with only Minor or No Known Errors.

**exe_client_field_mismatch**: This is a specific error that doesn't have a specific cause.
Scripts that cause this error will run serverside but clients cannot join due to this error.

**Severe Errors**: Minidump, hang on map_rotate, crash, or other error that prevents the server from starting up is in this category.
This type of error can be caused by many different things

Each script will be sorted by its location e.g. patch_zm/maps/mp/zombies check the markdown in each folder to see the current status of a script