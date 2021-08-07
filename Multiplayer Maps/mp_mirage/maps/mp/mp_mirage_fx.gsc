#include maps/mp/_utility;

#using_animtree( "fxanim_props" );

main()
{
	precache_fxanim_props();
	precache_scripted_fx();
	precache_createfx_fx();
	maps/mp/createfx/mp_mirage_fx::main();
}

precache_scripted_fx()
{
}

precache_createfx_fx()
{
	level._effect[ "fx_mp_distortion_md" ] = loadfx( "maps/mp_maps/fx_mp_mirage_distortion_md" );
	level._effect[ "fx_mp_distortion_lg" ] = loadfx( "maps/mp_maps/fx_mp_mirage_distortion_lg" );
	level._effect[ "fx_mp_sand_gust_int_sm" ] = loadfx( "maps/mp_maps/fx_mp_mirage_sand_gust_int_sm" );
	level._effect[ "fx_mp_dust_lg" ] = loadfx( "maps/mp_maps/fx_mp_mirage_dust_lg" );
	level._effect[ "fx_mp_dust_xlg" ] = loadfx( "maps/mp_maps/fx_mp_mirage_dust_xlg" );
	level._effect[ "fx_mp_dust_xlg_fast" ] = loadfx( "maps/mp_maps/fx_mp_mirage_dust_xlg_fast" );
	level._effect[ "fx_mp_foliage_gust" ] = loadfx( "maps/mp_maps/fx_mp_mirage_foliage_gust" );
	level._effect[ "fx_mp_sand_dist_md" ] = loadfx( "maps/mp_maps/fx_mp_mirage_sand_dist_md" );
	level._effect[ "fx_mp_sand_fall_md" ] = loadfx( "maps/mp_maps/fx_mp_mirage_sand_fall_md" );
	level._effect[ "fx_mp_sand_fall_md_dist" ] = loadfx( "maps/mp_maps/fx_mp_mirage_sand_fall_md_dist" );
	level._effect[ "fx_mp_sand_fall_sm" ] = loadfx( "maps/mp_maps/fx_mp_mirage_sand_fall_sm" );
	level._effect[ "fx_mp_sand_gust_md" ] = loadfx( "maps/mp_maps/fx_mp_mirage_sand_gust_md" );
	level._effect[ "fx_mp_sand_gust_sm" ] = loadfx( "maps/mp_maps/fx_mp_mirage_sand_gust_sm" );
	level._effect[ "fx_mp_sand_gust_sm_far" ] = loadfx( "maps/mp_maps/fx_mp_mirage_sand_gust_sm_far" );
	level._effect[ "fx_mp_godray_md" ] = loadfx( "maps/mp_maps/fx_mp_mirage_godray_md" );
	level._effect[ "fx_mp_godray_lg" ] = loadfx( "maps/mp_maps/fx_mp_mirage_godray_lg" );
	level._effect[ "fx_mp_godray_sm" ] = loadfx( "maps/mp_maps/fx_mp_mirage_godray_sm" );
	level._effect[ "fx_mp_sand_wind" ] = loadfx( "maps/mp_maps/fx_mp_mirage_sand_wind" );
	level._effect[ "fx_mp_light_sm" ] = loadfx( "maps/mp_maps/fx_mp_mirage_light_sm" );
	level._effect[ "fx_mp_sun" ] = loadfx( "lens_flares/fx_lf_mp_mirage_sun1" );
	level._effect[ "fx_water_shower_dribble_splsh" ] = loadfx( "water/fx_water_shower_dribble_sm_splsh" );
	level._effect[ "fx_water_shower_dribble" ] = loadfx( "water/fx_water_shower_dribble_sm" );
}

precache_fxanim_props()
{
	level.scr_anim[ "fxanim_props" ][ "lantern_lrg" ] = %fxanim_mp_mirage_lantern_lrg_anim;
	level.scr_anim[ "fxanim_props" ][ "lantern_sm" ] = %fxanim_mp_mirage_lantern_sm_anim;
	level.scr_anim[ "fxanim_props" ][ "lamp" ] = %fxanim_mp_mirage_lamp_anim;
	level.scr_anim[ "fxanim_props" ][ "ruined_lanterns" ] = %fxanim_mp_mirage_lanterns_ruined_anim;
	level.scr_anim[ "fxanim_props" ][ "lanterns_string" ] = %fxanim_mp_mirage_lanterns_string_anim;
	level.scr_anim[ "fxanim_props" ][ "lantern_lrg_02" ] = %fxanim_mp_mirage_lantern_lrg_02_anim;
}
