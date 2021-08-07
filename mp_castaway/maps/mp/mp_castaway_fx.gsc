#include maps/mp/_utility;

#using_animtree( "fxanim_props" );
#using_animtree( "fxanim_props_dlc3" );

main()
{
	precache_fxanim_props();
	precache_fxanim_props_dlc3();
	precache_scripted_fx();
	precache_createfx_fx();
	maps/mp/createfx/mp_castaway_fx::main();
}

precache_scripted_fx()
{
	level._effect[ "water_splash_sm" ] = loadfx( "bio/player/fx_player_water_splash_mp_sm" );
}

precache_createfx_fx()
{
	level._effect[ "fx_mp_castaway_crate_fire" ] = loadfx( "maps/mp_maps/fx_mp_castaway_crate_fire" );
	level._effect[ "fx_mp_castaway_oil_slick" ] = loadfx( "maps/mp_maps/fx_mp_castaway_oil_slick" );
	level._effect[ "fx_mp_castaway_splash_md" ] = loadfx( "maps/mp_maps/fx_mp_castaway_splash_md" );
	level._effect[ "fx_mp_castaway_rock_splash01_runner" ] = loadfx( "maps/mp_maps/fx_mp_castaway_rock_splash01_runner" );
	level._effect[ "fx_mp_castaway_cave_drip" ] = loadfx( "maps/mp_maps/fx_mp_castaway_cave_drip" );
	level._effect[ "fx_xtreme_water_hit_mp_castaway" ] = loadfx( "impacts/fx_xtreme_water_hit_mp_castaway" );
	level._effect[ "fx_mp_slums_dark_smoke_sm" ] = loadfx( "maps/mp_maps/fx_mp_slums_dark_smoke_sm" );
	level._effect[ "fx_mp_castaway_fire_md" ] = loadfx( "maps/mp_maps/fx_mp_castaway_fire_md" );
	level._effect[ "fx_mp_castaway_fire_sm" ] = loadfx( "maps/mp_maps/fx_mp_castaway_fire_sm" );
	level._effect[ "fx_mp_castaway_fire_lg" ] = loadfx( "maps/mp_maps/fx_mp_castaway_fire_lg" );
	level._effect[ "fx_smk_smolder_gray_slow_dark" ] = loadfx( "smoke/fx_smk_smolder_gray_slow_dark" );
	level._effect[ "fx_mp_studio_smoke_area" ] = loadfx( "maps/mp_maps/fx_mp_studio_smoke_area" );
	level._effect[ "fx_mp_castaway_smoke_area" ] = loadfx( "maps/mp_maps/fx_mp_castaway_smoke_area" );
	level._effect[ "fx_mp_castaway_wing_fire" ] = loadfx( "maps/mp_maps/fx_mp_castaway_wing_fire" );
	level._effect[ "fx_mp_castaway_fire_geo" ] = loadfx( "maps/mp_maps/fx_mp_castaway_fire_geo" );
	level._effect[ "fx_mp_castaway_fire_geo2" ] = loadfx( "maps/mp_maps/fx_mp_castaway_fire_geo2" );
	level._effect[ "fx_mp_castaway_crate_smoke01" ] = loadfx( "maps/mp_maps/fx_mp_castaway_crate_smoke01" );
	level._effect[ "fx_mp_castaway_crate_smoke02" ] = loadfx( "maps/mp_maps/fx_mp_castaway_crate_smoke02" );
	level._effect[ "fx_mp_castaway_smoke_sm" ] = loadfx( "maps/mp_maps/fx_mp_castaway_smoke_sm" );
	level._effect[ "fx_mp_castaway_smoke_tunnel" ] = loadfx( "maps/mp_maps/fx_mp_castaway_smoke_tunnel" );
	level._effect[ "fx_mp_castaway_elec_fire" ] = loadfx( "maps/mp_maps/fx_mp_castaway_elec_fire" );
	level._effect[ "fx_mp_castaway_smoke_area_white" ] = loadfx( "maps/mp_maps/fx_mp_castaway_smoke_area_white" );
	level._effect[ "fx_mp_castaway_wing02_smoke" ] = loadfx( "maps/mp_maps/fx_mp_castaway_wing02_smoke" );
	level._effect[ "fx_mp_castaway_fire_only_sm" ] = loadfx( "maps/mp_maps/fx_mp_castaway_fire_only_sm" );
	level._effect[ "fx_mp_castaway_smoke_blow" ] = loadfx( "maps/mp_maps/fx_mp_castaway_smoke_blow" );
	level._effect[ "fx_mp_castaway_fire_drip" ] = loadfx( "maps/mp_maps/fx_mp_castaway_fire_drip" );
	level._effect[ "fx_insects_swarm_lg_light" ] = loadfx( "bio/insects/fx_insects_swarm_lg_light" );
	level._effect[ "fx_insects_flies_dragonflies" ] = loadfx( "bio/insects/fx_insects_flies_dragonflies" );
	level._effect[ "fx_insects_butterfly_flutter" ] = loadfx( "bio/insects/fx_insects_butterfly_flutter" );
	level._effect[ "fx_mp_castaway_fire_int" ] = loadfx( "maps/mp_maps/fx_mp_castaway_fire_int" );
	level._effect[ "fx_mp_castaway_god_ray_lg" ] = loadfx( "maps/mp_maps/fx_mp_castaway_god_ray_lg" );
	level._effect[ "fx_mp_castaway_god_ray_lg_r" ] = loadfx( "maps/mp_maps/fx_mp_castaway_god_ray_lg_r" );
	level._effect[ "fx_mp_castaway_god_ray_lg_02" ] = loadfx( "maps/mp_maps/fx_mp_castaway_god_ray_lg_02" );
	level._effect[ "fx_mp_castaway_fire_dlite" ] = loadfx( "maps/mp_maps/fx_mp_castaway_fire_dlite" );
	level._effect[ "fx_mp_castaway_fire_dlite02" ] = loadfx( "maps/mp_maps/fx_mp_castaway_fire_dlite02" );
	level._effect[ "fx_mp_castaway_case_lite" ] = loadfx( "maps/mp_maps/fx_mp_castaway_case_lite" );
	level._effect[ "fx_mp_light_dust_motes_md" ] = loadfx( "maps/mp_maps/fx_mp_light_dust_motes_md" );
	level._effect[ "fx_mp_castaway_air_dust" ] = loadfx( "maps/mp_maps/fx_mp_castaway_air_dust" );
	level._effect[ "fx_mp_castaway_air_mist" ] = loadfx( "maps/mp_maps/fx_mp_castaway_air_mist" );
	level._effect[ "fx_mp_castaway_air_dust_blow" ] = loadfx( "maps/mp_maps/fx_mp_castaway_air_dust_blow" );
	level._effect[ "fx_mp_castaway_leaf_debris" ] = loadfx( "maps/mp_maps/fx_mp_castaway_leaf_debris" );
	level._effect[ "fx_mp_castaway_vista_mist" ] = loadfx( "maps/mp_maps/fx_mp_castaway_vista_mist" );
	level._effect[ "fx_mp_castaway_vista_mist02" ] = loadfx( "maps/mp_maps/fx_mp_castaway_vista_mist02" );
	level._effect[ "fx_mp_carrier_spark_bounce_runner" ] = loadfx( "maps/mp_maps/fx_mp_carrier_spark_bounce_runner" );
	level._effect[ "fx_mp_elec_spark_burst_xsm_thin_runner" ] = loadfx( "maps/mp_maps/fx_mp_elec_spark_burst_xsm_thin_runner" );
	level._effect[ "fx_mp_castaway_spark_lite_runner" ] = loadfx( "maps/mp_maps/fx_mp_castaway_spark_lite_runner" );
	level._effect[ "fx_lf_mp_castaway_sun" ] = loadfx( "lens_flares/fx_lf_mp_castaway_sun" );
}

