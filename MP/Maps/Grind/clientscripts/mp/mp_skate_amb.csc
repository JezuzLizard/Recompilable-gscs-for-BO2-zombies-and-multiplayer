// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\_ambientpackage;
#include clientscripts\mp\_audio;

main()
{
    declareambientroom( "skate_outdoor", 1 );
    setambientroomtone( "skate_outdoor", "amb_wind_exterior_2d", 0.7, 1 );
    setambientroomreverb( "skate_outdoor", "skate_outdoor", 1, 1 );
    setambientroomcontext( "skate_outdoor", "ringoff_plr", "outdoor" );
    declareambientroom( "med_stone_room" );
    setambientroomtone( "med_stone_room", "amb_wind_interior_2d", 0.7, 1 );
    setambientroomreverb( "med_stone_room", "skate_stoneroom", 1, 1 );
    setambientroomcontext( "med_stone_room", "ringoff_plr", "indoor" );
    declareambientroom( "indoor_skate_room" );
    setambientroomtone( "indoor_skate_room", "amb_wind_interior_2d", 0.7, 1 );
    setambientroomreverb( "indoor_skate_room", "skate_mediumroom", 1, 1 );
    setambientroomcontext( "indoor_skate_room", "ringoff_plr", "indoor" );
    declareambientroom( "indoor_store_room" );
    setambientroomtone( "indoor_store_room", "amb_wind_interior_2d", 0.7, 1 );
    setambientroomreverb( "indoor_store_room", "skate_smallroom", 1, 1 );
    setambientroomcontext( "indoor_store_room", "ringoff_plr", "indoor" );
    declareambientroom( "locker_room" );
    setambientroomtone( "locker_room", "amb_wind_interior_2d", 0.7, 1 );
    setambientroomreverb( "locker_room", "skate_locker", 1, 1 );
    setambientroomcontext( "locker_room", "ringoff_plr", "indoor" );
    declareambientroom( "mtl_corridor_room" );
    setambientroomtone( "mtl_corridor_room", "amb_wind_interior_2d", 0.7, 1 );
    setambientroomreverb( "mtl_corridor_room", "skate_corridor", 1, 1 );
    setambientroomcontext( "mtl_corridor_room", "ringoff_plr", "indoor" );
    declareambientroom( "partial_stone_room" );
    setambientroomtone( "partial_stone_room", "amb_wind_exterior_2d_qt", 0.7, 1 );
    setambientroomreverb( "partial_stone_room", "skate_stoneroom", 1, 1 );
    setambientroomcontext( "partial_stone_room", "ringoff_plr", "outdoor" );
    declareambientroom( "full_pipe_room" );
    setambientroomtone( "full_pipe_room", "amb_wind_interior_2d", 0.7, 1 );
    setambientroomreverb( "full_pipe_room", "skate_pipe", 1, 1 );
    setambientroomcontext( "full_pipe_room", "ringoff_plr", "outdoor" );
    declareambientroom( "underground_room" );
    setambientroomtone( "underground_room", "amb_wind_interior_2d", 0.7, 1 );
    setambientroomreverb( "underground_room", "skate_stoneroom_sml", 1, 1 );
    setambientroomcontext( "underground_room", "ringoff_plr", "indoor" );
    declareambientroom( "open_halfpipe_room" );
    setambientroomtone( "open_halfpipe_room", "amb_wind_exterior_2d_qt", 0.7, 1 );
    setambientroomreverb( "open_halfpipe_room", "skate_pipe", 1, 1 );
    setambientroomcontext( "open_halfpipe_room", "ringoff_plr", "outdoor" );
    declareambientroom( "restroom_room" );
    setambientroomtone( "restroom_room", "amb_wind_interior_2d", 0.7, 1 );
    setambientroomreverb( "restroom_room", "skate_tile_room", 1, 1 );
    setambientroomcontext( "restroom_room", "ringoff_plr", "indoor" );
    declareambientroom( "covered_platform_room" );
    setambientroomtone( "covered_platform_room", "amb_wind_interior_2d", 0.7, 1 );
    setambientroomreverb( "covered_platform_room", "skate_platform", 1, 1 );
    setambientroomcontext( "covered_platform_room", "ringoff_plr", "outdoor" );
    thread snd_start_autofx_audio();
    thread snd_play_loopers();
}

snd_play_loopers()
{

}

snd_start_autofx_audio()
{

}
