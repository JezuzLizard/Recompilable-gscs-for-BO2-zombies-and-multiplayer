// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\_ambientpackage;
#include clientscripts\mp\_audio;

main()
{
    thread pa_think( "notify_20", "amb_pa_notify_20" );
    thread pa_think( "notify_10", "amb_pa_notify_10" );
    thread pa_think( "notify_5", "amb_pa_notify_5" );
    thread pa_think( "notify_1", "amb_pa_notify_1" );
    thread pa_think( "notify_stones", "mus_sympathy_for_the_devil" );
    thread snd_fx_create();
    declareambientroom( "nuked_outdoor", 1 );
    setambientroomtone( "nuked_outdoor", "amb_wind_extreior_2d", 0.55, 1 );
    setambientroomreverb( "nuked_outdoor", "nuked_outdoor", 1, 1 );
    setambientroomcontext( "nuked_outdoor", "ringoff_plr", "outdoor" );
    declareambientroom( "int_room" );
    setambientroomreverb( "int_room", "nuked_house", 1, 1 );
    setambientroomcontext( "int_room", "ringoff_plr", "indoor" );
    declareambientroom( "int_room_partial" );
    setambientroomreverb( "int_room_partial", "nuked_house", 1, 1 );
    setambientroomcontext( "int_room_partial", "ringoff_plr", "outdoor" );
    declareambientroom( "truck_room" );
    setambientroomreverb( "truck_room", "nuked_truck", 1, 1 );
    setambientroomcontext( "truck_room", "ringoff_plr", "indoor" );
    declareambientroom( "truck_room_partial" );
    setambientroomreverb( "truck_room_partial", "nuked_truck", 1, 1 );
    setambientroomcontext( "truck_room_partial", "ringoff_plr", "outdoor" );
    declareambientroom( "garage" );
    setambientroomreverb( "garage", "nuked_garage", 1, 1 );
    setambientroomcontext( "garage", "ringoff_plr", "indoor" );
    declareambientroom( "garage_partial" );
    setambientroomreverb( "garage_partial", "nuked_garage", 1, 1 );
    setambientroomcontext( "garage_partial", "ringoff_plr", "outdoor" );
    declareambientroom( "wood_room" );
    setambientroomreverb( "wood_room", "nuked_wood_room", 1, 1 );
    setambientroomcontext( "wood_room", "ringoff_plr", "indoor" );
    activateambientroom( 0, "default", 0 );
}

snd_fx_create()
{
    wait 1;
    clientscripts\mp\_audio::snd_play_auto_fx( "fx_mp_nuked_sprinkler", "amb_sprinklers" );
    clientscripts\mp\_audio::snd_play_auto_fx( "fx_nuke_plant_sprinkler", "amb_sprinkler_sml", 0, 0, 0, 0 );
    clientscripts\mp\_audio::snd_play_auto_fx( "fx_nuke_vent_steam", "amb_exhaust", 0, 0, 0, 0 );
    clientscripts\mp\_audio::snd_play_auto_fx( "fx_nuke_stove_heat", "amb_stove_fire", 0, 0, 0, 0 );
    clientscripts\mp\_audio::snd_play_auto_fx( "fx_nuke_car_wash_sprinkler", "amb_steam_hiss", 0, 0, 0, 0 );
    clientscripts\mp\_audio::snd_play_auto_fx( "fx_mp_nuke_fireplace", "amb_gas_fire", 0, 0, 0, 0 );
    clientscripts\mp\_audio::snd_play_auto_fx( "fx_insects_swarm_lg_light", "amb_flies", 0, 0, 0, 0 );
    clientscripts\mp\_audio::snd_play_auto_fx( "fx_light_recessed_cool_sm_soft", "amb_small_lights", 0, 0, 0, 0 );
    clientscripts\mp\_audio::snd_play_auto_fx( "fx_mp_nuke_sound_rings", "amb_dryer", 0, 0, 0, 0 );
}

pa_think( notifyname, alias )
{
    level waittill( notifyname );

    speakers = getentarray( 0, "loudspeaker", "targetname" );

    for ( i = 0; i < speakers.size; i++ )
        speakers[i] thread pa_play( alias );
}

pa_play( alias )
{
    wait( self.script_wait_min );
    self playsound( 0, alias );
}

bomb_sound_go()
{
    level waittill( "notify_nuke" );

    playsound( 0, "amb_end_nuke", ( 0, 0, 0 ) );
}
