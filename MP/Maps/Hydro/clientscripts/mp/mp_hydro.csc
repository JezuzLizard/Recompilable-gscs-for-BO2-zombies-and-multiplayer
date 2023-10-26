// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\_load;
#include clientscripts\mp\mp_hydro_fx;
#include clientscripts\mp\_audio;
#include clientscripts\mp\mp_hydro_amb;

main()
{
    level.worldmapx = 0;
    level.worldmapy = 0;
    level.worldlat = 24.5581;
    level.worldlong = 67.9817;
    clientscripts\mp\_load::main();
    clientscripts\mp\mp_hydro_fx::main();
    thread clientscripts\mp\_audio::audio_init( 0 );
    thread clientscripts\mp\mp_hydro_amb::main();
    level.onplayerconnect = ::hydroplayerconnected;
    registerclientfield( "world", "pre_wave", 1, 1, "int", ::playprewave, 0 );
    registerclientfield( "world", "big_wave", 1, 1, "int", ::playbigwave, 0 );
    setsaveddvar( "r_waterwavebase", 0 );
    setsaveddvar( "r_waterwavewavelength", "290 1 1 1" );
    setsaveddvar( "r_waterwaveangle", "91.43 0 0 0" );
    setsaveddvar( "r_waterwavespeed", "2 2 2 2" );
    setsaveddvar( "r_waterwaveamplitude", "1 0 0 0" );
    setsaveddvar( "r_waterwavenormalscale", 0.25 );
    setsaveddvar( "sm_sunsamplesizenear", 0.35 );
    setdvar( "tu6_player_shallowWaterHeight", "10.5" );
    setdvar( "bg_plantInWaterDepth", "11" );
    setdvar( "tu7_cg_deathCamAboveWater", "8" );
    setdvar( "scr_hydro_water_rush_speed", "4" );
    setdvar( "scr_hydro_water_rush_up_time", "8" );
    setdvar( "scr_hydro_water_rush_down_time", "4.5" );
    waitforclient( 0 );
/#
    println( "*** Client : mp_hydro running..." );
#/
    level thread water_animation();
}

water_animation()
{
    framerate = 0.0166667;
    color_u = 0;
    color_v = 0;
    dist_u = 0;
    dist_v = 0;
    level.water_multiplier = 1;
    level.water_rate = 1;
    multiplier = 1;
    alpha = 0;

    for (;;)
    {
        color_u_rate = 0.0000933333;
        color_v_rate = 0.00035;
        dist_u_rate = -0.00014;
        dist_v_rate = 0.00035;

        if ( multiplier < level.water_multiplier )
        {
            multiplier = clamp( multiplier + level.water_rate, 1, level.water_multiplier );
            alpha = clamp( alpha + framerate, 0, 1 );
        }
        else if ( multiplier > level.water_multiplier )
        {
            multiplier = clamp( multiplier - level.water_rate, 1, multiplier );
            alpha = clamp( alpha - framerate, 0, 1 );
        }

        color_u_rate *= multiplier;
        color_v_rate *= multiplier;
        dist_u_rate *= multiplier;
        dist_v_rate *= multiplier;
        color_u += color_u_rate;
        color_v += color_v_rate;
        dist_u += dist_u_rate;
        dist_v += dist_v_rate;
        str = color_u + "  " + color_v + " " + dist_u + " " + dist_v;
        setsaveddvar( "r_waterWaveScriptShader0", str );
        str = alpha + " " + alpha + " 0 0";
        setsaveddvar( "r_waterWaveScriptShader1", str );
        wait( framerate );
    }
}

hydroplayerconnected( localclientnum )
{
    for (;;)
    {
        level waittill( "snap_processed", snapshotlocalclientnum );

        if ( snapshotlocalclientnum == localclientnum )
            break;
    }

    level thread water_killstreak_fx( localclientnum );
    water_sheeting_triggers = getentarray( 0, "prone_water_fx", "targetname" );

    foreach ( trigger in water_sheeting_triggers )
        trigger thread water_prone_fx( localclientnum );

    security_camera_balls = getentarray( localclientnum, "security_camera_ball", "targetname" );

    foreach ( cameraball in security_camera_balls )
        cameraball thread cameratrackplayer( localclientnum );
}

