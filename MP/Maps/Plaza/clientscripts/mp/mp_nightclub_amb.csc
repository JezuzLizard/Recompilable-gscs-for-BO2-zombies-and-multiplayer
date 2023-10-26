// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\_ambientpackage;
#include clientscripts\mp\_audio;

main()
{
    declareambientroom( "nightclub_outdoor", 1 );
    setambientroomtone( "nightclub_outdoor", "amb_wind_extreior_2d", 0.55, 1 );
    setambientroomreverb( "nightclub_outdoor", "nightclub_outdoor", 1, 1 );
    setambientroomcontext( "nightclub_outdoor", "ringoff_plr", "outdoor" );
    declareambientroom( "nightclub_partial_room" );
    setambientroomreverb( "nightclub_partial_room", "nightclub_partial_room", 1, 1 );
    setambientroomcontext( "nightclub_partial_room", "ringoff_plr", "outdoor" );
    declareambientroom( "nightclub_small_room" );
    setambientroomreverb( "nightclub_small_room", "nightclub_small_room", 1, 1 );
    setambientroomcontext( "nightclub_small_room", "ringoff_plr", "indoor" );
    declareambientroom( "nightclub_construction_rm" );
    setambientroomreverb( "nightclub_construction_rm", "nightclub_small_room", 1, 1 );
    setambientroomcontext( "nightclub_construction_rm", "ringoff_plr", "indoor" );
    declareambientroom( "nightclub_construction_rm_prt" );
    setambientroomreverb( "nightclub_construction_rm_prt", "nightclub_small_room", 1, 1 );
    setambientroomcontext( "nightclub_construction_rm_prt", "ringoff_plr", "outdoor" );
    declareambientroom( "nightclub_gift_shop" );
    setambientroomreverb( "nightclub_gift_shop", "nightclub_small_room", 1, 1 );
    setambientroomcontext( "nightclub_gift_shop", "ringoff_plr", "indoor" );
    declareambientroom( "nightclub_gift_shop_prt" );
    setambientroomreverb( "nightclub_gift_shop_prt", "nightclub_small_room", 1, 1 );
    setambientroomcontext( "nightclub_gift_shop_prt", "ringoff_plr", "outdoor" );
    declareambientroom( "nightclub_gift_shop_md" );
    setambientroomreverb( "nightclub_gift_shop_md", "nightclub_medium_room", 1, 1 );
    setambientroomcontext( "nightclub_gift_shop_md", "ringoff_plr", "indoor" );
    declareambientroom( "nightclub_gift_shop_md_prt" );
    setambientroomreverb( "nightclub_gift_shop_md_prt", "nightclub_medium_room", 1, 1 );
    setambientroomcontext( "nightclub_gift_shop_md_prt", "ringoff_plr", "outdoor" );
    declareambientroom( "nightclub_wood_room" );
    setambientroomreverb( "nightclub_wood_room", "nightclub_small_room", 1, 1 );
    setambientroomcontext( "nightclub_wood_room", "ringoff_plr", "indoor" );
    declareambientroom( "nightclub_maint_rm" );
    setambientroomreverb( "nightclub_maint_rm", "nightclub_stone_room", 1, 1 );
    setambientroomcontext( "nightclub_maint_rm", "ringoff_plr", "indoor" );
    declareambientroom( "nightclub_maint_rm_prt" );
    setambientroomreverb( "nightclub_maint_rm_prt", "nightclub_stone_room", 1, 1 );
    setambientroomcontext( "nightclub_maint_rm_prt", "ringoff_plr", "outdoor" );
    declareambientroom( "nightclub_club_hallway" );
    setambientroomreverb( "nightclub_club_hallway", "nightclub_dense_hallway", 1, 1 );
    setambientroomcontext( "nightclub_club_hallway", "ringoff_plr", "indoor" );
    declareambientroom( "nightclub_club_lobby" );
    setambientroomreverb( "nightclub_club_lobby", "nightclub_small_room", 1, 1 );
    setambientroomcontext( "nightclub_club_lobby", "ringoff_plr", "indoor" );
    declareambientroom( "nightclub_club_lobby_prt" );
    setambientroomreverb( "nightclub_club_lobby_prt", "nightclub_small_room", 1, 1 );
    setambientroomcontext( "nightclub_club_lobby_prt", "ringoff_plr", "outdoor" );
    declareambientroom( "nightclub_bar" );
    setambientroomreverb( "nightclub_bar", "nightclub_large_room", 1, 1 );
    setambientroomcontext( "nightclub_bar", "ringoff_plr", "indoor" );
    declareambientroom( "nightclub_stairs" );
    setambientroomreverb( "nightclub_stairs", "nightclub_stone_room", 1, 1 );
    setambientroomcontext( "nightclub_stairs", "ringoff_plr", "indoor" );
    declareambientroom( "nightclub_stairs_prt" );
    setambientroomreverb( "nightclub_stairs_prt", "nightclub_stone_room", 1, 1 );
    setambientroomcontext( "nightclub_stairs_prt", "ringoff_plr", "outdoor" );
    declareambientroom( "nightclub_coffee_shop" );
    setambientroomreverb( "nightclub_coffee_shop", "nightclub_small_room", 1, 1 );
    setambientroomcontext( "nightclub_coffee_shop", "ringoff_plr", "indoor" );
    declareambientroom( "nightclub_medium_room" );
    setambientroomreverb( "nightclub_medium_room", "nightclub_medium_room", 1, 1 );
    setambientroomcontext( "nightclub_medium_room", "ringoff_plr", "indoor" );
    declareambientroom( "nightclub_large_room" );
    setambientroomreverb( "nightclub_large_room", "nightclub_large_room", 1, 1 );
    setambientroomcontext( "nightclub_large_room", "ringoff_plr", "indoor" );
    declareambientroom( "nightclub_open_room" );
    setambientroomreverb( "nightclub_open_room", "nightclub_open_room", 1, 1 );
    setambientroomcontext( "nightclub_open_room", "ringoff_plr", "indoor" );
    declareambientroom( "nightclub_dense_hallway" );
    setambientroomreverb( "nightclub_dense_hallway", "nightclub_dense_hallway", 1, 1 );
    setambientroomcontext( "nightclub_dense_hallway", "ringoff_plr", "indoor" );
    declareambientroom( "nightclub_stone_room" );
    setambientroomreverb( "nightclub_stone_room", "nightclub_stone_room", 1, 1 );
    setambientroomcontext( "nightclub_stone_room", "ringoff_plr", "indoor" );
    declareambientroom( "nightclub_container" );
    setambientroomreverb( "nightclub_container", "nightclub_container", 1, 1 );
    setambientroomcontext( "nightclub_container", "ringoff_plr", "indoor" );
    thread snd_start_autofnightclub_audio();
    thread snd_play_loopers();
    thread snd_start_club_music();
}

