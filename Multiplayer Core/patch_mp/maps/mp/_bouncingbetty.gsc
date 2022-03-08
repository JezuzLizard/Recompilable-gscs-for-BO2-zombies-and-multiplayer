// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes\_weaponobjects;
#include maps\mp\_challenges;
#include maps\mp\_scoreevents;

init()
{
    precachemodel( "t6_wpn_bouncing_betty_world" );
    level.bettyexplosionfx = loadfx( "weapon/bouncing_betty/fx_betty_explosion" );
    level.bettydestroyedfx = loadfx( "weapon/bouncing_betty/fx_betty_destroyed" );
    level.bettylaunchfx = loadfx( "weapon/bouncing_betty/fx_betty_launch_dust" );
    level._effect["fx_betty_friendly_light"] = loadfx( "weapon/bouncing_betty/fx_betty_light_green" );
    level._effect["fx_betty_enemy_light"] = loadfx( "weapon/bouncing_betty/fx_betty_light_red" );
    level.bettymindist = 20;
    level.bettygraceperiod = 0.6;
    level.bettyradius = 192;
    level.bettystuntime = 1;
    level.bettydamageradius = 256;
    level.bettydamagemax = 210;
    level.bettydamagemin = 70;
    level.bettyjumpheight = 65;
    level.bettyjumptime = 0.65;
    level.bettyrotatevelocity = ( 0, 750, 32 );
    level.bettyactivationdelay = 0.1;
}

createbouncingbettywatcher()
{
    watcher = self createproximityweaponobjectwatcher( "bouncingbetty", "bouncingbetty_mp", self.team );
    watcher.onspawn = ::onspawnbouncingbetty;
    watcher.watchforfire = 1;
    watcher.detonate = ::bouncingbettydetonate;
    watcher.activatesound = "wpn_claymore_alert";
    watcher.hackable = 1;
    watcher.hackertoolradius = level.equipmenthackertoolradius;
    watcher.hackertooltimems = level.equipmenthackertooltimems;
    watcher.reconmodel = "t6_wpn_bouncing_betty_world_detect";
    watcher.ownergetsassist = 1;
    watcher.ignoredirection = 1;
    watcher.detectionmindist = level.bettymindist;
    watcher.detectiongraceperiod = level.bettygraceperiod;
    watcher.detonateradius = level.bettyradius;
    watcher.stun = ::weaponstun;
    watcher.stuntime = level.bettystuntime;
    watcher.activationdelay = level.bettyactivationdelay;
}

onspawnbouncingbetty( watcher, owner )
{
    onspawnproximityweaponobject( watcher, owner );
    self thread spawnminemover();
}

spawnminemover()
{
    self waittillnotmoving();
    minemover = spawn( "script_model", self.origin );
    minemover.angles = self.angles;
    minemover setmodel( "tag_origin" );
    minemover.owner = self.owner;
    minemover.killcamoffset = ( 0, 0, getdvarfloatdefault( "scr_bouncing_betty_killcam_offset", 8.0 ) );
    killcament = spawn( "script_model", minemover.origin + minemover.killcamoffset );
    killcament.angles = ( 0, 0, 0 );
    killcament setmodel( "tag_origin" );
    killcament setweapon( "bouncingbetty_mp" );
    minemover.killcament = killcament;
    self.minemover = minemover;
    self thread killminemoveronpickup();
}

killminemoveronpickup()
{
    self.minemover endon( "death" );
    self waittill_any( "picked_up", "hacked" );
    self killminemover();
}

killminemover()
{
    if ( isdefined( self.minemover ) )
    {
        if ( isdefined( self.minemover.killcament ) )
            self.minemover.killcament delete();

        self.minemover delete();
    }
}

bouncingbettydetonate( attacker, weaponname )
{
    if ( isdefined( weaponname ) )
    {
        if ( isdefined( attacker ) )
        {
            if ( self.owner isenemyplayer( attacker ) )
            {
                attacker maps\mp\_challenges::destroyedexplosive( weaponname );
                maps\mp\_scoreevents::processscoreevent( "destroyed_bouncingbetty", attacker, self.owner, weaponname );
            }
        }

        self bouncingbettydestroyed();
    }
    else if ( isdefined( self.minemover ) )
    {
        self.minemover setmodel( self.model );
        self.minemover thread bouncingbettyjumpandexplode();
        self delete();
    }
    else
        self bouncingbettydestroyed();
}

bouncingbettydestroyed()
{
    playfx( level.bettydestroyedfx, self.origin );
    playsoundatposition( "dst_equipment_destroy", self.origin );

    if ( isdefined( self.trigger ) )
        self.trigger delete();

    if ( isdefined( self.minemover ) )
    {
        if ( isdefined( self.minemover.killcament ) )
            self.minemover.killcament delete();

        self.minemover delete();
    }

    self radiusdamage( self.origin, 128, 110, 10, self.owner, "MOD_EXPLOSIVE", "bouncingbetty_mp" );
    self delete();
}

bouncingbettyjumpandexplode()
{
    explodepos = self.origin + ( 0, 0, level.bettyjumpheight );
    self moveto( explodepos, level.bettyjumptime, level.bettyjumptime, 0 );
    self.killcament moveto( explodepos + self.killcamoffset, level.bettyjumptime, 0, level.bettyjumptime );
    playfx( level.bettylaunchfx, self.origin );
    self rotatevelocity( level.bettyrotatevelocity, level.bettyjumptime, 0, level.bettyjumptime );
    self playsound( "fly_betty_jump" );
    wait( level.bettyjumptime );
    self thread mineexplode();
}

mineexplode()
{
    if ( !isdefined( self ) || !isdefined( self.owner ) )
        return;

    self playsound( "fly_betty_explo" );
    wait 0.05;

    if ( !isdefined( self ) || !isdefined( self.owner ) )
        return;

    self hide();
    self radiusdamage( self.origin, level.bettydamageradius, level.bettydamagemax, level.bettydamagemin, self.owner, "MOD_EXPLOSIVE", "bouncingbetty_mp" );
    playfx( level.bettyexplosionfx, self.origin );
    wait 0.2;

    if ( !isdefined( self ) || !isdefined( self.owner ) )
        return;

    if ( isdefined( self.trigger ) )
        self.trigger delete();

    self.killcament delete();
    self delete();
}
