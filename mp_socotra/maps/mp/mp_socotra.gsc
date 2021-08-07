#include maps/mp/gametypes/_spawning;
#include maps/mp/_compass;
#include maps/mp/_utility;

main()
{
	level.levelspawndvars = ::levelspawndvars;
	maps/mp/mp_socotra_fx::main();
	maps/mp/_load::main();
	maps/mp/_compass::setupminimap( "compass_map_mp_socotra" );
	maps/mp/mp_socotra_amb::main();
	setheliheightpatchenabled( "war_mode_heli_height_lock", 0 );
	maps/mp/gametypes/_spawning::level_use_unified_spawning( 1 );
	rts_remove();
	level.remotemotarviewleft = 30;
	level.remotemotarviewright = 30;
	level.remotemotarviewup = 18;
}

levelspawndvars( reset_dvars )
{
	ss = level.spawnsystem;
	ss.enemy_influencer_radius = set_dvar_float_if_unset( "scr_spawn_enemy_influencer_radius", "2000", reset_dvars );
}

rts_remove()
{
	rtsfloors = getentarray( "overwatch_floor", "targetname" );
	_a38 = rtsfloors;
	_k38 = getFirstArrayKey( _a38 );
	while ( isDefined( _k38 ) )
	{
		rtsfloor = _a38[ _k38 ];
		if ( isDefined( rtsfloor ) )
		{
			rtsfloor delete();
		}
		_k38 = getNextArrayKey( _a38, _k38 );
	}
}
