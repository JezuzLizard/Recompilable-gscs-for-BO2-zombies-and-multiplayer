#include maps/mp/_utility;

#using_animtree( "fxanim_props" );
#using_animtree( "fxanim_props_dlc3" );

main()
{
	precache_fxanim_props();
	precache_fxanim_props_dlc3();
	precache_scripted_fx();
	precache_createfx_fx();
	maps/mp/createfx/mp_bridge_fx::main();
}

precache_scripted_fx()
{
	level._effect[ "water_splash" ] = loadfx( "bio/player/fx_player_water_splash_mp" );
}

precache_createfx_fx()
{
	level._effect[ "fx_mp_carrier_smoke_center" ] = loadfx( "maps/mp_maps/fx_mp_carrier_smoke_center" );
	level._effect[ "fx_mp_bridge_smoke_md" ] = loadfx( "maps/mp_maps/fx_mp_bridge_smoke_md" );
	level._effect[ "fx_mp_bridge_smoke_sm" ] = loadfx( "maps/mp_maps/fx_mp_bridge_smoke_sm" );
	level._effect[ "fx_mp_bridge_smoke_area" ] = loadfx( "maps/mp_maps/fx_mp_bridge_smoke_area" );
	level._effect[ "fx_mp_bridge_smoke_vista" ] = loadfx( "maps/mp_maps/fx_mp_bridge_smoke_vista" );
	level._effect[ "fx_mp_bridge_under_smoke" ] = loadfx( "maps/mp_maps/fx_mp_bridge_under_smoke" );
	level._effect[ "fx_mp_bridge_under_smoke_lg" ] = loadfx( "maps/mp_maps/fx_mp_bridge_under_smoke_lg" );
	level._effect[ "fx_mp_bridge_fire_med" ] = loadfx( "maps/mp_maps/fx_mp_bridge_fire_med" );
	level._effect[ "fx_mp_bridge_fire_sm" ] = loadfx( "maps/mp_maps/fx_mp_bridge_fire_sm" );
	level._effect[ "fx_mp_bridge_fire_fireball" ] = loadfx( "maps/mp_maps/fx_mp_bridge_fire_fireball" );
	level._effect[ "fx_mp_elec_spark_burst_xsm_thin_runner" ] = loadfx( "maps/mp_maps/fx_mp_elec_spark_burst_xsm_thin_runner" );
	level._effect[ "fx_mp_bridge_spark_light_runner" ] = loadfx( "maps/mp_maps/fx_mp_bridge_spark_light_runner" );
	level._effect[ "fx_mp_bridge_spark_light02_runner" ] = loadfx( "maps/mp_maps/fx_mp_bridge_spark_light02_runner" );
	level._effect[ "fx_mp_bridge_spark_light" ] = loadfx( "maps/mp_maps/fx_mp_bridge_spark_light" );
	level._effect[ "fx_mp_bridge_spark_loop" ] = loadfx( "maps/mp_maps/fx_mp_bridge_spark_loop" );
	level._effect[ "fx_mp_bridge_sparks_loop_sm" ] = loadfx( "maps/mp_maps/fx_mp_bridge_sparks_loop_sm" );
	level._effect[ "fx_mp_bridge_sparks_sm_runner" ] = loadfx( "maps/mp_maps/fx_mp_bridge_sparks_sm_runner" );
	level._effect[ "fx_vertigo_rectangle_light01" ] = loadfx( "light/fx_vertigo_rectangle_light01" );
	level._effect[ "fx_mp_bridge_god_ray_01" ] = loadfx( "maps/mp_maps/fx_mp_bridge_god_ray_01" );
	level._effect[ "fx_mp_bridge_god_ray_02" ] = loadfx( "maps/mp_maps/fx_mp_bridge_god_ray_02" );
	level._effect[ "fx_mp_bridge_god_ray_03" ] = loadfx( "maps/mp_maps/fx_mp_bridge_god_ray_03" );
	level._effect[ "fx_bridge_street_light" ] = loadfx( "light/fx_bridge_street_light" );
	level._effect[ "fx_vertigo_vista_glare01" ] = loadfx( "light/fx_vertigo_vista_glare01" );
	level._effect[ "fx_vertigo_vista_glare02" ] = loadfx( "light/fx_vertigo_vista_glare02" );
	level._effect[ "fx_bridge_vista_glare_red" ] = loadfx( "light/fx_bridge_vista_glare_red" );
	level._effect[ "fx_mp_light_cougar_vehicle" ] = loadfx( "maps/mp_maps/fx_mp_light_cougar_vehicle" );
	level._effect[ "fx_mp_light_cmd_vehicle_cab" ] = loadfx( "maps/mp_maps/fx_mp_light_cmd_vehicle_cab" );
	level._effect[ "fx_mp_light_cmd_vehicle_trailer" ] = loadfx( "maps/mp_maps/fx_mp_light_cmd_vehicle_trailer" );
	level._effect[ "fx_bridge_rectangle_light" ] = loadfx( "light/fx_bridge_rectangle_light" );
	level._effect[ "fx_dust_crumble_lg_runner" ] = loadfx( "dirt/fx_dust_crumble_lg_runner" );
	level._effect[ "fx_dust_crumble_windy_runner" ] = loadfx( "dirt/fx_dust_crumble_windy_runner" );
	level._effect[ "fx_mp_bridge_blowing_ash" ] = loadfx( "maps/mp_maps/fx_mp_bridge_blowing_ash" );
	level._effect[ "fx_mp_bridge_blowing_dust" ] = loadfx( "maps/mp_maps/fx_mp_bridge_blowing_dust" );
	level._effect[ "fx_mp_light_dust_motes_md" ] = loadfx( "maps/mp_maps/fx_mp_light_dust_motes_md" );
	level._effect[ "fx_mp_castaway_air_dust_blow" ] = loadfx( "maps/mp_maps/fx_mp_castaway_air_dust_blow" );
	level._effect[ "fx_mp_bridge_air_dust_blow" ] = loadfx( "maps/mp_maps/fx_mp_bridge_air_dust_blow" );
	level._effect[ "fx_paper_interior_short" ] = loadfx( "debris/fx_paper_interior_short" );
	level._effect[ "fx_lf_mp_bridge_sun" ] = loadfx( "lens_flares/fx_lf_mp_bridge_sun" );
	level._effect[ "fx_mp_elec_spark_burst_xsm_thin" ] = loadfx( "maps/mp_maps/fx_mp_elec_spark_burst_xsm_thin" );
	level._effect[ "fx_mp_light_police_car" ] = loadfx( "maps/mp_maps/fx_mp_light_police_car" );
}

