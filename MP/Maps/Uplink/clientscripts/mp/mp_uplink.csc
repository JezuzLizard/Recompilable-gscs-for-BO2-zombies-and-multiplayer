// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\_load;
#include clientscripts\mp\mp_uplink_fx;
#include clientscripts\mp\_audio;
#include clientscripts\mp\mp_uplink_amb;
#include clientscripts\mp\_fx;

main()
{
    level.worldmapx = 0;
    level.worldmapy = 0;
    level.worldlat = 19.2278;
    level.worldlong = 94.4495;
    clientscripts\mp\_load::main();
    clientscripts\mp\mp_uplink_fx::main();
    thread clientscripts\mp\_audio::audio_init( 0 );
    thread clientscripts\mp\mp_uplink_amb::main();
    registerclientfield( "world", "trigger_lightning", 1, 1, "int", ::emptyfunction, 0 );
    level.onplayerconnect = ::uplinkonplayerconnect;
    level._glasssmashcbfunc = ::_glasssmashcbfunc;
    setsaveddvar( "sm_sunshadowsmall", 1 );
    waitforclient( 0 );
/#
    println( "*** Client : mp_uplink running..." );
#/
    level notify( "uplink_client_connected" );
    initrainfx( 0 );
    level thread initlightningloop( 0 );
}

_glasssmashcbfunc( org, dir )
{
    level notify( "_glassSmashCBFunc" );
    level endon( "_glassSmashCBFunc" );

    if ( !isdefined( level._uplinkglasssmashed ) )
        level._uplinkglasssmashed = [];

    level._uplinkglasssmashed[level._uplinkglasssmashed.size] = org;

    for ( last = level._uplinkglasssmashed.size - 1; last >= 0; last-- )
    {
        wait 0.05;
        level notify( "uplink_glass_smash", level._uplinkglasssmashed[last] );
        level._uplinkglasssmashed[last] = undefined;
    }
}

joininprogressglasssmash()
{
    level endon( "uplink_client_connected" );

    level waittill( "uplink_glass_smash", origin );

    level.glasssmashjoininprogress[level.glasssmashjoininprogress.size] = origin;
}

uplinkonplayerconnect( localclientnum )
{
    for (;;)
    {
        level waittill( "snap_processed", snapshotlocalclientnum );

        if ( snapshotlocalclientnum == localclientnum )
            break;
    }

    windvanearray = getentarray( localclientnum, "wind_direction", "targetname" );

    if ( isdefined( windvanearray ) && windvanearray.size > 0 )
    {
        foreach ( windvane in windvanearray )
            windvane thread windvanedirection( localclientnum );
    }

    lightpost = getent( localclientnum, "sway_lightpost", "targetname" );

    if ( isdefined( lightpost ) && !isdemoplaying() )
        lightpost thread lightpostsway();
}

initlightningloop( localclientnum )
{
    for (;;)
    {
        serverwait( localclientnum, randomfloatrange( 10.0, 15.0 ) );
        playlightning( localclientnum );
    }
}

playlightning( localclientnum )
{
    lightning_id = randomintrange( 7001, 7005 );
/#
    assert( isdefined( level.createfxexploders[lightning_id] ) );
    assert( isdefined( level.createfxexploders[lightning_id][0].v["origin"] ) );
#/
    if ( isdefined( level.createfxexploders[lightning_id] ) )
    {
        clientscripts\mp\_fx::activate_exploder( lightning_id );
        lightning_origin = level.createfxexploders[lightning_id][0].v["origin"];
        serverwait( localclientnum, randomfloatrange( 0.05, 0.15 ) );
        n_level_sunlight = getdvarfloat( "r_lightTweakSunLight" );
        n_level_exposure = getdvarfloat( "r_exposureValue" );
        n_strikes = randomintrange( 2, 4 );

        for ( i = 0; i < n_strikes; i++ )
        {
            n_blend_time = randomfloatrange( 0.0, 0.25 );
            setdvar( "r_exposureTweak", 1 );
            playsound( localclientnum, "amb_thunder_flash", lightning_origin );
            setdvar( "r_exposureValue", randomfloatrange( 1.8, 2.3 ) );
            level thread serverlerpdvar( localclientnum, "r_exposureValue", n_level_exposure, n_blend_time );
            setsaveddvar( "r_lightTweakSunLight", randomfloatrange( 25, 32 ) );
            level thread serverlerpdvar( localclientnum, "r_lightTweakSunLight", n_level_sunlight, n_blend_time, 1 );
            serverwait( localclientnum, n_blend_time );
            setdvar( "r_exposureTweak", 0 );
        }
    }
}

