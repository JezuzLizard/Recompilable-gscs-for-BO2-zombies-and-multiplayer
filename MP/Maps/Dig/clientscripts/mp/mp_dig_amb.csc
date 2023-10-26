// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\_ambientpackage;
#include clientscripts\mp\_audio;

main()
{
    declareambientroom( "dig_outdoor", 1 );
    setambientroomreverb( "dig_outdoor", "gen_outdoor", 1, 1 );
    setambientroomcontext( "dig_outdoor", "ringoff_plr", "outdoor" );
    declareambientroom( "enclosed_room" );
    setambientroomreverb( "enclosed_room", "dig_stoneroom", 1, 1 );
    setambientroomcontext( "enclosed_room", "ringoff_plr", "indoor" );
    declareambientroom( "tarp_room" );
    setambientroomreverb( "tarp_room", "dig_mediumroom", 1, 1 );
    setambientroomcontext( "tarp_room", "ringoff_plr", "indoor" );
    declareambientroom( "open_air_room" );
    setambientroomreverb( "open_air_room", "dig_partialroom", 1, 1 );
    setambientroomcontext( "open_air_room", "ringoff_plr", "outdoor" );
    declareambientroom( "center_open_air_room" );
    setambientroomreverb( "center_open_air_room", "dig_smallroom", 1, 1 );
    setambientroomcontext( "center_open_air_room", "ringoff_plr", "outdoor" );
    declareambientroom( "tunnel_hall" );
    setambientroomtone( "tunnel_hall", "amb_tunnel_tone_2d", 0.55, 1 );
    setambientroomreverb( "tunnel_hall", "dig_hallroom", 1, 1 );
    setambientroomcontext( "tunnel_hall", "ringoff_plr", "indoor" );
    declareambientroom( "tunnel_room" );
    setambientroomtone( "tunnel_room", "amb_tunnel_tone_2d", 0.55, 1 );
    setambientroomreverb( "tunnel_room", "dig_hallroom", 1, 1 );
    setambientroomcontext( "tunnel_room", "ringoff_plr", "indoor" );
    thread snd_start_autofx_audio();
    thread snd_play_loopers();
}

snd_start_autofx_audio()
{
    snd_play_auto_fx( "fx_mp_dig_flood_light", "amb_light", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_mp_dig_gas_drip", "amb_drips", 0, 0, 0, 0 );
}

snd_play_loopers()
{
    playloopat( "amb_wind_middle", ( -414, -129, 484 ) );
    playloopat( "amb_gas_pumper", ( -1009, -168, 125 ) );
    playloopat( "amb_pipe_flow", ( -1396, 611, 188 ) );
    playloopat( "amb_pipe_flow_blend", ( -1431, 694, 209 ) );
    playloopat( "amb_pipe_flow_blend", ( -1313, 464, 170 ) );
    playloopat( "amb_pipe_flow_2", ( -1073, 141, 154 ) );
    playloopat( "amb_pipe_flow_2", ( -1144, 277, 152 ) );
    playloopat( "amb_pipe_flow_2", ( -989, -38, 55 ) );
    playloopat( "amb_generator", ( -657, 166, 32 ) );
    playloopat( "amb_generator", ( -622, -490, 39 ) );
    playloopat( "amb_generator", ( 418, 574, 202 ) );
    playloopat( "amb_generator", ( 326, -841, 205 ) );
    playloopat( "amb_generator", ( -538, -248, 112 ) );
    playloopat( "amb_generator", ( -1674, 1694, 68 ) );
    playloopat( "amb_generator", ( -1562, 1153, 122 ) );
    playloopat( "amb_generator", ( -1649, -756, 145 ) );
    playloopat( "amb_generator", ( -191, 1531, 131 ) );
    playloopat( "amb_generator", ( 80, 187, 80 ) );
    playloopat( "amb_generator", ( -514, -1586, 108 ) );
}
