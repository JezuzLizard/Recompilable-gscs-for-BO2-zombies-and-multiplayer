#include maps/mp/gametypes/_spawning;
#include maps/mp/_compass;
#include maps/mp/_utility;

main()
{
	level.levelspawndvars = ::levelspawndvars;
	maps/mp/mp_dig_fx::main();
	precachemodel( "collision_clip_wall_32x32x10" );
	precachemodel( "p6_dig_brick_03" );
	maps/mp/_load::main();
	maps/mp/mp_dig_amb::main();
	maps/mp/_compass::setupminimap( "compass_map_mp_dig" );
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
	brick1 = spawn( "script_model", ( -5,6285, 604,473, 39,05 ) );
	brick1.angles = ( 359,199, 90,0129, -0,822672 );
	brick2 = spawn( "script_model", ( -12,63, 604,47, 39,05 ) );
	brick2.angles = ( 359,199, 90,0129, -0,822672 );
	brick3 = spawn( "script_model", ( -5,63, 614,97, 39,05 ) );
	brick3.angles = ( 359,199, 90,0129, -0,822672 );
	brick4 = spawn( "script_model", ( -12,63, 614,97, 39,05 ) );
	brick4.angles = ( 359,199, 90,0129, -0,822672 );
	brick5 = spawn( "script_model", ( -5,63, 629,47, 39,55 ) );
	brick5.angles = ( 359,199, 90,0129, -0,822672 );
	brick6 = spawn( "script_model", ( -12,63, 629,47, 39,55 ) );
	brick6.angles = ( 359,199, 90,0129, -0,822672 );
	brick1 setmodel( "p6_dig_brick_03" );
	brick2 setmodel( "p6_dig_brick_03" );
	brick3 setmodel( "p6_dig_brick_03" );
	brick4 setmodel( "p6_dig_brick_03" );
	brick5 setmodel( "p6_dig_brick_03" );
	brick6 setmodel( "p6_dig_brick_03" );
	spawncollision( "collision_clip_wall_32x32x10", "collider", ( -1404, -1126, 46,5 ), vectorScale( ( 0, 1, 0 ), 90 ) );
	maps/mp/gametypes/_spawning::level_use_unified_spawning( 1 );
}

levelspawndvars( reset_dvars )
{
	ss = level.spawnsystem;
	ss.enemy_influencer_radius = set_dvar_float_if_unset( "scr_spawn_enemy_influencer_radius", "2300", reset_dvars );
	ss.hq_objective_influencer_inner_radius = set_dvar_float_if_unset( "scr_spawn_hq_objective_influencer_inner_radius", "1000", reset_dvars );
}