precache_fxanim_props()
{
	level.scr_anim = [];
	level.scr_anim[ "fxanim_props" ] = [];
	level.scr_anim[ "fxanim_props" ][ "seagull_circle_01" ] = %fxanim_gp_seagull_circle_01_anim;
	level.scr_anim[ "fxanim_props" ][ "seagull_circle_02" ] = %fxanim_gp_seagull_circle_02_anim;
	level.scr_anim[ "fxanim_props" ][ "seagull_circle_03" ] = %fxanim_gp_seagull_circle_03_anim;
	level.scr_anim[ "fxanim_props" ][ "wirespark_long" ] = %fxanim_gp_wirespark_long_anim;
	level.scr_anim[ "fxanim_props" ][ "wirespark_med" ] = %fxanim_gp_wirespark_med_anim;
}

precache_fxanim_props_dlc3()
{
	level.scr_anim[ "fxanim_props_dlc3" ] = [];
	level.scr_anim[ "fxanim_props_dlc3" ][ "wires_01" ] = %fxanim_mp_bridge_wires_01_anim;
	level.scr_anim[ "fxanim_props_dlc3" ][ "wires_02" ] = %fxanim_mp_bridge_wires_02_anim;
	level.scr_anim[ "fxanim_props_dlc3" ][ "wires_03" ] = %fxanim_mp_bridge_wires_03_anim;
	level.scr_anim[ "fxanim_props_dlc3" ][ "truck_parts" ] = %viewmodel_fxanim_mp_bridge_truck_parts_anim;
	level.scr_anim[ "fxanim_props_dlc3" ][ "truck_wires" ] = %fxanim_mp_bridge_truck_wires_anim;
	level.scr_anim[ "fxanim_props_dlc3" ][ "control_wires" ] = %fxanim_mp_bridge_control_wires_anim;
	level.scr_anim[ "fxanim_props_dlc3" ][ "wires_billboard" ] = %fxanim_mp_bridge_wires_billboard_anim;
	level.scr_anim[ "fxanim_props_dlc3" ][ "wires_generator" ] = %fxanim_mp_bridge_wires_generator_anim;
	level.scr_anim[ "fxanim_props_dlc3" ][ "wires_road_hole" ] = %fxanim_mp_bridge_wires_road_hole_anim;
}
