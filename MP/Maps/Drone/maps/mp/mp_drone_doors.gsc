// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes\_weaponobjects;
#include maps\mp\_tacticalinsertion;

init()
{
    triggers = getentarray( "trigger_multiple", "classname" );

    for ( i = 0; i < 4; i++ )
    {
        door = getent( "drone_door" + i, "targetname" );

        if ( !isdefined( door ) )
            continue;

        right = anglestoforward( door.angles );
        right = vectorscale( right, 116 );
        door.opened = 1;
        door.origin_opened = door.origin;
        door.force_open_time = 0;

        if ( isdefined( door.script_noteworthy ) && door.script_noteworthy == "flip" )
            door.origin_closed = door.origin + right;
        else
            door.origin_closed = door.origin - right;

        door.mins = door getmins();
        door.maxs = door getmaxs();
        door setcandamage( 1 );
        door allowbottargetting( 0 );
        door.triggers = [];

        foreach ( trigger in triggers )
        {
            if ( isdefined( trigger.target ) )
            {
                if ( trigger.target == door.targetname )
                {
                    trigger.mins = trigger getmins();
                    trigger.maxs = trigger getmaxs();
                    door.triggers[door.triggers.size] = trigger;
                }
            }
        }

        door thread door_damage_think();
        door thread door_think( i );
    }
}

door_think( index )
{
    wait( 0.05 * index );
    self door_close();

    for (;;)
    {
        wait 0.25;

        if ( self door_should_open() )
            self door_open();
        else
            self door_close();

        self movement_process();
    }
}

door_should_open()
{
    if ( gettime() < self.force_open_time )
        return true;

    foreach ( trigger in self.triggers )
    {
        if ( trigger trigger_is_occupied() )
            return true;
    }

    return false;
}

door_open()
{
    if ( self.opened )
        return;

    dist = distance( self.origin_opened, self.origin );
    frac = dist / 116;
    time = clamp( frac * 0.5, 0.1, 0.5 );
    self moveto( self.origin_opened, time );
    self playsound( "mpl_drone_door_open" );
    self.opened = 1;
}

door_close()
{
    if ( !self.opened )
        return;

    dist = distance( self.origin_closed, self.origin );
    frac = dist / 116;
    time = clamp( frac * 0.5, 0.1, 0.5 );
    self moveto( self.origin_closed, time );
    self playsound( "mpl_drone_door_close" );
    self.opened = 0;
}

movement_process()
{
    moving = 0;

    if ( self.opened )
    {
        if ( distancesquared( self.origin, self.origin_opened ) > 0.001 )
            moving = 1;
    }
    else if ( distancesquared( self.origin, self.origin_closed ) > 0.001 )
        moving = 1;

    if ( moving )
    {
        entities = gettouchingvolume( self.origin, self.mins, self.maxs );

        foreach ( entity in entities )
        {
            if ( isdefined( entity.classname ) && entity.classname == "grenade" )
            {
                if ( !isdefined( entity.name ) )
                    continue;

                if ( !isdefined( entity.owner ) )
                    continue;

                watcher = entity.owner getwatcherforweapon( entity.name );

                if ( !isdefined( watcher ) )
                    continue;

                watcher thread maps\mp\gametypes\_weaponobjects::waitanddetonate( entity, 0.0, undefined );
            }

            if ( self.opened )
                continue;

            if ( isdefined( entity.classname ) && entity.classname == "auto_turret" )
            {
                if ( !isdefined( entity.damagedtodeath ) || !entity.damagedtodeath )
                    entity domaxdamage( self.origin + ( 0, 0, 1 ), self, self, 0, "MOD_CRUSH" );

                continue;
            }

            if ( isdefined( entity.model ) && entity.model == "t6_wpn_tac_insert_world" )
                entity maps\mp\_tacticalinsertion::destroy_tactical_insertion();
        }
    }
}

trigger_is_occupied()
{
    entities = gettouchingvolume( self.origin, self.mins, self.maxs );

    foreach ( entity in entities )
    {
        if ( isalive( entity ) )
        {
            if ( isplayer( entity ) || isai( entity ) || isvehicle( entity ) )
                return true;
        }
    }

    return false;
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

door_damage_think()
{
    self.maxhealth = 99999;
    self.health = self.maxhealth;

    for (;;)
    {
        self waittill( "damage", damage, attacker, dir, point, mod, model, tag, part, weapon, flags );

        self.maxhealth = 99999;
        self.health = self.maxhealth;

        if ( mod == "MOD_PISTOL_BULLET" || mod == "MOD_RIFLE_BULLET" )
            self.force_open_time = gettime() + 1500;
    }
}
