// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\_ambientpackage;
#include clientscripts\mp\_audio;

main()
{
    declareambientroom( "outside", 1 );
    setambientroomtone( "outside", "amb_rain_blend_track", 0.5, 0.5 );
    setambientroomreverb( "outside", "uplink_outside", 1, 1 );
    setambientroomcontext( "outside", "ringoff_plr", "outdoor" );
    declareambientroom( "inside" );
    setambientroomtone( "inside", "amb_silent", 0.3, 0.3 );
    setambientroomreverb( "inside", "uplink_inside", 1, 1 );
    setambientroomcontext( "inside", "ringoff_plr", "indoor" );
    declareambientroom( "utility_room" );
    setambientroomtone( "utility_room", "amb_silent", 0.3, 0.3 );
    setambientroomreverb( "utility_room", "uplink_utility_room", 1, 1 );
    setambientroomcontext( "utility_room", "ringoff_plr", "indoor" );
    declareambientroom( "floor_2" );
    setambientroomtone( "floor_2", "amb_silent", 0.3, 0.3 );
    setambientroomreverb( "floor_2", "uplink_floor_2", 1, 1 );
    setambientroomcontext( "floor_2", "ringoff_plr", "indoor" );
    declareambientroom( "small_room" );
    setambientroomtone( "small_room", "amb_silent", 0.3, 0.3 );
    setambientroomreverb( "small_room", "uplink_small_room", 1, 1 );
    setambientroomcontext( "small_room", "ringoff_plr", "indoor" );
    declareambientroom( "open_room" );
    setambientroomtone( "open_room", "amb_silent", 0.3, 0.3 );
    setambientroomreverb( "open_room", "uplink_open_room", 1, 1 );
    setambientroomcontext( "open_room", "ringoff_plr", "indoor" );
    declareambientroom( "partial" );
    setambientroomtone( "partial", "amb_silent", 0.3, 0.3 );
    setambientroomreverb( "partial", "uplink_partial_room", 1, 1 );
    setambientroomcontext( "partial", "ringoff_plr", "indoor" );
    declareambientroom( "container" );
    setambientroomtone( "container", "amb_silent", 0.3, 0.3 );
    setambientroomreverb( "container", "uplink_container", 1, 1 );
    setambientroomcontext( "container", "ringoff_plr", "indoor" );
    declareambientroom( "rain_hit_player" );
    setambientroomtone( "rain_hit_player", "amb_rain_on_player", 0.2, 0.2 );
    setambientroomreverb( "rain_hit_player", "uplink_outside", 1, 1 );
    setambientroomcontext( "rain_hit_player", "ringoff_plr", "outdoor" );
    declareambientroom( "rain_hit_player_1" );
    setambientroomtone( "rain_hit_player_1", "amb_rain_on_player", 0.2, 0.2 );
    setambientroomreverb( "rain_hit_player_1", "uplink_outside", 1, 1 );
    setambientroomcontext( "rain_hit_player_1", "ringoff_plr", "outdoor" );
    thread snd_start_autofx_audio();
    thread snd_play_loopers();
    thread snd_dyn_wind();
}

vox_comp_radio()
{
    while ( true )
    {
        wait( randomintrange( 12, 30 ) );
        playsound( 0, "vox_comp_radio", ( 2635, 1596, 406 ) );
    }
}

vox_comp_radio_mainframe()
{
    while ( true )
    {
        wait( randomintrange( 12, 30 ) );
        playsound( 0, "vox_comp_radio", ( 2734, -842, 379 ) );
    }
}

snd_random( min, max, position, alias )
{
    while ( true )
    {
        wait( randomintrange( min, max ) );
        playsound( 0, alias, position );
    }
}

snd_start_autofx_audio()
{
    snd_play_auto_fx( "fx_mp_distortion_wall_heater", "amb_space_heater", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_water_drip_light_short", "amb_water_drip", 0, 0, 0, 1 );
    snd_play_auto_fx( "fx_mp_water_roof_spill_lg_hvy", "amb_rain_roof_spill", 0, 0, 0, 1 );
    snd_play_auto_fx( "fx_water_pipe_gutter_md", "amb_waterpipe_flow", 0, 0, 0, 1 );
    snd_play_auto_fx( "fx_drone_rectangle_light", "amb_rectangle_lights", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_light_flour_glow_yellow_sm", "amb_rectangle_lights", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_light_recessed_blue", "amb_rectangle_lights", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_light_floodlight_sqr_cool", "amb_square_lights", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_light_recessed_cool", "amb_small_lights", 0, 0, 0, 0 );
}

snd_play_loopers()
{
    playloopat( "amb_spawn_rain", ( 1419, 1092, 242 ) );
    playloopat( "amb_large_lights", ( 3540, -3518, 452 ) );
    playloopat( "amb_weather_vane_1", ( 4054, -1348, 567 ) );
    playloopat( "amb_weather_vane_2", ( 4049, -1160, 561 ) );
    playloopat( "amb_weather_vane_2", ( 3767, 1499, 632 ) );
    playloopat( "amb_window_rain", ( 2289, -1027, 607 ) );
    playloopat( "amb_window_rain", ( 2306, -1227, 598 ) );
    playloopat( "amb_rain_metal_tank", ( 1929, -359, 457 ) );
    playloopat( "amb_rain_metal_tank", ( 1781, -324, 325 ) );
}

snd_dyn_wind()
{
    snd_add_exploder_alias( 1001, "amb_dynwind" );
    snd_add_exploder_alias( 1002, "amb_dynwind" );
}

snd_add_exploder_alias( num, alias )
{
    for ( i = 0; i < level.createfxent.size; i++ )
    {
        if ( isdefined( level.createfxent[i].v["exploder"] ) )
        {
            if ( level.createfxent[i].v["exploder"] == num )
                level.createfxent[i].v["soundalias"] = alias;
        }
    }
}
