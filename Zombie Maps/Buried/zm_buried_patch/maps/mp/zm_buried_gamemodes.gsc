// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_game_module;
#include maps\mp\gametypes_zm\_zm_gametype;
#include maps\mp\zombies\_zm_buildables;
#include maps\mp\zm_buried;
#include maps\mp\zm_buried_classic;
#include maps\mp\zm_buried_turned_street;
#include maps\mp\zm_buried_grief_street;
#include maps\mp\zombies\_zm_zonemgr;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\zombies\_zm_unitrigger;

init()
{
    add_map_gamemode( "zclassic", maps\mp\zm_buried::zclassic_preinit, undefined, undefined );
    add_map_gamemode( "zcleansed", maps\mp\zm_buried::zcleansed_preinit, undefined, undefined );
    add_map_gamemode( "zgrief", maps\mp\zm_buried::zgrief_preinit, undefined, undefined );
    add_map_location_gamemode( "zclassic", "processing", maps\mp\zm_buried_classic::precache, maps\mp\zm_buried_classic::main );
    add_map_location_gamemode( "zcleansed", "street", maps\mp\zm_buried_turned_street::precache, maps\mp\zm_buried_turned_street::main );
    add_map_location_gamemode( "zgrief", "street", maps\mp\zm_buried_grief_street::precache, maps\mp\zm_buried_grief_street::main );
}

deletechalktriggers()
{
    chalk_triggers = getentarray( "chalk_buildable_trigger", "targetname" );
    array_thread( chalk_triggers, ::self_delete );
}

deletebuyabledoors()
{
    doors_trigs = getentarray( "zombie_door", "targetname" );

    foreach ( door in doors_trigs )
    {
        doors = getentarray( door.target, "targetname" );
        array_thread( doors, ::self_delete );
    }

    array_thread( doors_trigs, ::self_delete );
}

deletebuyabledebris( justtriggers )
{
    debris_trigs = getentarray( "zombie_debris", "targetname" );

    if ( !is_true( justtriggers ) )
    {
        foreach ( trig in debris_trigs )
        {
            if ( isdefined( trig.script_flag ) )
                flag_set( trig.script_flag );

            parts = getentarray( trig.target, "targetname" );
            array_thread( parts, ::self_delete );
        }
    }

    array_thread( debris_trigs, ::self_delete );
}

deleteslothbarricades( justtriggers )
{
    sloth_trigs = getentarray( "sloth_barricade", "targetname" );

    if ( !is_true( justtriggers ) )
    {
        foreach ( trig in sloth_trigs )
        {
            if ( isdefined( trig.script_flag ) && level flag_exists( trig.script_flag ) )
                flag_set( trig.script_flag );

            parts = getentarray( trig.target, "targetname" );
            array_thread( parts, ::self_delete );
        }
    }

    array_thread( sloth_trigs, ::self_delete );
}

deleteslothbarricade( location )
{
    sloth_trigs = getentarray( "sloth_barricade", "targetname" );

    foreach ( trig in sloth_trigs )
    {
        if ( isdefined( trig.script_location ) && trig.script_location == location )
        {
            if ( isdefined( trig.script_flag ) )
                flag_set( trig.script_flag );

            parts = getentarray( trig.target, "targetname" );
            array_thread( parts, ::self_delete );
        }
    }
}

spawnmapcollision( collision_model, origin )
{
    if ( !isdefined( origin ) )
        origin = ( 0, 0, 0 );

    collision = spawn( "script_model", origin, 1 );
    collision setmodel( collision_model );
    collision disconnectpaths();
}

turnperkon( perk )
{
    level notify( perk + "_on" );
    wait_network_frame();
}

disableallzonesexcept( zones )
{
    foreach ( zone in zones )
        level thread maps\mp\zombies\_zm_zonemgr::enable_zone( zone );

    foreach ( zoneindex, zone in level.zones )
    {
        should_disable = 1;

        foreach ( cleared_zone in zones )
        {
            if ( zoneindex == cleared_zone )
                should_disable = 0;
        }

        if ( is_true( should_disable ) )
        {
            zone.is_enabled = 0;
            zone.is_spawning_allowed = 0;
        }
    }
}

remove_adjacent_zone( main_zone, adjacent_zone )
{
    if ( isdefined( level.zones[main_zone].adjacent_zones ) && isdefined( level.zones[main_zone].adjacent_zones[adjacent_zone] ) )
        level.zones[main_zone].adjacent_zones[adjacent_zone] = undefined;

    if ( isdefined( level.zones[adjacent_zone].adjacent_zones ) && isdefined( level.zones[adjacent_zone].adjacent_zones[main_zone] ) )
        level.zones[adjacent_zone].adjacent_zones[main_zone] = undefined;
}

builddynamicwallbuy( location, weaponname )
{
    match_string = level.scr_zm_ui_gametype + "_" + level.scr_zm_map_start_location;

    foreach ( stub in level.chalk_builds )
    {
        wallbuy = getstruct( stub.target, "targetname" );

        if ( isdefined( wallbuy.script_location ) && wallbuy.script_location == location )
        {
            if ( !isdefined( wallbuy.script_noteworthy ) || issubstr( wallbuy.script_noteworthy, match_string ) )
            {
                maps\mp\zombies\_zm_weapons::add_dynamic_wallbuy( weaponname, wallbuy.targetname, 1 );
                thread wait_and_remove( stub, stub.buildablezone.pieces[0] );
            }
        }
    }
}

buildbuildable( buildable )
{
    player = get_players()[0];

    foreach ( stub in level.buildable_stubs )
    {
        if ( !isdefined( buildable ) || stub.equipname == buildable )
        {
            if ( isdefined( buildable ) || stub.persistent != 3 )
            {
                stub maps\mp\zombies\_zm_buildables::buildablestub_finish_build( player );
                stub maps\mp\zombies\_zm_buildables::buildablestub_remove();

                foreach ( piece in stub.buildablezone.pieces )
                    piece maps\mp\zombies\_zm_buildables::piece_unspawn();

                stub.model notsolid();
                stub.model show();
                return;
            }
        }
    }
}

wait_and_remove( stub, piece )
{
    wait 0.1;
    self buildablestub_remove();
    thread maps\mp\zombies\_zm_unitrigger::unregister_unitrigger( stub );
    piece piece_unspawn();
}

generatebuildabletarps()
{
    struct_locations = getstructarray( "buildables_tarp", "targetname" );
    level.buildable_tarps = [];

    foreach ( struct in struct_locations )
    {
        tarp = spawn( "script_model", struct.origin );
        tarp.angles = struct.angles;
        tarp setmodel( "p6_zm_bu_buildable_bench_tarp" );
        tarp.targetname = "buildable_tarp";

        if ( isdefined( struct.script_location ) )
            tarp.script_location = struct.script_location;

        level.buildable_tarps[level.buildable_tarps.size] = tarp;
    }
}

deletebuildabletarp( location )
{
    foreach ( tarp in level.buildable_tarps )
    {
        if ( isdefined( tarp.script_location ) && tarp.script_location == location )
            tarp delete();
    }
}

powerswitchstate( on )
{
    trigger = getent( "use_elec_switch", "targetname" );

    if ( isdefined( trigger ) )
        trigger delete();

    master_switch = getent( "elec_switch", "targetname" );

    if ( isdefined( master_switch ) )
    {
        master_switch notsolid();

        if ( is_true( on ) )
        {
            master_switch rotateroll( -90, 0.3 );
            flag_set( "power_on" );
        }
    }
}
