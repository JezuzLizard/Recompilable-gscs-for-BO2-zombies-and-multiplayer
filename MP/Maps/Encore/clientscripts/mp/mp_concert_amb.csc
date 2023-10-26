// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\_ambientpackage;
#include clientscripts\mp\_audio;

main()
{
    declareambientroom( "concert_outdoor", 1 );
    setambientroomtone( "concert_outdoor", "amb_wind_ext_2d", 0.5, 1 );
    setambientroomreverb( "concert_outdoor", "concert_outdoor", 1, 1 );
    setambientroomcontext( "concert_outdoor", "ringoff_plr", "outdoor" );
    declareambientroom( "onstage_room" );
    setambientroomtone( "onstage_room", "amb_wind_ext_2d_qt", 0.5, 1 );
    setambientroomreverb( "onstage_room", "concert_stage", 1, 1 );
    setambientroomcontext( "onstage_room", "ringoff_plr", "outdoor" );
    declareambientroom( "backstage_room" );
    setambientroomtone( "backstage_room", "amb_wind_int_2d", 0.5, 1 );
    setambientroomreverb( "backstage_room", "concert_backstage", 1, 1 );
    setambientroomcontext( "backstage_room", "ringoff_plr", "indoor" );
    declareambientroom( "shop_room" );
    setambientroomtone( "shop_room", "amb_wind_int_2d", 0.5, 1 );
    setambientroomreverb( "shop_room", "concert_smallroom", 1, 1 );
    setambientroomcontext( "shop_room", "ringoff_plr", "indoor" );
    declareambientroom( "staircase_room" );
    setambientroomtone( "staircase_room", "amb_wind_int_2d", 0.5, 1 );
    setambientroomreverb( "staircase_room", "concert_smallroom", 1, 1 );
    setambientroomcontext( "staircase_room", "ringoff_plr", "indoor" );
    declareambientroom( "restaurant_room" );
    setambientroomtone( "restaurant_room", "amb_wind_int_2d", 0.5, 1 );
    setambientroomreverb( "restaurant_room", "concert_mediumroom", 1, 1 );
    setambientroomcontext( "restaurant_room", "ringoff_plr", "indoor" );
    declareambientroom( "rest_patio_room" );
    setambientroomtone( "rest_patio_room", "amb_wind_ext_2d", 0.5, 1 );
    setambientroomreverb( "rest_patio_room", "concert_outdoor", 1, 1 );
    setambientroomcontext( "rest_patio_room", "ringoff_plr", "outdoor" );
    declareambientroom( "seating_area" );
    setambientroomtone( "seating_area", "amb_wind_ext_2d_qt", 0.5, 1 );
    setambientroomreverb( "seating_area", "concert_outdoor", 1, 1 );
    setambientroomcontext( "seating_area", "ringoff_plr", "outdoor" );
    declareambientroom( "bleacherbox_room" );
    setambientroomtone( "bleacherbox_room", "amb_wind_int_2d", 0.5, 1 );
    setambientroomreverb( "bleacherbox_room", "concert_stoneroom", 1, 1 );
    setambientroomcontext( "bleacherbox_room", "ringoff_plr", "indoor" );
    declareambientroom( "locker_room" );
    setambientroomtone( "locker_room", "amb_wind_int_2d", 0.5, 1 );
    setambientroomreverb( "locker_room", "concert_stoneroom", 1, 1 );
    setambientroomcontext( "locker_room", "ringoff_plr", "indoor" );
    declareambientroom( "bleacher_alcove" );
    setambientroomtone( "bleacher_alcove", "amb_wind_ext_2d_qt", 0.5, 1 );
    setambientroomreverb( "bleacher_alcove", "concert_mediumroom", 1, 1 );
    setambientroomcontext( "bleacher_alcove", "ringoff_plr", "outdoor" );
    declareambientroom( "bleacher_overhang" );
    setambientroomtone( "bleacher_overhang", "amb_wind_ext_2d", 0.5, 1 );
    setambientroomreverb( "bleacher_overhang", "concert_outdoor", 1, 1 );
    setambientroomcontext( "bleacher_overhang", "ringoff_plr", "outdoor" );
    declareambientroom( "bleacher_transition" );
    setambientroomtone( "bleacher_transition", "amb_wind_ext_2d_qt", 0.5, 1 );
    setambientroomreverb( "bleacher_transition", "concert_outdoor", 1, 1 );
    setambientroomcontext( "bleacher_transition", "ringoff_plr", "outdoor" );
    declareambientroom( "crawlspace_room" );
    setambientroomtone( "crawlspace_room", "amb_wind_int_2d", 0.5, 1 );
    setambientroomreverb( "crawlspace_room", "concert_smallroom", 1, 1 );
    setambientroomcontext( "crawlspace_room", "ringoff_plr", "indoor" );
    declareambientroom( "under_ramp_room" );
    setambientroomtone( "under_ramp_room", "amb_wind_ext_2d", 0.5, 1 );
    setambientroomreverb( "under_ramp_room", "concert_outdoor", 1, 1 );
    setambientroomcontext( "under_ramp_room", "ringoff_plr", "outdoor" );
    thread snd_start_autofx_audio();
    thread snd_play_loopers();
}

snd_play_loopers()
{

}

snd_start_autofx_audio()
{

}
