#include maps/mp/zombies/_zm_zonemgr;
#include maps/mp/gametypes_zm/_zm_gametype;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

init()
{
/#
	println( "ZM >> Zombiemode Server Scripts Init (_zm_zonemgr.gsc)" );
#/
	flag_init( "zones_initialized" );
	level.zones = [];
	level.zone_flags = [];
	level.zone_scanning_active = 0;
	if ( !isDefined( level.create_spawner_list_func ) )
	{
		level.create_spawner_list_func = ::create_spawner_list;
	}
}

zone_is_enabled( zone_name )
{
	if ( isDefined( level.zones ) || !isDefined( level.zones[ zone_name ] ) && !level.zones[ zone_name ].is_enabled )
	{
		return 0;
	}
	return 1;
}

get_player_zone()
{
	player_zone = undefined;
	keys = getarraykeys( level.zones );
	i = 0;
	while ( i < keys.size )
	{
		if ( self entity_in_zone( keys[ i ] ) )
		{
			player_zone = keys[ i ];
			break;
		}
		else
		{
			i++;
		}
	}
	return player_zone;
}

get_zone_from_position( v_pos )
{
	zone = undefined;
	scr_org = spawn( "script_origin", v_pos );
	keys = getarraykeys( level.zones );
	i = 0;
	while ( i < keys.size )
	{
		if ( scr_org entity_in_zone( keys[ i ] ) )
		{
			zone = keys[ i ];
			break;
		}
		else
		{
			i++;
		}
	}
	scr_org delete();
	return zone;
}

get_zone_magic_boxes( zone_name )
{
	if ( isDefined( zone_name ) && !zone_is_enabled( zone_name ) )
	{
		return undefined;
	}
	zone = level.zones[ zone_name ];
/#
	assert( isDefined( zone_name ) );
#/
	return zone.magic_boxes;
}

get_zone_zbarriers( zone_name )
{
	if ( isDefined( zone_name ) && !zone_is_enabled( zone_name ) )
	{
		return undefined;
	}
	zone = level.zones[ zone_name ];
/#
	assert( isDefined( zone_name ) );
#/
	return zone.zbarriers;
}

get_players_in_zone( zone_name, return_players )
{
	if ( !zone_is_enabled( zone_name ) )
	{
		return 0;
	}
	zone = level.zones[ zone_name ];
	num_in_zone = 0;
	players_in_zone = [];
	players = get_players();
	i = 0;
	while ( i < zone.volumes.size )
	{
		j = 0;
		while ( j < players.size )
		{
			if ( players[ j ] istouching( zone.volumes[ i ] ) )
			{
				num_in_zone++;
				players_in_zone[ players_in_zone.size ] = players[ j ];
			}
			j++;
		}
		i++;
	}
	if ( isDefined( return_players ) )
	{
		return players_in_zone;
	}
	return num_in_zone;
}

player_in_zone( zone_name )
{
	if ( !zone_is_enabled( zone_name ) )
	{
		return 0;
	}
	zone = level.zones[ zone_name ];
	i = 0;
	while ( i < zone.volumes.size )
	{
		players = get_players();
		j = 0;
		while ( j < players.size )
		{
			if ( players[ j ] istouching( zone.volumes[ i ] ) && players[ j ].sessionstate != "spectator" )
			{
				return 1;
			}
			j++;
		}
		i++;
	}
	return 0;
}

entity_in_zone( zone_name, ignore_enabled_check )
{
	if ( !zone_is_enabled( zone_name ) && isDefined( ignore_enabled_check ) && !ignore_enabled_check )
	{
		return 0;
	}
	zone = level.zones[ zone_name ];
	i = 0;
	while ( i < zone.volumes.size )
	{
		if ( self istouching( zone.volumes[ i ] ) )
		{
			return 1;
		}
		i++;
	}
	return 0;
}

deactivate_initial_barrier_goals()
{
	special_goals = getstructarray( "exterior_goal", "targetname" );
	i = 0;
	while ( i < special_goals.size )
	{
		if ( isDefined( special_goals[ i ].script_noteworthy ) )
		{
			special_goals[ i ].is_active = 0;
			special_goals[ i ] trigger_off();
		}
		i++;
	}
}

