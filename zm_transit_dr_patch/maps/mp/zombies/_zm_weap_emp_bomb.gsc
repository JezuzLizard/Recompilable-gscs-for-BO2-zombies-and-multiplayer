#include maps/mp/zombies/_zm_equipment;
#include maps/mp/zombies/_zm_ai_basic;
#include maps/mp/zombies/_zm_power;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

init()
{
	if ( !emp_bomb_exists() )
	{
		return;
	}
	set_zombie_var( "emp_stun_range", 600 );
	set_zombie_var( "emp_stun_time", 20 );
	set_zombie_var( "emp_perk_off_range", 420 );
	set_zombie_var( "emp_perk_off_time", 90 );
	precacheshellshock( "frag_grenade_mp" );
/#
	level.zombiemode_devgui_emp_bomb_give = ::player_give_emp_bomb;
#/
	level thread onplayerconnect();
	level._equipment_emp_destroy_fx = loadfx( "weapon/emp/fx_emp_explosion_equip" );
}

onplayerconnect()
{
	for ( ;; )
	{
		level waittill( "connecting", player );
		player thread watch_for_grenade_throw();
	}
}

player_give_emp_bomb()
{
	self giveweapon( "emp_grenade_zm" );
	self set_player_tactical_grenade( "emp_grenade_zm" );
}

emp_bomb_exists()
{
	return isDefined( level.zombie_weapons[ "emp_grenade_zm" ] );
}

watch_for_grenade_throw()
{
	self endon( "disconnect" );
	while ( 1 )
	{
		self waittill( "grenade_fire", grenade, weapname );
		while ( weapname != "emp_grenade_zm" )
		{
			continue;
		}
		grenade.use_grenade_special_bookmark = 1;
		grenade.grenade_multiattack_bookmark_count = 1;
		grenade.owner = self;
		self thread emp_detonate( grenade );
	}
}

emp_detonate( grenade )
{
	grenade_owner = undefined;
	if ( isDefined( grenade.owner ) )
	{
		grenade_owner = grenade.owner;
	}
	grenade waittill( "explode", grenade_origin );
	emp_radius = level.zombie_vars[ "emp_perk_off_range" ];
	emp_time = level.zombie_vars[ "emp_perk_off_time" ];
	origin = grenade_origin;
	if ( !isDefined( origin ) )
	{
		return;
	}
	level notify( "emp_detonate" );
	self thread emp_detonate_zombies( grenade_origin, grenade_owner );
	if ( isDefined( level.custom_emp_detonate ) )
	{
		thread [[ level.custom_emp_detonate ]]( grenade_origin );
	}
	if ( isDefined( grenade_owner ) )
	{
		grenade_owner thread destroyequipment( origin, emp_radius );
	}
	players_emped = emp_players( origin, emp_radius );
	disabled_list = maps/mp/zombies/_zm_power::change_power_in_radius( -1, origin, emp_radius );
	wait emp_time;
	maps/mp/zombies/_zm_power::revert_power_to_list( 1, origin, emp_radius, disabled_list );
	unemp_players( players_emped );
}

emp_detonate_zombies( grenade_origin, grenade_owner )
{
	zombies = get_array_of_closest( grenade_origin, getaispeciesarray( level.zombie_team, "all" ), undefined, undefined, level.zombie_vars[ "emp_stun_range" ] );
	if ( !isDefined( zombies ) )
	{
		return;
	}
	i = 0;
	while ( i < zombies.size )
	{
		if ( !isDefined( zombies[ i ] ) || isDefined( zombies[ i ].ignore_inert ) && zombies[ i ].ignore_inert )
		{
			i++;
			continue;
		}
		else
		{
			zombies[ i ].becoming_inert = 1;
		}
		i++;
	}
	stunned = 0;
	i = 0;
	while ( i < zombies.size )
	{
		if ( !isDefined( zombies[ i ] ) || isDefined( zombies[ i ].ignore_inert ) && zombies[ i ].ignore_inert )
		{
			i++;
			continue;
		}
		else
		{
			stunned++;
			zombies[ i ] thread stun_zombie();
			wait 0,05;
		}
		i++;
	}
	if ( stunned >= 10 && isDefined( grenade_owner ) )
	{
		grenade_owner notify( "the_lights_of_their_eyes" );
	}
}

stun_zombie()
{
	self endon( "death" );
	self notify( "stun_zombie" );
	self endon( "stun_zombie" );
	if ( self.health <= 0 )
	{
/#
		iprintln( "trying to stun a dead zombie" );
#/
		return;
	}
	if ( isDefined( self.stun_zombie ) )
	{
		self thread [[ self.stun_zombie ]]();
		return;
	}
	self thread maps/mp/zombies/_zm_ai_basic::start_inert();
}

