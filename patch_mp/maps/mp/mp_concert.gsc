//checked includes changed to match cerberus output
#include maps/mp/gametypes/_spawning;
#include maps/mp/_compass;
#include maps/mp/mp_concert_amb;
#include maps/mp/_load;
#include maps/mp/mp_concert_fx;
#include maps/mp/_utility;

main() //checked matches cerberus output
{
	level.levelspawndvars = ::levelspawndvars;
	level.overrideplayerdeathwatchtimer = ::leveloverridetime;
	level.useintermissionpointsonwavespawn = ::useintermissionpointsonwavespawn;
	maps/mp/mp_concert_fx::main();
	maps/mp/_load::main();
	maps/mp/mp_concert_amb::main();
	maps/mp/_compass::setupminimap( "compass_map_mp_concert" );
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
	level.remotemotarviewup = 18;
	level thread water_trigger_init();
}

levelspawndvars( reset_dvars ) //checked matches cerberus output
{
	ss = level.spawnsystem;
	ss.enemy_influencer_radius = set_dvar_float_if_unset( "scr_spawn_enemy_influencer_radius", "2300", reset_dvars );
}

water_trigger_init() //checked partially changed to match cerberus output see info.md
{
	wait 3;
	triggers = getentarray( "trigger_hurt", "classname" );
	foreach ( trigger in triggers )
	{
		if ( trigger.origin[ 2 ] > level.mapcenter[ 2 ] )
		{
		}
		else
		{
			trigger thread water_trigger_think();
		}
	}
	triggers = getentarray( "water_killbrush", "targetname" );
	foreach ( trigger in triggers )
	{
		trigger thread player_splash_think();
	}
}

player_splash_think() //checked matches cerberus output
{
	for ( ;; )
	{
		self waittill( "trigger", entity );
		if ( isplayer( entity ) && isalive( entity ) )
		{
			self thread trigger_thread( entity, ::player_water_fx );
		}
	}
}

player_water_fx( player, endon_condition ) //checked matches cerberus output
{
	maxs = self.origin + self getmaxs();
	if ( maxs[ 2 ] > 60 )
	{
		maxs += vectorScale( ( 0, 0, 1 ), 10 );
	}
	origin = ( player.origin[ 0 ], player.origin[ 1 ], maxs[ 2 ] );
	playfx( level._effect[ "water_splash_sm" ], origin );
}

water_trigger_think() //checked matches cerberus output
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

leveloverridetime( defaulttime ) //checked matches cerberus output
{
	if ( self isinwater() )
	{
		return 0.4;
	}
	return defaulttime;
}

useintermissionpointsonwavespawn() //checked matches cerberus output
{
	return self isinwater();
}

isinwater() //checked partially changed to match cerberus output see info.md
{
	triggers = getentarray( "trigger_hurt", "classname" );
	foreach ( trigger in triggers )
	{
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
	}
	return 0;
}