precache_fxanim_props()
{
	level.scr_anim = [];
	level.scr_anim[ "fxanim_props" ] = [];
	level.scr_anim[ "fxanim_props" ][ "seagull_circle_01" ] = %fxanim_gp_seagull_circle_01_anim;
	level.scr_anim[ "fxanim_props" ][ "seagull_circle_02" ] = %fxanim_gp_seagull_circle_02_anim;
	level.scr_anim[ "fxanim_props" ][ "seagull_circle_03" ] = %fxanim_gp_seagull_circle_03_anim;
	level.scr_anim[ "fxanim_props" ][ "river_debris_barrel" ] = %fxanim_angola_river_debris_barrel_anim;
	level.scr_anim[ "fxanim_props" ][ "shark_fins" ] = %fxanim_mp_stu_shark_fins_anim;
}

precache_fxanim_props_dlc3()
{
	level.scr_anim[ "fxanim_props_dlc3" ] = [];
	level.scr_anim[ "fxanim_props_dlc3" ][ "speed_boat" ] = %viewmodel_fxanim_mp_cast_speed_boat_anim;
	level.scr_anim[ "fxanim_props_dlc3" ][ "zodiac_boats" ] = %viewmodel_fxanim_mp_cast_zodiac_boats_anim;
	level.scr_anim[ "fxanim_props_dlc3" ][ "palm_tree_float" ] = %viewmodel_fxanim_mp_cast_palm_tree_float_anim;
	level.scr_anim[ "fxanim_props_dlc3" ][ "fish_grp_01" ] = %fxanim_mp_cast_fish_grp_01_anim;
	level.scr_anim[ "fxanim_props_dlc3" ][ "floating_boxes" ] = %fxanim_mp_cast_floating_boxes_anim;
	level.scr_anim[ "fxanim_props_dlc3" ][ "raft_ropes" ] = %fxanim_mp_cast_raft_ropes_anim;
	level.scr_anim[ "fxanim_props_dlc3" ][ "floating_seaweed" ] = %fxanim_mp_cast_seaweed_anim;
	level.scr_anim[ "fxanim_props_dlc3" ][ "floating_boxes_fx" ] = %fxanim_mp_cast_floating_boxes_fx_anim;
	level.scr_anim[ "fxanim_props_dlc3" ][ "crab_blue_01_01" ] = %fxanim_mp_cast_crab_blue_01_01_anim;
	level.scr_anim[ "fxanim_props_dlc3" ][ "crab_blue_01_02" ] = %fxanim_mp_cast_crab_blue_01_02_anim;
	level.scr_anim[ "fxanim_props_dlc3" ][ "crab_blue_02_01" ] = %fxanim_mp_cast_crab_blue_02_01_anim;
	level.scr_anim[ "fxanim_props_dlc3" ][ "crab_blue_02_02" ] = %fxanim_mp_cast_crab_blue_02_02_anim;
	level.scr_anim[ "fxanim_props_dlc3" ][ "crab_blue_03_01" ] = %fxanim_mp_cast_crab_blue_03_01_anim;
	level.scr_anim[ "fxanim_props_dlc3" ][ "crab_blue_03_02" ] = %fxanim_mp_cast_crab_blue_03_02_anim;
	level.scr_anim[ "fxanim_props_dlc3" ][ "hammock" ] = %fxanim_mp_cast_hammock_anim;
	level.scr_anim[ "fxanim_props_dlc3" ][ "vine_cluster" ] = %fxanim_gp_vine_cluster_anim;
}