emp_players( origin, radius )
{
	players_emped = [];
	players = get_players();
	rsquared = radius * radius;
	_a192 = players;
	_k192 = getFirstArrayKey( _a192 );
	while ( isDefined( _k192 ) )
	{
		player = _a192[ _k192 ];
		if ( isalive( player ) && distancesquared( origin, player.origin ) < rsquared )
		{
			player player_emp_on();
			players_emped[ players_emped.size ] = player;
		}
		_k192 = getNextArrayKey( _a192, _k192 );
	}
	return players_emped;
}

unemp_players( players_emped )
{
	_a206 = players_emped;
	_k206 = getFirstArrayKey( _a206 );
	while ( isDefined( _k206 ) )
	{
		player = _a206[ _k206 ];
		player player_emp_off();
		_k206 = getNextArrayKey( _a206, _k206 );
	}
}

player_emp_on()
{
	self.empgrenaded = 1;
	self setempjammed( 1 );
	self shellshock( "frag_grenade_mp", 2 );
}

player_emp_off()
{
	if ( isDefined( self ) )
	{
		self stopshellshock();
		self setempjammed( 0 );
		self.empgrenaded = undefined;
	}
}

getwatcherforweapon( weapname )
{
	if ( !isDefined( self ) )
	{
		return undefined;
	}
	if ( !isplayer( self ) )
	{
		return undefined;
	}
	i = 0;
	while ( i < self.weaponobjectwatcherarray.size )
	{
		if ( self.weaponobjectwatcherarray[ i ].weapon != weapname )
		{
			i++;
			continue;
		}
		else
		{
			return self.weaponobjectwatcherarray[ i ];
		}
		i++;
	}
	return undefined;
}

destroyequipment( origin, radius )
{
	grenades = getentarray( "grenade", "classname" );
	rsquared = radius * radius;
	i = 0;
	while ( i < grenades.size )
	{
		item = grenades[ i ];
		if ( distancesquared( origin, item.origin ) > rsquared )
		{
			i++;
			continue;
		}
		else if ( !isDefined( item.name ) )
		{
			i++;
			continue;
		}
		else if ( !is_offhand_weapon( item.name ) )
		{
			i++;
			continue;
		}
		else watcher = item.owner getwatcherforweapon( item.name );
		if ( !isDefined( watcher ) )
		{
			i++;
			continue;
		}
		else
		{
			watcher thread waitanddetonate( item, 0, self, "emp_grenade_zm" );
		}
		i++;
	}
	equipment = maps/mp/zombies/_zm_equipment::get_destructible_equipment_list();
	i = 0;
	while ( i < equipment.size )
	{
		item = equipment[ i ];
		if ( !isDefined( item ) )
		{
			i++;
			continue;
		}
		else if ( distancesquared( origin, item.origin ) > rsquared )
		{
			i++;
			continue;
		}
		else if ( isDefined( item.isriotshield ) && item.isriotshield )
		{
			i++;
			continue;
		}
		else
		{
			waitanddamage( item, 505 );
		}
		i++;
	}
}

isempweapon( weaponname )
{
	if ( isDefined( weaponname ) && weaponname != "emp_mp" || weaponname == "emp_grenade_mp" && weaponname == "emp_grenade_zm" )
	{
		return 1;
	}
	return 0;
}

waitanddetonate( object, delay, attacker, weaponname )
{
	object endon( "death" );
	object endon( "hacked" );
	from_emp = isempweapon( weaponname );
	if ( from_emp )
	{
		object.stun_fx = 1;
		if ( isDefined( level._equipment_emp_destroy_fx ) )
		{
			playfx( level._equipment_emp_destroy_fx, object.origin + vectorScale( ( 0, 0, 1 ), 5 ), ( 0, randomfloat( 360 ), 0 ) );
		}
		delay = 1,1;
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
		else
		{
			if ( attacker != object.owner )
			{
				attacker notify( "destroyed_explosive" );
			}
		}
	}
	object.detonated = 1;
	object [[ self.detonate ]]( attacker, weaponname );
}

waitanddamage( object, damage )
{
	object endon( "death" );
	object endon( "hacked" );
	object.stun_fx = 1;
	if ( isDefined( level._equipment_emp_destroy_fx ) )
	{
		playfx( level._equipment_emp_destroy_fx, object.origin + vectorScale( ( 0, 0, 1 ), 5 ), ( 0, randomfloat( 360 ), 0 ) );
	}
	delay = 1,1;
	if ( delay )
	{
		wait delay;
	}
	object maps/mp/zombies/_zm_equipment::item_damage( damage );
}
