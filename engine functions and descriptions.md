# Black Ops 2 Functions Descriptions and Locations List

## Built in Functions:

getgametypesetting( STRING ) - returns the value of a gametypesetting based on the STRING input
- STRING 
getentitynumber() -

getentarray() - returns an array of all entities on the map currently OPTIONAL ARGS:
- STRING arg1: makes the function return all of the entities with this name based on arg2
- STRING arg2: can be targetname or classname depending on the array of arg1

getbaseweaponitemindex( weapon_name ) - 
- weapon_name is a STRING

getreffromitemindex( weapon_name ) -
- weapon_name is a STRING

giveweapon( weapon_name ) - gives the entity a weapon
- weapon_name is a STRING

switchtoweapon( weapon_name ) - forces the entity to switch to the indicated weapon entity must have the weapon for the switch to occur

getplayerviewheight() - returns the view height of the entity

getcurrentweapon() - returns the name of the current weapon as a string that the entity is holding

gettime() - returns the current time since the game has started as milliseconds increments in 0050

getweaponammostock() - returns the remaining ammo stock in the weapon the entity is holding

setweaponammoclip( weapon_name, weapon_clip_to_give ) - sets the weapon clip of the weapon for the entity
- STRING weapon_name: the name of the weapon
- INT weapon_clip_to_give the amount of ammo to set the clip to

setweaponammostock( weapon_name, weapon_stock_to_give ) - sets the weapon stock of the weapon for the entity
- STRING weapon_name: the name of the weapon 

isthrowinggrenade() - returns a boolean must be called on an entity

isreloading() - returns a boolean must be called on an entity

isswitchingweapons() - returns a boolean must be called on an entity

ismantling() - returns a boolean must be called on an entity

isonladder() - returns a boolean must be called on an entity

isalive( entity ) - returns a boolean

isplayer( entity ) - returns a boolean

isai( entity ) - returns a boolean based on whether the input is an AI

loadfx( effect ) - loads an effect in

randomfloatrange( float1, float2 ) - returns a random float with a value between the 2 inputs values

playerads() - 

pixendevent() -

predictspawnpoint( spawnpoint.origin, spawnpoint.angles ) -

spawn() -

setclientnamemode( STRING ) -

### AI related engine functions

allowattack( boolean ) - controls whether the entity is allowed to attack

addgoal( goal, goal_radius, goal_priority, goal_name ) - gives the AI a goal where:
- goal: is generally an entity's or object's origin
- INT goal_radius: is how close the AI has to be for the goal to be completed
- INT goal_priority: is how high a priority the AI has in accomplishing the goal over other goals
- STRING goal_name: is used by other goal functions like atgoal( goal_name )  or cancel( goal_name )

atgoal( goal ) - returns a boolean if the AI is at the goal input

cancelgoal( goal ) - cancels the current goal the AI has

pressads( boolean ) - makes an entity press the ads button

pressattackbutton( duration ) - makes an entity press the attack button for a duration

pressusebutton( duration ) - makes an entity press the use buton for the duration

pressmelee() - makes an entity press the melee button

gethreats( fov ) - returns the enemies in the AIs fov accepts -1 as an input

botsighttracepassed( entity ) - returns a boolean if the entity is visible to the entity it being called on

### Math functions


## Shared Script Based Functions Between Zombies and MP

maps/mp/_utility::is_bot() - returns the value of self.pers[ "bot" ], this var is always set on a bots spawn

common_scripts/utility::cointoss() - returns a specific boolean 50% of the time