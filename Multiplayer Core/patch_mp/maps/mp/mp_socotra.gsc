// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include maps\mp\mp_socotra_fx;
#include maps\mp\_load;
#include maps\mp\_compass;
#include maps\mp\mp_socotra_amb;
#include maps\mp\gametypes\_spawning;

main()
{
    level.levelspawndvars = ::levelspawndvars;
    maps\mp\mp_socotra_fx::main();
    precachemodel( "collision_physics_64x64x64" );
    precachemodel( "collision_physics_32x32x128" );
    precachemodel( "collision_physics_wall_256x256x256" );
    precachemodel( "collision_physics_wall_128x128x10" );
    precachemodel( "collision_clip_128x128x128" );
    precachemodel( "collision_physics_512x512x10" );
    precachemodel( "p6_wood_plank_rustic01_2x12_96" );
    maps\mp\_load::main();
    maps\mp\_compass::setupminimap( "compass_map_mp_socotra" );
    maps\mp\mp_socotra_amb::main();
    setheliheightpatchenabled( "war_mode_heli_height_lock", 0 );
    spawncollision( "collision_physics_64x64x64", "collider", ( -63, -2135, 47 ), ( 0, 0, 0 ) );
    spawncollision( "collision_physics_128x128x128", "collider", ( 1922, -202, 139 ), ( 0, 0, 0 ) );
    spawncollision( "collision_physics_256x256x256", "collider", ( 1826, -263, 25 ), ( 0, 0, 0 ) );
    spawncollision( "collision_physics_256x256x256", "collider", ( 1998, -256, -26 ), vectorscale( ( 0, 1, 0 ), 341.4 ) );
    spawncollision( "collision_physics_wall_128x128x10", "collider", ( -1636, -391, 353 ), vectorscale( ( 0, 1, 0 ), 52.0 ) );
    spawncollision( "collision_physics_128x128x128", "collider", ( 213, 3058, 745 ), vectorscale( ( 0, 1, 0 ), 11.4 ) );
    spawncollision( "collision_physics_128x128x128", "collider", ( 6, 3052, 757 ), vectorscale( ( 0, 1, 0 ), 11.4 ) );
    spawncollision( "collision_physics_128x128x128", "collider", ( 1360, 2049, 498 ), ( 0, 0, 0 ) );
    spawncollision( "collision_physics_wall_128x128x10", "collider", ( 2208, 1940, 1116 ), ( 0, 0, 0 ) );
    spawncollision( "collision_clip_128x128x128", "collider", ( 1586, 192, 81 ), ( 311.643, 43.2677, 5.16974 ) );
    spawncollision( "collision_clip_128x128x128", "collider", ( 1631, 229, 142 ), vectorscale( ( 0, 1, 0 ), 44.4 ) );
    spawncollision( "collision_clip_128x128x128", "collider", ( 1631, 229, 270 ), vectorscale( ( 0, 1, 0 ), 44.4 ) );
    spawncollision( "collision_clip_128x128x128", "collider", ( 1631, 229, 398 ), vectorscale( ( 0, 1, 0 ), 44.4 ) );
    spawncollision( "collision_clip_128x128x128", "collider", ( 1631, 229, 526 ), vectorscale( ( 0, 1, 0 ), 44.4 ) );
    spawncollision( "collision_physics_256x256x256", "collider", ( -819, 2061, 227 ), ( 0, 0, 0 ) );
    spawncollision( "collision_physics_256x256x256", "collider", ( -819, 1804, 227 ), ( 0, 0, 0 ) );
    spawncollision( "collision_physics_512x512x10", "collider", ( -921.363, 1719.01, 26.6748 ), ( 313, 359.6, 13.2 ) );
    spawncollision( "collision_physics_32x32x128", "collider", ( 40, 50, 69 ), ( 303.214, 312.283, 99.131 ) );
    spawncollision( "collision_physics_32x32x128", "collider", ( 146, 224, 89 ), ( 302.856, 333.349, 97.5482 ) );
    spawncollision( "collision_physics_32x32x128", "collider", ( 172, 382, 107 ), ( 302.856, 353.549, 97.5482 ) );
    spawncollision( "collision_physics_32x32x128", "collider", ( 526, -2, 74 ), ( 302.387, 100.157, -69.419 ) );
    spawncollision( "collision_physics_32x32x128", "collider", ( 380, -103, 90 ), ( 286.432, 125.086, -81.861 ) );
    spawncollision( "collision_physics_wall_128x128x10", "collider", ( 640, 1325, 289 ), ( 0, 0, 0 ) );
    roofboard1 = spawn( "script_model", ( -133, 602, 521 ) );
    roofboard1.angles = vectorscale( ( 0, 1, 0 ), 270.0 );
    roofboard1 setmodel( "p6_wood_plank_rustic01_2x12_96" );
    roofboard2 = spawn( "script_model", ( -133, 507, 521 ) );
    roofboard2.angles = vectorscale( ( 0, 1, 0 ), 270.0 );
    roofboard2 setmodel( "p6_wood_plank_rustic01_2x12_96" );
    roofboard3 = spawn( "script_model", ( -133, 412, 521 ) );
    roofboard3.angles = vectorscale( ( 0, 1, 0 ), 270.0 );
    roofboard3 setmodel( "p6_wood_plank_rustic01_2x12_96" );
    roofboard4 = spawn( "script_model", ( -133, 375, 522.5 ) );
    roofboard4.angles = vectorscale( ( 0, 1, 0 ), 270.0 );
    roofboard4 setmodel( "p6_wood_plank_rustic01_2x12_96" );
    spawncollision( "collision_physics_128x128x128", "collider", ( -970, 968.5, 407.5 ), ( 0, 0, 0 ) );
    spawncollision( "collision_physics_128x128x128", "collider", ( -970, 841, 407.5 ), ( 0, 0, 0 ) );
    spawncollision( "collision_physics_128x128x128", "collider", ( -842, 841, 407.5 ), ( 0, 0, 0 ) );
    spawncollision( "collision_physics_128x128x128", "collider", ( -842, 968.5, 407.5 ), ( 0, 0, 0 ) );
    maps\mp\gametypes\_spawning::level_use_unified_spawning( 1 );
    rts_remove();
    level.remotemotarviewleft = 30;
    level.remotemotarviewright = 30;
    level.remotemotarviewup = 18;
}

levelspawndvars( reset_dvars )
{
    ss = level.spawnsystem;
    ss.enemy_influencer_radius = set_dvar_float_if_unset( "scr_spawn_enemy_influencer_radius", "2200", reset_dvars );
}

rts_remove()
{
    rtsfloors = getentarray( "overwatch_floor", "targetname" );

    foreach ( rtsfloor in rtsfloors )
    {
        if ( isdefined( rtsfloor ) )
            rtsfloor delete();
    }
}
