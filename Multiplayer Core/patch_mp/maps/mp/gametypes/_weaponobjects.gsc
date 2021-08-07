//checked includes match cerberus output
#include maps/mp/gametypes/_dev;
#include maps/mp/_vehicles;
#include maps/mp/gametypes/_globallogic_audio;
#include maps/mp/_entityheadicons;
#include maps/mp/gametypes/_damagefeedback;
#include maps/mp/gametypes/_globallogic_player;
#include maps/mp/_scrambler;
#include maps/mp/gametypes/_weaponobjects;
#include maps/mp/_scoreevents;
#include maps/mp/_challenges;
#include maps/mp/killstreaks/_emp;
#include maps/mp/killstreaks/_qrdrone;
#include maps/mp/killstreaks/_rcbomb;
#include maps/mp/_ballistic_knife;
#include maps/mp/_sensor_grenade;
#include maps/mp/_trophy_system;
#include maps/mp/_bouncingbetty;
#include maps/mp/_proximity_grenade;
#include maps/mp/_satchel_charge;
#include maps/mp/gametypes/_hud_util;
#include maps/mp/_utility;
#include common_scripts/utility;

init() //checked matches cerberus output
{
	/*
/#
	debug = weapons_get_dvar_int( "scr_weaponobject_debug", "0" );
#/
	*/
	coneangle = weapons_get_dvar_int( "scr_weaponobject_coneangle", "70" );
	mindist = weapons_get_dvar_int( "scr_weaponobject_mindist", "20" );
	graceperiod = weapons_get_dvar( "scr_weaponobject_graceperiod", "0.6" );
	radius = weapons_get_dvar_int( "scr_weaponobject_radius", "192" );
	level thread onplayerconnect();
	level.watcherweapons = [];
	level.watcherweapons = getwatcherweapons();
	level.watcherweaponnames = [];
	level.watcherweaponnames = getwatchernames( level.watcherweapons );
	level.retrievableweapons = [];
	level.retrievableweapons = getretrievableweapons();
	level.retrievableweaponnames = [];
	level.retrievableweaponnames = getwatchernames( level.retrievableweapons );
	level.weaponobjects_headicon_offset = [];
	level.weaponobjects_headicon_offset[ "default" ] = vectorScale( ( 0, 0, 1 ), 20 );
	level.weaponobjectexplodethisframe = 0;
	if ( getDvar( "scr_deleteexplosivesonspawn" ) == "" )
	{
		setdvar( "scr_deleteexplosivesonspawn", 1 );
	}
	level.deleteexplosivesonspawn = getDvarInt( "scr_deleteexplosivesonspawn" );
	if ( sessionmodeiszombiesgame() )
	{
		return;
	}
	precachestring( &"MP_DEFUSING_EXPLOSIVE" );
	level.claymorefxid = loadfx( "weapon/claymore/fx_claymore_laser" );
	level._equipment_spark_fx = loadfx( "weapon/grenade/fx_spark_disabled_weapon" );
	level._equipment_emp_destroy_fx = loadfx( "weapon/emp/fx_emp_explosion_equip" );
	level._equipment_explode_fx = loadfx( "explosions/fx_exp_equipment" );
	level._equipment_explode_fx_lg = loadfx( "explosions/fx_exp_equipment_lg" );
	level._effect[ "powerLight" ] = loadfx( "weapon/crossbow/fx_trail_crossbow_blink_red_os" );
	setupretrievablehintstrings();
	level.weaponobjects_headicon_offset[ "acoustic_sensor_mp" ] = vectorScale( ( 0, 0, 1 ), 25 );
	level.weaponobjects_headicon_offset[ "sensor_grenade_mp" ] = vectorScale( ( 0, 0, 1 ), 25 );
	level.weaponobjects_headicon_offset[ "camera_spike_mp" ] = vectorScale( ( 0, 0, 1 ), 35 );
	level.weaponobjects_headicon_offset[ "claymore_mp" ] = vectorScale( ( 0, 0, 1 ), 20 );
	level.weaponobjects_headicon_offset[ "bouncingbetty_mp" ] = vectorScale( ( 0, 0, 1 ), 20 );
	level.weaponobjects_headicon_offset[ "satchel_charge_mp" ] = vectorScale( ( 0, 0, 1 ), 10 );
	level.weaponobjects_headicon_offset[ "scrambler_mp" ] = vectorScale( ( 0, 0, 1 ), 20 );
	level.weaponobjects_headicon_offset[ "trophy_system_mp" ] = vectorScale( ( 0, 0, 1 ), 35 );
	level.weaponobjects_hacker_trigger_width = 32;
	level.weaponobjects_hacker_trigger_height = 32;
}

getwatchernames( weapons ) //checked changed to match cerberus output
{
	names = [];
	foreach ( weapon in weapons )
	{
		names[ index ] = getsubstr( weapon, 0, weapon.size - 3 );
	}
	return names;
}

weapons_get_dvar_int( dvar, def ) //checked matches cerberus output
{
	return int( weapons_get_dvar( dvar, def ) );
}

weapons_get_dvar( dvar, def ) //checked matches cerberus output
{
	if ( getDvar( dvar ) != "" )
	{
		return getDvarFloat( dvar );
	}
	else
	{
		setdvar( dvar, def );
		return def;
	}
}

setupretrievablehintstrings() //checked matches cerberus output
{
	createretrievablehint( "hatchet", &"MP_HATCHET_PICKUP" );
	createretrievablehint( "claymore", &"MP_CLAYMORE_PICKUP" );
	createretrievablehint( "bouncingbetty", &"MP_BOUNCINGBETTY_PICKUP" );
	createretrievablehint( "trophy_system", &"MP_TROPHY_SYSTEM_PICKUP" );
	createretrievablehint( "acoustic_sensor", &"MP_ACOUSTIC_SENSOR_PICKUP" );
	createretrievablehint( "camera_spike", &"MP_CAMERA_SPIKE_PICKUP" );
	createretrievablehint( "satchel_charge", &"MP_SATCHEL_CHARGE_PICKUP" );
	createretrievablehint( "scrambler", &"MP_SCRAMBLER_PICKUP" );
	createretrievablehint( "proximity_grenade", &"MP_SHOCK_CHARGE_PICKUP" );
	createdestroyhint( "trophy_system", &"MP_TROPHY_SYSTEM_DESTROY" );
	createdestroyhint( "sensor_grenade", &"MP_SENSOR_GRENADE_DESTROY" );
	createhackerhint( "claymore_mp", &"MP_CLAYMORE_HACKING" );
	createhackerhint( "bouncingbetty_mp", &"MP_BOUNCINGBETTY_HACKING" );
	createhackerhint( "trophy_system_mp", &"MP_TROPHY_SYSTEM_HACKING" );
	createhackerhint( "acoustic_sensor_mp", &"MP_ACOUSTIC_SENSOR_HACKING" );
	createhackerhint( "camera_spike_mp", &"MP_CAMERA_SPIKE_HACKING" );
	createhackerhint( "satchel_charge_mp", &"MP_SATCHEL_CHARGE_HACKING" );
	createhackerhint( "scrambler_mp", &"MP_SCRAMBLER_HACKING" );
}

onplayerconnect() //checked matches cerberus output
{
	if ( isDefined( level._weaponobjects_on_player_connect_override ) )
	{
		level thread [[ level._weaponobjects_on_player_connect_override ]]();
		return;
	}
	for ( ;; )
	{
		level waittill( "connecting", player );
		player.usedweapons = 0;
		player.hits = 0;
		player thread onplayerspawned();
	}
}

onplayerspawned() //checked matches cerberus output
{
	self endon( "disconnect" );
	for ( ;; )
	{
		self waittill( "spawned_player" );
		pixbeginevent( "onPlayerSpawned" );
		if ( !isDefined( self.watchersinitialized ) )
		{
			self createbasewatchers();
			self maps/mp/_satchel_charge::createsatchelwatcher();
			self maps/mp/_proximity_grenade::createproximitygrenadewatcher();
			self maps/mp/_bouncingbetty::createbouncingbettywatcher();
			self maps/mp/_trophy_system::createtrophysystemwatcher();
			self maps/mp/_sensor_grenade::createsensorgrenadewatcher();
			self createclaymorewatcher();
			self creatercbombwatcher();
			self createqrdronewatcher();
			self createplayerhelicopterwatcher();
			self createballisticknifewatcher();
			self createhatchetwatcher();
			self createtactinsertwatcher();
			self setupretrievablewatcher();
			self thread watchweaponobjectusage();
			self.watchersinitialized = 1;
		}
		self resetwatchers();
		pixendevent();
	}
}

resetwatchers() //checked changed to match cerberus output
{
	if ( !isDefined( self.weaponobjectwatcherarray ) )
	{
		return undefined;
	}
	team = self.team;
	foreach ( watcher in self.weaponobjectwatcherarray )
	{
		resetweaponobjectwatcher( watcher, team );
	}
}

createbasewatchers() //checked changed to match cerberus output
{
	foreach ( weapon in level.watcherweapons )
	{
		self createweaponobjectwatcher( level.watcherweaponnames[ index ], weapon, self.team );
	}
	foreach ( weapon in level.retrievableweapons )
	{
		self createweaponobjectwatcher( level.retrievableweaponnames[ index ], weapon, self.team );
	}
}

setupretrievablewatcher() //checked changed to match cerberus output
{
	for ( i = 0; i < level.retrievableweapons.size; i++ )
	{
		watcher = getweaponobjectwatcherbyweapon( level.retrievableweapons[ i ] );
		if ( !isDefined( watcher.onspawnretrievetriggers ) )
		{
			watcher.onspawnretrievetriggers = ::onspawnretrievableweaponobject;
		}
		if ( !isDefined( watcher.ondestroyed ) )
		{
			watcher.ondestroyed = ::ondestroyed;
		}
		if ( !isDefined( watcher.pickup ) )
		{
			watcher.pickup = ::pickup;
		}
	}
}

