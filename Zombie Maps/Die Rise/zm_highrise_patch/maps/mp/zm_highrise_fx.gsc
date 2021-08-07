#include maps/mp/_utility;

#using_animtree( "fxanim_props" );

main()
{
	precache_createfx_fx();
	precache_scripted_fx();
	precache_fxanim_props();
	maps/mp/createfx/zm_highrise_fx::main();
}

precache_scripted_fx()
{
	level._effect[ "switch_sparks" ] = loadfx( "maps/zombie/fx_zmb_pswitch_spark" );
	level._effect[ "zapper_light_ready" ] = loadfx( "maps/zombie/fx_zombie_zapper_light_green" );
	level._effect[ "zapper_light_notready" ] = loadfx( "maps/zombie/fx_zombie_zapper_light_red" );
	level._effect[ "lght_marker" ] = loadfx( "maps/zombie/fx_zmb_tranzit_marker" );
	level._effect[ "pandora_box_inverted" ] = loadfx( "maps/zombie/fx_zmb_highrise_marker" );
	level._effect[ "lght_marker_flare" ] = loadfx( "maps/zombie/fx_zmb_tranzit_marker_fl" );
	level._effect[ "poltergeist" ] = loadfx( "misc/fx_zombie_couch_effect" );
	level._effect[ "zomb_gib" ] = loadfx( "maps/zombie/fx_zmb_tranzit_lava_torso_explo" );
	level._effect[ "elec_md" ] = loadfx( "electrical/fx_elec_player_md" );
	level._effect[ "elec_sm" ] = loadfx( "electrical/fx_elec_player_sm" );
	level._effect[ "elec_torso" ] = loadfx( "electrical/fx_elec_player_torso" );
	level._effect[ "blue_eyes" ] = loadfx( "maps/zombie/fx_zombie_eye_single_blue" );
	level._effect[ "elevator_tell" ] = loadfx( "maps/zombie_highrise/fx_highrise_elevator_tell" );
	level._effect[ "elevator_sparks" ] = loadfx( "maps/zombie_highrise/fx_highrise_elevator_sparks" );
	level._effect[ "elevator_impact" ] = loadfx( "maps/zombie_highrise/fx_highrise_elevator_impact" );
	level._effect[ "elevator_glint" ] = loadfx( "maps/zombie_highrise/fx_highrise_key_glint" );
	level._effect[ "elevator_light" ] = loadfx( "maps/zombie_highrise/fx_highrise_elevator_light" );
	level._effect[ "perk_elevator_idle" ] = loadfx( "maps/zombie_highrise/fx_highrise_elevator_perk_slow" );
	level._effect[ "perk_elevator_departing" ] = loadfx( "maps/zombie_highrise/fx_highrise_elevator_perk_fast" );
	level._effect[ "perk_elevator_indicator_up" ] = loadfx( "maps/zombie_highrise/fx_highrise_elevator_arrow_up" );
	level._effect[ "perk_elevator_indicator_down" ] = loadfx( "maps/zombie_highrise/fx_highrise_elevator_arrow_down" );
	level._effect[ "sidequest_dragon_spark_max" ] = loadfx( "maps/zombie_highrise/fx_highrise_dragon_spark_max" );
	level._effect[ "sidequest_dragon_fireball_max" ] = loadfx( "maps/zombie_highrise/fx_highrise_dragon_fireball_max" );
	level._effect[ "sidequest_dragon_spark_ric" ] = loadfx( "maps/zombie_highrise/fx_highrise_dragon_spark_ric" );
	level._effect[ "sidequest_dragon_fireball_ric" ] = loadfx( "maps/zombie_highrise/fx_highrise_dragon_fireball_ric" );
	level._effect[ "sidequest_flash" ] = loadfx( "maps/zombie_highrise/fx_highrise_sq_flash" );
	level._effect[ "sidequest_tower_bolts" ] = loadfx( "maps/zombie_highrise/fx_highrise_sidequest_tower_bolts" );
}

