#include maps/mp/zombies/_zm_perks;
#include maps/mp/zombies/_zm_equipment;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_weap_cymbal_monkey;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;

init()
{
	onplayerconnect_callback( ::tombstone_player_init );
	level.tombstone_laststand_func = ::tombstone_laststand;
	level.tombstone_spawn_func = ::tombstone_spawn;
	level thread tombstone_hostmigration();
}

tombstone_player_init()
{
	while ( !isDefined( self.tombstone_index ) )
	{
		wait 0,1;
	}
	level.tombstones[ self.tombstone_index ] = spawnstruct();
}

tombstone_spawn()
{
	dc = spawn( "script_model", self.origin + vectorScale( ( 0, 0, 1 ), 40 ) );
	dc.angles = self.angles;
	dc setmodel( "tag_origin" );
	dc_icon = spawn( "script_model", self.origin + vectorScale( ( 0, 0, 1 ), 40 ) );
	dc_icon.angles = self.angles;
	dc_icon setmodel( "ch_tombstone1" );
	dc_icon linkto( dc );
	dc.icon = dc_icon;
	dc.script_noteworthy = "player_tombstone_model";
	dc.player = self;
	dc thread tombstone_wobble();
	dc thread tombstone_revived( self );
	result = self waittill_any_return( "player_revived", "spawned_player", "disconnect" );
	if ( result == "player_revived" || result == "disconnect" )
	{
		dc notify( "tombstone_timedout" );
		dc_icon unlink();
		dc_icon delete();
		dc delete();
		return;
	}
	dc thread tombstone_timeout();
	dc thread tombstone_grab();
}

tombstone_revived( player )
{
	self endon( "tombstone_timedout" );
	player endon( "disconnect" );
	shown = 1;
	while ( isDefined( self ) && isDefined( player ) )
	{
		if ( isDefined( player.revivetrigger ) && isDefined( player.revivetrigger.beingrevived ) && player.revivetrigger.beingrevived )
		{
			if ( shown )
			{
				shown = 0;
				self.icon hide();
			}
		}
		else
		{
			if ( !shown )
			{
				shown = 1;
				self.icon show();
			}
		}
		wait 0,05;
	}
}

tombstone_laststand()
{
	primaries = self getweaponslistprimaries();
	currentweapon = self getcurrentweapon();
	dc = level.tombstones[ self.tombstone_index ];
	dc.player = self;
	dc.weapon = [];
	dc.current_weapon = -1;
	_a118 = primaries;
	index = getFirstArrayKey( _a118 );
	while ( isDefined( index ) )
	{
		weapon = _a118[ index ];
		dc.weapon[ index ] = weapon;
		dc.stockcount[ index ] = self getweaponammostock( weapon );
		if ( weapon == currentweapon )
		{
			dc.current_weapon = index;
		}
		index = getNextArrayKey( _a118, index );
	}
	if ( isDefined( self.hasriotshield ) && self.hasriotshield )
	{
		dc.hasriotshield = 1;
	}
	dc save_weapons_for_tombstone( self );
	if ( self hasweapon( "claymore_zm" ) )
	{
		dc.hasclaymore = 1;
		dc.claymoreclip = self getweaponammoclip( "claymore_zm" );
	}
	if ( self hasweapon( "emp_grenade_zm" ) )
	{
		dc.hasemp = 1;
		dc.empclip = self getweaponammoclip( "emp_grenade_zm" );
	}
	dc.perk = tombstone_save_perks( self );
	lethal_grenade = self get_player_lethal_grenade();
	if ( self hasweapon( lethal_grenade ) )
	{
		dc.grenade = self getweaponammoclip( lethal_grenade );
	}
	else
	{
		dc.grenade = 0;
	}
	if ( maps/mp/zombies/_zm_weap_cymbal_monkey::cymbal_monkey_exists() )
	{
		dc.zombie_cymbal_monkey_count = self getweaponammoclip( "cymbal_monkey_zm" );
	}
}

tombstone_save_perks( ent )
{
	perk_array = [];
	if ( ent hasperk( "specialty_armorvest" ) )
	{
		perk_array[ perk_array.size ] = "specialty_armorvest";
	}
	if ( ent hasperk( "specialty_deadshot" ) )
	{
		perk_array[ perk_array.size ] = "specialty_deadshot";
	}
	if ( ent hasperk( "specialty_fastreload" ) )
	{
		perk_array[ perk_array.size ] = "specialty_fastreload";
	}
	if ( ent hasperk( "specialty_flakjacket" ) )
	{
		perk_array[ perk_array.size ] = "specialty_flakjacket";
	}
	if ( ent hasperk( "specialty_longersprint" ) )
	{
		perk_array[ perk_array.size ] = "specialty_longersprint";
	}
	if ( ent hasperk( "specialty_quickrevive" ) )
	{
		perk_array[ perk_array.size ] = "specialty_quickrevive";
	}
	if ( ent hasperk( "specialty_rof" ) )
	{
		perk_array[ perk_array.size ] = "specialty_rof";
	}
	return perk_array;
}

