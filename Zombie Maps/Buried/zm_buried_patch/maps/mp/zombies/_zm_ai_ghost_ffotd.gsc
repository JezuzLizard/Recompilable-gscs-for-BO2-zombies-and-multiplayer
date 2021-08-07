#include maps/mp/zombies/_zm_ai_ghost;
#include maps/mp/zombies/_zm_zonemgr;
#include maps/mp/zm_buried;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

ghost_init_start()
{
	level ghost_bad_path_init();
	level.is_player_in_ghost_zone = ::is_player_in_ghost_zone;
	level ghost_bad_spawn_zone_init();
	level.ghost_round_start_monitor_time = 10;
}

ghost_init_end()
{
	disable_traversal_clip_around_mansion();
}

prespawn_start()
{
}

prespawn_end()
{
}

ghost_round_start()
{
	level thread ghost_teleport_to_playable_area();
}

ghost_round_end()
{
	disable_traversal_clip_around_mansion();
}

is_player_in_ghost_zone( player )
{
	result = 0;
	if ( !isDefined( level.ghost_zone_overrides ) )
	{
		level.ghost_zone_overrides = getentarray( "ghost_round_override", "script_noteworthy" );
	}
	is_player_in_override_trigger = 0;
	while ( isDefined( level.zombie_ghost_round_states ) && !is_true( level.zombie_ghost_round_states.is_started ) )
	{
		_a86 = level.ghost_zone_overrides;
		_k86 = getFirstArrayKey( _a86 );
		while ( isDefined( _k86 ) )
		{
			trigger = _a86[ _k86 ];
			if ( player istouching( trigger ) )
			{
				is_player_in_override_trigger = 1;
				break;
			}
			else
			{
				_k86 = getNextArrayKey( _a86, _k86 );
			}
		}
	}
	curr_zone = player get_current_zone();
	if ( !is_player_in_override_trigger && isDefined( curr_zone ) && curr_zone == "zone_mansion" )
	{
		result = 1;
	}
	return result;
}

ghost_bad_path_init()
{
	level.bad_zones = [];
	level.bad_zones[ 0 ] = spawnstruct();
	level.bad_zones[ 0 ].name = "zone_underground_courthouse";
	level.bad_zones[ 0 ].adjacent = [];
	level.bad_zones[ 0 ].adjacent[ 0 ] = "zone_underground_courthouse2";
	level.bad_zones[ 0 ].adjacent[ 1 ] = "zone_tunnels_north2";
	level.bad_zones[ 0 ].ignore_func = ::maps/mp/zm_buried::is_courthouse_open;
	level.bad_zones[ 1 ] = spawnstruct();
	level.bad_zones[ 1 ].name = "zone_underground_courthouse2";
	level.bad_zones[ 1 ].adjacent = [];
	level.bad_zones[ 1 ].adjacent[ 0 ] = "zone_underground_courthouse";
	level.bad_zones[ 1 ].adjacent[ 1 ] = "zone_tunnels_north2";
	level.bad_zones[ 1 ].ignore_func = ::maps/mp/zm_buried::is_courthouse_open;
	level.bad_zones[ 2 ] = spawnstruct();
	level.bad_zones[ 2 ].name = "zone_tunnels_north2";
	level.bad_zones[ 2 ].adjacent = [];
	level.bad_zones[ 2 ].adjacent[ 0 ] = "zone_underground_courthouse2";
	level.bad_zones[ 2 ].adjacent[ 1 ] = "zone_underground_courthouse";
	level.bad_zones[ 2 ].flag = "tunnels2courthouse";
	level.bad_zones[ 2 ].flag_adjacent = "zone_tunnels_north";
	level.bad_zones[ 2 ].ignore_func = ::maps/mp/zm_buried::is_courthouse_open;
	level.bad_zones[ 3 ] = spawnstruct();
	level.bad_zones[ 3 ].name = "zone_tunnels_north";
	level.bad_zones[ 3 ].adjacent = [];
	level.bad_zones[ 3 ].adjacent[ 0 ] = "zone_tunnels_center";
	level.bad_zones[ 3 ].flag = "tunnels2courthouse";
	level.bad_zones[ 3 ].flag_adjacent = "zone_tunnels_north2";
	level.bad_zones[ 3 ].ignore_func = ::maps/mp/zm_buried::is_tunnel_open;
	level.bad_zones[ 4 ] = spawnstruct();
	level.bad_zones[ 4 ].name = "zone_tunnels_center";
	level.bad_zones[ 4 ].adjacent = [];
	level.bad_zones[ 4 ].adjacent[ 0 ] = "zone_tunnels_north";
	level.bad_zones[ 4 ].adjacent[ 1 ] = "zone_tunnels_south";
	level.bad_zones[ 4 ].ignore_func = ::maps/mp/zm_buried::is_tunnel_open;
	level.bad_zones[ 5 ] = spawnstruct();
	level.bad_zones[ 5 ].name = "zone_tunnels_south";
	level.bad_zones[ 5 ].adjacent = [];
	level.bad_zones[ 5 ].adjacent[ 0 ] = "zone_tunnels_center";
	level.bad_zones[ 5 ].ignore_func = ::maps/mp/zm_buried::is_tunnel_open;
}

