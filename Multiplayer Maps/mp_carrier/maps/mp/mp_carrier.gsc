#include maps/mp/_compass;
#include maps/mp/_utility;

main()
{
	level.levelspawndvars = ::levelspawndvars;
	level.overrideplayerdeathwatchtimer = ::leveloverridetime;
	level.useintermissionpointsonwavespawn = ::useintermissionpointsonwavespawn;
	maps/mp/mp_carrier_fx::main();
	maps/mp/_load::main();
	maps/mp/mp_carrier_amb::main();
	maps/mp/_compass::setupminimap( "compass_map_mp_carrier" );
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
	level thread water_trigger_init();
}

levelspawndvars( reset_dvars )
{
	ss = level.spawnsystem;
	ss.enemy_influencer_radius = set_dvar_float_if_unset( "scr_spawn_enemy_influencer_radius", "2600", reset_dvars );
}

water_trigger_init()
{
	wait 3;
	triggers = getentarray( "trigger_hurt", "classname" );
	_a53 = triggers;
	_k53 = getFirstArrayKey( _a53 );
	while ( isDefined( _k53 ) )
	{
		trigger = _a53[ _k53 ];
		if ( trigger.origin[ 2 ] > level.mapcenter[ 2 ] )
		{
		}
		else
		{
			trigger thread water_trigger_think();
		}
		_k53 = getNextArrayKey( _a53, _k53 );
	}
}

water_trigger_think()
{
	for ( ;; )
	{
		self waittill( "trigger", entity );
		if ( isplayer( entity ) )
		{
			trace = worldtrace( entity.origin + vectorScale( ( 0, 0, 1 ), 30 ), entity.origin - vectorScale( ( 0, 0, 1 ), 256 ) );
			if ( trace[ "surfacetype" ] == "none" )
			{
				entity playsound( "mpl_splash_death" );
				playfx( level._effect[ "water_splash" ], entity.origin + vectorScale( ( 0, 0, 1 ), 40 ) );
			}
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
	_a101 = triggers;
	_k101 = getFirstArrayKey( _a101 );
	while ( isDefined( _k101 ) )
	{
		trigger = _a101[ _k101 ];
		if ( trigger.origin[ 2 ] > level.mapcenter[ 2 ] )
		{
		}
		else
		{
			if ( self istouching( trigger ) )
			{
				trace = worldtrace( self.origin + vectorScale( ( 0, 0, 1 ), 30 ), self.origin - vectorScale( ( 0, 0, 1 ), 256 ) );
				return trace[ "surfacetype" ] == "none";
			}
		}
		_k101 = getNextArrayKey( _a101, _k101 );
	}
	return 0;
}
