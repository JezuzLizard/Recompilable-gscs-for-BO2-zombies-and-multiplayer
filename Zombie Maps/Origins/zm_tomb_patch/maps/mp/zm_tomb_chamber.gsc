#include maps/mp/zombies/_zm_laststand;
#include maps/mp/zombies/_zm_ai_basic;
#include maps/mp/zm_tomb_utility;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

main()
{
	level thread inits();
	level thread chamber_wall_change_randomly();
}

inits()
{
	a_walls = getentarray( "chamber_wall", "script_noteworthy" );
	_a24 = a_walls;
	_k24 = getFirstArrayKey( _a24 );
	while ( isDefined( _k24 ) )
	{
		e_wall = _a24[ _k24 ];
		e_wall.down_origin = e_wall.origin;
		e_wall.up_origin = ( e_wall.origin[ 0 ], e_wall.origin[ 1 ], e_wall.origin[ 2 ] + 1000 );
		_k24 = getNextArrayKey( _a24, _k24 );
	}
	level.n_chamber_wall_active = 0;
	flag_wait( "start_zombie_round_logic" );
	wait 3;
	_a40 = a_walls;
	_k40 = getFirstArrayKey( _a40 );
	while ( isDefined( _k40 ) )
	{
		e_wall = _a40[ _k40 ];
		e_wall moveto( e_wall.up_origin, 0,05 );
		e_wall connectpaths();
		_k40 = getNextArrayKey( _a40, _k40 );
	}
/#
	level thread chamber_devgui();
#/
}

chamber_devgui()
{
/#
	setdvarint( "chamber_wall", 5 );
	adddebugcommand( "devgui_cmd "Zombies/Tomb:1/Chamber:1/Fire:1" "chamber_wall 1"\n" );
	adddebugcommand( "devgui_cmd "Zombies/Tomb:1/Chamber:1/Air:2" "chamber_wall 2"\n" );
	adddebugcommand( "devgui_cmd "Zombies/Tomb:1/Chamber:1/Lightning:3" "chamber_wall 3"\n" );
	adddebugcommand( "devgui_cmd "Zombies/Tomb:1/Chamber:1/Water:4" "chamber_wall 4"\n" );
	adddebugcommand( "devgui_cmd "Zombies/Tomb:1/Chamber:1/None:5" "chamber_wall 0"\n" );
	level thread watch_chamber_wall();
#/
}