precache_createfx_fx()
{
	level._effect[ "fx_highrise_cloud_lg_single" ] = loadfx( "maps/zombie_highrise/fx_highrise_cloud_lg_single" );
	level._effect[ "fx_highrise_cloud_lg_flat" ] = loadfx( "maps/zombie_highrise/fx_highrise_cloud_lg_flat" );
	level._effect[ "fx_highrise_cloud_lg_left" ] = loadfx( "maps/zombie_highrise/fx_highrise_cloud_lg_left" );
	level._effect[ "fx_highrise_cloud_lg_right" ] = loadfx( "maps/zombie_highrise/fx_highrise_cloud_lg_right" );
	level._effect[ "fx_highrise_cloud_sm_bottom" ] = loadfx( "maps/zombie_highrise/fx_highrise_cloud_sm_bottom" );
	level._effect[ "fx_highrise_cloud_sm_right" ] = loadfx( "maps/zombie_highrise/fx_highrise_cloud_sm_right" );
	level._effect[ "fx_highrise_cloud_bend_sm" ] = loadfx( "maps/zombie_highrise/fx_highrise_cloud_bend_sm" );
	level._effect[ "fx_highrise_cloud_bend_01" ] = loadfx( "maps/zombie_highrise/fx_highrise_cloud_bend_01" );
	level._effect[ "fx_highrise_meteor_lg_bottom" ] = loadfx( "maps/zombie_highrise/fx_highrise_meteor_lg_bottom" );
	level._effect[ "fx_highrise_meteor_lg_top" ] = loadfx( "maps/zombie_highrise/fx_highrise_meteor_lg_top" );
	level._effect[ "fx_highrise_meteor_lg_top2" ] = loadfx( "maps/zombie_highrise/fx_highrise_meteor_lg_top2" );
	level._effect[ "fx_highrise_meteor_sm_top" ] = loadfx( "maps/zombie_highrise/fx_highrise_meteor_sm_top" );
	level._effect[ "fx_highrise_meteor_sm_horizon" ] = loadfx( "maps/zombie_highrise/fx_highrise_meteor_sm_horizon" );
	level._effect[ "fx_lf_zmb_highrise_sun" ] = loadfx( "lens_flares/fx_lf_zmb_highrise_sun" );
	level._effect[ "fx_zmb_flies" ] = loadfx( "maps/zombie/fx_zmb_flies" );
	level._effect[ "fx_zmb_tranzit_fire_med" ] = loadfx( "maps/zombie/fx_zmb_tranzit_fire_med" );
	level._effect[ "fx_highrise_ash_rising_md" ] = loadfx( "maps/zombie_highrise/fx_highrise_ash_rising_md" );
	level._effect[ "fx_highrise_bld_crumble_runner" ] = loadfx( "maps/zombie_highrise/fx_highrise_bld_crumble_runner" );
	level._effect[ "fx_highrise_ceiling_dust_md_runner" ] = loadfx( "maps/zombie_highrise/fx_highrise_ceiling_dust_md_runner" );
	level._effect[ "fx_highrise_ceiling_dust_sm_runner" ] = loadfx( "maps/zombie_highrise/fx_highrise_ceiling_dust_sm_runner" );
	level._effect[ "fx_highrise_ceiling_dust_edge_100" ] = loadfx( "maps/zombie_highrise/fx_highrise_ceiling_dust_edge_100" );
	level._effect[ "fx_highrise_edge_crumble_ext" ] = loadfx( "maps/zombie_highrise/fx_highrise_edge_crumble_ext" );
	level._effect[ "fx_highrise_point_crumble_ext" ] = loadfx( "maps/zombie_highrise/fx_highrise_point_crumble_ext" );
	level._effect[ "fx_highrise_wire_spark" ] = loadfx( "maps/zombie_highrise/fx_highrise_wire_spark" );
	level._effect[ "fx_highrise_water_drip_fast" ] = loadfx( "maps/zombie_highrise/fx_highrise_water_drip_fast" );
	level._effect[ "fx_highrise_haze_int_med" ] = loadfx( "maps/zombie_highrise/fx_highrise_haze_int_med" );
	level._effect[ "fx_highrise_fire_distant" ] = loadfx( "maps/zombie_highrise/fx_highrise_fire_distant" );
	level._effect[ "fx_highrise_smk_plume_sm" ] = loadfx( "maps/zombie_highrise/fx_highrise_smk_plume_sm" );
	level._effect[ "fx_highrise_smk_plume_md" ] = loadfx( "maps/zombie_highrise/fx_highrise_smk_plume_md" );
	level._effect[ "fx_highrise_smk_plume_xlg" ] = loadfx( "maps/zombie_highrise/fx_highrise_smk_plume_xlg" );
	level._effect[ "fx_highrise_moon" ] = loadfx( "maps/zombie_highrise/fx_highrise_moon" );
	level._effect[ "fx_highrise_god_ray_sm" ] = loadfx( "maps/zombie_highrise/fx_highrise_god_ray_sm" );
	level._effect[ "fx_highrise_god_ray_md" ] = loadfx( "maps/zombie_highrise/fx_highrise_god_ray_md" );
	level._effect[ "fx_highrise_god_ray_cool_sm" ] = loadfx( "maps/zombie_highrise/fx_highrise_god_ray_cool_sm" );
	level._effect[ "fx_highrise_god_ray_cool_md" ] = loadfx( "maps/zombie_highrise/fx_highrise_god_ray_cool_md" );
	level._effect[ "fx_highrise_light_bulb" ] = loadfx( "maps/zombie_highrise/fx_highrise_light_bulb" );
	level._effect[ "fx_highrise_light_build_lamp" ] = loadfx( "maps/zombie_highrise/fx_highrise_light_build_lamp" );
	level._effect[ "fx_highrise_light_fluorescent" ] = loadfx( "maps/zombie_highrise/fx_highrise_light_fluorescent" );
	level._effect[ "fx_highrise_light_fluorescent_wall" ] = loadfx( "maps/zombie_highrise/fx_highrise_light_fluorescent_wall" );
	level._effect[ "fx_highrise_light_fluorescent_wal2" ] = loadfx( "maps/zombie_highrise/fx_highrise_light_fluorescent_wal2" );
	level._effect[ "fx_highrise_light_recessed" ] = loadfx( "maps/zombie_highrise/fx_highrise_light_recessed" );
	level._effect[ "fx_highrise_light_recessed_md" ] = loadfx( "maps/zombie_highrise/fx_highrise_light_recessed_md" );
	level._effect[ "fx_highrise_light_recessed_tall" ] = loadfx( "maps/zombie_highrise/fx_highrise_light_recessed_tall" );
	level._effect[ "fx_highrise_light_recessed_tiny" ] = loadfx( "maps/zombie_highrise/fx_highrise_light_recessed_tiny" );
	level._effect[ "fx_highrise_light_mall" ] = loadfx( "maps/zombie_highrise/fx_highrise_light_mall" );
	level._effect[ "fx_highrise_light_lantern_red" ] = loadfx( "maps/zombie_highrise/fx_highrise_light_lantern_red" );
	level._effect[ "fx_highrise_light_lantern_yel" ] = loadfx( "maps/zombie_highrise/fx_highrise_light_lantern_yel" );
	level._effect[ "fx_highrise_light_sconce_glow" ] = loadfx( "maps/zombie_highrise/fx_highrise_light_sconce_glow" );
	level._effect[ "fx_highrise_light_sconce_beam" ] = loadfx( "maps/zombie_highrise/fx_highrise_light_sconce_beam" );
	level._effect[ "fx_highrise_dragon_breath_max" ] = loadfx( "maps/zombie_highrise/fx_highrise_dragon_breath_max" );
	level._effect[ "fx_highrise_dragon_tower_absorb_max" ] = loadfx( "maps/zombie_highrise/fx_highrise_dragon_tower_absorb_max" );
	level._effect[ "fx_highrise_dragon_tower_glow_max" ] = loadfx( "maps/zombie_highrise/fx_highrise_dragon_tower_glow_max" );
	level._effect[ "fx_highrise_sidequest_complete" ] = loadfx( "maps/zombie_highrise/fx_highrise_sidequest_complete" );
	level._effect[ "fx_highrise_dragon_breath_ric" ] = loadfx( "maps/zombie_highrise/fx_highrise_dragon_breath_ric" );
	level._effect[ "fx_highrise_dragon_tower_absorb_ric" ] = loadfx( "maps/zombie_highrise/fx_highrise_dragon_tower_absorb_ric" );
	level._effect[ "fx_highrise_dragon_tower_glow_ric" ] = loadfx( "maps/zombie_highrise/fx_highrise_dragon_tower_glow_ric" );
	level._effect[ "fx_highrise_sidequest_complete_ric" ] = loadfx( "maps/zombie_highrise/fx_highrise_sidequest_complete_ric" );
}

precache_fxanim_props()
{
	level.scr_anim[ "fxanim_props" ][ "wirespark_med_lrg" ] = %fxanim_gp_wirespark_med_lrg_anim;
	level.scr_anim[ "fxanim_props" ][ "wirespark_long_lrg" ] = %fxanim_gp_wirespark_long_lrg_anim;
	level.scr_anim[ "fxanim_props" ][ "roaches" ] = %fxanim_gp_roaches_anim;
	level.scr_anim[ "fxanim_props" ][ "dragon_a" ] = %fxanim_zom_highrise_dragon_a_anim;
	level.scr_anim[ "fxanim_props" ][ "dragon_b" ] = %fxanim_zom_highrise_dragon_b_anim;
	level.scr_anim[ "fxanim_props" ][ "dragon" ] = %fxanim_zom_highrise_dragon_idle_anim;
	level.scr_anim[ "fxanim_props" ][ "rock_slide" ] = %fxanim_zom_highrise_rock_slide_anim;
}
