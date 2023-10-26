// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\_fxanim_dlc4;
#include clientscripts\mp\createfx\mp_dig_fx;
#include clientscripts\mp\_fx;

precache_scripted_fx()
{

}

precache_createfx_fx()
{
    level._effect["fx_lf_mp_dig_sun1"] = loadfx( "lens_flares/fx_lf_mp_dig_sun1" );
    level._effect["fx_mp_dig_floor_swirl_sm"] = loadfx( "maps/mp_maps/fx_mp_dig_floor_swirl_sm" );
    level._effect["fx_mp_dig_floor_swirl_lg"] = loadfx( "maps/mp_maps/fx_mp_dig_floor_swirl_lg" );
    level._effect["fx_mp_dig_dust"] = loadfx( "maps/mp_maps/fx_mp_dig_dust" );
    level._effect["fx_mp_dig_dust_fall"] = loadfx( "maps/mp_maps/fx_mp_dig_dust_fall" );
    level._effect["fx_mp_dig_dust_fall_2"] = loadfx( "maps/mp_maps/fx_mp_dig_dust_fall_2" );
    level._effect["fx_mp_dig_dust_fall_3"] = loadfx( "maps/mp_maps/fx_mp_dig_dust_fall_3" );
    level._effect["fx_mp_dig_dust_floor"] = loadfx( "maps/mp_maps/fx_mp_dig_dust_floor" );
    level._effect["fx_mp_dig_dust_floor_fall"] = loadfx( "maps/mp_maps/fx_mp_dig_dust_floor_fall" );
    level._effect["fx_mp_dig_dust_fall_pill"] = loadfx( "maps/mp_maps/fx_mp_dig_dust_fall_pill" );
    level._effect["fx_mp_dig_vista_dust"] = loadfx( "maps/mp_maps/fx_mp_dig_vista_dust" );
    level._effect["fx_mp_dig_vista_dust_sm"] = loadfx( "maps/mp_maps/fx_mp_dig_vista_dust_sm" );
    level._effect["fx_mp_dig_vista_dust_close"] = loadfx( "maps/mp_maps/fx_mp_dig_vista_dust_close" );
    level._effect["fx_mp_dig_heat_distort"] = loadfx( "maps/mp_maps/fx_mp_dig_heat_distort" );
    level._effect["fx_mp_dig_dust_lg"] = loadfx( "maps/mp_maps/fx_mp_dig_dust_lg" );
    level._effect["fx_mp_dig_vista_birds"] = loadfx( "maps/mp_maps/fx_mp_dig_vista_birds" );
    level._effect["fx_mp_dig_godray"] = loadfx( "maps/mp_maps/fx_mp_dig_godray" );
    level._effect["fx_mp_dig_godray_wide"] = loadfx( "maps/mp_maps/fx_mp_dig_godray_wide" );
    level._effect["fx_mp_dig_flood_light"] = loadfx( "maps/mp_maps/fx_mp_dig_flood_light" );
    level._effect["fx_mp_dig_dust_mote"] = loadfx( "maps/mp_maps/fx_mp_dig_dust_mote" );
    level._effect["fx_mp_dig_gas_drip"] = loadfx( "maps/mp_maps/fx_mp_dig_gas_drip" );
}

#using_animtree("fxanim_props_dlc4");

precache_fxanim_props_dlc4()
{
    level.scr_anim["fxanim_props_dlc4"]["wires_yellow_01"] = %fxanim_mp_dig_wires_yellow_01_anim;
    level.scr_anim["fxanim_props_dlc4"]["wires_yellow_02"] = %fxanim_mp_dig_wires_yellow_02_anim;
    level.scr_anim["fxanim_props_dlc4"]["wires_yellow_03"] = %fxanim_mp_dig_wires_yellow_03_anim;
    level.scr_anim["fxanim_props_dlc4"]["ropes_01"] = %fxanim_mp_dig_ropes_01_anim;
    level.scr_anim["fxanim_props_dlc4"]["fuel_pipe"] = %fxanim_mp_dig_fuel_pipe_anim;
    level.scr_anim["fxanim_props_dlc4"]["wires_yellow_04"] = %fxanim_mp_dig_wires_yellow_04_anim;
    level.scr_anim["fxanim_props_dlc4"]["wires_yellow_05"] = %fxanim_mp_dig_wires_yellow_05_anim;
    level.scr_anim["fxanim_props_dlc4"]["wires_yellow_06"] = %fxanim_mp_dig_wires_yellow_06_anim;
}

fxanim_init( localclientnum )
{
    level thread clientscripts\mp\_fxanim_dlc4::fxanim_init_dlc( localclientnum );
}

#using_animtree("fxanim_props");

precache_fx_anims()
{
    level.scr_anim["fxanim_props"]["roaches"] = %fxanim_gp_roaches_anim;
    level.fx_anim_level_init = ::fxanim_init;
}

main()
{
    clientscripts\mp\createfx\mp_dig_fx::main();
    clientscripts\mp\_fx::reportnumeffects();
    precache_createfx_fx();
    precache_fx_anims();
    precache_fxanim_props_dlc4();
    disablefx = getdvarint( _hash_C9B177D6 );

    if ( !isdefined( disablefx ) || disablefx <= 0 )
        precache_scripted_fx();
}
