#include maps/mp/zombies/_zm_ai_basic;
#include maps/mp/_demo;
#include maps/mp/zombies/_zm_perks;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

init()
{
	if ( !isDefined( level.powered_items ) )
	{
		level.powered_items = [];
	}
	if ( !isDefined( level.local_power ) )
	{
		level.local_power = [];
	}
	thread standard_powered_items();
}

watch_global_power()
{
	while ( 1 )
	{
		flag_wait( "power_on" );
		level thread set_global_power( 1 );
		flag_waitopen( "power_on" );
		level thread set_global_power( 0 );
	}
}

standard_powered_items()
{
	flag_wait( "start_zombie_round_logic" );
	vending_triggers = getentarray( "zombie_vending", "targetname" );
	i = 0;
	while ( i < vending_triggers.size)
	{
		if ( vending_triggers[ i ].script_noteworthy == "specialty_weapupgrade" )
		{
			i++;
			continue;
		}
		powered_on = maps/mp/zombies/_zm_perks::get_perk_machine_start_state( vending_triggers[ i ].script_noteworthy );
		add_powered_item( ::perk_power_on, ::perk_power_off, ::perk_range, ::cost_low_if_local, 0, powered_on, vending_triggers[ i ] );
		i++;
	}
	pack_a_punch = getentarray( "specialty_weapupgrade", "script_noteworthy" );
	foreach ( trigger in pack_a_punch )
	{
		powered_on = maps/mp/zombies/_zm_perks::get_perk_machine_start_state( trigger.script_noteworthy );
		trigger.powered = add_powered_item( ::pap_power_on, ::pap_power_off, ::pap_range, ::cost_low_if_local, 0, powered_on, trigger );
	}
	zombie_doors = getentarray( "zombie_door", "targetname" );
	foreach ( door in zombie_doors )
	{
		if ( isDefined( door.script_noteworthy ) && door.script_noteworthy == "electric_door" )
		{
			add_powered_item( ::door_power_on, ::door_power_off, ::door_range, ::cost_door, 0, 0, door );
		}
		if ( isDefined( door.script_noteworthy ) && door.script_noteworthy == "local_electric_door" )
		{
			power_sources = 0;
			if ( !is_true( level.power_local_doors_globally ) )
			{
				power_sources = 1;
			}
			add_powered_item( ::door_local_power_on, ::door_local_power_off, ::door_range, ::cost_door, power_sources, 0, door );
		}
	}
	thread watch_global_power();
}

add_powered_item( power_on_func, power_off_func, range_func, cost_func, power_sources, self_powered, target )
{
	powered = spawnstruct();
	powered.power_on_func = power_on_func;
	powered.power_off_func = power_off_func;
	powered.range_func = range_func;
	powered.power_sources = power_sources;
	powered.self_powered = self_powered;
	powered.target = target;
	powered.cost_func = cost_func;
	powered.power = self_powered;
	powered.powered_count = self_powered;
	powered.depowered_count = 0;
	if ( !isDefined( level.powered_items ) )
	{
		level.powered_items = [];
	}
	level.powered_items[ level.powered_items.size ] = powered;
	return powered;
}

remove_powered_item( powered )
{
	arrayremovevalue( level.powered_items, powered, 0 );
}

add_temp_powered_item( power_on_func, power_off_func, range_func, cost_func, power_sources, self_powered, target )
{
	powered = add_powered_item( power_on_func, power_off_func, range_func, cost_func, power_sources, self_powered, target );
	if ( isDefined( level.local_power ) )
	{
		foreach ( localpower in level.local_power )
		{
			if ( powered [[ powered.range_func ]]( 1, localpower.origin, localpower.radius ) )
			{
				powered change_power( 1, localpower.origin, localpower.radius );
				if ( !isDefined( localpower.added_list ) )
				{
					localpower.added_list = [];
				}
				localpower.added_list[ localpower.added_list.size ] = powered;
			}
		}
	}
	thread watch_temp_powered_item( powered );
	return powered;
}

watch_temp_powered_item( powered )
{
	powered.target waittill( "death" );
	remove_powered_item( powered );
	if ( isDefined( level.local_power ) )
	{
		foreach ( localpower in level.local_power )
		{
			if ( isDefined( localpower.added_list ) )
			{
				arrayremovevalue( localpower.added_list, powered, 0 );
			}
			if ( isDefined( localpower.enabled_list ) )
			{
				arrayremovevalue( localpower.enabled_list, powered, 0 );
			}
		}
	}
}

change_power_in_radius( delta, origin, radius )
{
	changed_list = [];
	for ( i = 0; i < level.powered_items.size; i++ )
	{
		powered = level.powered_items[ i ];
		if ( powered.power_sources != 2 )
		{
			if ( powered [[ powered.range_func ]]( delta, origin, radius ) )
			{
				powered change_power( delta, origin, radius );
				changed_list[ changed_list.size ] = powered;
			}
		}
	}
	return changed_list;
}

