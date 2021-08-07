#include maps/mp/_utility;

#using_animtree( "fxanim_props" );

main()
{
	precache_fxanim_props();
	precache_scripted_fx();
	precache_createfx_fx();
	maps/mp/createfx/mp_downhill_fx::main();
}

precache_scripted_fx()
{
}

precache_createfx_fx()
{
	level._effect[ "fx_lf_mp_downhill_sun1" ] = loadfx( "lens_flares/fx_lf_mp_downhill_sun1" );
	level._effect[ "fx_mp_downhill_snow_fall_lrg" ] = loadfx( "maps/mp_maps/fx_mp_downhill_snow_fall_lrg" );
	level._effect[ "fx_mp_downhill_snow_indoor_lg" ] = loadfx( "maps/mp_maps/fx_mp_downhill_snow_indoor_lg" );
	level._effect[ "fx_mp_downhill_snow_gust" ] = loadfx( "maps/mp_maps/fx_mp_downhill_snow_gust" );
	level._effect[ "fx_mp_downhill_snow_gust_floor" ] = loadfx( "maps/mp_maps/fx_mp_downhill_snow_gust_floor" );
	level._effect[ "fx_mp_downhill_snow_gust_cab" ] = loadfx( "maps/mp_maps/fx_mp_downhill_snow_gust_cab" );
	level._effect[ "fx_mp_downhill_snow_gust_in" ] = loadfx( "maps/mp_maps/fx_mp_downhill_snow_gust_in" );
	level._effect[ "fx_mp_downhill_snow_tree" ] = loadfx( "maps/mp_maps/fx_mp_downhill_snow_tree" );
	level._effect[ "fx_mp_downhill_snow_tree_trunk" ] = loadfx( "maps/mp_maps/fx_mp_downhill_snow_tree_trunk" );
	level._effect[ "fx_mp_downhill_water_drips" ] = loadfx( "maps/mp_maps/fx_mp_downhill_water_drips" );
	level._effect[ "fx_mp_downhill_sparkle" ] = loadfx( "maps/mp_maps/fx_mp_downhill_sparkle" );
	level._effect[ "fx_mp_downhill_fog_vista" ] = loadfx( "maps/mp_maps/fx_mp_downhill_fog_vista" );
	level._effect[ "fx_mp_downhill_fog_vista_wide" ] = loadfx( "maps/mp_maps/fx_mp_downhill_fog_vista_wide" );
	level._effect[ "fx_mp_downhill_fog_vista_light" ] = loadfx( "maps/mp_maps/fx_mp_downhill_fog_vista_light" );
	level._effect[ "fx_mp_downhill_fireplace" ] = loadfx( "maps/mp_maps/fx_mp_downhill_fireplace" );
	level._effect[ "fx_mp_downhill_light_sml" ] = loadfx( "maps/mp_maps/fx_mp_downhill_light_sml" );
	level._effect[ "fx_mp_downhill_fog_int" ] = loadfx( "maps/mp_maps/fx_mp_downhill_fog_int" );
	level._effect[ "fx_mp_downhill_fog_int_3" ] = loadfx( "maps/mp_maps/fx_mp_downhill_fog_int_3" );
	level._effect[ "fx_mp_downhill_chimney_smk" ] = loadfx( "maps/mp_maps/fx_mp_downhill_chimney_smk" );
	level._effect[ "fx_mp_downhill_light_lg" ] = loadfx( "maps/mp_maps/fx_mp_downhill_light_lg" );
	level._effect[ "fx_mp_downhill_gust_window" ] = loadfx( "maps/mp_maps/fx_mp_downhill_gust_window" );
	level._effect[ "fx_mp_downhill_exhaust" ] = loadfx( "maps/mp_maps/fx_mp_downhill_exhaust" );
	level._effect[ "fx_mp_downhill_tractor_lights" ] = loadfx( "maps/mp_maps/fx_mp_downhill_tractor_lights" );
	level._effect[ "fx_mp_downhill_tractor_lights_sm" ] = loadfx( "maps/mp_maps/fx_mp_downhill_tractor_lights_sm" );
}

precache_fxanim_props()
{
	level.scr_anim[ "fxanim_props" ][ "wirespark_med" ] = %fxanim_gp_wirespark_med_anim;
	level.scr_anim[ "fxanim_props" ][ "teardrop_flag" ] = %fxanim_gp_teardrop_flag_loop_anim;
	level.scr_anim[ "fxanim_props" ][ "windsock" ] = %fxanim_gp_windsock_anim;
	level.scr_anim[ "fxanim_props" ][ "quad_chair" ] = %viewmodel_fxanim_mp_downhill_quad_chair_loop_anim;
	level.scr_anim[ "fxanim_props" ][ "xmas_lights" ] = %fxanim_gp_xmas_lights_anim;
	level.scr_anim[ "fxanim_props" ][ "standing_skiis" ] = %fxanim_mp_downhill_standing_skiis_loop_anim;
	level.scr_anim[ "fxanim_props" ][ "standing_skiis_02" ] = %fxanim_mp_downhill_standing_skiis_loop_02_anim;
}