lightpostsway()
{
    while ( true )
    {
        randomswingangle = randomfloatrange( 0.25, 0.5 );
        randomswingtime = randomfloatrange( 2.0, 4.0 );
        self rotateto( ( randomswingangle * 0.5, randomswingangle * 0.6, randomswingangle * 0.8 ), randomswingtime, randomswingtime * 0.3, randomswingtime * 0.3 );

        self waittill( "rotatedone" );

        self rotateto( ( randomswingangle * 0.5 * -1, randomswingangle * -1 * 0.6, randomswingangle * 0.8 * -1 ), randomswingtime, randomswingtime * 0.3, randomswingtime * 0.3 );

        self waittill( "rotatedone" );
    }
}

initrainfx( localclientnum )
{
    intact_window_exploders = [];
    shattered_window_exploders = [];
    directional_exploders = [];

    for ( i = 0; i < level.createfxent.size; i++ )
    {
        ent = level.createfxent[i];

        if ( !isdefined( ent ) )
            continue;

        if ( ent.v["type"] != "exploder" )
            continue;

        if ( ent.v["exploder"] >= 5001 && ent.v["exploder"] <= 5029 )
        {
            intact_window_exploders[intact_window_exploders.size] = ent;
            continue;
        }

        if ( ent.v["exploder"] >= 6001 && ent.v["exploder"] <= 6020 )
        {
            shattered_window_exploders[shattered_window_exploders.size] = ent;

            if ( ent.v["exploder"] >= 6003 && ent.v["exploder"] <= 6006 )
                directional_exploders[directional_exploders.size] = ent;
        }
    }

    level thread activaterainfxonconnect( localclientnum, intact_window_exploders, shattered_window_exploders, directional_exploders );
}

activaterainfxonconnect( localclientnum, intact_window_exploders, shattered_window_exploders, directional_exploders )
{
    level thread playerjoininprogressglassshatter( localclientnum, intact_window_exploders, shattered_window_exploders );
    level thread triggerexplodersonglassshatter( localclientnum, intact_window_exploders, shattered_window_exploders );
    player = getlocalplayer( localclientnum );
    player thread rainexploderswitch( localclientnum, directional_exploders );
    player thread activateintactwindowexploders( intact_window_exploders );
}

rainexploderswitch( localclientnum, directional_exploders )
{
    level.current_rain_exploder = undefined;
    waittillframeend;

    for (;;)
    {
        if ( !isdefined( level.createfxexploders ) )
            return;

        for ( i = 0; i < directional_exploders.size; i++ )
            clientscripts\mp\_fx::deactivate_exploder( directional_exploders[i].v["exploder"] );

        if ( randomint( 2 ) )
        {
            level.current_rain_exploder = 1002;
            level notify( "wind_changed", 270 );
        }
        else
        {
            level.current_rain_exploder = 1001;
            level notify( "wind_changed", 90 );

            if ( isdemoplaying() == 0 )
            {
                for ( i = 0; i < directional_exploders.size; i++ )
                {
                    if ( isdefined( directional_exploders[i].glass_broken ) )
                        clientscripts\mp\_fx::activate_exploder( directional_exploders[i].v["exploder"] );
                }
            }
        }

        clientscripts\mp\_fx::activate_exploder( level.current_rain_exploder );
        serverwait( localclientnum, 8.0 );
    }
}

