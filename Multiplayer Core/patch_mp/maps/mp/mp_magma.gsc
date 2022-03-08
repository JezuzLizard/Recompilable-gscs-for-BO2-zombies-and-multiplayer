// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\mp_magma_fx;
#include maps\mp\_load;
#include maps\mp\mp_magma_amb;
#include maps\mp\_compass;
#include maps\mp\gametypes\_spawning;
#include maps\mp\gametypes\_weaponobjects;

main()
{
    level.levelspawndvars = ::levelspawndvars;
    level.overrideplayerdeathwatchtimer = ::leveloverridetime;
    level thread spawnkilltrigger();
    maps\mp\mp_magma_fx::main();
    precachemodel( "collision_clip_64x64x10" );
    precachemodel( "collision_physics_64x64x10" );
    precachemodel( "collision_physics_256x256x10" );
    precachemodel( "collision_physics_128x128x10" );
    precachemodel( "collision_physics_64x64x10" );
    precachemodel( "p6_mag_k_rail_barrier" );
    precachemodel( "p6_mag_rocks_medium_02" );
    maps\mp\_load::main();
    maps\mp\mp_magma_amb::main();
    maps\mp\_compass::setupminimap( "compass_map_mp_magma" );
    setdvar( "compassmaxrange", "2100" );
    game["strings"]["war_callsign_a"] = &"MPUI_CALLSIGN_MAPNAME_A";
    game["strings"]["war_callsign_b"] = &"MPUI_CALLSIGN_MAPNAME_B";
    game["strings"]["war_callsign_c"] = &"MPUI_CALLSIGN_MAPNAME_C";
    game["strings"]["war_callsign_d"] = &"MPUI_CALLSIGN_MAPNAME_D";
    game["strings"]["war_callsign_e"] = &"MPUI_CALLSIGN_MAPNAME_E";
    game["strings_menu"]["war_callsign_a"] = "@MPUI_CALLSIGN_MAPNAME_A";
    game["strings_menu"]["war_callsign_b"] = "@MPUI_CALLSIGN_MAPNAME_B";
    game["strings_menu"]["war_callsign_c"] = "@MPUI_CALLSIGN_MAPNAME_C";
    game["strings_menu"]["war_callsign_d"] = "@MPUI_CALLSIGN_MAPNAME_D";
    game["strings_menu"]["war_callsign_e"] = "@MPUI_CALLSIGN_MAPNAME_E";
    barrier1 = spawn( "script_model", ( 235.49, 907.91, -395.97 ) );
    barrier1.angles = ( 2.96968, 263.594, -1.33952 );
    barrier2 = spawn( "script_model", ( 245.37, 837.028, -401.885 ) );
    barrier2.angles = ( 6.5989, 268.994, -0.115603 );
    barrier1 setmodel( "p6_mag_k_rail_barrier" );
    barrier2 setmodel( "p6_mag_k_rail_barrier" );
    rock1 = spawn( "script_model", ( 271.92, 893.99, -494 ) );
    rock1.angles = vectorscale( ( 0, 1, 0 ), 132.0 );
    rock2 = spawn( "script_model", ( 393.42, 895.49, -494 ) );
    rock2.angles = vectorscale( ( 0, 1, 0 ), 132.0 );
    rock3 = spawn( "script_model", ( 477.92, 882.49, -509 ) );
    rock3.angles = vectorscale( ( 0, 1, 0 ), 132.0 );
    rock1 setmodel( "p6_mag_rocks_medium_02" );
    rock2 setmodel( "p6_mag_rocks_medium_02" );
    rock3 setmodel( "p6_mag_rocks_medium_02" );
    spawncollision( "collision_clip_64x64x10", "collider", ( 234, 907, -391.5 ), ( 356.785, 83.5728, -83.5116 ) );
    spawncollision( "collision_clip_64x64x10", "collider", ( 243.5, 835.5, -399 ), ( 353.903, 88.8464, -83.1852 ) );
    spawncollision( "collision_clip_64x64x10", "collider", ( 254, 902.5, -395 ), ( 0.42985, 353.514, 3.77564 ) );
    spawncollision( "collision_clip_64x64x10", "collider", ( 264, 835.5, -401.5 ), ( 0.0466956, 359.602, 6.69984 ) );
    spawncollision( "collision_clip_64x64x10", "collider", ( 247.5, 831.5, -363 ), ( 353.903, 88.8464, -83.1852 ) );
    spawncollision( "collision_clip_64x64x10", "collider", ( 237.5, 904.5, -357.5 ), ( 356.785, 83.5728, -83.5116 ) );
    spawncollision( "collision_physics_64x64x10", "collider", ( 234, 907, -391.5 ), ( 356.785, 83.5728, -83.5116 ) );
    spawncollision( "collision_physics_64x64x10", "collider", ( 243.5, 835.5, -399 ), ( 353.903, 88.8464, -83.1852 ) );
    spawncollision( "collision_physics_256x256x10", "collider", ( -459, 357.5, -578.5 ), ( 270, 183.902, 86.0983 ) );
    spawncollision( "collision_physics_128x128x10", "collider", ( -267, 233.5, -514 ), vectorscale( ( 1, 0, 0 ), 270.0 ) );
    spawncollision( "collision_physics_128x128x10", "collider", ( -669.5, 216, -514 ), vectorscale( ( 1, 0, 0 ), 270.0 ) );
    spawncollision( "collision_physics_64x64x10", "collider", ( -748, 95, -483.5 ), ( 270, 270.2, 1.43 ) );
    level.levelkillbrushes = [];
    maps\mp\gametypes\_spawning::level_use_unified_spawning( 1 );
    level.remotemotarviewup = 20;
    registerclientfield( "scriptmover", "police_car_lights", 1, 1, "int" );
    precacheitem( "lava_mp" );
    level thread destructible_lights();
    level.overrideweaponfunc = ::overrideweaponfunc;
    level.deleteonkillbrushoverride = ::deleteonkillbrushoverride;
    level thread lava_trigger_init();
    level.onplayerkilledextraunthreadedcbs[level.onplayerkilledextraunthreadedcbs.size] = ::checkcorpseinlava;
}

