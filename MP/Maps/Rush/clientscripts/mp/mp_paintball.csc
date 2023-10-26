// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\_load;
#include clientscripts\mp\mp_paintball_fx;
#include clientscripts\mp\_audio;
#include clientscripts\mp\mp_paintball_amb;

main()
{
    level.worldmapx = 0;
    level.worldmapy = 0;
    level.worldlat = 32.1143;
    level.worldlong = -82.9414;
    clientscripts\mp\_load::main();
    clientscripts\mp\mp_paintball_fx::main();
    thread clientscripts\mp\_audio::audio_init( 0 );
    thread clientscripts\mp\mp_paintball_amb::main();
    registerclientfield( "scriptmover", "police_car_lights", 1, 1, "int", ::destructible_car_lights, 0 );
    setsaveddvar( "sm_sunshadowsmall", 1 );
    setsaveddvar( "sm_sunsamplesizenear", 0.35 );
    waitforclient( 0 );
/#
    println( "*** Client : mp_paintball running..." );
#/
}

destructible_car_lights( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
    player = getlocalplayer( localclientnum );

    if ( !isdefined( player ) )
        return;

    if ( player getinkillcam( localclientnum ) )
        return;

    if ( newval )
    {
        wait( randomfloatrange( 0.1, 0.5 ) );

        if ( isdefined( self.fx ) )
        {
            stopfx( localclientnum, self.fx );
            self.fx = undefined;
        }

        if ( fieldname == "police_car_lights" )
            self.fx = playfxontag( localclientnum, level._effect["fx_mp_light_police_car"], self, "tag_origin" );
    }
    else if ( isdefined( self.fx ) )
    {
        stopfx( localclientnum, self.fx );
        self.fx = undefined;
    }
}
