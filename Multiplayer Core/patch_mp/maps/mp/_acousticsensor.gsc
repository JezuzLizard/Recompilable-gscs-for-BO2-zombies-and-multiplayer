// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\gametypes\_weaponobjects;
#include maps\mp\_utility;
#include maps\mp\killstreaks\_emp;
#include maps\mp\_challenges;
#include maps\mp\_scoreevents;
#include maps\mp\gametypes\_globallogic_player;
#include maps\mp\gametypes\_damagefeedback;

init()
{
    level._effect["acousticsensor_enemy_light"] = loadfx( "misc/fx_equip_light_red" );
    level._effect["acousticsensor_friendly_light"] = loadfx( "misc/fx_equip_light_green" );
}

createacousticsensorwatcher()
{
    watcher = self maps\mp\gametypes\_weaponobjects::createuseweaponobjectwatcher( "acoustic_sensor", "acoustic_sensor_mp", self.team );
    watcher.onspawn = ::onspawnacousticsensor;
    watcher.detonate = ::acousticsensordetonate;
    watcher.stun = maps\mp\gametypes\_weaponobjects::weaponstun;
    watcher.stuntime = 5;
    watcher.reconmodel = "t5_weapon_acoustic_sensor_world_detect";
    watcher.hackable = 1;
    watcher.ondamage = ::watchacousticsensordamage;
}

onspawnacousticsensor( watcher, player )
{
    self endon( "death" );
    self thread maps\mp\gametypes\_weaponobjects::onspawnuseweaponobject( watcher, player );
    player.acousticsensor = self;
    self setowner( player );
    self setteam( player.team );
    self.owner = player;
    self playloopsound( "fly_acoustic_sensor_lp" );

    if ( !self maps\mp\_utility::ishacked() )
        player addweaponstat( "acoustic_sensor_mp", "used", 1 );

    self thread watchshutdown( player, self.origin );
}

acousticsensordetonate( attacker, weaponname )
{
    from_emp = maps\mp\killstreaks\_emp::isempweapon( weaponname );

    if ( !from_emp )
        playfx( level._equipment_explode_fx, self.origin );

    if ( isdefined( attacker ) )
    {
        if ( self.owner isenemyplayer( attacker ) )
        {
            attacker maps\mp\_challenges::destroyedequipment( weaponname );
            maps\mp\_scoreevents::processscoreevent( "destroyed_motion_sensor", attacker, self.owner, weaponname );
        }
    }

    playsoundatposition( "dst_equipment_destroy", self.origin );
    self destroyent();
}

destroyent()
{
    self delete();
}

watchshutdown( player, origin )
{
    self waittill_any( "death", "hacked" );

    if ( isdefined( player ) )
        player.acousticsensor = undefined;
}

watchacousticsensordamage( watcher )
{
    self endon( "death" );
    self endon( "hacked" );
    self setcandamage( 1 );
    damagemax = 100;

    if ( !self maps\mp\_utility::ishacked() )
        self.damagetaken = 0;

    while ( true )
    {
        self.maxhealth = 100000;
        self.health = self.maxhealth;

        self waittill( "damage", damage, attacker, direction, point, type, tagname, modelname, partname, weaponname, idflags );

        if ( !isdefined( attacker ) || !isplayer( attacker ) )
            continue;

        if ( level.teambased && attacker.team == self.owner.team && attacker != self.owner )
            continue;

        if ( isdefined( weaponname ) )
        {
            switch ( weaponname )
            {
                case "flash_grenade_mp":
                case "concussion_grenade_mp":
                    if ( watcher.stuntime > 0 )
                        self thread maps\mp\gametypes\_weaponobjects::stunstart( watcher, watcher.stuntime );

                    if ( level.teambased && self.owner.team != attacker.team )
                    {
                        if ( maps\mp\gametypes\_globallogic_player::dodamagefeedback( weaponname, attacker ) )
                            attacker maps\mp\gametypes\_damagefeedback::updatedamagefeedback();
                    }
                    else if ( !level.teambased && self.owner != attacker )
                    {
                        if ( maps\mp\gametypes\_globallogic_player::dodamagefeedback( weaponname, attacker ) )
                            attacker maps\mp\gametypes\_damagefeedback::updatedamagefeedback();
                    }

                    continue;
                case "emp_grenade_mp":
                    damage = damagemax;
                default:
                    if ( maps\mp\gametypes\_globallogic_player::dodamagefeedback( weaponname, attacker ) )
                        attacker maps\mp\gametypes\_damagefeedback::updatedamagefeedback();

                    break;
            }
        }
        else
            weaponname = "";

        if ( isplayer( attacker ) && level.teambased && isdefined( attacker.team ) && self.owner.team == attacker.team && attacker != self.owner )
            continue;

        if ( type == "MOD_MELEE" )
            self.damagetaken = damagemax;
        else
            self.damagetaken += damage;

        if ( self.damagetaken >= damagemax )
        {
            watcher thread maps\mp\gametypes\_weaponobjects::waitanddetonate( self, 0.0, attacker, weaponname );
            return;
        }
    }
}
