#include maps/mp/zombies/_zm_ai_basic;
#include maps/mp/zombies/_zm_spawner;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

zombie_tracking_init()
{
	level.zombie_respawned_health = [];
	if ( !isDefined( level.zombie_tracking_dist ) )
	{
		level.zombie_tracking_dist = 1000;
	}
	if ( !isDefined( level.zombie_tracking_high ) )
	{
		level.zombie_tracking_high = 500;
	}
	if ( !isDefined( level.zombie_tracking_wait ) )
	{
		level.zombie_tracking_wait = 10;
	}
	building_trigs = getentarray( "zombie_fell_off", "targetname" );
	if ( isDefined( building_trigs ) )
	{
		array_thread( building_trigs, ::zombies_off_building );
	}
	level.distance_tracker_aggressive_distance = 500;
	level.distance_tracker_aggressive_height = 200;
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
			if ( isDefined( zombies[ i ] ) && isDefined( zombies[ i ].ignore_distance_tracking ) && !zombies[ i ].ignore_distance_tracking )
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
	if ( !isDefined( how_close ) )
	{
		how_close = 1000;
	}
	if ( !isDefined( how_high ) )
	{
		how_high = 500;
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
	i = 0;
	while ( i < players.size )
	{
		if ( players[ i ].sessionstate == "spectator" )
		{
			i++;
			continue;
		}
		else if ( isDefined( level.only_track_targeted_players ) )
		{
			if ( !isDefined( self.favoriteenemy ) || self.favoriteenemy != players[ i ] )
			{
				i++;
				continue;
			}
		}
		else
		{
			can_be_seen = self player_can_see_me( players[ i ] );
			if ( can_be_seen && distancesquared( self.origin, players[ i ].origin ) < too_far_dist )
			{
				self.inview++;
			}
			if ( distancesquared( self.origin, players[ i ].origin ) < distance_squared_check && abs( self.origin[ 2 ] - players[ i ].origin[ 2 ] ) < how_high )
			{
				self.player_close++;
			}
		}
		i++;
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
			if ( self maymovetopoint( players[ i ].origin, 1 ) )
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
		if ( is_player_in_inverted_elevator_shaft() )
		{
			n_delete_distance = level.distance_tracker_aggressive_distance;
			n_delete_height = level.distance_tracker_aggressive_height;
		}
		if ( !isDefined( found_player ) && isDefined( self.completed_emerging_into_playable_area ) && self.completed_emerging_into_playable_area )
		{
			self thread delete_zombie_noone_looking( n_delete_distance, n_delete_height );
			self.zombie_path_bad = 1;
			self escaped_zombies_cleanup();
		}
		wait 0,1;
	}
}

is_player_in_inverted_elevator_shaft()
{
	b_player_is_in_elevator_shaft = 0;
	a_occupied_zones = get_occupied_zones();
	i = 0;
	while ( i < a_occupied_zones.size )
	{
		if ( issubstr( a_occupied_zones[ i ], "orange_elevator_shaft" ) )
		{
			b_player_is_in_elevator_shaft = 1;
		}
		i++;
	}
	return b_player_is_in_elevator_shaft;
}

get_occupied_zones()
{
	a_occupied_zones = [];
	i = 0;
	while ( i < level.active_zone_names.size )
	{
		if ( level.zones[ level.active_zone_names[ i ] ].is_occupied )
		{
			a_occupied_zones[ a_occupied_zones.size ] = level.active_zone_names[ i ];
		}
		i++;
	}
	return a_occupied_zones;
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

get_current_zone()
{
	str_zone = undefined;
	a_zones = getarraykeys( level.zones );
	_a310 = a_zones;
	_k310 = getFirstArrayKey( _a310 );
	while ( isDefined( _k310 ) )
	{
		zone = _a310[ _k310 ];
		i = 0;
		while ( i < level.zones[ zone ].volumes.size )
		{
			if ( self istouching( level.zones[ zone ].volumes[ i ] ) )
			{
				str_zone = zone;
			}
			i++;
		}
		_k310 = getNextArrayKey( _a310, _k310 );
	}
	return str_zone;
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
	_a345 = a_zones;
	_k345 = getFirstArrayKey( _a345 );
	while ( isDefined( _k345 ) )
	{
		zone = _a345[ _k345 ];
		a_dog_locations = arraycombine( a_dog_locations, level.zones[ zone ].dog_locations, 0, 0 );
		_k345 = getNextArrayKey( _a345, _k345 );
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

check_player_available()
{
	self notify( "_check_player_available" );
	self endon( "_check_player_available" );
	self endon( "death" );
	self endon( "goal" );
	self endon( "reaquire_player" );
	while ( self.zombie_path_bad )
	{
		if ( self can_zombie_see_any_player() )
		{
			self notify( "reaquire_player" );
		}
		wait randomfloatrange( 0,2, 0,5 );
	}
}

can_zombie_path_to_any_player()
{
	a_players = get_players();
	i = 0;
	while ( i < a_players.size )
	{
		if ( findpath( self.origin, a_players[ i ].origin ) )
		{
			return 1;
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
		if ( self maymovetopoint( a_players[ i ].origin, 1 ) )
		{
			return 1;
		}
		i++;
	}
	return 0;
}

zombies_off_building()
{
	while ( 1 )
	{
		self waittill( "trigger", who );
		if ( !isplayer( who ) && isDefined( who.is_leaper ) && !who.is_leaper )
		{
			zombies = getaiarray( "axis" );
			if ( ( zombies.size + level.zombie_total ) > 24 || ( zombies.size + level.zombie_total ) <= 24 && who.health >= who.maxhealth )
			{
				if ( isDefined( who.exclude_distance_cleanup_adding_to_total ) && !who.exclude_distance_cleanup_adding_to_total && isDefined( who.is_leaper ) && !who.is_leaper )
				{
					level.zombie_total++;
					if ( who.health < level.zombie_health )
					{
						level.zombie_respawned_health[ level.zombie_respawned_health.size ] = who.health;
					}
				}
			}
			who maps/mp/zombies/_zm_spawner::reset_attack_spot();
			who notify( "zombie_delete" );
			who dodamage( who.health + 666, who.origin, who );
			recalc_zombie_array();
		}
		wait 0,1;
	}
}