windvanedirection( localclientnum )
{
    originalangles = self.angles;

    for (;;)
    {
        level waittill( "wind_changed", yaw );

        self thread windvanejitter( originalangles, yaw );
    }
}

windvanejitter( originalangles, yaw )
{
    self notify( "windVaneJitter_singleton" );
    self endon( "windVaneJitter_singleton" );
    wait 0.5;
    self rotateto( ( originalangles[0], yaw, originalangles[2] ), 1.0 );

    self waittill( "rotatedone" );

    for (;;)
    {
        time = randomfloatrange( 0.1, 0.5 );
        currentyaw = randomfloatrange( yaw - 30, yaw + 30 );
        self rotateto( ( originalangles[0], currentyaw, originalangles[2] ), time );

        self waittill( "rotatedone" );
    }
}

activateintactwindowexploders( intact_window_exploders )
{
    if ( intact_window_exploders.size > 0 )
    {
        for ( i = 0; i < intact_window_exploders.size; i++ )
            clientscripts\mp\_fx::activate_exploder( intact_window_exploders[i].v["exploder"] );
    }
}

playerjoininprogressglassshatter( localclientnum, intact_window_exploders, shattered_window_exploders )
{
    if ( isdefined( level.glasssmashjoininprogress ) )
    {
        foreach ( origin in level.glasssmashjoininprogress )
        {
            glasssmashdetected( localclientnum, origin, intact_window_exploders, shattered_window_exploders );
            wait 0.05;
        }
    }
}

triggerexplodersonglassshatter( localclientnum, intact_window_exploders, shattered_window_exploders )
{
    for (;;)
    {
        level waittill( "uplink_glass_smash", origin );

        glasssmashdetected( localclientnum, origin, intact_window_exploders, shattered_window_exploders );
    }
}

glasssmashdetected( localclientnum, origin, intact_window_exploders, shattered_window_exploders )
{
    closest = 998001;
    closest_intact_exploder = undefined;
    closest_shattered_exploder = undefined;

    foreach ( intact_window_exploder in intact_window_exploders )
    {
        if ( !isdefined( intact_window_exploder ) )
            continue;

        if ( isdefined( intact_window_exploder.glass_broken ) )
            continue;

        distsq = distancesquared( intact_window_exploder.v["origin"], origin );

        if ( distsq > 2500 )
            continue;

        if ( distsq < closest )
        {
            closest_intact_exploder = intact_window_exploder;
            closest = distsq;
        }
    }

    if ( isdefined( closest_intact_exploder ) )
    {
        closest_intact_exploder.glass_broken = 1;
        clientscripts\mp\_fx::deactivate_exploder( closest_intact_exploder.v["exploder"] );
    }

    closest = 998001;

    foreach ( shattered_window_exploder in shattered_window_exploders )
    {
        if ( !isdefined( shattered_window_exploder ) )
            continue;

        if ( isdefined( shattered_window_exploder.glass_broken ) )
            continue;

        distsq = distancesquared( shattered_window_exploder.v["origin"], origin );

        if ( issouthernexploder( shattered_window_exploder ) )
            currentthreshold = 7225;
        else
            currentthreshold = 2500;

        if ( distsq > currentthreshold )
            continue;

        if ( distsq < closest )
        {
            closest_shattered_exploder = shattered_window_exploder;
            closest = distsq;
        }
    }

    if ( isdefined( closest_shattered_exploder ) )
    {
        closest_shattered_exploder.glass_broken = 1;

        if ( !issouthernexploder( closest_shattered_exploder ) || level.current_rain_exploder == 1001 )
        {
            clientscripts\mp\_fx::activate_exploder( closest_shattered_exploder.v["exploder"] );
            origin = closest_shattered_exploder.v["origin"];
            rainsnd = spawn( localclientnum, origin, "script_origin" );
            rainsnd playloopsound( "amb_rain_thru_window", 0.5 );
        }
    }
}

issouthernexploder( exploder )
{
    return exploder.v["exploder"] >= 6003 && exploder.v["exploder"] <= 6006;
}

emptyfunction( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{

}
