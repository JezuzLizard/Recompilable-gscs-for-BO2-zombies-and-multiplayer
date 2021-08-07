#include maps/mp/_utility;

#using_animtree( "fxanim_props" );
#using_animtree( "fxanim_props_dlc4" );

main()
{
	maps/mp/createfx/mp_takeoff_fx::main();
	precache_fxanim_props();
	precache_fxanim_props_dlc4();
	precache_scripted_fx();
	precache_createfx_fx();
}

precache_scripted_fx()
{
}

precache_createfx_fx()
{
	level._effect[ "fx_light_exit_sign" ] = loadfx( "light/fx_light_exit_sign_glow" );
	level._effect[ "fx_light_flour_glow_cool" ] = loadfx( "light/fx_tak_light_flour_glow_cool" );
	level._effect[ "fx_tak_light_flour_glow_cool_sm" ] = loadfx( "light/fx_tak_light_flour_glow_cool_sm" );
	level._effect[ "fx_light_upl_flour_glow_v_shape_cool" ] = loadfx( "light/fx_light_upl_flour_glow_v_shape_cool" );
	level._effect[ "fx_light_recessed_blue" ] = loadfx( "light/fx_light_recessed_blue" );
	level._effect[ "fx_light_recessed_cool_sm_soft" ] = loadfx( "light/fx_light_recessed_cool_sm_soft" );
	level._effect[ "fx_mp_tak_glow_blue" ] = loadfx( "maps/mp_maps/fx_mp_tak_glow_blue" );
	level._effect[ "fx_mp_tak_glow_orange" ] = loadfx( "maps/mp_maps/fx_mp_tak_glow_orange" );
	level._effect[ "fx_mp_tak_glow_yellow" ] = loadfx( "maps/mp_maps/fx_mp_tak_glow_yellow" );
	level._effect[ "fx_mp_tak_glow_red" ] = loadfx( "maps/mp_maps/fx_mp_tak_glow_red" );
	level._effect[ "fx_tak_light_flour_glow_ceiling" ] = loadfx( "light/fx_tak_light_flour_glow_ceiling" );
	level._effect[ "fx_tak_light_flour_sqr_lg" ] = loadfx( "light/fx_tak_light_flour_sqr_lg" );
	level._effect[ "fx_tak_light_flour_rnd_lg" ] = loadfx( "light/fx_tak_light_flour_rnd_lg" );
	level._effect[ "fx_tak_light_tv_glow_blue" ] = loadfx( "light/fx_tak_light_tv_glow_blue" );
	level._effect[ "fx_tak_light_tv_glow_blue_flckr" ] = loadfx( "light/fx_tak_light_tv_glow_blue_flckr" );
	level._effect[ "fx_drone_light_yellow" ] = loadfx( "light/fx_drone_light_yellow" );
	level._effect[ "fx_tak_light_sign_glow_blue" ] = loadfx( "light/fx_tak_light_sign_glow_blue" );
	level._effect[ "fx_tak_light_blue_stair" ] = loadfx( "light/fx_tak_light_blue_stair" );
	level._effect[ "fx_tak_light_blue_stair_sm" ] = loadfx( "light/fx_tak_light_blue_stair_sm" );
	level._effect[ "fx_tak_light_blue" ] = loadfx( "light/fx_tak_light_blue" );
	level._effect[ "fx_tak_light_blue_pulse" ] = loadfx( "light/fx_tak_light_blue_pulse" );
	level._effect[ "fx_tak_light_blue_pulse_curve" ] = loadfx( "light/fx_tak_light_blue_pulse_curve" );
	level._effect[ "fx_light_beacon_yellow" ] = loadfx( "light/fx_light_beacon_yellow" );
	level._effect[ "fx_light_beacon_red_blink_fst_sm" ] = loadfx( "light/fx_light_beacon_red_blink_fst_sm" );
	level._effect[ "fx_tak_light_modern_sconce" ] = loadfx( "light/fx_tak_light_modern_sconce" );
	level._effect[ "fx_tak_light_spotlight" ] = loadfx( "light/fx_tak_light_spotlight" );
	level._effect[ "fx_tak_light_wall_ext" ] = loadfx( "light/fx_tak_light_wall_ext" );
	level._effect[ "fx_mp_light_dust_motes_md" ] = loadfx( "maps/mp_maps/fx_mp_light_dust_motes_md" );
	level._effect[ "fx_mp_tak_dust_ground" ] = loadfx( "maps/mp_maps/fx_mp_tak_dust_ground" );
	level._effect[ "fx_tak_water_fountain_pool_sm" ] = loadfx( "water/fx_tak_water_fountain_pool_sm" );
	level._effect[ "fx_paper_interior_short_sm" ] = loadfx( "debris/fx_paper_interior_short_sm" );
	level._effect[ "fx_paper_exterior_short_sm_fst" ] = loadfx( "debris/fx_paper_exterior_short_sm_fst" );
	level._effect[ "fx_insects_swarm_md_light" ] = loadfx( "bio/insects/fx_insects_swarm_md_light" );
	level._effect[ "fx_mp_vent_heat_distort" ] = loadfx( "maps/mp_maps/fx_mp_vent_heat_distort" );
	level._effect[ "fx_mp_tak_steam_loading_dock" ] = loadfx( "maps/mp_maps/fx_mp_tak_steam_loading_dock" );
	level._effect[ "fx_mp_vent_steam_line" ] = loadfx( "maps/mp_maps/fx_mp_vent_steam_line" );
	level._effect[ "fx_mp_vent_steam_line_sm" ] = loadfx( "maps/mp_maps/fx_mp_vent_steam_line_sm" );
	level._effect[ "fx_mp_vent_steam_line_lg" ] = loadfx( "maps/mp_maps/fx_mp_vent_steam_line_lg" );
	level._effect[ "fx_mp_steam_amb_xlg" ] = loadfx( "maps/mp_maps/fx_mp_steam_amb_xlg" );
	level._effect[ "fx_mp_tak_steam_hvac" ] = loadfx( "maps/mp_maps/fx_mp_tak_steam_hvac" );
	level._effect[ "fx_lf_mp_overflow_sun1" ] = loadfx( "lens_flares/fx_lf_mp_overflow_sun1" );
	level._effect[ "fx_lf_mp_takeoff_sun1" ] = loadfx( "lens_flares/fx_lf_mp_takeoff_sun1" );
	level._effect[ "fx_mp_tak_shuttle_thruster_lg" ] = loadfx( "maps/mp_maps/fx_mp_tak_shuttle_thruster_lg" );
	level._effect[ "fx_mp_tak_shuttle_thruster_md" ] = loadfx( "maps/mp_maps/fx_mp_tak_shuttle_thruster_md" );
	level._effect[ "fx_mp_tak_shuttle_thruster_sm" ] = loadfx( "maps/mp_maps/fx_mp_tak_shuttle_thruster_sm" );
	level._effect[ "fx_mp_tak_shuttle_thruster_smk_grnd" ] = loadfx( "maps/mp_maps/fx_mp_tak_shuttle_thruster_smk_grnd" );
	level._effect[ "fx_mp_tak_shuttle_thruster_steam" ] = loadfx( "maps/mp_maps/fx_mp_tak_shuttle_thruster_steam" );
	level._effect[ "fx_mp_tak_shuttle_thruster_steam_w" ] = loadfx( "maps/mp_maps/fx_mp_tak_shuttle_thruster_steam_w" );
	level._effect[ "fx_mp_tak_shuttle_frame_light" ] = loadfx( "maps/mp_maps/fx_mp_tak_shuttle_frame_light" );
	level._effect[ "fx_mp_tak_steam_nozzle" ] = loadfx( "maps/mp_maps/fx_mp_tak_steam_nozzle" );
}

