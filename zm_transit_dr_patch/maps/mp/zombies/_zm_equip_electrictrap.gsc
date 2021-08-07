#include maps/mp/zombies/_zm_traps;
#include maps/mp/zombies/_zm_buildables;
#include maps/mp/zombies/_zm_power;
#include maps/mp/zombies/_zm_unitrigger;
#include maps/mp/zombies/_zm;
#include maps/mp/gametypes_zm/_weaponobjects;
#include maps/mp/zombies/_zm_equipment;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

init()
{
	if ( !maps/mp/zombies/_zm_equipment::is_equipment_included( "equip_electrictrap_zm" ) )
	{
		return;
	}
	level.electrictrap_name = "equip_electrictrap_zm";
	maps/mp/zombies/_zm_equipment::register_equipment( "equip_electrictrap_zm", &"ZOMBIE_EQUIP_ELECTRICTRAP_PICKUP_HINT_STRING", &"ZOMBIE_EQUIP_ELECTRICTRAP_HOWTO", "etrap_zm_icon", "electrictrap", undefined, ::transfertrap, ::droptrap, ::pickuptrap, ::placetrap );
	maps/mp/zombies/_zm_equipment::add_placeable_equipment( "equip_electrictrap_zm", "p6_anim_zm_buildable_etrap" );
	level thread onplayerconnect();
	maps/mp/gametypes_zm/_weaponobjects::createretrievablehint( "equip_electrictrap", &"ZOMBIE_EQUIP_ELECTRICTRAP_PICKUP_HINT_STRING" );
	level._effect[ "etrap_on" ] = loadfx( "maps/zombie/fx_zmb_tranzit_electric_trap_on" );
	thread wait_init_damage();
}

wait_init_damage()
{
	while ( !isDefined( level.zombie_vars ) || !isDefined( level.zombie_vars[ "zombie_health_start" ] ) )
	{
		wait 1;
	}
	level.etrap_damage = maps/mp/zombies/_zm::ai_zombie_health( 50 );
}

onplayerconnect()
{
	for ( ;; )
	{
		level waittill( "connecting", player );
		player thread onplayerspawned();
	}
}

onplayerspawned()
{
	self endon( "disconnect" );
	self thread setupwatchers();
	for ( ;; )
	{
		self waittill( "spawned_player" );
		self thread watchelectrictrapuse();
	}
}

setupwatchers()
{
	self waittill( "weapon_watchers_created" );
	watcher = maps/mp/gametypes_zm/_weaponobjects::getweaponobjectwatcher( "equip_electrictrap" );
	watcher.onspawnretrievetriggers = ::maps/mp/zombies/_zm_equipment::equipment_onspawnretrievableweaponobject;
}

watchelectrictrapuse()
{
	self notify( "watchElectricTrapUse" );
	self endon( "watchElectricTrapUse" );
	self endon( "death" );
	self endon( "disconnect" );
	for ( ;; )
	{
		self waittill( "equipment_placed", weapon, weapname );
		if ( weapname == level.electrictrap_name )
		{
			self cleanupoldtrap();
			self.buildableelectrictrap = weapon;
			self thread startelectrictrapdeploy( weapon );
		}
	}
}

cleanupoldtrap()
{
	if ( isDefined( self.buildableelectrictrap ) )
	{
		if ( isDefined( self.buildableelectrictrap.stub ) )
		{
			thread maps/mp/zombies/_zm_unitrigger::unregister_unitrigger( self.buildableelectrictrap.stub );
			self.buildableelectrictrap.stub = undefined;
		}
		self.buildableelectrictrap delete();
	}
	if ( isDefined( level.electrap_sound_ent ) )
	{
		level.electrap_sound_ent delete();
		level.electrap_sound_ent = undefined;
	}
}

watchforcleanup()
{
	self notify( "etrap_cleanup" );
	self endon( "etrap_cleanup" );
	self waittill_any( "death", "disconnect", "equip_electrictrap_zm_taken", "equip_electrictrap_zm_pickup" );
	cleanupoldtrap();
}

placetrap( origin, angles )
{
	item = self maps/mp/zombies/_zm_equipment::placed_equipment_think( "p6_anim_zm_buildable_etrap", "equip_electrictrap_zm", origin, angles );
	if ( isDefined( item ) )
	{
		item.owner = self;
		item.zombie_attack_callback = ::zombie_attacked_trap;
	}
	return item;
}