ghost_bad_path_failsafe()
{
	self endon( "death" );
	self notify( "stop_bad_path_failsafe" );
	self endon( "stop_bad_path_failsafe" );
	self thread non_ghost_round_failsafe();
	while ( 1 )
	{
		player = self.favoriteenemy;
		if ( isDefined( player ) )
		{
			in_bad_zone = 0;
			_a174 = level.bad_zones;
			_k174 = getFirstArrayKey( _a174 );
			while ( isDefined( _k174 ) )
			{
				zone = _a174[ _k174 ];
				if ( isDefined( zone.ignore_func ) )
				{
					if ( level [[ zone.ignore_func ]]() )
					{
						break;
					}
				}
				else if ( player maps/mp/zombies/_zm_zonemgr::entity_in_zone( zone.name ) )
				{
					if ( self maps/mp/zombies/_zm_zonemgr::entity_in_zone( zone.name ) )
					{
						break;
					}
					else ghost_is_adjacent = 0;
					_a192 = zone.adjacent;
					_k192 = getFirstArrayKey( _a192 );
					while ( isDefined( _k192 ) )
					{
						adjacent = _a192[ _k192 ];
						if ( self maps/mp/zombies/_zm_zonemgr::entity_in_zone( adjacent ) )
						{
							ghost_is_adjacent = 1;
							break;
						}
						else
						{
							_k192 = getNextArrayKey( _a192, _k192 );
						}
					}
					if ( isDefined( zone.flag ) && flag( zone.flag ) )
					{
						if ( self maps/mp/zombies/_zm_zonemgr::entity_in_zone( zone.flag_adjacent ) )
						{
							ghost_is_adjacent = 1;
						}
					}
					if ( !ghost_is_adjacent )
					{
						in_bad_zone = 1;
						break;
					}
				}
				else
				{
					_k174 = getNextArrayKey( _a174, _k174 );
				}
			}
			if ( in_bad_zone )
			{
				nodes = getnodesinradiussorted( player.origin, 540, 180, 60, "Path" );
				if ( nodes.size > 0 )
				{
					node = nodes[ randomint( nodes.size ) ];
				}
				else
				{
					node = getnearestnode( player.origin );
				}
				if ( isDefined( node ) )
				{
					while ( 1 )
					{
						if ( !is_true( self.is_traversing ) )
						{
							break;
						}
						else
						{
							wait 0,1;
						}
					}
					self forceteleport( node.origin, ( 0, 0, 0 ) );
				}
			}
		}
		wait 0,25;
	}
}

