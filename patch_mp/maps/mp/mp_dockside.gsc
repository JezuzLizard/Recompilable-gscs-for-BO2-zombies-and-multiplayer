#include maps/mp/mp_dockside_crane;
#include maps/mp/_compass;
#include maps/mp/_utility;

main()
{
	level.levelspawndvars = ::levelspawndvars;
	maps/mp/mp_dockside_fx::main();
	precachemodel( "collision_clip_64x64x64" );
	precachemodel( "collision_clip_32x32x32" );
	precachemodel( "collision_missile_128x128x10" );
	precachemodel( "collision_missile_32x32x128" );
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
	spawncollision( "collision_clip_64x64x64", "collider", ( 1095, 1489, -111 ), ( 0, 0, 1 ) );
	spawncollision( "collision_clip_32x32x32", "collider", ( 1079, 1441, -97 ), ( 0, 0, 1 ) );
	spawncollision( "collision_clip_wall_128x128x10", "collider", ( -1791, 2954, -23 ), vectorScale( ( 0, 0, 1 ), 270 ) );
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
	_a92 = triggers;
	_k92 = getFirstArrayKey( _a92 );
	while ( isDefined( _k92 ) )
	{
		trigger = _a92[ _k92 ];
		if ( trigger.origin[ 2 ] > level.mapcenter[ 2 ] )
		{
		}
		else
		{
			trigger thread water_trigger_think();
		}
		_k92 = getNextArrayKey( _a92, _k92 );
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
	_a138 = triggers;
	_k138 = getFirstArrayKey( _a138 );
	while ( isDefined( _k138 ) )
	{
		trigger = _a138[ _k138 ];
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
		_k138 = getNextArrayKey( _a138, _k138 );
	}
	return 0;
}

rts_remove()
{
	removes = getentarray( "rts_only", "targetname" );
	_a157 = removes;
	_k157 = getFirstArrayKey( _a157 );
	while ( isDefined( _k157 ) )
	{
		remove = _a157[ _k157 ];
		if ( isDefined( remove ) )
		{
			remove delete();
		}
		_k157 = getNextArrayKey( _a157, _k157 );
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
	_a211 = dvars;
	_k211 = getFirstArrayKey( _a211 );
	while ( isDefined( _k211 ) )
	{
		dvar = _a211[ _k211 ];
		print( dvar + ": " );
		println( getDvar( dvar ) );
		_k211 = getNextArrayKey( _a211, _k211 );
#/
	}
}
