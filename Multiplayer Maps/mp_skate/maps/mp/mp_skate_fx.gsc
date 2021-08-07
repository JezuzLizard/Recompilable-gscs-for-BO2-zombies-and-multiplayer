#include maps/mp/_utility;

#using_animtree( "fxanim_props" );

main()
{
	precache_fxanim_props();
	precache_scripted_fx();
	precache_createfx_fx();
	maps/mp/createfx/mp_skate_fx::main();
}

precache_scripted_fx()
{
}

precache_createfx_fx()
{
	level._effect[ "fx_lf_mp_skate_sun1" ] = loadfx( "lens_flares/fx_lf_mp_skate_sun1" );
	level._effect[ "fx_mp_debris_papers" ] = loadfx( "maps/mp_maps/fx_mp_debris_papers" );
	level._effect[ "fx_mp_skate_dust" ] = loadfx( "maps/mp_maps/fx_mp_skate_dust" );
	level._effect[ "fx_mp_skate_flies" ] = loadfx( "maps/mp_maps/fx_mp_skate_flies" );
	level._effect[ "fx_insects_swarm_lg_light" ] = loadfx( "bio/insects/fx_insects_swarm_lg_light" );
	level._effect[ "fx_mp_skate_seaguls" ] = loadfx( "maps/mp_maps/fx_mp_skate_seaguls" );
	level._effect[ "fx_mp_skate_paper_devil" ] = loadfx( "maps/mp_maps/fx_mp_skate_paper_devil" );
	level._effect[ "fx_mp_skate_paper_tree_gust" ] = loadfx( "maps/mp_maps/fx_mp_skate_paper_tree_gust" );
	level._effect[ "fx_mp_skate_light_sml" ] = loadfx( "maps/mp_maps/fx_mp_skate_light_sml" );
	level._effect[ "fx_mp_skate_light_sq" ] = loadfx( "maps/mp_maps/fx_mp_skate_light_sq" );
	level._effect[ "fx_mp_skate_light_sq_2" ] = loadfx( "maps/mp_maps/fx_mp_skate_light_sq_2" );
	level._effect[ "fx_mp_skate_light_sq_3" ] = loadfx( "maps/mp_maps/fx_mp_skate_light_sq_3" );
	level._effect[ "fx_mp_skate_light_sq_4" ] = loadfx( "maps/mp_maps/fx_mp_skate_light_sq_4" );
	level._effect[ "fx_mp_skate_godray_lg" ] = loadfx( "maps/mp_maps/fx_mp_skate_godray_lg" );
	level._effect[ "fx_mp_skate_godray_lg_2" ] = loadfx( "maps/mp_maps/fx_mp_skate_godray_lg_2" );
	level._effect[ "fx_mp_skate_godray_md" ] = loadfx( "maps/mp_maps/fx_mp_skate_godray_md" );
	level._effect[ "fx_mp_light_dust_motes_md" ] = loadfx( "maps/mp_maps/fx_mp_light_dust_motes_md" );
	level._effect[ "fx_mp_skate_sand_gust" ] = loadfx( "maps/mp_maps/fx_mp_skate_sand_gust" );
	level._effect[ "fx_mp_skate_sand_gust_sm" ] = loadfx( "maps/mp_maps/fx_mp_skate_sand_gust_sm" );
	level._effect[ "fx_mp_skate_toilet_water" ] = loadfx( "maps/mp_maps/fx_mp_skate_toilet_water" );
	level._effect[ "fx_paper_swirl_tube" ] = loadfx( "debris/fx_paper_swirl_tube" );
	level._effect[ "fx_paper_arc_ramp" ] = loadfx( "debris/fx_paper_arc_ramp" );
}

precache_fxanim_props()
{
	level.scr_anim[ "fxanim_props" ][ "air_dancer" ] = %fxanim_mp_skate_air_dancer_anim;
	level.scr_anim[ "fxanim_props" ][ "seagull_circle_01" ] = %fxanim_gp_seagull_circle_01_anim;
	level.scr_anim[ "fxanim_props" ][ "seagull_circle_02" ] = %fxanim_gp_seagull_circle_02_anim;
	level.scr_anim[ "fxanim_props" ][ "seagull_circle_03" ] = %fxanim_gp_seagull_circle_03_anim;
	level.scr_anim[ "fxanim_props" ][ "ferris_wheel_spin" ] = %fxanim_mp_skate_ferris_wheel_spin_anim;
	level.scr_anim[ "fxanim_props" ][ "banner_01" ] = %fxanim_mp_skate_banner_01_anim;
	level.scr_anim[ "fxanim_props" ][ "teardrop_flag" ] = %fxanim_gp_teardrop_flag_loop_anim;
}
