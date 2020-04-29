#include maps/mp/_challenges;
#include maps/mp/_scoreevents;
#include maps/mp/gametypes/_damagefeedback;
#include maps/mp/gametypes/_weapons;
#include maps/mp/_burnplayer;
#include maps/mp/gametypes/_globallogic_utils;
#include maps/mp/gametypes/_globallogic_player;
#include maps/mp/_utility;

callback_actordamage( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, boneindex )
{
	if ( game[ "state" ] == "postgame" )
	{
		return;
	}
	if ( self.aiteam == "spectator" )
	{
		return;
	}
	if ( isDefined( eattacker ) && isplayer( eattacker ) && isDefined( eattacker.candocombat ) && !eattacker.candocombat )
	{
		return;
	}
	self.idflags = idflags;
	self.idflagstime = getTime();
	eattacker = maps/mp/gametypes/_globallogic_player::figureoutattacker( eattacker );
	if ( !isDefined( vdir ) )
	{
		idflags |= level.idflags_no_knockback;
	}
	friendly = 0;
	if ( self.health == self.maxhealth || !isDefined( self.attackers ) )
	{
		self.attackers = [];
		self.attackerdata = [];
		self.attackerdamage = [];
	}
	if ( maps/mp/gametypes/_globallogic_utils::isheadshot( sweapon, shitloc, smeansofdeath, einflictor ) )
	{
		smeansofdeath = "MOD_HEAD_SHOT";
	}
	if ( level.onlyheadshots )
	{
		if ( smeansofdeath == "MOD_PISTOL_BULLET" || smeansofdeath == "MOD_RIFLE_BULLET" )
		{
			return;
		}
		else
		{
			if ( smeansofdeath == "MOD_HEAD_SHOT" )
			{
				idamage = 150;
			}
		}
	}
	if ( smeansofdeath == "MOD_BURNED" )
	{
		if ( sweapon == "none" )
		{
			self maps/mp/_burnplayer::walkedthroughflames();
		}
		if ( sweapon == "m2_flamethrower_mp" )
		{
			self maps/mp/_burnplayer::burnedwithflamethrower();
		}
	}
	if ( sweapon == "none" && isDefined( einflictor ) )
	{
		if ( isDefined( einflictor.targetname ) && einflictor.targetname == "explodable_barrel" )
		{
			sweapon = "explodable_barrel_mp";
		}
		else
		{
			if ( isDefined( einflictor.destructible_type ) && issubstr( einflictor.destructible_type, "vehicle_" ) )
			{
				sweapon = "destructible_car_mp";
			}
		}
	}
	if ( idflags & level.idflags_no_protection )
	{
		if ( isplayer( eattacker ) )
		{
			eattacker.pers[ "participation" ]++;
		}
		prevhealthratio = self.health / self.maxhealth;
		if ( level.teambased && isplayer( eattacker ) && self != eattacker && self.aiteam == eattacker.pers[ "team" ] )
		{
			if ( level.friendlyfire == 0 )
			{
				return;
			}
			else if ( level.friendlyfire == 1 )
			{
				if ( idamage < 1 )
				{
					idamage = 1;
				}
				self.lastdamagewasfromenemy = 0;
				self finishactordamage( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, boneindex );
			}
			else if ( level.friendlyfire == 2 )
			{
				return;
			}
			else
			{
				if ( level.friendlyfire == 3 )
				{
					idamage = int( idamage * 0,5 );
					if ( idamage < 1 )
					{
						idamage = 1;
					}
					self.lastdamagewasfromenemy = 0;
					self finishactordamage( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, boneindex );
				}
			}
			friendly = 1;
		}
		else
		{
			if ( isDefined( eattacker ) && isDefined( self.script_owner ) && eattacker == self.script_owner && !level.hardcoremode )
			{
				return;
			}
			if ( isDefined( eattacker ) && isDefined( self.script_owner ) && isDefined( eattacker.script_owner ) && eattacker.script_owner == self.script_owner )
			{
				return;
			}
			if ( idamage < 1 )
			{
				idamage = 1;
			}
			if ( isDefined( eattacker ) && isplayer( eattacker ) && isDefined( sweapon ) && !issubstr( smeansofdeath, "MOD_MELEE" ) )
			{
				eattacker thread maps/mp/gametypes/_weapons::checkhit( sweapon );
			}
			if ( issubstr( smeansofdeath, "MOD_GRENADE" ) && isDefined( einflictor ) && isDefined( einflictor.iscooked ) )
			{
				self.wascooked = getTime();
			}
			else
			{
				self.wascooked = undefined;
			}
			if ( isDefined( eattacker ) )
			{
				self.lastdamagewasfromenemy = eattacker != self;
			}
			self finishactordamage( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, boneindex );
		}
		if ( isDefined( eattacker ) && eattacker != self )
		{
			if ( sweapon != "artillery_mp" || !isDefined( einflictor ) && !isai( einflictor ) )
			{
				if ( idamage > 0 )
				{
					eattacker thread maps/mp/gametypes/_damagefeedback::updatedamagefeedback( smeansofdeath, einflictor );
				}
			}
		}
	}
/#
	if ( getDvarInt( "g_debugDamage" ) )
	{
		println( "actor:" + self getentitynumber() + " health:" + self.health + " attacker:" + eattacker.clientid + " inflictor is player:" + isplayer( einflictor ) + " damage:" + idamage + " hitLoc:" + shitloc );
#/
	}
	if ( 1 )
	{
		lpselfnum = self getentitynumber();
		lpselfteam = self.aiteam;
		lpattackerteam = "";
		if ( isplayer( eattacker ) )
		{
			lpattacknum = eattacker getentitynumber();
			lpattackguid = eattacker getguid();
			lpattackname = eattacker.name;
			lpattackerteam = eattacker.pers[ "team" ];
		}
		else
		{
			lpattacknum = -1;
			lpattackguid = "";
			lpattackname = "";
			lpattackerteam = "world";
		}
		logprint( "AD;" + lpselfnum + ";" + lpselfteam + ";" + lpattackguid + ";" + lpattacknum + ";" + lpattackerteam + ";" + lpattackname + ";" + sweapon + ";" + idamage + ";" + smeansofdeath + ";" + shitloc + ";" + boneindex + "\n" );
	}
}

callback_actorkilled( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime )
{
	if ( game[ "state" ] == "postgame" )
	{
		return;
	}
	if ( isai( attacker ) && isDefined( attacker.script_owner ) )
	{
		if ( attacker.script_owner.team != self.aiteam )
		{
			attacker = attacker.script_owner;
		}
	}
	if ( attacker.classname == "script_vehicle" && isDefined( attacker.owner ) )
	{
		attacker = attacker.owner;
	}
	if ( isDefined( attacker ) && isplayer( attacker ) )
	{
		if ( !level.teambased || self.aiteam != attacker.pers[ "team" ] )
		{
			level.globalkillstreaksdestroyed++;
			attacker addweaponstat( "dogs_mp", "destroyed", 1 );
			maps/mp/_scoreevents::processscoreevent( "killed_dog", attacker, self, sweapon );
			attacker maps/mp/_challenges::killeddog();
		}
	}
}
