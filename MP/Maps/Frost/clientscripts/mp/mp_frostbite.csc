// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\_load;
#include clientscripts\mp\mp_frostbite_fx;
#include clientscripts\mp\_audio;
#include clientscripts\mp\mp_frostbite_amb;

main()
{
    clientscripts\mp\_load::main();
    clientscripts\mp\mp_frostbite_fx::main();
    thread clientscripts\mp\_audio::audio_init( 0 );
    thread clientscripts\mp\mp_frostbite_amb::main();
    setdvar( "tu7_cg_deathCamAboveWater", "8" );
    setsaveddvar( "sm_sunshadowsmall", 1 );
    setsaveddvar( "sm_sunsamplesizenear", 0.25 );
    waitforclient( 0 );
/#
    println( "*** Client : mp_frostbite running..." );
#/
}
