// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\_ambientpackage;
#include clientscripts\mp\_audio;

main()
{
    declareambientroom( "raid_outdoor", 1 );
    setambientroomtone( "raid_outdoor", "amb_wind_extreior_2d", 0.55, 1 );
    setambientroomreverb( "raid_outdoor", "raid_outdoor", 1, 1 );
    setambientroomcontext( "raid_outdoor", "ringoff_plr", "outdoor" );
    declareambientroom( "raid_partial_room" );
    setambientroomreverb( "raid_partial_room", "raid_partial_room", 1, 1 );
    setambientroomcontext( "raid_partial_room", "ringoff_plr", "outdoor" );
    declareambientroom( "raid_basketball_room" );
    setambientroomreverb( "raid_basketball_room", "raid_small_room", 1, 1 );
    setambientroomcontext( "raid_basketball_room", "ringoff_plr", "indoor" );
    declareambientroom( "raid_round_pool_rm" );
    setambientroomreverb( "raid_round_pool_rm", "raid_small_room", 1, 1 );
    setambientroomcontext( "raid_round_pool_rm", "ringoff_plr", "indoor" );
    declareambientroom( "raid_lounge" );
    setambientroomreverb( "raid_lounge", "raid_small_room", 1, 1 );
    setambientroomcontext( "raid_lounge", "ringoff_plr", "outdoor" );
    declareambientroom( "raid_bedroom" );
    setambientroomreverb( "raid_bedroom", "raid_small_room", 1, 1 );
    setambientroomcontext( "raid_bedroom", "ringoff_plr", "indoor" );
    declareambientroom( "raid_bedroom_partial" );
    setambientroomreverb( "raid_bedroom_partial", "raid_small_room", 1, 1 );
    setambientroomcontext( "raid_bedroom_partial", "ringoff_plr", "outdoor" );
    declareambientroom( "raid_garage" );
    setambientroomreverb( "raid_garage", "raid_garage", 1, 1 );
    setambientroomcontext( "raid_garage", "ringoff_plr", "indoor" );
    declareambientroom( "raid_garage_partial" );
    setambientroomreverb( "raid_garage_partial", "raid_garage", 1, 1 );
    setambientroomcontext( "raid_garage_partial", "ringoff_plr", "outdoor" );
    declareambientroom( "raid_arcade_rm" );
    setambientroomreverb( "raid_arcade_rm", "raid_medium_room", 1, 1 );
    setambientroomcontext( "raid_arcade_rm", "ringoff_plr", "indoor" );
    declareambientroom( "raid_driveway_overhang" );
    setambientroomreverb( "raid_driveway_overhang", "raid_garage", 1, 1 );
    setambientroomcontext( "raid_driveway_overhang", "ringoff_plr", "outdoor" );
    declareambientroom( "raid_house_entrance" );
    setambientroomreverb( "raid_house_entrance", "raid_medium_room", 1, 1 );
    setambientroomcontext( "raid_house_entrance", "ringoff_plr", "indoor" );
    declareambientroom( "raid_house_entrance_partial" );
    setambientroomreverb( "raid_house_entrance_partial", "raid_medium_room", 1, 1 );
    setambientroomcontext( "raid_house_entrance_partial", "ringoff_plr", "outdoor" );
    declareambientroom( "raid_house_office" );
    setambientroomreverb( "raid_house_office", "raid_small_room", 1, 1 );
    setambientroomcontext( "raid_house_office", "ringoff_plr", "indoor" );
    declareambientroom( "raid_kitchen" );
    setambientroomreverb( "raid_kitchen", "raid_small_room", 1, 1 );
    setambientroomcontext( "raid_kitchen", "ringoff_plr", "indoor" );
    declareambientroom( "raid_kitchen_partial" );
    setambientroomreverb( "raid_kitchen_partial", "raid_small_room", 1, 1 );
    setambientroomcontext( "raid_kitchen_partial", "ringoff_plr", "outdoor" );
    declareambientroom( "raid_library" );
    setambientroomreverb( "raid_library", "raid_small_room", 1, 1 );
    setambientroomcontext( "raid_library", "ringoff_plr", "indoor" );
    declareambientroom( "raid_library_partial" );
    setambientroomreverb( "raid_library_partial", "raid_small_room", 1, 1 );
    setambientroomcontext( "raid_library_partial", "ringoff_plr", "outdoor" );
    declareambientroom( "raid_laundry_rm" );
    setambientroomreverb( "raid_laundry_rm", "raid_small_room", 1, 1 );
    setambientroomcontext( "raid_laundry_rm", "ringoff_plr", "indoor" );
    declareambientroom( "raid_laundry_rm_partial" );
    setambientroomreverb( "raid_laundry_rm_partial", "raid_small_room", 1, 1 );
    setambientroomcontext( "raid_laundry_rm_partial", "ringoff_plr", "outdoor" );
    thread snd_start_autofraid_audio();
    thread snd_play_loopers();
}

snd_play_loopers()
{
    playloopat( "amb_tv_static", ( 1713, 4185, 63 ) );
    playloopat( "amb_tv_static", ( 1609, 4168, 61 ) );
    playloopat( "amb_umbrella", ( 1268, 4490, 100 ) );
}

snd_start_autofraid_audio()
{
    snd_play_auto_fx( "fx_insects_swarm_lg_light", "amb_flies", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_raid_spot_light", "amb_spot_light", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_raid_hot_tub_sm", "amb_jacuzzi_bubbles", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_mp_fumes_vent_xsm_int", "amb_vent_exhaust", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_mp_slums_fire_lg", "amb_fire", 0, 0, 0, 0 );
}