non_ghost_round_failsafe()
{
	self endon( "death" );
	while ( 1 )
	{
		self waittill( "bad_path" );
		if ( self.state == "runaway_update" )
		{
			if ( !maps/mp/zombies/_zm_ai_ghost::is_ghost_round_started() && is_true( self.is_spawned_in_ghost_zone ) )
			{
				self maps/mp/zombies/_zm_ai_ghost::start_evaporate( 1 );
				return;
			}
		}
		wait 0,25;
	}
}

disable_traversal_clip_around_mansion()
{
	while ( isDefined( level.ghost_zone_door_clips ) && level.ghost_zone_door_clips.size > 0 )
	{
		_a276 = level.ghost_zone_door_clips;
		_k276 = getFirstArrayKey( _a276 );
		while ( isDefined( _k276 ) )
		{
			door_clip = _a276[ _k276 ];
			door_clip notsolid();
			_k276 = getNextArrayKey( _a276, _k276 );
		}
	}
}

ghost_bad_spawn_zone_init()
{
	level.ghost_bad_spawn_zones = [];
	level.ghost_bad_spawn_zones[ 0 ] = "zone_mansion_backyard";
	level.ghost_bad_spawn_zones[ 1 ] = "zone_maze";
	level.ghost_bad_spawn_zones[ 2 ] = "zone_maze_staircase";
}

can_use_mansion_back_flying_out_node( zone_name )
{
	if ( zone_name == "zone_mansion_backyard" )
	{
		return 1;
	}
	if ( zone_name == "zone_maze" )
	{
		return 1;
	}
	if ( zone_name == "zone_maze_staircase" )
	{
		return 1;
	}
	return 0;
}

ghost_teleport_to_playable_area()
{
	level endon( "intermission" );
	if ( level.intermission )
	{
		return;
	}
	level endon( "ghost_round_end" );
	monitor_time = 0;
	while ( 1 )
	{
		ghosts = get_current_ghosts();
		_a332 = ghosts;
		_k332 = getFirstArrayKey( _a332 );
		while ( isDefined( _k332 ) )
		{
			ghost = _a332[ _k332 ];
			while ( !is_true( self.is_spawned_in_ghost_zone ) && !is_true( self.is_teleported_in_bad_zone ) )
			{
				_a336 = level.ghost_bad_spawn_zones;
				_k336 = getFirstArrayKey( _a336 );
				while ( isDefined( _k336 ) )
				{
					bad_spawn_zone_name = _a336[ _k336 ];
					if ( ghost maps/mp/zombies/_zm_zonemgr::entity_in_zone( bad_spawn_zone_name ) )
					{
						if ( is_player_valid( ghost.favoriteenemy ) )
						{
							destination_node = ghost maps/mp/zombies/_zm_ai_ghost::get_best_flying_target_node( ghost.favoriteenemy );
							if ( isDefined( destination_node ) )
							{
								ghost forceteleport( destination_node.origin, ( 0, 0, 0 ) );
								self.is_teleported_in_bad_zone = 1;
							}
						}
						if ( !is_true( self.is_teleported_in_bad_zone ) )
						{
							if ( can_use_mansion_back_flying_out_node( bad_spawn_zone_name ) )
							{
								ghost forceteleport( level.ghost_back_flying_out_path_starts[ 0 ].origin, ( 0, 0, 0 ) );
							}
							else
							{
								ghost forceteleport( level.ghost_front_flying_out_path_starts[ 0 ].origin, ( 0, 0, 0 ) );
							}
							self.is_teleported_in_bad_zone = 1;
						}
					}
					_k336 = getNextArrayKey( _a336, _k336 );
				}
			}
			_k332 = getNextArrayKey( _a332, _k332 );
		}
		monitor_time += 0,1;
		if ( monitor_time > level.ghost_round_start_monitor_time )
		{
			return;
		}
		else
		{
			wait 0,1;
		}
	}
}
