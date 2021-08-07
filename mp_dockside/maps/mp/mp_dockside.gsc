#include maps/mp/mp_dockside_crane;
#include maps/mp/_compass;
#include maps/mp/_utility;

main()
{
	level.levelspawndvars = ::levelspawndvars;
	maps/mp/mp_dockside_fx::main();
	maps/mp/_load::main();
	maps/mp/mp_dockside_amb::main();
	maps/mp/_compass::setupminimap( "compass_map_mp_dockside" );
	level.overrideplayerdeathwatchtimer = ::leveloverridetime;
	level.useintermissionpointsonwavespawn = ::useintermissionpointsonwavespawn;
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
	setdvar( "sm_sunsamplesizenear", 0,39 );
	setdvar( "sm_sunshadowsmall", 1 );
	if ( getgametypesetting( "allowMapScripting" ) )
	{
		level maps/mp/mp_dockside_crane::init();
	}
	else
	{
		crate_triggers = getentarray( "crate_kill_trigger", "targetname" );
		i = 0;
		while ( i < crate_triggers.size )
		{
			crate_triggers[ i ] delete();
			i++;
		}
	}
	setheliheightpatchenabled( "war_mode_heli_height_lock", 0 );
	level thread water_trigger_init();
	rts_remove();
/#
	level thread devgui_dockside();
	execdevgui( "devgui_mp_dockside" );
#/
}

levelspawndvars( reset_dvars )
{
	ss = level.spawnsystem;
	ss.enemy_influencer_radius = set_dvar_float_if_unset( "scr_spawn_enemy_influencer_radius", "2700", reset_dvars );
}

water_trigger_init()
{
	wait 3;
	triggers = getentarray( "trigger_hurt", "classname" );
	_a80 = triggers;
	_k80 = getFirstArrayKey( _a80 );
	while ( isDefined( _k80 ) )
	{
		trigger = _a80[ _k80 ];
		if ( trigger.origin[ 2 ] > level.mapcenter[ 2 ] )
		{
		}
		else
		{
			trigger thread water_trigger_think();
		}
		_k80 = getNextArrayKey( _a80, _k80 );
	}
}

water_trigger_think()
{
	for ( ;; )
	{
		self waittill( "trigger", entity );
		if ( isplayer( entity ) )
		{
			entity playsound( "mpl_splash_death" );
			playfx( level._effect[ "water_splash" ], entity.origin + vectorScale( ( 0, 0, 1 ), 40 ) );
		}
	}
}

leveloverridetime( defaulttime )
{
	if ( self isinwater() )
	{
		return 0,4;
	}
	return defaulttime;
}

useintermissionpointsonwavespawn()
{
	return self isinwater();
}

isinwater()
{
	triggers = getentarray( "trigger_hurt", "classname" );
	_a126 = triggers;
	_k126 = getFirstArrayKey( _a126 );
	while ( isDefined( _k126 ) )
	{
		trigger = _a126[ _k126 ];
		if ( trigger.origin[ 2 ] > level.mapcenter[ 2 ] )
		{
		}
		else
		{
			if ( self istouching( trigger ) )
			{
				return 1;
			}
		}
		_k126 = getNextArrayKey( _a126, _k126 );
	}
	return 0;
}

rts_remove()
{
	removes = getentarray( "rts_only", "targetname" );
	_a145 = removes;
	_k145 = getFirstArrayKey( _a145 );
	while ( isDefined( _k145 ) )
	{
		remove = _a145[ _k145 ];
		if ( isDefined( remove ) )
		{
			remove delete();
		}
		_k145 = getNextArrayKey( _a145, _k145 );
	}
}

devgui_dockside()
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
			case "crane_print_dvars":
				crane_print_dvars();
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

crane_print_dvars()
{
/#
	dvars = [];
	dvars[ dvars.size ] = "scr_crane_claw_move_time";
	dvars[ dvars.size ] = "scr_crane_crate_lower_time";
	dvars[ dvars.size ] = "scr_crane_crate_raise_time";
	dvars[ dvars.size ] = "scr_crane_arm_y_move_time";
	dvars[ dvars.size ] = "scr_crane_arm_z_move_time";
	dvars[ dvars.size ] = "scr_crane_claw_drop_speed";
	dvars[ dvars.size ] = "scr_crane_claw_drop_time_min";
	_a199 = dvars;
	_k199 = getFirstArrayKey( _a199 );
	while ( isDefined( _k199 ) )
	{
		dvar = _a199[ _k199 ];
		print( dvar + ": " );
		println( getDvar( dvar ) );
		_k199 = getNextArrayKey( _a199, _k199 );
#/
	}
}
