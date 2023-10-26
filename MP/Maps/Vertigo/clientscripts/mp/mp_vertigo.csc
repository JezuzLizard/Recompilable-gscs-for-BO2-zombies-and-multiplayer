// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\_load;
#include clientscripts\mp\mp_vertigo_fx;
#include clientscripts\mp\_audio;
#include clientscripts\mp\mp_vertigo_amb;

main()
{
    level.worldmapx = 0;
    level.worldmapy = 0;
    level.worldlat = 18.9752;
    level.worldlong = 72.8275;
    clientscripts\mp\_load::main();
    clientscripts\mp\mp_vertigo_fx::main();
    thread clientscripts\mp\_audio::audio_init( 0 );
    thread clientscripts\mp\mp_vertigo_amb::main();
    level.onplayerconnect = ::vertigoplayerconnected;
    waitforclient( 0 );
/#
    println( "*** Client : mp_vertigo running..." );
#/
}

vertigoplayerconnected( localclientnum )
{
    for (;;)
    {
        level waittill( "snap_processed", snapshotlocalclientnum );

        if ( snapshotlocalclientnum == localclientnum )
            break;
    }

    security_camera_balls = getentarray( localclientnum, "security_camera_ball", "targetname" );

    foreach ( cameraball in security_camera_balls )
        cameraball thread cameratrackplayer( localclientnum );
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
