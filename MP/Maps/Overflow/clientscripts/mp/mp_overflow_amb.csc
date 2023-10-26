// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\_ambientpackage;
#include clientscripts\mp\_audio;

main()
{
    declareambientroom( "outdoor", 1 );
    setambientroomtone( "outdoor", "amb_wind_extreior_2d", 0.55, 1 );
    setambientroomreverb( "outdoor", "overflow_outdoor", 1, 1 );
    setambientroomcontext( "outdoor", "ringoff_plr", "outdoor" );
    declareambientroom( "small_room" );
    setambientroomreverb( "small_room", "overflow_smallroom", 1, 1 );
    setambientroomcontext( "small_room", "ringoff_plr", "indoor" );
    declareambientroom( "small_room_partial" );
    setambientroomreverb( "small_room_partial", "overflow_smallroom", 1, 1 );
    setambientroomcontext( "small_room_partial", "ringoff_plr", "outdoor" );
    declareambientroom( "construction_bldg" );
    setambientroomreverb( "construction_bldg", "overflow_construction_open", 1, 1 );
    setambientroomcontext( "construction_bldg", "ringoff_plr", "outdoor" );
    declareambientroom( "medium_room" );
    setambientroomreverb( "medium_room", "overflow_mediumroom", 1, 1 );
    setambientroomcontext( "medium_room", "ringoff_plr", "indoor" );
    declareambientroom( "medium_room_partial" );
    setambientroomreverb( "medium_room_partial", "overflow_mediumroom", 1, 1 );
    setambientroomcontext( "medium_room_partial", "ringoff_plr", "outdoor" );
    declareambientroom( "cement_small_room" );
    setambientroomreverb( "cement_small_room", "overflow_cement_sml", 1, 1 );
    setambientroomcontext( "cement_small_room", "ringoff_plr", "indoor" );
    declareambientroom( "cement_small_room_partial" );
    setambientroomreverb( "cement_small_room_partial", "overflow_cement_sml", 1, 1 );
    setambientroomcontext( "cement_small_room_partial", "ringoff_plr", "outdoor" );
    declareambientroom( "cement_hallway" );
    setambientroomreverb( "cement_hallway", "overflow_cement_hall", 1, 1 );
    setambientroomcontext( "cement_hallway", "ringoff_plr", "indoor" );
    declareambientroom( "brick_alley_roof_hall" );
    setambientroomreverb( "brick_alley_roof_hall", "overflow_roof_hall", 1, 1 );
    setambientroomcontext( "brick_alley_roof_hall", "ringoff_plr", "indoor" );
    declareambientroom( "brick_alley_hall" );
    setambientroomreverb( "brick_alley_hall", "overflow_alley_hall", 1, 1 );
    setambientroomcontext( "brick_alley_hall", "ringoff_plr", "outdoor" );
    declareambientroom( "padded_room" );
    setambientroomreverb( "padded_room", "overflow_padded_dead", 1, 1 );
    setambientroomcontext( "padded_room", "ringoff_plr", "indoor" );
    declareambientroom( "padded_room_partial" );
    setambientroomreverb( "padded_room_partial", "overflow_padded_dead", 1, 1 );
    setambientroomcontext( "padded_room_partial", "ringoff_plr", "outdoor" );
    declareambientroom( "grand_stone_room" );
    setambientroomreverb( "grand_stone_room", "overflow_grand_stone_rm", 1, 1 );
    setambientroomcontext( "grand_stone_room", "ringoff_plr", "indoor" );
    declareambientroom( "grand_stone_room_partial" );
    setambientroomreverb( "grand_stone_room_partial", "overflow_grand_stone_rm", 1, 1 );
    setambientroomcontext( "grand_stone_room_partial", "ringoff_plr", "outdoor" );
    declareambientroom( "grand_stone_side_room" );
    setambientroomreverb( "grand_stone_side_room", "overflow_grand_side_rm", 1, 1 );
    setambientroomcontext( "grand_stone_side_room", "ringoff_plr", "indoor" );
    declareambientroom( "grand_stone_stairs" );
    setambientroomreverb( "grand_stone_stairs", "overflow_grand_stairs_sml", 1, 1 );
    setambientroomcontext( "grand_stone_stairs", "ringoff_plr", "indoor" );
    declareambientroom( "parital_brick_room" );
    setambientroomreverb( "parital_brick_room", "overflow_brick_med_partial", 1, 1 );
    setambientroomcontext( "parital_brick_room", "ringoff_plr", "outdoor" );
    thread snd_start_autofx_audio();
    thread snd_play_loopers();
}

snd_play_loopers()
{
    playloopat( "amb_water_edge", ( -3390, -349, 221 ) );
    playloopat( "amb_water_lap_lp", ( -3394, -350, 220 ) );
    playloopat( "amb_wind_howl", ( -1119, -53, 330 ) );
    playloopat( "amb_alley_dank_sml", ( 708, -938, 97 ) );
    playloopat( "amb_alley_dank_sml", ( 1340, -1027, 93 ) );
    playloopat( "amb_alley_dank_sml", ( 1145, -48, 176 ) );
    playloopat( "amb_alley_dank_sml_low", ( 21, 1379, 175 ) );
    playloopat( "amb_alley_dank_sml_low", ( -419, 2026, 132 ) );
    playloopat( "amb_wind_mtl_rattle_lp", ( -1542, 374, 407 ) );
}

snd_start_autofx_audio()
{
    wait 2;
    snd_play_auto_fx( "fx_mp_water_drip_light_shrt", "amb_water_drip_shrt", 0, 0, 0, 1 );
    snd_play_auto_fx( "fx_mp_water_drip_light_long", "amb_water_drip_lng", 0, 0, 0, 1 );
    snd_play_auto_fx( "fx_mp_steam_pipe_md", "dst_steam_pipe_lp", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_mp_steam_gas_pipe_md", "dst_gas_pipe_lp", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_water_pipe_spill_md", "amb_sewer_flow", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_water_pipe_spray_splash", "amb_sewer_splash", 0, 0, 0, 1 );
    snd_play_auto_fx( "fx_insects_swarm_lg_light", "amb_sml_flies", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_insects_swarm_md_light", "amb_lrg_flies", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_insects_fly_sngl_parent", "amb_sml_flies", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_light_flour_glow_cool_sngl_shrt", "amb_flour_light", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_fire_sm", "amb_car_fire_sml", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_fire_detail", "amb_fire_med", 0, 0, 0, 0 );
}