createballisticknifewatcher() //checked matches cerberus output
{
	watcher = self createuseweaponobjectwatcher( "knife_ballistic", "knife_ballistic_mp", self.team );
	watcher.onspawn = maps/mp/_ballistic_knife::onspawn;
	watcher.detonate = ::deleteent;
	watcher.onspawnretrievetriggers = maps/mp/_ballistic_knife::onspawnretrievetrigger;
	watcher.storedifferentobject = 1;
}

createhatchetwatcher() //checked matches cerberus output
{
	watcher = self createuseweaponobjectwatcher( "hatchet", "hatchet_mp", self.team );
	watcher.detonate = ::deleteent;
	watcher.onspawn = ::voidonspawn;
	watcher.ondamage = ::voidondamage;
	watcher.onspawnretrievetriggers = ::onspawnhatchettrigger;
}

createtactinsertwatcher() //checked matches cerberus output
{
	watcher = self createuseweaponobjectwatcher( "tactical_insertion", "tactical_insertion_mp", self.team );
	watcher.playdestroyeddialog = 0;
}

creatercbombwatcher() //checked matches cerberus output
{
	watcher = self createuseweaponobjectwatcher( "rcbomb", "rcbomb_mp", self.team );
	watcher.altdetonate = 0;
	watcher.headicon = 0;
	watcher.ismovable = 1;
	watcher.ownergetsassist = 1;
	watcher.playdestroyeddialog = 0;
	watcher.deleteonkillbrush = 0;
	watcher.detonate = maps/mp/killstreaks/_rcbomb::blowup;
	watcher.stuntime = 1;
}

createqrdronewatcher() //checked matches cerberus output
{
	watcher = self createuseweaponobjectwatcher( "qrdrone", "qrdrone_turret_mp", self.team );
	watcher.altdetonate = 0;
	watcher.headicon = 0;
	watcher.ismovable = 1;
	watcher.ownergetsassist = 1;
	watcher.playdestroyeddialog = 0;
	watcher.deleteonkillbrush = 0;
	watcher.detonate = maps/mp/killstreaks/_qrdrone::qrdrone_blowup;
	watcher.ondamage = maps/mp/killstreaks/_qrdrone::qrdrone_damagewatcher;
	watcher.stuntime = 5;
}

createplayerhelicopterwatcher() //checked matches cerberus output
{
	watcher = self createuseweaponobjectwatcher( "helicopter_player", "helicopter_player_mp", self.team );
	watcher.altdetonate = 1;
	watcher.headicon = 0;
}

createclaymorewatcher() //checked matches cerberus output
{
	watcher = self createproximityweaponobjectwatcher( "claymore", "claymore_mp", self.team );
	watcher.watchforfire = 1;
	watcher.detonate = ::claymoredetonate;
	watcher.activatesound = "wpn_claymore_alert";
	watcher.hackable = 1;
	watcher.hackertoolradius = level.equipmenthackertoolradius;
	watcher.hackertooltimems = level.equipmenthackertooltimems;
	watcher.reconmodel = "t6_wpn_claymore_world_detect";
	watcher.ownergetsassist = 1;
	detectionconeangle = weapons_get_dvar_int( "scr_weaponobject_coneangle" );
	watcher.detectiondot = cos( detectionconeangle );
	watcher.detectionmindist = weapons_get_dvar_int( "scr_weaponobject_mindist" );
	watcher.detectiongraceperiod = weapons_get_dvar( "scr_weaponobject_graceperiod" );
	watcher.detonateradius = weapons_get_dvar_int( "scr_weaponobject_radius" );
	watcher.stun = ::weaponstun;
	watcher.stuntime = 1;
}

waittillnotmoving_and_notstunned() //checked changed to match cerberus output
{
	prevorigin = self.origin;
	while ( 1 )
	{
		wait 0.15;
		if ( self.origin == prevorigin && !self isstunned() )
		{
			break;
		}
		prevorigin = self.origin;
	}
}

voidonspawn( unused0, unused1 ) //checked matches cerberus output
{
}

voidondamage( unused0 ) //checked matches cerberus output
{
}

deleteent( attacker, emp ) //checked matches cerberus output
{
	self delete();
}

clearfxondeath( fx ) //checked matches cerberus output
{
	fx endon( "death" );
	self waittill_any( "death", "hacked" );
	fx delete();
}

deleteweaponobjectarray() //checked changed to match cerberus output
{
	if ( isDefined( self.objectarray ) )
	{
		for ( i = 0; i < self.objectarray.size; i++ )
		{
			if ( isDefined( self.objectarray[ i ] ) )
			{
				if ( isDefined( self.objectarray[ i ].minemover ) )
				{
					if ( isDefined( self.objectarray[ i ].minemover.killcament ) )
					{
						self.objectarray[ i ].minemover.killcament delete();
					}
					self.objectarray[ i ].minemover delete();
				}
				self.objectarray[ i ] delete();
			}
		}
	}
	self.objectarray = [];
}

claymoredetonate( attacker, weaponname ) //checked matches cerberus output
{
	from_emp = maps/mp/killstreaks/_emp::isempkillstreakweapon( weaponname );
	if ( !isDefined( from_emp ) || !from_emp )
	{
		if ( isDefined( attacker ) )
		{
			if ( self.owner isenemyplayer( attacker ) )
			{
				attacker maps/mp/_challenges::destroyedexplosive( weaponname );
				maps/mp/_scoreevents::processscoreevent( "destroyed_claymore", attacker, self.owner, weaponname );
			}
		}
	}
	maps/mp/gametypes/_weaponobjects::weapondetonate( attacker, weaponname );
}

weapondetonate( attacker, weaponname ) //checked matches cerberus output
{
	from_emp = maps/mp/killstreaks/_emp::isempweapon( weaponname );
	if ( from_emp )
	{
		self delete();
		return;
	}
	if ( isDefined( attacker ) )
	{
		if ( isDefined( self.owner ) && attacker != self.owner )
		{
			self.playdialog = 1;
		}
		if ( isplayer( attacker ) )
		{
			self detonate( attacker );
		}
		else
		{
			self detonate();
		}
	}
	else if ( isDefined( self.owner ) && isplayer( self.owner ) )
	{
		self.playdialog = 0;
		self detonate( self.owner );
	}
	else
	{
		self detonate();
	}
}

waitanddetonate( object, delay, attacker, weaponname ) //checked changed to match cerberus output
{
	object endon( "death" );
	object endon( "hacked" );
	from_emp = maps/mp/killstreaks/_emp::isempweapon( weaponname );
	if ( from_emp && !( isDefined( object.name ) && object.name == "qrdrone_turret_mp" ) )
	{
		object setclientflag( 15 );
		object setclientflag( 9 );
		object.stun_fx = 1;
		playfx( level._equipment_emp_destroy_fx, object.origin + vectorScale( ( 0, 0, 1 ), 5 ), ( 0, randomfloat( 360 ), 0 ) );
		delay = 1.1;
	}
	if ( delay )
	{
		wait delay;
	}
	if ( isDefined( object.detonated ) && object.detonated == 1 )
	{
		return;
	}
	if ( !isDefined( self.detonate ) )
	{
		return;
	}
	if ( isDefined( attacker ) && isplayer( attacker ) && isDefined( attacker.pers[ "team" ] ) && isDefined( object.owner ) && isDefined( object.owner.pers[ "team" ] ) )
	{
		if ( level.teambased )
		{
			if ( attacker.pers[ "team" ] != object.owner.pers[ "team" ] )
			{
				attacker notify( "destroyed_explosive" );
			}
		}
		else if ( attacker != object.owner )
		{
			attacker notify( "destroyed_explosive" );
		}
	}
	object.detonated = 1;
	object [[ self.detonate ]]( attacker, weaponname );
}

detonateweaponobjectarray( forcedetonation, weapon ) //checked partially changed to match cerberus output see info.md
{
	undetonated = [];
	if ( isDefined( self.objectarray ) )
	{
		i = 0;
		while ( i < self.objectarray.size )
		{
			if ( isDefined( self.objectarray[ i ] ) )
			{
				if ( self.objectarray[ i ] isstunned() && forcedetonation == 0 )
				{
					undetonated[ undetonated.size ] = self.objectarray[ i ];
					i++;
					continue;
				}
				if ( isDefined( weapon ) )
				{
					if ( weapon ishacked() && weapon.name != self.objectarray[ i ].name )
					{
						undetonated[ undetonated.size ] = self.objectarray[ i ];
						i++;
						continue;
					}
					else if ( self.objectarray[ i ] ishacked() && weapon.name != self.objectarray[ i ].name )
					{
						undetonated[ undetonated.size ] = self.objectarray[ i ];
						i++;
						continue;
					}
				}
				self thread waitanddetonate( self.objectarray[ i ], 0,1, undefined, weapon );
			}
			i++;
		}
	}
	self.objectarray = undetonated;
}

addweaponobjecttowatcher( watchername, weapon ) //checked matches cerberus output
{
	watcher = getweaponobjectwatcher( watchername );
	/*
/#
	assert( isDefined( watcher ), "Weapon object watcher " + watchername + " does not exist" );
#/
	*/
	self addweaponobject( watcher, weapon );
}