water_killstreak_fx( localclientnum )
{
    if ( isdemoplaying() )
        return;

    ents = level.createfxexploders[2001];
    assert( isdefined( ents ) );

    foreach ( ent in ents )
    {
        if ( !isdefined( ent.loopfx ) )
            ent.loopfx = [];
    }

    airborne = 2 | 4 | 8;

    for (;;)
    {
        level waittill( "snap_processed", snapshotlocalclientnum );

        if ( snapshotlocalclientnum == localclientnum )
        {
            player = getlocalplayer( localclientnum );

            if ( !isdefined( player ) )
                continue;

            foreach ( ent in ents )
            {
                if ( player.eflags2 & airborne )
                {
                    if ( !isdefined( ent.loopfx[localclientnum] ) )
                        ent.loopfx[localclientnum] = playfx( localclientnum, level._effect[ent.v["fxid"]], ent.v["origin"], ent.v["forward"], ent.v["up"] );

                    continue;
                }

                if ( isdefined( ent.loopfx[localclientnum] ) )
                {
                    stopfx( localclientnum, ent.loopfx[localclientnum] );
                    ent.loopfx[localclientnum] = undefined;
                }
            }
        }
    }
}

water_prone_fx( localclientnum )
{
    for (;;)
    {
        self waittill( "trigger", player );

        if ( !player islocalplayer() )
            continue;

        clientnum = player getlocalclientnumber();

        if ( !isdefined( clientnum ) )
            continue;

        if ( clientnum != localclientnum )
            continue;

        while ( player istouching( self ) )
        {
            if ( player getstance( localclientnum ) == "prone" )
                startwatersheetingfx( localclientnum );
            else
                stopwatersheetingfx( localclientnum, 2 );

            wait 0.1;

            if ( !isdefined( player ) )
                break;
        }

        stopwatersheetingfx( localclientnum, 2 );
    }
}

playprewave( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
    if ( localclientnum != 0 )
        return;

    if ( newval )
    {
        multiplier = getdvarfloat( _hash_EF33F5E5 );
        seconds = getdvarfloat( _hash_25994707 );
        diff = abs( multiplier - level.water_multiplier );
        frames = 60 * seconds;
        level.water_multiplier = multiplier;
        level.water_rate = diff / frames;
    }
    else
    {
        multiplier = 1;
        seconds = getdvarfloat( _hash_71478E3A );
        diff = abs( multiplier - level.water_multiplier );
        frames = 60 * seconds;
        level.water_multiplier = multiplier;
        level.water_rate = diff / frames;
    }
}

playbigwave( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
    if ( localclientnum != 0 )
        return;

    player = getlocalplayer( localclientnum );

    if ( !isdefined( player ) )
        return;

    if ( player getinkillcam( localclientnum ) )
        return;

    if ( newval == oldval )
        return;

    if ( newval )
    {
        level notify( "playBigWaveSingleton" );
        level endon( "playBigWaveSingleton" );
        wave_1_origin = ( -188, -2267, 208 );
        wave_2_origin = ( 128, -2267, 208 );
        level thread waterlevel();
        level thread waterwaves();
        wait 0.05;
        setripplewave( localclientnum, wave_1_origin[0] * -1, wave_1_origin[1] * -1, 800, 1.5, 0.07, 0.0, 5.0, 1800, 2100 );
        setripplewave( localclientnum, wave_2_origin[0] * -1, wave_2_origin[1] * -1, 800, 1.5, 0.07, 0.0, 5.0, 1800, 2100 );
    }
}

waterlevel()
{
    level endon( "playBigWaveSingleton" );

    for ( i = 1; i < 101; i++ )
    {
        setsaveddvar( "R_WaterWaveBase", 0 + i * 0.205 );
        setsaveddvar( "r_waterwavenormalscale", 0.25 + i * 0.0375 );
        wait 0.025;
    }

    wait 2.5;

    for ( i = 100; i > -1; i-- )
    {
        setsaveddvar( "R_WaterWaveBase", 0 + i * 0.205 );
        setsaveddvar( "r_waterwavenormalscale", 0.25 + i * 0.0375 );
        wait 0.015;
    }
}

waterwaves()
{
    level endon( "playBigWaveSingleton" );

    for ( i = 1; i < 18; i++ )
    {
        amp = i + " 0 0 0";
        setsaveddvar( "r_waterwaveamplitude", amp );
        wait 0.15;
    }

    wait 2.8;

    for ( i = 16; i > 0; i-- )
    {
        amp = i + " 0 0 0";
        setsaveddvar( "r_waterwaveamplitude", amp );
        wait 0.15;
    }
}

cameratrackplayer( localclientnum )
{
    pitch = self.angles[0];
    roll = self.angles[2];

    for (;;)
    {
        localplayer = getnonpredictedlocalplayer( 0 );

        if ( isdefined( localplayer ) && isdefined( localplayer.origin ) )
        {
            direction = localplayer.origin - self.origin;
            angles = vectortoangles( direction );
            flattenedangles = ( pitch, angles[1] + 90, roll );
            self rotateto( flattenedangles, 0.5 );
        }

        wait 0.5;
    }
}