zone_init( zone_name )
{
	if ( isDefined( level.zones[ zone_name ] ) )
	{
		return;
	}
/#
	println( "ZM >> zone_init (1) = " + zone_name );
#/
	level.zones[ zone_name ] = spawnstruct();
	zone = level.zones[ zone_name ];
	zone.is_enabled = 0;
	zone.is_occupied = 0;
	zone.is_active = 0;
	zone.adjacent_zones = [];
	zone.is_spawning_allowed = 0;
	zone.volumes = [];
	volumes = getentarray( zone_name, "targetname" );
/#
	println( "ZM >> zone_init (2) = " + volumes.size );
#/
	i = 0;
	while ( i < volumes.size )
	{
		if ( volumes[ i ].classname == "info_volume" )
		{
			zone.volumes[ zone.volumes.size ] = volumes[ i ];
		}
		i++;
	}
/#
	assert( isDefined( zone.volumes[ 0 ] ), "zone_init: No volumes found for zone: " + zone_name );
#/
	while ( isDefined( zone.volumes[ 0 ].target ) )
	{
		spots = getstructarray( zone.volumes[ 0 ].target, "targetname" );
		zone.spawn_locations = [];
		zone.dog_locations = [];
		zone.screecher_locations = [];
		zone.avogadro_locations = [];
		zone.inert_locations = [];
		zone.quad_locations = [];
		zone.leaper_locations = [];
		zone.ghost_locations = [];
		zone.brutus_locations = [];
		zone.zbarriers = [];
		zone.magic_boxes = [];
		barricades = getstructarray( "exterior_goal", "targetname" );
		box_locs = getstructarray( "treasure_chest_use", "targetname" );
		i = 0;
		while ( i < spots.size )
		{
			spots[ i ].zone_name = zone_name;
			if ( isDefined( spots[ i ].is_blocked ) && !spots[ i ].is_blocked )
			{
				spots[ i ].is_enabled = 1;
			}
			else
			{
				spots[ i ].is_enabled = 0;
			}
			tokens = strtok( spots[ i ].script_noteworthy, " " );
			_a323 = tokens;
			_k323 = getFirstArrayKey( _a323 );
			while ( isDefined( _k323 ) )
			{
				token = _a323[ _k323 ];
				if ( token == "dog_location" )
				{
					zone.dog_locations[ zone.dog_locations.size ] = spots[ i ];
				}
				else if ( token == "screecher_location" )
				{
					zone.screecher_locations[ zone.screecher_locations.size ] = spots[ i ];
				}
				else if ( token == "avogadro_location" )
				{
					zone.avogadro_locations[ zone.avogadro_locations.size ] = spots[ i ];
				}
				else if ( token == "inert_location" )
				{
					zone.inert_locations[ zone.inert_locations.size ] = spots[ i ];
				}
				else if ( token == "quad_location" )
				{
					zone.quad_locations[ zone.quad_locations.size ] = spots[ i ];
				}
				else if ( token == "leaper_location" )
				{
					zone.leaper_locations[ zone.leaper_locations.size ] = spots[ i ];
				}
				else if ( token == "ghost_location" )
				{
					zone.ghost_locations[ zone.ghost_locations.size ] = spots[ i ];
				}
				else if ( token == "brutus_location" )
				{
					zone.brutus_locations[ zone.brutus_locations.size ] = spots[ i ];
				}
				else
				{
					zone.spawn_locations[ zone.spawn_locations.size ] = spots[ i ];
				}
				_k323 = getNextArrayKey( _a323, _k323 );
			}
			while ( isDefined( spots[ i ].script_string ) )
			{
				barricade_id = spots[ i ].script_string;
				k = 0;
				while ( k < barricades.size )
				{
					while ( isDefined( barricades[ k ].script_string ) && barricades[ k ].script_string == barricade_id )
					{
						nodes = getnodearray( barricades[ k ].target, "targetname" );
						j = 0;
						while ( j < nodes.size )
						{
							if ( isDefined( nodes[ j ].type ) && nodes[ j ].type == "Begin" )
							{
								spots[ i ].target = nodes[ j ].targetname;
							}
							j++;
						}
					}
					k++;
				}
			}
			i++;
		}
		i = 0;
		while ( i < barricades.size )
		{
			targets = getentarray( barricades[ i ].target, "targetname" );
			j = 0;
			while ( j < targets.size )
			{
				if ( targets[ j ] iszbarrier() && isDefined( targets[ j ].script_string ) && targets[ j ].script_string == zone_name )
				{
					zone.zbarriers[ zone.zbarriers.size ] = targets[ j ];
				}
				j++;
			}
			i++;
		}
		i = 0;
		while ( i < box_locs.size )
		{
			chest_ent = getent( box_locs[ i ].script_noteworthy + "_zbarrier", "script_noteworthy" );
			if ( chest_ent entity_in_zone( zone_name, 1 ) )
			{
				zone.magic_boxes[ zone.magic_boxes.size ] = box_locs[ i ];
			}
			i++;
		}
	}
}

