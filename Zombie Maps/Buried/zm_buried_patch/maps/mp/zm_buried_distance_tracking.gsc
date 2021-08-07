#include maps/mp/zombies/_zm_ai_basic;
#include maps/mp/zombies/_zm_zonemgr;
#include maps/mp/zombies/_zm_spawner;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

zombie_tracking_init()
{
	level.zombie_respawned_health = [];
	if ( !isDefined( level.zombie_tracking_dist ) )
	{
		level.zombie_tracking_dist = 1600;
	}
	if ( !isDefined( level.zombie_tracking_high ) )
	{
		level.zombie_tracking_high = 600;
	}
	if ( !isDefined( level.zombie_tracking_wait ) )
	{
		level.zombie_tracking_wait = 0,4;
	}
	for ( ;; )
	{
		while ( 1 )
		{
			zombies = get_round_enemy_array();
			if ( !isDefined( zombies ) || isDefined( level.ignore_distance_tracking ) && level.ignore_distance_tracking )
			{
				wait level.zombie_tracking_wait;
			}
		}
		else i = 0;
		while ( i < zombies.size )
		{
			if ( isDefined( zombies[ i ] ) && isDefined( zombies[ i ].ignore_distance_tracking ) && !zombies[ i ].ignore_distance_tracking && isDefined( zombies[ i ].ignoreall ) && !zombies[ i ].ignoreall )
			{
				zombies[ i ] thread delete_zombie_noone_looking( level.zombie_tracking_dist, level.zombie_tracking_high );
			}
			i++;
		}
		wait level.zombie_tracking_wait;
	}
}

delete_zombie_noone_looking( how_close, how_high )
{
	self endon( "death" );
	if ( self can_be_deleted_from_buried_special_zones() )
	{
		self.inview = 0;
		self.player_close = 0;
	}
	else
	{
		if ( !isDefined( how_close ) )
		{
			how_close = 1000;
		}
		if ( !isDefined( how_high ) )
		{
			how_high = 500;
		}
		if ( isDefined( self.has_legs ) && !self.has_legs )
		{
			how_close *= 1,5;
		}
		distance_squared_check = how_close * how_close;
		height_squared_check = how_high * how_high;
		too_far_dist = distance_squared_check * 3;
		if ( isDefined( level.zombie_tracking_too_far_dist ) )
		{
			too_far_dist = level.zombie_tracking_too_far_dist * level.zombie_tracking_too_far_dist;
		}
		self.inview = 0;
		self.player_close = 0;
		players = get_players();
		_a98 = players;
		_k98 = getFirstArrayKey( _a98 );
		while ( isDefined( _k98 ) )
		{
			player = _a98[ _k98 ];
			if ( player.sessionstate == "spectator" )
			{
			}
			else if ( isDefined( player.laststand ) && player.laststand && isDefined( self.favoriteenemy ) && self.favoriteenemy == player )
			{
				if ( !self can_zombie_see_any_player() )
				{
					self.favoriteenemy = undefined;
					self.zombie_path_bad = 1;
					self thread escaped_zombies_cleanup();
				}
			}
			if ( isDefined( level.only_track_targeted_players ) )
			{
				if ( !isDefined( self.favoriteenemy ) || self.favoriteenemy != player )
				{
				}
			}
			else
			{
				can_be_seen = self player_can_see_me( player );
				distance_squared = distancesquared( self.origin, player.origin );
				if ( can_be_seen && distance_squared < too_far_dist )
				{
					self.inview++;
				}
				if ( distance_squared < distance_squared_check && abs( self.origin[ 2 ] - player.origin[ 2 ] ) < how_high )
				{
					self.player_close++;
				}
			}
			_k98 = getNextArrayKey( _a98, _k98 );
		}
	}
	wait 0,1;
	if ( self.inview == 0 && self.player_close == 0 )
	{
		if ( !isDefined( self.animname ) || isDefined( self.animname ) && self.animname != "zombie" )
		{
			return;
		}
		if ( isDefined( self.electrified ) && self.electrified == 1 )
		{
			return;
		}
		zombies = getaiarray( "axis" );
		if ( ( zombies.size + level.zombie_total ) > 24 || ( zombies.size + level.zombie_total ) <= 24 && self.health >= self.maxhealth )
		{
			if ( isDefined( self.exclude_distance_cleanup_adding_to_total ) && !self.exclude_distance_cleanup_adding_to_total && isDefined( self.isscreecher ) && !self.isscreecher )
			{
				level.zombie_total++;
				if ( self.health < level.zombie_health )
				{
					level.zombie_respawned_health[ level.zombie_respawned_health.size ] = self.health;
				}
			}
		}
		self maps/mp/zombies/_zm_spawner::reset_attack_spot();
		self notify( "zombie_delete" );
		if ( isDefined( self.anchor ) )
		{
			self.anchor delete();
		}
		self delete();
		recalc_zombie_array();
	}
}