change_power( delta, origin, radius )
{
	if ( delta > 0 )
	{
		if ( !self.power )
		{
			self.power = 1;
			self [[ self.power_on_func ]]( origin, radius );
		}
		self.powered_count++;
	}
	else if ( delta < 0 )
	{
		if ( self.power )
		{
			self.power = 0;
			self [[ self.power_off_func ]]( origin, radius );
		}
		self.depowered_count++;
	}
}

revert_power_to_list( delta, origin, radius, powered_list )
{
	for ( i = 0; i < powered_list.size; i++ )
	{
		powered = powered_list[ i ];
		powered revert_power( delta, origin, radius );
	}
}

revert_power( delta, origin, radius, powered_list )
{
	if ( delta > 0 )
	{
		self.depowered_count--;
		if ( self.depowered_count == 0 && self.powered_count > 0 && !self.power )
		{
			self.power = 1;
			self [[ self.power_on_func ]]( origin, radius );
		}
	}
	if ( delta < 0 )
	{
		self.powered_count--;
		if ( self.powered_count == 0 && self.power )
		{
			self.power = 0;
			self [[ self.power_off_func ]]( origin, radius );
		}
	}
}

add_local_power( origin, radius )
{
	localpower = spawnstruct();
	localpower.origin = origin;
	localpower.radius = radius;
	localpower.enabled_list = change_power_in_radius( 1, origin, radius );
	if ( !isDefined( level.local_power ) )
	{
		level.local_power = [];
	}
	level.local_power[ level.local_power.size ] = localpower;
	return localpower;
}

move_local_power( localpower, origin )
{
	changed_list = [];
	i = 0;
	while ( i < level.powered_items.size )
	{
		powered = level.powered_items[ i ];
		if ( powered.power_sources == 2 )
		{
			i++;
			continue;
		}
		waspowered = isinarray( localpower.enabled_list, powered );
		ispowered = powered [[ powered.range_func ]]( 1, origin, localpower.radius );
		if ( ispowered && !waspowered )
		{
			powered change_power( 1, origin, localpower.radius );
			localpower.enabled_list[ localpower.enabled_list.size ] = powered;
			i++;
			continue;
		}
		if ( !ispowered && waspowered )
		{
			powered revert_power( -1, localpower.origin, localpower.radius, localpower.enabled_list );
			arrayremovevalue( localpower.enabled_list, powered, 0 );
		}
		i++;
	}
	localpower.origin = origin;
	return localpower;
}

end_local_power( localpower )
{
	if ( isDefined( localpower.enabled_list ) )
	{
		revert_power_to_list( -1, localpower.origin, localpower.radius, localpower.enabled_list );
	}
	localpower.enabled_list = undefined;
	if ( isDefined( localpower.added_list ) )
	{
		revert_power_to_list( -1, localpower.origin, localpower.radius, localpower.added_list );
	}
	localpower.added_list = undefined;
	arrayremovevalue( level.local_power, localpower, 0 );
}

has_local_power( origin )
{
	if ( isDefined( level.local_power ) )
	{
		foreach ( localpower in level.local_power )
		{
			if ( distancesquared( localpower.origin, origin ) < ( localpower.radius * localpower.radius ) )
			{
				return 1;
			}
		}
	}
	return 0;
}

get_powered_item_cost()
{
	if ( !is_true( self.power ) )
	{
		return 0;
	}
	if ( is_true( level._power_global ) && self.power_sources != 1 )
	{
		return 0;
	}
	cost = [[ self.cost_func ]]();
	power_sources = self.powered_count;
	if ( power_sources < 1 )
	{
		power_sources = 1;
	}
	return cost / power_sources;
}

get_local_power_cost( localpower )
{
	cost = 0;
	if ( isDefined( localpower ) && isDefined( localpower.enabled_list ) )
	{
		foreach ( powered in localpower.enabled_list )
		{
			cost += powered get_powered_item_cost();
		}
	}
	else if ( isDefined( localpower ) && isDefined( localpower.added_list ) )
	{
		foreach ( powered in localpower.added_list )
		{
			cost += powered get_powered_item_cost();
		}
	}
	return cost;
}

set_global_power( on_off )
{
	maps/mp/_demo::bookmark( "zm_power", getTime(), undefined, undefined, 1 );
	level._power_global = on_off;
	for ( i = 0; i < level.powered_items.size; i++ )
	{
		powered = level.powered_items[ i ];
		if ( isDefined( powered.target ) && powered.power_sources != 1 )
		{
			powered global_power( on_off );
			wait_network_frame();
		}
	}
}

global_power( on_off )
{
	if ( on_off )
	{
		if ( !self.power )
		{
			self.power = 1;
			self [[ self.power_on_func ]]();
		}
		self.powered_count++;
	}
	else
	{
		self.powered_count--;
		if ( self.powered_count == 0 && self.power )
		{
			self.power = 0;
			self [[ self.power_off_func ]]();
		}
	}
}

never_power_on( origin, radius )
{
}

never_power_off( origin, radius )
{
}

cost_negligible()
{
	if ( isDefined( self.one_time_cost ) )
	{
		cost = self.one_time_cost;
		self.one_time_cost = undefined;
		return cost;
	}
	return 0;
}