watch_chamber_wall()
{
/#
	while ( 1 )
	{
		if ( getDvarInt( #"763A3046" ) != 5 )
		{
			chamber_change_walls( getDvarInt( #"763A3046" ) );
			setdvarint( "chamber_wall", 5 );
		}
		wait 0,05;
#/
	}
}

cap_value( val, min, max )
{
	if ( val < min )
	{
		return min;
	}
	else
	{
		if ( val > max )
		{
			return max;
		}
		else
		{
			return val;
		}
	}
}

chamber_wall_dust()
{
	i = 1;
	while ( i <= 9 )
	{
		playfxontag( level._effect[ "crypt_wall_drop" ], self, "tag_fx_dust_0" + i );
		wait_network_frame();
		i++;
	}
}

chamber_change_walls( n_element )
{
	if ( n_element == level.n_chamber_wall_active )
	{
		return;
	}
	e_current_wall = undefined;
	e_new_wall = undefined;
	playsoundatposition( "zmb_chamber_wallchange", ( 10342, -7921, -272 ) );
	a_walls = getentarray( "chamber_wall", "script_noteworthy" );
	_a123 = a_walls;
	_k123 = getFirstArrayKey( _a123 );
	while ( isDefined( _k123 ) )
	{
		e_wall = _a123[ _k123 ];
		if ( e_wall.script_int == n_element )
		{
			e_wall thread move_wall_down();
		}
		else
		{
			if ( e_wall.script_int == level.n_chamber_wall_active )
			{
				e_wall thread move_wall_up();
			}
		}
		_k123 = getNextArrayKey( _a123, _k123 );
	}
	level.n_chamber_wall_active = n_element;
}

is_chamber_occupied()
{
	a_players = getplayers();
	_a142 = a_players;
	_k142 = getFirstArrayKey( _a142 );
	while ( isDefined( _k142 ) )
	{
		e_player = _a142[ _k142 ];
		if ( is_point_in_chamber( e_player.origin ) )
		{
			return 1;
		}
		_k142 = getNextArrayKey( _a142, _k142 );
	}
	return 0;
}

is_point_in_chamber( v_origin )
{
	if ( !isDefined( level.s_chamber_center ) )
	{
		level.s_chamber_center = getstruct( "chamber_center", "targetname" );
		level.s_chamber_center.radius_sq = level.s_chamber_center.script_float * level.s_chamber_center.script_float;
	}
	return distance2dsquared( level.s_chamber_center.origin, v_origin ) < level.s_chamber_center.radius_sq;
}

chamber_wall_change_randomly()
{
	flag_wait( "start_zombie_round_logic" );
	a_element_enums = array( 1, 2, 3, 4 );
	level endon( "stop_random_chamber_walls" );
	n_elem_prev = undefined;
	while ( 1 )
	{
		while ( !is_chamber_occupied() )
		{
			wait 1;
		}
		flag_wait( "any_crystal_picked_up" );
		n_round = cap_value( level.round_number, 10, 30 );
		f_progression_pct = ( n_round - 10 ) / ( 30 - 10 );
		n_change_wall_time = lerpfloat( 15, 5, f_progression_pct );
		n_elem = random( a_element_enums );
		arrayremovevalue( a_element_enums, n_elem, 0 );
		if ( isDefined( n_elem_prev ) )
		{
			a_element_enums[ a_element_enums.size ] = n_elem_prev;
		}
		chamber_change_walls( n_elem );
		wait n_change_wall_time;
		n_elem_prev = n_elem;
	}
}

move_wall_up()
{
	self moveto( self.up_origin, 1 );
	self waittill( "movedone" );
	self connectpaths();
}

move_wall_down()
{
	self moveto( self.down_origin, 1 );
	self waittill( "movedone" );
	rumble_players_in_chamber( 2, 0,1 );
	self thread chamber_wall_dust();
	self disconnectpaths();
}

random_shuffle( a_items, item )
{
	b_done_shuffling = undefined;
	if ( !isDefined( item ) )
	{
		item = a_items[ a_items.size - 1 ];
	}
	while ( isDefined( b_done_shuffling ) && !b_done_shuffling )
	{
		a_items = array_randomize( a_items );
		if ( a_items[ 0 ] != item )
		{
			b_done_shuffling = 1;
		}
		wait 0,05;
	}
	return a_items;
}

tomb_chamber_find_exit_point()
{
	self endon( "death" );
	player = get_players()[ 0 ];
	dist_zombie = 0;
	dist_player = 0;
	dest = 0;
	away = vectornormalize( self.origin - player.origin );
	endpos = self.origin + vectorScale( away, 600 );
	locs = array_randomize( level.enemy_dog_locations );
	i = 0;
	while ( i < locs.size )
	{
		dist_zombie = distancesquared( locs[ i ].origin, endpos );
		dist_player = distancesquared( locs[ i ].origin, player.origin );
		if ( dist_zombie < dist_player )
		{
			dest = i;
			break;
		}
		else
		{
			i++;
		}
	}
	self notify( "stop_find_flesh" );
	self notify( "zombie_acquire_enemy" );
	if ( isDefined( locs[ dest ] ) )
	{
		self setgoalpos( locs[ dest ].origin );
	}
	self.b_wandering_in_chamber = 1;
	flag_wait( "player_active_in_chamber" );
	self.b_wandering_in_chamber = 0;
	self thread maps/mp/zombies/_zm_ai_basic::find_flesh();
}

chamber_zombies_find_poi()
{
	zombies = getaiarray( level.zombie_team );
	i = 0;
	while ( i < zombies.size )
	{
		if ( isDefined( zombies[ i ].b_wandering_in_chamber ) && zombies[ i ].b_wandering_in_chamber )
		{
			i++;
			continue;
		}
		else
		{
			if ( !is_point_in_chamber( zombies[ i ].origin ) )
			{
				i++;
				continue;
			}
			else
			{
				zombies[ i ] thread tomb_chamber_find_exit_point();
			}
		}
		i++;
	}
}

tomb_is_valid_target_in_chamber()
{
	a_players = getplayers();
	_a322 = a_players;
	_k322 = getFirstArrayKey( _a322 );
	while ( isDefined( _k322 ) )
	{
		e_player = _a322[ _k322 ];
		if ( e_player maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
		{
		}
		else if ( isDefined( e_player.b_zombie_blood ) || e_player.b_zombie_blood && isDefined( e_player.ignoreme ) && e_player.ignoreme )
		{
		}
		else
		{
			if ( !is_point_in_chamber( e_player.origin ) )
			{
				break;
			}
			else
			{
				return 1;
			}
		}
		_k322 = getNextArrayKey( _a322, _k322 );
	}
	return 0;
}

is_player_in_chamber()
{
	if ( is_point_in_chamber( self.origin ) )
	{
		return 1;
	}
	else
	{
		return 0;
	}
}

tomb_watch_chamber_player_activity()
{
	flag_init( "player_active_in_chamber" );
	flag_wait( "start_zombie_round_logic" );
	while ( 1 )
	{
		wait 1;
		if ( is_chamber_occupied() )
		{
			if ( tomb_is_valid_target_in_chamber() )
			{
				flag_set( "player_active_in_chamber" );
				break;
			}
			else
			{
				flag_clear( "player_active_in_chamber" );
				chamber_zombies_find_poi();
			}
		}
	}
}