addweaponobject( watcher, weapon ) //checked matches cerberus output
{
	if ( !isDefined( watcher.storedifferentobject ) )
	{
		watcher.objectarray[ watcher.objectarray.size ] = weapon;
	}
	weapon.owner = self;
	weapon.detonated = 0;
	weapon.name = watcher.weapon;
	if ( isDefined( watcher.ondamage ) )
	{
		weapon thread [[ watcher.ondamage ]]( watcher );
	}
	else
	{
		weapon thread weaponobjectdamage( watcher );
	}
	weapon.ownergetsassist = watcher.ownergetsassist;
	if ( isDefined( watcher.onspawn ) )
	{
		weapon thread [[ watcher.onspawn ]]( watcher, self );
	}
	if ( isDefined( watcher.onspawnfx ) )
	{
		weapon thread [[ watcher.onspawnfx ]]();
	}
	if ( isDefined( watcher.reconmodel ) )
	{
		weapon thread attachreconmodel( watcher.reconmodel, self );
	}
	if ( isDefined( watcher.onspawnretrievetriggers ) )
	{
		weapon thread [[ watcher.onspawnretrievetriggers ]]( watcher, self );
	}
	if ( watcher.hackable )
	{
		weapon thread hackerinit( watcher );
	}
	if ( isDefined( watcher.stun ) )
	{
		weapon thread watchscramble( watcher );
	}
	if ( watcher.playdestroyeddialog )
	{
		weapon thread playdialogondeath( self );
		weapon thread watchobjectdamage( self );
	}
	if ( watcher.deleteonkillbrush )
	{
		if ( isDefined( level.deleteonkillbrushoverride ) )
		{
			weapon thread [[ level.deleteonkillbrushoverride ]]( self, watcher );
			return;
		}
		else
		{
			weapon thread deleteonkillbrush( self );
		}
	}
}

watchscramble( watcher ) //checked changed to match beta dump
{
	self endon( "death" );
	self endon( "hacked" );
	self waittillnotmoving();
	if ( self maps/mp/_scrambler::checkscramblerstun() )
	{
		self thread stunstart( watcher );
	}
	else
	{
		self stunstop();
	}
	for ( ;; )
	{
		level waittill_any( "scrambler_spawn", "scrambler_death", "hacked" );
		if ( isDefined( self.owner ) && self.owner isempjammed() )
		{
			continue;
		}
		if ( self maps/mp/_scrambler::checkscramblerstun() )
		{
			self thread stunstart( watcher );
		}
		else
		{
			self stunstop();
		}
	}
}

deleteweaponobjecthelper( weapon_ent ) //checked matches cerberus output
{
	if ( !isDefined( weapon_ent.name ) )
	{
		return;
	}
	watcher = self getweaponobjectwatcherbyweapon( weapon_ent.name );
	if ( !isDefined( watcher ) )
	{
		return;
	}
	watcher.objectarray = deleteweaponobject( watcher, weapon_ent );
}

deleteweaponobject( watcher, weapon_ent ) //checked partially changed to match cerberus output see info.md
{
	temp_objectarray = watcher.objectarray;
	watcher.objectarray = [];
	j = 0;
	i = 0;
	while ( i < temp_objectarray.size )
	{
		if ( !isDefined( temp_objectarray[ i ] ) || temp_objectarray[ i ] == weapon_ent )
		{
			i++;
			continue;
		}
		watcher.objectarray[ j ] = temp_objectarray[ i ];
		j++;
		i++;
	}
	return watcher.objectarray;
}

