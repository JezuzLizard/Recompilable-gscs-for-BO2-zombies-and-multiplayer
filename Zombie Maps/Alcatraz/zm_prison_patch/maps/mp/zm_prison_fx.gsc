#include maps/mp/_utility;

#using_animtree( "fxanim_props" );

main()
{
	precache_createfx_fx();
	precache_scripted_fx();
	precache_fxanim_props();
	maps/mp/createfx/zm_prison_fx::main();
}

precache_scripted_fx()
{
	level._effect[ "elevator_fall" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_elevator_fall" );
	level._effect[ "key_glint" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_key_glint" );
	level._effect[ "quest_item_glow" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_quest_item_glow" );
	level._effect[ "eye_glow" ] = loadfx( "maps/zombie_alcatraz/fx_zombie_eye_single_red" );
	level._effect[ "fx_alcatraz_unlock_door" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_unlock_door" );
	level._effect[ "fx_alcatraz_elec_chair" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_elec_chair" );
	level._effect[ "fx_alcatraz_lightning_finale" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_lightning_finale" );
	level._effect[ "fx_alcatraz_panel_on_2" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_panel_on_2" );
	level._effect[ "fx_alcatraz_panel_off_2" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_panel_off_2" );
	level._effect[ "fx_alcatraz_lightning_wire" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_lightning_wire" );
	level._effect[ "fx_alcatraz_afterlife_zmb_tport" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_afterlife_zmb_tport" );
	level._effect[ "fx_alcatraz_panel_ol" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_panel_ol" );
	level._effect[ "fx_alcatraz_plane_apear" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_plane_apear" );
	level._effect[ "switch_sparks" ] = loadfx( "env/electrical/fx_elec_wire_spark_burst" );
	level._effect[ "zapper_light_ready" ] = loadfx( "maps/zombie/fx_zombie_zapper_light_green" );
	level._effect[ "zapper_light_notready" ] = loadfx( "maps/zombie/fx_zombie_zapper_light_red" );
	level._effect[ "fx_alcatraz_plane_trail" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_plane_trail" );
	level._effect[ "fx_alcatraz_plane_trail_fast" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_plane_trail_fast" );
	level._effect[ "fx_alcatraz_flight_lightning" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_flight_lightning" );
	level._effect[ "fx_alcatraz_plane_fire_trail" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_plane_fire_trail" );
	level._effect[ "alcatraz_dryer_light_green" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_dryer_light_green" );
	level._effect[ "alcatraz_dryer_light_red" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_dryer_light_red" );
	level._effect[ "alcatraz_dryer_light_yellow" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_dryer_light_yellow" );
	level._effect[ "zomb_gib" ] = loadfx( "maps/zombie/fx_zmb_tranzit_lava_torso_explo" );
	level._effect[ "elec_md" ] = loadfx( "electrical/fx_elec_player_md" );
	level._effect[ "elec_sm" ] = loadfx( "electrical/fx_elec_player_sm" );
	level._effect[ "elec_torso" ] = loadfx( "electrical/fx_elec_player_torso" );
	level._effect[ "acid_spray" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_acid_spray" );
	level._effect[ "acid_death" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_acid_death" );
	level._effect[ "box_activated" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_box_charge" );
	level._effect[ "fan_blood" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_fan_blood" );
	level._effect[ "light_gondola" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_light_gondola" );
	level._effect[ "lightning_flash" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_lightning_lg" );
	level._effect[ "tomahawk_trail" ] = loadfx( "weapon/tomahawk/fx_tomahawk_trail" );
	level._effect[ "tomahawk_trail_ug" ] = loadfx( "weapon/tomahawk/fx_tomahawk_trail_ug" );
	level._effect[ "tomahawk_impact" ] = loadfx( "weapon/tomahawk/fx_tomahawk_impact" );
	level._effect[ "tomahawk_impact_ug" ] = loadfx( "weapon/tomahawk/fx_tomahawk_impact_ug" );
	level._effect[ "tomahawk_charge_up" ] = loadfx( "weapon/tomahawk/fx_tomahawk_charge" );
	level._effect[ "tomahawk_charge_up_ug" ] = loadfx( "weapon/tomahawk/fx_tomahawk_charge_ug" );
	level._effect[ "tomahawk_pickup" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_tomahawk_pickup" );
	level._effect[ "tomahawk_pickup_upgrade" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_tomahawk_pickup_ug" );
	level._effect[ "tomahawk_charged_trail" ] = loadfx( "weapon/tomahawk/fx_tomahawk_trail_charged" );
	level._effect[ "tomahawk_fire_dot" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_zmb_fire_torso" );
	level._effect[ "soul_charge_start" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_soul_charge_start" );
	level._effect[ "soul_charge" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_soul_charge" );
	level._effect[ "soul_charge_impact" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_soul_charge_impact" );
	level._effect[ "soul_charged" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_soul_charged" );
	level._effect[ "hell_portal" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_portal_hell" );
	level._effect[ "hell_portal_close" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_portal_hell_close" );
	level._effect[ "tomahawk_hellhole" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_brutus_footstomp" );
	level._effect[ "wolf_bite_blood" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_soul_charge_impact_sm" );
	level._effect[ "uzi_zm_fx" ] = loadfx( "maps/zombie/fx_zmb_wall_buy_uzi" );
	level._effect[ "thompson_zm_fx" ] = loadfx( "maps/zombie/fx_zmb_wall_buy_thompson" );
	level._effect[ "fx_alcatraz_lighthouse" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_light_house" );
	level._effect[ "ee_skull_shot" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_skull_elec_2" );
}

precache_createfx_fx()
{
	level._effect[ "fx_alcatraz_storm_start" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_storm_start" );
	level._effect[ "fx_alcatraz_vista_fog" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_vista_fog" );
	level._effect[ "fx_alcatraz_docks_fog" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_docks_fog" );
	level._effect[ "fx_alcatraz_fog_closet" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_fog_closet" );
	level._effect[ "fx_alcatraz_fire_works" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_fire_works" );
	level._effect[ "fx_alcatraz_tunnel_dust_fall" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_tunnel_dust_fall" );
	level._effect[ "fx_alcatraz_tunnel_ash" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_tunnel_ash" );
	level._effect[ "fx_alcatraz_steam_pipe_2" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_steam_pipe_2" );
	level._effect[ "fx_alcatraz_steam_pipe" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_steam_pipe" );
	level._effect[ "fx_alcatraz_shower_steam" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_shower_steam" );
	level._effect[ "fx_alcatraz_steam_pipe" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_steam_pipe" );
	level._effect[ "fx_alcatraz_panel_on" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_panel_on" );
	level._effect[ "fx_alcatraz_door_blocker" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_door_blocker" );
	level._effect[ "fx_alcatraz_dryer_on" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_dryer_on" );
	level._effect[ "fx_alcatraz_elec_fence" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_elec_fence" );
	level._effect[ "fx_alcatraz_generator_smk" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_generator_smk" );
	level._effect[ "fx_alcatraz_generator_sparks" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_generator_sparks" );
	level._effect[ "fx_alcatraz_generator_exp" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_generator_exp" );
	level._effect[ "fx_alcatraz_elevator_spark" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_elevator_spark" );
	level._effect[ "fx_alcatraz_elec_key" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_elec_key" );
	level._effect[ "fx_alcatraz_sparks_ceiling" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_sparks_ceiling" );
	level._effect[ "fx_alcatraz_sparks_panel" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_sparks_panel" );
	level._effect[ "fx_alcatraz_fire_sm" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_fire_sm" );
	level._effect[ "fx_alcatraz_fire_xsm" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_fire_xsm" );
	level._effect[ "fx_alcatraz_embers_flat" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_embers_flat" );
	level._effect[ "fx_alcatraz_falling_fire" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_falling_fire" );
	level._effect[ "fx_alcatraz_steam_3floor" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_steam_3floor" );
	level._effect[ "fx_alcatraz_elec_box_amb" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_elec_box_amb" );
	level._effect[ "fx_alcatraz_blood_drip" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_blood_drip" );
	level._effect[ "fx_alcatraz_godray_grill" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_godray_grill" );
	level._effect[ "fx_alcatraz_godray_grill_lg" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_godray_grill_lg" );
	level._effect[ "fx_alcatraz_godray_skinny" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_godray_skinny" );
	level._effect[ "fx_alcatraz_ground_fog" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_ground_fog" );
	level._effect[ "fx_alcatraz_flies" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_flies" );
	level._effect[ "fx_alcatraz_candle_fire" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_candle_fire" );
	level._effect[ "fx_alcatraz_portal_amb" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_portal_amb" );
	level._effect[ "fx_alcatraz_fire_md" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_fire_md" );
	level._effect[ "fx_alcatraz_smk_linger" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_smk_linger" );
	level._effect[ "fx_alcatraz_embers_indoor" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_embers_indoor" );
	level._effect[ "fx_alcatraz_papers" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_papers" );
	level._effect[ "fx_alcatraz_ceiling_fire" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_ceiling_fire" );
	level._effect[ "fx_alcatraz_steam_ash" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_steam_ash" );
	level._effect[ "fx_alcatraz_godray_jail" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_godray_jail" );
	level._effect[ "fx_alcatraz_water_drip" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_water_drip" );
	level._effect[ "fx_alcatraz_shower_steam" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_shower_steam" );
	level._effect[ "fx_alcatraz_steam_pipe" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_steam_pipe" );
	level._effect[ "fx_alcatraz_light_tinhat" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_light_tinhat" );
	level._effect[ "fx_alcatraz_light_round_oo" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_light_round_oo" );
	level._effect[ "fx_alcatraz_light_tinhat_oo" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_light_tinhat_oo" );
	level._effect[ "fx_alcatraz_flight_clouds" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_flight_clouds" );
	level._effect[ "fx_alcatraz_lightning_bridge" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_lightning_bridge" );
	level._effect[ "fx_alcatraz_elec_chair" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_elec_chair" );
}

precache_fxanim_props()
{
	level.scr_anim[ "fxanim_props" ][ "wirespark_med" ] = %fxanim_gp_wirespark_med_anim;
	level.scr_anim[ "fxanim_props" ][ "dryer_start" ] = %fxanim_zom_al_industrial_dryer_start_anim;
	level.scr_anim[ "fxanim_props" ][ "dryer_idle" ] = %fxanim_zom_al_industrial_dryer_idle_anim;
	level.scr_anim[ "fxanim_props" ][ "dryer_end" ] = %fxanim_zom_al_industrial_dryer_end_anim;
	level.scr_anim[ "fxanim_props" ][ "dryer_hide" ] = %fxanim_zom_al_industrial_dryer_hide_anim;
	level.scr_anim[ "fxanim_props" ][ "pulley_down" ] = %fxanim_zom_al_key_pulley_down_anim;
	level.scr_anim[ "fxanim_props" ][ "pulley_up" ] = %fxanim_zom_al_key_pulley_up_anim;
	level.scr_anim[ "fxanim_props" ][ "crane_palette" ] = %fxanim_zom_al_crane_palette_anim;
	level.scr_anim[ "fxanim_props" ][ "chain_hook_rotate" ] = %fxanim_zom_al_chain_short_hook_rotate_anim;
	level.scr_anim[ "fxanim_props" ][ "bodybag_rotate" ] = %fxanim_zom_al_bodybag_rotate_anim;
	level.scr_anim[ "fxanim_props" ][ "chain_hook_swing" ] = %fxanim_zom_al_chain_short_hook_swing_anim;
	level.scr_anim[ "fxanim_props" ][ "bodybag_swing" ] = %fxanim_zom_al_bodybag_swing_anim;
	level.scr_anim[ "fxanim_props" ][ "chain_hook_crane" ] = %fxanim_zom_al_chain_short_hook_crane_anim;
	level.scr_anim[ "fxanim_props" ][ "bodybag_crane" ] = %fxanim_zom_al_bodybag_crane_anim;
}
