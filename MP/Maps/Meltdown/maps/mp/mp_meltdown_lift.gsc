// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes\_weaponobjects;
#include maps\mp\_tacticalinsertion;
#include maps\mp\killstreaks\_supplydrop;

init()
{
    precachestring( &"MP_LIFT_OPERATE" );
    precachestring( &"MP_LIFT_COOLDOWN" );
    trigger = getent( "lift_trigger", "targetname" );
    platform = getent( "lift_platform", "targetname" );

    if ( !isdefined( trigger ) || !isdefined( platform ) )
        return;

    trigger enablelinkto();
    trigger linkto( platform );
    part = getent( "lift_part", "targetname" );

    if ( isdefined( part ) )
        part linkto( platform );

    level thread lift_think( trigger, platform );
}

lift_think( trigger, platform )
{
    level waittill( "prematch_over" );

    location = 0;

    for (;;)
    {
        trigger sethintstring( &"MP_LIFT_OPERATE" );

        trigger waittill( "trigger" );

        trigger sethintstring( &"MP_LIFT_COOLDOWN" );

        if ( location == 0 )
        {
            goal = platform.origin + vectorscale( ( 0, 0, 1 ), 128.0 );
            location = 1;
        }
        else
        {
            goal = platform.origin - vectorscale( ( 0, 0, 1 ), 128.0 );
            location = 0;
        }

        platform thread lift_move_think( goal );

        platform waittill( "movedone" );

        if ( location == 1 )
            trigger thread lift_auto_lower_think();

        wait 10;
    }
}

lift_move_think( goal )
{
    self endon( "movedone" );
    timer = 5;
    self moveto( goal, 5 );

    while ( timer >= 0 )
    {
        self destroy_equipment();
        self destroy_tactical_insertions();
        self destroy_supply_crates();
        self destroy_corpses();
        self destroy_stuck_weapons();
        wait 0.5;
        timer -= 0.5;
    }
}

lift_auto_lower_think()
{
    self endon( "trigger" );
    wait 30;
    self notify( "trigger" );
}

destroy_equipment()
{
    grenades = getentarray( "grenade", "classname" );

    for ( i = 0; i < grenades.size; i++ )
    {
        item = grenades[i];

        if ( !isdefined( item.name ) )
            continue;

        if ( !isdefined( item.owner ) )
            continue;

        if ( !isweaponequipment( item.name ) )
            continue;

        if ( !item istouching( self ) )
            continue;

        watcher = item.owner getwatcherforweapon( item.name );

        if ( !isdefined( watcher ) )
            continue;

        watcher thread maps\mp\gametypes\_weaponobjects::waitanddetonate( item, 0.0, undefined );
    }
}

destroy_tactical_insertions()
{
    players = get_players();

    for ( i = 0; i < players.size; i++ )
    {
        player = players[i];

        if ( !isdefined( player.tacticalinsertion ) )
            continue;

        if ( player.tacticalinsertion istouching( self ) )
            player.tacticalinsertion maps\mp\_tacticalinsertion::destroy_tactical_insertion();
    }
}

destroy_supply_crates()
{
    crates = getentarray( "care_package", "script_noteworthy" );

    for ( i = 0; i < crates.size; i++ )
    {
        crate = crates[i];

        if ( crate istouching( self ) )
        {
            playfx( level._supply_drop_explosion_fx, crate.origin );
            playsoundatposition( "wpn_grenade_explode", crate.origin );
            wait 0.1;
            crate maps\mp\killstreaks\_supplydrop::cratedelete();
        }
    }
}

destroy_corpses()
{
    corpses = getcorpsearray();

    for ( i = 0; i < corpses.size; i++ )
    {
        if ( distance2dsquared( corpses[i].origin, self.origin ) < 1048576 )
            corpses[i] delete();
    }
}

destroy_stuck_weapons()
{
    weapons = getentarray( "sticky_weapon", "targetname" );
    origin = self getpointinbounds( 0.0, 0.0, -0.6 );
    z_cutoff = origin[2];

    for ( i = 0; i < weapons.size; i++ )
    {
        weapon = weapons[i];

        if ( weapon istouching( self ) && weapon.origin[2] > z_cutoff )
            weapon delete();
    }
}

getwatcherforweapon( weapname )
{
    if ( !isdefined( self ) )
        return undefined;

    if ( !isplayer( self ) )
        return undefined;

    for ( i = 0; i < self.weaponobjectwatcherarray.size; i++ )
    {
        if ( self.weaponobjectwatcherarray[i].weapon != weapname )
            continue;

        return self.weaponobjectwatcherarray[i];
    }

    return undefined;
}
