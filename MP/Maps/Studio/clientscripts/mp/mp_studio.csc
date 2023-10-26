// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\_load;
#include clientscripts\mp\mp_studio_fx;
#include clientscripts\mp\_audio;
#include clientscripts\mp\mp_studio_amb;

main()
{
    level.worldmapx = 0;
    level.worldmapy = 0;
    level.worldlat = 34.0901;
    level.worldlong = -118.335;
    clientscripts\mp\_load::main();
    clientscripts\mp\mp_studio_fx::main();
    thread clientscripts\mp\_audio::audio_init( 0 );
    thread clientscripts\mp\mp_studio_amb::main();
    setsaveddvar( "r_waterwavespeed", ".528274 .667363 .337185 .172103" );
    setsaveddvar( "r_waterwaveamplitude", "1.5 1.5 1.75 1.65" );
    setsaveddvar( "r_waterwavewavelength", "134.162 113.085 254.753 323.322" );
    setsaveddvar( "r_waterwavesteepness", "1 1 1 1" );
    setsaveddvar( "r_waterwaveangle", "0 130.23 57.3609 128.687" );
    setsaveddvar( "r_waterwavephase", "0 0 0 0" );
    waitforclient( 0 );
    setsaveddvar( "sm_sunsamplesizenear", 0.3 );
/#
    println( "*** Client : mp_studio running..." );
#/
}