lava_trigger_init()
{
    wait 3;
    killbrushes = getentarray( "trigger_hurt", "classname" );

    for ( i = 0; i < killbrushes.size; i++ )
    {
        if ( isdefined( killbrushes[i].script_noteworthy ) && killbrushes[i].script_noteworthy == "lava" )
            level.levelkillbrushes[level.levelkillbrushes.size] = killbrushes[i];
    }
}

levelspawndvars( reset_dvars )
{
    ss = level.spawnsystem;
    ss.enemy_influencer_radius = set_dvar_float_if_unset( "scr_spawn_enemy_influencer_radius", "2600", reset_dvars );
}

overrideweaponfunc( sweapon, script_noteworthy )
{
    if ( isdefined( script_noteworthy ) && script_noteworthy == "lava" )
        sweapon = "lava_mp";

    return sweapon;
}

destructible_lights()
{
    wait 0.05;
    destructibles = getentarray( "destructible", "targetname" );

    foreach ( destructible in destructibles )
    {
        if ( destructible.destructibledef == "veh_t6_dlc_police_car_jp_destructible" )
        {
            destructible thread destructible_think( "police_car_lights" );
            destructible setclientfield( "police_car_lights", 1 );
        }
    }
}

destructible_think( clientfield )
{
    self waittill_any( "death", "destructible_base_piece_death" );
    self setclientfield( clientfield, 0 );
}

checkcorpseinlava( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration )
{
    if ( !isdefined( einflictor ) || !isdefined( einflictor.script_noteworthy ) )
        return;

    if ( einflictor.script_noteworthy != "lava" )
        return;

    if ( !isdefined( self.body ) )
        return;

    playfxontag( level._effect["fx_fire_torso"], self.body, "J_Spine4" );
    playfxontag( level._effect["fx_fire_arm_left"], self.body, "J_Elbow_LE" );
    playfxontag( level._effect["fx_fire_arm_right"], self.body, "J_Elbow_RI" );
    playfxontag( level._effect["fx_fire_leg_left"], self.body, "J_Hip_LE" );
    playfxontag( level._effect["fx_fire_leg_right"], self.body, "J_Hip_RI" );
}

leveloverridetime( defaulttime )
{
    if ( self isinlava() )
        return getdvarfloatdefault( "scr_lavaPlayerDeathWatchTime", 0.5 );

    return defaulttime;
}

isinlava()
{
    if ( !isdefined( self.lastattacker ) || !isdefined( self.lastattacker.script_noteworthy ) )
        return false;

    if ( self.lastattacker.script_noteworthy != "lava" )
        return false;

    return true;
}

testkillbrushonstationary( lavaarray, killbrusharray, player, watcher )
{
    player endon( "disconnect" );
    self endon( "death" );

    self waittill( "stationary" );

    wait 0.1;

    for ( i = 0; i < lavaarray.size; i++ )
    {
        if ( self istouching( lavaarray[i] ) )
        {
            playfx( level._effect["fx_fire_torso"], self.origin );
            watcher maps\mp\gametypes\_weaponobjects::waitanddetonate( self, 0.0, undefined, "lava_mp" );
            return;
        }
    }

    for ( i = 0; i < killbrusharray.size; i++ )
    {
        if ( self istouching( killbrusharray[i] ) )
        {
            if ( self.origin[2] > player.origin[2] )
                break;

            if ( isdefined( self ) )
                self delete();

            return;
        }
    }
}

deleteonkillbrushoverride( player, watcher )
{
    player endon( "disconnect" );
    self endon( "death" );
    self endon( "stationary" );
    trigger_hurtarray = getentarray( "trigger_hurt", "classname" );
    lavaarray = [];
    killbrusharray = [];

    for ( i = 0; i < trigger_hurtarray.size; i++ )
    {
        if ( isdefined( trigger_hurtarray[i].script_noteworthy ) && trigger_hurtarray[i].script_noteworthy == "lava" )
        {
            lavaarray[lavaarray.size] = trigger_hurtarray[i];
            continue;
        }

        killbrusharray[killbrusharray.size] = trigger_hurtarray[i];
    }

    if ( lavaarray.size < 1 )
        return;

    self thread testkillbrushonstationary( lavaarray, killbrusharray, player, watcher );

    while ( true )
    {
        for ( i = 0; i < lavaarray.size; i++ )
        {
            if ( self istouching( lavaarray[i] ) )
            {
                wait 0.05;
                playfx( level._effect["fx_fire_torso"], self.origin );
                watcher maps\mp\gametypes\_weaponobjects::waitanddetonate( self, 0.0, undefined, "lava_mp" );
                return;
            }
        }

        for ( i = 0; i < killbrusharray.size; i++ )
        {
            if ( self istouching( killbrusharray[i] ) )
            {
                if ( self.origin[2] > player.origin[2] )
                    break;

                if ( isdefined( self ) )
                    self delete();

                return;
            }
        }

        wait 0.1;
    }
}

spawnkilltrigger()
{
    trigger = spawn( "trigger_radius", ( 2132, -1692, -708 ), 0, 250, 100 );

    while ( true )
    {
        trigger waittill( "trigger", player );

        player dodamage( player.health * 2, trigger.origin, trigger, trigger, "none", "MOD_SUICIDE", 0, "lava_mp" );
    }
}