player_can_see_me( player )
{
	playerangles = player getplayerangles();
	playerforwardvec = anglesToForward( playerangles );
	playerunitforwardvec = vectornormalize( playerforwardvec );
	banzaipos = self.origin;
	playerpos = player getorigin();
	playertobanzaivec = banzaipos - playerpos;
	playertobanzaiunitvec = vectornormalize( playertobanzaivec );
	forwarddotbanzai = vectordot( playerunitforwardvec, playertobanzaiunitvec );
	if ( forwarddotbanzai >= 1 )
	{
		anglefromcenter = 0;
	}
	else if ( forwarddotbanzai <= -1 )
	{
		anglefromcenter = 180;
	}
	else
	{
		anglefromcenter = acos( forwarddotbanzai );
	}
	playerfov = getDvarFloat( "cg_fov" );
	banzaivsplayerfovbuffer = getDvarFloat( "g_banzai_player_fov_buffer" );
	if ( banzaivsplayerfovbuffer <= 0 )
	{
		banzaivsplayerfovbuffer = 0,2;
	}
	playercanseeme = anglefromcenter <= ( ( playerfov * 0,5 ) * ( 1 - banzaivsplayerfovbuffer ) );
	return playercanseeme;
}

can_be_deleted_from_buried_special_zones()
{
	if ( self can_be_deleted_from_start_area() )
	{
		return 1;
	}
	if ( self can_be_deleted_from_maze_area() )
	{
		return 1;
	}
	return 0;
}

can_be_deleted_from_start_area()
{
	start_zones = [];
	start_zones[ start_zones.size ] = "zone_start";
	start_zones[ start_zones.size ] = "zone_start_lower";
	return self can_be_deleted_from_area( start_zones );
}

can_be_deleted_from_maze_area()
{
	maze_zones = [];
	maze_zones[ maze_zones.size ] = "zone_mansion_backyard";
	maze_zones[ maze_zones.size ] = "zone_maze";
	maze_zones[ maze_zones.size ] = "zone_maze_staircase";
	return self can_be_deleted_from_area( maze_zones );
}

can_be_deleted_from_area( zone_names )
{
	self_in_zone = 0;
	_a265 = zone_names;
	_k265 = getFirstArrayKey( _a265 );
	while ( isDefined( _k265 ) )
	{
		zone_name = _a265[ _k265 ];
		if ( isDefined( level.zones[ zone_name ] ) && isDefined( level.zones[ zone_name ].is_occupied ) && level.zones[ zone_name ].is_occupied )
		{
			return 0;
		}
		if ( !self_in_zone && self maps/mp/zombies/_zm_zonemgr::entity_in_zone( zone_name ) )
		{
			self_in_zone = 1;
		}
		_k265 = getNextArrayKey( _a265, _k265 );
	}
	if ( self_in_zone )
	{
		return 1;
	}
	return 0;
}

escaped_zombies_cleanup_init()
{
	self endon( "death" );
	self.zombie_path_bad = 0;
	while ( 1 )
	{
		if ( !self.zombie_path_bad )
		{
			self waittill( "bad_path" );
		}
		found_player = undefined;
		players = get_players();
		i = 0;
		while ( i < players.size )
		{
			if ( is_player_valid( players[ i ] ) && !is_true( players[ i ].is_in_ghost_zone ) && self maymovetopoint( players[ i ].origin, 1 ) )
			{
				self.favoriteenemy = players[ i ];
				found_player = 1;
				i++;
				continue;
			}
			i++;
		}
		n_delete_distance = 800;
		n_delete_height = 300;
		if ( !isDefined( found_player ) && isDefined( self.completed_emerging_into_playable_area ) && self.completed_emerging_into_playable_area )
		{
			self thread delete_zombie_noone_looking( n_delete_distance, n_delete_height );
			self.zombie_path_bad = 1;
			self escaped_zombies_cleanup();
		}
		wait 0,1;
	}
}

