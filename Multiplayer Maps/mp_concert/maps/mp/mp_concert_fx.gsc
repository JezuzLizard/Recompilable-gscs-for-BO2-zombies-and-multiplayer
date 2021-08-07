#include maps/mp/_utility;

#using_animtree( "fxanim_props" );
#using_animtree( "fxanim_props_dlc" );

main()
{
	precache_fxanim_props();
	precache_fxanim_props_dlc();
	precache_scripted_fx();
	precache_createfx_fx();
	maps/mp/createfx/mp_concert_fx::main();
}

precache_scripted_fx()
{
	level._effect[ "water_splash" ] = loadfx( "bio/player/fx_player_water_splash_mp" );
}

precache_createfx_fx()
{
	level._effect[ "fx_lf_mp_concert_sun" ] = loadfx( "lens_flares/fx_lf_mp_concert_sun" );
	level._effect[ "fx_pigeon_panic_flight_med" ] = loadfx( "bio/animals/fx_pigeon_panic_flight_med" );
	level._effect[ "fx_leaves_ground_wind" ] = loadfx( "foliage/fx_leaves_ground_wind" );
	level._effect[ "fx_sand_gust_ground_sm" ] = loadfx( "dirt/fx_sand_gust_ground_sm" );
	level._effect[ "fx_sand_gust_ground_md_xslw" ] = loadfx( "dirt/fx_sand_gust_ground_md_xslw" );
	level._effect[ "fx_concert_leaves_falling_red" ] = loadfx( "foliage/fx_concert_leaves_falling_red" );
	level._effect[ "fx_concert_leaves_falling_orange" ] = loadfx( "foliage/fx_concert_leaves_falling_orange" );
	level._effect[ "fx_leaves_ground_windy" ] = loadfx( "foliage/fx_leaves_ground_windy" );
	level._effect[ "fx_patio_flame_lamp_heat" ] = loadfx( "props/fx_patio_flame_lamp_heat" );
	level._effect[ "fx_water_sprinkler_drip_physics" ] = loadfx( "water/fx_water_sprinkler_drip_physics" );
	level._effect[ "fx_fire_fireplace_md2" ] = loadfx( "fire/fx_fire_fireplace_md2" );
	level._effect[ "fx_smk_linger_lit" ] = loadfx( "smoke/fx_concert_smk_linger_lit" );
	level._effect[ "fx_concert_smk_field_md" ] = loadfx( "smoke/fx_concert_smk_field_md" );
	level._effect[ "fx_light_floodlight_sqr_cool_xlg" ] = loadfx( "light/fx_light_floodlight_sqr_cool_xlg" );
	level._effect[ "fx_light_buoy_red_blink" ] = loadfx( "light/fx_light_buoy_red_blink" );
	level._effect[ "fx_light_floodlight_stadium_lg" ] = loadfx( "light/fx_light_floodlight_stadium_lg" );
	level._effect[ "fx_light_stagelight_wht" ] = loadfx( "light/fx_light_stagelight_wht" );
	level._effect[ "fx_concert_can_light_blue" ] = loadfx( "light/fx_concert_can_light_blue" );
	level._effect[ "fx_concert_can_light_blue_static" ] = loadfx( "light/fx_concert_can_light_blue_static" );
	level._effect[ "fx_concert_can_light_purple" ] = loadfx( "light/fx_concert_can_light_purple" );
	level._effect[ "fx_concert_can_light_red" ] = loadfx( "light/fx_concert_can_light_red" );
	level._effect[ "fx_concert_can_light_red_static" ] = loadfx( "light/fx_concert_can_light_red_static" );
	level._effect[ "fx_light_spotlight_md_cool" ] = loadfx( "light/fx_light_spotlight_md_cool" );
	level._effect[ "fx_light_baracade_yellow" ] = loadfx( "light/fx_light_baracade_yellow" );
	level._effect[ "fx_light_fluorescent_overhead_bright" ] = loadfx( "light/fx_light_fluorescent_overhead_bright" );
	level._effect[ "fx_light_flourescent_ceiling_panel_2" ] = loadfx( "light/fx_light_flourescent_ceiling_panel_2" );
	level._effect[ "fx_track_light" ] = loadfx( "light/fx_track_light" );
	level._effect[ "fx_light_button_yellow_on" ] = loadfx( "light/fx_light_button_yellow_on" );
	level._effect[ "fx_light_vend_machine_sm_orange" ] = loadfx( "light/fx_light_vend_machine_sm_orange" );
	level._effect[ "fx_light_vend_machine_sm_blue" ] = loadfx( "light/fx_light_vend_machine_sm_blue" );
	level._effect[ "fx_concert_bathroom_monitor_glow" ] = loadfx( "light/fx_concert_bathroom_monitor_glow" );
	level._effect[ "fx_concert_bath_hygiene_box_glow" ] = loadfx( "light/fx_concert_bath_hygiene_box_glow" );
	level._effect[ "fx_concert_hand_dryer_glow" ] = loadfx( "light/fx_concert_hand_dryer_glow" );
	level._effect[ "fx_light_com_utility_cool" ] = loadfx( "light/fx_light_com_utility_cool" );
	level._effect[ "fx_light_exit_sign_glow" ] = loadfx( "light/fx_light_exit_sign_glow" );
	level._effect[ "fx_light_recessed_cool" ] = loadfx( "light/fx_light_recessed_cool" );
	level._effect[ "fx_light_recessed_wrm" ] = loadfx( "light/fx_light_recessed_wrm" );
	level._effect[ "fx_light_hanging_modern" ] = loadfx( "light/fx_light_hanging_modern" );
	level._effect[ "fx_light_neon_open_sign" ] = loadfx( "light/fx_light_neon_open_sign" );
	level._effect[ "fx_concert_light_ceiling_recessed_short" ] = loadfx( "light/fx_concert_light_ceiling_recessed_short" );
	level._effect[ "fx_concert_light_ceiling_recessed" ] = loadfx( "light/fx_concert_light_ceiling_recessed" );
	level._effect[ "fx_light_exit_sign_glow_yellowish" ] = loadfx( "light/fx_light_exit_sign_glow_yellowish" );
	level._effect[ "fx_light_flour_glow_v_shape_cool" ] = loadfx( "light/fx_light_flour_glow_v_shape_cool" );
	level._effect[ "fx_light_flour_glow_v_shape_cool_sm" ] = loadfx( "light/fx_light_flour_glow_v_shape_cool_sm" );
	level._effect[ "fx_concert_light_ray_sun_lg_spread_1s" ] = loadfx( "light/fx_concert_light_ray_sun_lg_spread_1s" );
	level._effect[ "fx_concert_light_ray_sun_md_1s" ] = loadfx( "light/fx_concert_light_ray_sun_md_1s" );
	level._effect[ "fx_concert_light_ray_sun_md_short_1s" ] = loadfx( "light/fx_concert_light_ray_sun_md_short_1s" );
	level._effect[ "fx_concert_light_ray_sun_md_spread_1s" ] = loadfx( "light/fx_concert_light_ray_sun_md_spread_1s" );
	level._effect[ "fx_concert_light_ray_sun_md_wide_1s" ] = loadfx( "light/fx_concert_light_ray_sun_md_wide_1s" );
	level._effect[ "fx_concert_light_ray_sun_window_1s" ] = loadfx( "light/fx_concert_light_ray_sun_window_1s" );
	level._effect[ "fx_light_dust_motes_xsm_short" ] = loadfx( "light/fx_concert_dust_motes_xsm_short" );
	level._effect[ "fx_light_dust_motes_sm" ] = loadfx( "light/fx_light_dust_motes_sm" );
	level._effect[ "fx_dust_motes_blowing_sm" ] = loadfx( "debris/fx_dust_motes_blowing_sm" );
	level._effect[ "fx_concert_fountain_sides" ] = loadfx( "water/fx_concert_fountain_sides" );
	level._effect[ "fx_concert_fountain_middle" ] = loadfx( "water/fx_concert_fountain_middle" );
	level._effect[ "fx_insects_butterfly_flutter_radial2" ] = loadfx( "bio/insects/fx_insects_butterfly_flutter_radial2" );
}

