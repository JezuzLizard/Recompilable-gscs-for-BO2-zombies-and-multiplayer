#include maps/mp/zombies/_zm_magicbox;
#include maps/mp/zombies/_zm_game_module;
#include maps/mp/gametypes_zm/_zm_gametype;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;

precache()
{
}

main()
{
	maps/mp/gametypes_zm/_zm_gametype::setup_standard_objects( "nuked" );
	maps/mp/zombies/_zm_game_module::set_current_game_module( level.game_module_standard_index );
	level.enemy_location_override_func = ::enemy_location_override;
	flag_wait( "initial_blackscreen_passed" );
	flag_set( "power_on" );
	nuked_treasure_chest_init();
}

enemy_location_override( zombie, enemy )
{
	location = enemy.origin;
	if ( is_true( self.reroute ) )
	{
		if ( isDefined( self.reroute_origin ) )
		{
			location = self.reroute_origin;
		}
	}
	return location;
}

nuked_treasure_chest_init()
{
	chest1 = getstruct( "start_chest1", "script_noteworthy" );
	chest2 = getstruct( "start_chest2", "script_noteworthy" );
	chest3 = getstruct( "culdesac_chest", "script_noteworthy" );
	chest4 = getstruct( "oh2_chest", "script_noteworthy" );
	chest5 = getstruct( "oh1_chest", "script_noteworthy" );
	level.chests = [];
	level.chests[ level.chests.size ] = chest1;
	level.chests[ level.chests.size ] = chest2;
	level.chests[ level.chests.size ] = chest3;
	level.chests[ level.chests.size ] = chest4;
	level.chests[ level.chests.size ] = chest5;
	maps/mp/zombies/_zm_magicbox::treasure_chest_init( "start_chest" );
}
