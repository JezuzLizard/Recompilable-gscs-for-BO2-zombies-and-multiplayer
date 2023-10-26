// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\_ambientpackage;
#include clientscripts\mp\_audio;

main()
{
    declareambientroom( "outside", 1 );
    setambientroomtone( "outside", "amb_wind_exterior_2d", 0.3, 0.5 );
    setambientroomreverb( "outside", "studio_outdoor", 1, 1 );
    setambientroomcontext( "outside", "ringoff_plr", "outdoor" );
    declareambientroom( "trailer" );
    setambientroomreverb( "trailer", "studio_hallway", 1, 1 );
    setambientroomcontext( "trailer", "ringoff_plr", "indoor" );
    declareambientroom( "med_room" );
    setambientroomreverb( "med_room", "studio_mediumroom", 1, 1 );
    setambientroomcontext( "med_room", "ringoff_plr", "indoor" );
    declareambientroom( "cave" );
    setambientroomreverb( "cave", "studio_cave", 1, 1 );
    setambientroomcontext( "cave", "ringoff_plr", "indoor" );
    declareambientroom( "partial_room" );
    setambientroomtone( "partial_room", "amb_wind_exterior_2d", 0.3, 0.5 );
    setambientroomreverb( "partial_room", "studio_smallroom", 1, 1 );
    setambientroomcontext( "partial_room", "ringoff_plr", "outdoor" );
    declareambientroom( "small_room" );
    setambientroomreverb( "small_room", "studio_smallroom", 1, 1 );
    setambientroomcontext( "small_room", "ringoff_plr", "indoor" );
    declareambientroom( "stone_room" );
    setambientroomreverb( "stone_room", "studio_stoneroom", 1, 1 );
    setambientroomcontext( "stone_room", "ringoff_plr", "indoor" );
    declareambientroom( "wherehouse" );
    setambientroomreverb( "wherehouse", "studio_smallroom", 1, 1 );
    setambientroomtone( "wherehouse", "amb_wind_exterior_2d", 0.3, 0.5 );
    setambientroomcontext( "wherehouse", "ringoff_plr", "outdoor" );
    declareambientroom( "saloon" );
    setambientroomreverb( "saloon", "studio_mediumroom", 1, 1 );
    setambientroomcontext( "saloon", "ringoff_plr", "indoor" );
    declareambientroom( "tall_room" );
    setambientroomreverb( "tall_room", "studio_tall", 1, 1 );
    setambientroomcontext( "tall_room", "ringoff_plr", "indoor" );
    declareambientroom( "shack" );
    setambientroomreverb( "shack", "studio_shack", 1, 1 );
    setambientroomcontext( "shack", "ringoff_plr", "indoor" );
    declareambientroom( "wood_room" );
    setambientroomreverb( "wood_room", "studio_mediumroom", 1, 1 );
    setambientroomcontext( "wood_room", "ringoff_plr", "indoor" );
    thread snd_start_autofx_audio();
}

snd_play_loopers()
{

}

snd_start_autofx_audio()
{
    snd_play_auto_fx( "fx_mp_studio_fire_md", "amb_fire_med", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_mp_studio_toy_fire", "amb_fire_sml", 0, 0, 0, 1 );
    snd_play_auto_fx( "fx_insects_swarm_lg_light", "amb_flies", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_mp_studio_sconce_glare", "amb_lights_buzz_2", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_mp_studio_sconce_glare2", "amb_lights_buzz_2", 0, 0, 0, 0 );
}
