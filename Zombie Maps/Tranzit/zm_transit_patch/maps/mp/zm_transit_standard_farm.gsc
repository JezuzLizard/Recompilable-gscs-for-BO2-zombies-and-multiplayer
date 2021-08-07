//checked includes match cerberus output
#include maps/mp/zombies/_zm_game_module;
#include maps/mp/zombies/_zm_zonemgr;
#include maps/mp/gametypes_zm/_zm_gametype;
#include maps/mp/zombies/_zm_magicbox;
#include maps/mp/zombies/_zm_race_utility;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;

precache() //checked matches cerberus output
{
}

farm_treasure_chest_init() //checked matches cerberus output
{
	chest1 = getstruct( "farm_chest", "script_noteworthy" );
	level.chests = [];
	level.chests[ level.chests.size ] = chest1;
	maps/mp/zombies/_zm_magicbox::treasure_chest_init( "farm_chest" );
}

main() //checked matches cerberus output
{
	maps/mp/gametypes_zm/_zm_gametype::setup_standard_objects( "farm" );
	init_standard_farm();
	farm_treasure_chest_init();
	level.enemy_location_override_func = ::enemy_location_override;
	flag_wait( "initial_blackscreen_passed" );
	level thread maps/mp/zombies/_zm_zonemgr::enable_zone( "zone_far_ext" );
	level thread maps/mp/zombies/_zm_zonemgr::enable_zone( "zone_brn" );
	maps/mp/zombies/_zm_game_module::turn_power_on_and_open_doors();
	flag_wait( "start_zombie_round_logic" );
	wait 1;
	level notify( "revive_on" );
	wait_network_frame();
	level notify( "doubletap_on" );
	wait_network_frame();
	level notify( "juggernog_on" );
	wait_network_frame();
	level notify( "sleight_on" );
	wait_network_frame();
}

init_standard_farm() //checked partially changed to match cerberus output see info.md No. 1, No. 2
{
	maps/mp/zombies/_zm_game_module::set_current_game_module( level.game_module_standard_index );
	ents = getentarray();
	foreach ( ent in ents )
	{
		if ( isDefined( ent.script_flag ) && ent.script_flag == "OnFarm_enter" )
		{
			ent delete();
		}
		else
		{
			if ( isDefined( ent.script_parameters ) )
			{
				tokens = strtok( ent.script_parameters, " " );
				remove = 0;
				for ( i = 0; i < tokens.size; i++ )
				{
					if ( tokens[ i ] == "standard_remove" )
					{
						remove = 1;
					}
				}
				if ( remove )
				{
					ent delete();
				}
			}
		}
	}
}

enemy_location_override( zombie, enemy ) //checked matches cerberus output
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
