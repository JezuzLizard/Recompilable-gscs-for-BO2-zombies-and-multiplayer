#include maps/mp/mp_drone_doors;
#include maps/mp/_compass;
#include maps/mp/_utility;

main()
{
	precachemodel( "fxanim_gp_robot_arm_welder_server_side_mod" );
	level.levelspawndvars = ::levelspawndvars;
	welders = [];
	welders[ welders.size ] = ( -1339,51, 76,04, 136,11 );
	welders[ welders.size ] = ( -1339,51, -171,9, 136,11 );
	welders[ welders.size ] = ( -1339,51, 559,04, 136,12 );
	welders[ welders.size ] = ( -1339,51, 312,01, 136,12 );
	maps/mp/mp_drone_fx::main();
	maps/mp/_compass::setupminimap( "compass_map_mp_drone" );
	maps/mp/_load::main();
	maps/mp/mp_drone_amb::main();
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
	if ( getgametypesetting( "allowMapScripting" ) )
	{
		level maps/mp/mp_drone_doors::init();
	}
	level.remotemotarviewleft = 35;
	level.remotemotarviewright = 35;
	level.remotemotarviewup = 18;
	setheliheightpatchenabled( "war_mode_heli_height_lock", 0 );
	geo_changes();
	_a54 = welders;
	_k54 = getFirstArrayKey( _a54 );
	while ( isDefined( _k54 ) )
	{
		welder = _a54[ _k54 ];
		collision = spawn( "script_model", welder );
		collision setmodel( "fxanim_gp_robot_arm_welder_server_side_mod" );
		_k54 = getNextArrayKey( _a54, _k54 );
	}
}

levelspawndvars( reset_dvars )
{
	ss = level.spawnsystem;
	ss.enemy_influencer_radius = set_dvar_float_if_unset( "scr_spawn_enemy_influencer_radius", "2600", reset_dvars );
}

geo_changes()
{
	rts_floor = getent( "overwatch_floor", "targetname" );
	if ( isDefined( rts_floor ) )
	{
		rts_floor delete();
	}
	removes = getentarray( "rts_only", "targetname" );
	_a77 = removes;
	_k77 = getFirstArrayKey( _a77 );
	while ( isDefined( _k77 ) )
	{
		removal = _a77[ _k77 ];
		removal delete();
		_k77 = getNextArrayKey( _a77, _k77 );
	}
}
