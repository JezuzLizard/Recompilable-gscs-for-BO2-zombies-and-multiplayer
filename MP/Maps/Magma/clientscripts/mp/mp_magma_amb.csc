// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\_ambientpackage;
#include clientscripts\mp\_audio;

main()
{
    declareambientroom( "magma_outdoor", 1 );
    setambientroomtone( "magma_outdoor", "amb_wind_extreior_2d", 0.2, 0.5 );
    setambientroomreverb( "magma_outdoor", "magma_outdoor", 1, 1 );
    setambientroomcontext( "magma_outdoor", "ringoff_plr", "outdoor" );
    declareambientroom( "magma_karaoke_sml" );
    setambientroomreverb( "magma_karaoke_sml", "magma_smallroom", 1, 1 );
    setambientroomcontext( "magma_karaoke_sml", "ringoff_plr", "indoor" );
    declareambientroom( "magma_karaoke_stairs" );
    setambientroomreverb( "magma_karaoke_stairs", "magma_hallroom", 1, 1 );
    setambientroomcontext( "magma_karaoke_stairs", "ringoff_plr", "indoor" );
    declareambientroom( "magma_bar" );
    setambientroomreverb( "magma_bar", "magma_mediumroom", 1, 1 );
    setambientroomcontext( "magma_bar", "ringoff_plr", "indoor" );
    declareambientroom( "magma_post_office" );
    setambientroomreverb( "magma_post_office", "magma_smallroom", 1, 1 );
    setambientroomcontext( "magma_post_office", "ringoff_plr", "indoor" );
    declareambientroom( "magma_fish_market" );
    setambientroomreverb( "magma_fish_market", "magma_mediumroom", 1, 1 );
    setambientroomcontext( "magma_fish_market", "ringoff_plr", "indoor" );
    declareambientroom( "magma_broken_train" );
    setambientroomreverb( "magma_broken_train", "magma_train", 1, 1 );
    setambientroomcontext( "magma_broken_train", "ringoff_plr", "indoor" );
    declareambientroom( "magma_train_depot_overhang" );
    setambientroomreverb( "magma_train_depot_overhang", "magma_cave", 1, 1 );
    setambientroomcontext( "magma_train_depot_overhang", "ringoff_plr", "indoor" );
    declareambientroom( "magma_train_depot_lrg" );
    setambientroomreverb( "magma_train_depot_lrg", "magma_largeroom", 1, 1 );
    setambientroomcontext( "magma_train_depot_lrg", "ringoff_plr", "indoor" );
    declareambientroom( "magma_train_depot_med" );
    setambientroomreverb( "magma_train_depot_med", "magma_mediumroom", 1, 1 );
    setambientroomcontext( "magma_train_depot_med", "ringoff_plr", "indoor" );
    declareambientroom( "magma_outdoor_stairs" );
    setambientroomreverb( "magma_outdoor_stairs", "magma_hallroom", 1, 1 );
    setambientroomcontext( "magma_outdoor_stairs", "ringoff_plr", "outdoor" );
    declareambientroom( "magma_tunnel" );
    setambientroomreverb( "magma_tunnel", "magma_hangar", 1, 1 );
    setambientroomcontext( "magma_tunnel", "ringoff_plr", "indoor" );
    thread snd_start_autofx_audio();
    thread snd_play_loopers();
}

snd_play_loopers()
{
    playloopat( "amb_ribbon_flap", ( -1474, -1162, -327 ) );
    playloopat( "amb_ribbon_flap", ( -1478, -1498, -330 ) );
    playloopat( "amb_ribbon_flap", ( -1474, -1162, -327 ) );
    playloopat( "amb_ac_wall_unit", ( -2320, -1322, -349 ) );
}

snd_start_autofx_audio()
{
    snd_play_auto_fx( "fx_mp_magma_ball_falling_sky", "amb_fire_sml_wide", 0, 0, 0, 1 );
    snd_play_auto_fx( "fx_mp_magma_lava_edge_fire_50", "amb_fire_sml", 0, 0, 0, 1 );
    snd_play_auto_fx( "fx_mp_magma_lava_edge_fire_100", "amb_fire_sml", 0, 0, 0, 1 );
    snd_play_auto_fx( "fx_mp_magma_lava_edge_fire_200_dist", "amb_fire_med", 0, 0, 0, 1 );
    snd_play_auto_fx( "fx_mp_magma_fire_lg", "amb_fire_lrg", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_mp_magma_fire_med", "amb_fire_med", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_mp_magma_lava_bubble_sm", "amb_magma_spatter", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_mp_magma_fire_xlg", "amb_fire_xlrg", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_mp_magma_steam_vent_w", "amb_exhaust_outside", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_mp_magma_steam_vent_int", "amb_exhaust_outside", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_light_mag_ceiling_light", "amb_ceiling_light", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_light_recessed_cool_sm_soft", "amb_ceiling_light", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_mp_magma_splat_detail", "amb_static_splat", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_mp_magma_splat_detail1", "amb_static_splat", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_mp_magma_splat_detail2", "amb_static_splat", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_mp_magma_splat_grnd_lg", "amb_splat_sizzle", 0, 0, 0, 1 );
    snd_play_auto_fx( "fx_mp_magma_splat_grnd_xlg", "amb_splat_sizzle", 0, 0, 0, 1 );
    snd_play_auto_fx( "fx_mp_magma_splat_grnd_md", "amb_static_splat", 0, 0, 0, 1 );
    snd_play_auto_fx( "fx_mp_magma_splat_wall", "amb_splat_sizzle", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_mp_magma_splat_wall_detail", "amb_splat_sizzle", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_mp_magma_splat_wall_lg", "amb_splat_sizzle", 0, 0, 0, 0 );
}
