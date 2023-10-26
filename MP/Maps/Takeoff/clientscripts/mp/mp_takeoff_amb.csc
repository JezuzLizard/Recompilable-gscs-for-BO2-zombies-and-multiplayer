// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\_ambientpackage;
#include clientscripts\mp\_audio;

main()
{
    declareambientroom( "outdoor", 1 );
    setambientroomtone( "outdoor", "amb_wind_middle", 0.3, 0.3 );
    setambientroomreverb( "outdoor", "takeoff_outdoor", 1, 1 );
    setambientroomcontext( "outdoor", "ringoff_plr", "outdoor" );
    declareambientroom( "control" );
    setambientroomreverb( "control", "takeoff_control", 1, 1 );
    setambientroomcontext( "control", "ringoff_plr", "indoor" );
    declareambientroom( "snack_shack" );
    setambientroomreverb( "snack_shack", "takeoff_snack", 1, 1 );
    setambientroomcontext( "snack_shack", "ringoff_plr", "indoor" );
    declareambientroom( "stairs" );
    setambientroomreverb( "stairs", "takeoff_stairs", 1, 1 );
    setambientroomcontext( "stairs", "ringoff_plr", "indoor" );
    declareambientroom( "odd_room" );
    setambientroomtone( "odd_room", "amb_odd_room_tone", 0.2, 0.4 );
    setambientroomreverb( "odd_room", "takeoff_odd", 1, 1 );
    setambientroomcontext( "odd_room", "ringoff_plr", "indoor" );
    declareambientroom( "odd_upstairs" );
    setambientroomtone( "odd_upstairs", "amb_odd_room_tone", 0.2, 0.4 );
    setambientroomreverb( "odd_upstairs", "takeoff_odd_up", 1, 1 );
    setambientroomcontext( "odd_upstairs", "ringoff_plr", "indoor" );
    declareambientroom( "tall_room" );
    setambientroomtone( "tall_room", "amb_odd_room_tone", 0.3, 0.4 );
    setambientroomreverb( "tall_room", "takeoff_tall", 1, 1 );
    setambientroomcontext( "tall_room", "ringoff_plr", "indoor" );
    declareambientroom( "tunnel_stone" );
    setambientroomreverb( "tunnel_stone", "takeoff_tunnel", 1, 1 );
    setambientroomcontext( "tunnel_stone", "ringoff_plr", "indoor" );
    declareambientroom( "lobby_side" );
    setambientroomtone( "lobby_side", "amb_space_music", 0.3, 0.4 );
    setambientroomreverb( "lobby_side", "takeoff_lobby_side", 1, 1 );
    setambientroomcontext( "lobby_side", "ringoff_plr", "indoor" );
    declareambientroom( "lobby_center" );
    setambientroomtone( "lobby_center", "amb_space_music", 0.3, 0.4 );
    setambientroomreverb( "lobby_center", "takeoff_lobby_center", 1, 1 );
    setambientroomcontext( "lobby_center", "ringoff_plr", "indoor" );
    declareambientroom( "medical" );
    setambientroomreverb( "medical", "takeoff_medical", 1, 1 );
    setambientroomcontext( "medical", "ringoff_plr", "indoor" );
    declareambientroom( "atrium" );
    setambientroomreverb( "atrium", "takeoff_atrium", 1, 1 );
    setambientroomcontext( "atrium", "ringoff_plr", "indoor" );
    thread snd_start_autofx_audio();
}

snd_play_loopers()
{
    clientscripts\mp\_audio::playloopat( "amb_flag", ( -68, 3130, 182 ) );
    clientscripts\mp\_audio::playloopat( "amb_small_waterfall", ( 529, 1798, 90 ) );
}

snd_start_autofx_audio()
{
    snd_play_auto_fx( "fx_mp_vent_steam_line_sm", "amb_steam", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_tak_light_flour_sqr_lg", "amb_light_lrg", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_tak_light_tv_glow_blue_flckr", "amb_light_lrg", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_mp_vent_heat_distort", "amb_heat_distort", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_tak_light_tv_glow_blue_flckr", "amb_tv", 0, 0, 0, 0 );
}