tombstone_grab()
{
	self endon( "tombstone_timedout" );
	wait 1;
	while ( isDefined( self ) )
	{
		players = get_players();
		i = 0;
		while ( i < players.size )
		{
			if ( players[ i ].is_zombie )
			{
				i++;
				continue;
			}
			else
			{
				if ( isDefined( self.player ) && players[ i ] == self.player )
				{
					tombstone_machine_triggers = getentarray( "specialty_scavenger", "script_noteworthy" );
					istombstonepowered = 0;
					_a242 = tombstone_machine_triggers;
					_k242 = getFirstArrayKey( _a242 );
					while ( isDefined( _k242 ) )
					{
						trigger = _a242[ _k242 ];
						if ( isDefined( trigger.power_on ) || trigger.power_on && isDefined( trigger.turbine_power_on ) && trigger.turbine_power_on )
						{
							istombstonepowered = 1;
						}
						_k242 = getNextArrayKey( _a242, _k242 );
					}
					if ( istombstonepowered )
					{
						dist = distance( players[ i ].origin, self.origin );
						if ( dist < 64 )
						{
							playfx( level._effect[ "powerup_grabbed" ], self.origin );
							playfx( level._effect[ "powerup_grabbed_wave" ], self.origin );
							players[ i ] tombstone_give();
							wait 0,1;
							playsoundatposition( "zmb_tombstone_grab", self.origin );
							self stoploopsound();
							self.icon unlink();
							self.icon delete();
							self delete();
							self notify( "tombstone_grabbed" );
							players[ i ] clientnotify( "dc0" );
							players[ i ] notify( "dance_on_my_grave" );
						}
					}
				}
			}
			i++;
		}
		wait_network_frame();
	}
}

tombstone_give()
{
	dc = level.tombstones[ self.tombstone_index ];
	while ( !flag( "solo_game" ) )
	{
		primaries = self getweaponslistprimaries();
		while ( dc.weapon.size > 1 || primaries.size > 1 )
		{
			_a294 = primaries;
			_k294 = getFirstArrayKey( _a294 );
			while ( isDefined( _k294 ) )
			{
				weapon = _a294[ _k294 ];
				self takeweapon( weapon );
				_k294 = getNextArrayKey( _a294, _k294 );
			}
		}
		i = 0;
		while ( i < dc.weapon.size )
		{
			if ( !isDefined( dc.weapon[ i ] ) )
			{
				i++;
				continue;
			}
			else if ( dc.weapon[ i ] == "none" )
			{
				i++;
				continue;
			}
			else
			{
				weapon = dc.weapon[ i ];
				stock = dc.stockcount[ i ];
				if ( !self hasweapon( weapon ) )
				{
					self giveweapon( weapon, 0, self maps/mp/zombies/_zm_weapons::get_pack_a_punch_weapon_options( weapon ) );
					self setweaponammoclip( weapon, weaponclipsize( weapon ) );
					self setweaponammostock( weapon, stock );
					if ( i == dc.current_weapon )
					{
						self switchtoweapon( weapon );
					}
				}
			}
			i++;
		}
	}
	if ( isDefined( dc.hasriotshield ) && dc.hasriotshield )
	{
		self maps/mp/zombies/_zm_equipment::equipment_give( "riotshield_zm" );
		if ( isDefined( self.player_shield_reset_health ) )
		{
			self [[ self.player_shield_reset_health ]]();
		}
	}
	dc restore_weapons_for_tombstone( self );
	if ( isDefined( dc.hasclaymore ) && dc.hasclaymore && !self hasweapon( "claymore_zm" ) )
	{
		self giveweapon( "claymore_zm" );
		self set_player_placeable_mine( "claymore_zm" );
		self setactionslot( 4, "weapon", "claymore_zm" );
		self setweaponammoclip( "claymore_zm", dc.claymoreclip );
	}
	if ( isDefined( dc.hasemp ) && dc.hasemp )
	{
		self giveweapon( "emp_grenade_zm" );
		self setweaponammoclip( "emp_grenade_zm", dc.empclip );
	}
	while ( isDefined( dc.perk ) && dc.perk.size > 0 )
	{
		i = 0;
		while ( i < dc.perk.size )
		{
			if ( self hasperk( dc.perk[ i ] ) )
			{
				i++;
				continue;
			}
			else if ( dc.perk[ i ] == "specialty_quickrevive" && flag( "solo_game" ) )
			{
				i++;
				continue;
			}
			else
			{
				maps/mp/zombies/_zm_perks::give_perk( dc.perk[ i ] );
			}
			i++;
		}
	}
	if ( dc.grenade > 0 && !flag( "solo_game" ) )
	{
		curgrenadecount = 0;
		if ( self hasweapon( self get_player_lethal_grenade() ) )
		{
			self getweaponammoclip( self get_player_lethal_grenade() );
		}
		else
		{
			self giveweapon( self get_player_lethal_grenade() );
		}
		self setweaponammoclip( self get_player_lethal_grenade(), dc.grenade + curgrenadecount );
	}
	if ( maps/mp/zombies/_zm_weap_cymbal_monkey::cymbal_monkey_exists() && !flag( "solo_game" ) )
	{
		if ( dc.zombie_cymbal_monkey_count )
		{
			self maps/mp/zombies/_zm_weap_cymbal_monkey::player_give_cymbal_monkey();
			self setweaponammoclip( "cymbal_monkey_zm", dc.zombie_cymbal_monkey_count );
		}
	}
}