reinit_zone_spawners()
{
	zkeys = getarraykeys( level.zones );
	i = 0;
	while ( i < level.zones.size )
	{
		zone = level.zones[ zkeys[ i ] ];
		while ( isDefined( zone.volumes[ 0 ].target ) )
		{
			spots = getstructarray( zone.volumes[ 0 ].target, "targetname" );
			zone.spawn_locations = [];
			zone.dog_locations = [];
			zone.screecher_locations = [];
			zone.avogadro_locations = [];
			zone.quad_locations = [];
			zone.leaper_locations = [];
			zone.ghost_locations = [];
			zone.brutus_locations = [];
			j = 0;
			while ( j < spots.size )
			{
				spots[ j ].zone_name = zkeys[ j ];
				if ( isDefined( spots[ j ].is_blocked ) && !spots[ j ].is_blocked )
				{
					spots[ j ].is_enabled = 1;
				}
				else
				{
					spots[ j ].is_enabled = 0;
				}
				tokens = strtok( spots[ j ].script_noteworthy, " " );
				_a440 = tokens;
				_k440 = getFirstArrayKey( _a440 );
				while ( isDefined( _k440 ) )
				{
					token = _a440[ _k440 ];
					if ( token == "dog_location" )
					{
						zone.dog_locations[ zone.dog_locations.size ] = spots[ j ];
					}
					else if ( token == "screecher_location" )
					{
						zone.screecher_locations[ zone.screecher_locations.size ] = spots[ j ];
					}
					else if ( token == "avogadro_location" )
					{
						zone.avogadro_locations[ zone.avogadro_locations.size ] = spots[ j ];
					}
					else if ( token == "quad_location" )
					{
						zone.quad_locations[ zone.quad_locations.size ] = spots[ j ];
					}
					else if ( token == "leaper_location" )
					{
						zone.leaper_locations[ zone.leaper_locations.size ] = spots[ j ];
					}
					else if ( token == "ghost_location" )
					{
						zone.ghost_locations[ zone.ghost_locations.size ] = spots[ j ];
					}
					else if ( token == "brutus_location" )
					{
						zone.brutus_locations[ zone.brutus_locations.size ] = spots[ j ];
					}
					else
					{
						zone.spawn_locations[ zone.spawn_locations.size ] = spots[ j ];
					}
					_k440 = getNextArrayKey( _a440, _k440 );
				}
				j++;
			}
		}
		i++;
	}
}

enable_zone( zone_name )
{
/#
	if ( isDefined( level.zones ) )
	{
		assert( isDefined( level.zones[ zone_name ] ), "enable_zone: zone has not been initialized" );
	}
#/
	if ( level.zones[ zone_name ].is_enabled )
	{
		return;
	}
	level.zones[ zone_name ].is_enabled = 1;
	level.zones[ zone_name ].is_spawning_allowed = 1;
	level notify( zone_name );
	spawn_points = maps/mp/gametypes_zm/_zm_gametype::get_player_spawns_for_gametype();
	i = 0;
	while ( i < spawn_points.size )
	{
		if ( spawn_points[ i ].script_noteworthy == zone_name )
		{
			spawn_points[ i ].locked = 0;
		}
		i++;
	}
	entry_points = getstructarray( zone_name + "_barriers", "script_noteworthy" );
	i = 0;
	while ( i < entry_points.size )
	{
		entry_points[ i ].is_active = 1;
		entry_points[ i ] trigger_on();
		i++;
	}
}

