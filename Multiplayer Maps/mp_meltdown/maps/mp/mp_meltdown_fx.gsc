#include maps/mp/_utility;

main()
{
	precache_fxanim_props();
	precache_scripted_fx();
	precache_createfx_fx();
	maps/mp/createfx/mp_meltdown_fx::main();
	maps/mp/createart/mp_meltdown_art::main();
}

precache_scripted_fx()
{
}

precache_createfx_fx()
{
	level._effect[ "fx_mp_fumes_vent_xsm_int" ] = loadfx( "maps/mp_maps/fx_mp_fumes_vent_xsm_int" );
	level._effect[ "fx_mp_steam_pipe_md" ] = loadfx( "maps/mp_maps/fx_mp_steam_pipe_md" );
	level._effect[ "fx_mp_vent_heat_distort" ] = loadfx( "maps/mp_maps/fx_mp_vent_heat_distort" );
	level._effect[ "fx_mp_vent_steam_line" ] = loadfx( "maps/mp_maps/fx_mp_vent_steam_line" );
	level._effect[ "fx_mp_vent_steam_windy" ] = loadfx( "maps/mp_maps/fx_mp_vent_steam_windy" );
	level._effect[ "fx_mp_vent_steam_windy_lg" ] = loadfx( "maps/mp_maps/fx_mp_vent_steam_windy_lg" );
	level._effect[ "fx_mp_steam_smoke" ] = loadfx( "maps/mp_maps/fx_mp_steam_smoke" );
	level._effect[ "fx_mp_water_rain_cooling_tower" ] = loadfx( "maps/mp_maps/fx_mp_water_rain_cooling_tower" );
	level._effect[ "fx_mp_water_rain_cooling_tower_splsh_200" ] = loadfx( "maps/mp_maps/fx_mp_water_rain_cooling_tower_splsh_200" );
	level._effect[ "fx_mp_water_drip_light_long" ] = loadfx( "maps/mp_maps/fx_mp_water_drip_light_long" );
	level._effect[ "fx_mp_steam_cooling_tower" ] = loadfx( "maps/mp_maps/fx_mp_steam_cooling_tower" );
	level._effect[ "fx_mp_steam_cooling_tower_blocker" ] = loadfx( "maps/mp_maps/fx_mp_steam_cooling_tower_blocker" );
	level._effect[ "fx_mp_steam_cooling_tower_door" ] = loadfx( "maps/mp_maps/fx_mp_steam_cooling_tower_door" );
	level._effect[ "fx_mp_steam_cooling_tower_int_top" ] = loadfx( "maps/mp_maps/fx_mp_steam_cooling_tower_int_top" );
	level._effect[ "fx_mp_steam_cooling_tower_thck_sm" ] = loadfx( "maps/mp_maps/fx_mp_steam_cooling_tower_thck_sm" );
	level._effect[ "fx_mp_steam_cooling_tower_thck_md" ] = loadfx( "maps/mp_maps/fx_mp_steam_cooling_tower_thck_md" );
	level._effect[ "fx_mp_steam_cooling_tower_thck_xsm" ] = loadfx( "maps/mp_maps/fx_mp_steam_cooling_tower_thck_xsm" );
	level._effect[ "fx_water_pipe_spill_ocean" ] = loadfx( "water/fx_water_pipe_spill_ocean" );
	level._effect[ "fx_water_surface_heat_lg" ] = loadfx( "water/fx_water_surface_heat_lg" );
	level._effect[ "fx_water_surface_heat_md" ] = loadfx( "water/fx_water_surface_heat_md" );
	level._effect[ "fx_mp_steam_tunnel" ] = loadfx( "maps/mp_maps/fx_mp_steam_tunnel" );
	level._effect[ "fx_mp_steam_tunnel_lng" ] = loadfx( "maps/mp_maps/fx_mp_steam_tunnel_lng" );
	level._effect[ "fx_water_wave_break_md" ] = loadfx( "water/fx_water_wave_break_md" );
	level._effect[ "fx_water_wave_break_lg" ] = loadfx( "water/fx_water_wave_break_lg" );
	level._effect[ "fx_insects_swarm_lg_light" ] = loadfx( "bio/insects/fx_insects_swarm_lg_light" );
	level._effect[ "fx_paper_interior_short" ] = loadfx( "debris/fx_paper_interior_short" );
	level._effect[ "fx_mp_light_dust_motes_md" ] = loadfx( "maps/mp_maps/fx_mp_light_dust_motes_md" );
	level._effect[ "fx_light_gray_white_ribbon_sm" ] = loadfx( "light/fx_light_gray_white_ribbon_sm" );
	level._effect[ "fx_light_flourescent_ceiling_panel_2" ] = loadfx( "light/fx_light_flourescent_ceiling_panel_2" );
	level._effect[ "fx_light_reactor_glw_blue" ] = loadfx( "light/fx_light_reactor_glw_blue" );
	level._effect[ "fx_light_beacon_red_blink_fst_sm" ] = loadfx( "light/fx_light_beacon_red_blink_fst_sm" );
	level._effect[ "fx_light_garage_parking_red" ] = loadfx( "light/fx_light_emergency_red" );
	level._effect[ "fx_light_m_p6_ext_wall_sml" ] = loadfx( "light/fx_light_m_p6_ext_wall_sml" );
	level._effect[ "fx_light_outdoor_wall03_white" ] = loadfx( "light/fx_light_outdoor_wall03_white" );
	level._effect[ "fx_light_flourescent_ceiling_panel" ] = loadfx( "light/fx_light_flourescent_ceiling_panel_soft" );
	level._effect[ "fx_light_recessed_cool_sm" ] = loadfx( "light/fx_light_recessed_cool_sm_soft" );
	level._effect[ "fx_light_floodlight_sqr_wrm_sm" ] = loadfx( "light/fx_light_floodlight_sqr_wrm_sm" );
	level._effect[ "fx_light_flour_glow_cool_dbl_md" ] = loadfx( "light/fx_light_flour_glow_cool_dbl_md" );
	level._effect[ "fx_lf_mp_meltdown_sun1" ] = loadfx( "lens_flares/fx_lf_mp_meltdown_sun1" );
	level._effect[ "fx_sand_gust_ground_sm" ] = loadfx( "dirt/fx_sand_gust_ground_sm_slw" );
	level._effect[ "fx_sand_gust_ground_md" ] = loadfx( "dirt/fx_sand_gust_ground_md_slw" );
	level._effect[ "fx_sand_gust_door" ] = loadfx( "dirt/fx_sand_gust_door_slw" );
	level._effect[ "fx_sand_blowing_lg_vista" ] = loadfx( "dirt/fx_sand_blowing_lg_vista" );
	level._effect[ "fx_dust_gray_street_low" ] = loadfx( "dirt/fx_dust_gray_street_low" );
	level._effect[ "fx_dust_swirl_sm_gray_runner" ] = loadfx( "dirt/fx_dust_swirl_sm_gray_runner" );
	level._effect[ "fx_pak_tower_fire_flareup" ] = loadfx( "maps/mp_maps/fx_mp_fire_tower_flareup" );
	level._effect[ "fx_mp_fire_tower_flareup_amb" ] = loadfx( "maps/mp_maps/fx_mp_fire_tower_flareup_amb" );
}

precache_fxanim_props()
{
}