tombstone_wobble()
{
	self endon( "tombstone_grabbed" );
	self endon( "tombstone_timedout" );
	if ( isDefined( self ) )
	{
		wait 1;
		playfxontag( level._effect[ "powerup_on" ], self, "tag_origin" );
		self playsound( "zmb_tombstone_spawn" );
		self playloopsound( "zmb_tombstone_looper" );
	}
	while ( isDefined( self ) )
	{
		self rotateyaw( 360, 3 );
		wait 2,9;
	}
}

tombstone_timeout()
{
	self endon( "tombstone_grabbed" );
	self thread playtombstonetimeraudio();
	wait 48,5;
	i = 0;
	while ( i < 40 )
	{
		if ( i % 2 )
		{
			self.icon ghost();
		}
		else
		{
			self.icon show();
		}
		if ( i < 15 )
		{
			wait 0,5;
			i++;
			continue;
		}
		else if ( i < 25 )
		{
			wait 0,25;
			i++;
			continue;
		}
		else
		{
			wait 0,1;
		}
		i++;
	}
	self notify( "tombstone_timedout" );
	self.icon unlink();
	self.icon delete();
	self delete();
}

playtombstonetimeraudio()
{
	self endon( "tombstone_grabbed" );
	self endon( "tombstone_timedout" );
	player = self.player;
	self thread playtombstonetimerout( player );
	while ( 1 )
	{
		player playsoundtoplayer( "zmb_tombstone_timer_count", player );
		wait 1;
	}
}

playtombstonetimerout( player )
{
	self endon( "tombstone_grabbed" );
	self waittill( "tombstone_timedout" );
	player playsoundtoplayer( "zmb_tombstone_timer_out", player );
}

save_weapons_for_tombstone( player )
{
	self.tombstone_melee_weapons = [];
	i = 0;
	while ( i < level._melee_weapons.size )
	{
		self save_weapon_for_tombstone( player, level._melee_weapons[ i ].weapon_name );
		i++;
	}
}

save_weapon_for_tombstone( player, weapon_name )
{
	if ( player hasweapon( weapon_name ) )
	{
		self.tombstone_melee_weapons[ weapon_name ] = 1;
	}
}

restore_weapons_for_tombstone( player )
{
	i = 0;
	while ( i < level._melee_weapons.size )
	{
		self restore_weapon_for_tombstone( player, level._melee_weapons[ i ].weapon_name );
		i++;
	}
	self.tombstone_melee_weapons = undefined;
}

restore_weapon_for_tombstone( player, weapon_name )
{
	if ( isDefined( weapon_name ) || !isDefined( self.tombstone_melee_weapons ) && !isDefined( self.tombstone_melee_weapons[ weapon_name ] ) )
	{
		return;
	}
	if ( isDefined( self.tombstone_melee_weapons[ weapon_name ] ) && self.tombstone_melee_weapons[ weapon_name ] )
	{
		player giveweapon( weapon_name );
		player set_player_melee_weapon( weapon_name );
		self.tombstone_melee_weapons[ weapon_name ] = 0;
	}
}

tombstone_hostmigration()
{
	level endon( "end_game" );
	level notify( "tombstone_hostmigration" );
	level endon( "tombstone_hostmigration" );
	while ( 1 )
	{
		level waittill( "host_migration_end" );
		tombstones = getentarray( "player_tombstone_model", "script_noteworthy" );
		_a564 = tombstones;
		_k564 = getFirstArrayKey( _a564 );
		while ( isDefined( _k564 ) )
		{
			model = _a564[ _k564 ];
			playfxontag( level._effect[ "powerup_on" ], model, "tag_origin" );
			_k564 = getNextArrayKey( _a564, _k564 );
		}
	}
}