cost_low_if_local()
{
	if ( isDefined( self.one_time_cost ) )
	{
		cost = self.one_time_cost;
		self.one_time_cost = undefined;
		return cost;
	}
	if ( is_true( level._power_global ) )
	{
		return 0;
	}
	if ( is_true( self.self_powered ) )
	{
		return 0;
	}
	return 1;
}

cost_high()
{
	if ( isDefined( self.one_time_cost ) )
	{
		cost = self.one_time_cost;
		self.one_time_cost = undefined;
		return cost;
	}
	return 10;
}

door_range( delta, origin, radius )
{
	if ( delta < 0 )
	{
		return 0;
	}
	if ( distancesquared( self.target.origin, origin ) < radius * radius )
	{
		return 1;
	}
	return 0;
}

door_power_on( origin, radius )
{
	self.target.power_on = 1;
	self.target notify( "power_on" );
}

door_power_off( origin, radius )
{
	self.target notify( "power_off" );
	self.target.power_on = 0;
}

door_local_power_on( origin, radius )
{
	self.target.local_power_on = 1;
	self.target notify( "local_power_on" );
}

door_local_power_off( origin, radius )
{
	self.target notify( "local_power_off" );
	self.target.local_power_on = 0;
}

cost_door()
{
	if ( isDefined( self.target.power_cost ) )
	{
		if ( !isDefined( self.one_time_cost ) )
		{
			self.one_time_cost = 0;
		}
		self.one_time_cost += self.target.power_cost;
		self.target.power_cost = 0;
	}
	if ( isDefined( self.one_time_cost ) )
	{
		cost = self.one_time_cost;
		self.one_time_cost = undefined;
		return cost;
	}
	return 0;
}

zombie_range( delta, origin, radius )
{
	if ( delta > 0 )
	{
		return 0;
	}
	self.zombies = get_array_of_closest( origin, get_round_enemy_array(), undefined, undefined, radius );
	if ( !isDefined( self.zombies ) )
	{
		return 0;
	}
	self.power = 1;
	return 1;
}

zombie_power_off( origin, radius )
{
	for ( i = 0; i < self.zombies.size; i++ )
	{
		self.zombies[ i ] thread stun_zombie();
		wait 0.05;
	}
}

stun_zombie()
{
	self endon( "death" );
	self notify( "stun_zombie" );
	self endon( "stun_zombie" );
	if ( self.health <= 0 )
	{
		return;
	}
	if ( is_true( self.ignore_inert ) )
	{
		return;
	}
	if ( isDefined( self.stun_zombie ) )
	{
		self thread [[ self.stun_zombie ]]();
		return;
	}
	self thread maps/mp/zombies/_zm_ai_basic::start_inert();
}

perk_range( delta, origin, radius )
{
	if ( isDefined( self.target ) )
	{
		perkorigin = self.target.origin;
		if ( is_true( self.target.trigger_off ) )
		{
			perkorigin = self.target.realorigin;
		}
		else if ( is_true( self.target.disabled ) )
		{
			perkorigin += vectorScale( ( 0, 0, 1 ), 10000 );
		}
		if ( distancesquared( perkorigin, origin ) < radius * radius )
		{
			return 1;
		}
	}
	return 0;
}

perk_power_on( origin, radius )
{
	level notify( self.target maps/mp/zombies/_zm_perks::getvendingmachinenotify() + "_on" );
	maps/mp/zombies/_zm_perks::perk_unpause( self.target.script_noteworthy );
}

perk_power_off( origin, radius )
{
	notify_name = self.target maps/mp/zombies/_zm_perks::getvendingmachinenotify();
	if ( isDefined( notify_name ) && notify_name == "revive" )
	{
		if ( level flag_exists( "solo_game" ) && flag( "solo_game" ) )
		{
			return;
		}
	}
	self.target notify( "death" );
	self.target thread maps/mp/zombies/_zm_perks::vending_trigger_think();
	if ( isDefined( self.target.perk_hum ) )
	{
		self.target.perk_hum delete();
	}
	maps/mp/zombies/_zm_perks::perk_pause( self.target.script_noteworthy );
	level notify( self.target maps/mp/zombies/_zm_perks::getvendingmachinenotify() + "_off" );
}

pap_range( delta, origin, radius )
{
	if ( isDefined( self.target ) )
	{
		paporigin = self.target.origin;
		if ( is_true( self.target.trigger_off ) )
		{
			paporigin = self.target.realorigin;
		}
		else if ( is_true( self.target.disabled ) )
		{
			paporigin += vectorScale( ( 0, 0, 1 ), 10000 );
		}
		if ( distancesquared( paporigin, origin ) < ( radius * radius ) )
		{
			return 1;
		}
	}
	return 0;
}

pap_power_on( origin, radius )
{
	level notify( "Pack_A_Punch_on" );
}

pap_power_off( origin, radius )
{
	level notify( "Pack_A_Punch_off" );
	self.target notify( "death" );
	self.target thread maps/mp/zombies/_zm_perks::vending_weapon_upgrade();
}

pap_is_on()
{
	if ( isDefined( self.powered ) )
	{
		return self.powered.power;
	}
	return 0;
}

