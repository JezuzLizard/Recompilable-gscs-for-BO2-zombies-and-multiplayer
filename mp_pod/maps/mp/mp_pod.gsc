#include maps/mp/gametypes/_spawning;
#include maps/mp/_compass;
#include maps/mp/_utility;

main()
{
	level.levelspawndvars = ::levelspawndvars;
	maps/mp/mp_pod_fx::main();
	precachemodel( "p_rus_door_white_frame_double" );
	precachemodel( "p6_pak_old_plywood" );
	precachemodel( "collision_clip_wall_32x32x10" );
	precachemodel( "collision_physics_wall_32x32x10" );
	precachemodel( "collision_physics_wall_128x128x10" );
	precachemodel( "collision_physics_wall_256x256x10" );
	precachemodel( "collision_physics_256x256x10" );
	precachemodel( "collision_missile_128x128x10" );
	precachemodel( "collision_clip_wall_64x64x10" );
	precachemodel( "collision_physics_256x256x256" );
	maps/mp/_load::main();
	maps/mp/mp_pod_amb::main();
	maps/mp/_compass::setupminimap( "compass_map_mp_pod" );
	prop1 = spawn( "script_model", ( 517,264, -627,226, 323 ) );
	prop1.angles = vectorScale( ( 0, 1, 0 ), 116,6 );
	prop1 setmodel( "p_rus_door_white_frame_double" );
	prop2 = spawn( "script_model", ( 62,1517, -1647,78, 481,602 ) );
	prop2.angles = vectorScale( ( 0, 1, 0 ), 35,2 );
	prop2 setmodel( "p6_pak_old_plywood" );
	prop3 = spawn( "script_model", ( 25,9997, -1673,49, 479,903 ) );
	prop3.angles = vectorScale( ( 0, 1, 0 ), 35,2 );
	prop3 setmodel( "p6_pak_old_plywood" );
	spawncollision( "collision_clip_wall_32x32x10", "collider", ( -1725, 2300, 514 ), ( 0, 1, 0 ) );
	spawncollision( "collision_clip_wall_32x32x10", "collider", ( -473, -2482, 412 ), vectorScale( ( 0, 1, 0 ), 14 ) );
	spawncollision( "collision_physics_wall_32x32x10", "collider", ( -473, -2482, 412 ), vectorScale( ( 0, 1, 0 ), 14 ) );
	spawncollision( "collision_physics_wall_128x128x10", "collider", ( -87, -1470,5, 751,5 ), vectorScale( ( 0, 1, 0 ), 34,2 ) );
	spawncollision( "collision_physics_256x256x10", "collider", ( 1287,5, -2468, 315 ), vectorScale( ( 0, 1, 0 ), 18,1 ) );
	spawncollision( "collision_physics_256x256x10", "collider", ( 1047,5, -2468, 315 ), vectorScale( ( 0, 1, 0 ), 18,1 ) );
	spawncollision( "collision_physics_256x256x10", "collider", ( 1047,5, -2627,5, 165,5 ), vectorScale( ( 0, 1, 0 ), 64,1 ) );
	spawncollision( "collision_missile_128x128x10", "collider", ( -911,5, -653, 496 ), ( 273, 45,0999, 90 ) );
	spawncollision( "collision_clip_wall_64x64x10", "collider", ( 1356, 50, 358 ), ( 5,64745, 114,9, 6 ) );
	spawncollision( "collision_clip_wall_64x64x10", "collider", ( 1364, 32, 349 ), ( 1,3883, 292,6, -4 ) );
	spawncollision( "collision_clip_wall_64x64x10", "collider", ( 1423, -127, 349 ), ( 1,3883, 285,8, -4 ) );
	spawncollision( "collision_physics_256x256x256", "collider", ( 1218, -2232, 244 ), vectorScale( ( 0, 1, 0 ), 30 ) );
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
	maps/mp/gametypes/_spawning::level_use_unified_spawning( 1 );
	level thread killstreak_init();
}

levelspawndvars( reset_dvars )
{
	ss = level.spawnsystem;
	ss.enemy_influencer_radius = set_dvar_float_if_unset( "scr_spawn_enemy_influencer_radius", "2400", reset_dvars );
	ss.hq_objective_influencer_inner_radius = set_dvar_float_if_unset( "scr_spawn_hq_objective_influencer_inner_radius", "1000", reset_dvars );
}

killstreak_init()
{
	while ( !isDefined( level.missile_swarm_flyheight ) )
	{
		wait 1;
	}
	level.missile_swarm_flyheight = 6000;
}
