// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\_ambientpackage;
#include clientscripts\mp\_audio;

main()
{
    declareambientroom( "default_outdoor", 1 );
    setambientroomtone( "default_outdoor", "amb_wind_extreior_2d", 0.2, 0.5 );
    setambientroomreverb( "default_outdoor", "express_outdoor", 1, 1 );
    setambientroomcontext( "default_outdoor", "ringoff_plr", "outdoor" );
    declareambientroom( "subway_room" );
    setambientroomreverb( "subway_room", "express_smallroom", 1, 1 );
    setambientroomcontext( "subway_room", "ringoff_plr", "indoor" );
    declareambientroom( "subway_room_partial" );
    setambientroomreverb( "subway_room_partial", "express_smallroom", 1, 1 );
    setambientroomcontext( "subway_room_partial", "ringoff_plr", "outdoor" );
    declareambientroom( "tunnel_ramp_room" );
    setambientroomreverb( "tunnel_ramp_room", "express_sewerpipe", 1, 1 );
    setambientroomcontext( "tunnel_ramp_room", "ringoff_plr", "indoor" );
    declareambientroom( "tunnel_bridge_room" );
    setambientroomreverb( "tunnel_bridge_room", "express_sewerpipe", 1, 1 );
    setambientroomcontext( "tunnel_bridge_room", "ringoff_plr", "indoor" );
    declareambientroom( "tunnel_bridge_room_partial" );
    setambientroomreverb( "tunnel_bridge_room_partial", "express_sewerpipe", 1, 1 );
    setambientroomcontext( "tunnel_bridge_room_partial", "ringoff_plr", "outdoor" );
    declareambientroom( "tunnel_wide_room" );
    setambientroomreverb( "tunnel_wide_room", "express_stoneroom", 1, 1 );
    setambientroomcontext( "tunnel_wide_room", "ringoff_plr", "indoor" );
    declareambientroom( "ticket_window_room" );
    setambientroomreverb( "ticket_window_room", "express_smallroom", 1, 1 );
    setambientroomcontext( "ticket_window_room", "ringoff_plr", "indoor" );
    declareambientroom( "ticket_main_room" );
    setambientroomreverb( "ticket_main_room", "express_mediumroom", 1, 1 );
    setambientroomcontext( "ticket_main_room", "ringoff_plr", "indoor" );
    declareambientroom( "stairwell" );
    setambientroomreverb( "stairwell", "express_stoneroom", 1, 1 );
    setambientroomcontext( "stairwell", "ringoff_plr", "indoor" );
    declareambientroom( "stairwell_open" );
    setambientroomreverb( "stairwell_open", "express_smallroom", 1, 1 );
    setambientroomcontext( "stairwell_open", "ringoff_plr", "indoor" );
    declareambientroom( "marble_room" );
    setambientroomreverb( "marble_room", "express_stoneroom", 1, 1 );
    setambientroomcontext( "marble_room", "ringoff_plr", "indoor" );
    declareambientroom( "marble_room_partial" );
    setambientroomreverb( "marble_room_partial", "express_stoneroom", 1, 1 );
    setambientroomcontext( "marble_room_partial", "ringoff_plr", "outdoor" );
    declareambientroom( "walkway_open" );
    setambientroomreverb( "walkway_open", "express_outdoor", 1, 1 );
    setambientroomcontext( "walkway_open", "ringoff_plr", "outdoor" );
    declareambientroom( "walkway_closed" );
    setambientroomreverb( "walkway_closed", "express_stoneroom", 1, 1 );
    setambientroomcontext( "walkway_closed", "ringoff_plr", "indoor" );
    declareambientroom( "main_lobby" );
    setambientroomreverb( "main_lobby", "express_largeroom", 1, 1 );
    setambientroomcontext( "main_lobby", "ringoff_plr", "indoor" );
    thread snd_start_autofx_audio();
}

snd_play_loopers()
{

}

snd_start_autofx_audio()
{
    snd_play_auto_fx( "fx_express_ceiling_light_big", "amb_halllight_lrg", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_express_hall_light_5", "amb_halllight_sml", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_express_hall_light_one", "amb_halllight_sml", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_mp_vent_heat_distort", "amb_exhaust", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_insects_swarm_lg_light", "amb_flies", 0, 0, 0, 0 );
}
