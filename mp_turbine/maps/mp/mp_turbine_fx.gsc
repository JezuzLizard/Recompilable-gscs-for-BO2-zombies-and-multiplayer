#include maps/mp/_utility;

#using_animtree( "fxanim_props" );

main()
{
	precache_fxanim_props();
	precache_scripted_fx();
	precache_createfx_fx();
	maps/mp/createfx/mp_turbine_fx::main();
	maps/mp/createart/mp_turbine_art::main();
}

precache_scripted_fx()
{
}

precache_createfx_fx()
{
	level._effect[ "fx_sand_blowing_lg" ] = loadfx( "dirt/fx_sand_blowing_lg" );
	level._effect[ "fx_sand_blowing_md" ] = loadfx( "dirt/fx_sand_blowing_md" );
	level._effect[ "fx_sand_blowing_sm" ] = loadfx( "dirt/fx_sand_blowing_sm" );
	level._effect[ "fx_sand_gust_ground_lg" ] = loadfx( "dirt/fx_sand_gust_ground_lg" );
	level._effect[ "fx_sand_gust_ground_sm" ] = loadfx( "dirt/fx_sand_gust_ground_sm" );
	level._effect[ "fx_sand_gust_ground_md" ] = loadfx( "dirt/fx_sand_gust_ground_md" );
	level._effect[ "fx_sand_gust_door" ] = loadfx( "dirt/fx_sand_gust_door" );
	level._effect[ "fx_sand_blowing_lg_vista" ] = loadfx( "dirt/fx_sand_blowing_lg_vista" );
	level._effect[ "fx_sand_blowing_lg_vista_shrt" ] = loadfx( "dirt/fx_sand_blowing_lg_vista_shrt" );
	level._effect[ "fx_sand_gust_cliff_fall" ] = loadfx( "dirt/fx_sand_gust_cliff_fall" );
	level._effect[ "fx_sand_gust_cliff_fall_md" ] = loadfx( "dirt/fx_sand_gust_cliff_fall_md" );
	level._effect[ "fx_sand_gust_cliff_fall_md_lng" ] = loadfx( "dirt/fx_sand_gust_cliff_fall_md_lng" );
	level._effect[ "fx_sand_gust_cliff_edge_md" ] = loadfx( "dirt/fx_sand_gust_cliff_edge_md" );
	level._effect[ "fx_sand_swirl_lg_pipe" ] = loadfx( "dirt/fx_sand_swirl_lg_pipe" );
	level._effect[ "fx_sand_swirl_sm_pipe" ] = loadfx( "dirt/fx_sand_swirl_sm_pipe" );
	level._effect[ "fx_sand_swirl_debris_pipe" ] = loadfx( "dirt/fx_sand_swirl_debris_pipe" );
	level._effect[ "fx_mp_light_wind_turbine" ] = loadfx( "maps/mp_maps/fx_mp_light_wind_turbine" );
	level._effect[ "fx_light_floodlight_sqr_cool" ] = loadfx( "light/fx_light_floodlight_sqr_cool" );
	level._effect[ "fx_light_flour_glow_cool_dbl_shrt" ] = loadfx( "light/fx_light_flour_glow_cool_dbl_shrt" );
	level._effect[ "fx_mp_sun_flare_turbine_streak" ] = loadfx( "maps/mp_maps/fx_mp_sun_flare_turbine_streak" );
	level._effect[ "fx_mp_sun_flare_turbine" ] = loadfx( "maps/mp_maps/fx_mp_sun_flare_turbine" );
	level._effect[ "fx_lf_mp_turbine_sun1" ] = loadfx( "lens_flares/fx_lf_mp_turbine_sun1" );
}

precache_fxanim_props()
{
	level.scr_anim[ "fxanim_props" ][ "wires_01" ] = %fxanim_mp_turbine_wires_01_anim;
	level.scr_anim[ "fxanim_props" ][ "wires_02" ] = %fxanim_mp_turbine_wires_02_anim;
	level.scr_anim[ "fxanim_props" ][ "wires_03" ] = %fxanim_mp_turbine_wires_03_anim;
	level.scr_anim[ "fxanim_props" ][ "bridge_cables" ] = %fxanim_mp_turbine_bridge_cables_anim;
}
