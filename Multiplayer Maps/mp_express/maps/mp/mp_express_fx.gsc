#include maps/mp/_utility;

#using_animtree( "fxanim_props" );

main()
{
	precache_fxanim_props();
	precache_scripted_fx();
	precache_createfx_fx();
	maps/mp/createfx/mp_express_fx::main();
	maps/mp/createart/mp_express_art::main();
}

precache_scripted_fx()
{
	level._effect[ "fx_mp_debris_papers" ] = loadfx( "maps/mp_maps/fx_mp_debris_papers" );
	level._effect[ "fx_paper_interior_short" ] = loadfx( "debris/fx_paper_interior_short" );
	level._effect[ "fx_mp_light_dust_motes_md" ] = loadfx( "maps/mp_maps/fx_mp_light_dust_motes_md" );
	level._effect[ "fx_mp_fog_low" ] = loadfx( "maps/mp_maps/fx_mp_fog_low" );
	level._effect[ "fx_mp_express_train_blow_dust" ] = loadfx( "maps/mp_maps/fx_mp_express_train_blow_dust" );
	level._effect[ "fx_mp_express_fog_water" ] = loadfx( "maps/mp_maps/fx_mp_express_fog_water" );
	level._effect[ "fx_mp_fumes_vent_xsm_int" ] = loadfx( "maps/mp_maps/fx_mp_fumes_vent_xsm_int" );
	level._effect[ "fx_mp_vent_heat_distort" ] = loadfx( "maps/mp_maps/fx_mp_vent_heat_distort" );
	level._effect[ "fx_insects_swarm_dark_lg" ] = loadfx( "bio/insects/fx_insects_swarm_dark_lg" );
	level._effect[ "fx_mp_debris_papers_narrow" ] = loadfx( "maps/mp_maps/fx_mp_debris_papers_narrow" );
	level._effect[ "fx_insects_swarm_lg_light" ] = loadfx( "bio/insects/fx_insects_swarm_lg_light" );
	level._effect[ "fx_insects_swarm_md_light" ] = loadfx( "bio/insects/fx_insects_swarm_md_light" );
	level._effect[ "fx_mp_express_train_dust_side2" ] = loadfx( "maps/mp_maps/fx_mp_express_train_dust_side2" );
	level._effect[ "fx_mp_express_train_dust" ] = loadfx( "maps/mp_maps/fx_mp_express_train_dust" );
	level._effect[ "fx_mp_express_train_dust_side" ] = loadfx( "maps/mp_maps/fx_mp_express_train_dust_side" );
	level._effect[ "fx_lf_mp_express_sun1" ] = loadfx( "lens_flares/fx_lf_mp_express_sun1" );
	level._effect[ "fx_light_god_ray_mp_express" ] = loadfx( "env/light/fx_light_god_ray_mp_express" );
	level._effect[ "fx_light_god_ray_mp_express2" ] = loadfx( "env/light/fx_light_god_ray_mp_express2" );
	level._effect[ "fx_window_god_ray" ] = loadfx( "light/fx_window_god_ray" );
	level._effect[ "fx_express_ceiling_light_big" ] = loadfx( "light/fx_express_ceiling_light_big" );
	level._effect[ "fx_express_ceiling_light_small" ] = loadfx( "light/fx_express_ceiling_light_small" );
	level._effect[ "fx_window_god_ray_sm" ] = loadfx( "light/fx_window_god_ray_sm" );
	level._effect[ "fx_express_train_side_light" ] = loadfx( "light/fx_express_train_side_light" );
	level._effect[ "fx_express_hall_light_one" ] = loadfx( "light/fx_express_hall_light_one" );
	level._effect[ "fx_express_hall_light_5" ] = loadfx( "light/fx_express_hall_light_5" );
	level._effect[ "fx_light_god_ray_mp_slums" ] = loadfx( "env/light/fx_light_god_ray_mp_slums" );
	level._effect[ "fx_express_ceiling_light_xsm" ] = loadfx( "light/fx_express_ceiling_light_xsm" );
	level._effect[ "fx_mp_light_police_car" ] = loadfx( "maps/mp_maps/fx_mp_light_police_car" );
	level._effect[ "fx_drone_rectangle_light_03" ] = loadfx( "light/fx_drone_rectangle_light_03" );
	level._effect[ "fx_express_flood_light" ] = loadfx( "light/fx_express_flood_light" );
	level._effect[ "fx_express_flood_light_beam" ] = loadfx( "light/fx_express_flood_light_beam" );
	level._effect[ "fx_mp_express_vista_smoke01" ] = loadfx( "maps/mp_maps/fx_mp_express_vista_smoke01" );
	level._effect[ "fx_mp_express_vista_fire01" ] = loadfx( "maps/mp_maps/fx_mp_express_vista_fire01" );
}

precache_createfx_fx()
{
}

precache_fxanim_props()
{
	level.scr_anim[ "fxanim_props" ][ "banner_side_thin" ] = %fxanim_mp_express_banner_side_thin_anim;
}
