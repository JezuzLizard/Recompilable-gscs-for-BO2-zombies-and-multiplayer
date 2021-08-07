#include maps/mp/_compass;
#include maps/mp/_utility;

main()
{
	level.levelspawndvars = ::levelspawndvars;
	maps/mp/mp_meltdown_fx::main();
	maps/mp/_load::main();
	maps/mp/mp_meltdown_amb::main();
	maps/mp/_compass::setupminimap( "compass_map_mp_meltdown" );
}

levelspawndvars( reset_dvars )
{
	ss = level.spawnsystem;
	ss.enemy_influencer_radius = set_dvar_float_if_unset( "scr_spawn_enemy_influencer_radius", "2100", reset_dvars );
}
