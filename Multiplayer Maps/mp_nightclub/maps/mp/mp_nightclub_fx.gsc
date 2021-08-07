#include maps/mp/_utility;

#using_animtree( "fxanim_props" );

precache_util_fx()
{
}

precache_scripted_fx()
{
}

precache_createfx_fx()
{
	level._effect[ "fx_mp_light_dust_motes_md" ] = loadfx( "maps/mp_maps/fx_mp_light_dust_motes_md" );
	level._effect[ "fx_mp_light_laser_blue_fxanim" ] = loadfx( "maps/mp_maps/fx_mp_light_laser_bluee_fxanim" );
	level._effect[ "fx_mp_nightclub_tank_bubbles" ] = loadfx( "maps/mp_maps/fx_mp_nightclub_tank_bubbles" );
	level._effect[ "fx_mp_nightclub_fire" ] = loadfx( "maps/mp_maps/fx_mp_nightclub_fire" );
	level._effect[ "fx_insects_mp_firefly" ] = loadfx( "bio/insects/fx_insects_mp_firefly" );
	level._effect[ "fx_mp_nightclub_laser_roller" ] = loadfx( "maps/mp_maps/fx_mp_nightclub_laser_roller" );
	level._effect[ "fx_mp_nightclub_laser_disco" ] = loadfx( "maps/mp_maps/fx_mp_nightclub_laser_disco" );
	level._effect[ "fx_mp_light_laser_blue_static" ] = loadfx( "maps/mp_maps/fx_mp_light_laser_blue_static" );
	level._effect[ "fx_mp_nightclub_vista_spotlight01" ] = loadfx( "maps/mp_maps/fx_mp_nightclub_vista_spotlight01" );
	level._effect[ "fx_mp_nightclub_vista_spotlight02" ] = loadfx( "maps/mp_maps/fx_mp_nightclub_vista_spotlight02" );
	level._effect[ "fx_mp_nightclub_red_flash" ] = loadfx( "maps/mp_maps/fx_mp_nightclub_red_flash" );
	level._effect[ "fx_nightclub_bar_light" ] = loadfx( "light/fx_nightclub_bar_light" );
	level._effect[ "fx_village_tube_light" ] = loadfx( "light/fx_village_tube_light" );
	level._effect[ "fx_mp_nightclub_cyl_glare" ] = loadfx( "maps/mp_maps/fx_mp_nightclub_cyl_glare" );
	level._effect[ "fx_mp_nightclub_cyl_glare02" ] = loadfx( "maps/mp_maps/fx_mp_nightclub_cyl_glare02" );
	level._effect[ "fx_mp_nightclub_cyl_glare03" ] = loadfx( "maps/mp_maps/fx_mp_nightclub_cyl_glare03" );
	level._effect[ "fx_mp_nightclub_cyl_glare04" ] = loadfx( "maps/mp_maps/fx_mp_nightclub_cyl_glare04" );
	level._effect[ "fx_mp_nightclub_cyl_glare05" ] = loadfx( "maps/mp_maps/fx_mp_nightclub_cyl_glare05" );
	level._effect[ "fx_mp_nightclub_flr_glare" ] = loadfx( "maps/mp_maps/fx_mp_nightclub_flr_glare" );
	level._effect[ "fx_mp_nightclub_flr_glare_cool" ] = loadfx( "maps/mp_maps/fx_mp_nightclub_flr_glare_cool" );
	level._effect[ "fx_mp_nightclub_flr_glare_warm" ] = loadfx( "maps/mp_maps/fx_mp_nightclub_flr_glare_warm" );
	level._effect[ "fx_mp_nightclub_flr_glare_sm" ] = loadfx( "maps/mp_maps/fx_mp_nightclub_flr_glare_sm" );
	level._effect[ "fx_mp_nightclub_flr_glare02" ] = loadfx( "maps/mp_maps/fx_mp_nightclub_flr_glare02" );
	level._effect[ "fx_mp_nightclub_sph_glare01" ] = loadfx( "maps/mp_maps/fx_mp_nightclub_sph_glare01" );
	level._effect[ "fx_mp_nightclub_flood_light" ] = loadfx( "maps/mp_maps/fx_mp_nightclub_flood_light" );
	level._effect[ "fx_mp_nightclub_fireworks_runner" ] = loadfx( "maps/mp_maps/fx_mp_nightclub_fireworks_runner" );
	level._effect[ "fx_mp_nightclub_fireworks_runner_02" ] = loadfx( "maps/mp_maps/fx_mp_nightclub_fireworks_runner_02" );
	level._effect[ "fx_mp_nightclub_mist" ] = loadfx( "maps/mp_maps/fx_mp_nightclub_mist" );
	level._effect[ "fx_mp_nightclub_mist_sm" ] = loadfx( "maps/mp_maps/fx_mp_nightclub_mist_sm" );
	level._effect[ "fx_mp_nightclub_vista_fog" ] = loadfx( "maps/mp_maps/fx_mp_nightclub_vista_fog" );
	level._effect[ "fx_mp_nightclub_area_fog" ] = loadfx( "maps/mp_maps/fx_mp_nightclub_area_fog" );
	level._effect[ "fx_mp_nightclub_club_ring_smk" ] = loadfx( "maps/mp_maps/fx_mp_nightclub_club_ring_smk" );
	level._effect[ "fx_lf_mp_nightclub_sun1" ] = loadfx( "lens_flares/fx_lf_mp_nightclub_sun1" );
	level._effect[ "fx_lf_mp_nightclub_moon" ] = loadfx( "lens_flares/fx_lf_mp_nightclub_moon" );
	level._effect[ "fx_mp_nightclub_spotlight" ] = loadfx( "maps/mp_maps/fx_mp_nightclub_spotlight" );
	level._effect[ "fx_mp_light_laser_blue_fxanim" ] = loadfx( "maps/mp_maps/fx_mp_light_laser_blue_fxanim" );
}

main()
{
	precache_fxanim_props();
	precache_util_fx();
	precache_createfx_fx();
	precache_scripted_fx();
	maps/mp/createfx/mp_nightclub_fx::main();
	maps/mp/createart/mp_nightclub_art::main();
}

precache_fxanim_props()
{
	level.scr_anim[ "fxanim_props" ][ "shopping_lights_short" ] = %fxanim_gp_shopping_lights_short_anim;
	level.scr_anim[ "fxanim_props" ][ "shopping_lights_long" ] = %fxanim_gp_shopping_lights_long_anim;
	level.scr_anim[ "fxanim_props" ][ "skylight" ] = %fxanim_gp_skylight_anim;
	level.scr_anim[ "fxanim_props" ][ "seagull_circle_01" ] = %fxanim_gp_seagull_circle_01_anim;
	level.scr_anim[ "fxanim_props" ][ "seagull_circle_02" ] = %fxanim_gp_seagull_circle_02_anim;
	level.scr_anim[ "fxanim_props" ][ "seagull_circle_03" ] = %fxanim_gp_seagull_circle_03_anim;
	level.scr_anim[ "fxanim_props" ][ "roofvent" ] = %fxanim_gp_roofvent_anim;
	level.scr_anim[ "fxanim_props" ][ "solar_system" ] = %fxanim_karma_solar_system_anim;
}
