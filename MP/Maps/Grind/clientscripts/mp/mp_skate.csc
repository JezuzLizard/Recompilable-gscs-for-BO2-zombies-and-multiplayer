// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\_load;
#include clientscripts\mp\mp_skate_fx;
#include clientscripts\mp\_audio;
#include clientscripts\mp\mp_skate_amb;

main()
{
    level.worldmapx = 0;
    level.worldmapy = 0;
    level.worldlat = 33.9857;
    level.worldlong = -118.474;
    clientscripts\mp\_load::main();
    clientscripts\mp\mp_skate_fx::main();
    thread clientscripts\mp\_audio::audio_init( 0 );
    thread clientscripts\mp\mp_skate_amb::main();
    waitforclient( 0 );
/#
    println( "*** Client : mp_skate running..." );
#/
}