weaponobjectdamage( watcher ) //checked changed to match cerberus output
{
	self endon( "death" );
	self endon( "hacked" );
	self setcandamage( 1 );
	self.maxhealth = 100000;
	self.health = self.maxhealth;
	attacker = undefined;
	for ( ;; )
	{
		while ( 1 )
		{
			self waittill( "damage", damage, attacker, direction_vec, point, type, modelname, tagname, partname, weaponname, idflags );
			if ( isDefined( weaponname ) )
			{
				switch( weaponname )
				{
					case "concussion_grenade_mp":
					case "flash_grenade_mp":
					case "proximity_grenade_mp":
						if ( watcher.stuntime > 0 )
						{
							self thread stunstart( watcher, watcher.stuntime );
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
					case "willy_pete_mp":
						continue;
					case "emp_grenade_mp":
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
						break;
					default:
						break;
				}
				if ( !isplayer( attacker ) && isDefined( attacker.owner ) )
				{
					attacker = attacker.owner;
				}
				if ( level.teambased && isplayer( attacker ) )
				{
					if ( !level.hardcoremode && self.owner.team == attacker.pers[ "team" ] && self.owner != attacker )
					{
						continue;
					}
				}
				if ( maps/mp/gametypes/_globallogic_player::dodamagefeedback( weaponname, attacker ) )
				{
					attacker maps/mp/gametypes/_damagefeedback::updatedamagefeedback();
				}
				if ( !isvehicle( self ) && !friendlyfirecheck( self.owner, attacker ) )
				{
					continue;
				}
				break;
			}
			if ( level.weaponobjectexplodethisframe )
			{
				wait ( 0.1 + randomfloat( 0.4 ) );
			}
			else
			{
				wait 0.05;
			}
			if ( !isDefined( self ) )
			{
				return;
			}
			level.weaponobjectexplodethisframe = 1;
			thread resetweaponobjectexplodethisframe();
			self maps/mp/_entityheadicons::setentityheadicon( "none" );
			if ( ( issubstr( type, "MOD_GRENADE_SPLASH" ) || issubstr( type, "MOD_GRENADE" ) ) && isDefined( type ) || isDefined( type ) && issubstr( type, "MOD_EXPLOSIVE" ) )
			{
				self.waschained = 1;
			}
			if ( is_true( idflags ) & level.idflags_penetration )
			{
				self.wasdamagedfrombulletpenetration = 1;
			}
			self.wasdamaged = 1;
			watcher thread waitanddetonate( self, 0, attacker, weaponname );
		}
	}
}

playdialogondeath( owner ) //checked matches cerberus output
{
	owner endon( "death" );
	owner endon( "disconnect" );
	self endon( "hacked" );
	self waittill( "death" );
	if ( is_true( self.playdialog ) )
	{
		owner maps/mp/gametypes/_globallogic_audio::leaderdialogonplayer( "equipment_destroyed", "item_destroyed" );
	}
}

watchobjectdamage( owner ) //checked changed to match cerberus output
{
	owner endon( "death" );
	owner endon( "disconnect" );
	self endon( "hacked" );
	self endon( "death" );
	while ( 1 )
	{
		self waittill( "damage", damage, attacker );
		if ( isDefined( attacker ) && isplayer( attacker ) && attacker != owner )
		{
			self.playdialog = 1;
		}
		else
		{
			self.playdialog = 0;
		}
	}
}

stunstart( watcher, time ) //checked matches cerberus output
{
	self endon( "death" );
	if ( self isstunned() )
	{
		return;
	}
	if ( isDefined( self.camerahead ) )
	{
		self.camerahead setclientflag( 9 );
	}
	self setclientflag( 9 );
	if ( isDefined( watcher.stun ) )
	{
		self thread [[ watcher.stun ]]();
	}
	if ( watcher.name == "rcbomb" )
	{
		self.owner freezecontrolswrapper( 1 );
	}
	if ( isDefined( time ) )
	{
		wait time;
	}
	else
	{
		return;
	}
	if ( watcher.name == "rcbomb" )
	{
		self.owner freezecontrolswrapper( 0 );
	}
	self stunstop();
}

stunstop() //checked matches cerberus output
{
	self notify( "not_stunned" );
	if ( isDefined( self.camerahead ) )
	{
		self.camerahead clearclientflag( 9 );
	}
	self clearclientflag( 9 );
}

weaponstun() //checked matches cerberus output
{
	self endon( "death" );
	self endon( "not_stunned" );
	origin = self gettagorigin( "tag_fx" );
	if ( !isDefined( origin ) )
	{
		origin = self.origin + vectorScale( ( 0, 0, 1 ), 10 );
	}
	self.stun_fx = spawn( "script_model", origin );
	self.stun_fx setmodel( "tag_origin" );
	self thread stunfxthink( self.stun_fx );
	wait 0.1;
	playfxontag( level._equipment_spark_fx, self.stun_fx, "tag_origin" );
	self.stun_fx playsound( "dst_disable_spark" );
}

stunfxthink( fx ) //checked matches cerberus output
{
	fx endon( "death" );
	self waittill_any( "death", "not_stunned" );
	fx delete();
}

isstunned() //checked matches cerberus output
{
	return isDefined( self.stun_fx );
}

resetweaponobjectexplodethisframe() //checked matches cerberus output
{
	wait 0.05;
	level.weaponobjectexplodethisframe = 0;
}

getweaponobjectwatcher( name ) //checked changed to match cerberus output
{
	if ( !isDefined( self.weaponobjectwatcherarray ) )
	{
		return undefined;
	}
	for ( watcher = 0; watcher < self.weaponobjectwatcherarray.size; watcher++ )
	{
		if ( self.weaponobjectwatcherarray[ watcher ].name == name )
		{
			return self.weaponobjectwatcherarray[ watcher ];
		}
	}
	return undefined;
}

getweaponobjectwatcherbyweapon( weapon ) //checked changed to match cerberus output
{
	if ( !isDefined( self.weaponobjectwatcherarray ) )
	{
		return undefined;
	}
	for ( watcher = 0; watcher < self.weaponobjectwatcherarray.size; watcher++ ) 
	{
		if ( isDefined( self.weaponobjectwatcherarray[ watcher ].weapon ) && self.weaponobjectwatcherarray[ watcher ].weapon == weapon )
		{
			return self.weaponobjectwatcherarray[ watcher ];
		}
		if ( isDefined( self.weaponobjectwatcherarray[ watcher ].weapon ) && isDefined( self.weaponobjectwatcherarray[ watcher ].altweapon ) && self.weaponobjectwatcherarray[ watcher ].altweapon == weapon )
		{
			return self.weaponobjectwatcherarray[ watcher ];
		}
	}
	return undefined;
}

resetweaponobjectwatcher( watcher, ownerteam ) //checked matches cerberus output
{
	if ( level.deleteexplosivesonspawn == 1 )
	{
		self notify( "weapon_object_destroyed" );
		watcher deleteweaponobjectarray();
	}
	watcher.ownerteam = ownerteam;
}

createweaponobjectwatcher( name, weapon, ownerteam ) //checked matches cerberus output
{
	if ( !isDefined( self.weaponobjectwatcherarray ) )
	{
		self.weaponobjectwatcherarray = [];
	}
	weaponobjectwatcher = getweaponobjectwatcher( name );
	if ( !isDefined( weaponobjectwatcher ) )
	{
		weaponobjectwatcher = spawnstruct();
		self.weaponobjectwatcherarray[ self.weaponobjectwatcherarray.size ] = weaponobjectwatcher;
		weaponobjectwatcher.name = name;
		weaponobjectwatcher.type = "use";
		weaponobjectwatcher.weapon = weapon;
		weaponobjectwatcher.weaponidx = getweaponindexfromname( weapon );
		weaponobjectwatcher.watchforfire = 0;
		weaponobjectwatcher.hackable = 0;
		weaponobjectwatcher.altdetonate = 0;
		weaponobjectwatcher.detectable = 1;
		weaponobjectwatcher.headicon = 1;
		weaponobjectwatcher.stuntime = 0;
		weaponobjectwatcher.activatesound = undefined;
		weaponobjectwatcher.ignoredirection = undefined;
		weaponobjectwatcher.immediatedetonation = undefined;
		weaponobjectwatcher.deploysound = getweaponfiresound( weaponobjectwatcher.weaponidx );
		weaponobjectwatcher.deploysoundplayer = getweaponfiresoundplayer( weaponobjectwatcher.weaponidx );
		weaponobjectwatcher.pickupsound = getweaponpickupsound( weaponobjectwatcher.weaponidx );
		weaponobjectwatcher.pickupsoundplayer = getweaponpickupsoundplayer( weaponobjectwatcher.weaponidx );
		weaponobjectwatcher.altweapon = undefined;
		weaponobjectwatcher.ownergetsassist = 0;
		weaponobjectwatcher.playdestroyeddialog = 1;
		weaponobjectwatcher.deleteonkillbrush = 1;
		weaponobjectwatcher.deleteondifferentobjectspawn = 1;
		weaponobjectwatcher.enemydestroy = 0;
		weaponobjectwatcher.onspawn = undefined;
		weaponobjectwatcher.onspawnfx = undefined;
		weaponobjectwatcher.onspawnretrievetriggers = undefined;
		weaponobjectwatcher.ondetonated = undefined;
		weaponobjectwatcher.detonate = undefined;
		weaponobjectwatcher.stun = undefined;
		weaponobjectwatcher.ondestroyed = undefined;
		if ( !isDefined( weaponobjectwatcher.objectarray ) )
		{
			weaponobjectwatcher.objectarray = [];
		}
	}
	resetweaponobjectwatcher( weaponobjectwatcher, ownerteam );
	return weaponobjectwatcher;
}

createuseweaponobjectwatcher( name, weapon, ownerteam ) //checked matches cerberus output
{
	weaponobjectwatcher = createweaponobjectwatcher( name, weapon, ownerteam );
	weaponobjectwatcher.type = "use";
	weaponobjectwatcher.onspawn = ::onspawnuseweaponobject;
	return weaponobjectwatcher;
}

createproximityweaponobjectwatcher( name, weapon, ownerteam ) //checked matches cerberus output
{
	weaponobjectwatcher = createweaponobjectwatcher( name, weapon, ownerteam );
	weaponobjectwatcher.type = "proximity";
	weaponobjectwatcher.onspawn = ::onspawnproximityweaponobject;
	detectionconeangle = weapons_get_dvar_int( "scr_weaponobject_coneangle" );
	weaponobjectwatcher.detectiondot = cos( detectionconeangle );
	weaponobjectwatcher.detectionmindist = weapons_get_dvar_int( "scr_weaponobject_mindist" );
	weaponobjectwatcher.detectiongraceperiod = weapons_get_dvar( "scr_weaponobject_graceperiod" );
	weaponobjectwatcher.detonateradius = weapons_get_dvar_int( "scr_weaponobject_radius" );
	return weaponobjectwatcher;
}

commononspawnuseweaponobject( watcher, owner ) //checked matches cerberus output
{
	if ( watcher.detectable )
	{
		if ( is_true( watcher.ismovable ) )
		{
			self thread weaponobjectdetectionmovable( owner.pers[ "team" ] );
		}
		else
		{
			self thread weaponobjectdetectiontrigger_wait( owner.pers[ "team" ] );
		}
		if ( watcher.headicon && level.teambased )
		{
			self waittillnotmoving();
			offset = level.weaponobjects_headicon_offset[ "default" ];
			if ( isDefined( level.weaponobjects_headicon_offset[ self.name ] ) )
			{
				offset = level.weaponobjects_headicon_offset[ self.name ];
			}
			if ( isDefined( self ) )
			{
				self maps/mp/_entityheadicons::setentityheadicon( owner.pers[ "team" ], owner, offset );
			}
		}
	}
}

onspawnuseweaponobject( watcher, owner ) //checked matches cerberus output
{
	self commononspawnuseweaponobject( watcher, owner );
}

onspawnproximityweaponobject( watcher, owner ) //checked matches cerberus output dvar taken from beta dump
{
	self thread commononspawnuseweaponobject( watcher, owner );
	self thread proximityweaponobjectdetonation( watcher );
	/*
/#
	if ( getDvarInt( "scr_weaponobject_debug" ) )
	{
		self thread proximityweaponobjectdebug( watcher );
#/
	}
	*/
}

watchweaponobjectusage() //checked matches cerberus output
{
	self endon( "disconnect" );
	if ( !isDefined( self.weaponobjectwatcherarray ) )
	{
		self.weaponobjectwatcherarray = [];
	}
	self thread watchweaponobjectspawn();
	self thread watchweaponprojectileobjectspawn();
	self thread watchweaponobjectdetonation();
	self thread watchweaponobjectaltdetonation();
	self thread watchweaponobjectaltdetonate();
	self thread deleteweaponobjectson();
}

watchweaponobjectspawn() //checked partially changed to match cerberus output see info.md
{
	self notify( "watchWeaponObjectSpawn" );
	self endon( "watchWeaponObjectSpawn" );
	self endon( "disconnect" );
	while ( 1 )
	{
		self waittill( "grenade_fire", weapon, weapname );
		switch( weapname )
		{
			case "acoustic_sensor_mp":
			case "bouncingbetty_mp":
			case "camera_spike_mp":
			case "scrambler_mp":
			case "tactical_insertion_mp":
				break;
			case "bouncingbetty_mp":
			case "claymore_mp":
			case "proximity_grenade_mp":
			case "satchel_charge_mp":
			case "sensor_grenade_mp":
			case "trophy_system_mp":
				i = 0;
				while ( i < self.weaponobjectwatcherarray.size )
				{
					if ( self.weaponobjectwatcherarray[ i ].weapon != weapname )
					{
						i++;
						continue;
					}
					objectarray_size = self.weaponobjectwatcherarray[ i ].objectarray.size;
					for ( j = 0; j < objectarray_size; j++ )
					{
						if ( !isDefined( self.weaponobjectwatcherarray[ i ].objectarray[ j ] ) )
						{
							self.weaponobjectwatcherarray[ i ].objectarray = deleteweaponobject( self.weaponobjectwatcherarray[ i ], weapon );
						}
					}
					numallowed = 2;
					if ( weapname == "proximity_grenade_mp" )
					{
						numallowed = weapons_get_dvar_int( "scr_proximityGrenadeMaxInstances" );
					}
					if ( isDefined( self.weaponobjectwatcherarray[ i ].detonate ) && self.weaponobjectwatcherarray[ i ].objectarray.size > ( numallowed - 1 ) )
					{
						self.weaponobjectwatcherarray[ i ] thread waitanddetonate( self.weaponobjectwatcherarray[ i ].objectarray[ 0 ], 0.1, undefined, weapname );
					}
					i++;
					break;
				}
				default:
					break;
				if ( !self ishacked() )
				{
					if ( weapname == "claymore_mp" || weapname == "satchel_charge_mp" || weapname == "bouncingbetty_mp" )
					{
						self addweaponstat( weapname, "used", 1 );
					}
				}
				watcher = getweaponobjectwatcherbyweapon( weapname );
				if ( isDefined( watcher ) )
				{
					self addweaponobject( watcher, weapon );
				}
		}
	}
}

anyobjectsinworld( weapon ) //checked partially changed to match cerberus output see info.md
{
	objectsinworld = 0;
	i = 0;
	while ( i < self.weaponobjectwatcherarray.size )
	{
		if ( self.weaponobjectwatcherarray[ i ].weapon != weapon )
		{
			i++;
			continue;
		}
		if ( isDefined( self.weaponobjectwatcherarray[ i ].detonate ) && self.weaponobjectwatcherarray[ i ].objectarray.size > 0 )
		{
			objectsinworld = 1;
			break;
		}
		i++;
	}
	return objectsinworld;
}

watchweaponprojectileobjectspawn() //checked changed to match cerberus output
{
	self endon( "disconnect" );
	while ( 1 )
	{
		self waittill( "missile_fire", weapon, weapname );
		watcher = getweaponobjectwatcherbyweapon( weapname );
		if ( isDefined( watcher ) )
		{
			self addweaponobject( watcher, weapon );
			objectarray_size = watcher.objectarray.size;
			for ( j = 0; j < objectarray_size; j++ )
			{
				if ( !isDefined( watcher.objectarray[ j ] ) )
				{
					watcher.objectarray = deleteweaponobject( watcher, weapon );
				}
			}
			if ( isDefined( watcher.detonate ) && watcher.objectarray.size > 3 )
			{
				watcher thread waitanddetonate( watcher.objectarray[ 0 ], 0,1 );
			}
		}
	}
}

proximityweaponobjectdebug( watcher ) //checked changed to match cerberus output
{
	/*
/#
	self waittillnotmoving();
	self thread showcone( acos( watcher.detectiondot ), watcher.detonateradius, ( 1, 0.85, 0 ) );
	self thread showcone( 60, 256, ( 1, 0, 0 ) );
#/
	*/
}

vectorcross( v1, v2 ) //checked matches cerberus output
{
	/*
/#
	return ( ( v1[ 1 ] * v2[ 2 ] ) - ( v1[ 2 ] * v2[ 1 ] ), ( v1[ 2 ] * v2[ 0 ] ) - ( v1[ 0 ] * v2[ 2 ] ), ( v1[ 0 ] * v2[ 1 ] ) - ( v1[ 1 ] * v2[ 0 ] ) );
#/
	*/
}

showcone( angle, range, color ) //checked changed to match cerberus output
{
	/*
/#
	self endon( "death" );
	start = self.origin;
	forward = anglesToForward( self.angles );
	right = vectorcross( forward, ( 0, 0, 1 ) );
	up = vectorcross( forward, right );
	fullforward = forward * range * cos( angle );
	sideamnt = range * sin( angle );
	while ( 1 )
	{
		prevpoint = ( 0, 0, 1 );
		for ( i = 0; i <= 20; i++ )
		{
			coneangle = ( i / 20 ) * 360;
			point = ( start + fullforward ) + ( sideamnt * ( ( right * cos( coneangle ) ) + ( up * sin( coneangle ) ) ) );
			if ( i > 0 )
			{
				line( start, point, color );
				line( prevpoint, point, color );
			}
			prevpoint = point;
		}
		wait 0.05;
#/
	}
	*/
}

weaponobjectdetectionmovable( ownerteam ) //checked partially changed to match cerberus output see info.md
{
	self endon( "end_detection" );
	level endon( "game_ended" );
	self endon( "death" );
	self endon( "hacked" );
	if ( level.oldschool )
	{
		return;
	}
	if ( !level.teambased )
	{
		return;
	}
	self.detectid = "rcBomb" + getTime() + randomint( 1000000 );
	while ( !level.gameended )
	{
		wait 1;
		players = get_players();
		i = 0;
		while ( i < players.size )
		{
			player = players[ i ];
			if ( isai( player ) )
			{
				i++;
				continue;
			}
			if ( isDefined( self.model_name ) && player hasperk( "specialty_detectexplosive" ) )
			{
				switch( self.model_name )
				{
					case "t6_wpn_c4_world_detect":
					case "t6_wpn_claymore_world_detect":
						break;
					default:
						continue;
				}
			}
			else 
			{
				continue;
			}
			if ( player.team == ownerteam )
			{
				i++;
				continue;
			}
			if ( isDefined( player.bombsquadids[ self.detectid ] ) )
			{
				i++;
				continue;
			}
			i++;
		}
	}
}

seticonpos( item, icon, heightincrease ) //checked matches cerberus output
{
	icon.x = item.origin[ 0 ];
	icon.y = item.origin[ 1 ];
	icon.z = item.origin[ 2 ] + heightincrease;
}

weaponobjectdetectiontrigger_wait( ownerteam ) //checked matches cerberus output
{
	self endon( "death" );
	self endon( "hacked" );
	waittillnotmoving();
	if ( level.oldschool )
	{
		return;
	}
	self thread weaponobjectdetectiontrigger( ownerteam );
}

weaponobjectdetectiontrigger( ownerteam ) //checked matches cerberus output
{
	trigger = spawn( "trigger_radius", self.origin - vectorScale( ( 0, 0, 1 ), 128 ), 0, 512, 256 );
	trigger.detectid = "trigger" + getTime() + randomint( 1000000 );
	trigger sethintlowpriority( 1 );
	self waittill_any( "death", "hacked" );
	trigger notify( "end_detection" );
	if ( isDefined( trigger.bombsquadicon ) )
	{
		trigger.bombsquadicon destroy();
	}
	trigger delete();
}

hackertriggersetvisibility( owner ) //checked matches beta dump
{
	self endon( "death" );
	/*
/#
	assert( isplayer( owner ) );
#/
	*/
	ownerteam = owner.pers[ "team" ];
	for ( ;; )
	{
		if ( level.teambased )
		{
			self setvisibletoallexceptteam( ownerteam );
			self setexcludeteamfortrigger( ownerteam );
		}
		else
		{
			self setvisibletoall();
			self setteamfortrigger( "none" );
		}
		if ( isDefined( owner ) )
		{
			self setinvisibletoplayer( owner );
		}
		level waittill_any( "player_spawned", "joined_team" );
	}
}

hackernotmoving() //checked matches cerberus output
{
	self endon( "death" );
	self waittillnotmoving();
	self notify( "landed" );
}

hackerinit( watcher ) //checked matches cerberus output
{
	self thread hackernotmoving();
	event = self waittill_any_return( "death", "landed" );
	if ( event == "death" )
	{
		return;
	}
	triggerorigin = self.origin;
	if ( isDefined( self.name ) && self.name == "satchel_charge_mp" )
	{
		triggerorigin = self gettagorigin( "tag_fx" );
	}
	self.hackertrigger = spawn( "trigger_radius_use", triggerorigin, level.weaponobjects_hacker_trigger_width, level.weaponobjects_hacker_trigger_height );
	self.hackertrigger sethintlowpriority( 1 );
	self.hackertrigger setcursorhint( "HINT_NOICON", self );
	self.hackertrigger setignoreentfortrigger( self );
	self.hackertrigger enablelinkto();
	self.hackertrigger linkto( self );
	if ( isDefined( level.hackerhints[ self.name ] ) )
	{
		self.hackertrigger sethintstring( level.hackerhints[ self.name ].hint );
	}
	else
	{
		self.hackertrigger sethintstring( &"MP_GENERIC_HACKING" );
	}
	self.hackertrigger setperkfortrigger( "specialty_disarmexplosive" );
	self.hackertrigger thread hackertriggersetvisibility( self.owner );
	self thread hackerthink( self.hackertrigger, watcher );
}

hackerthink( trigger, watcher ) //checked changed to match cerberus output
{
	self endon( "death" );
	for ( ;; )
	{
		trigger waittill( "trigger", player, instant );
		if ( !isDefined( instant ) && !trigger hackerresult( player, self.owner ) )
		{
			continue;
		}
		self.owner hackerremoveweapon( self );
		self.owner maps/mp/gametypes/_globallogic_audio::leaderdialogonplayer( "hacked_equip", "item_destroyed" );
		self.hacked = 1;
		self setmissileowner( player );
		self setteam( player.pers[ "team" ] );
		self.owner = player;
		if ( isweaponequipment( self.name ) || self.name == "proximity_grenade_mp" )
		{
			maps/mp/_scoreevents::processscoreevent( "hacked", player );
			player addweaponstat( "pda_hack_mp", "CombatRecordStat", 1 );
			player maps/mp/_challenges::hackedordestroyedequipment();
		}
		if ( self.name == "satchel_charge_mp" && isDefined( player.lowermessage ) )
		{
			player.lowermessage settext( &"PLATFORM_SATCHEL_CHARGE_DOUBLE_TAP" );
			player.lowermessage.alpha = 1;
			player.lowermessage fadeovertime( 2 );
			player.lowermessage.alpha = 0;
		}
		self notify( "hacked", player );
		level notify( "hacked", self, player );
		if ( self.name == "camera_spike_mp" && isDefined( self.camerahead ) )
		{
			self.camerahead notify( "hacked" );
		}
		if ( isDefined( watcher.stun ) )
		{
			self thread stunstart( watcher, 0.75 );
			wait 0.75;
		}
		else
		{
			wait 0.05;
		}
		if ( isDefined( player ) && player.sessionstate == "playing" )
		{
			player notify( "grenade_fire", self, self.name, 1 );
		}
		else
		{
			watcher thread waitanddetonate( self, 0 );
		}
		return;
	}
}

hackerunfreezeplayer( player ) //checked matches cerberus output
{
	self endon( "hack_done" );
	self waittill( "death" );
	if ( isDefined( player ) )
	{
		player freeze_player_controls( 0 );
		player enableweapons();
	}
}

hackerresult( player, owner ) //checked matches cerberus output
{
	success = 1;
	time = getTime();
	hacktime = getDvarFloat( "perk_disarmExplosiveTime" );
	if ( !canhack( player, owner, 1 ) )
	{
		return 0;
	}
	self thread hackerunfreezeplayer( player );
	while ( ( time + ( hacktime * 1000 ) ) > getTime() )
	{
		if ( !canhack( player, owner, 0 ) )
		{
			success = 0;
			break;
		}
		if ( !player usebuttonpressed() )
		{
			success = 0;
			break;
		}
		if ( !isDefined( self ) )
		{
			success = 0;
			break;
		}
		player freeze_player_controls( 1 );
		player disableweapons();
		if ( !isDefined( self.progressbar ) )
		{
			self.progressbar = player createprimaryprogressbar();
			self.progressbar.lastuserate = -1;
			self.progressbar showelem();
			self.progressbar updatebar( 0.01, 1 / hacktime );
			self.progresstext = player createprimaryprogressbartext();
			self.progresstext settext( &"MP_HACKING" );
			self.progresstext showelem();
			player playlocalsound( "evt_hacker_hacking" );
		}
		wait 0.05;
	}
	if ( isDefined( player ) )
	{
		player freeze_player_controls( 0 );
		player enableweapons();
	}
	if ( isDefined( self.progressbar ) )
	{
		self.progressbar destroyelem();
		self.progresstext destroyelem();
	}
	if ( isDefined( self ) )
	{
		self notify( "hack_done" );
	}
	return success;
}

canhack( player, owner, weapon_check ) //checked matches cerberus output
{
	if ( !isDefined( player ) )
	{
		return 0;
	}
	if ( !isplayer( player ) )
	{
		return 0;
	}
	if ( !isalive( player ) )
	{
		return 0;
	}
	if ( !isDefined( owner ) )
	{
		return 0;
	}
	if ( owner == player )
	{
		return 0;
	}
	if ( level.teambased && player.team == owner.team )
	{
		return 0;
	}
	if ( is_true( player.isdefusing ) )
	{
		return 0;
	}
	if ( is_true( player.isplanting ) )
	{
		return 0;
	}
	if ( !is_true( player.proxbar ) )
	{
		return 0;
	}
	if ( isDefined( player.revivingteammate ) && player.revivingteammate == 1 )
	{
		return 0;
	}
	if ( !player isonground() )
	{
		return 0;
	}
	if ( player isinvehicle() )
	{
		return 0;
	}
	if ( player isweaponviewonlylinked() )
	{
		return 0;
	}
	if ( !player hasperk( "specialty_disarmexplosive" ) )
	{
		return 0;
	}
	if ( player isempjammed() )
	{
		return 0;
	}
	if ( is_true( player.laststand ) )
	{
		return 0;
	}
	if ( weapon_check )
	{
		if ( player isthrowinggrenade() )
		{
			return 0;
		}
		if ( player isswitchingweapons() )
		{
			return 0;
		}
		if ( player ismeleeing() )
		{
			return 0;
		}
		weapon = player getcurrentweapon();
		if ( !isDefined( weapon ) )
		{
			return 0;
		}
		if ( weapon == "none" )
		{
			return 0;
		}
		if ( isweaponequipment( weapon ) && player isfiring() )
		{
			return 0;
		}
		if ( isweaponspecificuse( weapon ) )
		{
			return 0;
		}
	}
	return 1;
}

hackerremoveweapon( weapon ) //checked partially changed to match cerberus output see info.md
{
	i = 0;
	while ( i < self.weaponobjectwatcherarray.size )
	{
		if ( self.weaponobjectwatcherarray[ i ].weapon != weapon.name )
		{
			i++;
			continue;
		}
		objectarray_size = self.weaponobjectwatcherarray[ i ].objectarray.size;
		for ( j = 0; j < objectarray_size; j++ )
		{
			self.weaponobjectwatcherarray[ i ].objectarray = deleteweaponobject( self.weaponobjectwatcherarray[ i ], weapon );
		}
		return;
		i++;
	}
}

proximityweaponobjectdetonation( watcher ) //checked changed to match cerberus output dvar taken from beta dump
{
	self endon( "death" );
	self endon( "hacked" );
	self waittillnotmoving();
	if ( isDefined( watcher.activationdelay ) )
	{
		wait watcher.activationdelay;
	}
	damagearea = spawn( "trigger_radius", self.origin + ( 0, 0, 0 - watcher.detonateradius ), level.aitriggerspawnflags | level.vehicletriggerspawnflags, watcher.detonateradius, watcher.detonateradius * 2 );
	damagearea enablelinkto();
	damagearea linkto( self );
	self thread deleteondeath( damagearea );
	up = anglesToUp( self.angles );
	traceorigin = self.origin + up;
	while ( 1 )
	{
		damagearea waittill( "trigger", ent );
		if ( getDvarInt( "scr_weaponobject_debug" ) != 1 )
		{
			if ( isDefined( self.owner ) && ent == self.owner )
			{
				continue;
			}
			if ( isDefined( self.owner ) && isvehicle( ent ) && isDefined( ent.owner ) && self.owner == ent.owner )
			{
				continue;
			}
			if ( !friendlyfirecheck( self.owner, ent, 0 ) )
			{
				continue;
			}
		}
		if ( lengthsquared( ent getvelocity() ) < 10 && !isDefined( watcher.immediatedetonation ) )
		{
			continue;
		}
		if ( !ent shouldaffectweaponobject( self, watcher ) )
		{
			continue;
		}
		if ( self isstunned() )
		{
			continue;
		}
		if ( isplayer( ent ) && !isalive( ent ) )
		{
			continue;
		}
		if ( ent damageconetrace( traceorigin, self ) > 0 )
		{
			break;
		}
	}
	if ( isDefined( watcher.activatesound ) )
	{
		self playsound( watcher.activatesound );
	}
	if ( isDefined( watcher.activatefx ) )
	{
		self setclientflag( 4 );
	}
	ent thread deathdodger( watcher.detectiongraceperiod );
	wait watcher.detectiongraceperiod;
	if ( isplayer( ent ) && ent hasperk( "specialty_delayexplosive" ) )
	{
		wait getDvarFloat( "perk_delayExplosiveTime" );
	}
	self maps/mp/_entityheadicons::setentityheadicon( "none" );
	self.origin = traceorigin;
	if ( isDefined( self.owner ) && isplayer( self.owner ) )
	{
		self [[ watcher.detonate ]]( self.owner );
	}
	else 
	{
		self [[ watcher.detonate ]]();
	}
}

shouldaffectweaponobject( object, watcher ) //checked matches cerberus output
{
	radius = getweaponexplosionradius( watcher.weapon );
	distancesqr = distancesquared( self.origin, object.origin );
	if ( ( radius * radius ) < distancesqr )
	{
		return 0;
	}
	pos = self.origin + vectorScale( ( 0, 0, 1 ), 32 );
	if ( isDefined( watcher.ignoredirection ) )
	{
		return 1;
	}
	dirtopos = pos - object.origin;
	objectforward = anglesToForward( object.angles );
	dist = vectordot( dirtopos, objectforward );
	if ( dist < watcher.detectionmindist )
	{
		return 0;
	}
	dirtopos = vectornormalize( dirtopos );
	dot = vectordot( dirtopos, objectforward );
	return dot > watcher.detectiondot;
}

deathdodger( graceperiod ) //checked matches cerberus output
{
	self endon( "death" );
	self endon( "disconnect" );
	wait ( 0.2 + graceperiod );
	self notify( "death_dodger" );
}

deleteondeath( ent ) //checked matches cerberus output
{
	self waittill_any( "death", "hacked" );
	wait 0.05;
	if ( isDefined( ent ) )
	{
		ent delete();
	}
}

testkillbrushonstationary( killbrusharray, player ) //checked changed to match cerberus output
{
	player endon( "disconnect" );
	self endon( "death" );
	self waittill( "stationary" );
	wait 0.1;
	for ( i = 0; i < killbrusharray.size; i++ )
	{
		if ( self istouching( killbrusharray[ i ] ) )
		{
			if ( self.origin[ 2 ] > player.origin[ 2 ] )
			{
				break;
			}
			if ( isDefined( self ) )
			{
				self delete();
			}
			return;
		}
	}
}

deleteonkillbrush( player ) //checked changed to match cerberus output
{
	player endon( "disconnect" );
	self endon( "death" );
	self endon( "stationary" );
	killbrushes = getentarray( "trigger_hurt", "classname" );
	self thread testkillbrushonstationary( killbrushes, player );
	while ( 1 )
	{
		for ( i = 0; i < killbrushes.size; i++ )
		{
			if ( self istouching( killbrushes[ i ] ) )
			{
				if ( self.origin[ 2 ] > player.origin[ 2 ] )
				{
					break;
				}
				if ( isDefined( self ) )
				{
					self delete();
				}
				return;
			}
		}
		wait 0.1;
	}
}

watchweaponobjectaltdetonation() //checked changed to match cerberus output
{
	self endon( "disconnect" );
	while ( 1 )
	{
		self waittill( "alt_detonate" );
		if ( !isalive( self ) )
		{
			continue;
		}
		for ( watcher = 0; watcher < self.weaponobjectwatcherarray.size; watcher++ )
		{
			if ( self.weaponobjectwatcherarray[ watcher ].altdetonate )
			{
				self.weaponobjectwatcherarray[ watcher ] detonateweaponobjectarray( 0 );
			}
		}
	}
}

watchweaponobjectaltdetonate() //checked changed to match cerberus output
{
	self endon( "disconnect" );
	self endon( "detonated" );
	level endon( "game_ended" );
	buttontime = 0;
	for ( ;; )
	{
		self waittill( "doubletap_detonate" );
		if ( !isalive( self ) )
		{
			continue;
		}
		self notify( "alt_detonate" );
		wait 0.05;
	}
}

watchweaponobjectdetonation() //checked matches cerberus output
{
	self endon( "disconnect" );
	while ( 1 )
	{
		self waittill( "detonate" );
		if ( self isusingoffhand() )
		{
			weap = self getcurrentoffhand();
		}
		else
		{
			weap = self getcurrentweapon();
		}
		watcher = getweaponobjectwatcherbyweapon( weap );
		if ( isDefined( watcher ) )
		{
			watcher detonateweaponobjectarray( 0 );
		}
	}
}

deleteweaponobjectson() //checked changed to match cerberus output
{
	while ( 1 )
	{
		msg = self waittill_any_return( "disconnect", "joined_team", "joined_spectators", "death" );
		if ( msg == "death" )
		{
			continue;
		}
		if ( !isDefined( self.weaponobjectwatcherarray ) )
		{
			return;
		}
		watchers = [];
		for ( watcher = 0; watcher < self.weaponobjectwatcherarray.size; watcher++ )
		{
			weaponobjectwatcher = spawnstruct();
			watchers[ watchers.size ] = weaponobjectwatcher;
			weaponobjectwatcher.objectarray = [];
			if ( isDefined( self.weaponobjectwatcherarray[ watcher ].objectarray ) )
			{
				weaponobjectwatcher.objectarray = self.weaponobjectwatcherarray[ watcher ].objectarray;
			}
		}
		wait 0.05;
		for ( watcher = 0; watcher < watchers.size; watcher++ )
		{
			watchers[ watcher ] deleteweaponobjectarray();
		}
		if ( msg == "disconnect" )
		{
			return;
		}
	}
}

saydamaged( orig, amount ) //checked changed to match cerberus output
{
	/*
/#
	for ( i = 0; i < 60; i++ )
	{
		print3d( orig, "damaged! " + amount );
		wait 0.05;
#/
	}
	*/
}

showheadicon( trigger ) //checked changed to match cerberus output
{
	triggerdetectid = trigger.detectid;
	useid = -1;
	for ( index = 0; index < 4; index++ )
	{
		detectid = self.bombsquadicons[ index ].detectid;
		if ( detectid == triggerdetectid )
		{
			return;
		}
		if ( detectid == "" )
		{
			useid = index;
		}
	}
	if ( useid < 0 )
	{
		return;
	}
	self.bombsquadids[ triggerdetectid ] = 1;
	self.bombsquadicons[ useid ].x = trigger.origin[ 0 ];
	self.bombsquadicons[ useid ].y = trigger.origin[ 1 ];
	self.bombsquadicons[ useid ].z = trigger.origin[ 2 ] + 24 + 128;
	self.bombsquadicons[ useid ] fadeovertime( 0,25 );
	self.bombsquadicons[ useid ].alpha = 1;
	self.bombsquadicons[ useid ].detectid = trigger.detectid;
	while ( isalive( self ) && isDefined( trigger ) && self istouching( trigger ) )
	{
		wait 0.05;
	}
	if ( !isDefined( self ) )
	{
		return;
	}
	self.bombsquadicons[ useid ].detectid = "";
	self.bombsquadicons[ useid ] fadeovertime( 0,25 );
	self.bombsquadicons[ useid ].alpha = 0;
	self.bombsquadids[ triggerdetectid ] = undefined;
}

friendlyfirecheck( owner, attacker, forcedfriendlyfirerule ) //checked changed to match cerberus output
{
	if ( !isDefined( owner ) )
	{
		return 1;
	}
	if ( !level.teambased )
	{
		return 1;
	}
	friendlyfirerule = level.friendlyfire;
	if ( isDefined( forcedfriendlyfirerule ) )
	{
		friendlyfirerule = forcedfriendlyfirerule;
	}
	if ( friendlyfirerule != 0 )
	{
		return 1;
	}
	if ( attacker == owner )
	{
		return 1;
	}
	if ( isplayer( attacker ) )
	{
		if ( !isDefined( attacker.pers[ "team" ] ) )
		{
			return 1;
		}
		if ( attacker.pers[ "team" ] != owner.pers[ "team" ] )
		{
			return 1;
		}
	}
	else if ( isai( attacker ) )
	{
		if ( attacker.aiteam != owner.pers[ "team" ] )
		{
			return 1;
		}
	}
	else if ( isvehicle( attacker ) )
	{
		if ( isDefined( attacker.owner ) && isplayer( attacker.owner ) )
		{
			if ( attacker.owner.pers[ "team" ] != owner.pers[ "team" ] )
			{
				return 1;
			}
		}
		else
		{
			occupant_team = attacker maps/mp/_vehicles::vehicle_get_occupant_team();
			if ( occupant_team != owner.pers[ "team" ] )
			{
				return 1;
			}
		}
	}
	return 0;
}

onspawnhatchettrigger( watcher, player ) //checked changed to match cerberus output
{
	self endon( "death" );
	self setowner( player );
	self setteam( player.pers[ "team" ] );
	self.owner = player;
	self.oldangles = self.angles;
	self waittillnotmoving();
	waittillframeend;
	if ( player.pers[ "team" ] == "spectator" )
	{
		return;
	}
	triggerorigin = self.origin;
	triggerparentent = undefined;
	if ( isDefined( self.stucktoplayer ) )
	{
		if ( isalive( self.stucktoplayer ) || !isDefined( self.stucktoplayer.body ) )
		{
			if ( isalive( self.stucktoplayer ) )
			{
				triggerparentent = self;
				self unlink();
				self.angles = self.oldangles;
				self launch( vectorScale( ( 1, 1, 1 ), 5 ) );
				self waittillnotmoving();
				waittillframeend;
			}
			else
			{
				triggerparentent = self.stucktoplayer;
			}
		}
		else
		{
			triggerparentent = self.stucktoplayer.body;
		}
	}
	if ( isDefined( triggerparentent ) )
	{
		triggerorigin = triggerparentent.origin + vectorScale( ( 0, 0, 1 ), 10 );
	}
	self.hatchetpickuptrigger = spawn( "trigger_radius", triggerorigin, 0, 50, 50 );
	self.hatchetpickuptrigger enablelinkto();
	self.hatchetpickuptrigger linkto( self );
	if ( isDefined( triggerparentent ) )
	{
		self.hatchetpickuptrigger linkto( triggerparentent );
	}
	self thread watchhatchettrigger( self.hatchetpickuptrigger, watcher.pickup, watcher.pickupsoundplayer, watcher.pickupsound );
	/*
/#
	thread switch_team( self, watcher.weapon, player );
#/
	*/
	self thread watchshutdown( player );
}

watchhatchettrigger( trigger, callback, playersoundonuse, npcsoundonuse ) //checked changed to match cerberus output
{
	self endon( "delete" );
	self endon( "hacked" );
	while ( 1 )
	{
		trigger waittill( "trigger", player );
		if ( !isalive( player ) )
		{
			continue;
		}
		if ( !player isonground() )
		{
			continue;
		}
		if ( isDefined( trigger.claimedby ) && player != trigger.claimedby )
		{
			continue;
		}
		if ( !player hasweapon( self.name ) )
		{
			continue;
		}
		curr_ammo = player getweaponammostock( "hatchet_mp" );
		maxammo = weaponmaxammo( "hatchet_mp" );
		if ( player.grenadetypeprimary == "hatchet_mp" )
		{
			maxammo = player.grenadetypeprimarycount;
		}
		else if ( isDefined( player.grenadetypesecondary ) && player.grenadetypesecondary == "hatchet_mp" )
		{
			maxammo = player.grenadetypesecondarycount;
		}
		if ( curr_ammo >= maxammo )
		{
			continue;
		}
		if ( isDefined( playersoundonuse ) )
		{
			player playlocalsound( playersoundonuse );
		}
		if ( isDefined( npcsoundonuse ) )
		{
			player playsound( npcsoundonuse );
		}
		self thread [[ callback ]]( player );
	}
}

onspawnretrievableweaponobject( watcher, player ) //checked matches cerberus output
{
	self endon( "death" );
	self endon( "hacked" );
	if ( ishacked() )
	{
		self thread watchshutdown( player );
		return;
	}
	self setowner( player );
	self setteam( player.pers[ "team" ] );
	self.owner = player;
	self.oldangles = self.angles;
	self waittillnotmoving();
	if ( isDefined( watcher.activationdelay ) )
	{
		wait watcher.activationdelay;
	}
	waittillframeend;
	if ( player.pers[ "team" ] == "spectator" )
	{
		return;
	}
	triggerorigin = self.origin;
	triggerparentent = undefined;
	if ( isDefined( self.stucktoplayer ) )
	{
		if ( isalive( self.stucktoplayer ) || !isDefined( self.stucktoplayer.body ) )
		{
			triggerparentent = self.stucktoplayer;
		}
		else
		{
			triggerparentent = self.stucktoplayer.body;
		}
	}
	if ( isDefined( triggerparentent ) )
	{
		triggerorigin = triggerparentent.origin + vectorScale( ( 0, 0, 1 ), 10 );
	}
	else
	{
		up = anglesToUp( self.angles );
		triggerorigin = self.origin + up;
	}
	self.pickuptrigger = spawn( "trigger_radius_use", triggerorigin );
	self.pickuptrigger sethintlowpriority( 1 );
	self.pickuptrigger setcursorhint( "HINT_NOICON", self );
	self.pickuptrigger enablelinkto();
	self.pickuptrigger linkto( self );
	self.pickuptrigger setinvisibletoall();
	self.pickuptrigger setvisibletoplayer( player );
	if ( isDefined( level.retrievehints[ watcher.name ] ) )
	{
		self.pickuptrigger sethintstring( level.retrievehints[ watcher.name ].hint );
	}
	else
	{
		self.pickuptrigger sethintstring( &"MP_GENERIC_PICKUP" );
	}
	if ( level.teambased )
	{
		self.pickuptrigger setteamfortrigger( player.pers[ "team" ] );
	}
	else
	{
		self.pickuptrigger setteamfortrigger( "none" );
	}
	if ( isDefined( triggerparentent ) )
	{
		self.pickuptrigger linkto( triggerparentent );
	}
	if ( watcher.enemydestroy )
	{
		self.enemytrigger = spawn( "trigger_radius_use", triggerorigin );
		self.enemytrigger setcursorhint( "HINT_NOICON", self );
		self.enemytrigger enablelinkto();
		self.enemytrigger linkto( self );
		self.enemytrigger setinvisibletoplayer( player );
		if ( level.teambased )
		{
			self.enemytrigger setexcludeteamfortrigger( player.team );
			self.enemytrigger.triggerteamignore = self.team;
		}
		if ( isDefined( level.destroyhints[ watcher.name ] ) )
		{
			self.enemytrigger sethintstring( level.destroyhints[ watcher.name ].hint );
		}
		else
		{
			self.enemytrigger sethintstring( &"MP_GENERIC_DESTROY" );
		}
		self thread watchusetrigger( self.enemytrigger, watcher.ondestroyed );
	}
	self thread watchusetrigger( self.pickuptrigger, watcher.pickup, watcher.pickupsoundplayer, watcher.pickupsound );
	/*
/#
	thread switch_team( self, watcher.weapon, player );
#/
	*/
	if ( isDefined( watcher.pickup_trigger_listener ) )
	{
		self thread [[ watcher.pickup_trigger_listener ]]( self.pickuptrigger, player );
	}
	self thread watchshutdown( player );
}

watch_trigger_visibility( triggers, weap_name ) //checked partially changed to match cerberus output see info.md
{
	self notify( "watchTriggerVisibility" );
	self endon( "watchTriggerVisibility" );
	self endon( "death" );
	self endon( "hacked" );
	max_ammo = weaponmaxammo( weap_name );
	start_ammo = weaponstartammo( weap_name );
	ammo_to_check = 0;
	while ( 1 )
	{
		players = level.players;
		for ( i = 0; i < players.size; i++ )
		{
			if ( players[ i ] hasweapon( weap_name ) )
			{
				ammo_to_check = max_ammo;
				if ( self.owner == players[ i ] )
				{
					curr_ammo = players[ i ] getweaponammostock( weap_name ) + players[ i ] getweaponammoclip( weap_name );
					if ( weap_name == "hatchet_mp" )
					{
						curr_ammo = players[ i ] getweaponammostock( weap_name );
					}
					if ( curr_ammo < ammo_to_check )
					{
						triggers[ "owner_pickup" ] setvisibletoplayer( players[ i ] );
						triggers[ "enemy_pickup" ] setinvisibletoplayer( players[ i ] );
					}
					else
					{
						triggers[ "owner_pickup" ] setinvisibletoplayer( players[ i ] );
						triggers[ "enemy_pickup" ] setinvisibletoplayer( players[ i ] );
					}
				}
				else 
				{
					curr_ammo = players[ i ] getweaponammostock( weap_name ) + players[ i ] getweaponammoclip( weap_name );
					if ( weap_name == "hatchet_mp" )
					{
						curr_ammo = players[ i ] getweaponammostock( weap_name );
					}
					if ( curr_ammo < ammo_to_check )
					{
						triggers[ "owner_pickup" ] setinvisibletoplayer( players[ i ] );
						triggers[ "enemy_pickup" ] setvisibletoplayer( players[ i ] );
					}
					else
					{
						triggers[ "owner_pickup" ] setinvisibletoplayer( players[ i ] );
						triggers[ "enemy_pickup" ] setinvisibletoplayer( players[ i ] );
					}
				}
			}
			else
			{
				triggers[ "owner_pickup" ] setinvisibletoplayer( players[ i ] );
				triggers[ "enemy_pickup" ] setinvisibletoplayer( players[ i ] );
			}
		}
		wait 0.05;
	}
}

destroyent() //checked matches cerberus output
{
	self delete();
}

pickup( player ) //checked matches cerberus output
{
	if ( self.name != "hatchet_mp" && isDefined( self.owner ) && self.owner != player )
	{
		return;
	}
	self notify( "picked_up" );
	self.playdialog = 0;
	self destroyent();
	player giveweapon( self.name );
	clip_ammo = player getweaponammoclip( self.name );
	clip_max_ammo = weaponclipsize( self.name );
	if ( clip_ammo < clip_max_ammo )
	{
		clip_ammo++;
	}
	player setweaponammoclip( self.name, clip_ammo );
}

ondestroyed( attacker ) //checked matches cerberus output
{
	playfx( level._effect[ "tacticalInsertionFizzle" ], self.origin );
	self playsound( "dst_tac_insert_break" );
	self.owner maps/mp/gametypes/_globallogic_audio::leaderdialogonplayer( "equipment_destroyed", "item_destroyed" );
	self delete();
}

watchshutdown( player ) //checked matches cerberus output
{
	self waittill_any( "death", "hacked" );
	pickuptrigger = self.pickuptrigger;
	hackertrigger = self.hackertrigger;
	hatchetpickuptrigger = self.hatchetpickuptrigger;
	enemytrigger = self.enemytrigger;
	if ( isDefined( pickuptrigger ) )
	{
		pickuptrigger delete();
	}
	if ( isDefined( hackertrigger ) )
	{
		if ( isDefined( hackertrigger.progressbar ) )
		{
			hackertrigger.progressbar destroyelem();
			hackertrigger.progresstext destroyelem();
		}
		hackertrigger delete();
	}
	if ( isDefined( hatchetpickuptrigger ) )
	{
		hatchetpickuptrigger delete();
	}
	if ( isDefined( enemytrigger ) )
	{
		enemytrigger delete();
	}
}

watchusetrigger( trigger, callback, playersoundonuse, npcsoundonuse ) //checked changed to match cerberus output
{
	self endon( "delete" );
	self endon( "hacked" );
	while ( 1 )
	{
		trigger waittill( "trigger", player );
		if ( !isalive( player ) )
		{
			continue;
		}
		if ( !player isonground() )
		{
			continue;
		}
		if ( isDefined( trigger.triggerteam ) && player.pers[ "team" ] != trigger.triggerteam )
		{
			continue;
		}
		if ( isDefined( trigger.triggerteamignore ) && player.team == trigger.triggerteamignore )
		{
			continue;
		}
		if ( isDefined( trigger.claimedby ) && player != trigger.claimedby )
		{
			continue;
		}
		grenade = player.throwinggrenade;
		isequipment = isweaponequipment( player getcurrentweapon() );
		if ( is_true( isequipment ) )
		{
			grenade = 0;
		}
		if ( player usebuttonpressed() && !grenade && !player meleebuttonpressed() )
		{
			if ( isDefined( playersoundonuse ) )
			{
				player playlocalsound( playersoundonuse );
			}
			if ( isDefined( npcsoundonuse ) )
			{
				player playsound( npcsoundonuse );
			}
			self thread [[ callback ]]( player );
		}
	}
}

createretrievablehint( name, hint ) //checked matches cerberus output
{
	retrievehint = spawnstruct();
	retrievehint.name = name;
	retrievehint.hint = hint;
	level.retrievehints[ name ] = retrievehint;
}

createhackerhint( name, hint ) //checked matches cerberus output
{
	hackerhint = spawnstruct();
	hackerhint.name = name;
	hackerhint.hint = hint;
	level.hackerhints[ name ] = hackerhint;
}

createdestroyhint( name, hint ) //checked matches cerberus output
{
	destroyhint = spawnstruct();
	destroyhint.name = name;
	destroyhint.hint = hint;
	level.destroyhints[ name ] = destroyhint;
}

attachreconmodel( modelname, owner ) //checked matches cerberus output
{
	if ( !isDefined( self ) )
	{
		return;
	}
	reconmodel = spawn( "script_model", self.origin );
	reconmodel.angles = self.angles;
	reconmodel setmodel( modelname );
	reconmodel.model_name = modelname;
	reconmodel linkto( self );
	reconmodel setcontents( 0 );
	reconmodel resetreconmodelvisibility( owner );
	reconmodel thread watchreconmodelfordeath( self );
	reconmodel thread resetreconmodelonevent( "joined_team", owner );
	reconmodel thread resetreconmodelonevent( "player_spawned", owner );
	self.reconmodelentity = reconmodel;
}

resetreconmodelvisibility( owner ) //checked partially changed to match beta dump see info.md
{
	if ( !isDefined( self ) )
	{
		return;
	}
	self setinvisibletoall();
	self setforcenocull();
	if ( !isDefined( owner ) )
	{
		return;
	}
	i = 0;
	while ( i < level.players.size )
	{
		if ( !level.players[ i ] hasperk( "specialty_detectexplosive" ) && !level.players[ i ] hasperk( "specialty_showenemyequipment" ) )
		{
			i++;
			continue;
		}
		if ( level.players[ i ].team == "spectator" )
		{
			i++;
			continue;
		}
		hasreconmodel = 0;
		if ( level.players[ i ] hasperk( "specialty_detectexplosive" ) )
		{
			switch( self.model_name )
			{
				case "t6_wpn_c4_world_detect":
				case "t6_wpn_claymore_world_detect":
					hasreconmodel = 1;
					break;
				break;
				default:
					break;
			}
			if ( level.players[ i ] hasperk( "specialty_showenemyequipment" ) )
			{
				switch( self.model_name )
				{
					case "t5_weapon_scrambler_world_detect":
					case "t6_wpn_bouncing_betty_world_detect":
					case "t6_wpn_c4_world_detect":
					case "t6_wpn_claymore_world_detect":
					case "t6_wpn_motion_sensor_world_detect":
					case "t6_wpn_tac_insert_detect":
					case "t6_wpn_taser_mine_world_detect":
					case "t6_wpn_trophy_system_world_detect":
						hasreconmodel = 1;
						break;
					default:
						break;
				}
				if ( !hasreconmodel )
				{
					i++;
					continue;
				}
				isenemy = 1;
				if ( level.teambased )
				{
					if ( level.players[ i ].team == owner.team )
					{
						isenemy = 0;
					}
				}
				else
				{
					if ( level.players[ i ] == owner )
					{
						isenemy = 0;
					}
				}
				if ( isenemy )
				{
					self setvisibletoplayer( level.players[ i ] );
				}
			}
		}
		i++;
	}
}

watchreconmodelfordeath( parentent ) //checked changed to match cerberus output
{
	self endon( "death" );
	parentent waittill_any( "death", "hacked" );
	self delete();
}

resetreconmodelonevent( eventname, owner ) //checked changed to match cerberus output
{
	self endon( "death" );
	for ( ;; )
	{
		level waittill( eventname, newowner );
		if ( isDefined( newowner ) )
		{
			owner = newowner;
		}
		self resetreconmodelvisibility( owner );
	}
}

switch_team( entity, weapon_name, owner ) //checked changed to match cerberus output
{
	/*
/#
	self notify( "stop_disarmthink" );
	self endon( "stop_disarmthink" );
	self endon( "death" );
	setdvar( "scr_switch_team", "" );
	while ( 1 )
	{
		wait 0.5;
		devgui_int = getDvarInt( "scr_switch_team" );
		if ( devgui_int != 0 )
		{
			team = "autoassign";
			player = maps/mp/gametypes/_dev::getormakebot( team );
			if ( !isDefined( player ) )
			{
				println( "Could not add test client" );
				wait 1;
			}
			entity.owner hackerremoveweapon( entity );
			entity.hacked = 1;
			entity setowner( player );
			entity setteam( player.pers[ "team" ] );
			entity.owner = player;
			entity notify( "hacked", player );
			level notify( "hacked", entity, player );
			if ( entity.name == "camera_spike_mp" && isDefined( entity.camerahead ) )
			{
				entity.camerahead notify( "hacked" );
			}
			wait 0.05;
			if ( isDefined( player ) && player.sessionstate == "playing" )
			{
				player notify( "grenade_fire", self, self.name );
			}
			setdvar( "scr_switch_team", "0" );
		}
#/
	}
	*/
}

