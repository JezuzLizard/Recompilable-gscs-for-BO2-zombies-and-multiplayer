# Black Ops 2 Functions Descriptions and Locations List

### Built in Functions:

isthrowinggrenade() - returns 1 if the player is currently throwing a grenade or 0 if they are not
- must be called on a player

loadfx( effect ) - loads an effect in
usage - level._effect[ "building_dust" ] = loadfx( "maps/zombie/fx_zmb_buildable_assemble_dust" );

### Functions in _zm_utility.gsc:

convertsecondstomilliseconds( seconds ) - returns seconds multiplied by 1000
usage - use this to compare actual seconds with getTime() which uses milliseconds

in_revive_trigger() - returns 1 if the player is currently in a revive trigger or 0 if they are not
- must be called on a player

is_classic() - returns 1 if the value of getDvar( "ui_zm_gamemodegroup" ) is "zclassic" returns 0 otherwise

is_player() - returns 0 if not called on a player, returns 0 if called on a bot, returns 1 otherwise

is_standard() - returns 1 if the value of getDvar( "ui_gametype" ) is "zstandard" returns 0 otherwise

lerp( chunk ) -

clear_mature_blood() - deletes blood patches if is_mature() returns 0

recalc_zombie_array() - empty function

clear_all_corpses() - deletes all corpses when called

get_current_corpse_count() - returns the number of corpses, if corpses are not defined returns 0

get_current_actor_count() - returns the number of alive zombies and corpses combined

get_round_enemy_array() - returns an array of the enemies on the level.zombie_team if an enemy has the property .ignore_enemy_count
they are not included

init_zombie_run_cycle() - picks whether a zombie should have different speed on spawn
- must be called on a zombie

change_zombie_run_cycle() - sets a zombies speed depending on the difficulty on easy zombies are sprinters on normal they are walkers
- must be called on a zombie

speed_change_watcher() - reduces the counter that tracks the number of zombies with unique speeds such as walkers or sprinters when they die
- must be called on a zombie

set_zombie_run_cycle( new_move_speed ) - sets a zombies speed to the new_move_speed input
- valid inputs are walk, run, sprint, super_sprint, and bus_sprint( tranzit maps only )
- must be called on a zombie

set_run_speed() - sets a zombies movespeed randomly on spawn on normal difficulty
- must be called on a zombie

set_run_speed_easy() = sets a zombies movespeed randomly on spawn on easy difficulty
- must be called on a zombie

spawn_zombie( spawner, target_name, spawn_point, round_number )
- 

