//checked includes match cerberus output
#include maps/mp/zombies/_zm_magicbox;
#include maps/mp/zombies/_zm_game_module;
#include maps/mp/gametypes_zm/_zm_gametype;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;

precache() //checked matches cerberus output
{
}

main() //checked matches cerberus output
{
	maps/mp/gametypes_zm/_zm_gametype::setup_standard_objects( "working" );
	maps/mp/zombies/_zm_game_module::set_current_game_module( level.game_module_standard_index );
	flag_wait( "initial_blackscreen_passed" );
	flag_set( "power_on" );
	zm_treasure_chest_init();
}

zm_treasure_chest_init() //checked matches cerberus output
{
	chest1 = getstruct( "start_chest", "script_noteworthy" );
	level.chests = [];
	level.chests[ level.chests.size ] = chest1;
	maps/mp/zombies/_zm_magicbox::treasure_chest_init( "start_chest" );
}