droptrap()
{
	item = self maps/mp/zombies/_zm_equipment::dropped_equipment_think( "p6_anim_zm_buildable_etrap", "equip_electrictrap_zm", self.origin, self.angles );
	if ( isDefined( item ) )
	{
		item.electrictrap_health = self.electrictrap_health;
	}
	self.electrictrap_health = undefined;
	return item;
}

pickuptrap( item )
{
	item.owner = self;
	self.electrictrap_health = item.electrictrap_health;
	item.electrictrap_health = undefined;
}

transfertrap( fromplayer, toplayer )
{
	buildableelectrictrap = toplayer.buildableelectrictrap;
	electrictrap_health = toplayer.electrictrap_health;
	toplayer.buildableelectrictrap = fromplayer.buildableelectrictrap;
	toplayer.buildableelectrictrap.original_owner = toplayer;
	toplayer notify( "equip_electrictrap_zm_taken" );
	toplayer thread startelectrictrapdeploy( toplayer.buildableelectrictrap );
	toplayer.electrictrap_health = fromplayer.electrictrap_health;
	fromplayer.buildableelectrictrap = buildableelectrictrap;
	fromplayer notify( "equip_electrictrap_zm_taken" );
	if ( isDefined( fromplayer.buildableelectrictrap ) )
	{
		fromplayer thread startelectrictrapdeploy( fromplayer.buildableelectrictrap );
		fromplayer.buildableelectrictrap.original_owner = fromplayer;
		fromplayer.buildableelectrictrap.owner = fromplayer;
	}
	else
	{
		fromplayer maps/mp/zombies/_zm_equipment::equipment_release( "equip_electrictrap_zm" );
	}
	fromplayer.electrictrap_health = electrictrap_health;
}

startelectrictrapdeploy( weapon )
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "equip_electrictrap_zm_taken" );
	self thread watchforcleanup();
	electricradius = 45;
	if ( !isDefined( self.electrictrap_health ) )
	{
		self.electrictrap_health = 60;
	}
	if ( isDefined( weapon ) )
	{
/#
		weapon thread debugelectrictrap( electricradius );
#/
		if ( isDefined( level.equipment_etrap_needs_power ) && level.equipment_etrap_needs_power )
		{
			weapon.power_on = 0;
			maps/mp/zombies/_zm_power::add_temp_powered_item( ::trap_power_on, ::trap_power_off, ::trap_in_range, ::maps/mp/zombies/_zm_power::cost_high, 1, weapon.power_on, weapon );
		}
		else
		{
			weapon.power_on = 1;
		}
		if ( !weapon.power_on )
		{
			self iprintlnbold( &"ZOMBIE_NEED_LOCAL_POWER" );
		}
		self thread electrictrapthink( weapon, electricradius );
		if ( isDefined( level.equipment_etrap_needs_power ) && !level.equipment_etrap_needs_power )
		{
			self thread electrictrapdecay( weapon );
		}
		self thread maps/mp/zombies/_zm_buildables::delete_on_disconnect( weapon );
		weapon waittill( "death" );
		if ( isDefined( level.electrap_sound_ent ) )
		{
			level.electrap_sound_ent playsound( "wpn_zmb_electrap_stop" );
			level.electrap_sound_ent delete();
			level.electrap_sound_ent = undefined;
		}
		self notify( "etrap_cleanup" );
	}
}

trap_in_range( delta, origin, radius )
{
	if ( distancesquared( self.target.origin, origin ) < ( radius * radius ) )
	{
		return 1;
	}
	return 0;
}

trap_power_on( origin, radius )
{
/#
	println( "^1ZM POWER: trap on\n" );
#/
	if ( !isDefined( self.target ) )
	{
		return;
	}
	self.target.power_on = 1;
	self.target.power_on_time = getTime();
	if ( !isDefined( level.electrap_sound_ent ) )
	{
		level.electrap_sound_ent = spawn( "script_origin", self.target.origin );
	}
	level.electrap_sound_ent playsound( "wpn_zmb_electrap_start" );
	level.electrap_sound_ent playloopsound( "wpn_zmb_electrap_loop", 2 );
	self.target thread trapfx();
}

trap_power_off( origin, radius )
{
/#
	println( "^1ZM POWER: trap off\n" );
#/
	if ( !isDefined( self.target ) )
	{
		return;
	}
	self.target.power_on = 0;
	if ( isDefined( level.electrap_sound_ent ) )
	{
		level.electrap_sound_ent playsound( "wpn_zmb_electrap_stop" );
		level.electrap_sound_ent delete();
		level.electrap_sound_ent = undefined;
	}
}

