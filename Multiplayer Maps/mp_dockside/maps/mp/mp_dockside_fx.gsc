#include maps/mp/_utility;

#using_animtree( "fxanim_props" );

precache_util_fx()
{
}

precache_scripted_fx()
{
	level._effect[ "crane_spark" ] = loadfx( "maps/mp_maps/fx_mp_container_lrg_spark_runner" );
	level._effect[ "crane_dust" ] = loadfx( "maps/mp_maps/fx_mp_container_lrg_dust_kickup" );
	level._effect[ "water_splash" ] = loadfx( "bio/player/fx_player_water_splash_mp" );
}

precache_createfx_fx()
{
	level._effect[ "fx_light_flour_dbl_oval_street_wrm" ] = loadfx( "light/fx_light_flour_dbl_oval_street_wrm" );
	level._effect[ "fx_light_floodlight_sqr_wrm" ] = loadfx( "light/fx_light_floodlight_sqr_wrm" );
	level._effect[ "fx_light_floodlight_sqr_cool_xlg" ] = loadfx( "light/fx_light_floodlight_sqr_cool_xlg" );
	level._effect[ "fx_light_floodlight_rnd_cool_glw_add" ] = loadfx( "light/fx_light_floodlight_rnd_cool_glw_add" );
	level._effect[ "fx_light_floodlight_rnd_cool_glw" ] = loadfx( "light/fx_light_floodlight_rnd_cool_glw" );
	level._effect[ "fx_light_floodlight_rnd_cool_glw_dim" ] = loadfx( "light/fx_light_floodlight_rnd_cool_glw_dim" );
	level._effect[ "fx_light_floodlight_rnd_cool_glw_lg" ] = loadfx( "light/fx_light_floodlight_rnd_cool_glw_lg" );
	level._effect[ "fx_light_floodlight_rnd_red_md" ] = loadfx( "light/fx_light_floodlight_rnd_red_md" );
	level._effect[ "fx_la2_light_beacon_red_blink" ] = loadfx( "light/fx_light_beacon_red_blink_fst" );
	level._effect[ "fx_light_beacon_red_blink_sm" ] = loadfx( "light/fx_light_beacon_red_blink_fst_sm" );
	level._effect[ "fx_light_spotlight_sm_cool" ] = loadfx( "light/fx_light_spotlight_sm_cool" );
	level._effect[ "fx_light_spotlight_sm_yellow" ] = loadfx( "light/fx_light_spotlight_sm_yellow" );
	level._effect[ "fx_light_flour_glow_wrm_dbl_md" ] = loadfx( "light/fx_light_flour_glow_wrm_dbl_md" );
	level._effect[ "fx_light_floodlight_sqr_wrm_vista_lg" ] = loadfx( "light/fx_light_floodlight_sqr_wrm_vista_lg" );
	level._effect[ "fx_light_beacon_white_static" ] = loadfx( "light/fx_light_beacon_white_static" );
	level._effect[ "fx_light_beacon_green_static" ] = loadfx( "light/fx_light_beacon_green_static" );
	level._effect[ "fx_light_buoy_red_blink" ] = loadfx( "light/fx_light_buoy_red_blink" );
	level._effect[ "fx_light_flourescent_ceiling_panel" ] = loadfx( "light/fx_light_flourescent_ceiling_panel" );
	level._effect[ "fx_light_bridge_accent_vista" ] = loadfx( "light/fx_light_bridge_accent_vista" );
	level._effect[ "fx_light_container_yellow" ] = loadfx( "light/fx_light_container_yellow" );
	level._effect[ "fx_fog_lit_spotlight_cool_lg" ] = loadfx( "fog/fx_fog_lit_spotlight_cool_lg" );
	level._effect[ "fx_fog_lit_overhead_wrm_lg" ] = loadfx( "fog/fx_fog_lit_overhead_wrm_lg" );
	level._effect[ "fx_fog_lit_overhead_wrm_xlg" ] = loadfx( "fog/fx_fog_lit_overhead_wrm_xlg" );
	level._effect[ "fx_fog_street_cool_slw_sm_md" ] = loadfx( "fog/fx_fog_street_cool_slw_md" );
	level._effect[ "fx_fog_street_red_slw_md" ] = loadfx( "fog/fx_fog_street_red_slw_md" );
	level._effect[ "fx_fog_street_red_slw_md" ] = loadfx( "fog/fx_fog_street_red_slw_md" );
	level._effect[ "fx_paper_interior_short_slw_flat" ] = loadfx( "debris/fx_paper_interior_short_slw_flat" );
	level._effect[ "fx_mp_steam_pipe_md" ] = loadfx( "maps/mp_maps/fx_mp_steam_pipe_md" );
	level._effect[ "fx_mp_steam_pipe_roof_lg" ] = loadfx( "maps/mp_maps/fx_mp_steam_pipe_roof_lg" );
	level._effect[ "fx_mp_water_drip_light_long" ] = loadfx( "maps/mp_maps/fx_mp_water_drip_light_long" );
	level._effect[ "fx_mp_water_drip_light_shrt" ] = loadfx( "maps/mp_maps/fx_mp_water_drip_light_shrt" );
	level._effect[ "fx_lf_dockside_sun1" ] = loadfx( "lens_flares/fx_lf_dockside_sun1" );
}

precache_fxanim_props()
{
	level.scr_anim[ "fxanim_props" ][ "buoy_fast" ] = %fxanim_gp_buoy_fast_anim;
	level.scr_anim[ "fxanim_props" ][ "seagull_circle_01" ] = %fxanim_gp_seagull_circle_01_anim;
	level.scr_anim[ "fxanim_props" ][ "seagull_circle_02" ] = %fxanim_gp_seagull_circle_02_anim;
	level.scr_anim[ "fxanim_props" ][ "seagull_circle_03" ] = %fxanim_gp_seagull_circle_03_anim;
	level.scr_anim[ "fxanim_props" ][ "roofvent_rotate" ] = %fxanim_gp_roofvent_anim;
	level.scr_anim[ "fxanim_props" ][ "wire_coil_large" ] = %fxanim_gp_wire_coil_lrg_anim;
	level.scr_anim[ "fxanim_props" ][ "crane_wires" ] = %fxanim_mp_dockside_crane_wires_anim;
}

main()
{
	precache_util_fx();
	precache_createfx_fx();
	precache_scripted_fx();
	maps/mp/createfx/mp_dockside_fx::main();
	maps/mp/createart/mp_dockside_art::main();
}
