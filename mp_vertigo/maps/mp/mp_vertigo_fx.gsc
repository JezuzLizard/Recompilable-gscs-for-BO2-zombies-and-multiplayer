#include maps/mp/_utility;

#using_animtree( "fxanim_props" );
#using_animtree( "fxanim_props_dlc" );

main()
{
	precache_fxanim_props();
	precache_fxanim_props_dlc();
	precache_scripted_fx();
	precache_createfx_fx();
	maps/mp/createfx/mp_vertigo_fx::main();
	maps/mp/createart/mp_vertigo_art::main();
}

precache_scripted_fx()
{
}

precache_createfx_fx()
{
	level._effect[ "fx_mp_vertigo_tube_cloud" ] = loadfx( "maps/mp_maps/fx_mp_vertigo_tube_cloud" );
	level._effect[ "fx_mp_vertigo_engine_exhaust" ] = loadfx( "maps/mp_maps/fx_mp_vertigo_engine_exhaust" );
	level._effect[ "fx_mp_vertigo_hvac_steam" ] = loadfx( "maps/mp_maps/fx_mp_vertigo_hvac_steam" );
	level._effect[ "fx_mp_vertigo_wind_cloud_med" ] = loadfx( "maps/mp_maps/fx_mp_vertigo_wind_cloud_med" );
	level._effect[ "fx_mp_vertigo_wind_med" ] = loadfx( "maps/mp_maps/fx_mp_vertigo_wind_med" );
	level._effect[ "fx_mp_vertigo_wind_med_dark" ] = loadfx( "maps/mp_maps/fx_mp_vertigo_wind_med_dark" );
	level._effect[ "fx_mp_vertigo_ground_dust" ] = loadfx( "maps/mp_maps/fx_mp_vertigo_ground_dust" );
	level._effect[ "fx_mp_vertigo_ground_dust_lite" ] = loadfx( "maps/mp_maps/fx_mp_vertigo_ground_dust_lite" );
	level._effect[ "fx_mp_vertigo_dirt_swirl" ] = loadfx( "maps/mp_maps/fx_mp_vertigo_dirt_swirl" );
	level._effect[ "fx_mp_vertigo_cloud_vista01" ] = loadfx( "maps/mp_maps/fx_mp_vertigo_cloud_vista01" );
	level._effect[ "fx_mp_vertigo_cloud_vista02" ] = loadfx( "maps/mp_maps/fx_mp_vertigo_cloud_vista02" );
	level._effect[ "fx_mp_vertigo_window_exploder" ] = loadfx( "maps/mp_maps/fx_mp_vertigo_window_exploder" );
	level._effect[ "fx_mp_vertigo_window_exploder_sm" ] = loadfx( "maps/mp_maps/fx_mp_vertigo_window_exploder_sm" );
	level._effect[ "fx_mp_light_dust_motes_md" ] = loadfx( "maps/mp_maps/fx_mp_light_dust_motes_md" );
	level._effect[ "fx_mp_vertigo_leaves" ] = loadfx( "maps/mp_maps/fx_mp_vertigo_leaves" );
	level._effect[ "fx_paper_interior_short" ] = loadfx( "debris/fx_paper_interior_short" );
	level._effect[ "fx_mp_vertigo_fountain" ] = loadfx( "maps/mp_maps/fx_mp_vertigo_fountain" );
	level._effect[ "fx_mp_vertigo_fountain2" ] = loadfx( "maps/mp_maps/fx_mp_vertigo_fountain2" );
	level._effect[ "fx_drone_red_blink" ] = loadfx( "light/fx_drone_red_blink" );
	level._effect[ "fx_vertigo_rectangle_light_skinny" ] = loadfx( "light/fx_vertigo_rectangle_light_skinny" );
	level._effect[ "fx_drone_light_yellow" ] = loadfx( "light/fx_drone_light_yellow" );
	level._effect[ "fx_vertigo_step_light" ] = loadfx( "light/fx_vertigo_step_light" );
	level._effect[ "fx_vertigo_step_light_sm" ] = loadfx( "light/fx_vertigo_step_light_sm" );
	level._effect[ "fx_mp_vertigo_pillar_lights" ] = loadfx( "maps/mp_maps/fx_mp_vertigo_pillar_lights" );
	level._effect[ "fx_mp_vertigo_ceiling_light" ] = loadfx( "maps/mp_maps/fx_mp_vertigo_ceiling_light" );
	level._effect[ "fx_mp_vertigo_ceiling_light_sm" ] = loadfx( "maps/mp_maps/fx_mp_vertigo_ceiling_light_sm" );
	level._effect[ "fx_light_god_ray_mp_vertigo" ] = loadfx( "env/light/fx_light_god_ray_mp_vertigo" );
	level._effect[ "fx_light_god_ray_mp_vertigo_sm" ] = loadfx( "env/light/fx_light_god_ray_mp_vertigo_sm" );
	level._effect[ "fx_light_mag_ceiling_light" ] = loadfx( "light/fx_light_mag_ceiling_light" );
	level._effect[ "fx_landing_light_vertigo" ] = loadfx( "light/fx_landing_light_vertigo" );
	level._effect[ "fx_mp_vertigo_scanner_glare" ] = loadfx( "maps/mp_maps/fx_mp_vertigo_scanner_glare" );
	level._effect[ "fx_vertigo_vista_glare01" ] = loadfx( "light/fx_vertigo_vista_glare01" );
	level._effect[ "fx_vertigo_vista_glare02" ] = loadfx( "light/fx_vertigo_vista_glare02" );
	level._effect[ "fx_vertigo_rectangle_light01" ] = loadfx( "light/fx_vertigo_rectangle_light01" );
	level._effect[ "fx_lf_mp_vertigo_sun1" ] = loadfx( "lens_flares/fx_lf_mp_vertigo_sun1" );
	level._effect[ "fx_insects_swarm_lg_light" ] = loadfx( "bio/insects/fx_insects_swarm_lg_light" );
}

precache_fxanim_props()
{
	level.scr_anim[ "fxanim_props" ][ "wirespark_med" ] = %fxanim_gp_wirespark_med_anim;
	level.scr_anim[ "fxanim_props" ][ "stair_chain" ] = %fxanim_mp_ver_stair_chain_sign_anim;
	level.scr_anim[ "fxanim_props" ][ "roofvent_modern" ] = %fxanim_gp_roofvent_slow_anim;
	level.scr_anim[ "fxanim_props" ][ "cell_antenna" ] = %fxanim_gp_cell_antenna_anim;
	level.scr_anim[ "fxanim_props" ][ "antenna_rooftop" ] = %fxanim_gp_antenna_rooftop_anim;
	level.scr_anim[ "fxanim_props" ][ "deck_antenna" ] = %fxanim_gp_deck_antenna_anim;
	level.scr_anim[ "fxanim_props" ][ "ant_rooftop_small" ] = %fxanim_gp_antenna_rooftop_small_anim;
	level.scr_anim[ "fxanim_props" ][ "sat_dish" ] = %fxanim_gp_satellite_dish_anim;
	level.scr_anim[ "fxanim_props" ][ "com_tower" ] = %fxanim_gp_communication_tower_anim;
}

precache_fxanim_props_dlc()
{
	level.scr_anim[ "fxanim_props_dlc" ][ "hook" ] = %fxanim_mp_ver_hook_anim;
	level.scr_anim[ "fxanim_props_dlc" ][ "blinds_impact" ] = %fxanim_gp_blinds_long_impact_anim;
	level.scr_anim[ "fxanim_props_dlc" ][ "blinds_idle" ] = %fxanim_gp_blinds_long_idle_anim;
}
