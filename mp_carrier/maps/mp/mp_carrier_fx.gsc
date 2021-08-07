#include maps/mp/_utility;

#using_animtree( "fxanim_props" );

precache_util_fx()
{
}

precache_scripted_fx()
{
	level._effect[ "water_splash" ] = loadfx( "bio/player/fx_player_water_splash_mp" );
}

precache_createfx_fx()
{
	level._effect[ "fx_mp_light_dust_motes_md" ] = loadfx( "maps/mp_maps/fx_mp_light_dust_motes_md" );
	level._effect[ "fx_mp_elec_spark_burst_xsm_thin_runner" ] = loadfx( "maps/mp_maps/fx_mp_elec_spark_burst_xsm_thin_runner" );
	level._effect[ "fx_mp_carrier_spark_bounce_runner" ] = loadfx( "maps/mp_maps/fx_mp_carrier_spark_bounce_runner" );
	level._effect[ "fx_mp_smk_plume_lg_blk" ] = loadfx( "maps/mp_maps/fx_mp_smk_plume_lg_blk" );
	level._effect[ "fx_mp_smk_plume_lg_blk_carrier" ] = loadfx( "maps/mp_maps/fx_mp_smk_plume_lg_blk_carrier" );
	level._effect[ "fx_mp_carrier_smoke_sm" ] = loadfx( "maps/mp_maps/fx_mp_carrier_smoke_sm" );
	level._effect[ "fx_mp_carrier_smoke_med" ] = loadfx( "maps/mp_maps/fx_mp_carrier_smoke_med" );
	level._effect[ "fx_mp_carrier_smoke_lg" ] = loadfx( "maps/mp_maps/fx_mp_carrier_smoke_lg" );
	level._effect[ "fx_mp_carrier_embers" ] = loadfx( "maps/mp_maps/fx_mp_carrier_embers" );
	level._effect[ "fx_mp_carrier_smoke_xlg" ] = loadfx( "maps/mp_maps/fx_mp_carrier_smoke_xlg" );
	level._effect[ "fx_mp_carrier_smoke_area" ] = loadfx( "maps/mp_maps/fx_mp_carrier_smoke_area" );
	level._effect[ "fx_mp_carrier_smoke_white" ] = loadfx( "maps/mp_maps/fx_mp_carrier_smoke_white" );
	level._effect[ "fx_mp_carrier_burning_vista" ] = loadfx( "maps/mp_maps/fx_mp_carrier_burning_vista" );
	level._effect[ "fx_mp_carrier_burning_vista_sm" ] = loadfx( "maps/mp_maps/fx_mp_carrier_burning_vista_sm" );
	level._effect[ "fx_mp_carrier_burning_vista_xsm" ] = loadfx( "maps/mp_maps/fx_mp_carrier_burning_vista_xsm" );
	level._effect[ "fx_mp_carrier_burning_vista_mist" ] = loadfx( "maps/mp_maps/fx_mp_carrier_burning_vista_mist" );
	level._effect[ "fx_mp_carrier_smoke_whisp" ] = loadfx( "maps/mp_maps/fx_mp_carrier_smoke_whisp" );
	level._effect[ "fx_mp_carrier_smoke_center" ] = loadfx( "maps/mp_maps/fx_mp_carrier_smoke_center" );
	level._effect[ "fx_mp_carrier_smoke_center_sm" ] = loadfx( "maps/mp_maps/fx_mp_carrier_smoke_center_sm" );
	level._effect[ "fx_mp_carrier_smoke_white_sm" ] = loadfx( "maps/mp_maps/fx_mp_carrier_smoke_white_sm" );
	level._effect[ "fx_mp_carrier_smoke_white_med" ] = loadfx( "maps/mp_maps/fx_mp_carrier_smoke_white_med" );
	level._effect[ "fx_mp_fumes_vent_xsm_int" ] = loadfx( "maps/mp_maps/fx_mp_fumes_vent_xsm_int" );
	level._effect[ "fx_mp_carrier_smoke_white_xlg" ] = loadfx( "maps/mp_maps/fx_mp_carrier_smoke_white_xlg" );
	level._effect[ "fx_mp_carrier_smoke_fire_sm" ] = loadfx( "maps/mp_maps/fx_mp_carrier_smoke_fire_sm" );
	level._effect[ "fx_mp_carrier_smoke_fire_med" ] = loadfx( "maps/mp_maps/fx_mp_carrier_smoke_fire_med" );
	level._effect[ "fx_mp_carrier_smoke_fire_lg" ] = loadfx( "maps/mp_maps/fx_mp_carrier_smoke_fire_lg" );
	level._effect[ "fx_mp_carrier_vista_wake01" ] = loadfx( "maps/mp_maps/fx_mp_carrier_vista_wake01" );
	level._effect[ "fx_mp_carrier_vista_wake_med" ] = loadfx( "maps/mp_maps/fx_mp_carrier_vista_wake_med" );
	level._effect[ "fx_mp_carrier_vista_wake_side" ] = loadfx( "maps/mp_maps/fx_mp_carrier_vista_wake_side" );
	level._effect[ "fx_mp_slums_sprinkle_water" ] = loadfx( "maps/mp_maps/fx_mp_slums_sprinkle_water" );
	level._effect[ "fx_wall_water_bottom" ] = loadfx( "water/fx_wall_water_bottom" );
	level._effect[ "fx_water_splash_detail" ] = loadfx( "water/fx_water_splash_detail" );
	level._effect[ "fx_carrier_hose_water" ] = loadfx( "water/fx_carrier_hose_water" );
	level._effect[ "fx_water_fire_sprinkler_gush_splash_sm" ] = loadfx( "water/fx_water_fire_sprinkler_gush_splash_sm" );
	level._effect[ "fx_mp_carrier_signal_lights" ] = loadfx( "maps/mp_maps/fx_mp_carrier_signal_lights" );
	level._effect[ "fx_window_god_ray" ] = loadfx( "light/fx_window_god_ray" );
	level._effect[ "fx_light_beacon_red_blink_fst" ] = loadfx( "light/fx_light_beacon_red_blink_fst_sm" );
	level._effect[ "fx_carrier_tube_light_sq" ] = loadfx( "light/fx_carrier_tube_light_sq" );
	level._effect[ "fx_carrier_hazard_light" ] = loadfx( "light/fx_carrier_hazard_light" );
	level._effect[ "fx_lf_mp_carrier_sun1" ] = loadfx( "lens_flares/fx_lf_mp_carrier_sun1" );
}

precache_fxanim_props()
{
	level.scr_anim[ "fxanim_props" ][ "towing_crane" ] = %fxanim_mp_carrier_towing_crane_anim;
	level.scr_anim[ "fxanim_props" ][ "sparking_wires_med" ] = %fxanim_gp_wirespark_med_anim;
}

main()
{
	precache_util_fx();
	precache_createfx_fx();
	precache_scripted_fx();
	precache_fxanim_props();
	maps/mp/createfx/mp_carrier_fx::main();
	maps/mp/createart/mp_carrier_art::main();
}
