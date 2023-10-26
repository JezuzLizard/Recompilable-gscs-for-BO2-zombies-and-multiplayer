// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes\_weaponobjects;
#include maps\mp\gametypes\_globallogic_audio;
#include maps\mp\_challenges;
#include maps\mp\_scoreevents;
#include maps\mp\_tacticalinsertion;
#include maps\mp\killstreaks\_emp;
#include maps\mp\gametypes\_globallogic_player;
#include maps\mp\gametypes\_damagefeedback;

#using_animtree("mp_trophy_system");

init()
{
    precachemodel( "t6_wpn_trophy_system_world" );
    level.trophylongflashfx = loadfx( "weapon/trophy_system/fx_trophy_flash_lng" );
    level.trophydetonationfx = loadfx( "weapon/trophy_system/fx_trophy_radius_detonation" );
    level._effect["fx_trophy_friendly_light"] = loadfx( "weapon/trophy_system/fx_trophy_light_friendly" );
    level._effect["fx_trophy_enemy_light"] = loadfx( "weapon/trophy_system/fx_trophy_light_enemy" );
    level._effect["fx_trophy_deploy_impact"] = loadfx( "weapon/trophy_system/fx_trophy_deploy_impact" );
    trophydeployanim = %o_trophy_deploy;
    trophyspinanim = %o_trophy_spin;
}

register()
{
    registerclientfield( "missile", "trophy_system_state", 1, 2, "int" );
    registerclientfield( "scriptmover", "trophy_system_state", 1, 2, "int" );
}

createtrophysystemwatcher()
{
    watcher = self maps\mp\gametypes\_weaponobjects::createuseweaponobjectwatcher( "trophy_system", "trophy_system_mp", self.team );
    watcher.detonate = ::trophysystemdetonate;
    watcher.activatesound = "wpn_claymore_alert";
    watcher.hackable = 1;
    watcher.hackertoolradius = level.equipmenthackertoolradius;
    watcher.hackertooltimems = level.equipmenthackertooltimems;
    watcher.reconmodel = "t6_wpn_trophy_system_world_detect";
    watcher.ownergetsassist = 1;
    watcher.ignoredirection = 1;
    watcher.activationdelay = 0.1;
    watcher.headicon = 1;
    watcher.enemydestroy = 1;
    watcher.onspawn = ::ontrophysystemspawn;
    watcher.ondamage = ::watchtrophysystemdamage;
    watcher.ondestroyed = ::ontrophysystemsmashed;
    watcher.stun = ::weaponstun;
    watcher.stuntime = 1;
}

ontrophysystemspawn( watcher, player )
{
    player endon( "death" );
    player endon( "disconnect" );
    level endon( "game_ended" );
    self maps\mp\gametypes\_weaponobjects::onspawnuseweaponobject( watcher, player );
    player addweaponstat( "trophy_system_mp", "used", 1 );
    self.ammo = 2;
    self thread trophyactive( player );
    self thread trophywatchhack();
    self setclientfield( "trophy_system_state", 1 );
    self playloopsound( "wpn_trophy_spin", 0.25 );

    if ( isdefined( watcher.reconmodel ) )
        self thread setreconmodeldeployed();
}

setreconmodeldeployed()
{
    self endon( "death" );

    for (;;)
    {
        if ( isdefined( self.reconmodelentity ) )
        {
            self.reconmodelentity setclientfield( "trophy_system_state", 1 );
            return;
        }

        wait 0.05;
    }
}

trophywatchhack()
{
    self endon( "death" );

    self waittill( "hacked", player );

    wait 0.05;
    self thread trophyactive( player );
}

ontrophysystemsmashed( attacker )
{
    playfx( level._effect["tacticalInsertionFizzle"], self.origin );
    self playsound( "dst_tac_insert_break" );
    self.owner maps\mp\gametypes\_globallogic_audio::leaderdialogonplayer( "equipment_destroyed", "item_destroyed" );

    if ( isdefined( attacker ) && self.owner isenemyplayer( attacker ) )
    {
        attacker maps\mp\_challenges::destroyedequipment();
        maps\mp\_scoreevents::processscoreevent( "destroyed_trophy_system", attacker, self.owner );
    }

    self delete();
}

