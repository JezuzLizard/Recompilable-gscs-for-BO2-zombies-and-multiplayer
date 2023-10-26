// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\_load;
#include clientscripts\mp\mp_express_fx;
#include clientscripts\mp\_audio;
#include clientscripts\mp\mp_express_amb;
#include clientscripts\mp\_fx;

main()
{
    level.worldmapx = -75;
    level.worldmapy = 87;
    level.worldlat = 34.0554;
    level.worldlong = -118.235;
    clientscripts\mp\_load::main();
    clientscripts\mp\mp_express_fx::main();
    thread clientscripts\mp\_audio::audio_init( 0 );
    thread clientscripts\mp\mp_express_amb::main();
    registerclientfield( "vehicle", "train_moving", 1, 1, "int", ::train_move, 0 );
    registerclientfield( "scriptmover", "train_moving", 1, 1, "int", ::train_move, 0 );
    setsaveddvar( "compassmaxrange", "2100" );
    setsaveddvar( "sm_sunsamplesizenear", 0.39 );
    setsaveddvar( "sm_sunshadowsmall", 1 );
    waitforclient( 0 );
/#
    println( "*** Client : mp_express running..." );
#/
}

train_move( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname )
{
    self endon( "death" );
    self endon( "entityshutdown" );

    if ( newval )
    {
        self notify( "train_stop" );
        self endon( "train_stop" );
        self thread train_move_think( localclientnum );
        clientobjid = getnextobjid( localclientnum );
        objective_add( localclientnum, clientobjid, "invisible", self.origin, "free" );
        objective_onentity( localclientnum, clientobjid, self, 1, 1, 0 );
        expresssize = getdvarintdefault( "scr_express_size", 45 );
        objective_seticonsize( localclientnum, clientobjid, expresssize );
        objective_setstencil( localclientnum, clientobjid, 1 );
        self thread train_end_think( localclientnum, clientobjid );
        wait 0.1;

        if ( self.type == "vehicle" )
        {
            objective_state( localclientnum, clientobjid, "active" );
            objective_seticon( localclientnum, clientobjid, "compass_train_engine" );
            self thread train_fx_think( 1001, 1011 );
        }
        else if ( self.model == "p6_bullet_train_engine_rev" )
            self thread train_fx_think( 2001, 2011 );
        else
        {
            objective_state( localclientnum, clientobjid, "active" );
            objective_seticon( localclientnum, clientobjid, "compass_train_carriage" );
        }
    }
    else
        self notify( "train_stop" );
}

train_end_think( localclientnum, clientobjid )
{
    self waittill_any( "train_stop", "death", "entityshutdown" );
    objective_delete( localclientnum, clientobjid );
    releaseobjid( localclientnum, clientobjid );
}

train_move_think( localclientnum )
{
    self endon( "train_stop" );
    self endon( "death" );
    self endon( "entityshutdown" );

    for (;;)
    {
        player = getlocalplayer( localclientnum );

        if ( !isdefined( player ) )
        {
            serverwait( localclientnum, 0.05 );
            continue;
        }
        else if ( player getinkillcam( localclientnum ) )
        {
            serverwait( localclientnum, 0.05 );
            continue;
        }

        if ( distancesquared( self.origin, player.origin ) < 262144 )
        {
            playrumbleonposition( localclientnum, "grenade_rumble", self.origin );
            player earthquake( 0.2, 0.25, self.origin, 512 );
            wait 0.05;
            continue;
        }

        serverwait( localclientnum, 0.05 );
    }
}

train_fx_think( id, id_end )
{
    self endon( "train_stop" );
    self endon( "death" );
    self endon( "entityshutdown" );

    for (;;)
    {
        if ( id > id_end )
            return;

        origin = level.createfxexploders[id][0].v["origin"];
        dir = vectornormalize( origin - self.origin );
        forward = anglestoforward( self.angles );
        dot = vectordot( forward, dir );

        if ( dot <= 0 )
        {
            clientscripts\mp\_fx::exploder( id );
            id++;
        }

        wait 0.01;
    }
}
