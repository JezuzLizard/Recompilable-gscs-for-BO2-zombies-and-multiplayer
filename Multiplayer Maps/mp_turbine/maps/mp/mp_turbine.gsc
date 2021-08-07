#include maps/mp/_compass;
#include maps/mp/_utility;

main()
{
	level.levelspawndvars = ::levelspawndvars;
	maps/mp/mp_turbine_fx::main();
	maps/mp/_load::main();
	maps/mp/_compass::setupminimap( "compass_map_mp_turbine" );
	maps/mp/mp_turbine_amb::main();
	if ( !level.console )
	{
		precachemodel( "collision_clip_32x32x32" );
		spawncollision( "collision_clip_32x32x32", "collider", ( -1400, 550, 360 ), ( 0, 0, 0 ) );
	}
	level.remotemotarviewleft = 50;
	level.remotemotarviewright = 50;
}

levelspawndvars( reset_dvars )
{
	ss = level.spawnsystem;
	ss.enemy_influencer_radius = set_dvar_float_if_unset( "scr_spawn_enemy_influencer_radius", "2600", reset_dvars );
	ss.koth_objective_influencer_inner_radius = 2400;
}

turbine_spin_init()
{
	level endon( "game_ended" );
	turbine1 = getent( "turbine_blades", "targetname" );
	turbine1 thread rotate_blades( 4 );
	turbine2 = getent( "turbine_blades2", "targetname" );
	turbine2 thread rotate_blades( 3 );
	turbine3 = getent( "turbine_blades3", "targetname" );
	turbine3 thread rotate_blades( 6 );
	turbine4 = getent( "turbine_blades4", "targetname" );
	turbine4 thread rotate_blades( 3 );
	turbine6 = getent( "turbine_blades6", "targetname" );
	turbine6 thread rotate_blades( 4 );
}

rotate_blades( time )
{
	self endon( "game_ended" );
	revolutions = 1000;
	while ( 1 )
	{
		self rotateroll( 360 * revolutions, time * revolutions );
		self waittill( "rotatedone" );
	}
}