trophyactive( owner )
{
    owner endon( "disconnect" );
    self endon( "death" );
    self endon( "hacked" );

    while ( true )
    {
        tac_inserts = maps\mp\_tacticalinsertion::gettacticalinsertions();

        if ( level.missileentities.size < 1 && tac_inserts.size < 1 || isdefined( self.disabled ) )
        {
            wait 0.05;
            continue;
        }

        for ( index = 0; index < level.missileentities.size; index++ )
        {
            wait 0.05;
            grenade = level.missileentities[index];

            if ( !isdefined( grenade ) )
                continue;

            if ( grenade == self )
                continue;

            if ( isdefined( grenade.weaponname ) )
            {
                switch ( grenade.weaponname )
                {
                    case "claymore_mp":
                        continue;
                }
            }

            if ( isdefined( grenade.name ) && grenade.name == "tactical_insertion_mp" )
                continue;

            switch ( grenade.model )
            {
                case "t6_wpn_grenade_supply_projectile":
                    continue;
            }

            if ( !isdefined( grenade.owner ) )
                grenade.owner = getmissileowner( grenade );

            if ( isdefined( grenade.owner ) )
            {
                if ( level.teambased )
                {
                    if ( grenade.owner.team == owner.team )
                        continue;
                }
                else if ( grenade.owner == owner )
                    continue;

                grenadedistancesquared = distancesquared( grenade.origin, self.origin );

                if ( grenadedistancesquared < 262144 )
                {
                    if ( bullettracepassed( grenade.origin, self.origin + vectorscale( ( 0, 0, 1 ), 29.0 ), 0, self ) )
                    {
                        playfx( level.trophylongflashfx, self.origin + vectorscale( ( 0, 0, 1 ), 15.0 ), grenade.origin - self.origin, anglestoup( self.angles ) );
                        owner thread projectileexplode( grenade, self );
                        index--;
                        self playsound( "wpn_trophy_alert" );
                        self.ammo--;

                        if ( self.ammo <= 0 )
                            self thread trophysystemdetonate();
                    }
                }
            }
        }

        for ( index = 0; index < tac_inserts.size; index++ )
        {
            wait 0.05;
            tac_insert = tac_inserts[index];

            if ( !isdefined( tac_insert ) )
                continue;

            if ( isdefined( tac_insert.owner ) )
            {
                if ( level.teambased )
                {
                    if ( tac_insert.owner.team == owner.team )
                        continue;
                }
                else if ( tac_insert.owner == owner )
                    continue;

                grenadedistancesquared = distancesquared( tac_insert.origin, self.origin );

                if ( grenadedistancesquared < 262144 )
                {
                    if ( bullettracepassed( tac_insert.origin, self.origin + vectorscale( ( 0, 0, 1 ), 29.0 ), 0, tac_insert ) )
                    {
                        playfx( level.trophylongflashfx, self.origin + vectorscale( ( 0, 0, 1 ), 15.0 ), tac_insert.origin - self.origin, anglestoup( self.angles ) );
                        owner thread trophydestroytacinsert( tac_insert, self );
                        index--;
                        self playsound( "wpn_trophy_alert" );
                        self.ammo--;

                        if ( self.ammo <= 0 )
                            self thread trophysystemdetonate();
                    }
                }
            }
        }
    }
}

projectileexplode( projectile, trophy )
{
    self endon( "death" );
    projposition = projectile.origin;
    playfx( level.trophydetonationfx, projposition );
    projectile delete();
    trophy radiusdamage( projposition, 128, 105, 10, self );
    maps\mp\_scoreevents::processscoreevent( "trophy_defense", self );
    self addplayerstat( "destroy_explosive_with_trophy", 1 );
    self addweaponstat( "trophy_system_mp", "CombatRecordStat", 1 );
}

trophydestroytacinsert( tacinsert, trophy )
{
    self endon( "death" );
    tacpos = tacinsert.origin;
    playfx( level.trophydetonationfx, tacinsert.origin );
    tacinsert thread maps\mp\_tacticalinsertion::tacticalinsertiondestroyedbytrophysystem( self, trophy );
    trophy radiusdamage( tacpos, 128, 105, 10, self );
    maps\mp\_scoreevents::processscoreevent( "trophy_defense", self );
    self addplayerstat( "destroy_explosive_with_trophy", 1 );
    self addweaponstat( "trophy_system_mp", "CombatRecordStat", 1 );
}

trophysystemdetonate( attacker, weaponname )
{
    from_emp = maps\mp\killstreaks\_emp::isempweapon( weaponname );

    if ( !from_emp )
        playfx( level._equipment_explode_fx_lg, self.origin );

    if ( isdefined( attacker ) && self.owner isenemyplayer( attacker ) )
    {
        attacker maps\mp\_challenges::destroyedequipment( weaponname );
        maps\mp\_scoreevents::processscoreevent( "destroyed_trophy_system", attacker, self.owner, weaponname );
    }

    playsoundatposition( "dst_equipment_destroy", self.origin );
    self delete();
}

watchtrophysystemdamage( watcher )
{
    self endon( "death" );
    self endon( "hacked" );
    self setcandamage( 1 );
    damagemax = 20;

    if ( !self maps\mp\_utility::ishacked() )
        self.damagetaken = 0;

    self.maxhealth = 10000;
    self.health = self.maxhealth;
    self setmaxhealth( self.maxhealth );
    attacker = undefined;

    while ( true )
    {
        self waittill( "damage", damage, attacker, direction_vec, point, type, modelname, tagname, partname, weaponname, idflags );

        if ( !isplayer( attacker ) )
            continue;

        if ( level.teambased )
        {
            if ( !level.hardcoremode && self.owner.team == attacker.pers["team"] && self.owner != attacker )
                continue;
        }

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

        if ( type == "MOD_MELEE" )
            self.damagetaken = damagemax;
        else
            self.damagetaken += damage;

        if ( self.damagetaken >= damagemax )
        {
            watcher thread maps\mp\gametypes\_weaponobjects::waitanddetonate( self, 0.05, attacker, weaponname );
            return;
        }
    }
}
