// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include maps\mp\gametypes_zm\_hud_util;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_game_module_utility;
#include maps\mp\zombies\_zm_game_module;

register_game_module()
{
    level.game_module_grief_index = 9;
    maps\mp\zombies\_zm_game_module::register_game_module( level.game_module_grief_index, "zgrief", ::onpreinitgametype, ::onpostinitgametype, undefined, ::onspawnzombie, ::onstartgametype );
}
