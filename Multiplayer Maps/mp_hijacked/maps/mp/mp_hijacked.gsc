#include maps/mp/_compass;
#include maps/mp/_utility;

main()
{
	level.levelspawndvars = ::levelspawndvars;
	level.overrideplayerdeathwatchtimer = ::leveloverridetime;
	level.useintermissionpointsonwavespawn = ::useintermissionpointsonwavespawn;
	maps/mp/mp_hijacked_fx::main();
	maps/mp/_load::main();
	maps/mp/mp_hijacked_amb::main();
	maps/mp/_compass::setupminimap( "compass_map_mp_hijacked" );
	level thread water_trigger_init();
}

levelspawndvars( reset_dvars )
{
	ss = level.spawnsystem;
	ss.enemy_influencer_radius = set_dvar_float_if_unset( "scr_spawn_enemy_influencer_radius", "1600", reset_dvars );
	ss.dead_friend_influencer_radius = set_dvar_float_if_unset( "scr_spawn_dead_friend_influencer_radius", "1300", reset_dvars );
	ss.dead_friend_influencer_timeout_seconds = set_dvar_float_if_unset( "scr_spawn_dead_friend_influencer_timeout_seconds", "8", reset_dvars );
	ss.dead_friend_influencer_count = set_dvar_float_if_unset( "scr_spawn_dead_friend_influencer_count", "7", reset_dvars );
	ss.hq_objective_influencer_inner_radius = set_dvar_float_if_unset( "scr_spawn_hq_objective_influencer_inner_radius", "1200", reset_dvars );
	ss.koth_objective_influencer_inner_radius = 1400;
}

water_trigger_init()
{
	wait 3;
	triggers = getentarray( "trigger_hurt", "classname" );
	_a43 = triggers;
	_k43 = getFirstArrayKey( _a43 );
	while ( isDefined( _k43 ) )
	{
		trigger = _a43[ _k43 ];
		if ( trigger.origin[ 2 ] > level.mapcenter[ 2 ] )
		{
		}
		else
		{
			trigger thread water_trigger_think();
		}
		_k43 = getNextArrayKey( _a43, _k43 );
	}
	triggers = getentarray( "water_killbrush", "targetname" );
	_a55 = triggers;
	_k55 = getFirstArrayKey( _a55 );
	while ( isDefined( _k55 ) )
	{
		trigger = _a55[ _k55 ];
		trigger thread player_splash_think();
		_k55 = getNextArrayKey( _a55, _k55 );
	}
}

player_splash_think()
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

player_water_fx( player, endon_condition )
{
	maxs = self.origin + self getmaxs();
	if ( maxs[ 2 ] > 60 )
	{
		maxs += vectorScale( ( 0, 0, 1 ), 10 );
	}
	origin = ( player.origin[ 0 ], player.origin[ 1 ], maxs[ 2 ] );
	playfx( level._effect[ "water_splash_sm" ], origin );
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
	_a120 = triggers;
	_k120 = getFirstArrayKey( _a120 );
	while ( isDefined( _k120 ) )
	{
		trigger = _a120[ _k120 ];
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
		_k120 = getNextArrayKey( _a120, _k120 );
	}
	return 0;
}
