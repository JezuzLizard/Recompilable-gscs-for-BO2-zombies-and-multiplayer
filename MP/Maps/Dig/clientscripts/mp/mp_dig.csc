// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\_load;
#include clientscripts\mp\mp_dig_fx;
#include clientscripts\mp\_audio;
#include clientscripts\mp\mp_dig_amb;

main()
{
    setsaveddvar( "sm_sunsamplesizenear", 0.25 );
    setsaveddvar( "sm_sunshadowsmall", 1 );
    clientscripts\mp\_load::main();
    clientscripts\mp\mp_dig_fx::main();
    thread clientscripts\mp\_audio::audio_init( 0 );
    thread clientscripts\mp\mp_dig_amb::main();
    waitforclient( 0 );
/#
    println( "*** Client : mp_dig running..." );
#/
}