snd_play_loopers()
{
    playloopat( "amb_rope_swing", ( -16077, 2513, 25 ) );
    playloopat( "amb_rope_swing", ( -16476, 2469, -6 ) );
    playloopat( "amb_rope_swing", ( -16911, 2539, 33 ) );
    playloopat( "amb_rope_swing", ( -17079, 2826, 42 ) );
    playloopat( "amb_rope_swing", ( -17507, 2573, 76 ) );
    playloopat( "vox_ads_1_01_003a_pa", ( -18485, 2094, -84 ) );
    playloopat( "vox_ads_1_01_003a_pa", ( -16887, 2830, -132 ) );
    playloopat( "vox_ads_1_01_003a_pa", ( -16716, 3155, -133 ) );
}

snd_start_autofnightclub_audio()
{
    snd_play_auto_fx( "fx_nightclub_bar_light", "amb_bar_lights", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_village_tube_light", "amb_flourescent_light", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_mp_nightclub_tank_bubbles", "amb_aquarium", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_mp_nightclub_flr_glare", "amb_floor_lights", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_mp_nightclub_flood_light", "amb_flood_lights", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_mp_nightclub_fire", "amb_fire", 0, 0, 0, 0 );
}

snd_start_club_music()
{
    if ( getgametypesetting( "allowMapScripting" ) )
        playloopat( "amb_nightclub_music", ( -16604, 1089, 98 ) );
}
