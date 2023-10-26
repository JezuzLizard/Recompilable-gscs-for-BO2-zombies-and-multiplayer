// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include maps\mp\gametypes_zm\_hud_util;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_turned;
#include maps\mp\zombies\_zm_game_module;
#include maps\mp\zombies\_zm_game_module_cleansed;

register_game_module()
{
    level.game_module_turned_index = 6;
    maps\mp\zombies\_zm_game_module::register_game_module( level.game_module_turned_index, "zturned", maps\mp\zombies\_zm_game_module_cleansed::onpreinitgametype, ::onpostinitgametype, undefined, maps\mp\zombies\_zm_game_module_cleansed::onspawnzombie, maps\mp\zombies\_zm_game_module_cleansed::onstartgametype );
}

register_turned_match( start_func, end_func, name )
{
    if ( !isdefined( level._registered_turned_matches ) )
        level._registered_turned_matches = [];

    match = spawnstruct();
    match.match_name = name;
    match.match_start_func = start_func;
    match.match_end_func = end_func;
    level._registered_turned_matches[level._registered_turned_matches.size] = match;
}

get_registered_turned_match( name )
{
    foreach ( struct in level._registered_turned_matches )
    {
        if ( struct.match_name == name )
            return struct;
    }
}

set_current_turned_match( name )
{
    level._current_turned_match = name;
}

get_current_turned_match()
{
    return level._current_turned_match;
}

init_zombie_weapon()
{
    maps\mp\zombies\_zm_turned::init();
}

onpostinitgametype()
{
    if ( level.scr_zm_game_module != level.game_module_turned_index )
        return;

    level thread init_zombie_weapon();
}