make_zone_adjacent( main_zone_name, adj_zone_name, flag_name )
{
	main_zone = level.zones[ main_zone_name ];
	if ( !isDefined( main_zone.adjacent_zones[ adj_zone_name ] ) )
	{
		main_zone.adjacent_zones[ adj_zone_name ] = spawnstruct();
		adj_zone = main_zone.adjacent_zones[ adj_zone_name ];
		adj_zone.is_connected = 0;
		adj_zone.flags_do_or_check = 0;
		if ( isarray( flag_name ) )
		{
			adj_zone.flags = flag_name;
		}
		else
		{
			adj_zone.flags[ 0 ] = flag_name;
		}
	}
	else
	{
/#
		assert( !isarray( flag_name ), "make_zone_adjacent: can't mix single and arrays of flags" );
#/
		adj_zone = main_zone.adjacent_zones[ adj_zone_name ];
		size = adj_zone.flags.size;
		adj_zone.flags_do_or_check = 1;
		adj_zone.flags[ size ] = flag_name;
	}
}

add_zone_flags( wait_flag, add_flags )
{
	if ( !isarray( add_flags ) )
	{
		temp = add_flags;
		add_flags = [];
		add_flags[ 0 ] = temp;
	}
	keys = getarraykeys( level.zone_flags );
	i = 0;
	while ( i < keys.size )
	{
		if ( keys[ i ] == wait_flag )
		{
			level.zone_flags[ keys[ i ] ] = arraycombine( level.zone_flags[ keys[ i ] ], add_flags, 1, 0 );
			return;
		}
		i++;
	}
	level.zone_flags[ wait_flag ] = add_flags;
}

add_adjacent_zone( zone_name_a, zone_name_b, flag_name, one_way )
{
	if ( !isDefined( one_way ) )
	{
		one_way = 0;
	}
	if ( !isDefined( level.flag[ flag_name ] ) )
	{
		flag_init( flag_name );
	}
	zone_init( zone_name_a );
	zone_init( zone_name_b );
	make_zone_adjacent( zone_name_a, zone_name_b, flag_name );
	if ( !one_way )
	{
		make_zone_adjacent( zone_name_b, zone_name_a, flag_name );
	}
}

setup_zone_flag_waits()
{
	flags = [];
	zkeys = getarraykeys( level.zones );
	z = 0;
	while ( z < level.zones.size )
	{
		zone = level.zones[ zkeys[ z ] ];
		azkeys = getarraykeys( zone.adjacent_zones );
		az = 0;
		while ( az < zone.adjacent_zones.size )
		{
			azone = zone.adjacent_zones[ azkeys[ az ] ];
			f = 0;
			while ( f < azone.flags.size )
			{
				flags = add_to_array( flags, azone.flags[ f ], 0 );
				f++;
			}
			az++;
		}
		z++;
	}
	i = 0;
	while ( i < flags.size )
	{
		level thread zone_flag_wait( flags[ i ] );
		i++;
	}
}

zone_flag_wait( flag_name )
{
	if ( !isDefined( level.flag[ flag_name ] ) )
	{
		flag_init( flag_name );
	}
	flag_wait( flag_name );
	flags_set = 0;
	z = 0;
	while ( z < level.zones.size )
	{
		zkeys = getarraykeys( level.zones );
		zone = level.zones[ zkeys[ z ] ];
		az = 0;
		while ( az < zone.adjacent_zones.size )
		{
			azkeys = getarraykeys( zone.adjacent_zones );
			azone = zone.adjacent_zones[ azkeys[ az ] ];
			if ( !azone.is_connected )
			{
				if ( azone.flags_do_or_check )
				{
					flags_set = 0;
					f = 0;
					while ( f < azone.flags.size )
					{
						if ( flag( azone.flags[ f ] ) )
						{
							flags_set = 1;
							break;
						}
						else
						{
							f++;
						}
					}
				}
				else flags_set = 1;
				f = 0;
				while ( f < azone.flags.size )
				{
					if ( !flag( azone.flags[ f ] ) )
					{
						flags_set = 0;
					}
					f++;
				}
				if ( flags_set )
				{
					enable_zone( zkeys[ z ] );
					azone.is_connected = 1;
					if ( !level.zones[ azkeys[ az ] ].is_enabled )
					{
						enable_zone( azkeys[ az ] );
					}
					if ( flag( "door_can_close" ) )
					{
						azone thread door_close_disconnect( flag_name );
					}
				}
			}
			az++;
		}
		z++;
	}
	keys = getarraykeys( level.zone_flags );
	i = 0;
	while ( i < keys.size )
	{
		if ( keys[ i ] == flag_name )
		{
			check_flag = level.zone_flags[ keys[ i ] ];
			k = 0;
			while ( k < check_flag.size )
			{
				flag_set( check_flag[ k ] );
				k++;
			}
		}
		else i++;
	}
}

