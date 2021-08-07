#include maps/mp/_utility;

#using_animtree( "fxanim_props" );

main()
{
	precache_fxanim_props();
	precache_scripted_fx();
	precache_createfx_fx();
	maps/mp/createfx/mp_slums_fx::main();
}

precache_scripted_fx()
{
}

precache_createfx_fx()
{
	level._effect[ "fx_mp_debris_papers" ] = loadfx( "maps/mp_maps/fx_mp_debris_papers" );
	level._effect[ "fx_mp_debris_papers_narrow" ] = loadfx( "maps/mp_maps/fx_mp_debris_papers_narrow" );
	level._effect[ "fx_mp_express_train_blow_dust" ] = loadfx( "maps/mp_maps/fx_mp_express_train_blow_dust" );
	level._effect[ "fx_insects_swarm_dark_lg" ] = loadfx( "bio/insects/fx_insects_swarm_dark_lg" );
	level._effect[ "fx_mp_slums_leaves" ] = loadfx( "maps/mp_maps/fx_mp_slums_leaves" );
	level._effect[ "fx_insects_swarm_lg_light" ] = loadfx( "bio/insects/fx_insects_swarm_lg_light" );
	level._effect[ "fx_mp_elec_spark_burst_md_runner" ] = loadfx( "maps/mp_maps/fx_mp_elec_spark_burst_md_runner" );
	level._effect[ "fx_insects_butterfly_flutter" ] = loadfx( "bio/insects/fx_insects_butterfly_flutter" );
	level._effect[ "fx_mp_light_dust_motes_md" ] = loadfx( "maps/mp_maps/fx_mp_light_dust_motes_md" );
	level._effect[ "fx_mp_slums_fire_sm" ] = loadfx( "maps/mp_maps/fx_mp_slums_fire_sm" );
	level._effect[ "fx_mp_slums_fire_lg" ] = loadfx( "maps/mp_maps/fx_mp_slums_fire_lg" );
	level._effect[ "fx_mp_slums_fire_distant" ] = loadfx( "maps/mp_maps/fx_mp_slums_fire_distant" );
	level._effect[ "fx_mp_slums_embers" ] = loadfx( "maps/mp_maps/fx_mp_slums_embers" );
	level._effect[ "fx_hvac_steam_md" ] = loadfx( "smoke/fx_hvac_steam_md" );
	level._effect[ "fx_smk_smolder_gray_slow_shrt" ] = loadfx( "smoke/fx_smk_smolder_gray_slow_shrt" );
	level._effect[ "fx_mp_slums_dark_smoke" ] = loadfx( "maps/mp_maps/fx_mp_slums_dark_smoke" );
	level._effect[ "fx_smk_tin_hat_sm" ] = loadfx( "smoke/fx_smk_tin_hat_sm" );
	level._effect[ "fx_mp_slums_vista_smoke" ] = loadfx( "maps/mp_maps/fx_mp_slums_vista_smoke" );
	level._effect[ "fx_mp_slums_vista_smoke_low" ] = loadfx( "maps/mp_maps/fx_mp_slums_vista_smoke_low" );
	level._effect[ "fx_mp_slums_dark_smoke_sm" ] = loadfx( "maps/mp_maps/fx_mp_slums_dark_smoke_sm" );
	level._effect[ "fx_window_god_ray_sm" ] = loadfx( "light/fx_window_god_ray_sm" );
	level._effect[ "fx_window_god_ray" ] = loadfx( "light/fx_window_god_ray" );
	level._effect[ "fx_village_tube_light" ] = loadfx( "light/fx_village_tube_light" );
	level._effect[ "fx_mp_slums_sprinkle_water" ] = loadfx( "maps/mp_maps/fx_mp_slums_sprinkle_water" );
	level._effect[ "fx_wall_water_bottom" ] = loadfx( "water/fx_wall_water_bottom" );
	level._effect[ "fx_water_splash_detail" ] = loadfx( "water/fx_water_splash_detail" );
	level._effect[ "fx_pipe_water_ground" ] = loadfx( "water/fx_pipe_water_ground" );
	level._effect[ "fx_water_fire_sprinkler_gush_splash_sm" ] = loadfx( "water/fx_water_fire_sprinkler_gush_splash_sm" );
	level._effect[ "fx_lf_mp_slums_sun1" ] = loadfx( "lens_flares/fx_lf_mp_slums_sun1" );
}

precache_fxanim_props()
{
	level.scr_anim[ "fxanim_props" ][ "control_wire_sm" ] = %fxanim_gp_control_wire_sm_anim;
	level.scr_anim[ "fxanim_props" ][ "roofvent" ] = %fxanim_gp_roofvent_anim;
	level.scr_anim[ "fxanim_props" ][ "rope_coil" ] = %fxanim_gp_rope_coil_anim;
	level.scr_anim[ "fxanim_props" ][ "dryer_loop" ] = %fxanim_gp_dryer_loop_anim;
}
