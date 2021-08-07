#include maps/mp/gametypes/_spawning;
#include maps/mp/_compass;
#include maps/mp/gametypes/_globallogic_utils;
#include maps/mp/_utility;
#include common_scripts/utility;

main()
{
	level.levelspawndvars = ::levelspawndvars;
	maps/mp/mp_uplink_fx::main();
	precachemodel( "collision_physics_128x128x10" );
	precachemodel( "collision_physics_256x256x10" );
	precachemodel( "collision_physics_64x64x10" );
	precachemodel( "collision_physics_32x32x10" );
	maps/mp/_load::main();
	maps/mp/mp_uplink_amb::main();
	maps/mp/_compass::setupminimap( "compass_map_mp_uplink" );
	setdvar( "compassmaxrange", "2100" );
	registerclientfield( "world", "trigger_lightning", 1, 1, "int" );
	game[ "strings" ][ "war_callsign_a" ] = &"MPUI_CALLSIGN_MAPNAME_A";
	game[ "strings" ][ "war_callsign_b" ] = &"MPUI_CALLSIGN_MAPNAME_B";
	game[ "strings" ][ "war_callsign_c" ] = &"MPUI_CALLSIGN_MAPNAME_C";
	game[ "strings" ][ "war_callsign_d" ] = &"MPUI_CALLSIGN_MAPNAME_D";
	game[ "strings" ][ "war_callsign_e" ] = &"MPUI_CALLSIGN_MAPNAME_E";
	game[ "strings_menu" ][ "war_callsign_a" ] = "@MPUI_CALLSIGN_MAPNAME_A";
	game[ "strings_menu" ][ "war_callsign_b" ] = "@MPUI_CALLSIGN_MAPNAME_B";
	game[ "strings_menu" ][ "war_callsign_c" ] = "@MPUI_CALLSIGN_MAPNAME_C";
	game[ "strings_menu" ][ "war_callsign_d" ] = "@MPUI_CALLSIGN_MAPNAME_D";
	game[ "strings_menu" ][ "war_callsign_e" ] = "@MPUI_CALLSIGN_MAPNAME_E";
	spawncollision( "collision_physics_128x128x10", "collider", ( 1661, 345,5, 298,5 ), ( 0, 1, 0 ) );
	spawncollision( "collision_physics_128x128x10", "collider", ( 1661, 345,5, 313,5 ), ( 0, 1, 0 ) );
	spawncollision( "collision_physics_256x256x10", "collider", ( 3257, -3,5, 872,5 ), ( 360, 270, 90 ) );
	spawncollision( "collision_physics_256x256x10", "collider", ( 3394, -136,5, 872,5 ), ( 270, 183,902, 86,0983 ) );
	spawncollision( "collision_physics_256x256x10", "collider", ( 3270,5, -3,5, 872,5 ), ( 360, 270, 90 ) );
	spawncollision( "collision_physics_256x256x10", "collider", ( 3394, 129,5, 872,5 ), ( 270, 183,902, 86,0983 ) );
	spawncollision( "collision_physics_256x256x10", "collider", ( 3399,5, 1, 990 ), ( 1,12, 270, 180 ) );
	spawncollision( "collision_physics_128x128x10", "collider", ( 2343,5, 865,5, 320,5 ), vectorScale( ( 0, 1, 0 ), 332,7 ) );
	spawncollision( "collision_physics_64x64x10", "collider", ( 2291, 904, 316 ), ( 355,461, 27,1924, -2,32818 ) );
	spawncollision( "collision_physics_32x32x10", "collider", ( 3049,5, -3452, 339 ), ( 78,6193, 281,502, -105,573 ) );
	maps/mp/gametypes/_spawning::level_use_unified_spawning( 1 );
	level.remotemotarviewdown = 50;
	level thread gondola_sway();
	glasses = getstructarray( "glass_shatter_on_spawn", "targetname" );
	i = 0;
	while ( i < glasses.size )
	{
		radiusdamage( glasses[ i ].origin, 64, 101, 100 );
		i++;
	}
}

levelspawndvars( reset_dvars )
{
	ss = level.spawnsystem;
	ss.enemy_influencer_radius = set_dvar_float_if_unset( "scr_spawn_enemy_influencer_radius", "2350", reset_dvars );
	ss.hq_objective_influencer_inner_radius = set_dvar_float_if_unset( "scr_spawn_hq_objective_influencer_inner_radius", "1000", reset_dvars );
}

gondola_sway()
{
	gondola_cab = getent( "gondola_cab", "targetname" );
	gondola_cab setmovingplatformenabled( 1 );
	while ( 1 )
	{
		randomswingangle = randomfloatrange( 0,25, 0,5 );
		randomswingtime = randomfloatrange( 2,5, 4 );
		gondola_cab rotateto( ( randomswingangle * 0,5, randomswingangle * 0,6, randomswingangle * 0,8 ), randomswingtime, randomswingtime * 0,3, randomswingtime * 0,3 );
		gondola_cab playsound( "amb_gondola_swing" );
		wait randomswingtime;
		gondola_cab rotateto( ( ( randomswingangle * 0,5 ) * -1, ( randomswingangle * -1 ) * 0,6, ( randomswingangle * 0,8 ) * -1 ), randomswingtime, randomswingtime * 0,3, randomswingtime * 0,3 );
		gondola_cab playsound( "amb_gondola_swing_back" );
		wait randomswingtime;
		gondola_cab destroy_corpses();
	}
}

destroy_corpses()
{
	time = getTime();
	corpses = getcorpsearray();
	i = 0;
	while ( i < corpses.size )
	{
		if ( ( corpses[ i ].birthtime + 3000 ) < time )
		{
			if ( distance2dsquared( corpses[ i ].origin, self.origin ) < 10000 )
			{
				corpses[ i ] delete();
			}
		}
		i++;
	}
}