escaped_zombies_cleanup()
{
	self endon( "death" );
	s_escape = self get_escape_position();
	self notify( "stop_find_flesh" );
	self notify( "zombie_acquire_enemy" );
	if ( isDefined( s_escape ) )
	{
		self setgoalpos( s_escape.origin );
		self thread check_player_available();
		self waittill_any( "goal", "reaquire_player" );
	}
	self.zombie_path_bad = !can_zombie_path_to_any_player();
	wait 0,1;
	if ( !self.zombie_path_bad )
	{
		self thread maps/mp/zombies/_zm_ai_basic::find_flesh();
	}
}

get_escape_position()
{
	self endon( "death" );
	str_zone = get_current_zone();
	if ( isDefined( str_zone ) )
	{
		a_zones = get_adjacencies_to_zone( str_zone );
		a_dog_locations = get_dog_locations_in_zones( a_zones );
		s_farthest = self get_farthest_dog_location( a_dog_locations );
	}
	return s_farthest;
}

check_player_available()
{
	self notify( "_check_player_available" );
	self endon( "_check_player_available" );
	self endon( "death" );
	self endon( "goal" );
	while ( self.zombie_path_bad )
	{
		if ( self can_zombie_see_any_player() )
		{
			self notify( "reaquire_player" );
			return;
		}
		wait randomfloatrange( 0,2, 0,5 );
	}
	self notify( "reaquire_player" );
}

can_zombie_path_to_any_player()
{
	a_players = get_players();
	i = 0;
	while ( i < a_players.size )
	{
		if ( !is_player_valid( a_players[ i ] ) )
		{
			i++;
			continue;
		}
		else if ( is_true( a_players[ i ].is_in_ghost_zone ) )
		{
			i++;
			continue;
		}
		else
		{
			if ( findpath( self.origin, a_players[ i ].origin ) )
			{
				return 1;
			}
		}
		i++;
	}
	return 0;
}

can_zombie_see_any_player()
{
	a_players = get_players();
	i = 0;
	while ( i < a_players.size )
	{
		if ( !is_player_valid( a_players[ i ] ) )
		{
			i++;
			continue;
		}
		else
		{
			path_length = 0;
			if ( !is_true( a_players[ i ].is_in_ghost_zone ) )
			{
				path_length = self calcpathlength( a_players[ i ].origin );
			}
			if ( self maymovetopoint( a_players[ i ].origin, 1 ) || path_length != 0 )
			{
				return 1;
			}
		}
		i++;
	}
	return 0;
}

get_adjacencies_to_zone( str_zone )
{
	a_adjacencies = [];
	a_adjacencies[ 0 ] = str_zone;
	a_adjacent_zones = getarraykeys( level.zones[ str_zone ].adjacent_zones );
	i = 0;
	while ( i < a_adjacent_zones.size )
	{
		if ( level.zones[ str_zone ].adjacent_zones[ a_adjacent_zones[ i ] ].is_connected )
		{
			a_adjacencies[ a_adjacencies.size ] = a_adjacent_zones[ i ];
		}
		i++;
	}
	return a_adjacencies;
}

get_dog_locations_in_zones( a_zones )
{
	a_dog_locations = [];
	_a479 = a_zones;
	_k479 = getFirstArrayKey( _a479 );
	while ( isDefined( _k479 ) )
	{
		zone = _a479[ _k479 ];
		a_dog_locations = arraycombine( a_dog_locations, level.zones[ zone ].dog_locations, 0, 0 );
		_k479 = getNextArrayKey( _a479, _k479 );
	}
	return a_dog_locations;
}

get_farthest_dog_location( a_dog_locations )
{
	n_farthest_index = 0;
	n_distance_farthest = 0;
	i = 0;
	while ( i < a_dog_locations.size )
	{
		n_distance_sq = distancesquared( self.origin, a_dog_locations[ i ].origin );
		if ( n_distance_sq > n_distance_farthest )
		{
			n_distance_farthest = n_distance_sq;
			n_farthest_index = i;
		}
		i++;
	}
	return a_dog_locations[ n_farthest_index ];
}
