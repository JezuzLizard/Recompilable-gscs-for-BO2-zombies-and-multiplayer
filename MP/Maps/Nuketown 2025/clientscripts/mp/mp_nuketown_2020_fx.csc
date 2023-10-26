// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\createfx\mp_nuketown_2020_fx;
#include clientscripts\mp\_fx;

main()
{
    clientscripts\mp\createfx\mp_nuketown_2020_fx::main();
    clientscripts\mp\_fx::reportnumeffects();
    precache_createfx_fx();
    precache_fxanim_props();
    disablefx = getdvarint( _hash_C9B177D6 );

    if ( !isdefined( disablefx ) || disablefx <= 0 )
        precache_scripted_fx();
}

precache_createfx_fx()
{
    level._effect["fx_water_fire_sprinkler_thin"] = loadfx( "water/fx_water_fire_sprinkler_thin" );
    level._effect["fx_nuke_plant_sprinkler"] = loadfx( "water/fx_nuke_plant_sprinkler" );
    level._effect["fx_nuke_car_wash_sprinkler"] = loadfx( "water/fx_nuke_car_wash_sprinkler" );
    level._effect["fx_window_god_ray_sm"] = loadfx( "light/fx_window_god_ray_sm" );
    level._effect["fx_window_god_ray"] = loadfx( "light/fx_window_god_ray" );
    level._effect["fx_light_recessed_cool_sm_soft"] = loadfx( "light/fx_light_recessed_cool_sm_soft" );
    level._effect["fx_light_recessed_cool_sm_softer"] = loadfx( "light/fx_light_recessed_cool_sm_softer" );
    level._effect["fx_red_button_flash"] = loadfx( "light/fx_red_button_flash" );
    level._effect["fx_mp_water_drip_light_shrt"] = loadfx( "maps/mp_maps/fx_mp_water_drip_light_shrt" );
    level._effect["fx_mp_water_drip_light_long"] = loadfx( "maps/mp_maps/fx_mp_water_drip_light_long" );
    level._effect["fx_mp_nuked_final_dust"] = loadfx( "maps/mp_maps/fx_mp_nuked_final_dust" );
    level._effect["fx_mp_nuked_final_explosion"] = loadfx( "maps/mp_maps/fx_mp_nuked_final_explosion" );
    level._effect["fx_nuke_car_wash_mist"] = loadfx( "smoke/fx_nuke_car_wash_mist" );
    level._effect["fx_nuke_vent_steam"] = loadfx( "smoke/fx_nuke_vent_steam" );
    level._effect["fx_nuke_heat_distort"] = loadfx( "smoke/fx_nuke_heat_distort" );
    level._effect["fx_nuke_stove_heat"] = loadfx( "smoke/fx_nuke_stove_heat" );
    level._effect["fx_lf_mp_nuketown_sun1"] = loadfx( "lens_flares/fx_lf_mp_nuketown_sun1" );
    level._effect["fx_mp_nuke_fireplace"] = loadfx( "maps/mp_maps/fx_mp_nuke_fireplace" );
    level._effect["fx_mp_nuke_butterfly"] = loadfx( "maps/mp_maps/fx_mp_nuke_butterfly" );
    level._effect["fx_insects_swarm_lg_light"] = loadfx( "bio/insects/fx_insects_swarm_lg_light" );
    level._effect["fx_insects_swarm_lg_white"] = loadfx( "bio/insects/fx_insects_swarm_lg_white" );
    level._effect["fx_mp_nuke_ufo_fly"] = loadfx( "maps/mp_maps/fx_mp_nuke_ufo_fly" );
    level._effect["fx_mp_nuke_bubbles_runner"] = loadfx( "maps/mp_maps/fx_mp_nuke_bubbles_runner" );
    level._effect["fx_mp_nuke_sparkles_runner"] = loadfx( "maps/mp_maps/fx_mp_nuke_sparkles_runner" );
    level._effect["fx_mp_nuke_sound_rings"] = loadfx( "maps/mp_maps/fx_mp_nuke_sound_rings" );
    level._effect["fx_mp_nuke_rainbow_sm"] = loadfx( "maps/mp_maps/fx_mp_nuke_rainbow_sm" );
    level._effect["fx_mp_nuke_sandbox"] = loadfx( "maps/mp_maps/fx_mp_nuke_sandbox" );
    level._effect["fx_mp_nuked_display_glass_break"] = loadfx( "maps/mp_maps/fx_mp_nuked_display_glass_break" );
    level._effect["fx_mp_nuke_steam_sm"] = loadfx( "maps/mp_maps/fx_mp_nuke_steam_sm" );
    level._effect["fx_mp_nuke_steam_sm_fast"] = loadfx( "maps/mp_maps/fx_mp_nuke_steam_sm_fast" );
}

precache_scripted_fx()
{

}

#using_animtree("fxanim_props");

precache_fxanim_props()
{
    level.scr_anim["fxanim_props"]["hose"] = %fxanim_mp_nuked2025_hose_anim;
    level.scr_anim["fxanim_props"]["sprinkler"] = %fxanim_mp_nuked2025_sprinkler_anim;
    level.scr_anim["fxanim_props"]["dome"] = %fxanim_mp_nuked2025_dome_anim;
    level.scr_anim["fxanim_props"]["cardestroy1"] = %fxanim_mp_nuked2025_car01_anim;
    level.scr_anim["fxanim_props"]["cardestroy2"] = %fxanim_mp_nuked2025_car02_anim;
    level.scr_anim["fxanim_props"]["displayGlassDestroy"] = %fxanim_mp_nuked2025_display_glass_anim;
    level.scr_anim["fxanim_props"]["gate_sign"] = %fxanim_mp_nuked2025_gate_sign_anim;
    level.scr_anim["fxanim_props"]["carwash_hoses"] = %fxanim_mp_nuked2025_carwash_hoses_anim;
    level.fx_anim_level_init = ::fxanim_init;
}

fxanim_init( localclientnum )
{
    for (;;)
    {
        level waittill( "snap_processed", snapshotlocalclientnum );

        if ( snapshotlocalclientnum == localclientnum )
            break;
    }

    fxanims = getentarray( localclientnum, "fxanim", "targetname" );

    foreach ( ent in fxanims )
    {
        if ( isdefined( ent.model ) && ent.model == "fxanim_mp_nuked2025_sprinkler_mod" )
        {
            ent waittill_dobj( localclientnum );
            ent playloopsound( "amb_track_sprinkler" );
        }
    }
}
