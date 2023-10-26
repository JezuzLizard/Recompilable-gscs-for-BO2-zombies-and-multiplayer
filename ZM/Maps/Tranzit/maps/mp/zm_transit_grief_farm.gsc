// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_magicbox;
#include maps\mp\gametypes_zm\_zm_gametype;
#include maps\mp\zombies\_zm_zonemgr;
#include maps\mp\zombies\_zm_game_module;
#include maps\mp\gametypes_zm\zmeat;

precache()
{

}

farm_treasure_chest_init()
{
    chest1 = getstruct( "farm_chest", "script_noteworthy" );
    level.chests = [];
    level.chests[level.chests.size] = chest1;
    maps\mp\zombies\_zm_magicbox::treasure_chest_init( "farm_chest" );
}

main()
{
    maps\mp\gametypes_zm\_zm_gametype::setup_standard_objects( "farm" );
    init_standard_farm();
    farm_treasure_chest_init();
    level.enemy_location_override_func = ::enemy_location_override;
    flag_wait( "initial_blackscreen_passed" );
    level thread maps\mp\zombies\_zm_zonemgr::enable_zone( "zone_far_ext" );
    level thread maps\mp\zombies\_zm_zonemgr::enable_zone( "zone_brn" );
    maps\mp\zombies\_zm_game_module::turn_power_on_and_open_doors();
    flag_wait( "start_zombie_round_logic" );
    wait 1;
    level notify( "revive_on" );
    wait_network_frame();
    level notify( "doubletap_on" );
    wait_network_frame();
    level notify( "juggernog_on" );
    wait_network_frame();
    level notify( "sleight_on" );
    wait_network_frame();
/#
    level thread maps\mp\gametypes_zm\zmeat::spawn_level_meat_manager();
#/
}

init_standard_farm()
{
    maps\mp\zombies\_zm_game_module::set_current_game_module( level.game_module_standard_index );
    ents = getentarray();

    foreach ( ent in ents )
    {
        if ( isdefined( ent.script_flag ) && ent.script_flag == "OnFarm_enter" )
        {
            ent delete();
            continue;
        }

        if ( isdefined( ent.script_parameters ) )
        {
            tokens = strtok( ent.script_parameters, " " );
            remove = 0;

            foreach ( token in tokens )
            {
                if ( token == "standard_remove" )
                    remove = 1;
            }

            if ( remove )
                ent delete();
        }
    }
}

enemy_location_override( zombie, enemy )
{
    location = enemy.origin;

    if ( is_true( self.reroute ) )
    {
        if ( isdefined( self.reroute_origin ) )
            location = self.reroute_origin;
    }

    return location;
}
