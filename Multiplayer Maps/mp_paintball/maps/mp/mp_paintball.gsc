#include maps/mp/gametypes/_spawning;
#include maps/mp/_compass;
#include common_scripts/utility;
#include maps/mp/_utility;

main()
{
	level.levelspawndvars = ::levelspawndvars;
	maps/mp/mp_paintball_fx::main();
	precachemodel( "collision_physics_cylinder_32x128" );
	precachemodel( "collision_physics_64x64x10" );
	precachemodel( "collision_physics_32x32x10" );
	precachemodel( "p6_pai_fence_pole" );
	maps/mp/_load::main();
	maps/mp/mp_paintball_amb::main();
	maps/mp/_compass::setupminimap( "compass_map_mp_paintball" );
	setdvar( "compassmaxrange", "2100" );
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
	spawncollision( "collision_physics_cylinder_32x128", "collider", ( 1071,5, -1998,5, 373,5 ), ( 0, 0, 1 ) );
	spawncollision( "collision_physics_cylinder_32x128", "collider", ( 1071,5, -1998,5, 262 ), ( 0, 0, 1 ) );
	spawncollision( "collision_physics_cylinder_32x128", "collider", ( 1071,5, -1998,5, 150 ), ( 0, 0, 1 ) );
	spawncollision( "collision_physics_cylinder_32x128", "collider", ( 1071,5, -1998,5, 37,5 ), ( 0, 0, 1 ) );
	spawncollision( "collision_physics_cylinder_32x128", "collider", ( -1446,5, 524,5, 401,5 ), ( 0, 0, 1 ) );
	spawncollision( "collision_physics_cylinder_32x128", "collider", ( -1446,5, 524,5, 290 ), ( 0, 0, 1 ) );
	spawncollision( "collision_physics_cylinder_32x128", "collider", ( -1446,5, 524,5, 178 ), ( 0, 0, 1 ) );
	spawncollision( "collision_physics_cylinder_32x128", "collider", ( -1446,5, 524,5, 65,5 ), ( 0, 0, 1 ) );
	spawncollision( "collision_physics_cylinder_32x128", "collider", ( -1303,5, 1611,5, 394,5 ), ( 0, 0, 1 ) );
	spawncollision( "collision_physics_cylinder_32x128", "collider", ( -1303,5, 1611,5, 283 ), ( 0, 0, 1 ) );
	spawncollision( "collision_physics_cylinder_32x128", "collider", ( -1303,5, 1611,5, 171 ), ( 0, 0, 1 ) );
	spawncollision( "collision_physics_cylinder_32x128", "collider", ( -1303,5, 1611,5, 58,5 ), ( 0, 0, 1 ) );
	spawncollision( "collision_physics_64x64x10", "collider", ( -104,5, -1176,5, 9 ), ( 9,93, 310, 79,786 ) );
	spawncollision( "collision_physics_32x32x10", "collider", ( -105, -1166,5, 38 ), ( 317,842, 319,39, 76,1599 ) );
	spawncollision( "collision_physics_32x32x10", "collider", ( -96,5, -1173, 38,5 ), ( 310,109, 322,353, 74,0248 ) );
	spawncollision( "collision_physics_32x32x10", "collider", ( -93, -1180,5, 38,5 ), ( 310,109, 322,353, 74,0248 ) );
	pole1 = spawn( "script_model", ( 385, 572,5, -39 ) );
	pole1.angles = vectorScale( ( 0, 0, 1 ), 282,6 );
	pole1 setmodel( "p6_pai_fence_pole" );
	maps/mp/gametypes/_spawning::level_use_unified_spawning( 1 );
	registerclientfield( "scriptmover", "police_car_lights", 1, 1, "int" );
	level thread destructible_lights();
	level.remotemotarviewleft = 35;
	level.remotemotarviewright = 35;
	level.remotemotarviewup = 18;
	level thread glass_node_think();
}

levelspawndvars( reset_dvars )
{
	ss = level.spawnsystem;
	ss.enemy_influencer_radius = set_dvar_float_if_unset( "scr_spawn_enemy_influencer_radius", "2200", reset_dvars );
	ss.hq_objective_influencer_inner_radius = set_dvar_float_if_unset( "scr_spawn_hq_objective_influencer_inner_radius", "1200", reset_dvars );
}

destructible_lights()
{
	wait 0,05;
	destructibles = getentarray( "destructible", "targetname" );
	_a98 = destructibles;
	_k98 = getFirstArrayKey( _a98 );
	while ( isDefined( _k98 ) )
	{
		destructible = _a98[ _k98 ];
		if ( destructible.destructibledef == "veh_t6_police_car_destructible_mp" )
		{
			destructible thread destructible_think( "police_car_lights" );
			destructible setclientfield( "police_car_lights", 1 );
		}
		_k98 = getNextArrayKey( _a98, _k98 );
	}
}

destructible_think( clientfield )
{
	self waittill_any( "death", "destructible_base_piece_death" );
	self setclientfield( clientfield, 0 );
}

glass_node_think()
{
	wait 1;
	glass_origin = ( -980,028, -959,375, 60,1195 );
	node_origin = ( -981,75, -934,5, 16 );
	node = getnearestnode( node_origin );
	while ( isDefined( node ) && node.type == "Begin" )
	{
		ent = spawn( "script_model", node.origin, 1 );
		ent setmodel( level.deployedshieldmodel );
		ent hide();
		ent disconnectpaths();
		ent.origin -= vectorScale( ( 0, 0, 1 ), 64 );
		for ( ;; )
		{
			level waittill( "glass_smash", origin );
			if ( distancesquared( origin, glass_origin ) < 16384 )
			{
				ent.origin += vectorScale( ( 0, 0, 1 ), 64 );
				ent delete();
				return;
			}
		}
	}
}
