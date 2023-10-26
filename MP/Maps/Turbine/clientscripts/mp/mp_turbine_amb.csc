// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\_ambientpackage;
#include clientscripts\mp\_audio;

main()
{
    declareambientroom( "turbine_outdoor", 1 );
    setambientroomtone( "turbine_outdoor", "amb_wind_extreior_2d", 0.55, 1 );
    setambientroomreverb( "turbine_outdoor", "turbine_outdoor", 1, 1 );
    setambientroomcontext( "turbine_outdoor", "ringoff_plr", "outdoor" );
    declareambientroom( "turbine_comp_room" );
    setambientroomreverb( "turbine_comp_room", "turbine_largeroom", 1, 1 );
    setambientroomcontext( "turbine_comp_room", "ringoff_plr", "indoor" );
    declareambientroom( "turbine_comp_hallway" );
    setambientroomreverb( "turbine_comp_hallway", "turbine_dense_hallway", 1, 1 );
    setambientroomcontext( "turbine_comp_hallway", "ringoff_plr", "indoor" );
    declareambientroom( "turbine_comp_mg_room" );
    setambientroomreverb( "turbine_comp_mg_room", "turbine_smallroom", 1, 1 );
    setambientroomcontext( "turbine_comp_mg_room", "ringoff_plr", "indoor" );
    declareambientroom( "tur_comp_hallway_partial" );
    setambientroomreverb( "tur_comp_hallway_partial", "turbine_dense_hallway", 1, 1 );
    setambientroomcontext( "tur_comp_hallway_partial", "ringoff_plr", "outdoor" );
    declareambientroom( "turbine_tubes" );
    setambientroomtone( "turbine_tubes", "amb_air_dank_a", 0.55, 0.55 );
    setambientroomreverb( "turbine_tubes", "turbine_tube", 1, 1 );
    setambientroomcontext( "turbine_tubes", "ringoff_plr", "indoor" );
    declareambientroom( "turbine_tubes_partial" );
    setambientroomtone( "turbine_tubes", "amb_air_dank_a", 0.55, 0.55 );
    setambientroomreverb( "turbine_tubes_partial", "turbine_tube", 1, 1 );
    setambientroomcontext( "turbine_tubes_partial", "ringoff_plr", "outdoor" );
    declareambientroom( "turbine_tubes_loud" );
    setambientroomtone( "turbine_tubes_loud", "amb_air_dank_c", 0.55, 0.55 );
    setambientroomreverb( "turbine_tubes_loud", "turbine_tube", 1, 1 );
    setambientroomcontext( "turbine_tubes_loud", "ringoff_plr", "indoor" );
    declareambientroom( "tur_tubes_loud_partial" );
    setambientroomtone( "tur_tubes_loud_partial", "amb_air_dank_c", 0.55, 0.55 );
    setambientroomreverb( "tur_tubes_loud_partial", "turbine_tube", 1, 1 );
    setambientroomcontext( "tur_tubes_loud_partial", "ringoff_plr", "outdoor" );
    declareambientroom( "turbine_sewer_pipe" );
    setambientroomtone( "turbine_sewer_pipe", "amb_air_dank_a", 0.55, 0.55 );
    setambientroomreverb( "turbine_sewer_pipe", "turbine_tube", 1, 1 );
    setambientroomcontext( "turbine_sewer_pipe", "ringoff_plr", "indoor" );
    declareambientroom( "turbine_comp_storage" );
    setambientroomreverb( "turbine_comp_storage", "turbine_smallroom", 1, 1 );
    setambientroomcontext( "turbine_comp_storage", "ringoff_plr", "indoor" );
    declareambientroom( "turbine_outside_shed" );
    setambientroomtone( "turbine_outside_shed", "amb_air_dank_a", 0.55, 0.55 );
    setambientroomreverb( "turbine_outside_shed", "turbine_partialroom", 1, 1 );
    setambientroomcontext( "turbine_outside_shed", "ringoff_plr", "outdoor" );
    thread snd_start_autofx_audio();
    thread snd_play_loopers();
    thread wmill_sfx_setup();
}

