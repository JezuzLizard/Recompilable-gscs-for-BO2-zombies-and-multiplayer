//checked includes match cerberus output
#include maps/mp/gametypes/_damagefeedback;
#include maps/mp/gametypes/_globallogic_player;
#include maps/mp/_challenges;
#include maps/mp/killstreaks/_emp;
#include maps/mp/gametypes/_weaponobjects;
#include common_scripts/utility;
#include maps/mp/_utility;

init() //checked matches cerberus output
{
	level._effect[ "scrambler_enemy_light" ] = loadfx( "misc/fx_equip_light_red" );
	level._effect[ "scrambler_friendly_light" ] = loadfx( "misc/fx_equip_light_green" );
	level.scramblerweapon = "scrambler_mp";
	level.scramblerlength = 30;
	level.scramblerouterradiussq = 1000000;
	level.scramblerinnerradiussq = 360000;
}

createscramblerwatcher() //checked matches cerberus output
{
	watcher = self maps/mp/gametypes/_weaponobjects::createuseweaponobjectwatcher( "scrambler", "scrambler_mp", self.team );
	watcher.onspawn = ::onspawnscrambler;
	watcher.detonate = ::scramblerdetonate;
	watcher.stun = ::maps/mp/gametypes/_weaponobjects::weaponstun;
	watcher.stuntime = 5;
	watcher.reconmodel = "t5_weapon_scrambler_world_detect";
	watcher.hackable = 1;
	watcher.ondamage = ::watchscramblerdamage;
}

onspawnscrambler( watcher, player ) //checked matches cerberus output
{
	player endon( "disconnect" );
	self endon( "death" );
	self thread maps/mp/gametypes/_weaponobjects::onspawnuseweaponobject( watcher, player );
	player.scrambler = self;
	self setowner( player );
	self setteam( player.team );
	self.owner = player;
	self setclientflag( 3 );
	if ( !self maps/mp/_utility::ishacked() )
	{
		player addweaponstat( "scrambler_mp", "used", 1 );
	}
	self thread watchshutdown( player );
	level notify( "scrambler_spawn" );
}

scramblerdetonate( attacker, weaponname ) //checked matches cerberus output
{
	from_emp = maps/mp/killstreaks/_emp::isempweapon( weaponname );
	if ( !from_emp )
	{
		playfx( level._equipment_explode_fx, self.origin );
	}
	if ( self.owner isenemyplayer( attacker ) )
	{
		attacker maps/mp/_challenges::destroyedequipment( weaponname );
	}
	playsoundatposition( "dst_equipment_destroy", self.origin );
	self delete();
}

watchshutdown( player ) //checked matches cerberus output
{
	self waittill_any( "death", "hacked" );
	level notify( "scrambler_death" );
	if ( isDefined( player ) )
	{
		player.scrambler = undefined;
	}
}

destroyent() //checked matches cerberus output
{
	self delete();
}

watchscramblerdamage( watcher ) //checked changed to match beta dump
{
	self endon( "death" );
	self endon( "hacked" );
	self setcandamage( 1 );
	damagemax = 100;
	if ( !self maps/mp/_utility::ishacked() )
	{
		self.damagetaken = 0;
	}
	while ( 1 )
	{
		self.maxhealth = 100000;
		self.health = self.maxhealth;
		self waittill( "damage", damage, attacker, direction, point, type, tagname, modelname, partname, weaponname, idflags );
		if ( !isDefined( attacker ) || !isplayer( attacker ) )
		{
			continue;
		}
		if ( level.teambased && attacker.team == self.owner.team && attacker != self.owner )
		{
			continue;
		}
		if ( isDefined( weaponname ) )
		{
			switch( weaponname )
			{
				case "concussion_grenade_mp":
				case "flash_grenade_mp":
					if ( watcher.stuntime > 0 )
					{
						self thread maps/mp/gametypes/_weaponobjects::stunstart( watcher, watcher.stuntime );
					}
					if ( level.teambased && self.owner.team != attacker.team )
					{
						if ( maps/mp/gametypes/_globallogic_player::dodamagefeedback( weaponname, attacker ) )
						{
							attacker maps/mp/gametypes/_damagefeedback::updatedamagefeedback();
						}
					}
					else if ( !level.teambased && self.owner != attacker )
					{
						if ( maps/mp/gametypes/_globallogic_player::dodamagefeedback( weaponname, attacker ) )
						{
							attacker maps/mp/gametypes/_damagefeedback::updatedamagefeedback();
						}
					}
					continue;
				case "emp_grenade_mp":
					damage = damagemax;
				default:
					if ( maps/mp/gametypes/_globallogic_player::dodamagefeedback( weaponname, attacker ) )
					{
						attacker maps/mp/gametypes/_damagefeedback::updatedamagefeedback();
					}
					break;
			}
		}
		else
		{
			weaponname = "";
		}
		if ( isplayer( attacker ) && level.teambased && isDefined( attacker.team ) && self.owner.team == attacker.team && attacker != self.owner )
		{
			continue;
		}
		if ( type == "MOD_MELEE" )
		{
			self.damagetaken = damagemax;
		}
		else
		{
			self.damagetaken += damage;
		}
		if ( self.damagetaken >= damagemax )
		{
			watcher thread maps/mp/gametypes/_weaponobjects::waitanddetonate( self, 0, attacker, weaponname );
		}
	}
}

ownersameteam( owner1, owner2 ) //checked matches cerberus output
{
	if ( !level.teambased )
	{
		return 0;
	}
	if ( !isDefined( owner1 ) || !isDefined( owner2 ) )
	{
		return 0;
	}
	if ( !isDefined( owner1.team ) || !isDefined( owner2.team ) )
	{
		return 0;
	}
	return owner1.team == owner2.team;
}

checkscramblerstun() //checked partially changed to match cerberus output see info.md
{
	scramblers = getentarray( "grenade", "classname" );
	if ( isDefined( self.name ) && self.name == "scrambler_mp" )
	{
		return 0;
	}
	i = 0;
	while ( i < scramblers.size )
	{
		scrambler = scramblers[ i ];
		if ( !isalive( scrambler ) )
		{
			i++;
			continue;
		}
		if ( !isDefined( scrambler.name ) )
		{
			i++;
			continue;
		}
		if ( scrambler.name != "scrambler_mp" )
		{
			i++;
			continue;
		}
		if ( ownersameteam( self.owner, scrambler.owner ) )
		{
			i++;
			continue;
		}
		flattenedselforigin = ( self.origin[ 0 ], self.origin[ 1 ], 0 );
		flattenedscramblerorigin = ( scrambler.origin[ 0 ], scrambler.origin[ 1 ], 0 );
		if ( distancesquared( flattenedselforigin, flattenedscramblerorigin ) < level.scramblerouterradiussq )
		{
			return 1;
		}
		i++;
	}
	return 0;
}