door_close_disconnect( flag_name )
{
	while ( flag( flag_name ) )
	{
		wait 1;
	}
	self.is_connected = 0;
	level thread zone_flag_wait( flag_name );
}

connect_zones( zone_name_a, zone_name_b, one_way )
{
	if ( !isDefined( one_way ) )
	{
		one_way = 0;
	}
	zone_init( zone_name_a );
	zone_init( zone_name_b );
	enable_zone( zone_name_a );
	enable_zone( zone_name_b );
	if ( !isDefined( level.zones[ zone_name_a ].adjacent_zones[ zone_name_b ] ) )
	{
		level.zones[ zone_name_a ].adjacent_zones[ zone_name_b ] = spawnstruct();
		level.zones[ zone_name_a ].adjacent_zones[ zone_name_b ].is_connected = 1;
	}
	if ( !one_way )
	{
		if ( !isDefined( level.zones[ zone_name_b ].adjacent_zones[ zone_name_a ] ) )
		{
			level.zones[ zone_name_b ].adjacent_zones[ zone_name_a ] = spawnstruct();
			level.zones[ zone_name_b ].adjacent_zones[ zone_name_a ].is_connected = 1;
		}
	}
}

manage_zones( initial_zone )
{
/#
	assert( isDefined( initial_zone ), "You must specify an initial zone to manage" );
#/
	deactivate_initial_barrier_goals();
	zone_choke = 0;
	spawn_points = maps/mp/gametypes_zm/_zm_gametype::get_player_spawns_for_gametype();
	i = 0;
	while ( i < spawn_points.size )
	{
/#
		assert( isDefined( spawn_points[ i ].script_noteworthy ), "player_respawn_point: You must specify a script noteworthy with the zone name" );
#/
		spawn_points[ i ].locked = 1;
		i++;
	}
	if ( isDefined( level.zone_manager_init_func ) )
	{
		[[ level.zone_manager_init_func ]]();
	}
/#
	println( "ZM >> zone_init bbbb  (_zm_zonemgr.gsc) = " + initial_zone.size );
#/
	if ( isarray( initial_zone ) )
	{
/#
		println( "ZM >> zone_init aaaa  (_zm_zonemgr.gsc) = " + initial_zone[ 0 ] );
#/
		i = 0;
		while ( i < initial_zone.size )
		{
			zone_init( initial_zone[ i ] );
			enable_zone( initial_zone[ i ] );
			i++;
		}
	}
	else /#
	println( "ZM >> zone_init (_zm_zonemgr.gsc) = " + initial_zone );
#/
	zone_init( initial_zone );
	enable_zone( initial_zone );
	setup_zone_flag_waits();
	zkeys = getarraykeys( level.zones );
	level.zone_keys = zkeys;
	level.newzones = [];
	z = 0;
	while ( z < zkeys.size )
	{
		level.newzones[ zkeys[ z ] ] = spawnstruct();
		z++;
	}
	flag_set( "zones_initialized" );
	flag_wait( "begin_spawning" );
/#
	level thread _debug_zones();
#/
	while ( getDvarInt( #"10873CCA" ) == 0 || getDvarInt( #"762F1309" ) != 0 )
	{
		z = 0;
		while ( z < zkeys.size )
		{
			level.newzones[ zkeys[ z ] ].is_active = 0;
			level.newzones[ zkeys[ z ] ].is_occupied = 0;
			z++;
		}
		a_zone_is_active = 0;
		a_zone_is_spawning_allowed = 0;
		level.zone_scanning_active = 1;
		z = 0;
		while ( z < zkeys.size )
		{
			zone = level.zones[ zkeys[ z ] ];
			newzone = level.newzones[ zkeys[ z ] ];
			if ( !zone.is_enabled )
			{
				z++;
				continue;
			}
			else
			{
				if ( isDefined( level.zone_occupied_func ) )
				{
					newzone.is_occupied = [[ level.zone_occupied_func ]]( zkeys[ z ] );
				}
				else
				{
					newzone.is_occupied = player_in_zone( zkeys[ z ] );
				}
				while ( newzone.is_occupied )
				{
					newzone.is_active = 1;
					a_zone_is_active = 1;
					if ( zone.is_spawning_allowed )
					{
						a_zone_is_spawning_allowed = 1;
					}
					azkeys = getarraykeys( zone.adjacent_zones );
					az = 0;
					while ( az < zone.adjacent_zones.size )
					{
						if ( zone.adjacent_zones[ azkeys[ az ] ].is_connected && level.zones[ azkeys[ az ] ].is_enabled )
						{
							level.newzones[ azkeys[ az ] ].is_active = 1;
							if ( level.zones[ azkeys[ az ] ].is_spawning_allowed )
							{
								a_zone_is_spawning_allowed = 1;
							}
						}
						az++;
					}
				}
				zone_choke++;
				if ( zone_choke >= 3 )
				{
					zone_choke = 0;
					wait 0,05;
				}
			}
			z++;
		}
		level.zone_scanning_active = 0;
		z = 0;
		while ( z < zkeys.size )
		{
			level.zones[ zkeys[ z ] ].is_active = level.newzones[ zkeys[ z ] ].is_active;
			level.zones[ zkeys[ z ] ].is_occupied = level.newzones[ zkeys[ z ] ].is_occupied;
			z++;
		}
		if ( !a_zone_is_active || !a_zone_is_spawning_allowed )
		{
			if ( isarray( initial_zone ) )
			{
				level.zones[ initial_zone[ 0 ] ].is_active = 1;
				level.zones[ initial_zone[ 0 ] ].is_occupied = 1;
				level.zones[ initial_zone[ 0 ] ].is_spawning_allowed = 1;
			}
			else
			{
				level.zones[ initial_zone ].is_active = 1;
				level.zones[ initial_zone ].is_occupied = 1;
				level.zones[ initial_zone ].is_spawning_allowed = 1;
			}
		}
		[[ level.create_spawner_list_func ]]( zkeys );
		level.active_zone_names = maps/mp/zombies/_zm_zonemgr::get_active_zone_names();
		wait 1;
	}
}

old_manage_zones( initial_zone )
{
/#
	assert( isDefined( initial_zone ), "You must specify an initial zone to manage" );
#/
	deactivate_initial_barrier_goals();
	spawn_points = maps/mp/gametypes_zm/_zm_gametype::get_player_spawns_for_gametype();
	i = 0;
	while ( i < spawn_points.size )
	{
/#
		assert( isDefined( spawn_points[ i ].script_noteworthy ), "player_respawn_point: You must specify a script noteworthy with the zone name" );
#/
		spawn_points[ i ].locked = 1;
		i++;
	}
	if ( isDefined( level.zone_manager_init_func ) )
	{
		[[ level.zone_manager_init_func ]]();
	}
/#
	println( "ZM >> zone_init bbbb  (_zm_zonemgr.gsc) = " + initial_zone.size );
#/
	if ( isarray( initial_zone ) )
	{
/#
		println( "ZM >> zone_init aaaa  (_zm_zonemgr.gsc) = " + initial_zone[ 0 ] );
#/
		i = 0;
		while ( i < initial_zone.size )
		{
			zone_init( initial_zone[ i ] );
			enable_zone( initial_zone[ i ] );
			i++;
		}
	}
	else /#
	println( "ZM >> zone_init (_zm_zonemgr.gsc) = " + initial_zone );
#/
	zone_init( initial_zone );
	enable_zone( initial_zone );
	setup_zone_flag_waits();
	zkeys = getarraykeys( level.zones );
	level.zone_keys = zkeys;
	flag_set( "zones_initialized" );
	flag_wait( "begin_spawning" );
/#
	level thread _debug_zones();
#/
	while ( getDvarInt( #"10873CCA" ) == 0 || getDvarInt( #"762F1309" ) != 0 )
	{
		z = 0;
		while ( z < zkeys.size )
		{
			level.zones[ zkeys[ z ] ].is_active = 0;
			level.zones[ zkeys[ z ] ].is_occupied = 0;
			z++;
		}
		a_zone_is_active = 0;
		a_zone_is_spawning_allowed = 0;
		z = 0;
		while ( z < zkeys.size )
		{
			zone = level.zones[ zkeys[ z ] ];
			if ( !zone.is_enabled )
			{
				z++;
				continue;
			}
			else
			{
				if ( isDefined( level.zone_occupied_func ) )
				{
					zone.is_occupied = [[ level.zone_occupied_func ]]( zkeys[ z ] );
				}
				else
				{
					zone.is_occupied = player_in_zone( zkeys[ z ] );
				}
				while ( zone.is_occupied )
				{
					zone.is_active = 1;
					a_zone_is_active = 1;
					if ( zone.is_spawning_allowed )
					{
						a_zone_is_spawning_allowed = 1;
					}
					azkeys = getarraykeys( zone.adjacent_zones );
					az = 0;
					while ( az < zone.adjacent_zones.size )
					{
						if ( zone.adjacent_zones[ azkeys[ az ] ].is_connected && level.zones[ azkeys[ az ] ].is_enabled )
						{
							level.zones[ azkeys[ az ] ].is_active = 1;
							if ( level.zones[ azkeys[ az ] ].is_spawning_allowed )
							{
								a_zone_is_spawning_allowed = 1;
							}
						}
						az++;
					}
				}
			}
			z++;
		}
		if ( !a_zone_is_active || !a_zone_is_spawning_allowed )
		{
			if ( isarray( initial_zone ) )
			{
				level.zones[ initial_zone[ 0 ] ].is_active = 1;
				level.zones[ initial_zone[ 0 ] ].is_occupied = 1;
				level.zones[ initial_zone[ 0 ] ].is_spawning_allowed = 1;
			}
			else
			{
				level.zones[ initial_zone ].is_active = 1;
				level.zones[ initial_zone ].is_occupied = 1;
				level.zones[ initial_zone ].is_spawning_allowed = 1;
			}
		}
		[[ level.create_spawner_list_func ]]( zkeys );
		level.active_zone_names = maps/mp/zombies/_zm_zonemgr::get_active_zone_names();
		wait 1;
	}
}

create_spawner_list( zkeys )
{
	level.zombie_spawn_locations = [];
	level.inert_locations = [];
	level.enemy_dog_locations = [];
	level.zombie_screecher_locations = [];
	level.zombie_avogadro_locations = [];
	level.quad_locations = [];
	level.zombie_leaper_locations = [];
	level.zombie_ghost_locations = [];
	level.zombie_brutus_locations = [];
	z = 0;
	while ( z < zkeys.size )
	{
		zone = level.zones[ zkeys[ z ] ];
		while ( zone.is_enabled && zone.is_active && zone.is_spawning_allowed )
		{
			i = 0;
			while ( i < zone.spawn_locations.size )
			{
				if ( zone.spawn_locations[ i ].is_enabled )
				{
					level.zombie_spawn_locations[ level.zombie_spawn_locations.size ] = zone.spawn_locations[ i ];
				}
				i++;
			}
			x = 0;
			while ( x < zone.inert_locations.size )
			{
				if ( zone.inert_locations[ x ].is_enabled )
				{
					level.inert_locations[ level.inert_locations.size ] = zone.inert_locations[ x ];
				}
				x++;
			}
			x = 0;
			while ( x < zone.dog_locations.size )
			{
				if ( zone.dog_locations[ x ].is_enabled )
				{
					level.enemy_dog_locations[ level.enemy_dog_locations.size ] = zone.dog_locations[ x ];
				}
				x++;
			}
			x = 0;
			while ( x < zone.screecher_locations.size )
			{
				if ( zone.screecher_locations[ x ].is_enabled )
				{
					level.zombie_screecher_locations[ level.zombie_screecher_locations.size ] = zone.screecher_locations[ x ];
				}
				x++;
			}
			x = 0;
			while ( x < zone.avogadro_locations.size )
			{
				if ( zone.avogadro_locations[ x ].is_enabled )
				{
					level.zombie_avogadro_locations[ level.zombie_avogadro_locations.size ] = zone.avogadro_locations[ x ];
				}
				x++;
			}
			x = 0;
			while ( x < zone.quad_locations.size )
			{
				if ( zone.quad_locations[ x ].is_enabled )
				{
					level.quad_locations[ level.quad_locations.size ] = zone.quad_locations[ x ];
				}
				x++;
			}
			x = 0;
			while ( x < zone.leaper_locations.size )
			{
				if ( zone.leaper_locations[ x ].is_enabled )
				{
					level.zombie_leaper_locations[ level.zombie_leaper_locations.size ] = zone.leaper_locations[ x ];
				}
				x++;
			}
			x = 0;
			while ( x < zone.ghost_locations.size )
			{
				if ( zone.ghost_locations[ x ].is_enabled )
				{
					level.zombie_ghost_locations[ level.zombie_ghost_locations.size ] = zone.ghost_locations[ x ];
				}
				x++;
			}
			x = 0;
			while ( x < zone.brutus_locations.size )
			{
				if ( zone.brutus_locations[ x ].is_enabled )
				{
					level.zombie_brutus_locations[ level.zombie_brutus_locations.size ] = zone.brutus_locations[ x ];
				}
				x++;
			}
		}
		z++;
	}
}

get_active_zone_names()
{
	ret_list = [];
	if ( !isDefined( level.zone_keys ) )
	{
		return ret_list;
	}
	while ( level.zone_scanning_active )
	{
		wait 0,05;
	}
	i = 0;
	while ( i < level.zone_keys.size )
	{
		if ( level.zones[ level.zone_keys[ i ] ].is_active )
		{
			ret_list[ ret_list.size ] = level.zone_keys[ i ];
		}
		i++;
	}
	return ret_list;
}

_init_debug_zones()
{
	current_y = 30;
	current_x = 20;
	xloc = [];
	xloc[ 0 ] = 50;
	xloc[ 1 ] = 60;
	xloc[ 2 ] = 100;
	xloc[ 3 ] = 130;
	xloc[ 4 ] = 170;
	zkeys = getarraykeys( level.zones );
	i = 0;
	while ( i < zkeys.size )
	{
		zonename = zkeys[ i ];
		zone = level.zones[ zonename ];
		zone.debug_hud = [];
		j = 0;
		while ( j < 5 )
		{
			zone.debug_hud[ j ] = newdebughudelem();
			if ( !j )
			{
				zone.debug_hud[ j ].alignx = "right";
			}
			else
			{
				zone.debug_hud[ j ].alignx = "left";
			}
			zone.debug_hud[ j ].x = xloc[ j ];
			zone.debug_hud[ j ].y = current_y;
			j++;
		}
		current_y += 10;
		zone.debug_hud[ 0 ] settext( zonename );
		i++;
	}
}

_destroy_debug_zones()
{
	zkeys = getarraykeys( level.zones );
	i = 0;
	while ( i < zkeys.size )
	{
		zonename = zkeys[ i ];
		zone = level.zones[ zonename ];
		j = 0;
		while ( j < 5 )
		{
			zone.debug_hud[ j ] destroy();
			j++;
		}
		i++;
	}
}

_debug_zones()
{
	enabled = 0;
	if ( getDvar( "zombiemode_debug_zones" ) == "" )
	{
		setdvar( "zombiemode_debug_zones", "0" );
	}
	while ( 1 )
	{
		wasenabled = enabled;
		enabled = getDvarInt( "zombiemode_debug_zones" );
		if ( enabled && !wasenabled )
		{
			_init_debug_zones();
		}
		else
		{
			if ( !enabled && wasenabled )
			{
				_destroy_debug_zones();
			}
		}
		while ( enabled )
		{
			zkeys = getarraykeys( level.zones );
			i = 0;
			while ( i < zkeys.size )
			{
				zonename = zkeys[ i ];
				zone = level.zones[ zonename ];
				text = zonename;
				zone.debug_hud[ 0 ] settext( text );
				if ( zone.is_enabled )
				{
					text += " Enabled";
					zone.debug_hud[ 1 ] settext( "Enabled" );
				}
				else
				{
					zone.debug_hud[ 1 ] settext( "" );
				}
				if ( zone.is_active )
				{
					text += " Active";
					zone.debug_hud[ 2 ] settext( "Active" );
				}
				else
				{
					zone.debug_hud[ 2 ] settext( "" );
				}
				if ( zone.is_occupied )
				{
					text += " Occupied";
					zone.debug_hud[ 3 ] settext( "Occupied" );
				}
				else
				{
					zone.debug_hud[ 3 ] settext( "" );
				}
				if ( zone.is_spawning_allowed )
				{
					text += " SpawningAllowed";
					zone.debug_hud[ 4 ] settext( "SpawningAllowed" );
				}
				else
				{
					zone.debug_hud[ 4 ] settext( "" );
				}
/#
				println( "ZM >> DEBUG=" + text );
#/
				i++;
			}
		}
		wait 0,1;
	}
}

is_player_in_zone( zone_name )
{
	zone = level.zones[ zone_name ];
	i = 0;
	while ( i < zone.volumes.size )
	{
		if ( self istouching( level.zones[ zone_name ].volumes[ i ] ) && self.sessionstate != "spectator" )
		{
			return 1;
		}
		i++;
	}
	return 0;
}