snd_play_loopers()
{
    clientscripts\mp\_audio::playloopat( "amb_wind_cliff", ( -1105, -1343, 1007 ) );
    clientscripts\mp\_audio::playloopat( "amb_wind_cliff", ( -1780, 3042, 462 ) );
    clientscripts\mp\_audio::playloopat( "amb_wind_cliff", ( -1436, -80, 524 ) );
    clientscripts\mp\_audio::playloopat( "amb_wind_cliff", ( -594, -2243, 432 ) );
    clientscripts\mp\_audio::playloopat( "amb_wind_cliff", ( -133, -1095, 734 ) );
    playloopat( "amb_wind_cliff", ( -1779, 1697, 676 ) );
    clientscripts\mp\_audio::playloopat( "amb_wmill_motor", ( -2524, 3083, 856 ) );
    clientscripts\mp\_audio::playloopat( "amb_wmill_base_rumble", ( -888, 1418, 547 ) );
    clientscripts\mp\_audio::playloopat( "amb_ribon_flap", ( -998, 3088, 283 ) );
    clientscripts\mp\_audio::playloopat( "amb_ribon_flap", ( -681, 3175, 239 ) );
    clientscripts\mp\_audio::playloopat( "amb_ribon_flap", ( -618, 3281, 217 ) );
    clientscripts\mp\_audio::playloopat( "amb_ribon_flap", ( 458, 4152, -115 ) );
    clientscripts\mp\_audio::playloopat( "amb_ribon_flap", ( 977, 4313, -110 ) );
    clientscripts\mp\_audio::playloopat( "amb_ribon_flap", ( -132, 3589, 126 ) );
}

snd_start_autofx_audio()
{
    snd_play_auto_fx( "fx_light_flour_glow_cool_dbl_shrt", "amb_flour_light", 0, 0, 0, 0 );
}

wmill_sfx_setup()
{
    wait 0.5;
    location = [];
    location[0] = spawnstruct();
    location[0].origin = ( -2579, 3014, 385 );
    location[0].alias = "amb_wmill_whoosh";
    location[1] = spawnstruct();
    location[1].origin = ( -1644, -636, 563 );
    location[1].alias = "amb_wmill_whoosh";
    location[2] = spawnstruct();
    location[2].origin = ( -1073, 1351, 1941 );
    location[2].alias = "amb_wmill_whoosh";

    while ( true )
    {
        for ( i = 0; i < location.size; i++ )
            playsound( 0, location[i].alias, location[i].origin );

        wait 1.35;
    }
}

snd_play_auto_fx( fxid, alias, offsetx, offsety, offsetz, onground, area )
{
    for ( i = 0; i < level.createfxent.size; i++ )
    {
        if ( level.createfxent[i].v["fxid"] == fxid )
        {
            level.createfxent[i].soundent = spawnfakeent( 0 );

            if ( isdefined( area ) )
                level.createfxent[i].soundentarea = area;

            origin = level.createfxent[i].v["origin"];

            if ( isdefined( offsetx ) && offsetx > 0 )
                origin += ( offsetx, 0, 0 );

            if ( isdefined( offsety ) && offsetx > 0 )
                origin += ( 0, offsety, 0 );

            if ( isdefined( offsetz ) && offsetx > 0 )
                origin += ( 0, 0, offsetz );

            if ( isdefined( onground ) && onground )
            {
                trace = undefined;
                d = undefined;
                fxorigin = origin;
                trace = bullettrace( fxorigin, fxorigin - vectorscale( ( 0, 0, 1 ), 100000.0 ), 0, undefined );
                d = distance( fxorigin, trace["position"] );
                origin = trace["position"];
            }

            setfakeentorg( 0, level.createfxent[i].soundent, origin );
            playloopsound( 0, level.createfxent[i].soundent, alias, 0.5 );
        }
    }
}

snd_play_auto_fturbine_area_emmiters()
{
    for ( i = 0; i < level.createfxent.size; i++ )
    {
        if ( level.createfxent[i].soundentarea > 1 )
        {

        }
    }
}

snd_print_fturbine_id( fxid, type, ent )
{
/#
    if ( getdvarint( _hash_AEB127D ) > 0 )
        println( "^5 ******* fxid; " + fxid + "^5 type; " + type );
#/
}
