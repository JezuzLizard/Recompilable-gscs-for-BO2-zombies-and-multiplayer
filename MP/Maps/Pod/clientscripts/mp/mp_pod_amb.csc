// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\_ambientpackage;
#include clientscripts\mp\_audio;

main()
{
    declareambientroom( "pod_outdoor", 1 );
    setambientroomtone( "pod_outdoor", "amb_wind_exterior_2d", 0.55, 1 );
    setambientroomreverb( "pod_outdoor", "pod_outdoor", 1, 1 );
    setambientroomcontext( "pod_outdoor", "ringoff_plr", "outdoor" );
    declareambientroom( "pod_small_int" );
    setambientroomtone( "pod_small_int", "amb_wind_interior_2d", 0.55, 1 );
    setambientroomreverb( "pod_small_int", "pod_mediumroom", 1, 1 );
    setambientroomcontext( "pod_small_int", "ringoff_plr", "indoor" );
    declareambientroom( "pod_stone_int" );
    setambientroomtone( "pod_stone_int", "amb_wind_interior_2d", 0.55, 1 );
    setambientroomreverb( "pod_stone_int", "pod_stoneroom", 1, 1 );
    setambientroomcontext( "pod_stone_int", "ringoff_plr", "indoor" );
    declareambientroom( "room_small" );
    setambientroomtone( "room_small", "amb_wind_interior_2d", 0.55, 1 );
    setambientroomreverb( "room_small", "pod_smallroom", 1, 1 );
    setambientroomcontext( "room_small", "ringoff_plr", "indoor" );
    declareambientroom( "open_room" );
    setambientroomtone( "open_room", "amb_wind_interior_2d", 0.55, 1 );
    setambientroomreverb( "open_room", "pod_partialroom", 1, 1 );
    setambientroomcontext( "open_room", "ringoff_plr", "indoor" );
    declareambientroom( "corridor_room" );
    setambientroomtone( "corridor_room", "amb_wind_interior_2d", 0.55, 1 );
    setambientroomreverb( "corridor_room", "pod_hallroom", 1, 1 );
    setambientroomcontext( "corridor_room", "ringoff_plr", "indoor" );
    thread snd_start_autofx_audio();
    thread snd_play_loopers();
}

snd_start_autofx_audio()
{
    snd_play_auto_fx( "fx_mp_pod_water_drips", "amb_water_drip_loop", 0, 0, 0, 1 );
    snd_play_auto_fx( "fx_mp_water_drip_light_shrt", "amb_water_drip_loop_small", 0, 0, 0, 1 );
}

snd_play_loopers()
{

}
