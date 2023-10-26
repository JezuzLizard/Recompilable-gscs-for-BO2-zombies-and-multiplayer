// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\_ambientpackage;
#include clientscripts\mp\_audio;

main()
{
    declareambientroom( "paintball_outdoor", 1 );
    setambientroomtone( "paintball_outdoor", "amb_wind_exterior_2d", 0.4, 1 );
    setambientroomreverb( "paintball_outdoor", "paintball_outdoor", 1, 1 );
    setambientroomcontext( "paintball_outdoor", "ringoff_plr", "outdoor" );
    declareambientroom( "obstacle_area_room" );
    setambientroomtone( "obstacle_area_room", "amb_wind_interior_2d", 0.4, 1 );
    setambientroomreverb( "obstacle_area_room", "paintball_outdoor", 1, 1 );
    setambientroomcontext( "obstacle_area_room", "ringoff_plr", "indoor" );
    declareambientroom( "obstacle_area_small_room" );
    setambientroomtone( "obstacle_area_small_room", "amb_wind_interior_2d", 0.4, 1 );
    setambientroomreverb( "obstacle_area_small_room", "paintball_wood_small", 1, 1 );
    setambientroomcontext( "obstacle_area_small_room", "ringoff_plr", "indoor" );
    declareambientroom( "obstacle_area_corridor" );
    setambientroomtone( "obstacle_area_corridor", "amb_wind_interior_2d", 0.4, 1 );
    setambientroomreverb( "obstacle_area_corridor", "paintball_hallway", 1, 1 );
    setambientroomcontext( "obstacle_area_corridor", "ringoff_plr", "indoor" );
    declareambientroom( "warehouse_room" );
    setambientroomtone( "warehouse_room", "amb_wind_interior_2d", 0.4, 1 );
    setambientroomreverb( "warehouse_room", "paintball_wherehouse", 1, 1 );
    setambientroomcontext( "warehouse_room", "ringoff_plr", "indoor" );
    declareambientroom( "warehouse_entrance" );
    setambientroomtone( "warehouse_entrance", "amb_wind_exterior_2d_qt", 0.4, 1 );
    setambientroomreverb( "warehouse_entrance", "gen_mediumroom", 1, 1 );
    setambientroomcontext( "warehouse_entrance", "ringoff_plr", "indoor" );
    declareambientroom( "proshop_room" );
    setambientroomtone( "proshop_room", "amb_wind_interior_2d", 0.4, 1 );
    setambientroomreverb( "proshop_room", "paintball_room_medium", 1, 1 );
    setambientroomcontext( "proshop_room", "ringoff_plr", "indoor" );
    declareambientroom( "proshop_room_small" );
    setambientroomtone( "proshop_room_small", "amb_wind_interior_2d", 0.4, 1 );
    setambientroomreverb( "proshop_room_small", "paintball_proshop", 1, 1 );
    setambientroomcontext( "proshop_room_small", "ringoff_plr", "indoor" );
    declareambientroom( "bus_room" );
    setambientroomtone( "bus_room", "amb_wind_exterior_2d_qt", 0.4, 1 );
    setambientroomreverb( "bus_room", "paintball_bus", 1, 1 );
    setambientroomcontext( "bus_room", "ringoff_plr", "indoor" );
    declareambientroom( "obstacle_area_under_room" );
    setambientroomtone( "obstacle_area_under_room", "amb_wind_interior_2d", 0.4, 1 );
    setambientroomreverb( "obstacle_area_under_room", "paintball_wood_small", 1, 1 );
    setambientroomcontext( "obstacle_area_under_room", "ringoff_plr", "indoor" );
    thread snd_start_autofx_audio();
    thread snd_play_loopers();
}

snd_play_loopers()
{

}

snd_start_autofx_audio()
{

}