precache_fxanim_props()
{
	level.scr_anim[ "fxanim_props" ][ "seagull_circle_01" ] = %fxanim_gp_seagull_circle_01_anim;
	level.scr_anim[ "fxanim_props" ][ "seagull_circle_02" ] = %fxanim_gp_seagull_circle_02_anim;
	level.scr_anim[ "fxanim_props" ][ "seagull_circle_03" ] = %fxanim_gp_seagull_circle_03_anim;
	level.scr_anim[ "fxanim_props" ][ "london_eye" ] = %fxanim_mp_con_london_eye_anim;
}

precache_fxanim_props_dlc()
{
	level.scr_anim[ "fxanim_props_dlc" ][ "wires_stage_rear" ] = %fxanim_mp_con_wires_stage_rear_anim;
	level.scr_anim[ "fxanim_props_dlc" ][ "wires_stage_scaffold" ] = %fxanim_mp_con_wires_stage_scaffold_anim;
	level.scr_anim[ "fxanim_props_dlc" ][ "wires_seats_scaffold" ] = %fxanim_mp_con_wires_seats_scaffold_anim;
	level.scr_anim[ "fxanim_props_dlc" ][ "river_boats" ] = %fxanim_mp_con_boat_link_anim;
	level.scr_anim[ "fxanim_props_dlc" ][ "wires_stage_right" ] = %fxanim_mp_con_wires_stage_right_anim;
}