precache_fxanim_props()
{
	level.scr_anim[ "fxanim_props" ][ "seagull_circle_01" ] = %fxanim_gp_seagull_circle_01_anim;
	level.scr_anim[ "fxanim_props" ][ "seagull_circle_02" ] = %fxanim_gp_seagull_circle_02_anim;
	level.scr_anim[ "fxanim_props" ][ "seagull_circle_03" ] = %fxanim_gp_seagull_circle_03_anim;
	level.scr_anim[ "fxanim_props" ][ "windsock" ] = %fxanim_gp_windsock_anim;
}

precache_fxanim_props_dlc4()
{
	level.scr_anim[ "fxanim_props_dlc4" ][ "decont_blasters" ] = %fxanim_mp_takeoff_decont_blasters_anim;
	level.scr_anim[ "fxanim_props_dlc4" ][ "scaffold_wires_01" ] = %fxanim_mp_takeoff_scaffold_wires_01_anim;
	level.scr_anim[ "fxanim_props_dlc4" ][ "crane_hooks" ] = %fxanim_mp_takeoff_crane_hooks_anim;
	level.scr_anim[ "fxanim_props_dlc4" ][ "rattling_sign" ] = %fxanim_mp_takeoff_rattling_sign_anim;
	level.scr_anim[ "fxanim_props_dlc4" ][ "radar01" ] = %fxanim_mp_takeoff_satellite_dish_01_anim;
	level.scr_anim[ "fxanim_props_dlc4" ][ "radar02" ] = %fxanim_mp_takeoff_satellite_dish_02_anim;
	level.scr_anim[ "fxanim_props_dlc4" ][ "radar03" ] = %fxanim_mp_takeoff_satellite_dish_03_anim;
	level.scr_anim[ "fxanim_props_dlc4" ][ "radar04" ] = %fxanim_mp_takeoff_satellite_dish_04_anim;
	level.scr_anim[ "fxanim_props_dlc4" ][ "radar05" ] = %fxanim_mp_takeoff_satellite_dish_05_anim;
	level.scr_anim[ "fxanim_props_dlc4" ][ "banners" ] = %fxanim_mp_takeoff_banner_01_anim;
	level.scr_anim[ "fxanim_props_dlc4" ][ "planets" ] = %fxanim_mp_takeoff_planets_anim;
	level.scr_anim[ "fxanim_props_dlc4" ][ "banners_lrg" ] = %fxanim_mp_takeoff_banner_lrg_anim;
}