trapfx()
{
	self endon( "disconnect" );
	while ( isDefined( self ) && isDefined( self.power_on ) && self.power_on )
	{
		playfxontag( level._effect[ "etrap_on" ], self, "tag_origin" );
		wait 0,3;
	}
}

zombie_attacked_trap( zombie )
{
	if ( isDefined( self.power_on ) && self.power_on )
	{
		self zap_zombie( zombie );
	}
}

electrocution_lockout( time )
{
	level.electrocuting_zombie = 1;
	wait time;
	level.electrocuting_zombie = 0;
}

zap_zombie( zombie )
{
	if ( isDefined( zombie.ignore_electric_trap ) && zombie.ignore_electric_trap )
	{
		return;
	}
	if ( zombie.health > level.etrap_damage )
	{
		zombie dodamage( level.etrap_damage, self.origin );
		zombie.ignore_electric_trap = 1;
		return;
	}
	self playsound( "wpn_zmb_electrap_zap" );
	if ( isDefined( level.electrocuting_zombie ) && !level.electrocuting_zombie )
	{
		thread electrocution_lockout( 2 );
		zombie thread play_elec_vocals();
		zombie thread maps/mp/zombies/_zm_traps::electroctute_death_fx();
		zombie.is_on_fire = 0;
		zombie notify( "stop_flame_damage" );
	}
	zombie thread electrictrapkill( self );
}

etrap_choke()
{
	if ( !isDefined( level.etrap_choke_count ) )
	{
		level.etrap_choke_count = 0;
	}
	level.etrap_choke_count++;
	if ( level.etrap_choke_count >= 5 )
	{
		wait 0,05;
		level.etrap_choke_count = 0;
	}
}

electrictrapthink( weapon, electricradius )
{
	weapon endon( "death" );
	radiussquared = electricradius * electricradius;
	while ( isDefined( weapon ) )
	{
		while ( weapon.power_on && ( getTime() - weapon.power_on_time ) > 2000 )
		{
			zombies = getaiarray( level.zombie_team );
			_a350 = zombies;
			_k350 = getFirstArrayKey( _a350 );
			while ( isDefined( _k350 ) )
			{
				zombie = _a350[ _k350 ];
				if ( !isDefined( zombie ) || !isalive( zombie ) )
				{
				}
				else
				{
					if ( isDefined( zombie.ignore_electric_trap ) && zombie.ignore_electric_trap )
					{
						break;
					}
					else
					{
						if ( distancesquared( weapon.origin, zombie.origin ) < radiussquared )
						{
							weapon zap_zombie( zombie );
							wait 0,15;
						}
						etrap_choke();
					}
				}
				_k350 = getNextArrayKey( _a350, _k350 );
			}
			players = get_players();
			_a369 = players;
			_k369 = getFirstArrayKey( _a369 );
			while ( isDefined( _k369 ) )
			{
				player = _a369[ _k369 ];
				if ( is_player_valid( player ) && distancesquared( weapon.origin, player.origin ) < radiussquared )
				{
					player thread maps/mp/zombies/_zm_traps::player_elec_damage();
					etrap_choke();
				}
				etrap_choke();
				_k369 = getNextArrayKey( _a369, _k369 );
			}
		}
		wait 0,1;
	}
}

electrictrapkill( weapon )
{
	self endon( "death" );
	wait randomfloatrange( 0,1, 0,4 );
	self dodamage( self.health + 666, self.origin );
}

electrictrapdecay( weapon )
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "equip_electrictrap_zm_taken" );
	while ( isDefined( weapon ) )
	{
		if ( weapon.power_on )
		{
			self.electrictrap_health--;

			if ( self.electrictrap_health <= 0 )
			{
				self cleanupoldtrap();
				self.electrictrap_health = undefined;
				self thread maps/mp/zombies/_zm_equipment::equipment_release( "equip_electrictrap_zm" );
				return;
			}
		}
		wait 1;
	}
}

debugelectrictrap( radius )
{
/#
	while ( isDefined( self ) )
	{
		if ( getDvarInt( #"EB512CB7" ) )
		{
			circle( self.origin, radius, ( 1, 1, 1 ), 0, 1, 1 );
		}
		wait 0,05;
#/
	}
}
