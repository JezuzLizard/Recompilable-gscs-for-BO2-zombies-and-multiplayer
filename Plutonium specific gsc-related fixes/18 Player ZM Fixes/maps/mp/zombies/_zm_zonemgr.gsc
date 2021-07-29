#include maps/mp/zombies/_zm_zonemgr;
#include maps/mp/gametypes_zm/_zm_gametype;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

init()
{
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
	if ( !isDefined( level.zones ) || !isDefined( level.zones[ zone_name ] ) || !level.zones[ zone_name ].is_enabled )
	{
		return 0;
	}
	return 1;
}

get_player_zone()
{
	player_zone = undefined;
	keys = getarraykeys( level.zones );
	for ( i = 0; i < keys.size; i++ )
	{
		if ( self entity_in_zone( keys[ i ] ) )
		{
			player_zone = keys[ i ];
			break;
		}
	}
	return player_zone;
}

get_zone_from_position( v_pos, ignore_enabled_check )
{
	zone = undefined;
	scr_org = spawn( "script_origin", v_pos );
	keys = getarraykeys(level.zones);
	for ( i = 0; i < keys.size; i++ )
	{
		if ( scr_org entity_in_zone( keys[ i ], ignore_enabled_check ) )
		{
			zone = keys [i ];
			break;
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
	return zone.magic_boxes;
}

get_zone_zbarriers( zone_name )
{
	if ( isDefined( zone_name ) && !zone_is_enabled( zone_name ) )
	{
		return undefined;
	}
	zone = level.zones[ zone_name ];
	return zone.zbarriers;
}

get_players_in_zone( zone_name, return_players )
{
	if ( !zone_is_enabled( zone_name ) )
	{
		return 0;
	}
	zone = level.zones[zone_name];
	num_in_zone = 0;
	players_in_zone = [];
	players = get_players();
	for ( i = 0; i < zone.volumes.size; i++ )
	{
		for ( j = 0; j < players.size; j++ )
		{
			if ( players[ j ] istouching( zone.volumes[ i ] ) )
			{
				num_in_zone++;
				players_in_zone[ players_in_zone.size ] = players[ j ];
			}
		}
	}
	if ( isdefined( return_players ) )
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
	for ( i = 0; i < zone.volumes.size; i++ )
	{
		players = get_players();
		for ( j = 0; j < players.size; j++ )
		{
			if ( players[ j ] istouching( zone.volumes[ i ] ) && !players[ j ] .sessionstate == "spectator" )
			{
				return 1;
			}
		}
	}
	return 0;
}

entity_in_zone( zone_name, ignore_enabled_check )
{
	if ( !zone_is_enabled( zone_name ) && !is_true( ignore_enabled_check ) )
	{
		return 0;
	}
	zone = level.zones[ zone_name ];
	for ( i = 0; i < zone.volumes.size; i++ )
	{
		if ( self istouching( zone.volumes[ i ] ) )
		{
			return 1;
		}
	}
	return 0;
}

deactivate_initial_barrier_goals()
{
	special_goals = getstructarray( "exterior_goal", "targetname" );
	for ( i = 0; i < special_goals.size; i++ )
	{
		if ( isdefined( special_goals[ i ].script_noteworthy ) )
		{
			special_goals[ i ].is_active = 0;
			special_goals[ i ] trigger_off();
		}
	}
}

zone_init( zone_name )
{
	
	if ( isDefined( level.zones[ zone_name ] ) )
	{
		return;
	}
	
	level.zones[ zone_name ] = spawnstruct();
	zone = level.zones[ zone_name ];
	zone.is_enabled = 0; 
	zone.is_occupied = 0; 
	zone.is_active = 0;
	zone.adjacent_zones = [];
	zone.is_spawning_allowed = 0;
	
	spawn_points = maps/mp/gametypes_zm/_zm_gametype::get_player_spawns_for_gametype();
	for( i = 0; i < spawn_points.size; i++ )
	{
		if ( spawn_points[ i ].script_noteworthy == zone_name )
		{
			spawn_points[ i ].locked = 0;
		}
	}
	
	
	zone.volumes = [];
	volumes = getentarray( zone_name, "targetname" );
	i = 0;
	for ( i = 0; i < volumes.size; i++ )
	{
		if ( volumes[ i ].classname == "info_volume" )
		{
			zone.volumes[ zone.volumes.size ] = volumes[ i ];
		}
	}
	if ( isdefined( zone.volumes[ 0 ].target ) )
	{
		spots = getstructarray( zone.volumes[ 0 ].target, "targetname" );
		zone.spawn_locations = [];
		zone.dog_locations = [];
		zone.screecher_locations = [];
		zone.avogadro_locations = [];
		zone.inert_locations = [];
		zone.quad_locations = [];
		zone.leaper_locations = [];
		zone.brutus_locations = [];
		zone.mechz_locations = [];
		zone.astro_locations = [];
		zone.napalm_locations = [];
		zone.zbarriers = [];
		zone.magic_boxes = [];
		barricades = getstructarray( "exterior_goal", "targetname" );
		box_locs = getstructarray( "treasure_chest_use", "targetname" );
		for (i = 0; i < spots.size; i++)
		{
			spots[ i ].zone_name = zone_name;
			if ( !is_true( spots[ i ].is_blocked ) )
			{
				spots[ i ].is_enabled = 1;
			}
			else
			{
				spots[ i ].is_enabled = 0;
			}
			tokens = strtok( spots[ i ].script_noteworthy, " " );
			foreach ( token in tokens )
			{
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
					zone.avogadro_locations[ zone.avogadro_locations.size ] = spots[ i] ;
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
				else if ( token == "brutus_location" )
				{
					zone.brutus_locations[ zone.brutus_locations.size ] = spots[ i ];
				}
				else if ( token == "mechz_location" )
				{
					zone.mechz_locations[ zone.mechz_locations.size ] = spots[ i ];
				}
				else if ( token == "astro_location" )
				{
					zone.astro_locations[ zone.astro_locations.size ] = spots[ i ];
				}
				else if ( token == "napalm_location" )
				{
					zone.napalm_locations[ zone.napalm_locations.size ] = spots[ i ];
				}
				else
				{
					zone.spawn_locations[ zone.spawn_locations.size ] = spots[ i ];
				}
			}
			if ( isdefined( spots[ i ].script_string ) )
			{
				barricade_id = spots[ i ].script_string;
				for ( k = 0; k < barricades.size; k++ )
				{
					if ( isdefined( barricades[ k ].script_string ) && barricades[ k ].script_string == barricade_id )
					{
						nodes = getnodearray( barricades[ k ].target, "targetname" );
						for ( j = 0; j < nodes.size; j++ )
						{
							if ( isdefined( nodes[ j ].type ) && nodes[ j ].type == "Begin" )
							{
								spots[ i ].target = nodes[ j ].targetname;
							}
						}
					}
				}
			}
		}
		for ( i = 0; i < barricades.size; i++ )
		{
			targets = getentarray( barricades[ i ].target, "targetname" );
			for ( j = 0; j < targets.size; j++ )
			{
				if ( targets[ j ] iszbarrier() && isdefined( targets[ j ].script_string ) && targets[ j ].script_string == zone_name )
				{
					zone.zbarriers[ zone.zbarriers.size ] = targets[ j ];
				}
			}
		}
		for ( i = 0; i < box_locs.size; i++ )
		{
			chest_ent = getent( box_locs[ i ].script_noteworthy + "_zbarrier", "script_noteworthy" );
			if ( chest_ent entity_in_zone( zone_name, 1 ) )
			{
				zone.magic_boxes[zone.magic_boxes.size] = box_locs[ i ];
			}
		}
	}
}

enable_zone( zone_name )
{
	if ( level.zones[ zone_name ].is_enabled )
	{
		return; 
	}
	level.zones[ zone_name ].is_enabled = 1;
	level.zones[zone_name].is_spawning_allowed = 1;
	level notify( zone_name );
	spawn_points = maps/mp/gametypes_zm/_zm_gametype::get_player_spawns_for_gametype();
	for( i = 0; i < spawn_points.size; i++ )
	{
		if ( spawn_points[ i ].script_noteworthy == zone_name )
		{
			spawn_points[ i ].locked = 0;
		}
	}
	entry_points = getstructarray( zone_name + "_barriers", "script_noteworthy" );
	for( i = 0; i < entry_points.size; i++ )
	{
		entry_points[ i ].is_active = 1;
		entry_points[ i ] trigger_on();
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
	for ( i = 0; i < keys.size; i++ )
	{
		if ( keys[ i ] == wait_flag )
		{
			level.zone_flags[ keys[ i ] ] = arraycombine( level.zone_flags[ keys[ i ] ], add_flags, 1, 0 );
			return;
		}
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
	for ( z = 0; z < level.zones.size; z++ )
	{
		zone = level.zones[ zkeys[ z ] ];
		azkeys = getarraykeys( zone.adjacent_zones );
		for ( az = 0; az < zone.adjacent_zones.size; az++ )
		{
			azone = zone.adjacent_zones[ azkeys[ az ] ];
			for ( f = 0; f < azone.flags.size; f++ )
			{
				flags = add_to_array( flags, azone.flags[ f ], 0);
			}
		}
	}
	for ( i = 0; i < flags.size; i++ )
	{
		level thread zone_flag_wait( flags[ i ] );
	}
}

zone_flag_wait( flag_name )
{
	if ( !isdefined( level.flag[ flag_name ] ) )
	{
		flag_init( flag_name );
	}
	flag_wait( flag_name );
	flags_set = 0;
	for ( z = 0; z < level.zones.size; z++ )
	{
		zkeys = getarraykeys( level.zones );
		zone = level.zones[ zkeys[ z ] ];
		for ( az = 0; az < zone.adjacent_zones.size; az++ )
		{
			azkeys = getarraykeys( zone.adjacent_zones );
			azone = zone.adjacent_zones[ azkeys[ az ] ];
			if ( !azone.is_connected )
			{
				if ( azone.flags_do_or_check )
				{
					flags_set = 0;
					for ( f = 0; f < azone.flags.size; f++ )
					{
						if ( flag( azone.flags[ f ] ) )
						{
							flags_set = 1;
							break;
						}
					}
				}
				else
				{
					flags_set = 1;
					for ( f = 0; f < azone.flags.size; f++ )
					{
						if ( !flag(azone.flags[ f ] ) )
						{
							flags_set = 0;
						}
					}
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
		}
	}
	keys = getarraykeys( level.zone_flags );
	for ( i = 0; i < keys.size; i++ )
	{
		if ( keys[ i ] == flag_name )
		{
			check_flag = level.zone_flags[ keys[ i ] ];
			for ( k = 0; k < check_flag.size; k++ )
			{
				flag_set( check_flag[ k ] );
			}
			break;
		}
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

	deactivate_initial_barrier_goals();
	zone_choke = 0;
	spawn_points = maps/mp/gametypes_zm/_zm_gametype::get_player_spawns_for_gametype();
	for ( i = 0; i < spawn_points.size; i++ )
	{
		spawn_points[ i ].locked = 1;
	}
	if ( isDefined( level.zone_manager_init_func ) )
	{
		[[ level.zone_manager_init_func ]]();
	}

	if ( isarray( initial_zone ) )
	{
		for ( i = 0; i < initial_zone.size; i++ )
		{
			zone_init( initial_zone[ i ] );
			enable_zone( initial_zone[ i ] );
		}
	}
	else
	{
		zone_init( initial_zone );
		enable_zone( initial_zone );
	}
	setup_zone_flag_waits();
	zkeys = getarraykeys( level.zones );
	level.zone_keys = zkeys;
	level.newzones = [];
	for ( z = 0; z < zkeys.size; z++ )
	{
		level.newzones[ zkeys[ z ] ] = spawnstruct();
	}
	oldzone = undefined;
	flag_set( "zones_initialized" );
	flag_wait( "begin_spawning" );
	while ( getDvarInt( "noclip" ) == 0 || getDvarInt( "notarget" ) != 0 )
	{	
		for( z = 0; z < zkeys.size; z++ )
		{
			level.newzones[ zkeys[ z ] ].is_active = 0;
			level.newzones[ zkeys[ z ] ].is_occupied = 0;
		}
		a_zone_is_active = 0;
		a_zone_is_spawning_allowed = 0;
		level.zone_scanning_active = 1;
		z = 0;
		while ( z < zkeys.size )
		{
			zone = level.zones[ zkeys[ z ] ];
			newzone = level.newzones[ zkeys[ z ] ];
			if( !zone.is_enabled )
			{
				z++;
				continue;
			}
			if ( isdefined(level.zone_occupied_func ) )
			{
				newzone.is_occupied = [[ level.zone_occupied_func ]]( zkeys[ z ] );
			}
			else
			{
				newzone.is_occupied = player_in_zone( zkeys[ z ] );
			}
			if ( newzone.is_occupied )
			{
				newzone.is_active = 1;
				a_zone_is_active = 1;
				if ( zone.is_spawning_allowed )
				{
					a_zone_is_spawning_allowed = 1;
				}
				if ( !isdefined(oldzone) || oldzone != newzone )
				{
					level notify( "newzoneActive", zkeys[ z ] );
					oldzone = newzone;
				}
				azkeys = getarraykeys( zone.adjacent_zones );
				for ( az = 0; az < zone.adjacent_zones.size; az++ )
				{
					if ( zone.adjacent_zones[ azkeys[ az ] ].is_connected && level.zones[ azkeys[ az ] ].is_enabled )
					{
						level.newzones[ azkeys[ az ] ].is_active = 1;
						if ( level.zones[ azkeys[ az ] ].is_spawning_allowed )
						{
							a_zone_is_spawning_allowed = 1;
						}
					}
				}
			}
			zone_choke++;
			if ( zone_choke >= 3 )
			{
				zone_choke = 0;
				wait 0.05;
			}
			z++;
		}
		level.zone_scanning_active = 0;
		for ( z = 0; z < zkeys.size; z++ )
		{
			level.zones[ zkeys[ z ] ].is_active = level.newzones[ zkeys[ z ] ].is_active;
			level.zones[ zkeys[ z ] ].is_occupied = level.newzones[ zkeys[ z ] ].is_occupied;
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

debug_show_spawn_locations()
{
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
	level.zombie_astro_locations = [];
	level.zombie_brutus_locations = [];
	level.zombie_mechz_locations = [];
	level.zombie_napalm_locations = [];
	for ( z = 0; z < zkeys.size; z++ )
	{
		zone = level.zones[ zkeys[ z ] ];
		if ( zone.is_enabled && zone.is_active && zone.is_spawning_allowed )
		{
			for ( i = 0; i < zone.spawn_locations.size; i++ )
			{
				if(zone.spawn_locations[ i ].is_enabled)
				{
					level.zombie_spawn_locations[ level.zombie_spawn_locations.size ] = zone.spawn_locations[ i ];
				}
			}
			for ( x = 0; x < zone.inert_locations.size; x++ )
			{
				if ( zone.inert_locations[ x ].is_enabled)
				{
					level.inert_locations[ level.inert_locations.size ] = zone.inert_locations[ x ];
				}
			}
			for ( x = 0; x < zone.dog_locations.size; x++ )
			{
				if ( zone.dog_locations[ x ].is_enabled )
				{
					level.enemy_dog_locations[ level.enemy_dog_locations.size ] = zone.dog_locations[ x ];
				}
			}
			for ( x = 0; x < zone.screecher_locations.size; x++ )
			{
				if ( zone.screecher_locations[ x ].is_enabled)
				{
					level.zombie_screecher_locations[ level.zombie_screecher_locations.size ] = zone.screecher_locations[ x ];
				}
			}
			for ( x = 0; x < zone.avogadro_locations.size; x++ )
			{
				if ( zone.avogadro_locations[ x ].is_enabled)
				{
					level.zombie_avogadro_locations[ level.zombie_avogadro_locations.size ] = zone.avogadro_locations[ x ];
				}
			}
			for ( x = 0; x < zone.quad_locations.size; x++ )
			{
				if ( zone.quad_locations[ x ].is_enabled )
				{
					level.quad_locations[ level.quad_locations.size ] = zone.quad_locations[ x ];
				}
			}
			for ( x = 0; x < zone.leaper_locations.size; x++ )
			{
				if ( zone.leaper_locations[ x ].is_enabled )
				{
					level.zombie_leaper_locations[ level.zombie_leaper_locations.size ] = zone.leaper_locations[ x ];
				}
			}
			for ( x = 0; x < zone.astro_locations.size; x++ )
			{
				if ( zone.astro_locations[ x ].is_enabled )
				{
					level.zombie_astro_locations[ level.zombie_astro_locations.size ] = zone.astro_locations[ x ];
				}
			}
			for ( x = 0; x < zone.napalm_locations.size; x++ )
			{
				if ( zone.napalm_locations[x].is_enabled )
				{
					level.zombie_napalm_locations[ level.zombie_napalm_locations.size ] = zone.napalm_locations[ x ];
				}
			}
			for ( x = 0; x < zone.brutus_locations.size; x++ )
			{
				if ( zone.brutus_locations[ x ].is_enabled )
				{
					level.zombie_brutus_locations[ level.zombie_brutus_locations.size ] = zone.brutus_locations[ x ];
				}
			}
			for ( x = 0; x < zone.mechz_locations.size; x++ )
			{
				if ( zone.mechz_locations[ x ].is_enabled )  
				{
					level.zombie_mechz_locations[level.zombie_mechz_locations.size] = zone.mechz_locations[ x ];
				}
			}
		}
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
		wait 0.05;
	}
	for ( i = 0; i < level.zone_keys.size; i++ )
	{
		if ( level.zones[ level.zone_keys[ i ] ].is_active )
		{
			ret_list[ ret_list.size ] = level.zone_keys[ i ];
		}
	}
	return ret_list;
}

is_player_in_zone( zone_name ) //checked changed to match cerberus output
{
	zone = level.zones[ zone_name ];
	for ( i = 0; i < zone.volumes.size; i++ )
	{
		if ( self istouching( level.zones[zone_name].volumes[ i ] ) && !self.sessionstate == "spectator" )
		{
			return 1;
		}
	}
	return 0;
}
