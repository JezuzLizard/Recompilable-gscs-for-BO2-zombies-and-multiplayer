#include maps/mp/mp_express_train;
#include maps/mp/_compass;
#include common_scripts/utility;
#include maps/mp/_utility;

main()
{
	level.levelspawndvars = ::levelspawndvars;
	maps/mp/mp_express_fx::main();
	maps/mp/_load::main();
	maps/mp/_compass::setupminimap( "compass_map_mp_express" );
	maps/mp/mp_express_amb::main();
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
	registerclientfield( "vehicle", "train_moving", 1, 1, "int" );
	registerclientfield( "scriptmover", "train_moving", 1, 1, "int" );
	if ( getgametypesetting( "allowMapScripting" ) )
	{
		maps/mp/mp_express_train::init();
	}
/#
	level thread devgui_express();
	execdevgui( "devgui_mp_express" );
#/
}

levelspawndvars( reset_dvars )
{
	ss = level.spawnsystem;
	ss.enemy_influencer_radius = set_dvar_float_if_unset( "scr_spawn_enemy_influencer_radius", "1900", reset_dvars );
}

devgui_express()
{
/#
	setdvar( "devgui_notify", "" );
	for ( ;; )
	{
		wait 0,5;
		devgui_string = getDvar( "devgui_notify" );
		switch( devgui_string )
		{
			case "":
				break;
			case "train_start":
				level notify( "train_start" );
				break;
			default:
			}
			if ( getDvar( "devgui_notify" ) != "" )
			{
				setdvar( "devgui_notify", "" );
			}
#/
		}
	}
}
